#include <cstdlib>
#include <cstring>
#include <climits>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
#include "format350.h"
using namespace std;

/*
Originally written by Dr. Bletch, modified for the purposes of ECE350 by Oliver Rodas
*/

void usage();
// removing MIF file support -- string mif_line(unsigned short addr, unsigned short val); 
string lgsim_line(unsigned short addr, unsigned int val);
// removing MIF file support -- void do_mif_header(ostream& out, int width, int depth);
void do_lgsim_header(ostream& out, int width, int depth);

struct instruction;
map<string,instruction*> opcodes;
map<string,int> symbol_table;

bool find_symbol(string symbol, unsigned int& value)
{
  int lpos = symbol.find('['), rpos = symbol.find(']'), msb, lsb;
  if(rpos > lpos)
  {
    char ch;
    string substr = symbol.substr(lpos+1,rpos-lpos-1);
    symbol = symbol.substr(0,lpos);
    istringstream in(substr);
    if(!(in >> msb))
      throw "Malformed array index: "+substr;
    if(!(in >> ch))
      lsb = msb;
    else if(!(ch == '.' && (in >> ch) && ch == '.' && (in >> lsb)))
      throw "Malformed array index: "+substr;
  }
  else
  {
    msb = WORD_BITS-1;
    lsb = 0;
  }

  map<string,int>::const_iterator it = symbol_table.find(symbol);
  if(it == symbol_table.end())
    return false;
  //value = (it->second >> lsb) & ((1 << (msb-lsb+1))-1);
  value = it->second;
  return true;
}

struct instruction
{
  unsigned short opcode;
  unsigned short alu_opcode;
  string opstr;
  instruction_type type;
  inst insn;
  string immed_symbol;
  string jump_addr_symbol;
  string ldia_symbol;
  int lineno;
  int pc;
  instruction* next_instruction;

  instruction()
   : next_instruction(NULL)
  {
  }

  ~instruction()
  {
    delete next_instruction;
  }

  instruction(unsigned short o, unsigned short alu_o, const string& s, instruction_type t)
   : opcode(o), alu_opcode(alu_o), type(t), opstr(s), lineno(0), pc(0), next_instruction(NULL)
  {
    insn.bits = 0;
    insn.itype.opcode = o;
	insn.rtype.alu_opcode = alu_o;
  }

  instruction(const instruction& i)
  {
    *this = i;
  }

  instruction& operator=(const instruction& i)
  {
    opcode = i.opcode;
	alu_opcode = i.alu_opcode;
    type = i.type;
    opstr = i.opstr;
    insn = i.insn;
    immed_symbol = i.immed_symbol;
    jump_addr_symbol = i.jump_addr_symbol;
    lineno = i.lineno;
    pc = i.pc;
    if(i.next_instruction != NULL)
      next_instruction = new instruction(*i.next_instruction);
    else
      next_instruction = NULL;
    return *this;
  }

  // parse a register identifier from an istream
  int parse_reg(istream& in)
  {
    int reg;
    char ch;
    if(!(in >> ch) || ch != '$') return -1;
    if(!(in >> ch) || tolower(ch) != 'r') return -1;
    if(!(in >> reg) || reg < 0 || reg >= NUM_REGS)
    {
      char buf[512];
      sprintf(buf,"Register identifier out of range [0,%d]: %d",NUM_REGS-1,reg);
      throw string(buf);
    }
    return reg;
  }

