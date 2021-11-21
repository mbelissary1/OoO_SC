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
    wire mult_ready, mult_overflow, div_ready, div_overflow, mult_operation, not_mult_operation, next_operation;
    wire [1:0] ctrl;

    assign ctrl[1] = ctrl_DIV;
    assign ctrl[0] = ctrl_MULT;
    dffe_ref is_mult_op(mult_operation, not_mult_operation, ctrl_MULT, clock, ctrl_MULT || ctrl_DIV, 1'b0);

    booth_mult mult(mult_result, mult_ready, mult_overflow, data_operandA, data_operandB, clock, ctrl_MULT);
    restoring_div div(div_result, div_ready, div_overflow, data_operandA, data_operandB, clock, ctrl_DIV);

    assign data_result = mult_operation ? mult_result : div_result;
    assign data_exception = mult_operation ? mult_overflow : div_overflow;
    
    and mult_ready(multRDY, mult_operation, mult_ready);
    and div_ready(divRDY, ~mult_operation, div_ready);
    or result_ready(data_resultRDY, divRDY, multRDY);

endmodule