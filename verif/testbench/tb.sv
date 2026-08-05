/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the top testbench
-- 
------------------------------------------------------------------------------*/

`include "cache_params.svh"
module tb;

	logic 				clk				;
	logic 				resetn			;
	logic 				axi_ready		;
	logic [DWIDTH-1:0] 	cache_line		;

	RV64_core rv64_cor(
		.clk   	(clk),
		.resetn	(resetn)
	);

	initial begin
		clk = 0;
		axi_ready = 0;
		resetn = 1'b1;
		#3ns;
		resetn = 1'b0;
		#3ns;
		resetn = 1'b1;
		fork
			begin
				dummy_axi_responder();
			end
			begin
				#1000ns;
			end
		join_any
		disable fork;
		$finish;
	end

	always #5ns clk = ~clk;

	// this function responds to miss requests in place of the axi
	task dummy_axi_responder();
		forever begin
			wait(rv64_cor.Icache_controller.o_axi_req_valid);
			@(posedge clk);
			force rv64_cor.Icache_controller.i_axi_rsp_ready = 1'b1;
			force rv64_cor.Icache_controller.i_axi_rsp_line = {$random(),$random(),$random(),$random(),$random(),$random(),$random(),$random(),$random(), $random(), $random(), $random(), $random(),$random(),$random(),$random()};
			@(posedge clk);
			force rv64_cor.Icache_controller.i_axi_rsp_ready = 1'b0;
			force rv64_cor.Icache_controller.i_axi_rsp_line = '0;
		end
	endtask : dummy_axi_responder





endmodule : tb
