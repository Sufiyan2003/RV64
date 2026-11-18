/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 18_11_2026
-- Description: This is the instruction decoder responsible for figuring out
-- which controller to enable, also responsible for checking if there is a
-- TODO: checker, if it can be chained...it will be chained
-- right now this is a dumb forwarder to get a proof of concept 
------------------------------------------------------------------------------*/

package vector_package;
    
    parameter NUM_REGS=32; // contains the number of registers in a register file
    parameter REG_NUM_WIDTH=$clog2(NUM_REGS);
    
    // scalar register width
    parameter XLEN=32;
    parameter DATA_WIDTH    = 64;
    
    
    // opcode disassembly (this will be )
    typedef enum logic [6:0] { 
        VL = 7'b0000_111;
        VS = 7'b0100_111;
        OP_V = 7'b1010_111;
        VSETVLI=7'b1010_111;
    } opcode_t;


    // instruction going into the vector processor
    typedef struct packed {
        logic [REG_NUM_WIDTH-1:0] i_vs1;
        logic [REG_NUM_WIDTH-1:0] i_vs2;
        logic [XLEN-1:0]          x1;
        logic [DATA_WIDTH-1:0]    imm;
        logic [6:0]               opcode;
    } vec_instr_t;

endpackage