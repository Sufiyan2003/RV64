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
	output logic [INSTR_WIDTH-1:0] o_data,
	output 	logic			o_hit 		,
	output logic 			o_write_done ,
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
	logic [NUM_WAYS-1:0]	invalid_line 		;


	logic read_tag_mem;
	logic read_data_mem;
	logic read_valid_mem;

	logic write_tag_mem  	[NUM_WAYS];
	logic write_data_mem 	[NUM_WAYS];
	logic write_invalid_mem [NUM_WAYS];

	// detect which way has the desired line
	logic [$clog2(NUM_WAYS)-1:0] target_way;
	logic [$clog2(NUM_WAYS)-1:0] write_to_inv_way;
	logic [$clog2(NUM_WAYS)-1:0] write_way;
	logic found_invalid_way;

	logic [$clog2(NUM_WAYS)-1:0] lru_victim_way;
	logic [$clog2(NUM_WAYS)-1:0] fill_way;


	// generate the number of memory wrappers as there are number of ways
	genvar i;
	generate
		// data storage
		for (i = 0; i < NUM_WAYS; i++) begin : data_block
			memwrap #(
				.DWIDTH    (DWIDTH),
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH)
			) memory(
				.clk     (clk) 					,
				.resetn  (resetn) 				,
				.write_en(write_data_mem[i]) 	,			// write to memory if its a hit
				.read_en (i_read) 		,			// ready from memory to throw it as an output 
				.i_addr  (line_number) 			,			// give it the line number
				.i_data  (i_data) 				,
				.o_data  (line_data[i])
			);
		end

		// for storing tags
		for (i = 0; i < NUM_WAYS; i++) begin : tag_set
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
				.read_en (i_read) 	,   			// read it to detect hit or miss
				.write_en(write_tag_mem[i])
			);
		end

		// for storing valids
		for (i = 0; i < NUM_WAYS; i++) begin : valid_set
			memwrap #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DEPTH     (DEPTH),
				.DWIDTH    (1),
				.DEFAULT_VAL (1)
			) invalid_mem(
				.clk     (clk) 						,
				.resetn  (resetn) 					,
				.i_data  (1'b0) 					,
				.i_addr  (line_number) 				,
				.o_data  (invalid_line[i]) 			,
				.read_en (i_read)   		,
				.write_en(write_invalid_mem[i])
			);
		end

		// for storing dirty bits
		for (i = 0; i < NUM_WAYS; i++) begin : dirty_bits
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


	/*------------------------------------------------------------------------------
	--  							LRU detector
	------------------------------------------------------------------------------*/
	lru_detector lru_detect(
		.clk         (clk)	 							,
		.resetn      (resetn)							,
		.access_valid(o_hit || (i_write && o_miss))		,
		.access_set  (line_number)						,
		.access_way  (o_hit ? target_way : fill_way)	,
		.victim_way  (lru_victim_way)
	);


	logic lookup_valid;

	always_ff @(posedge clk or negedge resetn) begin
	    if(!resetn)
	        lookup_valid <= 1'b0;
	    else
	        lookup_valid <= i_read;
	end


	assign o_miss = lookup_valid && !o_hit;

	// hold the byte offset with the SRAM lookup so it still matches when hit is seen
	logic [BYTE_OFF_WIDTH-1:0] byte_offset_q;

	always_ff @(posedge clk or negedge resetn) begin
	    if(!resetn)
	        byte_offset_q <= '0;
	    else if(i_read)
	        byte_offset_q <= byte_offset;
	end

	/*------------------------------------------------------------------------------
	--  						Detecting Hit or miss
	------------------------------------------------------------------------------*/
	always_comb begin
		o_hit = 1'b0;
		target_way = '0;
		if(lookup_valid) begin
			for (int i = 0; i < NUM_WAYS; i++) begin
				if(!invalid_line[i] && (tag_val[i] == tag_value)) begin
					o_hit = 1'b1;
					target_way = i;
				end
			end
		end
	end

	/*------------------------------------------------------------------------------
	--  Drive the 32-bit instruction from the hit-way line
	------------------------------------------------------------------------------*/
	always_comb begin
		o_data = '0;
		if(o_hit)
			// 4-byte-align the offset, then convert byte index to bit index
			o_data = line_data[target_way][{byte_offset_q[BYTE_OFF_WIDTH-1:2], 5'b0} +: INSTR_WIDTH];
	end


	// check if there is a tag match to indicate hit
	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			read_tag_mem <= 1'b0;
			read_data_mem <= 1'b0;
			read_valid_mem <= 1'b0;
		end else begin
			if(i_read) begin
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



	// check which is the target way if any line is invalid
	always_comb begin
	    write_to_inv_way = '0;
	    found_invalid_way = 1'b0;
	    for (int i = 0; i < NUM_WAYS; i++) begin
	        if (invalid_line[i] && !found_invalid_way) begin
	            write_to_inv_way = i[$clog2(NUM_WAYS)-1:0];
	            found_invalid_way = 1'b1;
	        end
	    end
	    fill_way = found_invalid_way ? write_to_inv_way : lru_victim_way;
	end


	// check if any line is invalid just write it in
	always_ff @(posedge clk or negedge resetn) begin
	    if (~resetn) begin
	    	o_write_done <= 1'b0;
	        for (int i = 0; i < NUM_WAYS; i++) begin
	            write_tag_mem[i]     <= 1'b0;
	            write_invalid_mem[i] <= 1'b0;
	            write_data_mem[i]    <= 1'b0;
	        end
	    end else begin
	        for (int i = 0; i < NUM_WAYS; i++) begin
	            write_tag_mem[i]     <= 1'b0;
	            write_invalid_mem[i] <= 1'b0;
	            write_data_mem[i]    <= 1'b0;
	        end
	        if (i_write) begin
	            // fill_way already picks invalid-way-first, else LRU victim
	            write_tag_mem[fill_way]     <= 1'b1;
	            write_invalid_mem[fill_way] <= 1'b1;
	            write_data_mem[fill_way]    <= 1'b1;
	            o_write_done <= 1'b1;
	        end
	        else begin
	        	o_write_done <= 1'b0;
	        end
	    end
	end


endmodule : cache_top
