/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 22_09_2026
-- Description: This is the Instruction Decode stage
------------------------------------------------------------------------------*/


module ID_stage #(
    parameter XLEN=32
)(
    input clk                       ,
    input resetn                    ,
    input [31:0] i_instruction      ,
    // control signals output to Exec stage
    output 

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

	ALU_Control alu_ctrl(
		.ALUOp			(exec_control_sigs.ALUOp)				,
		.func3			(i_instruction[25])						,
		.func7_0		(i_instruction[30])						,
		.func7_5		(i_instruction[14:12])					,
		.ALUCtrl		(ALUCtrl)
	);

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
		.i_rs1				(o_instruction[19:15])				,
		.i_rs2				(o_instruction[24:20])				,
		.i_rd				(o_instruction[11:7])				, // need to reroute the destination register back somehow
		.i_wr_data			(exec_control_sigs.MemWrite)		,
		.o_rs1				(rd1)								,
		.o_rs2				(rd2)
	
	);


endmodule
