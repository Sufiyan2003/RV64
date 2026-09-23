/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 22_09_2026
-- Description: This is the Execution stage
-- TODO: Must add other multi cycle execution instructions
------------------------------------------------------------------------------*/

`include "riscv_typedefs.svh"
`include "cache_params.svh"
module EX_stage #(
    parameter XLEN=32
)(
    input                   clk                 ,
    input                   resetn              ,
    input [XLEN-1:0]        rd1                 ,
    input [XLEN-1:0]        rd2                 ,
    input [XLEN-1:0]        immediate           ,
    input [ADDR_WIDTH-1:0]	if_instr_addr 		,
    input [2:0]             i_ALUOp             ,
    input                   i_ALUSrc            ,
    input                   i_ASel              ,
    input                   i_func3             ,
    input                   i_func7_0           ,
    input  [2:0]            i_func7_5           ,
    output [XLEN-1:0]       o_alu_result
);

	logic [XLEN - 1: 0]     BMuxOut 			;
	logic [XLEN - 1: 0] 	AMuxOut 			;
    logic [3:0]             ALUCtrl             ;

    //A mux
	mux_2_to_1 #(
		.XLEN(XLEN)
	) AMux(
		.x			(rd1)										,
		.y			(if_instr_addr)								,
		.select		(i_ASel)					,
		.out		(AMuxOut)
	);
	
	//B mux
	mux_2_to_1 #(
		.XLEN(XLEN)
	) BMux(
		.x			(rd2)										,
		.y			(immediate)									,
		.select		(i_ALUSrc)					                ,
		.out		(BMuxOut)
	);

    ALU_Control alu_ctrl(
		.ALUOp			(i_ALUOp)				,
		.func3			(i_func3)						        ,
		.func7_0		(i_func7_0)						        ,
		.func7_5		(i_func7_5)					            ,
		.ALUCtrl		(ALUCtrl)
	);


	ALU #(
		.XLEN(XLEN)
	) alu_p (
		.in1(AMuxOut),
		.in2(BMuxOut),
		.ALUCtrl(ALUCtrl),
		.Result (o_alu_result)
	);




endmodule
