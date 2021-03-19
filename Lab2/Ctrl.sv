// CSE141L
import definitions::*;

// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
	input        [8:0] Instruction, // machine code instruction, 9 bits
	input   Clk,
	output logic		BranchEn,
	output logic		JumpEqEn,
	output logic		JumpNeqEn,
	output logic		MemWrite,
	output logic		RegWrite
	);

// jump on right shift that generates a zero
// always_comb
//   if(Instruction[8:5] ==  kRSH)
//     Jump = 1;
//   else
//     Jump = 0;

// branch every time ALU result LSB = 0 (even)
assign BranchEn = (Instruction[8:5] == 4'b1010); // if OP == JEQ, BranchEn == 1
assign JumpEqEn = (Instruction[8:5] == 4'b1010);   // if OP == JEQ, JumpEqEn == 1
assign JumpNeqEn = (Instruction[8:5] == 4'b1111); // if OP == JNEQ, JumpNeqEn == 1
assign MemWrite = (Instruction[8:5] == 4'b0111);  // mem_store command
                                       // STORE  instruction        // Jump Equal instruction
assign RegWrite = ( ((Instruction[8:5] == 4'b0111 || Instruction[8:5] == 4'b1010)  )  ? 'b0 : 'b1);  // mem_store command

// program counter can clear to 0, increment, or jump
//always_comb begin	            // or just always; always_ff is a linting construct
//	if(Reset)
//		ProgCtr <= 0;				         // for first program; want different value for 2nd or 3rd
//	else if(Start)						      // hold while start asserted; commence when released
//		ProgCtr <= ProgCtr;
//	else
//		ProgCtr <= ProgCtr+'b1; 	      // default increment (no need for ARM/MIPS +4 -- why?)
//end

endmodule
