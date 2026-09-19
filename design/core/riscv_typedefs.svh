`ifndef RISCV_TYPEDEFS_SVH
`define RISCV_TYPEDEFS_SVH

typedef struct packed {
    logic        Branch  ;
    logic        RegDst  ;
    logic        MemRead ;
    logic [1:0]  MemtoReg;
    logic        RegWEn  ;
    logic [1:0]  ALUOp   ;
    logic        ALUSrc  ;
    logic        MemWrite;
    logic [2:0]  ImmSel  ;
    logic        ASel    ;
    logic        Jump    ;
} control_signals_t;

`endif
