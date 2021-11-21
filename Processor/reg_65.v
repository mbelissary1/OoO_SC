module reg_65(q, q_not, d, clk, en, clr);
    input[64:0] d;
    input clk, en, clr;

    output[64:0] q, q_not;

    dffe_ref registers[64:0](q, q_not, d, clk, en, clr);
endmodule