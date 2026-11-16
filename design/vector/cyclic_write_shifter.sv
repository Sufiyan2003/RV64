/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 16_11_2026
-- Description: This is the block which is responsible for generating write
-- signals to write into the desired register file
------------------------------------------------------------------------------*/

module cyclic_write_shifter #(
    parameter NUM_BANKS=16
)(
    input                   clk         ,
    input                   resetn      ,
    input [2:0]             i_sew       ,
    input                   i_start     , // this signal will tell the cyclic shifter to switch
    input                   i_shift_en  ,
    input                   i_dis_write ,
    input                   reg_write   ,
    output [NUM_BANKS-1:0]  o_wr_en 
);

    // shift register and static mask
    logic [NUM_BANKS-1:0]   wr_en       ;
    logic [NUM_BANKS-1:0]   wr_mask     ; // this is to stop the register file writing something it shouldnt
    
    
    logic [3:0]             shift_amt   ;
    logic [3:0]             shift_in    ;
    
    // [0   0   0   1] -----> shift by 1
    // [0   0   1   1] -----> shift by 2 and so on....

    logic [3:0]             enabled_window;

    always_ff @( posedge clk or negedge resetn ) begin
        if(~resetn) begin
            wr_en <= '0;
        end 
        else begin
            if(i_shift_en && i_start) begin
                // load the window into the shift register on start
                case (i_sew)
                    3'b000: wr_en <= {shift_in[0], wr_en[NUM_BANKS-2:0]};
                    3'b001: wr_en <= {shift_in[1:0], wr_en[NUM_BANKS-3:0]};
                    3'b010: wr_en <= {shift_in[2:0], wr_en[NUM_BANKS-4:0]};
                    3'b011: wr_en <= {shift_in[3:0] ,wr_en[NUM_BANKS-5:0]};
                endcase
            end
            else if(i_shift_en) begin
                // right shift when only shift is enabled
                case (i_sew)
                    3'b000: wr_en <= wr_en >> 1;
                    3'b001: wr_en <= wr_en >> 2;
                    3'b010: wr_en <= wr_en >> 4;
                    3'b011: wr_en <= wr_en >> 8;
                endcase
            end
            else begin
                wr_en <= wr_en;
            end
        end       
    end

    // mux to select the input
    always_comb begin
        if(i_start) shift_in = enabled_window   ;
        else        shift_in = wr_en[3:0]       ;
    end

    
    always_comb begin
        case (i_sew)
            3'b000: shift_amt = 4'b0001;  
            3'b001: shift_amt = 4'b0010;
            3'b010: shift_amt = 4'b0100;
            3'b011: shift_amt = 4'b1000;
        endcase
    end

    always_comb begin
        case (i_sew)
            3'b000: enabled_window = 4'b0001;
            3'b001: enabled_window = 4'b0011;
            3'b010: enabled_window = 4'b0111;
            3'b011: enabled_window = 4'b1111;
        endcase
    end

    // write mask is set based on whether stall_reg_file is set
    always_comb begin
        if(i_dis_write) wr_mask <= '0;
        else            wr_mask <= '1;
    end

    // combinationally output 
    assign o_wr_en = wr_en && wr_mask;

endmodule
