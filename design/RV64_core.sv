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
	logic 					i_cache_hit 		;
	logic 					i_cache_miss 		;
	logic 					o_axi_req_valid 	;
	logic [ADDR_WIDTH-1:0] 	o_axi_req_addr 		; 
	logic 					i_axi_rsp_ready 	;
	logic [DWIDTH-1:0] 		i_axi_rsp_line 		;
	logic [ADDR_WIDTH-1:0]	o_instr_addr 		;
	logic 					cache_write			;
	logic 					cache_write_done 	;
	logic [DWIDTH-1:0] 		cache_line_in 		;
	logic [31:0] 			o_instruction 		;
	control_signals_t 		exec_control_sigs 	;
	logic [XLEN-1:0]        immediate 			;
	logic [3:0] 			ALUCtrl				;
	logic [XLEN - 1: 0]     BMuxOut 			;
	logic [XLEN - 1: 0] 	AMuxOut 			;
	logic [XLEN - 1: 0]     alu_out 			; 
	logic [XLEN - 1: 0] 	rd1, rd2 			;
	logic [ADDR_WIDTH-1:0]	if_instr_addr 		;
	logic 					if_instr_valid 		;

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

	instr_decode instr_dec
	(
		.i_instr		(o_instruction)	 		,
		.o_ctrl			(exec_control_sigs)
	);


	ALU_Control alu_ctrl(
		.ALUOp			(exec_control_sigs.ALUOp)				,
		.func3			(o_instruction[25])						,
		.func7_0		(o_instruction[30])						,
		.func7_5		(o_instruction[14:12])					,
		.ALUCtrl		(ALUCtrl)

	);

	ImmGen imm_generator(
		.instruction	(o_instruction) 						,
		.ImmSel 		(exec_control_sigs.ImmSel)				,
		.Imm			(immediate)
	);



	register_file #(
		.DEPTH(32),
		.XLEN (XLEN)	
	) RegFile(
		.clk				(clk)								,
		.resetn				(resetn)							,
		.wr_en				(exec_control_sigs.RegWEn)			,
		.rd_en				(1'b1)								,
		.i_rs1				(o_instruction[19:15])				,
		.i_rs2				(o_instruction[24:20])				,
		.i_rd				(o_instruction[11:7])				, // need to reroute the destination register back somehow
		.i_wr_data			(exec_control_sigs.MemWrite)		,
		.o_rs1				(rd1)								,
		.o_rs2				(rd2)
	
	);

	/*------------------------------------------------------------------------------
	--  						Execute Step
	------------------------------------------------------------------------------*/

	EX_stage #(
		.XLEN(XLEN)
	) execution_stage(
	 .clk                 	(clk),
     .resetn              	(resetn),
     .rd1                 	(rd1),
     .rd2                 	(rd2),
     .immediate           	(immediate),
     .if_instr_addr 		(if_instr_addr),
     .exec_control_sigs   	(exec_control_sigs),
     .ALUCtrl				(ALUCtrl),
     .o_alu_result			(alu_out)
	);


endmodule : RV64_core
