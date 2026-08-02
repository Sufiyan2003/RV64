/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the riscv 64 core
-- TODO: must have an axi interface to communicate with the L2 cache
------------------------------------------------------------------------------*/

module RV64_core (
	input clk,
	input resetn
);


	logic [63:0] instr_addr;
	logic o_read_valid;
	/*------------------------------------------------------------------------------
	--  						Instruction Fetch
	------------------------------------------------------------------------------*/
	ProgramCounter #(
		.WIDTH(64),
		.DEFAULT_VAL(64'h8000_0000)
	) PC(
		.clk         (clk),
		.resetn      (resetn),
		.i_stall     (1'b0),   		// stall signal will come from cache controller
		.o_instr_addr(instr_addr)
	);


	cache_controller Icache(
		.clk         (clk),
		.resetn      (resetn),
		.i_pc        (instr_addr),
		.o_read_valid(o_read_valid)
	);


endmodule : RV64_core