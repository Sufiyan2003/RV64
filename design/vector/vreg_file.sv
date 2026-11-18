/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq
-- Date: 15_11_2026
-- Description: This is the larger register file which is made up off interleaved
-- smaller register files
------------------------------------------------------------------------------*/

module vreg_file #(
    parameter NUM_REGFILES=16,
    parameter SEW_MAX_WIDTH=64
) (
    input clk                                   ,
    input resetn                                ,
    input [$clog2(NUM_REGFILES)-1:0] i_mux_sel     ,
    input [2:0] i_sew                           ,
    input [31:0] i_write_count                  ,
    input [SEW_MAX_WIDTH-1:0] i_write_val       ,
    
    input [4:0] i_v1                            ,
    input [4:0] i_v2                            ,
    input [4:0] i_vd                            ,
    input i_reg_write                           ,
    input i_reg_start                           ,
    input i_stop_write                          ,

    // these are the outputs of the vector units

    // output will go to the processing unit interconnect
    output  [SEW_MAX_WIDTH-1:0] o_v1            ,
    output [SEW_MAX_WIDTH-1:0] o_v2



);

    // feed these signal to the muxes
    logic [15:0] concat_sew_16_v1[NUM_REGFILES/2];
    logic [31:0] concat_sew_32_v1[NUM_REGFILES/4];
    logic [63:0] concat_sew_64_v1[NUM_REGFILES/8];

    logic [15:0] concat_sew_16_v2[NUM_REGFILES/2];
    logic [31:0] concat_sew_32_v2[NUM_REGFILES/4];
    logic [63:0] concat_sew_64_v2[NUM_REGFILES/8];


    // reg_file signal outputs
    logic [7:0] vreg_arr_v1[NUM_REGFILES];
    logic [7:0] vreg_arr_v2[NUM_REGFILES];
    
    // wires to connect to each reg_file (for toggling write)
    logic [NUM_REGFILES-1:0] write_reg;

    // this is the output from the generated muxes to feed into each individual register file
    logic [7:0] reg_write_val[NUM_REGFILES];



    /**********************************************************************
        This is responsible for generating write enables to each smaller
        register file
    **********************************************************************/
    cyclic_write_shifter #(
        .NUM_REGFILES(NUM_REGFILES)
    ) cyc_write_shift(
        .clk                (clk)           ,
        .resetn             (resetn)        ,
        .i_sew              (i_sew)         ,
        .i_start            (i_reg_start)   ,
        .i_shift_en         (i_reg_write)   ,
        .i_dis_write        (i_stop_write)  ,
        .o_wr_en            (write_reg)
    );    

    genvar i;
    generate
        // instantiating the reg files
        for(i  =0; i < NUM_REGFILES; i++) begin
            reg_file vreg(
                .clk            (clk),
                .resetn         (resetn),
                .wr_en          (write_reg[NUM_REGFILES-1-i]), // register is inverted
                .i_vs1          (i_v1),
                .i_vs2          (i_v2),
                .i_vd           (i_vd),
                .i_wr_data      (reg_write_val[i]),
                .o_vs1          (vreg_arr_v1[i]),
                .o_vs2          (vreg_arr_v2[i])
            );
        end

        // concatenate the elements from the regfile 
        for(i = 0; i < NUM_REGFILES/2; i = i + 2) begin
            assign concat_sew_16_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1]};
            assign concat_sew_16_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1]};
        end

        for(i = 0; i < NUM_REGFILES/4; i = i + 4) begin
            assign concat_sew_32_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1], vreg_arr_v1[i+2], vreg_arr_v1[i+3]};
            assign concat_sew_32_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1], vreg_arr_v2[i+2], vreg_arr_v2[i+3]};
        end

        for (i = 0; i < NUM_REGFILES/8 ; i = i + 8) begin
            assign concat_sew_64_v1[i] = {vreg_arr_v1[i], vreg_arr_v1[i+1], vreg_arr_v1[i+2], vreg_arr_v1[i+3], vreg_arr_v1[i+4], vreg_arr_v1[i+5], vreg_arr_v1[i+6], vreg_arr_v1[i+7]};
            assign concat_sew_64_v2[i] = {vreg_arr_v2[i], vreg_arr_v2[i+1], vreg_arr_v2[i+2], vreg_arr_v2[i+3], vreg_arr_v2[i+4], vreg_arr_v2[i+5], vreg_arr_v2[i+6], vreg_arr_v2[i+7]};
        end

        // Generating the muxes to control the write values to each mux
        for(i = 0; i < NUM_REGFILES; i++) begin
            mux_4_to_1 #(
                .XLEN(8)
            ) u_mux (
                .a          (i_write_val[7:0]),
                .b          (i_write_val[(15- 8*(i % 2))  : (8 -  8*(i%2))]),
                .c          (i_write_val[(31- 8*(i % 2))  : (24 - 8*(i%4))]),
                .d          (i_write_val[(63- 8*(i % 2))  : (56 - 8*(i%8))]),
                .select     (i_sew[1:0]),
                .out        (reg_write_val[i])
            );
        end        


    endgenerate

endmodule
