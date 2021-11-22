module multiCycleInsnSim #(parameter LATENCY=8, SIZE=32) (instrIn, clock, enable, reset, instrOut, instrRDY);
    input clock, enable, reset;
    input[SIZE-1:0] instrIn;

    output insnRDY;
    output[SIZE-1:0] instrOut;

    wire[SIZE-1:0] register_d[LATENCY-1:0];
    wire[SIZE-1:0] register_q[LATENCY-1:0];

    assign register_d[0] = instrIn;
    assign register_q[0] = startRegOut;

    reg32 startRegister(.q(register_q[0]), .d(register_d[0]), .clk(clock), .en(enable), .clr(reset));

    genvar i;
    generate
        for (i=1; i < LATENCY-1; i++) begin
            reg32 registers(.q(register_q[i]), .d(register_d[i-1]), .clk(clock), .en(enable), .clr(reset));
        end
    endgenerate

    reg32 endRegister(.q(instrOut), .d(register_d[LATENCY-2]), .clk(clock), .en(enable), .clr(reset));

    if (instrIn == instrOut) begin
        assign instrRDY = 1'b1;
    end

endmodule