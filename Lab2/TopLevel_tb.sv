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
    DUT.RF1.Registers[1] = 8'b00000011; // r1 = 3
    $display("setting r1 value to 3");
    DUT.RF1.Registers[3] = 8'b00001001;
    $display("setting r3 value to 9");
    DUT.RF1.Registers[5] = 8'b00001011;
    $display("setting r5 value to 11");


    //#1ns
    Req = 'b0;
    $display("Program Counter after init data mem and reg %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);

    $display("***************************************");
    $display("TEST 1:  ADD  r6(=5), r1(=3)  ");

    if ( DUT.ALU1.InputA != 8'b00000101) begin
        $display("ALU register A did not have value 5");
        $display("Input A data = %b ", DUT.ALU1.InputA);
        #10ns $stop;
    end

    if ( DUT.ALU1.InputB != 8'b00000011) begin
        $display("ALU register B did not have value 3");
        $display("Input B data = %b ", DUT.ALU1.InputB);
        #10ns $stop;
    end

    if ( DUT.ALU1.OP != 3'b000) begin
        $display("ALU operation was not add (000_");
        $display("ALU OP= %b ", DUT.ALU1.OP);
        #10ns $stop;
    end

    if ( DUT.ALU1.OP != 3'b000) begin
        $display("ALU operation was not add (000_");
        $display("ALU OP= %b ", DUT.ALU1.OP);
        #10ns $stop;
    end

    if ( DUT.ALU_out != 8'b00001000) begin // if out != 8
        $display("ALU was not equal to 8");
        $display("ALU = %b ", DUT.ALU_out);
        #10ns $stop;
    end

    $display("TEST 1 PASSED ");



    $display("***************************************");
	// ############################################################################
	// Increment To next test
	#10ns
    // ############################################################################
	$display("Program Counter after Test 1 %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);
	$display("***************************************");



	$display("TEST 2  MOVE  r15(=0), r1(=3)   ");
    $display("(Low to High)    after r15 =3   ");

    if ( DUT.RF1.RaddrA  != 4'b1111) begin
        $display("Reg addr A should be reg 15");
        $display("addr A val = %b ", DUT.RF1.RaddrA );
        #10ns $stop;
    end

    if ( DUT.RF1.RaddrB  != 1'b1) begin
        $display("Reg addr B  should b 1");
        $display("addr B val = %b ", DUT.RF1.RaddrB);
        #10ns $stop;
    end

    if ( DUT.RF1.OP != 4'b1001) begin
        $display("RF1 operation was not Move Low To High (1001)");
        $display("OP= %b ", DUT.RF1.OP);
        #10ns $stop;
    end

	// ############################################################################
	#10ns // Verify the register values were changed by examining them at next instruction!
    // ############################################################################

     if (  DUT.RF1.Registers[15]  != 8'b00000011) begin
        $display("Reg File:  DataOutA (R15) should be 3");
        $display(" actual DataOutA= %b ", DUT.RF1.Registers[15]);
        #10ns $stop;
    end

    if (  DUT.RF1.Registers[1] != 8'b00000011) begin
        $display("Reg File:  DataOutB (R1) should be ALSO be 3");
        $display(" actual DataOutB= %b ", DUT.RF1.Registers[1]);
        #10ns $stop;
    end
    $display("TEST 2 PASSED ");
    $display("***************************************");


    $display("Program Counter after Test 2 %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);


	$display("***************************************");
    $display("TEST 3:  STORE  MEM[ LUT [ rd ]  ] = r3  ");
    $display("  rd=7 , r3=9     where  MEM[ 61 ]  = 9  ");

    if (  DUT.Instruction[8:5]  != 4'b0111) begin
        $display(" Opcode != store{0111} ");
        $display(" Opcode =  %b ", DUT.Instruction[8:5]  );
        #10ns $stop;
    end

    if (  DUT.RF1.Registers[3] != 8'b00001001) begin
        $display("Reg File:  R3 value != 9 ");
        $display(" r3 value = %b ", DUT.RF1.Registers[3]  );
        #10ns $stop;
    end

    if (  DUT.DM1.WriteEn != 1'b1) begin
        $display("WriteEnable is NOT enabled. Will not allow data to be written");
        #10ns $stop;
    end

    if (  DUT.DM1.DataIn != 8'b00001001) begin
        $display("DataIn is NOT 9.  Mem[..] = 9 is the goal.  ");
        $display(" DataIn = %b ", DUT.DM1.DataIn  );
        #10ns $stop;
    end


    if (  DUT.Instruction[4:0]  != 4'b00111) begin
        $display(" rd != 7 ");
        $display(" rd =  %b ", DUT.Instruction[8:5]  );
        #10ns $stop;
    end


    if (  DUT.DM1.DataAddress != 8'b00111101) begin
        $display(" not writing into MEM[61] ");
        $display("  ( MEM [DataAddress] ) where DataAddress = %b ", DUT.DM1.DataAddress   );
        #10ns $stop;
    end

	// ############################################################################
	#10ns // Verify the register values were changed by examining them at next instruction!
    // ############################################################################


    if (  DUT.DM1.Core[61] != 8'b00001001) begin
        $display(" MEM[61] != 9 ");
        $display(" MEM[61] =  %b ", DUT.DM1.Core[61] );
        #10ns $stop;
    end

    $display("TEST 3 PASSED ");
    $display("***************************************");



    $display("Program Counter after Test 3 %b ", DUT.PgmCtr);
    $display("instruction out %b ", DUT.Instruction);


	$display("***************************************");
    $display("TEST 4:  LOAD  r2 =  MEM[ LUT[rd] ]  ");
    $display(" where,  rd=6,  LUT[6]=54,  MEM[54]=15 ");
    $display("  so r2 = 15 after load  ");

    if (  DUT.Instruction[8:5]  != 4'b0110) begin
        $display(" Opcode != Load{0110} ");
        $display(" Opcode =  %b ", DUT.Instruction[8:5]  );
        #10ns $stop;
    end

    if (  DUT.Instruction[4:0]  != 4'b00110) begin
        $display(" rd != 6 ");
        $display(" rd =  %b ", DUT.Instruction[8:5]  );
        #10ns $stop;
    end

    if (  DUT.DM1.Core[54]  != 8'b00001111) begin
        $display("  MEM[54] != 15   ");
        $display("  DUT.DM1.Core[54] =  %b ",  DUT.DM1.Core[11]  );
        #10ns $stop;
    end

    if (  DUT.MemReadValue  != 8'b00001111) begin
        $display("  MemReadValue != 15   ");
        $display(" MemReadValue =  %b ",  DUT.MemReadValue  );
        #10ns $stop;
    end

    if (  DUT.RegWriteValue  != 8'b00001111) begin
        $display("  RegWriteValue != 15   ");
        $display("  RegWriteValue =  %b ",  DUT.MemReadValue  );
        #10ns $stop;
    end

	// ############################################################################
	#10ns // Verify the register values were changed by examining them at next instruction!
    // ############################################################################

    if (  DUT.RF1.Registers[2]  != 8'b00001111) begin
        $display("  r2 value != 15   ");
        $display("  r2 value  =  %b ",  DUT.RF1.Registers[2] );
        #10ns $stop;
    end

    $display("TEST 4 PASSED ");
    $display("***************************************");


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
