#ifndef _FORMAT_350_H
#define _FORMAT_350_H

/*
Originally written by Dr. Bletch, modified for the purposes of ECE350 by Mary Stuart Elder and Oliver Rodas
*/

enum instruction_type {I,IBranchComp,IDisp,J,R,R1RS,RSH};
struct instruction_t
{
  unsigned short opcode;
  unsigned short alu_opcode;
  const char* str;
  instruction_type type;
  instruction_t() { str = 0; }
  instruction_t(unsigned short o, unsigned short alu_o, const char* s, instruction_type t) { opcode = o; alu_opcode = alu_o; str = s; type = t; }
};

#define OPCODE_ALU    0x0
#define OPCODE_ALU_DEFAULT	0x0
#define OPCODE_ADDI   0x5
#define OPCODE_ADD    0x0
#define OPCODE_SUB    0x1
#define OPCODE_AND    0x2
#define OPCODE_OR     0x3
#define OPCODE_SLL    0x4
#define OPCODE_SRA    0x5
#define OPCODE_SW     0x7
#define OPCODE_LW     0x8
#define OPCODE_J      0x1
#define OPCODE_BNE	  0x2
#define OPCODE_JAL    0x3
#define OPCODE_JR     0x4
#define OPCODE_BLT	  0x6
#define OPCODE_BEX    0x16
#define OPCODE_SETX   0x15
#define OPCODE_MULT   0x6
#define OPCODE_DIV    0x7


instruction_t opcode_arr[] = {
    instruction_t(OPCODE_ALU, OPCODE_ADD,		   "add",   R),
    instruction_t(OPCODE_ADDI, OPCODE_ALU_DEFAULT, "addi",  I),
    instruction_t(OPCODE_ALU, OPCODE_SUB,		   "sub",   R),
	instruction_t(OPCODE_ALU, OPCODE_AND,		   "and",   R),
	instruction_t(OPCODE_ALU, OPCODE_OR,		   "or",    R),
    instruction_t(OPCODE_ALU, OPCODE_SLL,		   "sll",   RSH),
    instruction_t(OPCODE_ALU, OPCODE_SRA,		   "sra",   RSH),
    instruction_t(OPCODE_SW, OPCODE_ALU_DEFAULT,   "sw",    IDisp),
    instruction_t(OPCODE_LW, OPCODE_ALU_DEFAULT,   "lw",    IDisp),
    instruction_t(OPCODE_J,	OPCODE_ALU_DEFAULT,	   "j",	    J),
    instruction_t(OPCODE_BNE, OPCODE_ALU_DEFAULT,  "bne",   IBranchComp),
    instruction_t(OPCODE_JAL, OPCODE_ALU_DEFAULT,  "jal",   J),
    instruction_t(OPCODE_JR, OPCODE_ALU_DEFAULT,   "jr",    R1RS),
    instruction_t(OPCODE_BLT, OPCODE_ALU_DEFAULT,  "blt",   IBranchComp),
    instruction_t(OPCODE_BEX, OPCODE_ALU_DEFAULT,  "bex",	J),
    instruction_t(OPCODE_SETX, OPCODE_ALU_DEFAULT, "setx",  J),
    instruction_t(OPCODE_ALU, OPCODE_MULT, "mul", R),
    instruction_t(OPCODE_ALU, OPCODE_DIV, "div", R),
};

// for CPUs without a shift (such as ones that have a rotate instead), the 'ldia' (also known as the 'la' instruction) can use multiple successive adds to shift a register to encode a full 16-bit immediate.
// such code is emitted if the LDIA_SHIFT_WITH_ADDS macro below true, else the usual shl instruction is used
#define LDIA_SHIFT_WITH_ADDS 0

const int NUM_OPCODES = sizeof(opcode_arr)/sizeof(instruction_t);
const int OPCODE_BITS = 5;
const int REG_BITS = 5;
const int ZERO_BITS = 2;
const int SHIFT_AMT_BITS = 5;
const int IMM_BITS = 17;
const int JMP_ADDR_BITS = 27;
const int ADDR_BITS = 12;
const int WORD_BITS = 32;

const int IMEM_SIZE = 1<<ADDR_BITS;
const int DMEM_SIZE = 1<<ADDR_BITS;

const int STATUS_REG = 30;
const int LINK_REG = 31;
const int ZERO_REG = 0;
const int DATA_BASE_ADDR = 16384;	// MSE: Doesn't seem to be used in asm.cpp or sim.cpp, so left as the old value

const int WIDTH = WORD_BITS;
const int DEPTH = 1<<ADDR_BITS;
const int NUM_REGS = 1<<REG_BITS;
const int MIN_IMM = -(1<<(IMM_BITS-1));
const int MAX_IMM = (1<<(IMM_BITS-1))-1;
const int MAX_JMP_ADDR = (1<<JMP_ADDR_BITS)-1;
const int MAX_SHIFT_AMT = (1<<SHIFT_AMT_BITS)-1;

struct type_i
{
  signed imm : IMM_BITS;
  unsigned rs : REG_BITS;
  unsigned rd : REG_BITS;
  unsigned opcode : OPCODE_BITS;
};

struct type_r
{
  unsigned zeros : ZERO_BITS;
  unsigned alu_opcode : OPCODE_BITS;
  unsigned shamt : SHIFT_AMT_BITS;
  unsigned rt : REG_BITS;
  unsigned rs : REG_BITS;
  unsigned rd : REG_BITS;
  unsigned opcode : OPCODE_BITS;
};

struct type_ji
{
  unsigned addr : JMP_ADDR_BITS;
  unsigned opcode : OPCODE_BITS;
};

struct type_jii
{
	unsigned zeros : JMP_ADDR_BITS - REG_BITS;
	unsigned rd : REG_BITS;
	unsigned opcode : OPCODE_BITS;
};

union inst
{
  type_i itype;
  type_r rtype;
  type_ji jitype;
  type_jii jiitype;
  unsigned int bits;
};

#endif
