/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the cache controller module
-- The cache can only cater for one request at a time
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module cache_controller (
	input 							clk					,
	input							resetn				,

	// program counter details
	input [ADDR_WIDTH-1:0] 			i_pc				,
	output 							cache_ready 		,
	input 							i_req_valid 		,
	output logic 					o_stall_pc 			,

	// signals tied to the cache
	output  [ADDR_WIDTH-1:0]		o_instr_addr		,
	output  						o_read_valid		,
	input							i_cache_hit			,
	input 							i_cache_miss		,
	output logic					o_write 			,
	input 							cache_write_done	,
	output logic [DWIDTH-1:0]		o_cache_line 		,

	// signals tied to the axi requestor
	output 							o_axi_req_valid		,
	output [ADDR_WIDTH-1:0] 		o_axi_req_addr		,
	input 							i_axi_rsp_ready		,
	input  [DWIDTH-1:0] 			i_axi_rsp_line 		
	
);



	//declaration of flags to indicate that the request is busy
	logic busy, busy_q;
	logic miss;
	logic fetch_complete;
	logic addr_dq;

	// registers to save context
	logic [ADDR_WIDTH-1:0] addr_q;
	logic [ADDR_WIDTH-1:0] request_address;

	logic fifo_empty;
	logic fifo_full;

	// add a synchronous fifo to store the addresses
	sync_fifo  addr_fifo(
		.clk			(clk),
		.resetn			(resetn),
		.wr_en			(i_req_valid),
		.rd_en			(addr_dq),
		.flush_fifo		(),
		.empty			(fifo_empty),
		.full			(fifo_full),
		.data_in		(i_pc),
		.q				(addr_q)
	);


	// once the request has been serviced we can dequeue it from the fifo
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			addr_dq <= '0;
		end
		else begin
			if(i_cache_miss) addr_dq <= '0;
			else if(i_cache_hit) addr_dq <= 1'b1;
			else addr_dq <= '0;
		end
	end


	// flag management
	always_ff @( posedge clk or negedge resetn ) begin : flag_manager_block
		if(~resetn) begin
			busy <= '0;
		end
		else begin
			// in case of a miss the flag should read busy
			if(i_cache_miss) 		busy <= 1'b1;
			else if(i_cache_hit || o_write) 	busy <= 1'b0;
			else 					busy <= busy;
		end
	end

	// check if its fetch_complete or not
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) fetch_complete <= '0;
		else begin
			if(i_axi_rsp_ready) fetch_complete <=  1'b1;
			else 				fetch_complete <= 1'b0;
		end
	end

	assign o_instr_addr = addr_q;

	// assert write to memory if fetching is set
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin 
			o_write <= 1'b0;
			o_cache_line <= '0;
		end
		else begin
			if(fetch_complete) begin 
				o_write <= 1'b1;
				o_cache_line <= i_axi_rsp_line;
			end
			else begin 
				o_write <= 1'b0; 
			end
		end
	end

	// flop the busy flag to control o_axi_req_valid
	always_ff @(posedge clk or negedge resetn) begin
		if(!resetn) busy_q <= '0;
		else busy_q <= busy;
	end

	// pulse valid signal
	assign o_axi_req_valid = busy && ~busy_q;

	// handover the register to the axi requester
	always_ff @(posedge clk or negedge resetn) begin
		if(!resetn) request_address <= '0;
		else  begin
			if(busy) request_address <= addr_q;
			else request_address <= request_address;
		end
	end


	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) miss <= '0;
		else begin
			if(i_cache_miss) miss <= 1'b1;
			else if(o_write) miss <= 1'b0;
			else miss <= miss;
		end
	end

	assign o_axi_req_addr = request_address;
	assign o_stall_pc = busy;

	// tie the cache_ready combinationally
	assign cache_ready =  (~miss || ~i_cache_miss) && ~miss && ~fifo_full;

	// reassert read when response is ready from the AXI interface
	// deassert read when there is a miss
	assign o_read_valid = !busy_q;

endmodule : cache_controller
