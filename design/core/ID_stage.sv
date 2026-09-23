/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 22_09_2026
-- Description: This is the Instruction Decode stage
------------------------------------------------------------------------------*/
`include "riscv_typedefs.svh"

module ID_stage #(
    parameter XLEN=32
)(
    input           clk             ,
    input           resetn          ,
    input [31:0]    i_instruction   ,
    // control signals output to Exec stage
    output          o_write_back    ,
    output          o_mem_read      ,
    output [2:0]    o_ALUOp         ,
    output          o_ALUSrc        ,
    output          o_ASel          ,

    // output values for computation
    output [XLEN-1:0] rd1           ,
    output [XLEN-1:0] rd2           ,
    output [XLEN-1:0] o_immediate

);

    logic [3:0]             ALUCtrl             ; 
    control_signals_t exec_control_sigs         ;


	instr_decode instr_dec(
		.i_instr		(i_instruction)	 		,
		.o_ctrl			(exec_control_sigs)
	);


    assign o_ALUOp      = exec_control_sigs.ALUOp       ;
    assign o_ALUSrc     = exec_control_sigs.ALUSrc      ;
    assign o_mem_read   = exec_control_sigs.MemRead     ;
    assign o_write_back = exec_control_sigs.RegWEn      ;
    assign o_ASel       = exec_control_sigs.ASel        ;

	ImmGen imm_generator(
		.instruction	(i_instruction) 						,
		.ImmSel 		(exec_control_sigs.ImmSel)				,
		.Imm			(o_immediate)
	);


    register_file #(
		.DEPTH(32),
		.XLEN (XLEN)	
	) RegFile(
		.clk				(clk)								,
		.resetn				(resetn)							,
		.wr_en				(exec_control_sigs.RegWEn)			,
		.rd_en				(1'b1)								,
		.i_rs1				(i_instruction[19:15])				,
		.i_rs2				(i_instruction[24:20])				,
		.i_rd				(i_instruction[11:7])				, // need to reroute the destination register back somehow
		.i_wr_data			(exec_control_sigs.MemWrite)		,
		.o_rs1				(rd1)								,
		.o_rs2				(rd2)
	
	);


endmodule
