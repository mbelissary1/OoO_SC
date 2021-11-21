module LSQueue #(parameter SIZE=32) (
    input 
        clock,
        reset,
        push,
        pop,

    output
        is_full,
        is_empty,

    input[31:0]
        instr_to_flush,
    input
        flushing_instr,

    input[31:0] 
        instr_in, 
        
    output[31:0]
        head_instr);

    wire[SIZE-1:0] 
        move_list,
        free_list,
        head_list,
        reset_list,
        finish_match_list,
        flush_match_list,
        flush_list;

    assign is_full = ~|free_list;
    assign is_empty = &free_list;
    
    wire [31:0]
        instrs[SIZE-1:0],
        pcs[SIZE-1:0];

    wire wEn = 1'b1;

    genvar i, j;
    for (i=0; i < SIZE; i=i+1) begin

        assign flush_match_list[i] = (instrs[i] == instr_to_flush) & flushing_instr;

        // The First Cell 
        if(!i) begin
            assign move_list[i] = 0;
            assign head_list[i] = !free_list[i];
            assign flush_list[i] = (pop & head_list[i]) | flush_match_list;
        end else begin
            assign move_list[i] = |free_list[i-1:0]; 
            assign head_list[i] = ~|head_list[i-1:0] & !free_list[i];

            if (i)
            assign flush_list[i] = |flush_match_list[i-1:0] 
                | (move_list[i] & flush_match_list[i]);
        end

        // All but the last cell
        if (i<SIZE-1) begin

            assign reset_list[i] = flush_list[i] |  (move_list ? (head_list[i+1] & pop) : (head_list[i] & pop));

            LSCell myCell(
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .free(free_list[i]),

                .instr_in(instrs[i+1]),

                .instr_out(instrs[i])
            );

        end else begin

            assign reset_list[i] = flush_list[i] | (!move_list[i] & head_list[i] & pop);

            LSCell myCell (
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .free(free_list[i]),

                .instr_in((!is_full & push) ? instr_in : 5'b0),

                .instr_out(instrs[i])
            );
        end

        triBuff instrBuff(.in(instrs[i]), .oe(head_list[i]), .out(head_instr));
    end

    triBuff defInstrBuff(.in(32'b0), .oe(~|head_list), .out(head_instr));
endmodule