// the lookup table acts like a function: target = f(index);
module LUT_Add (
	input        [4:0] index,
	output logic [9:0] address
	);

always_comb 
	case (index)
		5'd01:   address = 10'd0000; 
		// more addresses to go here
		default: address = 10'd1023; // error: tried to look up a nonexistent index
	endcase

endmodule