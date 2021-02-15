//This file defines the parameters used in the alu
// CSE141L
package definitions;

// Instruction map
  const logic [3:0]kADD  = 4'b0000;
  const logic [3:0]kXOR  = 4'b0010;
  const logic [3:0]kAND  = 4'b0011;
  const logic [3:0]kLSH  = 4'b0100;
  const logic [3:0]kRSH  = 4'b1101;
	// const logic [2:0]kCLR  = 3'b110;

// enum names will appear in timing diagram
    typedef enum logic[3:0] {
        ADD, XOR, AND, LSH, RSH } op_mne;
        // CLR might need to be added

// note: kADD is of type logic[2:0] (3-bit binary)
//   ADD is of type enum -- equiv., but watch casting
//   see ALU.sv for how to handle this
endpackage // definitions
