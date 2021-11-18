module rng(random_number, clk);
    input clk;
    output[1:0] random_number;
    
    reg initial_cycle = 1;
    always @ (posedge clk) begin // TODO: Make sure this works, and if not swap to posedge
        initial_cycle <= 0;
    end

    wire q_0, q_not_0, d_0;
    assign d_0 = q_8 ^ q_9;
    dffe_ref flip_flop_0(q_0, q_not_0, initial_cycle ? 1'b1 : d_0, clk, 1'b1, 1'b0);

    wire q_1, q_not_1;
    dffe_ref flip_flop_1(q_1, q_not_1, q_0, clk, 1'b1, 1'b0);

    wire q_2, q_not_2;
    dffe_ref flip_flop_2(q_2, q_not_2, q_1, clk, 1'b1, 1'b0);

    wire q_3, q_not_3;
    dffe_ref flip_flop_3(q_3, q_not_3, q_2, clk, 1'b1, 1'b0);

    wire q_4, q_not_4;
    dffe_ref flip_flop_4(q_4, q_not_4, q_3, clk, 1'b1, 1'b0);

    wire q_5, q_not_5;
    dffe_ref flip_flop_5(q_5, q_not_5, q_4, clk, 1'b1, 1'b0);

    wire q_6, q_not_6;
    dffe_ref flip_flop_6(q_6, q_not_6, q_5, clk, 1'b1, 1'b0);

    wire q_7, q_not_7;
    dffe_ref flip_flop_7(q_7, q_not_7, q_6, clk, 1'b1, 1'b0);

    wire q_8, q_not_8;
    dffe_ref flip_flop_8(q_8, q_not_8, q_7, clk, 1'b1, 1'b0);

    wire q_9, q_not_9;
    dffe_ref flip_flop_9(q_9, q_not_9, q_8, clk, 1'b1, 1'b0);

    wire q_10, q_not_10;
    dffe_ref flip_flop_10(q_10, q_not_10, q_9, clk, 1'b1, 1'b0);

    assign random_number[1] = q_6;
    assign random_number[0] = q_4;
endmodule