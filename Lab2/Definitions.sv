//This file defines the parameters used in the alu
// CSE141L
package definitions;

// Instruction map
const logic [3:0] kADD   = 4'b0000;
const logic [3:0] kRXOR = 4'b0001;
const logic [3:0] kXOR   = 4'b0010;
const logic [3:0] kAND   = 4'b0011;
const logic [3:0] kRSH   = 4'b0100;
							// 4'b0101
							// 4'b0110
							// 4'b0111
							// 4'b1000
							// 4'b1001
const logic [3:0] JEQ	 = 4'b1010;
const logic [3:0] SLT	 = 4'b1011;
const logic [3:0] SEQ	 = 4'b1100;
							// 4'b1101
							// 4'b1110
							// 4'b1111
const logic [3:0] kACK   = 4'b1101;
// const logic [2:0]kCLR  = 3'b110;;

// enum names will appear in timing diagram
	typedef enum logic [3:0] {
		k_ADD, kR_XOR, k_XOR, k_AND, k_RSH, 
		BLANK_1, BLANK_2, BLANK_3, BLANK_4, BLANK_5, 
		K_JEQ, k_SLT, k_SEQ, k_ACK, BLANK_6, BLANK_7
	} op_mne;
   // CLR might need to be added

// note: kADD is of type logic[2:0] (3-bit binary)
// ADD is of type enum -- equiv., but watch casting
// see ALU.sv for how to handle this
endpackage // definitions
