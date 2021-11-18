module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] not_B, add_sub_mux_out, csa_out, bitwise_AND_out, bitwise_OR_out, SLL_out, SRA_out;
    wire csa_32_bit_Cout, A_B_match_out, A_B_same_sign, less_than_0, less_than_1, less_than_2, B_pos;

    // Handle the inversion of B (in case of subtraction) and feed both into a mux
    not not_B[31:0] (not_B, data_operandB);
    mux_2 add_sub_mux(add_sub_mux_out, ctrl_ALUopcode[0], data_operandB, not_B);

    // Handle addition/subtraction ops
    // NOTE: The carry-in is set to the LSB of the opcode to accomodate for the 2's complement
    csa_32_bit adder(csa_out, csa_32_bit_Cout, data_operandA, add_sub_mux_out, ctrl_ALUopcode[0]);
    
    // Check for over/underflows
    // Overflow check for 2's complement is just 3-input XOR (see Lecture 5)
    xnor A_B_same_sign(A_B_same_sign, data_operandA[31], add_sub_mux_out[31]);
    xor A_B_match_out(A_B_match_out, add_sub_mux_out[31], csa_out[31]);
    and checkOverflow(overflow, A_B_same_sign, A_B_match_out);

    // AND and OR
    bitwise_AND bitwise_AND(bitwise_AND_out[31:0], data_operandA[31:0], data_operandB[31:0]);
    bitwise_OR bitwise_OR(bitwise_OR_out[31:0], data_operandA[31:0], data_operandB[31:0]);
    
    // Check comparator outputs 
    or is_not_equal(isNotEqual, csa_out[0], csa_out[1], csa_out[2], csa_out[3], csa_out[4], csa_out[5], csa_out[6], csa_out[7], csa_out[8], csa_out[9], csa_out[10], csa_out[11], csa_out[12], csa_out[13], csa_out[14], csa_out[15], csa_out[16], csa_out[17], csa_out[18], csa_out[19], csa_out[20], csa_out[21], csa_out[22], csa_out[23], csa_out[24], csa_out[25], csa_out[26], csa_out[27], csa_out[28], csa_out[29], csa_out[30], csa_out[31]);
    not B_pos(B_pos, data_operandB[31]);
    and less_than_0(less_than_0, data_operandA[31], B_pos);
    and less_than_1(less_than_1, data_operandA[31], csa_out[31]);
    and less_than_2(less_than_2, B_pos, csa_out[31]);
    or is_less_than(isLessThan, less_than_0, less_than_1, less_than_2);

    // Do SLLs and SRAs
    left_barrel_shifter left_shifter(SLL_out, data_operandA, ctrl_shiftamt);
    right_barrel_shifter right_shifter(SRA_out, data_operandA, ctrl_shiftamt);

    // MUX everything together
    mux_8 output_mux(data_result, ctrl_ALUopcode[2:0], csa_out, csa_out, bitwise_AND_out, bitwise_OR_out, SLL_out, SRA_out, 0, 0);

endmodule