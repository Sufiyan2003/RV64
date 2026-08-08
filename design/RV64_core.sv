/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the riscv 64 core
-- TODO: must have an axi interface to communicate with the L2 cache
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module RV64_core (
	input clk,
	input resetn
);


	logic [63:0] 			instr_addr 			;
	logic 					o_read_valid 		;
	logic 					address_valid 		;
	logic 					o_stall_pc 			;
	logic 					i_cache_hit 		;
	logic 					i_cache_miss 		;
	logic 					o_axi_req_valid 	;
	logic [ADDR_WIDTH-1:0] 	o_axi_req_addr 		; 
	logic 					i_axi_rsp_ready 	;
	logic [DWIDTH-1:0] 		i_axi_rsp_line 		;
	logic [ADDR_WIDTH-1:0]	o_instr_addr 		;
	logic 					cache_write			;
	logic 					cache_write_done 	;
	logic [DWIDTH-1:0] 		cache_line_in 		;


	// interfaces
	axi4_intf axi_if(clk, resetn);



	/*------------------------------------------------------------------------------
	--  						Instruction Fetch
	------------------------------------------------------------------------------*/
	ProgramCounter #(
		.WIDTH(64),
		.DEFAULT_VAL(64'h8000_0000)
	) PC(
		.clk         (clk)			,
		.resetn      (resetn)		,
		.i_stall     (o_stall_pc)	,
		.o_instr_addr(instr_addr) 	,
		.o_req_valid (address_valid)
	);



	/*------------------------------------------------------------------------------
	--  					Cache to store instructions
	------------------------------------------------------------------------------*/
	// TODO: make all cache controllers and memory wrappers into one top level cache
	cache_controller Icache_controller 	(
		.clk         		(clk)				,
		.resetn      		(resetn)			,
		.i_pc        		(instr_addr)		,
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
		.o_data     		() 					, // the data to be transmitted out
		.o_hit      		(i_cache_hit) 		, // to relay hit to controller
		.o_write_done		(cache_write_done),
		.o_miss     		(i_cache_miss) 		  // to relay miss to controller
	);

	/*------------------------------------------------------------------------------
	--  	TODO: An AXI-4 wrapper to take beats and form a complete line
	------------------------------------------------------------------------------*/
	axi_cache_requester axi_icache_master(
		.clk        (clk),
		.resetn     (resetn),
		.i_axi_addr (o_instr_addr),
		.i_axi_fetch(o_axi_req_valid),
		.i_axi_evict(),
		.axi_if     (axi_if)
	);

endmodule : RV64_core