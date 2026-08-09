/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This will take the slave input from the interconnect and then
-- will get response from the ram
------------------------------------------------------------------------------*/
`include "cache_params.svh"
module ram_axi_wrapper (
	input 						clk,    // Clock
	input 						resetn,
	axi4_intf.slave 			axi_if,
	output [15:0] 				o_ram_off,
	output logic				re,
	output [DWIDTH/8 - 1: 0]	byte_en,
	output 						we 		,
	input 						ram_ready,
	input [63:0]				read_data
);


	// define states to receive read requests
	typedef enum logic [2:0] {
		RIDLE,
		AR,
		R
	} e_read_state;


	e_read_state r_current_state, r_next_state;
	logic incoming_rd_req;
	logic fulfilling_rd_req;

	logic [9:0] tr_len;
	logic [7:0] num_bytes;
	logic [15:0] addr;
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

			end

		endcase
	end


	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			incoming_rd_req <= 0;
			addr <= '0;
		end else begin
			if(axi_if.AREADY && axi_if.ARVALID) begin 
				incoming_rd_req <= 1'b1;
				fulfilling_rd_req <= 1'b1;
				addr <= axi_if.ARADDR[15:0];
			end
			else if(axi_if.RLAST) begin
				fulfilling_rd_req <= '0;
			end
			else begin 
				incoming_rd_req <= 1'b0;
				fulfilling_rd_req <= fulfilling_rd_req;
				addr <= addr;
			end
		end
	end

	// store the number of transactions we need to send
	always_comb begin
		tr_len = '0;
		case (axi_if.ARLEN)
			8'd0: tr_len = 1;
			8'd1: tr_len = 2;
			8'd2: tr_len = 4;
			8'd3: tr_len = 8;
			8'd4: tr_len = 16;
			default tr_len = 16;
		endcase
	end


	// COUNTER TO READ FROM RAM
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			num_bytes <= 0;
			re <= '0;
		end else begin
			if(r_current_state == R && (num_bytes < tr_len)) begin
				num_bytes <= num_bytes + 1;
				re <= 1'b1;
			end
			else begin
				num_bytes <= num_bytes;
				re <= '0;
			end
		end
	end



	assign axi_if.AREADY = ram_ready;
	assign o_ram_off = addr + num_bytes;
	assign axi_if.WLAST = (num_bytes == tr_len);


endmodule : ram_axi_wrapper