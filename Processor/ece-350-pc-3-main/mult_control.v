module mult_control(data_result_ready, processed_multiplicand, carry_in, initial_cycle, booth_opcode, multiplicand, clk, reset);
    output[31:0] processed_multiplicand;
    output data_result_ready, carry_in, initial_cycle;

    input[31:0] multiplicand;
    input[1:0] booth_opcode;
    input clk, reset;

    wire[31:0] inverted_multiplicand;
    wire[5:0] counter_val;
    wire[1:0] not_booth_opcode;
    wire initial_cycle;

    not inverted_multiplicand[31:0](inverted_multiplicand, multiplicand);

    not not_booth[1:0](not_booth_opcode, booth_opcode);
    and carry_in(carry_in, booth_opcode[1], not_booth_opcode[0]);

    mux_4 booth_mux(processed_multiplicand, booth_opcode, 32'b0, multiplicand, inverted_multiplicand, 32'b0);

    six_bit_counter counter(counter_val, clk, reset);
    and(data_result_ready, counter_val[0], ~counter_val[1], ~counter_val[2], ~counter_val[3], ~counter_val[4], counter_val[5]);

    and initial_cycle(initial_cycle, ~counter_val[0], ~counter_val[1], ~counter_val[2], ~counter_val[3], ~counter_val[4], ~counter_val[5]);
endmodule