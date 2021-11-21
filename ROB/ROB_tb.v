`timescale 1ns/100ps
module ROB_tb;

	// Module Inputs
	reg clock = 0, push = 0, pop = 0, finishing_instr = 0, flushing_instr = 0;
	reg[4:0] rd_in = 0, rd_search_0 = 0, rd_search_1 = 0, rd_search_2 = 0, rd_search_3 = 0;
	reg[31:0] instr_to_finish = 0,
			 finish_val = 0, instr_in = 0, instr_to_flush = 0; 

	// Module outputs
	wire[31:0] head_instr, head_val;
	wire head_ready, is_full, is_empty;
	wire [31:0]
        bypass_val_0,
        bypass_val_1,
        bypass_val_2,
        bypass_val_3;

	// Instantiate the module
	ROB #(.SIZE(10)) dut (    
        .clock(clock),
        .push(push),
        .pop(pop),
        .finishing_instr(finishing_instr),
		.reset(1'b0),

        .is_full(is_full),
        .is_empty(is_empty),

        .instr_to_finish(instr_to_finish),
        .finish_val(finish_val),

        .instr_to_flush(instr_to_flush),
        .flushing_instr(flushing_instr),

        .instr_in(instr_in), 
		.rd_in(rd_in),

        .rd_search_0(rd_search_0),
        .rd_search_1(rd_search_1),
        .rd_search_2(rd_search_2),
        .rd_search_3(rd_search_3),
    
        .bypass_val_0(bypass_val_0),
        .bypass_val_1(bypass_val_1),
        .bypass_val_2(bypass_val_2),
        .bypass_val_3(bypass_val_3),

        .head_instr(head_instr),
        .head_val(head_val),
        .head_ready(head_ready));

	// Initialize our strings
	reg[1023:0] instrFileName, actFileName, testName;

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
		$fdisplay(actFile, "push, pop, instr_in, finishing_instr, instr_to_finish, finish_val,head_instr, head_val, head_ready, is_empty, is_full");

		// Ignore the header of the instrected file
		instrScan = $fscanf(instrFile, "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", 
			push, pop, instr_in, rd_in, finishing_instr, instr_to_finish, finish_val, flushing_instr, instr_to_flush, rd_search_0, rd_search_1, rd_search_2, rd_search_3);

		if(instrScan == 0) begin
			$display("Error reading the %0s file.\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		// Get the input for the parameters from the input file
		instrScan = $fscanf(instrFile, "%b,%b,%d,%d,%b,%d,%d,%b,%d,%d,%d,%d,%d",
			push, pop, instr_in, rd_in, finishing_instr, instr_to_finish, finish_val, flushing_instr, instr_to_flush, rd_search_0, rd_search_1, rd_search_2, rd_search_3);

		if(instrScan != 13) begin
			$display("Error reading %0s\nMake sure there are no spaces ANYWHERE in your file.\nYou can check by opening it in a text editor.", instrFileName);
			$finish;
		end

		$dumpfile({testName, ".vcd"});
		$dumpvars(0, ROB_tb);

		// Iterate until reaching the end of the file
		while(instrScan == 13) begin

			@(negedge clock);

			// Write the actual module outputs to the actual file
			$fdisplay(actFile, "%b,%b,%d,%b,%d,%d,%d,%d,%b,%b,%b",
				push, pop, instr_in, finishing_instr, instr_to_finish, finish_val,
				head_instr, head_val, head_ready, is_empty, is_full);
			
			tests = tests + 1;

			// Get the input for the parameters from the input file
			instrScan = $fscanf(instrFile, "%b,%b,%d,%d,%b,%d,%d,%b,%d,%d,%d,%d,%d",
				push, pop, instr_in, rd_in, finishing_instr, instr_to_finish, finish_val, flushing_instr, instr_to_flush, rd_search_0, rd_search_1, rd_search_2, rd_search_3);
		end

		if (instrScan > 0) begin
			$display("Testbench ended prematurely, please check line %0d", tests+1);
			$finish;
		end

		// Close the Files
		$fclose(instrFile);
		$fclose(actFile);

		$display("DONE\n");
		$finish;
	end

	always
		#10 clock <= ~clock;
endmodule