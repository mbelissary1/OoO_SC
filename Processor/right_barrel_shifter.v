module right_barrel_shifter (Shifted, A, SHAMT);

    input[31:0] A;
    input[4:0] SHAMT;

    output[31:0] Shifted;

    wire[31:0] shifted_16, shifted_8, shifted_4, shifted_2, shifted_1;
    wire[31:0] out_16, out_8, out_4, out_2;

    // 16-bit RAS
    assign shifted_16[31:16] = {16{A[31]}};
    assign shifted_16[15:0] = A[31:16];
    mux_2 shift_16(out_16, SHAMT[4], A, shifted_16);

    // 8-bit RAS
    assign shifted_8[31:24] = {8{out_16[31]}};
    assign shifted_8[23:0] = out_16[31:8];
    mux_2 shift_8(out_8, SHAMT[3], out_16, shifted_8);

    // 4-bit RAS
    assign shifted_4[31:28] = {4{out_8[31]}};
    assign shifted_4[27:0] = out_8[31:4];
    mux_2 shift_4(out_4, SHAMT[2], out_8, shifted_4);

    // 2-bit RAS
    assign shifted_2[31:30] = {2{out_4[31]}};
    assign shifted_2[29:0] = out_4[31:2];
    mux_2 shift_2(out_2, SHAMT[1], out_4, shifted_2);

    // 1-bit RAS
    assign shifted_1[31] = {1{out_2[31]}};
    assign shifted_1[30:0] = out_2[31:1];
    mux_2 shift_1(Shifted, SHAMT[0], out_2, shifted_1);
    
endmodule