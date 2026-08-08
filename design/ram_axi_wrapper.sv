/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This will take the slave input from the interconnect and then
-- will get response from the ram
------------------------------------------------------------------------------*/
`include "cache_params.svh"
module ram_axi_wrapper (
	input clk,    // Clock
	input resetn,
	axi4_intf.slave axi_if
);


	// define states to receive read requests
	typedef enum logic [2:0] {
		RIDLE,
		AR,
		R
	} e_read_state;


	e_read_state r_current_state, r_next_state;
	logic incoming_rd_req;

	/*------------------------------------------------------------------------------
	--  						State transition
	------------------------------------------------------------------------------*/
	always_ff @(posedge clk or negedge resetn) begin
		if(!resetn) r_current_state <= RIDLE;
		else 		r_current_state <= r_next_state;
	end

	always_comb begin
		r_next_state = r_current_state;
		case (r_current_state)
			RIDLE: begin
				if(axi_if.ARVALID) r_next_state = AR;
				else  			   r_next_state = RIDLE;
			end
			AR: begin
				if(!incoming_rd_req) 	r_next_state = R;
				else 					r_next_state = AR;
			end
			R: begin
				// take the address and take the ARSIZE and ARLEN and grab the bytes from RAM
			end

		endcase
	end


	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			incoming_rd_req <= 0;
		end else begin
			if(axi_if.AREADY && axi_if.ARVALID) incoming_rd_req <= 1'b1;
			else 								incoming_rd_req <= 1'b0;
		end
	end

	assign axi_if.AREADY = incoming_rd_req ? 1'b1 : 1'b0;




endmodule : ram_axi_wrapper