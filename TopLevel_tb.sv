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

    //DUT.DM1.Core[11] = 8'b00001111;
    DUT.DM1.Core[54] = 8'b00001111;

	// students may also pre_load desired constants into DM
	// initialize DUT's register file
	for(int j=0; j<16; j++)
		DUT.RF1.Registers[j] = 8'b0;    // default -- clear it
	// students may pre-load desired constants into the reg_file

    DUT.RF1.Registers[6] = 8'b00000101; // pre-load register 6 with value 5
    $display("setting r6 value to 5");
    DUT.RF1.Registers[0] = 8'b00000011; // r1 = 3
    $display("setting r0 value to 3");
    DUT.RF1.Registers[1] = 8'b00001001;
    $display("setting r1 value to 9");
    DUT.RF1.Registers[5] = 8'b00001011;
    $display("setting r5 value to 11");

    DUT.RF1.Registers[10] = 8'b11110000;
    DUT.RF1.Registers[11] = 8'b00001111;

    //#1ns
    Req = 'b0;
    $display("Program Counter after init data mem and reg %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);

    $display("***************************************");
    $display("TEST 1:  ADD  r6(=5), r1(=9)  ");

    $display("ALU = %b ", DUT.ALU1.OP);
    $display("RF RaddrA = %d ", DUT.RF1.RaddrA);
    $display("RF RaddrB = %d ", DUT.RF1.RaddrB);

    // $display("RF1 DataOutA = %b ", DUT.RF1.DataOutA);
    // $display("RF1 DataOutB = %b ", DUT.RF1.DataOutB);

	#5ns
	$display("Program Counter after Test 1 %d ", DUT.PgmCtr);
    $display("DataOut A data = %d ", DUT.RF1.DataOutA);
    $display("DataOut B data = %d ", DUT.RF1.DataOutB);
    $display("ALU Input A data = %d ", DUT.ALU1.InputA);
    $display("ALU Input B data = %d ", DUT.ALU1.InputB);
    $display("ALU Output value = %d ", DUT.ALU1.Out);
    $display("R0 value before cycle completed: ", DUT.RF1.Registers[0]);
    $display("Curr instruction value %b ", DUT.Instruction);
    #5ns
    $display("R0 value after cycle: ", DUT.RF1.Registers[0]);

    assert(DUT.RF1.Registers[0] == 8'd14) begin
        $display("***************************************");
        $display("TEST 1 PASSED");
        $display("***************************************");
    end
    else $error("R0 is not the expected value!");
	// ############################################################################
	// Next test
    // ############################################################################

    #5ns // half cycle
	$display("TEST 2  MOVE  r15(=0), r0(=14)   ");
    $display("(Low to High)    after r15 =14   ");
    $display("OP = %b ", DUT.RF1.OP);
    $display("R15 has value: %d ", DUT.RF1.Registers[15]);

    #5ns // completed cycle
	// ############################################################################
	// Verify the register values were changed by examining them at next instruction!
    // ############################################################################
    assert(DUT.RF1.Registers[15] == 8'd14) begin
        $display("R15 has correct value");
        $display("***************************************");
        $display("TEST 2 PASSED ");
        $display("***************************************");
        $display("Program Counter after Test 2 %d ", DUT.PgmCtr);
        $display("instruction out %b ", DUT.Instruction);
    end
    else begin
        $display("TEST 2 Failed!");
    end

    $display("***************************************");
    $display("TEST 3 ");
    $display("***************************************");

    if ( DUT.ALU1.OP != 3'b100) begin
        $display("ALU operation was not shift left (100)");
        $display("ALU OP= %b ", DUT.ALU1.OP);
        #10ns $stop;
    end

    if ( DUT.ALU1.InputA != 8'b00001111) begin
        $display("ALU register A did not have value 00001111");
        $display("Input A data = %b ", DUT.ALU1.InputA);
        #10ns $stop;
    end

    if ( DUT.ALU_out != 8'b00011110) begin
        $display("ALU was not equal to 00011110");
        $display("ALU = %b ", DUT.ALU_out);
        #10ns $stop;
    end

	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################

    if ( DUT.RF1.Registers[0] != 8'b00011110) begin
        $display("DUT.RF1.Registers[0] was not equal to 00011110");
        $display("DUT.RF1.Registers[0] = %b ", DUT.RF1.Registers[0]);
        #10ns $stop;
    end

    $display("***************************************");
    $display("TEST 3 PASSED ");
    $display("***************************************");

    $display("***************************************");
    $display("TEST 4 Move High To Low ");
    $display("***************************************");
    if ( DUT.Instruction[8:5] != 4'b1000) begin
        $display("operation is not MOVE HIGH TO LOW");
        $display("OP= %b ", DUT.Instruction[8:5] );
        #10ns $stop;
    end

    if ( DUT.RF1.Registers[14] != 8'b00000000) begin
        $display("DUT.RF1.Registers[15] was not equal to 0");
        $display("DUT.RF1.Registers[015] = %b ", DUT.RF1.Registers[14]);
        #10ns $stop;
    end

	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################

    if ( DUT.RF1.Registers[0] != 8'b00000000) begin
        $display("DUT.RF1.Registers[0] was not equal to 0");
        $display("DUT.RF1.Registers[0] = %b ", DUT.RF1.Registers[0]);
        #10ns $stop;
    end

    $display("***************************************");
    $display("TEST 4 PASSED ");
    $display("***************************************");

    $display("***************************************");
    $display("TEST 5 JUMP ABSOLUTE EQUAL  ");
    $display("***************************************");

    if ( DUT.Instruction[8:5] != 4'b1010) begin
        $display("operation is not Jump Absolute");
        $display("OP= %b ", DUT.Instruction[8:5] );
        #10ns $stop;
    end

    if ( DUT.Instruction[4:0] != 5'b11001) begin
        $display("immediate was not 25");
        $display("immediate = %b ", DUT.Instruction[4:0] );
        #10ns $stop;
    end

    if ( DUT.r0IsZeroFlag != 1'b1) begin
        $display(" r0IsZeroFlag is Not 1 ");
        $display(" r0IsZeroFlag= %b ",  DUT.r0IsZeroFlag );
        #10ns $stop;
    end

     if ( DUT.Jump != 1'b1) begin
        $display("Jump Enable is not 1 ");
        $display("Jump Enable = %b ",  DUT.Jump);
        #10ns $stop;
    end

    if ( DUT.PgmCtr != 9'b000000101) begin
        $display("PC was not 5 ");
        $display("PC  = %b ",  DUT.PgmCtr);
        #10ns $stop;
    end

    if ( DUT.PCTarg != 9'b000001010) begin
        $display("PC TARGET was not 10");
        $display("PC TARGET = %b ",  DUT.PCTarg );
        #10ns $stop;
    end


    DUT.RF1.Registers[8] = 8'b00000111; // RD = 7

	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################

     if ( DUT.PgmCtr != 9'b000001010) begin
        $display("PC was not 10 ");
        $display("PC  = %b ",  DUT.PgmCtr);
        #10ns $stop;
    end

    $display("***************************************");
    $display("TEST 5 PASSED ");
    $display("***************************************");


    $display("***************************************");
    $display("TEST 6  RED XOR  ");
    $display("***************************************");

    if ( DUT.Instruction[8:5] != 4'b0001) begin
        $display("operation is not RED XOR  ");
        $display("OP= %b ", DUT.Instruction[8:5] );
        #10ns $stop;
    end

    if ( DUT.Instruction[4:1] != 4'b1000) begin
        $display("inst rd is not 8 ");
        $display("inst rd = %b ", DUT.Instruction[4:1] );
        #10ns $stop;
    end

    if ( DUT.Instruction[0:0] != 1'b0) begin
        $display("inst rs is not 0");
        $display("inst rs = %b ", DUT.Instruction[0:0] );
        #10ns $stop;
    end

    if ( DUT.ALU1.InputA != 8'b00000111) begin
        $display("ALU register A did not have value 7");
        $display("Input A data = %b ", DUT.ALU1.InputA);
        #10ns $stop;
    end

    if ( DUT.ALU1.OP != 4'b0001) begin
        $display("ALU operation was not RED XOR ");
        $display("ALU OP= %b ", DUT.ALU1.OP);
        #10ns $stop;
    end

    if ( DUT.ALU_out != 8'b00000001) begin
        $display("ALU was not equal to 1");
        $display("ALU = %b ", DUT.ALU_out);
        #10ns $stop;
    end

    DUT.RF1.Registers[1]  = 8'b11110000; // RS
    DUT.RF1.Registers[10] = 8'b00001111; // RD

	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################

    if ( DUT.RF1.Registers[0] != 8'b00000001) begin
        $display("DUT.RF1.Registers[0] was not equal to 1");
        $display("DUT.RF1.Registers[0] = %b ", DUT.RF1.Registers[0]);
        #10ns $stop;
    end

    $display("***************************************");
    $display("TEST 6 passed ");
    $display("***************************************");

    $display("***************************************");
    $display("TEST 7 SET LESS THAN ");
    $display("***************************************");

    if ( DUT.Instruction[8:5] != 4'b1011) begin
        $display("operation is not SET LESS THAN ");
        $display("OP= %b ", DUT.Instruction[8:5] );
        #10ns $stop;
    end

    if ( DUT.Instruction[4:1] != 4'b1010) begin
        $display("inst rd is not 10 ");
        $display("inst rd = %b ", DUT.Instruction[4:1] );
        #10ns $stop;
    end

    if ( DUT.Instruction[0:0] != 1'b1) begin
        $display("inst rs is not 1 ");
        $display("inst rs = %b ", DUT.Instruction[0:0] );
        #10ns $stop;
    end

    if ( DUT.ALU1.InputA != 8'b00001111) begin
        $display("ALU register A did not have value 15");
        $display("Input A data = %b ", DUT.ALU1.InputA);
        #10ns $stop;
    end

    if ( DUT.ALU1.InputB != 8'b11110000) begin
        $display("ALU register B did not have value 240");
        $display("Input B data = %b ", DUT.ALU1.InputB);
        #10ns $stop;
    end

    if ( DUT.ALU1.OP != 4'b1011) begin
        $display("ALU operation was not SLT (1011)");
        $display("ALU OP= %b ", DUT.ALU1.OP);
        #10ns $stop;
    end

    if ( DUT.ALU_out != 8'b00000000) begin
        $display("ALU was not equal to 0");
        $display("ALU = %b ", DUT.ALU_out);
        #10ns $stop;
    end

	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################

    if ( DUT.RF1.Registers[0] != 8'b00000000) begin
        $display("DUT.RF1.Registers[0] was not equal to 0");
        $display("DUT.RF1.Registers[0] = %b ", DUT.RF1.Registers[0]);
        #10ns $stop;
    end

    $display("***************************************");
    $display("TEST 7 PASSED ");
    $display("***************************************");

    // Do SEQ on 2 non-equal values and do JEQ Again
    $display("Testing JNEQ, where r0=8'd1");
    $display("We Expect PC to be unchanged since r0==1 means");










    $display("");
    $display("");
    $display("***************************************");
    $display("ALL TESTS PASSED ");
    $display("***************************************");

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