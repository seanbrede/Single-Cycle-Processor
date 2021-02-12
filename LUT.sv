// the lookup table acts like a function: target = f(index);
module LUT (
	input        [4:0] index,
	output logic [7:0] target
	);

always_comb 
	case (index)
		5'd01:   target = 8'd000; // convenience
		5'd02:   target = 8'd001; // convenience
		5'd03:   target = 8'd009; // iterating through tap patterns
		5'd04:   target = 8'd010; // bounding the number of spaces
		5'd05:   target = 8'd026; // bounding the number of spaces
		5'd06:   target = 8'd054; // 
		5'd07:   target = 8'd061; // 
		5'd08:   target = 8'd064; // 
		5'd09:   target = 8'd065; // 
		5'd10:   target = 8'd075; //
		// more constants to probably go here
		default: target = 8'd255; // error: tried to look up a nonexistent index
	endcase

endmodule