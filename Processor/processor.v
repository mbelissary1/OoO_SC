/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    // Wires for control opertations
    // needs_flush goes high for "wrong guess" branches and jump-returns so we can flush out the pipeline
    wire needs_flush, decode_jr, decode_jal, execute_jal, decode_bex, execute_setx;

    // Wires for multdiv operations
    wire multdiv_in_progress, multdiv_complete;

    // Detect pipeline hazards!!!
    // Identify potentially hazardous instructions!
    wire potential_hazard = (decode_r_type | decode_addi | decode_lw | decode_sw | decode_jr);
    wire [4:0] haz1, haz2;
    wire rs_zero = &(!FD_out[21:17]); // Check for zeroed rs (you can't actually write to zero, so not a hazard!!!)
    wire rt_zero = &(!FD_out[16:12]); // Check for zeroed rt (ditto)
    xnor haz1_gate[4:0](haz1, FD_out[21:17], DX_out[26:22]); // Assert true if FD_out[21:17] (rs and rd?) decode and execute respectively
    xnor haz2_gate[4:0](haz2, FD_out[16:12], DX_out[26:22]); // (rt and rd?) ditto

    wire haz1_check = &haz1 & !rs_zero & potential_hazard; // Hazard condition and it's "legit" 
    wire haz2_check = &haz2 &!decode_r_type &!rt_zero; // Likewise

    wire stall = execute_lw && (haz1_check || haz2_check); // STALL! Only on an execute lw though...

    // FETCH!

    // Handle possible control redirections

    // Opcode matching
    wire fetch_jump = (q_imem[31:27] == 5'b00001);
    wire fetch_jal = (q_imem[31:27] == 5'b00011);
    wire fetch_jr = (q_imem[31:27] == 5'b00100);
    wire fetch_rng = (q_imem[31:27] == 5'b11111);
    wire[31:0] jump_address = decode_jr ? data_readRegB : q_imem[26:0]; // jr? Comes out of data_readRegB! Otherwise just pull the next instruction...
    wire[31:0] bex_data = execute_setx ? DX_out[26:0] : (memory_setx ? XM_out[26:0] : (write_setx ? MW_out[26:0] : data_readRegB)); // Just does what a bex does
    wire [31:0] final_address = (decode_bex && !(bex_data == 32'b0)) ? FD_out[26:0] : jump_address; // Decode bex and bex_data nonzero? Grab the bex address. Otherwise just keep on rolling.


    wire bootstrap_cycles_fetch = (address_imem == 32'b0 || address_imem == 32'b1); // Kinda hacky, but avoids inaccurate x assertions

    // In the event that we are attempting to concurrently read and write to the same register...we can't do that!
    wire read_and_write_haz = fetch_jr && ((q_imem[26:22] == FD_out[26:22] || decode_jal) || (q_imem[26:22] == DX_out[26:22] || execute_jal) || (q_imem[26:22] == XM_out[26:22] || memory_jal));

    // Define the program counter (PC)
    wire overflow_PC, unused_PC_q_not, overflow_branch_PC, check_jump;
    wire [31:0] program_counter, program_counter_increment, branch_program_counter;

    csa_32_bit PC_adder(program_counter_increment, overflow_PC, address_imem, 32'b1, 1'b0);
    csa_32_bit PC_branch_adder(branch_program_counter, overflow_branch_PC, DX_out[63:32], DX_out[16:0], 1'b1);

    // If flush is asserted, then we need to take the branch case!!!
    // Otherwise, assume that we're not branching.
    assign program_counter = (needs_flush & !bootstrap_cycles_fetch) ? branch_program_counter : program_counter_increment;
    assign check_jump = (fetch_jump | fetch_jal | decode_jr | (decode_bex && !(bex_data == 32'b0))); // Check for jumps and handle them accordingly
    dffe_ref PC[31:0](address_imem, unused_PC_q_not, check_jump ? final_address : program_counter, !clock, !stall & !multdiv_in_progress & !read_and_write_haz, reset);
    
   
    wire [31:0] jal_replacement;
    assign jal_replacement[31:27] = 5'b00011; // Populate the top 5 with the JAL opcode as a placeholder
    assign jal_replacement [26:0] = program_counter; // Set the return address (and hope that some 310 student hasn't gotten to the stack smash lab yet...)

    wire [31:0] rng_replacement;
    assign rng_replacement[31:22] = q_imem[31:22];
    assign rng_replacement[21:0] = 22'b0;

    // F/D Pipeline Stage (64-bit register, PC [63:32], Instruction[31:0])
    wire [63:0] FD_in, FD_out;
    wire [31:0] check_fetch_jal;
    wire unused_FD_q_not;
    
    assign FD_in[63:32] = read_and_write_haz ? 32'b0 : address_imem;
    assign check_fetch_jal = fetch_jal ? jal_replacement : (fetch_rng ? rng_replacement : q_imem);
    assign FD_in[31:0] = read_and_write_haz ? 32'b0 : check_fetch_jal;
    dffe_ref FD[63:0](FD_out, unused_FD_q_not, (decode_jr | needs_flush | (decode_bex && !(bex_data == 32'b0))) ? 64'b0 : FD_in, !clock, !stall & !multdiv_in_progress, reset);

    // DECODE!

    // Parse out the opcode to determine what type of instruction we have.
    wire decode_r_type = &(!FD_out[31:27]);
    wire decode_addi = !FD_out[31] & !FD_out[30] & FD_out[29] & !FD_out[28] & FD_out[27];
    wire decode_lw = !FD_out[31] & FD_out[30] & !FD_out[29] & !FD_out[28] & !FD_out[27];
    wire decode_sw = !FD_out[31] & !FD_out[30] & FD_out[29] & FD_out[28] & FD_out[27];
    assign decode_jr = !FD_out[31] & !FD_out[30] & FD_out[29] & !FD_out[28] & !FD_out[27];
    assign decode_jal = !FD_out[31] & !FD_out[30] & !FD_out[29] & FD_out[28] & FD_out[27];
    assign decode_bex = FD_out[31] & !FD_out[30] & FD_out[29] & FD_out[28] & !FD_out[27];

    // For r-type instructions, addi, load and store word, and bne/blt, readRegA is rs
    assign ctrl_readRegA = FD_out[21:17]; // Load in rs to crtl_readRegA (no harm if we don't use it!)

    // For r-type instructions, readRegB is rt for store word, it's rd
    // Make the distinction and load in, again no harm if unused
    assign ctrl_readRegB = decode_bex ? 5'b11110 : (decode_r_type ? FD_out[16:12] : FD_out[26:22]); 

    // D/X Pipeline Stage
    wire [127:0] DX_in;
    wire [127:0] DX_out;
    wire unused_DX_q_not;
    // Note that on stalls, we flush with nops to purge out the bad instructions. (bad branch prediction and multdiv for example)
    assign DX_in[127:96] = stall ? 32'b0 : data_readRegA; // A
    assign DX_in[95:64] = stall ? 32'b0 : data_readRegB; // B
    assign DX_in[63:32] = stall ? 32'b0 : FD_out[63:32]; // PC
    assign DX_in[31:0] = stall ? 32'b0 : FD_out[31:0]; // IR
    dffe_ref DX[127:0](DX_out, unused_DX_q_not, needs_flush ? 128'b0 : DX_in, !clock, !multdiv_in_progress || multdiv_complete, reset);

    
    // EXECUTE!

    // Parse out the opcode to determine what type of instruction we have.
    wire execute_r_type = &(!DX_out[31:27]);
    wire execute_addi = !DX_out[31] & !DX_out[30] & DX_out[29] & !DX_out[28] & DX_out[27];
    wire execute_lw = !DX_out[31] & DX_out[30] & !DX_out[29] & !DX_out[28] & !DX_out[27];
    wire execute_sw = !DX_out[31] & !DX_out[30] & DX_out[29] & DX_out[28] & DX_out[27];
    assign execute_jal = !DX_out[31] & !DX_out[30] & !DX_out[29] & DX_out[28] & DX_out[27];
    wire execute_bne = !DX_out[31] & !DX_out[30] & !DX_out[29] & DX_out[28] & !DX_out[27];
    wire execute_blt = !DX_out[31] & !DX_out[30] & DX_out[29] & DX_out[28] & !DX_out[27];
    assign execute_setx = DX_out[31] & !DX_out[30] & DX_out[29] & !DX_out[28] & DX_out[27];
    wire execute_close_enough = (DX_out[31:27] == 5'b11110);
    wire execute_rng = &(DX_out[31:27]);

    // ALU Bypassing

    // General utilization/dependency logic
    // Basically isomorphic to the above bypassing case. Set high if we have an instruction that could be hazardous.
    wire XM_utilizes_rd = memory_r_type || memory_addi || memory_lw || memory_setx || memory_rng;
    wire DX_utilizes_rs = execute_r_type || execute_addi || execute_lw || execute_sw || execute_bne || execute_blt;
    wire MW_utilizes_rd = write_r_type || write_addi || write_lw || write_setx || write_rng;

    // Input A bypassing logic
    wire [4:0] XM_rd_equals_DX_rs; // Check for concurrent use bypass
    wire [4:0] MW_rd_equals_DX_rs; // Likewise
    xnor XM_rd_equals_DX_rs[4:0](XM_rd_equals_DX_rs, XM_out[26:22], DX_out[21:17]);
    xnor MW_rd_equals_DX_rs[4:0](MW_rd_equals_DX_rs, MW_out[26:22], DX_out[21:17]);

    // Check resultant bypassing logic for A
    // Actually determine if we're going to bypass 
    wire WX_bypass_A = (MW_utilizes_rd && DX_utilizes_rs && (&MW_rd_equals_DX_rs) && (|MW_out[26:22])) || (write_jal && (DX_out[21:17] == 5'b11111));
    wire MX_bypass_A = (XM_utilizes_rd && DX_utilizes_rs && (&XM_rd_equals_DX_rs) && (|XM_out[26:22])) || (memory_jal && (DX_out[21:17] == 5'b11111));

    // This multiplexer determines what operand A of the ALU will be
    // 00: no bypass ==> Use the regular operand
    // 01: WX_bypass ==> Use the data from memory data_writeReg
    // 10/11: MX_bypass ==> Use the previous ALU output

    // NOTE: We prioritize MX bypasses over WX bypasses because the memory stage comes before writeback
    // and thus is more recent.
    wire [31:0] ALU_operand_A;
    wire [1:0] ALU_operand_A_CTRL;
    assign ALU_operand_A_CTRL[1] = MX_bypass_A;
    assign ALU_operand_A_CTRL[0] = WX_bypass_A;
    mux_4 ALU_operand_A_mux(ALU_operand_A, ALU_operand_A_CTRL, DX_out[127:96], data_writeReg, XM_out[95:64], XM_out[95:64]);

    // Input B bypassing logic
    wire[4:0] XM_rd_equals_DX_rt;
    wire[4:0] MW_rd_equals_DX_rt;
    wire[4:0] operand_B_reg = (execute_lw || execute_sw || execute_bne || execute_blt) ? DX_out[26:22] : DX_out[16:12];
    xnor XM_rd_equals_DX_rt[4:0](XM_rd_equals_DX_rt, XM_out[26:22], operand_B_reg);
    xnor MW_rd_equals_DX_rt[4:0](MW_rd_equals_DX_rt, MW_out[26:22], operand_B_reg);
    
    // Check resultant bypassing logic for B
    wire WX_bypass_B = (MW_utilizes_rd && (execute_r_type || execute_lw || execute_sw || execute_blt || execute_bne) && (&MW_rd_equals_DX_rt) && (|MW_out[26:22])) || (write_jal && (operand_B_reg == 5'b11111));
    wire MX_bypass_B = (XM_utilizes_rd && (execute_r_type || execute_lw || execute_sw || execute_blt || execute_bne) && (&XM_rd_equals_DX_rt) && (|XM_out[26:22])) || (memory_jal && (operand_B_reg == 5'b11111));

    // This multiplexer determines what operand B of the ALU will be
    // Implementation is basically the same as the one for operand A

    // Same prioritization decision as above. Basically just isomorphic.
    wire [31:0] ALU_operand_B;
    wire [1:0] ALU_operand_B_CTRL;
    assign ALU_operand_B_CTRL[1] = MX_bypass_B;
    assign ALU_operand_B_CTRL[0] = WX_bypass_B;
    mux_4 ALU_operand_B_mux(ALU_operand_B, ALU_operand_B_CTRL, DX_out[95:64], data_writeReg, XM_out[95:64], XM_out[95:64]);

    // ALU
    wire [31:0] ALU_out;
    wire ALU_NE, ALU_GT, ALU_overflow;
    // Also kind of a hack (peep that nested ternary!) but it handles the branching cases fairly cleanly.
    wire [4:0] ALU_opcode = (execute_blt || execute_bne || execute_close_enough) ? 5'b00001 : (execute_r_type ? DX_out[6:2] : 5'b00000);
    wire [31:0] final_ALU_operand_B;
    wire [31:0] signed_immediate;
    assign signed_immediate[16:0] = DX_out[16:0]; // Grab the immediate value from the DX latch
    assign signed_immediate[31:17] = {15{DX_out[16]}}; // Sign extend it to fit the full 32-bits
    assign final_ALU_operand_B[31:0] = (execute_addi | execute_lw | execute_sw | execute_close_enough) ? signed_immediate : ALU_operand_B;
    alu alu(execute_close_enough ? 32'd450 : ALU_operand_A, final_ALU_operand_B, ALU_opcode, DX_out[11:7], ALU_out, ALU_NE, ALU_GT, ALU_overflow);
    wire is_close_enough = ((ALU_out[31:7] == 25'b0) || (ALU_out[31:7] == 25'd33554431));
    // Determine if we need to flush out bad instructions as a result of a branching operation
    // It's basically what it looks like.
    assign needs_flush = (execute_blt && !ALU_GT && ALU_NE) || (execute_bne && ALU_NE);


    
    // Multdiv
    wire [31:0] multdiv_out;
    wire unused_multdiv_q_not, multdiv_overflow;
    wire ctrl_MULT = (ALU_opcode == 5'b00110) && !multdiv_in_progress && (DX_out[31:27] == 5'b00000);
    wire ctrl_DIV = (ALU_opcode == 5'b00111) && !multdiv_in_progress && (DX_out[31:27] == 5'b00000);
    // This latch basically just keeps track of whether or not multdiv is running. 
    // This is used to determine when fetch and decode should halt!
    dffe_ref multdiv_status_latch(multdiv_in_progress, unused_multdiv_q_not, ctrl_MULT | ctrl_DIV, clock, ctrl_MULT | ctrl_DIV | multdiv_complete, reset);
    multdiv multdiv(ALU_operand_A, ALU_operand_B, ctrl_MULT, ctrl_DIV, clock, multdiv_out, multdiv_overflow, multdiv_complete);

    // RNG
    wire[1:0] rng_out;
    rng random_number_generator(rng_out, clock);

    // If we've completed a multdiv operation, recover from the stall and take that output, otherwise default 
    // to the ALU output!
    wire [31:0] execute_stage_output = (multdiv_complete && multdiv_in_progress) ? multdiv_out : (execute_close_enough ? is_close_enough : (execute_rng ? rng_out : ALU_out));

    // X/M Pipeline Stage
    wire [127:0] XM_out;
    wire [127:0] XM_in;
    wire unused_XM_q_not;
    assign XM_in[127:96] = DX_out[63:32];
    assign XM_in[95:64] = (ALU_overflow || (multdiv_overflow && multdiv_in_progress)) ? 32'b1 : execute_stage_output;
    assign XM_in[63:32] = ALU_operand_B;
    // Avoid the prematurely asserting overflow from the x's that result from the initial filling of the pipeline
    wire bootstrap_cycles = (DX_out[63:32] == 32'd0 || DX_out[63:32] == 32'd1);
    // Kind of a hack, but this handles the overflow cases...
    assign XM_in[31:0] = ((ALU_overflow || (multdiv_overflow && multdiv_in_progress)) && !bootstrap_cycles) ? 32'b00101111100000000000000000000001 : DX_out[31:0];
    dffe_ref XM[127:0](XM_out, unused_XM_q_not, XM_in, !clock, !multdiv_in_progress || multdiv_complete, reset);


    // MEMORY!

    // Parse out the opcode to determine what type of instruction we have.
    wire memory_r_type = &(!XM_out[31:27]);
    wire memory_addi = !XM_out[31] & !XM_out[30] & XM_out[29] & !XM_out[28] & XM_out[27];
    wire memory_lw = !XM_out[31] & XM_out[30] & !XM_out[29] & !XM_out[28] & !XM_out[27];
    wire memory_sw = !XM_out[31] & !XM_out[30] & XM_out[29] & XM_out[28] & XM_out[27];
    wire memory_setx = XM_out[31] & !XM_out[30] & XM_out[29] & !XM_out[28] & XM_out[27];
    wire memory_jal = !XM_out[31] & !XM_out[30] & !XM_out[29] & XM_out[28] & XM_out[27];
    wire memory_rng = &(XM_out[31:27]);

    // We only enable writes for store-word instructions
    assign wren = memory_sw ? 1'b1 : 1'b0;

    // Check for possible WM bypassing
    // We've beat this to death at this point
    wire [4:0] XM_rd_equals_MW_rd, XM_rd_equals_MW_rs;
    xnor XM_rd_equals_MW_rd[4:0](XM_rd_equals_MW_rd, XM_out[26:22], MW_out[26:22]);
    xnor XM_rd_equals_MW_rs[4:0](XM_rd_equals_MW_rs, XM_out[26:22], MW_out[21:17]);
    wire WM_bypass = memory_sw && write_lw && &XM_rd_equals_MW_rd && (|MW_out[26:22]);
    
    assign data = WM_bypass ? data_writeReg : XM_out[63:32];

    assign address_dmem = XM_out[95:64];


    // M/W Pipeline Stage
    wire [127:0] MW_out;
    wire [127:0] MW_in;
    wire unused_MW_q_not;
    assign MW_in[127:96] = XM_out[127:96];
    assign MW_in[95:64] = XM_out[95:64];
    assign MW_in[63:32] = q_dmem;
    assign MW_in[31:0] = XM_out[31:0];
    dffe_ref MW[127:0](MW_out, unused_MW_q_not, MW_in, !clock, !multdiv_in_progress || multdiv_complete, reset);

    // WRITEBACK!

    // Parse out the opcode to determine what type of instruction we have.
    // For R-type, addi, jal, lw, or setx instruction ctrl_writeEnable is true
    wire write_r_type = &(!MW_out[31:27]);
    wire write_addi = !MW_out[31] & !MW_out[30] & MW_out[29] & !MW_out[28] & MW_out[27];
    wire write_jal = !MW_out[31] & !MW_out[30] & !MW_out[29] & MW_out[28] & MW_out[27];
    wire write_setx = MW_out[31] & !MW_out[30] & MW_out[29] & !MW_out[28] & MW_out[27];
    wire write_lw = !MW_out[31] & MW_out[30] & !MW_out[29] & !MW_out[28] & !MW_out[27];
    wire write_rng = &(MW_out[31:27]);
    wire write_close_enough = (MW_out[31:27] == 5'b11110);
    or write_enable(ctrl_writeEnable, write_r_type, write_addi, write_jal, write_setx, write_lw, write_rng, write_close_enough);

    // ctrl_writeReg for r-type, addi, and LW is rd
    // ctrl_writeReg for jal is r31
    // ctrl_writeReg for setx is r30 (rstatus)
    wire[4:0] wr_reg = write_jal ? 5'b11111 : 5'b11110;
    assign ctrl_writeReg = (write_jal) ? wr_reg : (write_setx ? 5'b11110 : MW_out[26:22]);

    // 00: lw ==> q_dmem
    // 01: setx ==> T
    // 10: jal ==> PC + 1
    // 11: r-type/addi ==> Execute Stage Out

    wire[1:0] ctrl_WR_mux;
    assign ctrl_WR_mux[1] = write_r_type | write_addi | write_jal | write_rng | write_close_enough;
    assign ctrl_WR_mux[0] = ctrl_WR_mux[1] ? (write_r_type | write_addi | write_rng | write_close_enough) : write_setx;
    mux_4 WR_mux(data_writeReg, ctrl_WR_mux, MW_out[63:32], MW_out[26:0], MW_out[26:0], MW_out[95:64]);

endmodule