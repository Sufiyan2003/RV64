/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 07_08_2026
-- Description: This is the register file we will be using, the register 0
-- is hardwired to 0
------------------------------------------------------------------------------*/

module register_file #(
	parameter DEPTH=32,
	parameter XLEN =64
)(
	input clk,    // Clock
	input resetn,
	input wr_en,
	input rd_en,
	input [$clog2(DEPTH)-1:0] i_rs1,
	input [$clog2(DEPTH)-1:0] i_rs2,
	input [$clog2(DEPTH)-1:0] i_rd,
	input [XLEN-1:0] i_wr_data,
	output [XLEN-1:0] o_rs1,
	output [XLEN-1:0] o_rs2	
);

	logic [XLEN-1:0] reg_array[DEPTH];

	// managing read 
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			for (int i = 0; i < DEPTH; i++) begin
				reg_array[i] <= '0;
			end
		end else begin
			if(wr_en) begin
				if(i_rd == 0) 	reg_array[0] 	<= '0;
				else 			reg_array[i_rd] <= i_wr_data;
			end
			else begin
				reg_array[i_rd] <= reg_array[i_rd];
			end
		end
	end

	assign o_rs1 = reg_array[i_rs1];
	assign o_rs2 = reg_array[i_rs2];
endmodule : register_file
