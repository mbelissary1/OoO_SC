module ROB #(parameter SIZE=32, NUM_BYPASS=4) (
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
    input[4:0]
        rd_in,

    input[4:0]
        rd_search_0,
        rd_search_1,
        rd_search_2,
        rd_search_3,
    
    output[31:0]
        bypass_val_0,
        bypass_val_1,
        bypass_val_2,
        bypass_val_3,
        
    output[31:0]
        head_instr,
        head_val,

    output
        head_ready);

    wire[SIZE-1:0] 
        move_list,
        free_list,
        ready_list,
        head_list,
        reset_list,
        finish_match_list,
        flush_match_list,
        flush_list,
        finish_list,
        bypass_match_list[NUM_BYPASS-1:0];

    assign is_full = ~|free_list;
    assign is_empty = &free_list;
    
    wire [31:0]
        instrs[SIZE-1:0],
        vals[SIZE-1:0];
    
    wire [4:0]
        rds[SIZE-1:0];

    wire wEn = 1'b1;

    wire[31:0] bypass_vals[NUM_BYPASS-1:0];
    assign bypass_val_0 = bypass_vals[0];
    assign bypass_val_1 = bypass_vals[1];
    assign bypass_val_2 = bypass_vals[2];
    assign bypass_val_3 = bypass_vals[3];

    wire[4:0] rd_searches[NUM_BYPASS-1:0];
    assign rd_searches[0] = rd_search_0;
    assign rd_searches[1] = rd_search_1;
    assign rd_searches[2] = rd_search_2;
    assign rd_searches[3] = rd_search_3;

    genvar i, j;
    for (i=0; i < SIZE; i=i+1) begin

        assign flush_match_list[i] = (instrs[i] == instr_to_flush) & flushing_instr;
        assign finish_match_list[i] = (instr_to_finish == instrs[i]) & finishing_instr & |instrs[i];

        // The First Cell 
        if(!i) begin
            assign move_list[i] = 0;
            assign head_list[i] = !free_list[i];
            assign flush_list[i] = 1'b0;
        end else begin
            assign move_list[i] = |free_list[i-1:0]; 
            assign head_list[i] = !free_list[i] & ~|head_list[i-1:0];
            assign flush_list[i] = (|flush_match_list[i-1:0] | (flush_match_list[i] & move_list[i])) & flushing_instr;
        end

        // All but the last cell
        if (i<SIZE-1) begin

            assign reset_list[i] = (pop & ((head_list[i] & !move_list[i] & ready_list[i]) | (head_list[i+1] & move_list[i+1] & ready_list[i+1]))) | flush_list[i];
            assign finish_list[i] = (move_list[i] | move_list[i+1]) ? finish_match_list[i+1] : finish_match_list[i];

            for (j=0; j < NUM_BYPASS; j=j+1) begin
                assign bypass_match_list[j][i] = (rds[i] == rd_searches[j]) & ~|bypass_match_list[j][SIZE-1:i+1] & ready_list[i];
            end

            BufferCell myCell(
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .free(free_list[i]),
                .just_finished(finish_list[i]),

                .instr_in(instrs[i+1]),
                .ready_in(finish_list[i] | ready_list[i+1]),
                .val_in(finish_list[i] ? finish_val : vals[i+1]),
                .rd_in(rds[i+1]),

                .instr_out(instrs[i]),
                .ready_out(ready_list[i]),
                .val_out(vals[i]),
                .rd_out(rds[i])
            );

        end else begin

            for (j=0; j < NUM_BYPASS; j=j+1) begin
                assign bypass_match_list[j][i] = rds[i] == rd_searches[j] & ready_list[i];
            end

            assign reset_list[i] = (pop & head_list[i] & !move_list[i] & ready_list[i]) | flush_list[i];
            assign finish_list[i] = !move_list[i] & finish_match_list[i];

            BufferCell myCell(
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .free(free_list[i]),
                .just_finished(finish_list[i]),

                .instr_in((!is_full & push) ? instr_in : 5'b0),
                .ready_in((!is_full & push) ? 1'b0 : finish_list[i]),
                .rd_in((!is_full & push) ? rd_in : 5'b0),
                .val_in((!is_full & push) ? 32'b0 : (finish_list[i] ? finish_val : vals[i])),

                .instr_out(instrs[i]),
                .ready_out(ready_list[i]), 
                .val_out(vals[i]),
                .rd_out(rds[i])
            );
        end

        for (j=0; j < NUM_BYPASS; j=j+1) begin
            triBuff bypassBuff(.in(vals[i]), .oe(bypass_match_list[j][i]), .out(bypass_vals[j]));
        end

        triBuff instrBuff(.in(instrs[i]), .oe(head_list[i]), .out(head_instr));
        triBuff valBuff(.in(vals[i]), .oe(head_list[i]), .out(head_val));
        triBuff #(.SIZE(1)) ReadyBuff(.in(ready_list[i]), .oe(head_list[i]), .out(head_ready));
    end

    for (j=0; j < NUM_BYPASS; j=j+1) begin
        wire[SIZE-1:0] bypass_match = bypass_match_list[j];
        triBuff defBypassBuff(.in(32'b0), .oe(~|bypass_match_list[j]), .out(bypass_vals[j]));
    end
    triBuff defInstrBuff(.in(32'b0), .oe(~|head_list), .out(head_instr));
    triBuff defValBuff(.in(32'b0), .oe(~|head_list), .out(head_val));
    triBuff  #(.SIZE(1)) defReadyBuff(.in(1'b0), .oe(~|head_list), .out(head_ready));

endmodule