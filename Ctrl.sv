// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0] Instruction,	   // machine code
  output logic BranchEn
  );
  
// jump on right shift that generates a zero
// always_comb
//   if(Instruction[8:5] ==  kRSH)
//     Jump = 1;
//   else
//     Jump = 0;

// branch every time ALU result LSB = 0 (even)
assign BranchEn = (Instruction[8:5] == 4'1010);

endmodule
