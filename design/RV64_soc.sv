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


	// CPU core with registers 32 bit wide for now
	// TODO: add support for XLEN = 64
	RV64_core #(
		.XLEN(32)
	) rv64_cor(
		.clk   	(clk)		,
		.resetn	(resetn) 	,
		.axi_if(axi_if)
	);


	// TODO: Add Axi interconnect and add multiple axi slaves

	ram_axi_slave ram_slave
	(
		.clk   (clk),
		.resetn(resetn) , 
		.axi_if(axi_if)
	);





endmodule : RV64_soc