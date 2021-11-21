module IsMulticycle(input[31:0] INSTR, output IS_MULTICYCLE); 
    wire[4:0] LOAD  = 5'b01000;
    wire[4:0] MULT  = 5'b00110;
    wire[4:0] DIV   = 5'b00111;
    wire[4:0] RTYPE = 5'b00000;
    wire[4:0] OPCODE = INSTR[31:27];
    wire[4:0] ALUOP = INSTR[6:2];

    assign IS_MULTICYCLE = OPCODE == LOAD | (OPCODE == RTYPE & (ALUOP == DIV | ALUOP == MULT | ALUOP == LOAD));
endmodule