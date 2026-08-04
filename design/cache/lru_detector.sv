/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 04_08_2026
-- Description: This is the lru detector
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module lru_detector (
	input clk,    // Clock
	input resetn,
	input access_valid,
	input [$clog2(DEPTH)-1:0] access_set,
	input [$clog2(NUM_WAYS)-1:0] access_way,
	output logic [$clog2(NUM_WAYS)-1:0] victim_way
);


	logic [$clog2(NUM_WAYS)-1:0] cnt[0:DEPTH-1][0:NUM_WAYS-1];

	// victim selection
    always_comb begin
        victim_way = '0;
        for (int j = 0; j < NUM_WAYS; j++) begin
            if (cnt[access_set][j] == '0)
                victim_way = j[$clog2(NUM_WAYS)-1:0];
        end
    end


	always_ff @(posedge clk or negedge resetn) begin
		if(~resetn) begin
			for (int i = 0; i < DEPTH; i++) begin
				for (int j = 0; j < NUM_WAYS; j++) begin
					cnt[i][j] <= j[$clog2(NUM_WAYS)-1:0];
				end
			end
		end 
		else if(access_valid) begin
			for (int k = 0; k < NUM_WAYS; k++) begin
				if(k == access_way)
					cnt[access_set][k] <= NUM_WAYS-1;
				else if(cnt[access_set][k] > cnt[access_set][access_way])
					cnt[access_set][k] <= cnt[access_set][k] - 1;
				else
					cnt[access_set][k] <= cnt[access_set][k];	
			end
		end
	end


endmodule : lru_detector
