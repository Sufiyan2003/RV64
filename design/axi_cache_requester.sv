/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This is to send the axi request to get a line from RAM
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module axi_cache_requester (
	input clk 							,    // Clock
	input resetn 						,
	input [ADDR_WIDTH-1:0] i_axi_addr 	,
	input 				   i_axi_fetch  ,
	input 				   i_axi_evict 	,
	axi4_intf.master       axi_if
	
);


	/*------------------------------------------------------------------------------
	--  							state machine
	------------------------------------------------------------------------------*/
	typedef enum logic [2:0] {
		IDLE	,	// waiting for eviction request
		AW 		,	// driving AW channel, waiting for master_if.awready
		W 		,	// driving W channel, waitin for master_if.wready
		B 			// one cycle pulse back to the cache
	} state_t;		
	
	typedef enum logic [2:0] {
		RIDLE ,
		AR 	  ,
		R 	  
	} read_state_t;

	state_t w_current_state, w_next_state;
	read_state_t r_current_state, r_next_state;


	/*------------------------------------------------------------------------------
	--  					Managing state transition
	------------------------------------------------------------------------------*/
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) w_current_state <= IDLE;
		else		w_current_state <= w_next_state;
	end

	// always_comb begin
	// 	w_next_state = w_current_state;
	// 	case (w_current_state)
	// 		IDLE: begin
	// 			if(i_axi_evict) w_next_state =AW;
	// 			else 			w_next_state = IDLE;
	// 		end
	// 		AW: begin
	// 		end
	// 		W:
	// 		B:	
	// 	endcase	
	// end




	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) r_current_state <= RIDLE;
		else 		r_current_state <= r_next_state;
	end


	always_comb begin
		r_next_state = r_current_state;
		case (r_current_state)
			RIDLE: begin
				if(i_axi_fetch) r_next_state = AR;
				else 			r_next_state = RIDLE;
			end 
			AR: begin
				if(axi_if.AREADY) 	r_next_state = R;
				else 			 	r_next_state = AR;
			end
			R: begin
				if(axi_if.WLAST) 					r_next_state = RIDLE;
				else 								r_next_state = R;
			end
		endcase	
	end




	assign axi_if.ARVALID 	= (r_current_state == AR);
	assign axi_if.ARADDR 	= (r_current_state == AR && i_axi_fetch) ? i_axi_addr : '0;
	assign axi_if.ARSIZE 	= 3'b010; // 8 bytes per transfer please
	assign axi_if.ARBURST	= '0;  // fixed line bursts
	assign axi_if.ARLEN 	= 8'b0100;
	assign axi_if.RVALID 	= (r_current_state == R);
        // output ARSIZE,
        // output ARBURST,
        // output ARCACHE,
        // output ARPROT,
        // output ARID,
        // output ARLEN,
        // output ARLOCK,
        // output ARREGION,
        // output ARUSER,



endmodule : axi_cache_requester