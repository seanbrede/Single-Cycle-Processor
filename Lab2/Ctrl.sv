// CSE141L
import definitions::*;

// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
	input         [8:0] Instruction, // machine code instruction, 9 bits
	input   			Clk,
	input				r0IsZeroFlag,
	output logic		BranchEn,
	output logic		LoadInst,
	// output logic		JumpEqEn,
	// output logic		JumpNeqEn,
	output logic		LoadTableEn,
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
// assign JumpEqEn = (Instruction[8:5] == 4'b1010);   // if OP == JEQ, JumpEqEn == 1
// assign JumpNeqEn = (Instruction[8:5] == 4'b1111); // if OP == JNEQ, JumpNeqEn == 1
assign MemWrite = (Instruction[8:5] == 4'b0111);  // mem_store command
// don't write to reg when:   // STORE  instruction        // Jump Equal instr	   // Jump Not Equal Instr
assign RegWrite = ((Instruction[8:5] == 4'b0111 || Instruction[8:5] == 4'b1010 || Instruction[8:5] == 4'b1111) ? 1'b0 : 1'b1);  // mem_store command
// If instruction is a Load (LOAD TABLE or LOAD)
assign LoadInst = (Instruction[8:5] == 4'b0110 || Instruction[8:5] == 4'b0101); // calls out load specially
// If instruction is LOAD TABLE select ImmReadValue in TopLevel
assign LoadTableEn = (Instruction[8:5] == 4'b0101); // Checks if LOAD TABLE called, else defaults to LOAD (DataMem)

// assign Jump = (JumpEqEn && JumpEq==0) || (JumpNeqEn && JumpNeq); // when OP == JEQ && r4 == 1 (JumpRdy)
// If the instruction is either JEQ or JNEQ, and r0 == 0, send JUMP signal to instr-fetch to JUMP
assign Jump = ( ( (Instruction[8:5] == 4'b1010) || (Instruction[8:5] == 4'b1111) )  && r0IsZeroFlag) ? 1'b1 : 1'b0 ;
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
