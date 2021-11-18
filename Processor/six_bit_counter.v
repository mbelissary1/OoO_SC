module six_bit_counter(cur_val, clk, reset);
    input clk, reset;

    output[5:0] cur_val;

    wire q_not_d0, q_not_d1, q_not_d2, q_not_d3, q_not_d4, q_not_d5;

    dffe_ref d_0(cur_val[0], q_not_d0, q_not_d0, clk, 1'b1, reset);
    dffe_ref d_1(cur_val[1], q_not_d1, q_not_d1, q_not_d0, 1'b1, reset);
    dffe_ref d_2(cur_val[2], q_not_d2, q_not_d2, q_not_d1, 1'b1, reset);
    dffe_ref d_3(cur_val[3], q_not_d3, q_not_d3, q_not_d2, 1'b1, reset);
    dffe_ref d_4(cur_val[4], q_not_d4, q_not_d4, q_not_d3, 1'b1, reset);
    dffe_ref d_5(cur_val[5], q_not_d5, q_not_d5, q_not_d4, 1'b1, reset);

endmodule