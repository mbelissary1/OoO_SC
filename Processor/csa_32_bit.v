module csa_32_bit (Sum, Cout, A, B, Cin);

    input [31:0] A, B;
    input Cin;
    
    output [31:0] Sum;
    output Cout;

    wire carry_0, carry_1, carry_2;
    wire [7:0] mux_10_sum, mux_11_sum, mux_20_sum, mux_21_sum, mux_30_sum, mux_31_sum;
    wire mux_10_carry, mux_11_carry, mux_20_carry, mux_30_carry, mux_31_carry;

    eight_bit_CLA adder_00(Sum[7:0], carry_0, A[7:0], B[7:0], Cin);

    eight_bit_CLA adder_10(mux_10_sum[7:0], mux_10_carry, A[15:8], B[15:8], 1'd0);
    eight_bit_CLA adder_11(mux_11_sum[7:0], mux_11_carry, A[15:8], B[15:8], 1'd1);
    mux_2 mux_10(Sum[15:8], carry_0, mux_10_sum, mux_11_sum);
    mux_2 mux_11(carry_1, carry_0, mux_10_carry, mux_11_carry);

    eight_bit_CLA adder_20(mux_20_sum[7:0], mux_20_carry, A[23:16], B[23:16], 1'd0);
    eight_bit_CLA adder_21(mux_21_sum[7:0], mux_21_carry, A[23:16], B[23:16], 1'd1);
    mux_2 mux_20(Sum[23:16], carry_1, mux_20_sum, mux_21_sum);
    mux_2 mux_21(carry_2, carry_1, mux_20_carry, mux_21_carry);

    eight_bit_CLA adder_30(mux_30_sum[7:0], mux_30_carry, A[31:24], B[31:24], 1'd0);
    eight_bit_CLA adder_31(mux_31_sum[7:0], mux_31_carry, A[31:24], B[31:24], 1'd1);
    mux_2 mux_30(Sum[31:24], carry_2, mux_30_sum, mux_31_sum);
    mux_2 mux_31(Cout, carry_2, mux_30_carry, mux_31_carry);

endmodule