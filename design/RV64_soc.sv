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


	// TODO: need to add an axi interconnect


	// TODO: need to wrap ram memory to act as an axi slave
	// need to instantiate the axi bridge on which the core is connected
	ram ram_memory(
		.clk    (clk)		,
		.rst_n  (resetn)	,
		.addr   ()			,
		.wdata  ()			,
		.rdata  ()			,
		.we     ()			,
		.byte_en()			,
		.re     ()
	);


endmodule : RV64_soc