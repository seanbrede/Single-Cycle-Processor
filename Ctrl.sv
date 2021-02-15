// CSE141L
import definitions::*;

// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
	input        [8:0] Instruction, // machine code instruction, 9 bits
	output logic       BranchEn,
	output logic       MemWrite,
	output logic       RegWrite
	);

// jump on right shift that generates a zero
// always_comb
//   if(Instruction[8:5] ==  kRSH)
//     Jump = 1;
//   else
//     Jump = 0;

// branch every time ALU result LSB = 0 (even)
assign BranchEn = (Instruction[8:5] == 4'b1010);
assign MemWrite = (Instruction[8:5] == 4'b0111);  // mem_store command
                  // ADD instruction              // Load instruction
assign RegWrite = ( ((Instruction[8:5] >= 4'b0000 & Instruction[8:5] <= 4'b0110) |
                    (Instruction[8:5] >= 4'b1000 & Instruction[8:5]  <= 4'b1001) |
                    (Instruction[8:5] >= 4'b1011 & Instruction[8:5]  <= 4'b1101)  )  ? 'b1 : 'b0);  // mem_store command

endmodule
