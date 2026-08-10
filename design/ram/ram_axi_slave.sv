/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 09_08_2026
-- Description: This is the ram axi slave which will be connected directly to
-- our axi interconnect
------------------------------------------------------------------------------*/

module ram_axi_slave (
	input clk,    // Clock
	input resetn,
	axi4_intf.slave axi_if
);


	logic [7:0] byte_en;
	logic we;
	logic re;
	logic [15:0] o_ram_off;
	logic ready;
	logic [63:0] data_read;


	ram_axi_wrapper ram_axi_wrap(
		.clk      (clk),
		.resetn   (resetn),
		.byte_en  (byte_en),
		.we       (we),
		.re       (re),
		.axi_if   (axi_if),
		.o_ram_off(o_ram_off),
		.ram_ready(ready),
		.read_data(data_read)
	);

	ram ram_memory(
		.clk    (clk)		,
		.rst_n  (resetn)	,
		.addr   (o_ram_off)	,
		.wdata  ()			, // dont need to write to the ram just yet
		.rdata  (data_read)	,
		.we     ('0)		,
		.byte_en(byte_en)	,
		.re     (re)		,
		.ready  (ready)
	);



endmodule : ram_axi_slave