/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 26_07_2026
-- Description: This is the top cache rtl just to test something
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module cache_top (
	input 					clk			,    // Clock
	input 					resetn		,
	input [ADDR_WIDTH-1:0] 	i_address	,
	input 					i_write 	,
	input 					i_req_valid ,
	input 					i_read 		,
	input [DWIDTH-1:0]  	i_data		,
	output [DWIDTH-1:0] 	o_data 		,
	output 	logic			o_hit 		,
	output 	logic			o_miss
	
);

	logic [NUM_WAYS-1:0] write_to_cache;

	logic [BYTE_OFF_WIDTH-1:0] 		byte_offset		; 
	logic [LINE_NUMBER_WIDTH-1:0] 	line_number 	;
	logic [TAG_WIDTH-1:0] 			tag_value 		;

	// dissect the input address
	assign byte_offset = i_address[BYTE_OFF_WIDTH-1:0];
	assign line_number = i_address[BYTE_OFF_WIDTH + LINE_NUMBER_WIDTH-1:BYTE_OFF_WIDTH];
	assign tag_value   = i_address[ADDR_WIDTH-1 : BYTE_OFF_WIDTH + LINE_NUMBER_WIDTH];
	

	logic [DWIDTH-1:0] 		line_data [NUM_WAYS];
	logic [TAG_WIDTH-1:0] 	tag_val   [NUM_WAYS];
	logic 					invalid_line[NUM_WAYS];


	logic read_tag_mem;
	logic read_data_mem;
	logic read_valid_mem;

	logic write_tag_mem  	[NUM_WAYS];
	logic write_data_mem 	[NUM_WAYS];
	logic write_invalid_mem [NUM_WAYS];
	logic write_valids      [NUM_WAYS];

	// detect which way has the desired line
	logic [$clog2(NUM_WAYS)-1:0] target_way;
	logic [$clog2(NUM_WAYS)-1:0] free_way;
	logic free_way_found;
	logic [$clog2(NUM_WAYS)-1:0] write_way;

	// generate the number of memory wrappers as there are number of ways
	genvar i;
	generate
		// data storage
		for (i = 0; i < NUM_WAYS; i++) begin
			memwrap #(
				.DWIDTH    (DWIDTH),
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH)
			) memory(
				.clk     (clk) 					,
				.resetn  (resetn) 				,
				.write_en(write_data_mem[i]) 	,			// write to memory if its a hit
				.read_en (read_data_mem) 		,			// ready from memory to throw it as an output 
				.i_addr  (line_number) 			,			// give it the line number
				.i_data  (i_data) 				,
				.o_data  (line_data[i])
			);
		end

		// for storing tags
		for (i = 0; i < NUM_WAYS; i++) begin
			memwrap #(
				.DWIDTH    (TAG_WIDTH),
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH)
			) tag_memory(
				.clk     (clk) 				,
				.resetn  (resetn) 			,
				.i_data  (tag_value) 		,
				.i_addr  (line_number) 		,
				.o_data  (tag_val[i]) 		,
				.read_en (read_tag_mem) 	,   			// read it to detect hit or miss
				.write_en(write_tag_mem[i])
			);
		end

		// for storing valids
		for (i = 0; i < NUM_WAYS; i++) begin
			memwrap #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH),
				.DWIDTH    (1),
				.DEFAULT_VAL (1)
			) invalid_mem(
				.clk     (clk) 						,
				.resetn  (resetn) 					,
				.i_data  (write_valids[i]) 			,
				.i_addr  (line_number) 				,
				.o_data  (invalid_line[i]) 			,
				.read_en (read_valid_mem)   		,
				.write_en(write_invalid_mem[i])
			);
		end

		// for storing dirty bits
		for (i = 0; i < NUM_WAYS; i++) begin
			memwrap #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH),
				.DWIDTH    (1)
			) dirty_mem(
				.clk     (clk) 						,
				.resetn  (resetn) 					,
				.i_data  ()   						,
				.i_addr  (line_number) 				,
				.o_data  () 						,
				.read_en () 						,
				.write_en()
			);
		end

	endgenerate


	always_comb begin
		o_hit = 1'b0;
		target_way = '0;
		for (int i = 0; i < NUM_WAYS; i++) begin
			// its a hit if its valid and the tags match
			if(~invalid_line[i] && (tag_val[i] == tag_value)) begin
				o_hit = 1'b1;
				target_way = i;
			end 
		end

		if(o_hit == 1'b0) o_miss = 1'b1;
		else 			  o_miss = 1'b0;
	end

	// check if there is a tag match to indicate hit
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			read_tag_mem <= 1'b0;
			read_data_mem <= 1'b0;
			read_valid_mem <= 1'b0;
		end else begin
			if(i_read && i_req_valid) begin
				read_tag_mem <= 1'b1;
				read_data_mem <= 1'b1;
				read_valid_mem <= 1'b1;
			end	
			else begin
				read_tag_mem <= 1'b0;
				read_data_mem <= 1'b0;
				read_valid_mem <= 1'b0;
			end
		end
	end





	// TODO: this block is only for initial testing- need to replace with a correct replacement scheme
	always_comb begin
		free_way_found = '0;
		free_way = '0;
		for (int i = 0; i < NUM_WAYS; i++) begin
			if(invalid_line[i] && !free_way_found) begin
				free_way  = i[$clog2(NUM_WAYS)-1:0];
				free_way_found = 1'b1;
			end
		end
	end

	// detemine which bank im supposed to write it


endmodule : cache_top
