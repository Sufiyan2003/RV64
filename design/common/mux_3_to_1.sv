module mux_3_to_1 #(
	parameter XLEN = 32
)(
	input [XLEN-1:0] x,
	input [XLEN-1:0] y,
	input [XLEN-1:0] z,
	input [1:0] select,
	output reg [XLEN-1:0] out
);
	always @(*) begin
		case(select)
			2'b00: out = x;
			2'b01: out = y;
			2'b10: out = z;
			default: out = 32'b0;
		endcase
	end

endmodule