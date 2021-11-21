module booth_mult (result, data_result_ready, overflow, multiplicand, multiplier, clk, reset);
    output[31:0] result;
    output data_result_ready, overflow;

    input[31:0] multiplicand, multiplier;
    input clk, reset;

    wire signed[64:0] reg_value, not_reg_value, next_reg_value;
    wire[31:0] multiplicand_to_adder, multiplicand_to_register, processed_multiplicand, adder_out;
    wire[1:0] booth_opcode;
    wire carry_in, initial_cycle, carry_out;

    mult_control control(data_result_ready, processed_multiplicand, carry_in, initial_cycle, booth_opcode, multiplicand, clk, reset);

    assign next_reg_value[64:33] = initial_cycle ? 32'b0 : adder_out;
    assign next_reg_value[32:1] = initial_cycle ? multiplier : reg_value[32:1];
    assign next_reg_value[0] = initial_cycle ? 1'b0 : reg_value[0];

    reg_65 main_register(reg_value, not_reg_value, initial_cycle ? next_reg_value : next_reg_value >>> 1, clk, 1'b1, reset);

    assign booth_opcode = reg_value[1:0];

    csa_32_bit adder(adder_out, carry_out, processed_multiplicand, reg_value[64:33], carry_in);    

    assign result = reg_value[32:1];

    // Handle overflow!
    wire hot_upper_32, cold_upper_32, overflow_pos, overflow_neg, all_hot_upper_32;
    wire pos_pos, neg_neg, pos_neg, neg_pos, multiplicand_is_nonzero, multiplier_is_nonzero, nonsense_sign_bits;
    wire min_int, one, min_int_case;

    assign hot_upper_32 = |reg_value[64:33]; // If at least one of the upper 32 is hot
    and overflow_pos(overflow_pos, hot_upper_32, ~reg_value[32]);
    assign cold_upper_32 = ~hot_upper_32;
    assign all_hot_upper_32 = &reg_value[64:33];
    xnor nonsense_sign_bits_overflow(nonsense_sign_bits, ~all_hot_upper_32, ~cold_upper_32);
    or check_min_int(min_int, &multiplier, &multiplicand);
    or check_one(one, !(|(multiplier[31:1])) & multiplier, !(|(multiplicand[31:1])) & multiplicand);
    and check_min_int_case(min_int_case, min_int, one); // Handle the MIN_INT * 1 and 1 * MIN_INT corner cases!!!
    and overflow_neg(overflow_neg, cold_upper_32, reg_value[32], min_int_case);

    and pos_pos(pos_pos, ~multiplier[31], ~multiplicand[31], reg_value[32]);
    and neg_neg(neg_neg, multiplier[31], multiplicand[31], reg_value[32]);
    assign multiplicand_is_nonzero = |multiplicand;
    assign multiplier_is_nonzero = |multiplier;
    and pos_neg(pos_neg, ~multiplier[31], multiplicand[31], ~reg_value[32], multiplier_is_nonzero);
    and neg_pos(neg_pos, multiplier[31], ~multiplicand[31], ~reg_value[32], multiplicand_is_nonzero);

    wire temp_overflow;
    or overflow(temp_overflow, overflow_pos, overflow_neg, pos_pos, neg_neg, pos_neg, neg_pos, nonsense_sign_bits);
    assign overflow = data_result_ready ? temp_overflow : 1'b0;

endmodule