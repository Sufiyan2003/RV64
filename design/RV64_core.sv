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
		.clk         (clk)			,
		.resetn      (resetn)		,
		.i_stall     (o_stall_pc)	,
		.o_instr_addr(instr_addr)
	);


	cache_controller Icache_controller(
		.clk         (clk)				,
		.resetn      (resetn)			,
		.i_pc        (instr_addr)		,
		.o_read_valid(o_read_valid)		,
		.o_instr_addr(instr_addr)		,
		.o_stall_pc  (o_stall_pc)
	);


	cache_top Icache (
		.clk        (clk)				,
		.resetn     (resetn)			,
		.i_data     () 					
	);




endmodule : RV64_core