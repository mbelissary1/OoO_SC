module IsMulticycle(input[31:0] INSTR, output IS_MULTICYCLE, output IS_MEM); 
    wire[4:0] LOAD  = 5'b01000;
    wire[4:0] STORE = 5'b00111;
    wire[4:0] MULT  = 5'b00110;
    wire[4:0] DIV   = 5'b00111;
    wire[4:0] RTYPE = 5'b00000;
    wire[4:0] OPCODE = INSTR[31:27];
    wire[4:0] ALUOP = INSTR[6:2];

    wire[4:0] IS_LOAD = LOAD == OPCODE;
    assign IS_MEM = STORE == OPCODE | IS_LOAD;

    assign IS_MULTICYCLE = IS_LOAD | (OPCODE == RTYPE & (ALUOP == DIV | ALUOP == MULT | ALUOP == LOAD));
endmodule