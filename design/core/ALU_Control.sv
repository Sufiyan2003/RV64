/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 26_07_2026
-- Description: This is the alu control block to select the mode of operation
-- for the alu 
------------------------------------------------------------------------------*/


module ALU_Control(
    input [1:0] ALUOp,
    input [2:0] func3,
    input func7_0, //for multiplaction later on
    input func7_5,
    output reg [3:0] ALUCtrl
);
    always @(*) begin
        if      (ALUOp == 2'b00) ALUCtrl = 4'b0010;
        else if (ALUOp == 2'b01) ALUCtrl = 4'b0110;
        else if (ALUOp == 2'b10) begin
            case (func3)
                3'b000: ALUCtrl = 4'b0010;
                3'b001: ALUCtrl = 4'b1000;        
                3'b010: ALUCtrl = 4'b0111;         
                3'b011: ALUCtrl = 4'b1001;        
                3'b100: ALUCtrl = 4'b0011;        
                3'b101: begin
                    if(func7_5) ALUCtrl = 4'b0101;
                    else        ALUCtrl = 4'b0100;
                end         
                3'b110: ALUCtrl = 4'b0001;        
                3'b111: ALUCtrl = 4'b0000;        
            endcase
        end
		else ALUCtrl = 4'b0000;
    end
endmodule