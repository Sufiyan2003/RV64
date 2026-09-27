/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 19_09_2026
-- Description: This is the Memory stage, should write or read from the data memory
-- as it contains the data cache
------------------------------------------------------------------------------*/

`include "cache_params.svh"

module MEM_stage #(
    parameter XLEN=64
)(
    input               clk                                 ,
    input               resetn                              ,
    input [XLEN-1:0]    i_addr                              ,
    output              o_stall                             ,
    
    // signals to handover the desired address to the axi master
    output              o_axi_req_valid                     ,
    output [XLEN-1:0]   o_axi_req_addr                      ,

    // signals to tell the cache controller that the desired line is present in the cache
    input                i_axi_rsp_ready                    ,
    input  [DWIDTH-1:0]  i_axi_rsp_line                     ,
    input                i_mem_rd                           ,

    // a valid memory read or write will come from the control unit
    output [XLEN-1:0]   o_data_value                        ,
    output              o_data_valid                        
);

    logic               o_read_valid            ;
    logic               i_cache_hit             ;
    logic               i_cache_miss            ;
    logic               cache_write             ;
    logic               cache_write_done        ;
    logic [DWIDTH-1:0]  cache_line_in           ;



    cache_controller dcache_controller(
    	.clk         		(clk)			            ,
		.resetn      		(resetn)	                ,
		.i_pc        		(i_addr)		            ,
		.o_read_valid		(o_read_valid)              ,
		.o_instr_addr		(o_instr_addr)              ,
		.o_stall_pc  		(o_stall)		            ,
		.i_cache_hit 		(i_cache_hit) 		        ,
		.i_cache_miss   	(i_cache_miss) 		        ,
		.o_axi_req_valid	(o_axi_req_valid) 	        ,
		.o_axi_req_addr 	(o_axi_req_addr) 	        ,
		.i_axi_rsp_ready	(i_axi_rsp_ready) 	        ,
		.i_axi_rsp_line 	(i_axi_rsp_line)            ,  // this line should be given to Icache
		.o_write        	(cache_write)               ,
		.cache_write_done	(cache_write_done)          ,
		.o_cache_line    	(cache_line_in) 	        ,
		.i_req_valid     	(address_valid)

    );


    cache_top #(
        .CWIDTH(64),
        .CADR_WIDTH(64)
    ) dcache(
        .clk			(clk)                           ,
        .resetn			(resetn)                        ,
        .i_address		(o_instr_addr)                  ,
        .i_write 		(cache_write)                   ,
        .i_req_valid 	(i_mem_rd)                      ,
        .i_read 		(o_read_valid)                  ,
        .i_data			(cache_line_in)                 ,
        .o_data	        (o_data_value)                  ,
        .o_data_valid	(o_data_valid)                  ,
        .o_hit 			(i_cache_hit)                   ,
        .o_write_done 	(cache_write_done)              ,
        .o_miss         (i_cache_miss)

    );




endmodule
