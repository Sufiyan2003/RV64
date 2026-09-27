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


	// axi interfaces
	axi4_intf imem_axi_if(clk, resetn);
	axi4_intf dmem_axi_if(clk, resetn);

	// CPU core with registers 32 bit wide for now
	// TODO: add support for XLEN = 64
	RV64_core #(
		.XLEN(32)
	) rv64_cor(
		.clk   			(clk)			,
		.resetn			(resetn) 		,
		.imem_axi_if	(imem_axi_if)	,
		.dmem_axi_if	(dmem_axi_if)
	);


	// TODO: Add Axi interconnect and add multiple axi slaves
	// TODO: need to figure out how requests from different address spaces are going to be catered 
	ram_axi_slave ram_slave
	(
		.clk   (clk),
		.resetn(resetn) , 
		.axi_if(imem_axi_if)
	);





endmodule : RV64_soc