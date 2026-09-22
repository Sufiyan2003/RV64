/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 26_07_2026
-- Description: This is the instruction decode module for decoding the instruction
-- from the cache according to the RV64I ISA
------------------------------------------------------------------------------*/

`include "riscv_typedefs.svh"
`include "cache_params.svh"

module instr_decode (
	input  logic [INSTR_WIDTH-1:0]  i_instr,
	output control_signals_t        o_ctrl
);

    logic [6:0] opcode;


    assign opcode = i_instr[6:0];

    typedef enum logic [2:0] {
        R_TYPE      ,
        I_TYPE      ,
        LOAD_TYPE   ,
        S_TYPE      ,
        B_TYPE      ,
        U_TYPE      ,
        J_TYPE
    } instr_type_t;

    instr_type_t instr_type;

    always_comb begin
        case(opcode)
            7'b0110011: instr_type = R_TYPE;
            7'b0010011: instr_type = I_TYPE;
            7'b0000011: instr_type = LOAD_TYPE;
            7'b0100011: instr_type = S_TYPE;
            7'b1100011: instr_type = B_TYPE;
            7'b0010111: instr_type = U_TYPE;
            7'b1101111: instr_type = J_TYPE;
        endcase
    end


    always_comb begin
        case(instr_type)
            // simple R type instruction 
            R_TYPE: begin
                o_ctrl.Branch      = 0;
                o_ctrl.RegDst      = 0;
                o_ctrl.MemRead     = 0;
                o_ctrl.MemtoReg    = 2'b01;
                o_ctrl.RegWEn      = 1;
                o_ctrl.ALUOp[0]    = 0;
                o_ctrl.ALUOp[1]    = 1;
                o_ctrl.ALUSrc      = 0;
                o_ctrl.MemWrite    = 0;
				o_ctrl.ImmSel      = 3'b000;
				o_ctrl.ASel        = 0;
				o_ctrl.Jump        = 0;
            end
            I_TYPE: begin
                o_ctrl.Branch  = 0;
				o_ctrl.RegDst = 0;
				o_ctrl.MemRead = 0;
				o_ctrl.MemtoReg = 2'b01;
				o_ctrl.RegWEn = 1;
				o_ctrl.ALUSrc = 1;
				o_ctrl.ALUOp[0] = 0;
				o_ctrl.ALUOp[1] = 1;
				o_ctrl.MemWrite = 0;
				o_ctrl.ImmSel = 3'b000;
				o_ctrl.ASel = 0;
				o_ctrl.Jump  = 0;
            end
            LOAD_TYPE: begin
            	o_ctrl.Branch  = 0;
				o_ctrl.RegDst = 0;
				o_ctrl.MemRead = 1;
				o_ctrl.MemtoReg = 2'b01;
				o_ctrl.RegWEn = 1;
				o_ctrl.ALUSrc = 1;
				o_ctrl.ALUOp[0] = 0;
				o_ctrl.ALUOp[1] = 0;
				o_ctrl.MemWrite = 0;
				o_ctrl.ImmSel = 3'b000;
				o_ctrl.ASel = 0;
				o_ctrl.Jump  = 0;
            end
            S_TYPE: begin
                o_ctrl.Branch  = 0;
                o_ctrl.MemRead = 0;
                o_ctrl.MemtoReg = 2'b00;
                o_ctrl.RegWEn = 0;
                o_ctrl.ALUSrc = 1;
                o_ctrl.ALUOp[0] = 0;
                o_ctrl.ALUOp[1] = 0;
                o_ctrl.MemWrite = 1;
                o_ctrl.ImmSel = 3'b001;
                o_ctrl.ASel = 0;
                o_ctrl.RegDst = 0;
                o_ctrl.Jump  = 0;
            end
            U_TYPE: begin
                o_ctrl.Branch  = 0;
                o_ctrl.RegDst = 0;
                o_ctrl.MemRead = 0;
                o_ctrl.MemtoReg = 2'b01;
                o_ctrl.RegWEn = 1;
                o_ctrl.ALUOp[0] = 0;
                o_ctrl.ALUOp[1] = 1;
                o_ctrl.MemWrite = 0;
                o_ctrl.ALUSrc = 1;
                o_ctrl.ImmSel = 3'b011;
                o_ctrl.ASel = 1;
                o_ctrl.Jump  = 0;
            end
            B_TYPE: begin
                o_ctrl.Branch  = 1;
				o_ctrl.ALUSrc = 1;
				o_ctrl.ASel = 1;
				o_ctrl.RegWEn = 0;
				o_ctrl.RegDst = 0;
				o_ctrl.MemRead = 0;
				o_ctrl.MemWrite = 0;
				o_ctrl.MemtoReg = 2'b01;
				o_ctrl.ALUOp[1] = 0;
				o_ctrl.ALUOp[0] = 0;
				o_ctrl.ImmSel = 3'b010;
				o_ctrl.Jump  = 0;
            end
            J_TYPE: begin
                o_ctrl.RegDst = 0;
                o_ctrl.MemRead = 0;
                o_ctrl.MemtoReg =2'b10;
                o_ctrl.MemWrite = 0; 
                o_ctrl.Jump  = 1;
                o_ctrl.Branch = 0;
                o_ctrl.ALUSrc = 1;
                o_ctrl.ALUOp[0] = 0;
                o_ctrl.ALUOp[1] = 0;
                o_ctrl.ASel = 1;
                o_ctrl.ImmSel = 3'b100;
                o_ctrl.RegWEn = 1;
            end
            default: begin
                o_ctrl.RegDst = 0;
				o_ctrl.MemRead = 0;
				o_ctrl.MemtoReg =2'b00;
				o_ctrl.Jump = 0;
				o_ctrl.RegWEn = 0;
				o_ctrl.ALUOp[0] = 0;
				o_ctrl.ALUOp[1] = 0;
				o_ctrl.MemWrite = 0; 
				o_ctrl.ALUSrc = 0;
				o_ctrl.ImmSel = 3'b000;
				o_ctrl.ASel = 0;
				o_ctrl.Branch  = 0; 
            end
        endcase
    end



endmodule : instr_decode
