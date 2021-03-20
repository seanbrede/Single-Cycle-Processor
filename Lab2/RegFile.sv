// Create Date:    2017.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

// import definitions
import definitions::*; // includes package "definitions"

/* parameters are compile time directives 
 * this can be an any-size reg_file: just override the params!
 */
module RegFile #(parameter W=8, D=4) (		  // W = data path width; D = pointer width
	input                   Clk,
                        WriteEn,
	input        [D-1:0] RaddrA,		      // address pointers
    input                RaddrB,
	input		 		 ALUzero, 			// takes the zero flag from ALU, sets SLT && SEQ
	input        [W-1:0] DataIn,
	input          [3:0] OP,            		// ALU opcode, part of microcode
	output       [W-1:0] DataOutA,			  // showing two different ways to handle DataOutX, for
	output 		 [W-1:0] DataOutB,		      // pedagogic reasons only
	output       [W-1:0] MemWriteValue,
	output		 		 r0IsZeroFlag,
	output		 [W-1:0] r1Val
);

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	  // or just Registers[16] if we know D=4 always

/* combinational reads 
 * can write always_comb in place of assign
 * difference: assign is limited to one line of code, so
 * always_comb is much more versatile     
 */
// assign      DataOutA = Registers[RaddrA];	// can't read from addr 0, just like MIPS
// assign		DataOutB = Registers[RaddrB];  // can read from addr 0, just like ARM
assign      DataOutA = Registers[RaddrA];	// can't read from addr 0, just like MIPS
assign		DataOutB = Registers[RaddrB];  // can read from addr 0, just like ARM
assign		r0IsZeroFlag = ( Registers[0] == 0 ) ? 1'b1 : 1'b0;
assign		r1Val = Registers[1];
assign		MemWriteValue = Registers[{RaddrA[2:0], RaddrB}]; // R[rd], for store, MEM[R[rd]]
// assign		Registers[0] = ALUzero;

// sequential (clocked) writes 
always_ff @ (posedge Clk)
	if (WriteEn) begin // works just like data_memory writes

	    // if SLT or SEQ,  write into R0
	    if( OP == SLT || OP == SEQ ) 
		    Registers[0] <= DataIn;  // R4 = ALU_OUTPUT
		// Standard ALU operations write into R0
		else if (OP == kADD || OP == kR_XOR || OP == kXOR || OP == kAND || OP == kLSH || OP == kOR) // all ALU operations store into R0
		    Registers[0] <= DataIn;
		else if ( OP == LDT || OP == LOD )// if LOAD TABLE or LOAD
		    Registers[1] <= DataIn;	//   R1 = ALU_OUTPUT
		else if ( OP == MVH ) 	// if Move High to Low (  R[rs] = R[rd] )
		    Registers[RaddrB] <=  Registers[RaddrA]; // write into RS
		else if ( OP == MVL ) begin // if Move LOW to HIGH (  R[rd] = R[rs] )
		    Registers[RaddrA] <=  Registers[RaddrB]; // write into RD the higher register
		end
		else
		    Registers[RaddrA] <=  DataIn; // otherwise, write into RD
    end
endmodule
