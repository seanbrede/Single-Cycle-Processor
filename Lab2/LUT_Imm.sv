// the lookup table acts like a function: target = f(index);
module LUT_Imm (
	input        [4:0] index,
	output logic [7:0] immediate
	);

always_comb 
	case (index)
		5'd01:   immediate = 8'd000; // convenience
		5'd02:   immediate = 8'd001; // convenience
		5'd03:   immediate = 8'd009; // iterating through tap patterns
		5'd04:   immediate = 8'd010; // bounding the number of spaces
		5'd05:   immediate = 8'd026; // bounding the number of spaces
		5'd06:   immediate = 8'd054; // FILL IN
		5'd07:   immediate = 8'd061; // FILL IN
		5'd08:   immediate = 8'd064; // FILL IN
		5'd09:   immediate = 8'd065; // FILL IN
		5'd10:   immediate = 8'd075; // FILL IN
		// more immediates to go here
		default: immediate = 8'd255; // error: tried to look up a nonexistent index
	endcase

endmodule