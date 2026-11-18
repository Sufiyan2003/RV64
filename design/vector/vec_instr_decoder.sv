/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 18_11_2026
-- Description: This is the instruction decoder responsible for figuring out
-- which controller to enable, also responsible for checking if there is a
-- TODO: checker, if it can be chained...it will be chained
-- right now this is a dumb forwarder to get a proof of concept 
------------------------------------------------------------------------------*/

import vector_package::*;
module vec_instr_decoder #(
    parameter SEW_MAX_WIDTH=64
) (
    input clk,
    input resetn,
    input vec_instr_t i_instr
);


    
    
endmodule
