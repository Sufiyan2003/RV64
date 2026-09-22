+incdir+./design
+incdir+./design/cache
+incdir+./design/ram
+incdir+./design/common
+incdir+./design/core
+incdir+./design/interfaces
+incdir+./verif
+incdir+./verif/testbench



// common files needed
./design/common/mux_2_to_1.sv
./design/common/mux_3_to_1.sv


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

./design/RV64_core.sv
./design/RV64_soc.sv
./verif/testbench/tb.sv