  // parse an immediate (integer or symbol) from an istream
  int parse_imm(istream& in, bool is_jump_addr = false, bool is_shift_amt = false, bool is_ldia = false)
  {
    string s;
    while(isspace(in.peek()))
      in.get();
    while(isalnum(in.peek()) || in.peek() == '-' || in.peek() == '_')
      s += in.get();

    if(s.length() == 0)
      return INT_MIN;

    ostringstream ss;
    int imm = atoi(s.c_str());
    ss << imm;

    if(s == ss.str()) // the immediate is a valid number
    {
      int imm = atoi(s.c_str());

      if(is_ldia)
        return imm;
      if(is_jump_addr)
      {
        if(imm < 0 || imm > MAX_JMP_ADDR)
        {
          char buf[512];
          sprintf(buf,"Jump address out of range [0,%d]: %d",MAX_JMP_ADDR,imm);
          throw string(buf);
        }
        insn.jitype.addr = imm;
      }
      else if(is_shift_amt)
      {
        if(imm < 0 || imm > MAX_SHIFT_AMT)
        {
          char buf[512];
          sprintf(buf,"1Immediate value out of range [0,%d]: %d",MAX_SHIFT_AMT,imm);
          throw string(buf);
        }
        insn.rtype.shamt = imm;
      }
      else
      {
        if(imm < MIN_IMM || imm > MAX_IMM)
        {
          char buf[512];
          sprintf(buf,"2Immediate value out of range [%d,%d]: %d",MIN_IMM,MAX_IMM,imm);
          throw string(buf);
        }
        insn.itype.imm = imm;
      }
    }
    else
    {
      if(is_ldia)
        ldia_symbol = s;
      else if(is_jump_addr)
        jump_addr_symbol = s;
      else if(is_shift_amt)
        throw string("Shift amount must be numeric, not symbolic");
      else
        immed_symbol = s;
    }

    return 0;
  }

  // parse an instruction's arguments from an istream
  void parse(istream& in)
  {
    char ch;
    int reg;
    switch(type)	// I,IBranchComp,IDisp,J,R,R1RS,RSH
    {
	case I:
		do
        {
		  if((reg = parse_reg(in)) < 0) break;
          insn.itype.rd = reg;
          if(!(in >> ch) || ch != ',') break;

          if((reg = parse_reg(in)) < 0) break;
          insn.itype.rs = reg;
          if(!(in >> ch) || ch != ',') break;

          if(parse_imm(in) < 0) break;
          
		  return;
        } while(0);

        throw string("Incorrectly formatted i-type instruction\nCorrect syntax is "+opstr+" $rL,$rM,N\nwhere L and M are register identifiers and N is an immediate value");

      case IBranchComp:
		  do
        {
          if((reg = parse_reg(in)) < 0) break;
          insn.itype.rd = reg;
          if(!(in >> ch) || ch != ',') break;

          if((reg = parse_reg(in)) < 0) break;
          insn.itype.rs = reg;
          if(!(in >> ch) || ch != ',') break;

          if(parse_imm(in) < 0) break;
          return;
        } while(0);

        throw string("Incorrectly formatted i-type instruction\nCorrect syntax is "+opstr+" $rL,$rM,N\nwhere L and M are register identifiers and N is an immediate value");

      case IDisp:
		  do
        {
          if((reg = parse_reg(in)) < 0) break;
          insn.itype.rd = reg;
          if(!(in >> ch) || ch != ',') break;

          if(parse_imm(in) < 0) break;

          if(!(in >> ch) || ch != '(') break;
          if((reg = parse_reg(in)) < 0) break;
          insn.itype.rs = reg;
          if(!(in >> ch) || ch != ')') break;
          return;

        } while(0);

        throw string("Incorrectly formatted i-type instruction\nCorrect syntax is "+opstr+" $rM,N($rL)\nwhere L and M are registers identifier and N is an immediate value");
        
      case J:
		  if(parse_imm(in,true) < 0)
          throw string("Incorrectly formatted j-type instruction\nCorrect syntax is "+opstr+" addr\nwhere addr is a jump address or label");
        break;

      case R:
		  do
        {
		  if (opstr == "nop")
		  {
			  insn.rtype.rd = 0;
			  insn.rtype.rs = 0;
			  insn.rtype.rt = 0;
			  return;
		  }
	      if((reg = parse_reg(in)) < 0) break;
          insn.rtype.rd = reg;
          if(!(in >> ch) || ch != ',') break;

          if((reg = parse_reg(in)) < 0) break;
          insn.rtype.rs = reg;
          if(!(in >> ch) || ch != ',') break;

          if((reg = parse_reg(in)) < 0) break;  
          insn.rtype.rt = reg;
          return;

        } while(0);

        throw string("Incorrectly formatted r-type instruction\nCorrect syntax is "+opstr+" $rN,$rL,$rM\nwhere L, M, and N are register identifiers");

      case R1RS:
		  if((reg = parse_reg(in)) < 0)
          throw string("Incorrectly formatted r-type instruction\nCorrect syntax is "+opstr+" $rN\nwhere N is a register identifier");
        insn.jiitype.rd = reg;
        break;

      case RSH:
		  do
        {
          if((reg = parse_reg(in)) < 0) break;
          insn.rtype.rd = reg;
          if(!(in >> ch) || ch != ',') break;

          if((reg = parse_reg(in)) < 0) break;
          insn.rtype.rs = reg;
          if(!(in >> ch) || ch != ',') break;

          if(parse_imm(in,false,true) < 0) break;  
          return;

        } while(0);

        throw string("Incorrectly formatted r-type instruction\nCorrect syntax is "+opstr+" $rN,$rL,N\nwhere L and M are register identifiers and N is an integer");
      default:
        throw string("Undefined instruction type!");
    }
  }

