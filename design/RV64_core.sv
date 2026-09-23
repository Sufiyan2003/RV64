/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the riscv 64 core
-- TODO: must have an axi interface to communicate with the L2 cache
------------------------------------------------------------------------------*/

`include "riscv_typedefs.svh"
`include "cache_params.svh"

module RV64_core #(
	parameter XLEN = 32
)(
	input clk 				,
	input resetn 			,
	axi4_intf.master axi_if
);


	logic [63:0] 			instr_addr 			;
	logic 					o_read_valid 		;
	logic 					address_valid 		;
	logic 					o_stall_pc 			;
	logic 					o_axi_req_valid 	;
	logic [ADDR_WIDTH-1:0] 	o_axi_req_addr 		; 
	logic 					i_axi_rsp_ready 	;
	logic [DWIDTH-1:0] 		i_axi_rsp_line 		;
	logic [31:0] 			o_instruction 		;
	control_signals_t 		exec_control_sigs 	;
	logic [XLEN-1:0]        immediate 			;
	logic [XLEN - 1: 0]     alu_out 			; 
	logic [XLEN - 1: 0] 	rd1, rd2 			;
	logic [ADDR_WIDTH-1:0]	if_instr_addr 		;
	logic 					if_instr_valid 		;
	logic 		WB			;
	logic 		MemRd		;
	logic [2:0] ALUOp		;
	logic 		ALUSrc		;
	logic 		ASel		;


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
		.o_instr_addr(instr_addr) 	,
		.o_req_valid (address_valid)
	);



	/*------------------------------------------------------------------------------
	--  					Cache to store instructions
	------------------------------------------------------------------------------*/
	IF_stage fetch_stage(
		.clk 					(clk)				,
		.resetn					(resetn)			,
		.i_PC					(instr_addr)		,
		.o_stall_pc				(o_stall_pc)		,
		.o_axi_req_valid		(o_axi_req_valid)	,
		.o_axi_req_addr			(o_axi_req_addr)	,
		.i_axi_rsp_ready		(i_axi_rsp_ready)	,
		.i_axi_rsp_line			(i_axi_rsp_line)	,
		.address_valid			(address_valid)		,
		.o_instruction 			(o_instruction) 	,
		.o_instr_addr 			(if_instr_addr)		,
		.o_instr_valid 			(if_instr_valid)
	);

	/*------------------------------------------------------------------------------
	--  	An AXI-4 wrapper to take beats and form a complete line
	------------------------------------------------------------------------------*/
	axi_cache_requester axi_icache_master(
		.clk        	(clk)					,
		.resetn     	(resetn)				,
		.i_axi_addr 	(o_axi_req_addr)			,
		.i_axi_fetch	(o_axi_req_valid)		,
		.i_axi_evict	(1'b0)					,
		.o_line     	(i_axi_rsp_line)		,
		.o_line_valid	(i_axi_rsp_ready)		,
		.axi_if     	(axi_if)
	);

	/*------------------------------------------------------------------------------
	--  					Instruction Decode Step
	------------------------------------------------------------------------------*/

	ID_stage #(
		.XLEN(XLEN)
	) decode_stage(
		.clk             	(clk)				,
		.resetn          	(resetn)			,
		.i_instruction   	(o_instruction)		,
		.o_write_back    	(WB)				,
		.o_mem_read      	(MemRd)				,
		.o_ALUOp         	(ALUOp)				,
		.o_ALUSrc        	(ALUSrc)			,
		.o_ASel 			(ASel) 				,
		.rd1           		(rd1)				,
		.rd2           		(rd2)				,
		.o_immediate   		(immediate)
	);



	/*------------------------------------------------------------------------------
	--  						Execute Step
	------------------------------------------------------------------------------*/

	EX_stage #(
		.XLEN(XLEN)
	) execution_stage(
		.clk                (clk)					,
		.resetn             (resetn)				,
		.rd1                (rd1)					,
		.rd2                (rd2)					,
		.immediate          (immediate)				,
		.if_instr_addr 		(if_instr_addr)			,
  		.i_ALUOp            (ALUOp)					,
    	.i_ALUSrc           (ALUSrc)				,
		.i_ASel 			(ASel) 					,
    	.i_func3            (o_instruction[25])		,
    	.i_func7_0          (o_instruction[30])		,
    	.i_func7_5          (o_instruction[14:12])	,
     	.o_alu_result		(alu_out)
	);


endmodule : RV64_core
