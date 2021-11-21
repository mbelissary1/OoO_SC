module ScoreboardCell (

    // Control
    input 
        clock,
        wEn,
        reset_sync,
        reset_async,

    input
        can_move,
        start,
        running_in,

    output
        free,
        running,

    // Adding Instruction and Values
    input[31:0]
        instr_in,
        pc_in,

    input[4:0]
        rs1_in, 
        rs2_in,
        rd_in,

    // Getting the instructions out of the Scoreboard
    output[31:0]
        instr_out,
        pc_out,
    output[4:0] 
        rs1_out, 
        rs2_out,
        rd_out
    );

    assign free = ~|instr_out;

    dflipflop runningFlop(.q(running), .d((((can_move | free) ? running_in : running) | start) & !reset_sync), .clk(clock), .en(wEn | reset_sync), .clr(reset_async));
  
    register instrReg(.in(reset_sync ? 32'd0 : ((can_move | free) ? instr_in : instr_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(instr_out));
    register pcReg(.in(reset_sync ? 32'd0 : ((can_move | free) ? pc_in : pc_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(pc_out));

    register #(.SIZE(5)) rs1Reg(.in(reset_sync ? 5'd0 : ((can_move | free) ? rs1_in : rs1_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(rs1_out));
    register #(.SIZE(5)) rs2Reg(.in(reset_sync ? 5'd0 : ((can_move | free) ? rs2_in : rs2_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(rs2_out));
    register #(.SIZE(5)) rdReg(.in(reset_sync ? 5'd0 : ((can_move | free) ? rd_in : rd_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(rd_out));
endmodule