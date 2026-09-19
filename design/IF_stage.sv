/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 19_09_2026
-- Description: This is the instruction fetch block, should fetch data from the
-- ram or L2 cache (for now it fetches from the ram)
------------------------------------------------------------------------------*/

`include "cache_params.svh"

module IF_stage
(
    input                   clk                 ,
    input                   resetn              ,
    input [ADDR_WIDTH-1:0]  i_PC                ,
    output                  o_stall_pc          ,
    output                  o_axi_req_valid     ,
    output [ADDR_WIDTH-1:0] o_axi_req_addr      ,
    input                   i_axi_rsp_ready     ,
    input [DWIDTH-1:0]      i_axi_rsp_line      ,
    input                   address_valid       ,
    output [31:0]           o_instruction
);

    logic                   o_read_valid;
    logic [ADDR_WIDTH-1:0]  o_instr_addr;
    logic                   i_cache_hit;
    logic                   i_cache_miss;
    logic                   cache_write;
    logic                   cache_write_done;
    logic [DWIDTH-1:0]      cache_line_in;

	cache_controller Icache_controller 	(
		.clk         		(clk)				,
		.resetn      		(resetn)			,
		.i_pc        		(i_PC)		        ,
		.o_read_valid		(o_read_valid)		,
		.o_instr_addr		(o_instr_addr)		,
		.o_stall_pc  		(o_stall_pc)		,
		.i_cache_hit 		(i_cache_hit) 		,
		.i_cache_miss   	(i_cache_miss) 		,
		.o_axi_req_valid	(o_axi_req_valid) 	,
		.o_axi_req_addr 	(o_axi_req_addr) 	,
		.i_axi_rsp_ready	(i_axi_rsp_ready) 	,
		.i_axi_rsp_line 	(i_axi_rsp_line)    ,  // this line should be given to Icache
		.o_write        	(cache_write)       ,
		.cache_write_done	(cache_write_done)  ,
		.o_cache_line    	(cache_line_in) 	,
		.i_req_valid     	(address_valid)
	);

	cache_top Icache (
		.clk        		(clk)				,
		.resetn     		(resetn)			,
		.i_data     		(cache_line_in)		, // right here
		.i_address  		(o_instr_addr)		,
		.i_write    		(cache_write)		, // this write should come from the controller when fetch cycle has finished
		.i_req_valid		(1'b1) 				, // is the instruction address valid
		.i_read     		(o_read_valid)		, // read will come whenever its a valid req address
		.o_data     		(o_instruction) 	, // the data to be transmitted out
		.o_hit      		(i_cache_hit) 		, // to relay hit to controller
		.o_write_done		(cache_write_done),
		.o_miss     		(i_cache_miss) 		  // to relay miss to controller
	);


endmodule


