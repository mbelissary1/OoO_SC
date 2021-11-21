module BufferCell (

    // Control
    input 
        clock,
        wEn,
        reset_sync,
        reset_async,

    input
        ready_in,
        can_move,
        just_finished,

    output
        free,
        ready_out,

    // Adding Instruction and Values
    input[31:0]
        instr_in,
        val_in,
    input[4:0]    
        rd_in,

    // Getting the instructions out of the ROB
    output[31:0]
        instr_out,
        val_out,
    output[4:0]
        rd_out);

    assign free = ~|instr_out;

    dflipflop readyFlop(.q(ready_out), .d(((can_move ? ready_in : ready_out) | just_finished) & !reset_sync), .clk(clock), .en(wEn | reset_sync | just_finished), .clr(reset_async));
  
    register instrReg(.in(reset_sync ? 32'd0 : ((can_move | free) ? instr_in : instr_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(instr_out));
    register valReg(.in(reset_sync ? 32'd0 : ((can_move | free | just_finished) ? val_in : val_out)), .en(wEn | reset_sync | just_finished), .clk(clock), .clr(reset_async), .out(val_out));

    register #(.SIZE(5)) rdReg(.in(reset_sync ? 5'd0 : ((can_move | free) ? rd_in : rd_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(rd_out));

endmodule