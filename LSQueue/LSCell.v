module LSCell (

    // Control
    input 
        clock,
        wEn,
        reset_sync,
        reset_async,

    input
        can_move,

    output
        free,

    // Adding Instruction and Values
    input[31:0]
        instr_in,

    // Getting the instructions out of the Scoreboard
    output[31:0]
        instr_out
    );

    assign free = ~|instr_out;
  
    register instrReg(.in(reset_sync ? 32'd0 : ((can_move | free) ? instr_in : instr_out)), .en(wEn | reset_sync), .clk(clock), .clr(reset_async), .out(instr_out));
endmodule