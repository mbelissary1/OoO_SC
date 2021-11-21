module restoring_div (quotient, data_result_ready, overflow, dividend, divisor, clk, reset);
    output[31:0] quotient;
    output data_result_ready, overflow;
    
    input[31:0] dividend, divisor;
    input clk, reset;

    // Handle counter and intial cycle/ready signals
    wire[5:0] counter_val;
    wire initial_cycle;
    
    six_bit_counter counter(counter_val, clk, reset);
    and initial_check(initial_cycle, ~counter_val[0], ~counter_val[1], ~counter_val[2], ~counter_val[3], ~counter_val[4], ~counter_val[5]);
    and(data_result_ready, counter_val[0], ~counter_val[1], ~counter_val[2], ~counter_val[3], ~counter_val[4], counter_val[5]);

    // Compensate for negative signing, if necessary and then handle the shift
    wire[63:0] reg_value, not_reg_value, next_reg_value, shifted_reg;
    wire[31:0] sign_compensated_dividend;
    wire unused_cout_0, reg_overflow, not_reg_overflow;

    csa_32_bit sign_compensation_adder(sign_compensated_dividend, unused_cout_0, dividend[31] ? ~dividend : dividend, dividend[31] ? 1'b1 : 1'b0, 1'b0);

    wire[31:0] inverted_divisor;

    assign inverted_divisor = divisor[31] ? divisor : ~divisor;
    assign shifted_reg = reg_value << 1;

    // Check for register overflow
    dffe_ref check_reg_overflow(reg_overflow, not_reg_overflow, 1'b1, clk, reg_value[63], reset);
    
    // Do the subtraction
    wire sub_carry_out;
    wire[31:0] sub_out;

    csa_32_bit subtractor(sub_out, sub_carry_out, shifted_reg[63:32], inverted_divisor, ~divisor[31]);

    // Handle the trial subtractions, correcting for the initial case if necessary!
    wire [31:0] Q, A;
    assign Q[31:1] = initial_cycle ? sign_compensated_dividend[31:1] : shifted_reg[31:1];
    assign Q[0] = initial_cycle ? sign_compensated_dividend[0] : ~sub_out[31];
    wire [31:0] A_temp;
    assign A_temp = sub_out[31] ? shifted_reg[63:32] : sub_out;
    assign A = initial_cycle ? 32'b0 : A_temp;
    
	assign next_reg_value[63:32] = A;
	assign next_reg_value[31:0] = Q[31:0];

    reg_64 main_register(reg_value, not_reg_value, next_reg_value, clk, 1'b1, reset);

    // Handle signing and overflow checks
    wire output_sign;
    xor output_sign(output_sign, dividend[31], divisor[31]);
    
    wire [31:0] signed_output;
    wire unused_cout_1;
    wire temp_overflow;
    csa_32_bit out_sub(signed_output, unused_cout_1, ~reg_value[31:0], 1'b1, 1'b0);
    wire [31:0] non_zero_res, non_overflow_res;
    assign non_zero_res = output_sign ? signed_output : reg_value[31:0];
    assign non_overflow_res = overflow ? 32'b0 : non_zero_res;
    assign quotient = reg_overflow ? 1'bx : non_overflow_res;
    
    assign temp_overflow = (~(|divisor)) || reg_overflow;
    assign overflow = data_result_ready ? temp_overflow : 1'b0;

endmodule