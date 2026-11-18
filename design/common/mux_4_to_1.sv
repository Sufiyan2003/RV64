

module mux_4_to_1 #(
    parameter XLEN = 32
)(
	input [XLEN-1:0] a,
	input [XLEN-1:0] b,
	input [XLEN-1:0] c,
	input [XLEN-1:0] d,
	input [1:0] select,
	output reg [XLEN-1:0] out

);
	always_comb begin
		if(select == 2'b00) out = a;
        if(select == 2'b01) out = b;
        if(select == 2'b10) out = c;
        if(select == 2'b11) out = d;
	end
endmodule  