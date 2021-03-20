// Adapted from Professor Eldon's starter code
// Module Name:    ALU
// Project Name:   CSE141L

import definitions::*; // includes package "definitions"

// combinational (unclocked) ALU
module ALU (
	input        [7:0] InputA, // data inputs
                       InputB,
	input        [3:0] OP,		// ALU opcode, part of microcode
	output logic [7:0] Out,		// or:  output reg [7:0] OUT,
	output logic       Zero    // output = zero flag
	);

op_mne op_mnemonic; // type enum: used for convenient waveform viewing

always_comb begin
    // Out = 0; // No Op = default

	if (OP == kADD)                          // add
		Out = InputA + InputB;
	else if ( OP == kR_XOR )                // REDUCTION XOR
	    Out = ^InputA;
	else if (OP == kXOR)                    // bitwise XOR
		Out = InputA ^ InputB;
	else if (OP == kAND)                    // bitwise AND
		Out = InputA & InputB;
	else if (OP == kLSH)                    // shift left
		Out = {InputA[6:0], 1'b0};
	else if (OP == SEQ) begin			// subtract for instructions { SEQ } , JEQ and SLT might need to be in a diff condition
		// Out = InputA - InputB; 
		if ((InputA - InputB) == 0)
			Out = 0; //r0
		else 
			Out = 1;//r0
	end
	else if (OP == SLT) begin
		// assuming InputA (Rd) and InputB (Rs)
		// check to see if Rd (InputA) < Rs (InputB)
		if ( InputA < InputB ) // if true, then Rd (InputA) < Rs (InputB)
			Out = 0; //r0
		else
			Out = 1;//r0 // means Rd (A) >= Rs (B)
	end 
	else if (OP == kOR) // OR operation
		Out = (InputA | InputB);
	else 
		Out = 0; // No Op = default
end

always_comb	// assign Zero = !Out;
	case(Out)
		'b0:     Zero = 1'b1;
		default: Zero = 1'b0;
	endcase

always_comb
	op_mnemonic = op_mne'(OP);	// displays operation name in waveform viewer

endmodule
