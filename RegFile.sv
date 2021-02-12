// Create Date:    2017.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/
module RegFile #(parameter W=8, D=4) (		  // W = data path width; D = pointer width
	input                Clk,
                        WriteEn,
	input        [D-1:0] RaddrA,				  // address pointers
                        RaddrB,
                        Waddr,
	input        [W-1:0] DataIn,
	output       [W-1:0] DataOutA,			  // showing two different ways to handle DataOutX, for
	output logic [W-1:0] DataOutB				  // pedagogic reasons only
);

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	  // or just Registers[16] if we know D=4 always

// combinational reads 
/* can write always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign      DataOutA = Registers[RaddrA];	  // can't read from addr 0, just like MIPS
always_comb DataOutB = Registers[RaddrB];    // can read from addr 0, just like ARM

// sequential (clocked) writes 
always_ff @ (posedge Clk)
	if (WriteEn)	                             // works just like data_memory writes
		Registers[Waddr] <= DataIn;

endmodule
