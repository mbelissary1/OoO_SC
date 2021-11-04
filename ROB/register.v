module register(in, en, clk, clr, out);
	input[31:0] in;
	input en, clk, clr;
	output[31:0] out;
	
	genvar i;
	generate
		for(i = 0; i < 32; i=i+1) begin: loop1
			dflipflop myDFF(out[i], in[i], clk, en, clr);
		end
	endgenerate
endmodule