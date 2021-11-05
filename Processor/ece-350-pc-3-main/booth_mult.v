module booth_mult (result, data_result_ready, overflow, multiplicand, multiplier, clk, reset);
    output[31:0] result;
    output data_result_ready, overflow;

    input[31:0] multiplicand, multiplier;
    input clk, reset;

    wire signed[64:0] reg_value, not_reg_value, next_reg_value;
    wire[31:0] multiplicand_to_adder, multiplicand_to_register, processed_multiplicand, adder_out;
    wire[1:0] booth_opcode;
    wire carry_in, initial_cycle, carry_out, hot_upper_32, cold_upper_32, overflow_pos, overflow_neg;

    mult_control control(data_result_ready, processed_multiplicand, carry_in, initial_cycle, booth_opcode, multiplicand, clk, reset);

    assign next_reg_value[64:33] = initial_cycle ? 32'b0 : adder_out;
    assign next_reg_value[32:1] = initial_cycle ? multiplier : reg_value[32:1];
    assign next_reg_value[0] = initial_cycle ? 1'b0 : reg_value[0];

    reg_65 main_register(reg_value, not_reg_value, initial_cycle ? next_reg_value : next_reg_value >>> 1, clk, 1'b1, reset);

    assign booth_opcode = reg_value[1:0];

    csa_32_bit adder(adder_out, carry_out, processed_multiplicand, reg_value[64:33], carry_in);    

    assign result = reg_value[32:1];

    assign hot_upper_32 = |reg_value[64:33]; // If at least one of the upper 32 is hot
    and overflow_pos(overflow_pos, hot_upper_32, ~reg_value[32]);
    assign cold_upper_32 = ~hot_upper_32;
    and overflow_neg(overflow_neg, cold_upper_32, reg_value[32]);
    or overflow(overflow, overflow_pos, overflow_neg);

endmodule