// Create Date:   2017.01.25
// Design Name:   TopLevel Test Bench
// Module Name:   TopLevel_tb.v
// CSE141L
// This is NOT synthesizable; use for logic simulation only
// Verilog Test Fixture created for module: TopLevel

module TopLevel_tb; // Lab 17

// to DUT inputs
bit Init = 'b1,
    Req,
    Clk;

// from DUT outputs
wire Ack; // flag to display output from memory

// instantiate the Device Under Test (DUT)
TopLevel DUT (
	.Reset (Init),
	.Start (Req),
	.Clk   (Clk),
	.Ack   (Ack)
	);

initial begin
	#10ns Init = 'b0;
	#10ns Req  = 'b1;
    $display("Program Started");
    $display("Program Counter at start %b ", DUT.PgmCtr);
	// initialize DUT's data memory
	#10ns for (int i=0; i<256; i++) begin
		DUT.DM1.Core[i] = 8'h0;	     // clear data_mem
		DUT.DM1.Core[1] = 8'h03;      // MSW of operand A
		DUT.DM1.Core[2] = 8'hff;
		DUT.DM1.Core[3] = 8'hff;      // MSW of operand B
		DUT.DM1.Core[4] = 8'hfb;
	end

	// students may also pre_load desired constants into DM
	// initialize DUT's register file
	for(int j=0; j<16; j++)
		DUT.RF1.Registers[j] = 8'b0;    // default -- clear it
	// students may pre-load desired constants into the reg_file

    DUT.RF1.Registers[6] = 8'b00000101; // pre-load register 6 with value 5
    DUT.RF1.Registers[1] = 8'b00000011; // r1 = 3
    #1ns
    $display("Program Counter after init data mem and reg %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);

    $display("RaddrA = %b ", DUT.RF1.RaddrA);
    $display("RaddrB = %b ", DUT.RF1.RaddrB);

    $display("InA = %b ", DUT.ALU1.InputA);
    $display("INB = %b ", DUT.ALU1.InputB);
    $display("OP  = %b ", DUT.ALU1.OP);

    if ( DUT.ALU_out != 8'b00001000) begin // out = 8
        $display("ALU was not equal to 8");
        #10ns;
        $display("ALU = %b ", DUT.ALU_out);
        #10ns $stop;
    end

    $display("ALU test passed ");
    $display("ALU = %b ", DUT.ALU_out);
	// launch prodvgram in DUT
	#10ns Req = 0;
	// Wait for done flag, then display results
	wait (Ack);
	#10ns $displayh(DUT.DM1.Core[5],
                   DUT.DM1.Core[6],
						 "_",
                   DUT.DM1.Core[7],
                   DUT.DM1.Core[8]);
	//$display("instruction = %d %t",DUT.PC,$time);
	$display("program ended");
	#10ns $stop;
end

always begin // clock period = 10 Verilog time units
	#5ns  Clk = 'b1;
	#5ns  Clk = 'b0;
end

endmodule
