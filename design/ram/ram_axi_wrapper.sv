/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq
-- Date: 08_08_2026
-- Description: AXI4 read slave wrapper around the 64-bit RAM. Turns an INCR
--              burst into sequential RAM reads and returns one beat per handshake.
------------------------------------------------------------------------------*/
`include "cache_params.svh"
module ram_axi_wrapper (
	input 						clk,
	input 						resetn,
	axi4_intf.slave 			axi_if,
	output [15:0] 				o_ram_off,
	output logic				re,
	output [7:0]				byte_en,
	output 						we,
	input 						ram_ready,
	input [63:0]				read_data
);

	typedef enum logic [1:0] {
		RIDLE,
		RD_ISSUE,
		RD_DATA
	} e_read_state;

	e_read_state r_current_state, r_next_state;

	logic [15:0] beat_addr;
	logic [7:0]  beats_left;	// remaining beats after the one in flight
	logic        last_q;

	always_ff @(posedge clk or negedge resetn) begin
		if (!resetn) r_current_state <= RIDLE;
		else         r_current_state <= r_next_state;
	end

	always_comb begin
		r_next_state = r_current_state;
		case (r_current_state)
			RIDLE: begin
				if (axi_if.ARVALID && ram_ready)
					r_next_state = RD_ISSUE;
			end
			RD_ISSUE: begin
				r_next_state = RD_DATA;
			end
			RD_DATA: begin
				if (axi_if.RREADY) begin
					if (last_q) r_next_state = RIDLE;
					else        r_next_state = RD_ISSUE;
				end
			end
			default: r_next_state = RIDLE;
		endcase
	end

	always_ff @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			beat_addr  <= '0;
			beats_left <= '0;
			last_q     <= 1'b0;
		end else begin
			if (r_current_state == RIDLE && axi_if.ARVALID && ram_ready) begin
				beat_addr  <= axi_if.ARADDR[15:0];
				beats_left <= axi_if.ARLEN;	// remaining after first beat
				last_q     <= (axi_if.ARLEN == 8'd0);
			end else if (r_current_state == RD_DATA && axi_if.RREADY && !last_q) begin
				beat_addr  <= beat_addr + 16'd8;
				beats_left <= beats_left - 8'd1;
				last_q     <= (beats_left == 8'd1);
			end
		end
	end

	assign re        = (r_current_state == RD_ISSUE);
	assign o_ram_off = beat_addr;
	assign we        = 1'b0;
	assign byte_en   = 8'h00;

	assign axi_if.AREADY = (r_current_state == RIDLE) && ram_ready;
	assign axi_if.RVALID = (r_current_state == RD_DATA);
	assign axi_if.RDATA  = read_data;
	assign axi_if.RLAST  = last_q;
	assign axi_if.RRESP  = 2'b00;
	assign axi_if.RID    = '0;
	assign axi_if.RUSER  = '0;

	assign axi_if.AWREADY = 1'b0;
	assign axi_if.WREADY  = 1'b0;
	assign axi_if.BVALID  = 1'b0;
	assign axi_if.BRESP   = '0;
	assign axi_if.BID     = '0;
	assign axi_if.BUSER   = '0;

endmodule : ram_axi_wrapper
