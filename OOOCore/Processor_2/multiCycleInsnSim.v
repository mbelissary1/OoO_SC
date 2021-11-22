module multiCycleInsnSim #(parameter LATENCY=4, SIZE=32) (instrIn, clock, enable, reset, instrOut, instrRDY);
    input clock, enable, reset;
    input[SIZE-1:0] instrIn;

    output instrRDY;
    output[SIZE-1:0] instrOut;

    wire[SIZE-1:0] register_list[LATENCY-1:0];

    assign register_list[0] = instrIn;

    genvar i;
    generate
        for (i=1; i < LATENCY; i=i+1) begin
            reg32 registers(.q(register_list[i]), .d(register_list[i-1]), .clk(clock), .en(enable), .clr(reset));
        end
    endgenerate

    assign instrOut = register_list[LATENCY-1];
    assign instrRDY = (instrOut == instrIn);

endmodule