// Adapted from Professor Eldon's starter code
// Module Name:    ALU
// Project Name:   CSE141L

import definitions::*; // includes package "definitions"

// combinational (unclocked) ALU
module ALU (
	input        [7:0] InputA, // data inputs
	input              InputB,
	input        [3:0] OP,		// ALU opcode, part of microcode
	output logic [7:0] Out,		// or:  output reg [7:0] OUT,
	output logic       Zero    // output = zero flag
	);

op_mne op_mnemonic; // type enum: used for convenient waveform viewing

always_comb begin
    Out = 0; // No Op = default

	if (OP >= kADD & OP <= 4'b0001)         // add
		Out = InputA + InputB;
	else if (OP >= 4'b1010 & OP <= 4'b1100) // subtract
		Out = InputA - InputB;
	else if (OP == kXOR)                    // bitwise XOR
		Out = InputA ^ InputB;
	else if (OP == kAND)                    // bitwise AND
		Out = InputA & InputB;
	else if (OP == kLSH)                    // shift left
		Out = InputA << 1;
	else if (OP == kRSH)                    // shift right
		Out = {1'b0, InputA[7:1]};
end

always_comb	// assign Zero = !Out;
	case(Out)
		'b0:     Zero = 1'b1;
		default: Zero = 1'b0;
	endcase

always_comb
	op_mnemonic = op_mne'(OP);	// displays operation name in waveform viewer

endmodule
