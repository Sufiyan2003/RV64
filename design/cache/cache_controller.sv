/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the cache controller module
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module cache_controller (
	input 					clk					,
	input					resetn				,
	input [ADDR_WIDTH-1:0] 	i_pc				,
	output logic 			o_instr_addr		,
	output logic 			o_read_valid		,
	input					i_cache_hit			,
	input 					i_cache_miss		,
	output 					o_axi_req_valid		,
	output [ADDR_WIDTH-1:0] o_axi_req_addr		,
	input 					i_axi_rsp_ready		,
	input  [DWIDTH-1:0] 	i_axi_rsp_line 		,
	output logic 			o_stall_pc
);

	logic [ADDR_WIDTH:0] pc_q 	;
	logic propogate_fetch_req 	;
	logic cache_write_done 		;

	typedef enum logic [3:0] {
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
	--  		Stalling PC when controller limit is reached (limit is 1)
	------------------------------------------------------------------------------*/

	always_comb begin
		if(cache_state == SEARCH_CACHE) o_read_valid = 1'b0;
		else 							o_read_valid = 1'b1;
	end

	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			o_stall_pc <= 0;
		end else begin
			if(cache_state == CACHE_OUTPUT) o_stall_pc <= 1'b0;
			else if(cache_state != IDLE)    o_stall_pc <= 1'b1;
		end
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
				cache_state_nxt = SEARCH_CACHE; // CURRENTLY NEED TO SEE IF IT CAN SEARCH THE CACHE
				if(i_cache_hit) cache_state_nxt = CACHE_HIT;
				else if(i_cache_miss) cache_state_nxt = CACHE_MISS;
				else cache_state_nxt = SEARCH_CACHE;
			end
			// CACHE_HIT:
			CACHE_MISS: begin
				// wait till the axi responder has the full line and then move to output cache
				if(propogate_fetch_req) cache_state_nxt = FETCH 	;
				else 					cache_state_nxt = CACHE_MISS;  
			end
			FETCH: begin
				if(i_axi_rsp_ready) 	cache_state_nxt = WRITE_TO_CACHE;
				else 					cache_state_nxt = FETCH 		;
			end
			WRITE_TO_CACHE: begin
				if(cache_write_done) 	cache_state_nxt = IDLE 			;
				else 					cache_state_nxt = WRITE_TO_CACHE;
			end
			// CACHE_OUTPUT:
			default: cache_state_nxt = IDLE;
		endcase
	end

	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			propogate_fetch_req <= 0;
		end else begin
			if(cache_state == CACHE_MISS) 	propogate_fetch_req <= 1'b1;
			else 							propogate_fetch_req <= 1'b0;
		end
	end



	// TODO: must come from a fifo if cache is in miss state
	assign o_instr_addr = i_pc; 

endmodule : cache_controller
