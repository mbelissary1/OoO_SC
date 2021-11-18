module reg_32(q, d, clk, en, clr);
    input[31:0] d;
    input clk, en, clr;

    output[31:0] q;

    wire[31:0] q_not;

    dffe_ref registers[31:0](q, q_not, d, clk, en, clr);
endmodule