  void fill_in_symbols()
  {
    if(immed_symbol != "")
    {
      unsigned int imm;
      if(!find_symbol(immed_symbol,imm))
      {
        ostringstream s;
        s << "Undefined symbol '" << immed_symbol << "' on line " << lineno;
        throw s.str();
      }

      if(type == IBranchComp)
        imm = imm - pc - 1;
      if((short)imm < MIN_IMM || (short)imm > MAX_IMM)
      {
        char buf[512];
        sprintf(buf,"Immediate value out of range [%d,%d] on line %d: %d",MIN_IMM,MAX_IMM,lineno,imm);
        throw string(buf);
      }
      insn.itype.imm = imm;
    }
    else if(jump_addr_symbol != "")
    {
      unsigned int addr;
      if(!find_symbol(jump_addr_symbol,addr))
      {
        ostringstream s;
        s << "Undefined symbol '" << jump_addr_symbol << "' on line " << lineno;
        throw s.str();
      }
      if((pc & ~MAX_JMP_ADDR) != (addr & ~MAX_JMP_ADDR))
      {
        char buf[512];
        sprintf(buf,"4Immediate value out of range [0,%d] on line %d: %d",MAX_JMP_ADDR,lineno,addr);
        throw string(buf);
      }
      insn.jitype.addr = addr & MAX_JMP_ADDR;
    }
  }
};

struct data_word
{
  unsigned int value;
  int lineno;
  string symbol;

  data_word() {}
  data_word(unsigned short v, int ln, const string& s)
    : value(v), lineno(ln), symbol(s) {}

  data_word(const data_word& dw)
    : value(dw.value), lineno(dw.lineno), symbol(dw.symbol) {}
   

  void fill_in_symbols()
  {
    if(symbol != "")
    {
      if(!find_symbol(symbol,value))
      {
        ostringstream s;
        s << "Undefined symbol '" << symbol << "' on line " << lineno;
        throw s.str();
      }
    }
  }  
};

vector<string> tokenize(string str, string tokens);

