/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq
-- Date: 08_08_2026
-- Description: AXI4 read master. Issues a line-sized INCR burst and packs
--              64-bit beats into a 512-bit cache line for the I-cache fill.
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module axi_cache_requester (
	input 						clk 			,
	input 						resetn 			,
	input [ADDR_WIDTH-1:0] 		i_axi_addr 		,
	input 				   		i_axi_fetch  	,
	input 				   		i_axi_evict 	,
	output logic [DWIDTH-1:0]	o_line 			,
	output logic 				o_line_valid 	,
	axi4_intf.master       		axi_if
);

	localparam int AXI_BEAT_W  = 64;
	localparam int NUM_BEATS   = DWIDTH / AXI_BEAT_W; // 8
	localparam int BEAT_IDX_W  = $clog2(NUM_BEATS);

	typedef enum logic [1:0] {
		RIDLE ,
		AR 	  ,
		R
	} read_state_t;

	read_state_t r_current_state, r_next_state;

	logic [ADDR_WIDTH-1:0] 		araddr_q;
	logic [BEAT_IDX_W-1:0] 		beat_cnt;
	logic [DWIDTH-1:0] 			line_acc;
	logic [DWIDTH-1:0] 			line_nxt;
	logic 						beat_fire;
	logic 						last_beat;

	assign beat_fire = (r_current_state == R) && axi_if.RVALID && axi_if.RREADY;
	assign last_beat = beat_fire && axi_if.RLAST;

	always_comb begin
		line_nxt = line_acc;
		if (beat_fire)
			line_nxt[beat_cnt*AXI_BEAT_W +: AXI_BEAT_W] = axi_if.RDATA;
	end

	always_ff @(posedge clk or negedge resetn) begin
		if (~resetn)
			r_current_state <= RIDLE;
		else
			r_current_state <= r_next_state;
	end

	always_comb begin
		r_next_state = r_current_state;
		case (r_current_state)
			RIDLE: begin
				if (i_axi_fetch)	r_next_state = AR;
				else				r_next_state = RIDLE;
			end
			AR: begin
				if (axi_if.AREADY)	r_next_state = R;
				else				r_next_state = AR;
			end
			R: begin
				if (last_beat)		r_next_state = RIDLE;
				else				r_next_state = R;
			end
			default: r_next_state = RIDLE;
		endcase
	end

	always_ff @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			araddr_q     <= '0;
			beat_cnt     <= '0;
			line_acc     <= '0;
			o_line       <= '0;
			o_line_valid <= 1'b0;
		end else begin
			o_line_valid <= 1'b0;

			if (r_current_state == RIDLE && i_axi_fetch) begin
				araddr_q <= {i_axi_addr[ADDR_WIDTH-1:BYTE_OFF_WIDTH], {BYTE_OFF_WIDTH{1'b0}}};
				beat_cnt <= '0;
				line_acc <= '0;
			end

			if (beat_fire) begin
				line_acc <= line_nxt;
				beat_cnt <= beat_cnt + 1'b1;
			end

			if (last_beat) begin
				o_line       <= line_nxt;
				o_line_valid <= 1'b1;
			end
		end
	end

	assign axi_if.ARVALID 	= (r_current_state == AR);
	assign axi_if.ARADDR  	= araddr_q;
	assign axi_if.ARSIZE  	= 3'b011;		// 8 bytes / beat
	assign axi_if.ARBURST 	= 2'b01;		// INCR
	assign axi_if.ARLEN   	= 8'(NUM_BEATS - 1); // 8 beats -> ARLEN=7
	assign axi_if.ARID    	= '0;
	assign axi_if.ARLOCK  	= 1'b0;
	assign axi_if.ARCACHE 	= '0;
	assign axi_if.ARPROT  	= '0;
	assign axi_if.ARREGION	= '0;
	assign axi_if.ARUSER  	= '0;

	assign axi_if.RREADY  	= (r_current_state == R);

	assign axi_if.AWVALID 	= 1'b0;
	assign axi_if.AWADDR  	= '0;
	assign axi_if.AWSIZE  	= '0;
	assign axi_if.AWBURST 	= '0;
	assign axi_if.AWCACHE 	= '0;
	assign axi_if.AWPROT  	= '0;
	assign axi_if.AWID    	= '0;
	assign axi_if.AWLEN   	= '0;
	assign axi_if.AWLOCK  	= 1'b0;
	assign axi_if.AWQOS   	= '0;
	assign axi_if.AWREGION	= '0;
	assign axi_if.AWUSER  	= '0;

	assign axi_if.WVALID  	= 1'b0;
	assign axi_if.WLAST   	= 1'b0;
	assign axi_if.WDATA   	= '0;
	assign axi_if.WSTRB   	= '0;
	assign axi_if.WUSER   	= '0;
	assign axi_if.BREADY  	= 1'b0;

endmodule : axi_cache_requester
