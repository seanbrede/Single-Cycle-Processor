// CSE141L
// possible lookup table for PC target
// leverage a few-bit pointer to a wider number
// Lookup table acts like a function: here Target = f(Addr);
//  in general, Output = f(Input); 
module LUT(
  input       [ 1:0] Addr,
  output logic[ 9:0] Target
  );

always_comb 
  case(Addr)		   //-16'd30;
	2'b00:   Target = 10'h3ff;  // -1
	2'b01:	 Target = 10'h003;
	2'b10:	 Target = 10'h007;
	default: Target = 10'h001;
  endcase

endmodule