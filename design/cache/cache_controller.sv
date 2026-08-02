/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the cache controller module
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module cache_controller (
	input clk,
	input resetn,
	input [ADDR_WIDTH:0] i_pc,
	output logic o_read_valid
);

	logic [ADDR_WIDTH:0] pc_q;

	typedef enum  {
		IDLE 			, 
		SEARCH_CACHE 	, 
		CACHE_HIT 		, 
		CACHE_MISS 		, 
		FETCH 			,
		WRITE_TO_CACHE 	,
		CACHE_OUTPUT
	} controller_state_e;
	
	controller_state_e cache_state, cache_state_nxt;

	/*------------------------------------------------------------------------------
	--  					Checking if PC is advancing
	------------------------------------------------------------------------------*/
	always_ff @(posedge clk or negedge resetn) begin : proc_
		if(~resetn) begin
			pc_q <= 0;
		end else begin
			pc_q <= i_pc;
		end
	end

	always_comb begin
		if(i_pc == pc_q) 	o_read_valid = 1'b0;
		else 				o_read_valid = 1'b1;
	end

	/*------------------------------------------------------------------------------
	--  					Managing controller states
	------------------------------------------------------------------------------*/
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) cache_state <= IDLE;
		else 		cache_state <= cache_state_nxt;
	end

	always_comb begin
		cache_state_nxt = IDLE;
		case (cache_state)
			IDLE: begin
				if(o_read_valid == 1) 	cache_state_nxt = SEARCH_CACHE;
				else 					cache_state_nxt = IDLE;
			end
			SEARCH_CACHE: begin
			end
			CACHE_HIT:
			CACHE_MISS:
			FETCH:
			WRITE_TO_CACHE:
			CACHE_OUTPUT:
		endcase
	end



endmodule : cache_controller