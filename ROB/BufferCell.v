module BufferCell (

    // Control
    input 
        clock,
        wEn,
        reset_sync,
        reset_async,

    input
        ready_in,

    output
        free,
        outReady,

    // Adding Instruction and Values
    input[31:0]
        inInstr,
        inVal,

    // Getting the instructions out of the ROB
    output[31:0]
        outInstr,
        outVal);

    dflipflop readyFlop(.q(outReady), .d(ready_in & !reset_sync), .clk(clock), .en(wEn | reset_async), .clr(reset_async));

    assign free = ~|outInstr;

    register instrReg(.in(reset_sync ? 32'd0 : inInstr), .en(wEn | reset_sync), .clk(clock), .clr(reset), .out(outInstr));

    register valReg(.in(reset_sync ? 32'd0 : inVal), .en(wEn | reset_sync), .clk(clock), .clr(reset), .out(outVal));

endmodule