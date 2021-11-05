`timescale 1ns/100ps
module booth_mult_tb;
    wire[31:0] result;
    reg[31:0] multiplicand, multiplier;
    wire data_result_ready, overflow, init;
    reg clk, reset;
    wire[64:0] val;
    
    booth_mult mult(result, data_result_ready, overflow, multiplicand, multiplier, clk, reset, init, val);
    
    initial begin
        multiplicand = 32'b11111111111111111111111111111011;
        multiplier = 32'b11111111111111111111111111111101;
        clk=0;
        reset=0;
        #2048;
        $finish;
    end
    
    always
    #10 clk = ~clk;
    
    always @(posedge clk) begin
        #1
        $display("top: %b, bottom: %b,  init: %b", val[64:33], val[32:0], init);
    end
endmodule