`timescale 1ns/100ps
module ROB_tb;

	// Module Inputs
	reg clock = 0, push = 0, pop = 0, finish_instr = 0;
	reg[31:0] instr_to_finish = 0,
			 finish_val = 0, instr_in = 0; 

	// Module outputs
	wire[31:0] head_instr, head_val;
	wire head_ready, is_full, is_empty;

	// Instantiate the module
	ROB #(.SIZE(10)) dut (    
        .clock(clock),
        .push(push),
        .pop(pop),
        .finish_instr(finish_instr),
		.reset(1'b0),

        .is_full(is_full),
        .is_empty(is_empty),

        .instr_to_finish(instr_to_finish),
        .finish_val(finish_val),

        .instr_in(instr_in), 
        .head_instr(head_instr),
        .head_val(head_val),
        .head_ready(head_ready));

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
		instrScan = $fscanf(instrFile, "%s,%s,%s,%s,%s,%s", 
			push, pop, instr_in, finish_instr, instr_to_finish, finish_val);

		if(instrScan == 0) begin
			$display("Error reading the %0s file.\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		// Get the input for the parameters from the input file
		instrScan = $fscanf(instrFile, "%b,%b,%h,%b,%h,%h",
			push, pop, instr_in, finish_instr, instr_to_finish, finish_val);

		if(instrScan != 6) begin
			$display("Error reading %0s\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		$dumpfile({testName, ".vcd"});
		$dumpvars(0, ROB_tb);

		// Iterate until reaching the end of the file
		while(instrScan == 6) begin

			@(negedge clock);

			// Write the actual module outputs to the actual file
			$fdisplay(actFile, "%b,%b,%h,%b,%h,%h,%h,%h,%b,%b,%b",
				push, pop, instr_in, finish_instr, instr_to_finish, finish_val,
				head_instr, head_val, head_ready, is_empty, is_full);
			
			tests = tests + 1;

			// Get the input for the parameters from the input file
			instrScan = $fscanf(instrFile, "%b,%b,%h,%b,%h,%h",
				push, pop, instr_in, finish_instr, instr_to_finish, finish_val);
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