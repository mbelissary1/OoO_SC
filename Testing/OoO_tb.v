`timescale 1ns/100ps
module OoO_tb #(parameter FILE = "nop", ROB_SIZE = 32, SCORE_SIZE = 32);

	// FileData
	localparam DIR = "Test Files/";
	localparam MEM_DIR = "Memory Files/";
	localparam OUT_DIR = "Output Files/";
	localparam VERIF_DIR = "Verification Files/";
	localparam DEFAULT_CYCLES = 255;

	// Module Inputs
	reg clock = 0, reset = 0;

	// Module outputs
	wire[31:0] instrOut;

	// Instantiate the PC and ROM Access
	wire rwe, mwe;
    wire[4:0] rd, rs1, rs2;
    wire[31:0] instAddr, instData, 
               rData, regA, regB,
               memAddr, memDataIn, memDataOut;

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "";

	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));

	// Access the PC values
	assign PCin = PCout + 32'b1;
    reg32 regPC(.q(PCout), .d(PCin), .clk(clock), .en(1'b1), .clr(reset));
	assign address_imem = PCout[11:0];

	// Instantiate the Scoreboard
	Scoreboard #(.SIZE(ROB_SIZE)) dut (    
        .clock(clock),
        .reset(reset),
        .push(push),
        .start_head(pop),
        .committing_instr(committing_instr),
    
        .is_full(is_full),
        .is_empty(is_empty),

        .instr_to_finish(instr_to_finish),

        .instr_to_flush(instr_to_flush),
        .flushing_instr(flushing_instr),

        .instr_in(instData), 
        .rd_in(instData[26;22]),
        .rs1_in(rs1_in[21:17]),
        .rs2_in(rs2_in[16:12]),
        
        .head_instr(head_instr),
        .head_ready(head_ready));

	// Instantiate the Load Store Queue

	// Instantiate the latency stallers
	multiCycleInsnSim #(parameter LATENCY=8, SIZE=32) lwStaller (
																 .instrIn(instrIn), 
																 .clock(clock), 
																 .enable(enable), 
																 .reset(reset), 
																 .instrOut(instrOut), 
																 .instrRDY(instrRDY));
	multiCycleInsnSim #(parameter LATENCY=16, SIZE=32) mulStaller (
																 .instrIn(instrIn), 
																 .clock(clock), 
																 .enable(enable), 
																 .reset(reset), 
																 .instrOut(instrOut), 
																 .instrRDY(instrRDY));
	multiCycleInsnSim #(parameter LATENCY=32, SIZE=32) divStaller (
																 .instrIn(instrIn), 
																 .clock(clock), 
																 .enable(enable), 
																 .reset(reset), 
																 .instrOut(instrOut), 
																 .instrRDY(instrRDY));

	//


	// Initialize our strings
	reg[255:0] instrFileName, actFileName, testName;

	// Where to store file error codes
	integer 	paramFile, 	   instrFile,		diffFile, 	  actFile,
				paramScan,	   instrScan;

	// Metadata
	integer errors = 0,
			tests = 0;

	initial begin

		// Assign Command Line Arguments to the Inputs
		if(! $value$plusargs("test=%s", testName)) begin
			$display("Please specify the test");
			$finish;
		end

		// Create the names for the files we are using
		instrFileName =   {testName, "_instr.csv"};
		actFileName =   {testName, "_actual.csv"};

		// Read the instruction file
		instrFile = $fopen(instrFileName, "r");

		// Check for any errors in opening the file
		if(!instrFile) begin
			$display("Couldn't read the instruction file.",
				"\nMake sure you are in the right directory and the %0s_instr.csv file exists.", testName);
			$finish;
		end

		// Create the files to store the output
		actFile   = $fopen(actFileName,   "w");

		// Add the headers to the Actual and Difference files
		$fdisplay(actFile, "Head Instruction, Head Value, Head Ready, Empty, Full");

		// Ignore the header of the instrected file
		instrScan = $fscanf(instrFile, "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", 
			push, pop, instr_in, rd_in, rs1_in, rs2_in, committing_instr, instr_to_finish, flushing_instr, instr_to_flush);

		if(instrScan == 0) begin
			$display("Error reading the %0s file.\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		// Get the input for the parameters from the input file
		instrScan = $fscanf(instrFile, "%b,%b,%d,%d,%d,%d,%b,%d,%b,%d",
			push, pop, instr_in, rd_in, rs1_in, rs2_in, committing_instr, instr_to_finish, flushing_instr, instr_to_flush);

		if(instrScan != 10) begin
			$display("Error reading %0s\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		$dumpfile({testName, ".vcd"});
		$dumpvars(0, Scoreboard_tb);

		// Iterate until reaching the end of the file
		while(instrScan == 10) begin

			@(negedge clock);

			// Write the actual module outputs to the actual file
			$fdisplay(actFile, "%b,%b,%d,%d,%d,%d,%b,%d,%d,%b,%b,%b",
				push, pop, instr_in, rd_in, rs1_in, rs2_in, committing_instr, instr_to_finish,
				head_instr, head_ready, is_empty, is_full);
			
			tests = tests + 1;

			// Get the input for the parameters from the input file
			instrScan = $fscanf(instrFile, "%b,%b,%d,%d,%d,%d,%b,%d,%b,%d",
				push, pop, instr_in, rd_in, rs1_in, rs2_in, committing_instr, instr_to_finish, flushing_instr, instr_to_flush);
		end

		if (instrScan > 0) begin
			$display("Testbench ended prematurely, please check line %0d", tests+1);
			$finish;
		end

		// Close the Files
		$fclose(instrFile);
		$fclose(actFile);

		$display("DONE\n");

		#100;
		$finish;
	end

	always
		#10 clock <= ~clock;
endmodule

module OoO.v #(parameter ROB_SIZE=32, SCORE_SIZE=32) ()

// If ROB or Scoreboard is full, dont allocate