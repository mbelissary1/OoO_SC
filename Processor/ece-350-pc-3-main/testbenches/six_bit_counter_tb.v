`timescale 1ns/1ps
module six_bit_counter_tb;
    // Module instantiation
    reg clk, reset; // Inputs to the module (reg)
    wire [5:0] cur_val; // Outputs of the module (wire)

    five_bit_counter five_bit_counter(.cur_val(cur_val), .clk(clk), .reset(reset)); // Instantiate the module to test

    // Input initialization
    // Initialize the inputs and specify the runtime
    initial begin
        // Initialize the inputs to zero
        clk = 1'b0;
        reset = 1'b1;
        #1290; // Set a time-delay in nanoseconds

        $finish; // Ends the testbench
    end

    // Input manipulation
    always
        #10 clk = ~clk; // Toggle input clk every 10 nanoseconds
    always
        #640 reset = ~reset; // Toggle input B[0] every 20 nanoseconds

    // Output results
    always @(clk) begin
        #1; // Small delay so the outputs can stabilize
        $display("clk:%b, reset:%b => cur_val:%b", clk, reset, cur_val);
    end

    // Generate waveform
    initial begin
        $dumpfile("five_bit_counter_waveform.vcd");
        $dumpvars(0, five_bit_counter_tb);
    end
endmodule