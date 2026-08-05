/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the cache controller module
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module cache_controller (
	input 							clk					,
	input							resetn				,
	input [ADDR_WIDTH-1:0] 			i_pc				,
	input 							i_req_valid 		,
	output logic [ADDR_WIDTH-1:0]	o_instr_addr		,
	output logic 					o_read_valid		,
	input							i_cache_hit			,
	input 							i_cache_miss		,
	output logic					o_axi_req_valid		,
	output [ADDR_WIDTH-1:0] 		o_axi_req_addr		,
	input 							i_axi_rsp_ready		,
	input  [DWIDTH-1:0] 			i_axi_rsp_line 		,
	output logic [DWIDTH-1:0]		o_cache_line 		,
	output logic 					o_stall_pc 			,
	output 							o_write 			,
	input 							cache_write_done
);

	logic [ADDR_WIDTH:0] pc_q 	;
	logic propogate_fetch_req 	;
	logic write_line_to_cache	;

	logic req_accepted 			;
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

	assign req_accepted  = (cache_state == IDLE) && i_req_valid; 
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) o_instr_addr <= '0;
		else if(req_accepted) o_instr_addr <= i_pc;
		else o_instr_addr <= o_instr_addr;
	end
	/*------------------------------------------------------------------------------
	--  		Stalling PC when controller limit is reached (limit is 1)
	------------------------------------------------------------------------------*/
	always_comb begin
	    if(cache_state == SEARCH_CACHE) o_read_valid = 1'b1;
	    else 							 o_read_valid = 1'b0;
	end

	// stalling the PC to give cache enough time to process address
	// combinational now, so it tracks cache_state with zero extra delay -
	// otherwise the PC could sneak in an extra advance the cycle IDLE->SEARCH_CACHE happens
	always_comb begin
	    o_stall_pc = (cache_state != IDLE);
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
	            // gate on the actual incoming request, not on o_read_valid -
	            // o_read_valid was a function of cache_state itself, so it was
	            // always 1 in IDLE and re-triggered SEARCH_CACHE every cycle
	            if(i_req_valid) 	cache_state_nxt = SEARCH_CACHE;
	            else 				cache_state_nxt = IDLE;
	        end
	        SEARCH_CACHE: begin
	            if(i_cache_hit) 		cache_state_nxt = CACHE_HIT;
	            else if(i_cache_miss) 	cache_state_nxt = CACHE_MISS;
	            else 					cache_state_nxt = SEARCH_CACHE;
	        end
	        CACHE_HIT: begin
	            cache_state_nxt = IDLE;
	        end
	        CACHE_MISS: begin
	            // wait till the axi responder has the full line and then move to output cache
	            if(propogate_fetch_req) cache_state_nxt = FETCH 	;
	            else 					 cache_state_nxt = CACHE_MISS;  
	        end
	        FETCH: begin
	            if(i_axi_rsp_ready) 	cache_state_nxt = WRITE_TO_CACHE;
	            else 					cache_state_nxt = FETCH 		;
	        end
	        WRITE_TO_CACHE: begin
	            if(cache_write_done) 	cache_state_nxt = IDLE 			;
	            else 					cache_state_nxt = WRITE_TO_CACHE;
	        end
	        // CACHE_OUTPUT: not wired in yet — will insert between WRITE_TO_CACHE and IDLE later
	        default: cache_state_nxt = IDLE;
	    endcase
	end

	// state issue request to the axi master
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			propogate_fetch_req <= 0;
		end else begin
			if(cache_state == CACHE_MISS) 	propogate_fetch_req <= 1'b1;
			else 							propogate_fetch_req <= 1'b0;
		end
	end

	// to the controller once it has a full line available
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			o_axi_req_valid <= 0;
		end else begin
			if(cache_state == CACHE_MISS && cache_state_nxt == FETCH) 	o_axi_req_valid <= 1'b1;
			else 						o_axi_req_valid <= 1'b0;
		end
	end


	// in case it needs to write to the cache
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			o_cache_line <= '0;
		end else begin
			if(cache_state == FETCH && i_axi_rsp_ready) begin	
				o_cache_line <= i_axi_rsp_line;
			end
		end
	end

	// TODO: must come from a fifo if cache is in miss state
	// assign o_instr_addr = i_pc; 
	assign o_write = write_line_to_cache;
	assign write_line_to_cache = (cache_state == WRITE_TO_CACHE);
endmodule : cache_controller
