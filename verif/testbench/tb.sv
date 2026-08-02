/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the top testbench
-- 
------------------------------------------------------------------------------*/


module tb;

	logic clk;
	logic resetn;


	RV64_core rv64_cor(
		.clk   	(clk),
		.resetn	(resetn)
	);

	initial begin
		clk = 0;
		resetn = 1'b1;
		#3ns;
		resetn = 1'b0;
		#3ns;
		resetn = 1'b1;
		#1000ns;
		$finish;
	end

	always #5ns clk = ~clk;



endmodule : tb
