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
	output logic		Jump,
	output logic		LoadTableEn,
	output logic		MemWrite,
	output logic		RegWrite
	);


assign BranchEn = (Instruction[8:5] == 4'b1010); // if OP == JEQ, BranchEn == 1
assign MemWrite = (Instruction[8:5] == 4'b0111);  // mem_store command
// don't write to reg when:   // STORE  instruction        // Jump Equal instr	   // Jump Not Equal Instr
assign RegWrite = ((Instruction[8:5] == 4'b0111 || Instruction[8:5] == 4'b1010 || Instruction[8:5] == 4'b1111) ? 1'b0 : 1'b1);  // mem_store command
// If instruction is a Load (LOAD TABLE or LOAD)
assign LoadInst = (Instruction[8:5] == 4'b0110 || Instruction[8:5] == 4'b0101); // calls out load specially
// If instruction is LOAD TABLE select ImmReadValue in TopLevel
assign LoadTableEn = (Instruction[8:5] == 4'b0101); // Checks if LOAD TABLE called, else defaults to LOAD (DataMem)
// to Jump, either: (instr is JEQ && r0 == 0 i.e SEQ was true) or (instr is JNEQ && r0 == 1 i.e SEQ was false which sets r0=1)
assign Jump = ( ((Instruction[8:5] == 4'b1010) && r0IsZeroFlag) || ((Instruction[8:5] == 4'b1111) && !r0IsZeroFlag) ) ? 1'b1 : 1'b0 ;

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
