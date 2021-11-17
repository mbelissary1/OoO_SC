module register #(parameter SIZE = 32) (in, en, clk, clr, out);
	input[SIZE-1:0] in;
	input en, clk, clr;
	output[SIZE-1:0] out;
	
	genvar i;
	generate
		for(i = 0; i < SIZE; i=i+1) begin: loop1
			dflipflop myDFF(out[i], in[i], clk, en, clr);
		end
	endgenerate
endmodule