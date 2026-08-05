/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the program counter
------------------------------------------------------------------------------*/

module ProgramCounter #(
	parameter WIDTH=64,
	parameter [WIDTH-1 : 0] DEFAULT_VAL = {WIDTH{1'b0}}
)(
	input 				clk 			,    // Clock
	input 				resetn			,
	input 				i_stall			,
	output 				o_req_valid 	,
	output [WIDTH-1:0 ]	o_instr_addr
);


	logic [WIDTH-1:0] counter;

	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			counter <= DEFAULT_VAL;
		end else begin
			if(!i_stall) counter <= counter + 4		;
			else 		counter <= counter 			;
		end
	end

	assign o_instr_addr = counter;
	assign o_req_valid = ~i_stall;

endmodule : ProgramCounter
