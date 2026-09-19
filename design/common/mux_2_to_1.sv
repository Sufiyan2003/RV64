

module mux_2_to_1 #(
    parameter XLEN = 32
)(
	input [XLEN-1:0] x,
	input [XLEN-1:0] y,
	input select,
	output reg [XLEN-1:0] out

);
	always @(*) begin
		out = select ? (y):(x);
	end
endmodule  