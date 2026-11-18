+incdir+./design
+incdir+./design/cache
+incdir+./design/ram
+incdir+./design/common
+incdir+./design/core
+incdir+./design/vector
+incdir+./design/interfaces
+incdir+./verif
+incdir+./verif/testbench



// common files needed
./design/common/mux_2_to_1.sv
./design/common/mux_3_to_1.sv
./design/common/mux_4_to_1.sv
./design/common/register.sv
./design/common/sync_fifo.sv

// rtl defines
./design/core/riscv_typedefs.svh

// interfaces
./design/interfaces/axi4_intf.sv

./design/cache/memwrap.sv
./design/cache/cache_params.svh
./design/cache/cache_controller.sv
./design/cache/lru_detector.sv
./design/cache/cache_top.sv

./design/ram/ram_axi_wrapper.sv
./design/ram/ram_axi_slave.sv

// IF files needed
./design/axi_cache_requester.sv
./design/ProgramCounter.sv
./design/ram.sv
./design/axi_cache_requester.sv


// ID files
./design/register_file.sv
./design/core/instr_decode.sv
./design/core/ALU_Control.sv
./design/core/ALU.sv
./design/core/ImmGen.sv
./design/core/instr_decode.sv

./design/IF_stage.sv
./design/core/ID_stage.sv
./design/core/EX_stage.sv
./design/MEM_stage.sv


// vector dependencies
./design/vector/vector_package.sv
./design/vector/vec_instr_decoder.sv
./design/vector/cyclic_write_shifter.sv
./design/vector/vreg_file.sv

// top level wrappers
./design/RV64_core.sv
./design/RV64_soc.sv
./verif/testbench/tb.sv