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
    input control_signals_t exec_control_sigs   ,
    input [3:0] 			ALUCtrl				,
    output [XLEN-1:0]       o_alu_result
);

	logic [XLEN - 1: 0]     BMuxOut 			;
	logic [XLEN - 1: 0] 	AMuxOut 			;
    
    //A mux
	mux_2_to_1 #(
		.XLEN(XLEN)
	) AMux(
		.x			(rd1)										,
		.y			(if_instr_addr)								,
		.select		(exec_control_sigs.ASel)					,
		.out		(AMuxOut)
	);
	
	//B mux
	mux_2_to_1 #(
		.XLEN(XLEN)
	) BMux(
		.x			(rd2)										,
		.y			(immediate)									,
		.select		(exec_control_sigs.ALUSrc)					,
		.out		(BMuxOut)
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
