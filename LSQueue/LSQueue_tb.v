`timescale 1ns/100ps
module LSQueue_tb;

	// Module Inputs
	reg clock = 0, reset = 0, push = 0, pop = 0, flushing_instr = 0;
	reg[31:0] instr_in = 0, instr_to_flush = 0; 

	// Module outputs
	wire[31:0] head_instr;
	wire head_ready, is_full, is_empty;

	// Instantiate the module
	LSQueue #(.SIZE(10)) dut (    
        .clock(clock),
        .reset(reset),
        .push(push),
        .pop(pop),

        .is_full(is_full),
        .is_empty(is_empty),

        .instr_to_flush(instr_to_flush),
        .flushing_instr(flushing_instr),

        .instr_in(instr_in), 
 
        .head_instr(head_instr));

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
		instrScan = $fscanf(instrFile, "%s,%s,%s,%s,%s", 
			push, pop, instr_in, flushing_instr, instr_to_flush);

		if(instrScan == 0) begin
			$display("Error reading the %0s file.\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		// Get the input for the parameters from the input file
		instrScan = $fscanf(instrFile, "%b,%b,%d,%b,%d", 
			push, pop, instr_in, flushing_instr, instr_to_flush);

		if(instrScan != 5) begin
			$display("Error reading %0s\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		$dumpfile({testName, ".vcd"});
		$dumpvars(0, LSQueue_tb);

		// Iterate until reaching the end of the file
		while(instrScan == 5) begin

			@(negedge clock);

			// Write the actual module outputs to the actual file
			$fdisplay(actFile, "%b,%b,%d,%d,%b,%b",
				push, pop, instr_in,
				head_instr, is_empty, is_full);
			
			tests = tests + 1;

			// Get the input for the parameters from the input file
			instrScan = $fscanf(instrFile, "%b,%b,%d,%b,%d", 
				push, pop, instr_in, flushing_instr, instr_to_flush);
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