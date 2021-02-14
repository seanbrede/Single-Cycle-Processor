//  Adapted from Professor Eldons starter code
// Module Name:    ALU 
// Project Name:   CSE141L

//   combinational (unclocked) ALU
import definitions::*;			         // includes package "definitions"
module ALU(
  input        [7:0] InputA,             // data inputs
                     InputB,
  input        [3:0] OP,		         // ALU opcode, part of microcode
  output logic [7:0] Out,		         // or:  output reg [7:0] OUT,
  output logic       Zero                // output = zero flag
    );								    
	 
  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing
	
  always_comb begin
    Out = 0;                             // No Op = default
    if ( OP >= 4'b0000 and OP <= 4'b0001)
        Out = InputA + InputB;      // add
    else if ( OP >= 4'b1010 and OP <= 4'b1100)
        Out = InputA - InputB;      // subtraction
    else if( OP == 4'b0010 )
        Out = InputA ^ InputB;      // exclusive OR
    else if(  OP == 4'b0010 )
        Out = InputA & InputB;      // bitwise AND
    else if(  OP == 4'b0100 )
        Out = InputA << 1;  	     // shift left
    else if(  OP == 4'b1101 )
        Out = {1'b0, InputA[7:1]};  // shift right
    endcase
  end

  always_comb							  // assign Zero = !Out;
    case(Out)
      'b0     : Zero = 1'b1;
	  default : Zero = 1'b0;
    endcase

  always_comb
    op_mnemonic = op_mne'(OP);			 // displays operation name in waveform viewer

endmodule
