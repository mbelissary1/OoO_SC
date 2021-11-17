module ROB #(parameter SIZE=32) (
    input 
        clock,
        reset,
        push,
        pop,
        finishing_instr,

    output
        is_full,
        is_empty,

    input[31:0] 
        instr_to_finish,
        finish_val,

    input[31:0]
        instr_to_flush,
    input
        flushing_instr,

    input[31:0] 
        instr_in, 
        
    output[31:0]
        head_instr,
        head_val,

    output
        head_ready);


    wire[SIZE-1:0] free_list;
    assign is_full = ~|free_list & ~|reset_list;
    assign is_empty = &free_list;

    wire[SIZE-1:0] 
        move_list,
        match_list,
        head_list,
        reset_list,
        wEn_list,
        flush_match_list,
        flush_list;

    wire [SIZE-1:0]
        currIterReady,
        nextIterReady,
        nextIterFree;
        
    wire [31:0]
        currIterVals[SIZE-1:0],
        nextIterVals[SIZE-1:0],
        currIterInstrs[SIZE-1:0],
        nextIterInstrs[SIZE-1:0];

    genvar i;
    for (i=0; i < SIZE; i=i+1) begin

        wire[31:0] currInstr = currIterInstrs[i];

        if (!i) begin
            assign head_list[i] = !free_list[i];
            assign move_list[i] = free_list[i] | |reset_list;
            assign match_list[i] = finishing_instr & |nextIterInstrs[i] & (instr_to_finish == nextIterInstrs[i]);
            assign flush_match_list[i] = |nextIterInstrs[i] & (instr_to_flush == nextIterInstrs[i]);
            assign flush_list[i] = 1'b0;

        end else begin
            assign head_list[i] = ~|head_list[i-1:0] & !free_list[i];
            assign move_list[i] = |free_list[i-1:0] | |reset_list;
            assign match_list[i] = finishing_instr & ~|match_list[i-1:0] & |nextIterInstrs[i] & (instr_to_finish == nextIterInstrs[i]);
            assign flush_match_list[i] = ~|flush_match_list[i-1:0] & |nextIterInstrs[i] & (instr_to_flush == nextIterInstrs[i]);
            assign flush_list[i] = |flush_match_list[i-1:0];

        end

       if (i != SIZE-1) begin
            assign nextIterFree[i] = move_list[i] ? free_list[i+1] : free_list[i];
            assign nextIterReady[i] = (match_list[i] & finishing_instr) | (move_list[i] ? (reset_list[i+1] ? 32'd0 : currIterReady[i+1]) : currIterReady[i]);
            assign nextIterVals[i] = (match_list[i] & finishing_instr) ? finish_val : (move_list[i] ? (reset_list[i+1] ? 32'd0 : currIterVals[i+1]) : currIterVals[i]);
            assign nextIterInstrs[i] = move_list[i] ? (reset_list[i+1] ? 32'd0 : currIterInstrs[i+1]) : currIterInstrs[i];
            assign reset_list[i] = pop & currIterReady[i] & head_list[i];
            assign wEn_list[i] = 1'b1;
        end else begin
            assign nextIterFree[i] = move_list[i] ? 1'b1 : free_list[i];
            assign nextIterReady[i] = move_list[i] ? 1'b0 : ((match_list[i] & finishing_instr) | currIterReady[i]);
            assign nextIterVals[i] = (match_list[i] & finishing_instr) ? finish_val : (move_list[i] ? 32'd0 : currIterVals[i]);
            assign nextIterInstrs[i] = move_list[i] ? (nextIterFree[i] ? instr_in : 32'd0) : currIterInstrs[i];
            assign reset_list[i] = pop & currIterReady[i] & head_list[i];
            assign wEn_list[i] = 1'b1;
        end

        triBuff instrBuff(.in(currIterInstrs[i]), .oe(head_list[i]), .out(head_instr));
        triBuff valBuff(.in(currIterVals[i]), .oe(head_list[i]), .out(head_val));
        triBuff  #(.SIZE(1)) readyBuff(.in(currIterReady[i]), .oe(head_list[i]), .out(head_ready));

        BufferCell myCell(
            .clock(clock), 
            .reset_async(reset), 
            .reset_sync(flush_list[i]),
            
            .ready_in(nextIterReady[i]),

            .wEn(wEn_list[i]), 
            .inInstr(nextIterInstrs[i]),
            .inVal(nextIterVals[i]),

            .free(free_list[i]),
            .outReady(currIterReady[i]),

            .outInstr(currIterInstrs[i]),
            .outVal(currIterVals[i]));
    end

    triBuff defInstrBuff(.in(32'b0), .oe(~|head_list), .out(head_instr));
    triBuff defValBuff(.in(32'b0), .oe(~|head_list), .out(head_val));
    triBuff  #(.SIZE(1)) defReadyBuff(.in(1'b0), .oe(~|head_list), .out(head_ready));

endmodule