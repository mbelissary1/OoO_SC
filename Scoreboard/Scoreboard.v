module Scoreboard #(parameter SIZE=32) (
    input 
        clock,
        reset,
        push,
        start_head,
        committing_instr,

    output
        is_full,
        is_empty,

    input[31:0]
        instr_to_finish,
        lsq_head,

    input[31:0]
        instr_to_flush,
    input
        flushing_instr,

    input[31:0] 
        instr_in, 
        pc_in,
    input[4:0]
        rd_in,
        rs1_in,
        rs2_in,
        
    output[31:0]
        head_instr,
        head_pc,

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
        running_list,
        start_list,
        multicycle_list,
        mem_list;

    assign is_full = ~|free_list;
    assign is_empty = &free_list;
    
    wire [31:0]
        instrs[SIZE-1:0],
        pcs[SIZE-1:0];
    
    wire [4:0]
        rds[SIZE-1:0],
        rs1s[SIZE-1:0],
        rs2s[SIZE-1:0];

    wire wEn = 1'b1;



    genvar i, j;
    for (i=0; i < SIZE; i=i+1) begin

        assign flush_match_list[i] = (instrs[i] == instr_to_flush) & flushing_instr;
        assign finish_match_list[i] = (instr_to_finish == instrs[i]) & committing_instr;
        IsMulticycle instrChecker(instrs[i], multicycle_list[i], mem_list[i]);

        // The First Cell 
        if(!i) begin
            assign move_list[i] = 0;
            assign ready_list[i] = !free_list[i];
            assign head_list[i] = !running_list[i] & ready_list[i];
            assign flush_list[i] = 1'b0;
        end else begin
            assign move_list[i] = |free_list[i-1:0]; 
            wire[i-1:0]
                rs1_match_list,
                rs2_match_list;
            for (j=0; j < i; j=j+1) begin
                assign rs1_match_list[j] = (rs1s[i] == rds[j]) & (!running_list[j] | multicycle_list[j]);
                assign rs2_match_list[j] = (rs2s[i] == rds[j]) & (!running_list[j] | multicycle_list[j]);
            end
            assign ready_list[i] = (~|rs1_match_list & ~|rs2_match_list & !free_list[i]) & (!mem_list[i] | lsq_head == instrs[i]);
            assign head_list[i] = !running_list[i] & ready_list[i] & ~|head_list[i-1:0];
            assign flush_list[i] = (|flush_match_list[i-1:0] 
                                    | (flush_match_list[i] & move_list[i])) 
                                    & flushing_instr;
        end

        // All but the last cell
        if (i<SIZE-1) begin

            assign reset_list[i] = (committing_instr & ((finish_match_list[i] & !move_list[i]) 
                                    | (finish_match_list[i+1] & move_list[i+1]))) 
                                    | flush_list[i];
            assign start_list[i] = ((head_list[i] & !move_list[i]) 
                                    | (head_list[i+1] & move_list[i+1])) 
                                    & start_head;

            ScoreboardCell myCell(
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .start(start_list[i]),                
                .free(free_list[i]),

                .running_in(running_list[i+1]),
                .instr_in(instrs[i+1]),
                .pc_in(pcs[i+1]),
                .rs1_in(rs1s[i+1]), 
                .rs2_in(rs2s[i+1]),
                .rd_in(rds[i+1]),

                .running(running_list[i]),
                .instr_out(instrs[i]),
                .pc_out(pcs[i]),
                .rs1_out(rs1s[i]), 
                .rs2_out(rs2s[i]),
                .rd_out(rds[i])
            );

        end else begin

            assign start_list[i] = head_list[i] 
                                    & !move_list[i] & start_head;
            assign reset_list[i] = (committing_instr & finish_match_list[i] 
                                    & !move_list[i]) 
                                    | flush_list[i];

            ScoreboardCell myCell(
                .clock(clock),
                .wEn(wEn),
                .reset_sync(reset_list[i]),
                .reset_async(reset),

                .can_move(move_list[i]),
                .free(free_list[i]),
                .start(start_list[i]),

                .running_in(1'b0),
                .instr_in((!is_full & push) ? instr_in : 5'b0),
                .pc_in((!is_full & push) ? pc_in : 5'b0),
                .rs1_in((!is_full & push) ? rs1_in : 5'b0),
                .rs2_in((!is_full & push) ? rs2_in : 5'b0),
                .rd_in((!is_full & push) ? rd_in : 5'b0),

                .running(running_list[i]),
                .instr_out(instrs[i]),
                .pc_out(pcs[i]),
                .rs1_out(rs1s[i]), 
                .rs2_out(rs2s[i]),
                .rd_out(rds[i])
            );
        end

        triBuff instrBuff(.in(instrs[i]), .oe(head_list[i]), .out(head_instr));
        triBuff pcBuff(.in(pcs[i]), .oe(head_list[i]), .out(head_pc));

        triBuff #(.SIZE(1)) ReadyBuff(.in(ready_list[i]), .oe(head_list[i]), .out(head_ready));
    end

    triBuff defInstrBuff(.in(32'b0), .oe(~|head_list), .out(head_instr));
    triBuff defPCBuff(.in(32'b0), .oe(~|head_list), .out(head_pc));
    triBuff  #(.SIZE(1)) defReadyBuff(.in(1'b0), .oe(~|head_list), .out(head_ready));

endmodule