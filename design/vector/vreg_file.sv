/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq
-- Date: 15_11_2026
-- Description: This is the larger register file which is made up off interleaved
-- smaller register files
------------------------------------------------------------------------------*/

module vreg_file #(
    parameter NUM_BANKS=16,
    parameter SEW_MAX_WIDTH=64
) (
    input clk,
    input resetn,
    input [$clog2(NUM_BANKS)-1:0] i_mux_sel,
    input [2:0] i_sew,
    input [31:0] i_write_count,
    input i_write ,
    // these are the outputs of the vector units

    // output will go to the processing unit interconnect
    output  [SEW_MAX_WIDTH-1:0] o_v1,
    output [SEW_MAX_WIDTH-1:0] o_v2



);

    // feed these signal to the muxes
    logic [15:0] concat_sew_16_v1[NUM_BANKS/2];
    logic [31:0] concat_sew_32_v1[NUM_BANKS/4];
    logic [63:0] concat_sew_64_v1[NUM_BANKS/8]

    logic [15:0] concat_sew_16_v2[NUM_BANKS/2];
    logic [31:0] concat_sew_32_v2[NUM_BANKS/4];
    logic [63:0] concat_sew_64_v2[NUM_BANKS/8]


    // reg_file signal outputs
    logic [7:0] vreg_arr_v1[NUM_BANKS];
    logic [7:0] vreg_arr_v2[NUM_BANKS];
    
    // wires to connect to each reg_file (for toggling write)
    logic [NUM_BANKS-1:0] write_reg;

    // decoder to make sure that the correct registers are written into
    always_ff @(posedge clk or negedge resetn) begin
        if(~resetn) begin
            write_reg <= '0;
        end
        else begin
            if(write_reg == 0 && i_write) begin
                case (i_sew)
                    3'b000: write_reg[NUM_BANKS-1] <= 1'b1                      ;
                    3'b001: write_reg[NUM_BANKS-1:NUM_BANKS-2] <= 2'b11         ;
                    3'b010: write_reg[NUM_BANKS-1:NUM_BANKS-4] <= 4'b1111       ;
                    3'b011: write_reg[NUM_BANKS-1:NUM_BANKS-8] <= 8'b1111_1111  ;
                endcase            
            end
            else if(i_write) begin
                case (i_sew)
                    3'b000: write_reg[NUM_BANKS-1] <= 1'b1                      ;
                    3'b001: write_reg[NUM_BANKS-1:NUM_BANKS-2] <= 2'b11         ;
                    3'b010: write_reg[NUM_BANKS-1:NUM_BANKS-4] <= 4'b1111       ;
                    3'b011: write_reg[NUM_BANKS-1:NUM_BANKS-8] <= 8'b1111_1111  ;
                endcase
            end
        end
    end


    genvar i;
    generate
        // instantiating the reg files
        for(i  =0; i < NUM_BANKS; i++) begin
            reg_file vreg(
                .clk            (clk),
                .resetn         (resetn),
                .wr_en          (),
                .i_vs1          (),
                .i_vs2          (),
                .i_vd           (),
                .i_wr_data      (),
                .o_vs1          (vreg_arr_v1[i]),
                .o_vs2          (vreg_arr_v2[i])
            );
        end

        // concatenate the elements from the regfile 
        for(i = 0; i < NUM_BANKS/2; i = i + 2) begin
            concat_sew_16_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1]};
            concat_sew_16_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1]};
        end

        for(i = 0; i < NUM_BANKS/4; i = i + 4) begin
            concat_sew_32_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1], vreg_arr_v1[i+2], vreg_arr_v1[i+3]};
            concat_sew_32_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1], vreg_arr_v2[i+2], vreg_arr_v2[i+3]};
        end

        for (i = 0; i < NUM_BANKS/8 ; i = i + 8) begin
            concat_sew_64_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1], vreg_arr_v1[i+2], vreg_arr_v1[i+3], vreg_arr_v1[i+4], vreg_arr_v1[i+5], vreg_arr_v1[i+6], vreg_arr_v1[i+7]};
            concat_sew_64_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1], vreg_arr_v2[i+2], vreg_arr_v2[i+3], vreg_arr_v2[i+4], vreg_arr_v2[i+5], vreg_arr_v2[i+6], vreg_arr_v2[i+7]};
        end

    endgenerate

    // generate muxes for selecting the output



endmodule
