`ifndef DCACHE_PARAMS_SVH
`define DCACHE_PARAMS_SVH

localparam DWIDTH=512;
localparam DEPTH =16;
localparam XLEN=32;
// the width of the cache address depends on XLEN for dcache
localparam NUM_WAYS=4;
localparam BYTE_OFF_WIDTH = $clog2(DWIDTH/8);
localparam LINE_NUMBER_WIDTH = $clog2(DEPTH);
localparam TAG_WIDTH = XLEN - LINE_NUMBER_WIDTH - BYTE_OFF_WIDTH; 

`endif