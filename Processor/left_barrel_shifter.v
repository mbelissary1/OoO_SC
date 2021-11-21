module left_barrel_shifter (Shifted, A, SHAMT);

    input[31:0] A;
    input[4:0] SHAMT;

    output[31:0] Shifted;

    wire[31:0] shifted_16, shifted_8, shifted_4, shifted_2, shifted_1;
    wire[31:0] out_16, out_8, out_4, out_2;

    // 16-bit LLS
    assign shifted_16[31:16] = A[15:0];
    assign shifted_16[15:0] = 16'd0;
    mux_2 shift_16(out_16, SHAMT[4], A, shifted_16);

    // 8-bit LLS
    assign shifted_8[31:8] = out_16[23:0];
    assign shifted_8[7:0] = 8'd0;
    mux_2 shift_8(out_8, SHAMT[3], out_16, shifted_8);

    // 4-bit LLS
    assign shifted_4[31:4] = out_8[27:0];
    assign shifted_4[3:0] = 4'd0;
    mux_2 shift_4(out_4, SHAMT[2], out_8, shifted_4);

    // 2-bit LLS
    assign shifted_2[31:2] = out_4[29:0];
    assign shifted_2[1:0] = 2'd0;
    mux_2 shift_2(out_2, SHAMT[1], out_4, shifted_2);

    // 1-bit LLS
    assign shifted_1[31:1] = out_2[30:0];
    assign shifted_1[0] = 1'd0;
    mux_2 shift_1(Shifted, SHAMT[0], out_2, shifted_1);
    
endmodule