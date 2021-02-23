module LUT_Add (
	input        [4:0] index,
	output logic [9:0] address
);
always_comb
	case (index)
		5'd0:    address = 10'd0;
		5'd1:    address = 10'd3;
		default: address = 10'd1023;
	endcase
endmodule