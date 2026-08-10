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


	axi4_intf axi_if(clk, resetn);


	// CPU core
	RV64_core rv64_cor(
		.clk   	(clk)		,
		.resetn	(resetn) 	,
		.axi_if(axi_if)
	);


	// TODO: Add Axi interconnect and add multiple axi slaves

	// TODO: Add ram axi slave
	ram_axi_slave ram_slave
	(
		.clk   (clk),
		.resetn(resetn) , 
		.axi_if(axi_if)
	);





endmodule : RV64_soc