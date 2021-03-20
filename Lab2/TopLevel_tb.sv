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
    DUT.DM1.Core[54] = 8'd15;

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
    DUT.RF1.Registers[4] = 8'd7;
    $display("setting r4 value to 7");

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
	// ############################################################################
	// test 3 STORE
    // ############################################################################
	$display("***************************************");
    $display("TEST 3:  STORE  MEM[ LUT [ rd ]  ] = r1  ");
    $display("  Rd=7 , r1=9     where  MEM[ LUT_Imm[7] ] = 9 is MEM[61] = 9  ");

    #5ns // half cycle
    assert(DUT.Instruction[8:5]  == 4'b0111) 
    else begin 
        $display("Expected Opcode is not STORE");
        $display("Opcode is %b ", DUT.Instruction[8:5]  );
    end

    assert(DUT.DM1.WriteEn == 1'b1)
    else $display("WriteEnable is NOT enabled. Will not allow data to be written");

    assert(DUT.DM1.DataIn == 8'd9) 
    else begin
        $display("Expected DM.DataIn != 9");
        $display(" DataIn is %b ", DUT.DM1.DataIn);
    end


    if (  DUT.Instruction[4:0]  != 4'b00111) begin
        $display(" rd != 7 ");
        $display(" rd =  %b ", DUT.Instruction[8:5]  );
    end


    assert(DUT.DM1.DataAddress == 8'd61) begin
        $display("Success, accessing MEM[61] where DataAddress = %d ", DUT.DM1.DataAddress);
    end
    else begin
        $display("Error: not writing into MEM[61] ");
    end

	// ############################################################################
	// Verify the register values were changed 
    // ############################################################################

    $display(" MEM[61] =  %d ", DUT.DM1.Core[61] );
    $display(" Instruction =  %b ", DUT.Instruction);
    $display(" LUT immediate value =  %d ", DUT.LUT_IMM.immediate);
    $display(" MemWriteValue =  %d ", DUT.RF1.MemWriteValue);
    // $display(" rd =  %d ", DUT.RF1.DataIn);
    $display(" DataMem[7] value: %d", DUT.MemWrite);
    $display(" DM.DataIn value: %d", DUT.DM1.DataIn);
    $display(" DM.WriteEn value: %d", DUT.DM1.WriteEn);
    $display(" DM.DataAddress value: %d", DUT.DM1.DataAddress);
    $display(" DataMem[7] value before rising edge: %d", DUT.DM1.Core[7]);
    #5ns // completed cycle

    assert(DUT.DM1.Core[7] == 8'd9) begin
    // assert(DUT.RF1.Registers[1] == 8'd61) begin
        $display(" MEM[7] has the right value stored! ");
        $display(" MEM[7] =  %d ", DUT.DM1.Core[61] );
        $display("***************************************");
        $display("TEST 3 PASSED ");
        $display("***************************************");        
        $display("Program Counter after Test 3 %b ", DUT.PgmCtr);
        $display("instruction out %b ", DUT.Instruction);
    end
    else $display("MEM[7] is not the expected value of 9!");

	// ############################################################################
	// Next test 4: LDT 6
    // ###########################################################################

    $display("TEST 4:  LDT 6  : R[r1] =  LUT_IMM[6] ");
    // $display(" where,  rd=6,  LUT[6]=54,  MEM[54]=15 ");
    $display("  so r1 = 54 after load  ");

    $display(" Opcode =  %b ", DUT.Instruction);
    if (  DUT.Instruction[8:5]  != 4'b0101) begin
        $display(" Opcode != Load{0101} ");
        $display(" Opcode =  %b ", DUT.Instruction[8:5]  );
        #10ns $stop;
    end

    // if (  DUT.Instruction[4:0]  != 4'b00110) begin
    //     $display(" rd != 6 ");
    //     $display(" rd =  %b ", DUT.Instruction[8:5]  );
    //     #10ns $stop;
    // end

    // if (  DUT.DM1.Core[54]  != 8'b00001111) begin
    //     $display("  MEM[54] != 15   ");
    //     $display("  DUT.DM1.Core[54] =  %b ",  DUT.DM1.Core[11]  );
    //     #10ns $stop;
    // end

    // if (  DUT.MemReadValue  != 8'b00001111) begin
    //     $display("  MemReadValue != 15   ");
    //     $display(" MemReadValue =  %b ",  DUT.MemReadValue  );
    //     #10ns $stop;
    // end

    // if (  DUT.RegWriteValue  != 8'b00001111) begin
    //     $display("  RegWriteValue != 15   ");
    //     $display("  RegWriteValue =  %b ",  DUT.MemReadValue  );
    //     #10ns $stop;
    // end
    #5ns
    assert(DUT.LUT_IMM.immediate == 8'd54) begin
        $display("LUT Immediate value is correct");
    end 
    else $display("LUT Immediate value is wrong!");

    assert(DUT.RF1.DataIn == 54) begin
        $display("RegFile DataIn value is correct");
    end
    else $display("RF1 DataIn value is wrong!");

    assert(DUT.RF1.Registers[1] == 8'd9)
    else begin
        $display("r1 should be 9, before rising edge changes it to 54");
    end
	// ############################################################################
	// Verify the register values were changed by examining them at next instruction!
    // ############################################################################
    #5ns // Cycle Complete
    assert(DUT.RF1.Registers[1] == 8'd54) begin
        $display("r1 is the right value!");        
        $display("Program Counter after Test 4 %b ", DUT.PgmCtr);
        $display("instruction out %b ", DUT.Instruction);
        $display("***************************************");
        $display("TEST 4 PASSED ");
        $display("***************************************");
    end
    else begin
        $display("expected r1 to be 54, but it is %d instead", DUT.RF1.Registers[1]);
    end

    // ############################################################################
	// Next test 5 LOD r1
    // ###########################################################################
    #5ns // Half cycle

    assert(DUT.DM1.DataOut == 8'd15) begin
        $display("DataMem DataOut value is correct! value: %d", DUT.DM1.DataOut);
    end
    else begin
        $display("Expected DataMem DataOut value to be 15, but its: %d", DUT.DM1.DataOut);
    end
    #5ns // Complete cycle
    assert(DUT.RF1.Registers[1] == 8'd15) begin
        $display("r1 is the right value!");        
        $display("Program Counter after Test 5 %b ", DUT.PgmCtr);
        $display("instruction out %b ", DUT.Instruction);
        $display("***************************************");
        $display("TEST 5 PASSED ");
        $display("***************************************");
    end
    else begin
        $display("expected r1 to be 15, but it is %d instead", DUT.RF1.Registers[1]);
    end

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
