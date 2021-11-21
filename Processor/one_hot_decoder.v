module one_hot_decoder (out, in);
    output[31:0] out;

    input[4:0] in;

    wire[4:0] not_in;

    not not_in[4:0](not_in, in);

    and out_0(out[0], not_in[4], not_in[3], not_in[2], not_in[1], not_in[0]);
    and out_1(out[1], not_in[4], not_in[3], not_in[2], not_in[1], in[0]);
    and out_2(out[2], not_in[4], not_in[3], not_in[2], in[1], not_in[0]);
    and out_3(out[3], not_in[4], not_in[3], not_in[2], in[1], in[0]);
    and out_4(out[4], not_in[4], not_in[3], in[2], not_in[1], not_in[0]);
    and out_5(out[5], not_in[4], not_in[3], in[2], not_in[1], in[0]);
    and out_6(out[6], not_in[4], not_in[3], in[2], in[1], not_in[0]);
    and out_7(out[7], not_in[4], not_in[3], in[2], in[1], in[0]);
    and out_8(out[8], not_in[4], in[3], not_in[2], not_in[1], not_in[0]);
    and out_9(out[9], not_in[4], in[3], not_in[2], not_in[1], in[0]);
    and out_10(out[10], not_in[4], in[3], not_in[2], in[1], not_in[0]);
    and out_11(out[11], not_in[4], in[3], not_in[2], in[1], in[0]);
    and out_12(out[12], not_in[4], in[3], in[2], not_in[1], not_in[0]);
    and out_13(out[13], not_in[4], in[3], in[2], not_in[1], in[0]);
    and out_14(out[14], not_in[4], in[3], in[2], in[1], not_in[0]);
    and out_15(out[15], not_in[4], in[3], in[2], in[1], in[0]);
    and out_16(out[16], in[4], not_in[3], not_in[2], not_in[1], not_in[0]);
    and out_17(out[17], in[4], not_in[3], not_in[2], not_in[1], in[0]);
    and out_18(out[18], in[4], not_in[3], not_in[2], in[1], not_in[0]);
    and out_19(out[19], in[4], not_in[3], not_in[2], in[1], in[0]);
    and out_20(out[20], in[4], not_in[3], in[2], not_in[1], not_in[0]);
    and out_21(out[21], in[4], not_in[3], in[2], not_in[1], in[0]);
    and out_22(out[22], in[4], not_in[3], in[2], in[1], not_in[0]);
    and out_23(out[23], in[4], not_in[3], in[2], in[1], in[0]);
    and out_24(out[24], in[4], in[3], not_in[2], not_in[1], not_in[0]);
    and out_25(out[25], in[4], in[3], not_in[2], not_in[1], in[0]);
    and out_26(out[26], in[4], in[3], not_in[2], in[1], not_in[0]);
    and out_27(out[27], in[4], in[3], not_in[2], in[1], in[0]);
    and out_28(out[28], in[4], in[3], in[2], not_in[1], not_in[0]);
    and out_29(out[29], in[4], in[3], in[2], not_in[1], in[0]);
    and out_30(out[30], in[4], in[3], in[2], in[1], not_in[0]);
    and out_31(out[31], in[4], in[3], in[2], in[1], in[0]);
endmodule