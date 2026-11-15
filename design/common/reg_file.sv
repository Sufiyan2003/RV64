/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 15_11_2026
-- Description: This is the mini register file making up the larger vector per lane
-- register file
------------------------------------------------------------------------------*/


module reg_file # (
    parameter DEPTH=32,
    parameter WIDTH=8
)(
    input clk,
    input resetn,
    input wr_en,
    input [$clog2(DEPTH)-1:0] i_vs1,
    input [$clog2(DEPTH)-1:0] i_vs2,
    input [$clog2(DEPTH)-1:0] i_vd,
    input [WIDTH-1:0] i_wr_data,
    output [WIDTH-1:0] o_vs1,
    output [WIDTH-1:0] o_vs2
);


    logic [WIDTH-1:0] registers[DEPTH];

    // managing the register file write
    always_ff @(posedge clk or negedge resetn) begin
        if(~resetn) begin
            for(int i =0; i < DEPTH; i++) begin
                registers[i] <= '0;
            end
        end
        else begin
            if(wr_en) registers[i_vd] <= i_wr_data;
        end
    end

    assign o_vs1 = registers[i_vs1];
    assign o_vs2 = registers[i_vs2];

endmodule