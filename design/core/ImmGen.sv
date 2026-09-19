/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 26_07_2026
-- Description: This is the immediate number generator, for feeding immediate
-- values inside the exec unit
------------------------------------------------------------------------------*/

module ImmGen #(
	parameter XLEN=64
)(
	input [31:0] 			instruction 		, 
	input [2:0] 			ImmSel 				, 
	output reg [XLEN-1:0] 	Imm
);
	parameter   ITYPE= 3'b000,STYPE=3'b001,BTYPE= 3'b010,UTYPE=3'b011,JTYPE=3'b100;
	always @(*) begin
		case(ImmSel)
			ITYPE: Imm = { {20{instruction[31]}}, instruction[31:20] };
			STYPE: Imm = {{20{instruction[24]}},instruction[24:18],instruction[4:0]};
			UTYPE: Imm = {instruction[31:12], 12'b0};
			BTYPE: Imm = {{20{instruction[31]}},instruction[7],instruction[30:25], instruction[11:8], 1'b0};
			JTYPE: Imm = {{11{instruction[31]}},instruction[19:12],instruction[20],instruction[30:21],1'b0};
			default: Imm = 32'b0;
		endcase
	end

endmodule
