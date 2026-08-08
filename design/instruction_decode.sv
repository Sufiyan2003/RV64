/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This is responsible for decoding the instruction fetched
-- should output instruction fields to send to control block
------------------------------------------------------------------------------*/

module instruction_decode (
	input clk,    // Clock
	input resetn,
	input [31:0] i_instruction
);


	// in case inst[1:0] == 2'b11
	typedef enum logic [4:0] {
	    INST_LOAD,
	    INST_LOAD_FP,
	    INST_CUSTOM_0,
	    INST_MISC_MEM,
	    INST_OP_IMM,
	    INST_AUIPC,
	    INST_OP_IMM_32,

	    INST_STORE,
	    INST_STORE_FP,
	    INST_CUSTOM_1,
	    INST_AMO,
	    INST_OP,
	    INST_LUI,
	    INST_OP_32,

	    INST_MADD,
	    INST_MSUB,
	    INST_NMSUB,
	    INST_NMADD,
	    INST_OP_FP,
	    INST_OP_V,
	    INST_CUSTOM_2,

	    INST_BRANCH,
	    INST_JALR,
	    INST_JAL,
	    INST_SYSTEM,
	    INST_OP_VE,
	    INST_CUSTOM_3,

	    INST_RESERVED
	} inst_type_e;
		
	logic [6:0] opcode;
	assign opcode = i_instruction[6:0];

    always_comb begin
        case (opcode)
            7'b0000011: inst_type = INST_LOAD;
            7'b0000111: inst_type = INST_LOAD_FP;
            7'b0001011: inst_type = INST_CUSTOM_0;
            7'b0001111: inst_type = INST_MISC_MEM;
            7'b0010011: inst_type = INST_OP_IMM;
            7'b0010111: inst_type = INST_AUIPC;
            7'b0011011: inst_type = INST_OP_IMM_32;

            7'b0100011: inst_type = INST_STORE;
            7'b0100111: inst_type = INST_STORE_FP;
            7'b0101011: inst_type = INST_CUSTOM_1;
            7'b0101111: inst_type = INST_AMO;
            7'b0110011: inst_type = INST_OP;
            7'b0110111: inst_type = INST_LUI;
            7'b0111011: inst_type = INST_OP_32;

            7'b1000011: inst_type = INST_MADD;
            7'b1000111: inst_type = INST_MSUB;
            7'b1001011: inst_type = INST_NMSUB;
            7'b1001111: inst_type = INST_NMADD;
            7'b1010011: inst_type = INST_OP_FP;
            7'b1010111: inst_type = INST_OP_V;
            7'b1011011: inst_type = INST_CUSTOM_2;

            7'b1100011: inst_type = INST_BRANCH;
            7'b1100111: inst_type = INST_JALR;
            7'b1101111: inst_type = INST_JAL;
            7'b1110011: inst_type = INST_SYSTEM;
            7'b1110111: inst_type = INST_OP_VE;
            7'b1111011: inst_type = INST_CUSTOM_3;
            default:    inst_type = INST_RESERVED;
        endcase
    end




endmodule : instruction_decode
