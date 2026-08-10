/* ram.v - Simple synchronous byte-addressable RAM for RV64 SoC simulation
 *
 * Features:
 *  - Byte-wide memory array: directly compatible with $readmemh loading
 *    objcopy -O verilog output (byte-per-line hex).
 *  - Parameterized depth and base address
 *  - 64-bit data bus, byte-enable writes (supports sb/sh/sw/sd)
 *  - Synchronous read and write (1 cycle latency), single port
 *
 * NOTE: This is a plain byte-addressable single-port RAM behavioral model,
 * intended as a starting point. Since you're planning to stream this to
 * an instruction cache over AXI, treat this module as the "backing store"
 * behind an AXI slave wrapper -- this module itself does NOT implement
 * AXI handshaking (AWVALID/AWREADY, ARVALID/ARREADY, etc.). You'd wrap
 * this in (or replace this interface with) an AXI4/AXI4-Lite slave that
 * translates AXI burst reads into sequential accesses against `mem`.
 * Happy to build that wrapper next once this base model is confirmed
 * working in simulation.
 */

module ram #(
    parameter          BASE_ADDR  = 64'h0000000080000000,
    parameter integer  MEM_BYTES  = 65536,              // 64KB default
    parameter integer  ADDR_WIDTH = 16                  // width of addr input port
) (
    input  wire                    clk,
    input  wire                    rst_n,

    input  wire [ADDR_WIDTH-1:0]   addr,       // byte address (full address, not offset)
    input  wire [63:0]             wdata,
    output reg  [63:0]             rdata,
    input  wire                    we,         // write enable (overall)
    input  wire [7:0]              byte_en,    // per-byte write enable, bit i = byte i
    input  wire                    re     ,    // read enable
    output                         ready
);

    // Byte-wide memory array -- index i holds byte at (BASE_ADDR + i)
    reg [7:0] mem [0:MEM_BYTES-1];

    // Local (offset) address relative to BASE_ADDR
    // wire [ADDR_WIDTH-1:0] local_addr = addr - BASE_ADDR[ADDR_WIDTH-1:0];

    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            rdata <= 64'b0;
        end else begin
            // Synchronous write, byte-enable granular
            if (we) begin
                for (i = 0; i < 8; i = i + 1) begin
                    if (byte_en[i]) begin
                        mem[addr + i] <= wdata[i*8 +: 8];
                    end
                end
            end

            // Synchronous read: assemble 64-bit word from 8 consecutive bytes
            if (re) begin
                rdata <= { mem[addr+7], mem[addr+6],
                           mem[addr+5], mem[addr+4],
                           mem[addr+3], mem[addr+2],
                           mem[addr+1], mem[addr+0] };
            end
        end
    end

    assign ready = ((we && re) == '0) ? 1'b1 : 1'b0;
    // ------------------------------------------------------------------
    //   Simulation-only preload support.
    //
    // From your testbench, load firmware like this (hierarchical path
    // depends on your instance names in soc_top):
    //
    //   initial begin
    //       $readmemh("firmware.hex", tb_top.soc_top_inst.ram_inst.mem);
    //   end
    //
    // This matches directly with:
    //   riscv-none-elf-objcopy -O verilog firmware.elf firmware.hex
    // since that output is byte-oriented and `mem` here is a byte array.
    // ------------------------------------------------------------------

    // Zero-init memory at start of simulation so uninitialized regions
    // read as 0 instead of X (makes waveform debugging much easier).
    // synthesis translate_off
    initial begin
        $readmemh("C:/Users/Sufiyan Sadiq/Desktop/work/cache/RV64/C/firmware_rebased.hex",tb.rv_soc.ram_slave.ram_memory.mem);
    end

endmodule