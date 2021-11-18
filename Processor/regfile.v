module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	wire[1023:0] reg_input_wire;
	wire[1023:0] reg_output_wire;
	wire[31:0] clk, write_enable, clr, write_enable_and_decoder, input_decoder_wire;

	assign clk = {32{clock}};
	assign reg_input_wire = {32{data_writeReg}};
	assign write_enable = {32{ctrl_writeEnable}};
	assign clr = {32{ctrl_reset}};

	reg_32 zero_reg(reg_output_wire[31:0], 32'b0, clock, 1'b0, 1'b0);
	one_hot_decoder input_decoder(input_decoder_wire, ctrl_writeReg);
	and write_enable_and_decoder[31:0](write_enable_and_decoder, write_enable, input_decoder_wire);
	reg_32 registers[30:0](reg_output_wire[1023:32], reg_input_wire[1023:32], clk[31:1], write_enable_and_decoder[31:1], clr[31:1]);

	wire[31:0] read_reg_a;
	one_hot_decoder read_a(read_reg_a, ctrl_readRegA);

	tsb_32 tsb_a0(data_readRegA[31:0], reg_output_wire[31:0], read_reg_a[0]);
	tsb_32 tsb_a1(data_readRegA[31:0], reg_output_wire[63:32], read_reg_a[1]);
	tsb_32 tsb_a2(data_readRegA[31:0], reg_output_wire[95:64], read_reg_a[2]);
	tsb_32 tsb_a3(data_readRegA[31:0], reg_output_wire[127:96], read_reg_a[3]);
	tsb_32 tsb_a4(data_readRegA[31:0], reg_output_wire[159:128], read_reg_a[4]);
	tsb_32 tsb_a5(data_readRegA[31:0], reg_output_wire[191:160], read_reg_a[5]);
	tsb_32 tsb_a6(data_readRegA[31:0], reg_output_wire[223:192], read_reg_a[6]);
	tsb_32 tsb_a7(data_readRegA[31:0], reg_output_wire[255:224], read_reg_a[7]);
	tsb_32 tsb_a8(data_readRegA[31:0], reg_output_wire[287:256], read_reg_a[8]);
	tsb_32 tsb_a9(data_readRegA[31:0], reg_output_wire[319:288], read_reg_a[9]);
	tsb_32 tsb_a10(data_readRegA[31:0], reg_output_wire[351:320], read_reg_a[10]);
	tsb_32 tsb_a11(data_readRegA[31:0], reg_output_wire[383:352], read_reg_a[11]);
	tsb_32 tsb_a12(data_readRegA[31:0], reg_output_wire[415:384], read_reg_a[12]);
	tsb_32 tsb_a13(data_readRegA[31:0], reg_output_wire[447:416], read_reg_a[13]);
	tsb_32 tsb_a14(data_readRegA[31:0], reg_output_wire[479:448], read_reg_a[14]);
	tsb_32 tsb_a15(data_readRegA[31:0], reg_output_wire[511:480], read_reg_a[15]);
	tsb_32 tsb_a16(data_readRegA[31:0], reg_output_wire[543:512], read_reg_a[16]);
	tsb_32 tsb_a17(data_readRegA[31:0], reg_output_wire[575:544], read_reg_a[17]);
	tsb_32 tsb_a18(data_readRegA[31:0], reg_output_wire[607:576], read_reg_a[18]);
	tsb_32 tsb_a19(data_readRegA[31:0], reg_output_wire[639:608], read_reg_a[19]);
	tsb_32 tsb_a20(data_readRegA[31:0], reg_output_wire[671:640], read_reg_a[20]);
	tsb_32 tsb_a21(data_readRegA[31:0], reg_output_wire[703:672], read_reg_a[21]);
	tsb_32 tsb_a22(data_readRegA[31:0], reg_output_wire[735:704], read_reg_a[22]);
	tsb_32 tsb_a23(data_readRegA[31:0], reg_output_wire[767:736], read_reg_a[23]);
	tsb_32 tsb_a24(data_readRegA[31:0], reg_output_wire[799:768], read_reg_a[24]);
	tsb_32 tsb_a25(data_readRegA[31:0], reg_output_wire[831:800], read_reg_a[25]);
	tsb_32 tsb_a26(data_readRegA[31:0], reg_output_wire[863:832], read_reg_a[26]);
	tsb_32 tsb_a27(data_readRegA[31:0], reg_output_wire[895:864], read_reg_a[27]);
	tsb_32 tsb_a28(data_readRegA[31:0], reg_output_wire[927:896], read_reg_a[28]);
	tsb_32 tsb_a29(data_readRegA[31:0], reg_output_wire[959:928], read_reg_a[29]);
	tsb_32 tsb_a30(data_readRegA[31:0], reg_output_wire[991:960], read_reg_a[30]);
	tsb_32 tsb_a31(data_readRegA[31:0], reg_output_wire[1023:992], read_reg_a[31]);
	

	wire[31:0] read_reg_b;
	one_hot_decoder read_b(read_reg_b, ctrl_readRegB);

	tsb_32 tsb_b0(data_readRegB[31:0], reg_output_wire[31:0], read_reg_b[0]);
	tsb_32 tsb_b1(data_readRegB[31:0], reg_output_wire[63:32], read_reg_b[1]);
	tsb_32 tsb_b2(data_readRegB[31:0], reg_output_wire[95:64], read_reg_b[2]);
	tsb_32 tsb_b3(data_readRegB[31:0], reg_output_wire[127:96], read_reg_b[3]);
	tsb_32 tsb_b4(data_readRegB[31:0], reg_output_wire[159:128], read_reg_b[4]);
	tsb_32 tsb_b5(data_readRegB[31:0], reg_output_wire[191:160], read_reg_b[5]);
	tsb_32 tsb_b6(data_readRegB[31:0], reg_output_wire[223:192], read_reg_b[6]);
	tsb_32 tsb_b7(data_readRegB[31:0], reg_output_wire[255:224], read_reg_b[7]);
	tsb_32 tsb_b8(data_readRegB[31:0], reg_output_wire[287:256], read_reg_b[8]);
	tsb_32 tsb_b9(data_readRegB[31:0], reg_output_wire[319:288], read_reg_b[9]);
	tsb_32 tsb_b10(data_readRegB[31:0], reg_output_wire[351:320], read_reg_b[10]);
	tsb_32 tsb_b11(data_readRegB[31:0], reg_output_wire[383:352], read_reg_b[11]);
	tsb_32 tsb_b12(data_readRegB[31:0], reg_output_wire[415:384], read_reg_b[12]);
	tsb_32 tsb_b13(data_readRegB[31:0], reg_output_wire[447:416], read_reg_b[13]);
	tsb_32 tsb_b14(data_readRegB[31:0], reg_output_wire[479:448], read_reg_b[14]);
	tsb_32 tsb_b15(data_readRegB[31:0], reg_output_wire[511:480], read_reg_b[15]);
	tsb_32 tsb_b16(data_readRegB[31:0], reg_output_wire[543:512], read_reg_b[16]);
	tsb_32 tsb_b17(data_readRegB[31:0], reg_output_wire[575:544], read_reg_b[17]);
	tsb_32 tsb_b18(data_readRegB[31:0], reg_output_wire[607:576], read_reg_b[18]);
	tsb_32 tsb_b19(data_readRegB[31:0], reg_output_wire[639:608], read_reg_b[19]);
	tsb_32 tsb_b20(data_readRegB[31:0], reg_output_wire[671:640], read_reg_b[20]);
	tsb_32 tsb_b21(data_readRegB[31:0], reg_output_wire[703:672], read_reg_b[21]);
	tsb_32 tsb_b22(data_readRegB[31:0], reg_output_wire[735:704], read_reg_b[22]);
	tsb_32 tsb_b23(data_readRegB[31:0], reg_output_wire[767:736], read_reg_b[23]);
	tsb_32 tsb_b24(data_readRegB[31:0], reg_output_wire[799:768], read_reg_b[24]);
	tsb_32 tsb_b25(data_readRegB[31:0], reg_output_wire[831:800], read_reg_b[25]);
	tsb_32 tsb_b26(data_readRegB[31:0], reg_output_wire[863:832], read_reg_b[26]);
	tsb_32 tsb_b27(data_readRegB[31:0], reg_output_wire[895:864], read_reg_b[27]);
	tsb_32 tsb_b28(data_readRegB[31:0], reg_output_wire[927:896], read_reg_b[28]);
	tsb_32 tsb_b29(data_readRegB[31:0], reg_output_wire[959:928], read_reg_b[29]);
	tsb_32 tsb_b30(data_readRegB[31:0], reg_output_wire[991:960], read_reg_b[30]);
	tsb_32 tsb_b31(data_readRegB[31:0], reg_output_wire[1023:992], read_reg_b[31]);

endmodule