int main(int argc, char** argv)
{
  bool verbose = false;
  string input_filename;
  for(int i = 1; i < argc; i++)
  {
    if(strcmp(argv[i],"-v") == 0)
      verbose = true;
    else if(input_filename == "")
      input_filename = argv[i];
    else
      usage();
  }

  if(input_filename == "")
    usage();

  ifstream infile(input_filename.c_str());
  if(!infile)
  {
    cerr << "Could not open " << input_filename << endl;
    return -1;
  }

  for(int i = 0; i < NUM_OPCODES; i++)
    if(opcode_arr[i].str)
      opcodes[opcode_arr[i].str] = new instruction(opcode_arr[i].opcode, opcode_arr[i].alu_opcode, opcode_arr[i].str,opcode_arr[i].type);

  // pseudo-instruction
  opcodes["nop"] = new instruction(0, 0, "nop", R);

  string text;
  infile >> text;
  if(text != ".text")
  {
    cerr << "Input must begin with .text" << endl;
    return -1;
  }

  vector<instruction> program_text;
  vector<data_word> program_data;

  string line;
  string label;
  int lineno = 0;
  int pc = 0;
  bool data_section = false;

  // first pass
  // parse everything except for symbols
  while(getline(infile,line))
  {
   //cout<<"made it here"<<flush;
    lineno++;
    //transform(line.begin(),line.end(),line.begin(),::tolower);

    // discard comments
    int pos = line.find('#');
    if(pos != string::npos)
      line = line.substr(0,pos);    

    istringstream in(line);
    string temp_label,op;
    if(!(in >> temp_label))
      continue;

    if(temp_label == ".data")
    {
      data_section = true;
      pc = 0;
      continue;
    }

    if(*(temp_label.end()-1) != ':')
      op = temp_label;
    else
    {
      label = string(temp_label.begin(),temp_label.end()-1);

      if(symbol_table.count(label))
      {
        cerr << "Duplicate symbol '" << label << "' on line " << lineno << endl;
        return -1;
      }

      symbol_table[label] = pc;

      if(!(in >> op))
        continue;
    }

    if(data_section)
    {
      if(op == ".asciiz")
      {
        int start = line.find('"'), end = line.rfind('"');
        if(start == string::npos || end == string::npos)
        {
          cerr << "Invalid .asciiz directive on line " << lineno << endl;
          return -1;
        }

        for(int i = start+1; i < end; i++)
        {
          program_data.push_back(data_word(line[i],lineno,""));
          pc++;
        }
        program_data.push_back(data_word(0,lineno,""));
        pc++;
      }
      else if(op == ".word")
      {
        string word;
        if(!(in >> word))
        {
          cerr << "Invalid .word directive on line " << lineno << endl;
          return -1;
        }

        data_word dw(atoi(word.c_str()),lineno,"");

        ostringstream oss;
        oss << dw.value;
        if(oss.str() != word)
          dw.symbol = word;

        program_data.push_back(dw);
        pc++;
      }
      else
      {
        cerr << "Unrecognized data directive on line " << lineno << endl
             << "Valid directives are: " << endl
             << "  .asciiz \"This is a string\"" << endl
             << "  .word 12345" << endl;
      }
      continue;
    }

    if(!opcodes.count(op))
    {
      cerr << "Invalid opcode " << op << " on line " << lineno << endl;
      cerr << "Valid opcodes are: " << endl;
      for(map<string,instruction*>::const_iterator it = opcodes.begin(); it != opcodes.end(); ++it)
        cerr << "  " << it->first << endl;
      return -1;
    }

    instruction insn = instruction(*opcodes[op]);
    try
    {
      insn.parse(in);
    }
    catch(string s)
    {
      cerr << "Parse error on line " << lineno << ":" << endl << s << endl;
      return -1;
    }
    insn.pc = pc;
    insn.lineno = lineno;
    label = "";
    for(instruction* insn_ptr = &insn; insn_ptr != NULL; insn_ptr = insn_ptr->next_instruction)
    {
      instruction* temp_ptr = insn_ptr->next_instruction;
      insn_ptr->next_instruction = NULL;
      program_text.push_back(*insn_ptr);
      insn_ptr->next_instruction = temp_ptr;
      pc++;
    }
  }

  if(verbose)
  {
    cerr << "Parsed " << lineno << " lines containing " << program_text.size() << " instructions." << endl;
    cerr << "Symbol table: " << endl;
    for(map<string,int>::const_iterator it = symbol_table.begin(); it != symbol_table.end(); ++it)
      cerr << "  " << it->first << '\t' << it->second << endl;
  }

  // second pass
  // fill in symbols
  for(vector<instruction>::iterator insn = program_text.begin(); insn != program_text.end(); ++insn)
  {
    try
    {
      insn->fill_in_symbols();
    }
    catch(string s)
    {
      cerr << s << endl;
      return -1;
    }
  }

  for(vector<data_word>::iterator word = program_data.begin(); word != program_data.end(); ++word)
  {
    try
    {
      word->fill_in_symbols();
    }
    catch(string s)
    {
      cerr << s << endl;
      return -1;
    }
  }

  int pos = input_filename.find('.');
  if(pos != string::npos)
    input_filename = input_filename.substr(0,pos);

  // removing MIF file support -- ofstream sim_out((input_filename+".sim").c_str());
  ofstream imem_out((input_filename+".mem").c_str());

  // removing MIF file support -- do_mif_header(sim_out,WIDTH,DEPTH);
  // Removing lgsim file support
  // do_lgsim_header(imem_out,WIDTH,IMEM_SIZE);
  // do_lgsim_header(dmem_out,WIDTH,DMEM_SIZE);
/*
  do_mif_header(imem_out,WIDTH,IMEM_SIZE);
  do_mif_header(dmem_out,WIDTH,DMEM_SIZE);
*/

  // print out assembled code
  pc = 0;
  for(vector<instruction>::iterator insn = program_text.begin(); insn != program_text.end(); ++insn)
  {
    // removing MIF file support -- sim_out << mif_line(pc,insn->insn.bits) << endl;
	  imem_out << lgsim_line(pc,insn->insn.bits) << endl;
    pc++;
  }

  for(int i = pc; i < 4096; i++) {
    imem_out << 0 << endl;
  }


  /*for (int ii = 0; ii< 0x4000; ii++)
  {
    dmem_out << lgsim_line(pc,0) << endl;
  }*/

  // pc = 0;
  // for(vector<data_word>::iterator word = program_data.begin(); word != program_data.end(); ++word)
  // {
  //   // removing MIF file support -- sim_out << mif_line(pc+DATA_BASE_ADDR,word->value) << endl;
  //   dmem_out << lgsim_line(pc,word->value) << endl;
  //   pc++;
  // }

  // removing MIF file support --   sim_out << "END;" << endl;

  // removing MIF file support -- sim_out.close();
  imem_out.close();
  
  return 0;
}

