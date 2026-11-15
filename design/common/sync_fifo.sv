/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 02_08_2026
-- Description: This is the synchronous fifo
------------------------------------------------------------------------------*/


module sync_fifo #(
    parameter DEPTH=16,
    parameter DWIDTH=32,
    parameter FULL_THRESH=DEPTH-2
) (
    input clk                       ,
    input resetn                    ,
    input wr_en                     ,
    input rd_en                     ,
    output empty                    ,
    output full                     ,
    input [DWIDTH-1:0] data_in      ,
    output [DWIDTH-1:0] q
);
    
    localparam PTR_WIDTH = $clog2(DWIDTH);
    
    // allocate pointers 
    logic [PTR_WIDTH:0] rd_ptr, wr_ptr;

    // declare the fifo mem
    logic [DWIDTH-1:0] mem[DEPTH];


    // initializing memory and wr_ptr updating
    always_ff @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            wr_ptr <= '0;
            for(int i = 0; i < DEPTH; i++) begin
                mem[i] <= '0;
            end
        end
        else if(wr_en && !full) begin
            mem[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // read pointer management
    always_ff @(posedge clk or negedge resetn) begin
        if(~resetn) rd_ptr <= '0;
        else if(rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    assign empty = wr_ptr == rd_ptr ? 1'b1 : 1'b0;
    assign full = (wr_ptr - rd_ptr) == FULL_THRESH ? 1'b1: 1'b0;

    assign q = mem[rd_ptr[PTR_WIDTH-1:0]];

endmodule

