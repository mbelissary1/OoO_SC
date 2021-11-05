module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire[31:0] mult_result, div_result;
    wire mult_ready, mult_overflow;

    booth_mult mult(mult_result, mult_ready, mult_overflow, data_operandA, data_operandB, clock, ctrl_MULT);

    and data_result[31:0](data_result, mult_result, {32{mult_ready}});
    assign data_exception = mult_overflow;
    assign data_resultRDY = mult_ready;

endmodule