void do_lgsim_header(ostream& out, int width, int depth)
{
  out << "v2.0 raw" << endl;
}

/* removing MIF file support -- 
void do_mif_header(ostream& out, int width, int depth)
{
  out << "DEPTH = " << depth << ";" << endl;
  out << "ADDRESS_RADIX = HEX;" << endl;
  out << "DATA_RADIX = HEX;" << endl;
  out << "CONTENT BEGIN;" << endl;
}
*/

string lgsim_line(unsigned short addr, unsigned int val)
{
  ostringstream s;
  s << setw((ADDR_BITS+3)/4) << setfill('0') << hex << val << " ";
/*
  s << setw((ADDR_BITS+3)/4) << setfill('0') << hex << addr << " : ";
  s << setw((ADDR_BITS+3)/4) << setfill('0') << hex << val << " ;";
*/
  return s.str();
}

/* removing MIF file support -- 
string mif_line(unsigned short addr, unsigned short val)
{
  ostringstream s;
  s << setw((ADDR_BITS+3)/4) << setfill('0') << hex << addr << " : ";
  s << setw((ADDR_BITS+3)/4) << setfill('0') << hex << val << " ;";
  return s.str();
}
*/

void usage()
{
  cerr << "Usage:" << endl
       << "  asm [options] <inputfile.s>" << endl
       << endl
       << "Options:" << endl
       << "  -v: verbose output" << endl
       << endl
       << "Upon successful execution, two files are created: " << endl
       << "  inputfile.imem.lgsim: memory initialization file for instruction memory" << endl
       << "  inputfile.dmem.lgsim: memory initialization file for data memory" << endl;
       //<< "  inputfile.sim: memory initialization file for the simulator" << endl;
  exit(0);
}
