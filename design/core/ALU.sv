/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 26_07_2026
-- Description: This is the scalar ALU
-- TODO: have to update it to support RV64, currently it supports RV32 only
------------------------------------------------------------------------------*/

module ALU #(
    parameter XLEN=32
)(
    input [XLEN-1:0]        in1             ,
    input [XLEN-1:0]        in2             ,
    input [3:0]             ALUCtrl         ,
    output reg [XLEN-1:0]   Result
);


    parameter AND  = 4'b0000 , OR   = 4'b0001   , 
              ADD  = 4'b0010 , XOR  = 4'b0011   ,
              SRL  = 4'b0100 , SRA  = 4'b0101   ,
              SUB  = 4'b0110 , SLT  = 4'b0111   ,
              SLL  = 4'b1000 , SLTU = 4'b1001   ;
        
    always_comb begin
        case(ALUCtrl) 
            AND:        Result = in1 & in2                     ;
            OR:         Result = in1 | in2                     ;
            ADD:        Result = in1 + in2                     ; 
            XOR:        Result = in1 ^ in2                     ;
            SRL:        Result = in1 >> in2[4:0]               ;
            SLL:        Result = in1 << in2[4:0]               ;
            SUB:        Result = in2 - in1                     ;
            SRA:        Result = $signed(in1) >>> in2[4:0]     ;
            SLT:        Result = $signed(in1) < $signed(in2)   ;
            SLTU:       Result = in1 < in2                     ;		 
            default:    Result = 0                             ;
        endcase 
    end
endmodule