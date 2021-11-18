module reg_64(q, q_not, d, clk, en, clr);
    input[63:0] d;
    input clk, en, clr;

    output[63:0] q, q_not;

    dffe_ref registers[63:0](q, q_not, d, clk, en, clr);
endmodule