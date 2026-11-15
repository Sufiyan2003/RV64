/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq
-- Date: 02_08_2026
-- Description: This is the top testbench
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module tb;

	logic clk;
	logic resetn;

	RV64_soc rv_soc(
		.clk   (clk),
		.resetn(resetn)
	);

	initial begin
		clk    = 0;
		resetn = 1'b1;
		#0.5ns;
		resetn = 1'b0;
		#0.5ns;
		resetn = 1'b1;
		#2000ns;
		$finish;
	end

	always #5ns clk = ~clk;

endmodule : tb
