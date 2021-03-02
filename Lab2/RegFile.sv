// Create Date:    2017.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

/* parameters are compile time directives 
 * this can be an any-size reg_file: just override the params!
 */
module RegFile #(parameter W=8, D=4) (		  // W = data path width; D = pointer width
	input                Clk,
                        WriteEn,
	input        [D-1:0] RaddrA,		      // address pointers
    input                RaddrB,
    //input        [D-1:0]  Waddr,
	input        [W-1:0] DataIn,
	output       [W-1:0] DataOutA,			  // showing two different ways to handle DataOutX, for
	output logic [W-1:0] DataOutB,		      // pedagogic reasons only
	input        [3:0] OP            		// ALU opcode, part of microcode
);

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	  // or just Registers[16] if we know D=4 always

/* combinational reads 
 * can write always_comb in place of assign
 * difference: assign is limited to one line of code, so
 * always_comb is much more versatile     
 */
assign      DataOutA = Registers[RaddrA];	// can't read from addr 0, just like MIPS
always_comb DataOutB = Registers[RaddrB];  // can read from addr 0, just like ARM

// sequential (clocked) writes 
always_ff @ (posedge Clk)
	if (WriteEn) begin // works just like data_memory writes
	    // acts like MUX to decide which register we are writing to
	    // if SLT or SEQ  write into R4
	    if( OP == 4'b1011 || OP == 4'b1011 )
		    Registers[4] <= DataIn;  // R4 = ALU_OUTPUT
		else if ( OP == 4'b0101 || OP == 4'b0110 )// if LOAD TABLE or LOAD
		    Registers[2] <= DataIn;//   write into R2
		else if ( OP == 4'b1000 ) // if Move High to Low (  R[rs] = R[rd] )
		    Registers[RaddrB] <=  Registers[RaddrA]; // write into RS
		else if ( OP == 4'b1001 ) // if Move LOW to HIGH (  R[rd] = R[rs] )
		    Registers[RaddrA] <=  Registers[RaddrB]; // write into RD the higher register
		else
		    Registers[RaddrA] <=  DataIn; // otherwise, write into RD
    end
endmodule
