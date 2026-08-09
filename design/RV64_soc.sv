/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This is the top soc
-- 
------------------------------------------------------------------------------*/

module RV64_soc (
	input clk,
	input resetn
);

	// CPU core
	RV64_core rv64_cor(
		.clk   	(clk)		,
		.resetn	(resetn)
	);


	// TODO: Add Axi interconnect and add multiple axi slaves

	// TODO: Add ram axi slave






endmodule : RV64_soc