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
    Out = 0; // No Op = default

	if (OP == kADD)                          // add
		Out = InputA + InputB;
	else if ( OP == kR_XOR )                // REDUCTION XOR
	    Out = ^InputA;
	else if (OP == kXOR)                    // bitwise XOR
		Out = InputA ^ InputB;
	else if (OP == kAND)                    // bitwise AND
		Out = InputA & InputB;
	else if (OP == kRSH)                    // shift right
		Out = {1'b0, InputA[7:1]};
	else if (OP == SEQ) begin			// subtract for instructions { SEQ } , JEQ and SLT might need to be in a diff condition
		Out = InputA - InputB; 
		if (Out == 0) 
			// take output of Zero assign to r4
			// or take output Out assign to r4
			Out = 1;
		else 
			Out = 0;
	end
	else if (OP == SLT) begin 			// subtr and shift for SLT
		Out = (InputA - InputB); 	// assuming InputA (Rs) and InputB (Rd)  
		if (Out[7] == 0) // if true, means Rs > Rd
			// set Out = 1, assign val to r4
			Out = 1;
		else 
			// set Out = 0, assign val to r4
			Out = 0;
	end 
	else 
		Out = 0; // No Op = default
	// Remaining to be done: JEQ instr case
end

always_comb	// assign Zero = !Out;
	case(Out)
		'b0:     Zero = 1'b1;
		default: Zero = 1'b0;
	endcase

always_comb
	op_mnemonic = op_mne'(OP);	// displays operation name in waveform viewer

endmodule
