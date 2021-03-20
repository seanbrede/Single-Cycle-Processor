// Create Date: 2018.04.05
// Design Name: BasicProcessor
// Module Name: TopLevel
// CSE141L
// partial only
module TopLevel (		  // you will have the same 3 ports
	input        Reset,   // init/reset, active high
			     Start,   // start next program
	               Clk,	  // clock -- posedge used inside design
	output logic Ack	  // done flag from DUT
	);

wire [9:0] PgmCtr, // program counter
		   PCTarg; // for jump

wire [8:0] Instruction;  // our 9-bit instruction
wire [7:0] ReadA, ReadB; // reg_file outputs
wire [7:0] InA, InB, 	 // ALU operand inputs
           ALU_out;      // ALU result

wire [7:0] RegWriteValue, // data in to reg file
           MemWriteValue, // data in to data_memory
	   	   MemReadValue,  // data out from data_memory
		   ImmReadValue; // data out of LUT_IMM

wire       MemWrite,	// data_memory write enable
		     RegWrEn,	// reg_file write enable
			    Zero,		// ALU output = 0 flag
           BranchEn,	// to program counter: branch enable
		   Jump,		// to program counter: jump 
           JumpEq,	   
		   JumpNeq,
		//    JumpEqEn,
		//    JumpNeqEn,
		   r0IsZeroFlag, 
		   LoadTableEn, 
		   LoadInst;

wire [7:0] r1Val;
wire [7:0] LoadValue;
		//    DataAddr;

logic [15:0] CycleCt; // standalone; NOT PC!
assign Ack = (Instruction[8:5] == 4'b1101);
assign InA = ReadA; // connect RF out to ALU in
assign InB = ReadB;

// assign LoadInst = (Instruction[8:5] == 4'b0110 || Instruction[8:5] == 4'b0101); // calls out load specially

// If instr is LOAD TABLE, write LUT_Imm value to r0, else write DataMem into r0 
assign LoadValue = LoadTableEn ? ImmReadValue : MemReadValue; 
// if its a Load instruction, take the Load Value (either from LUT_IMM or DM), if not, take ALU 
assign RegWriteValue = LoadInst ? LoadValue : ALU_out; 

// assign RegWriteValue = LoadInst ? MemReadValue : ALU_out; 

// if JumpEqual instr and r0 value is 0 (i.e. !JumpEq == 0)
// or if JumpNotEqual instr and r0 value is 0 (i.e. JumpNeq == 1)
// assign DataAddr = LoadInst ? RF1.Registers[ Instruction[3:0] ] : {3'b000, Instruction[4:0]};

// Instruction fetch
InstFetch InstFetch1 (
	.Reset       (Reset),
	.Start       (Start),    // SystemVerilg shorthand for .halt(halt),
	.Clk         (Clk),      // (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs   (Jump),     // jump enable
	.BranchRelEn (BranchEn), // branch anable
	.ALU_flag	 (Zero),	 // Zero flag, not in use (yet)
	.Target      (PCTarg),
	.ProgCtr     (PgmCtr)	 // program count = index to instruction memory
	);

// Control decoder
Ctrl Ctrl1 (
	.Instruction	(Instruction),	// from instr_ROM
	.Clk			(Clk),
	.r0IsZeroFlag	(r0IsZeroFlag),
	.BranchEn		(BranchEn),		// to PC
	.LoadInst		(LoadInst),
	.Jump			(Jump),
	// .JumpEqEn  		(JumpEqEn),		// JEQ instr detected
	// .JumpNeqEn		(JumpNeqEn),	// JNEQ instr detected
	.LoadTableEn	(LoadTableEn),
	.MemWrite    	(MemWrite),
	.RegWrite    	(RegWrEn)
	);

// Instruction ROM
InstROM #(.W(9)) InstROM1 (
	.InstAddress (PgmCtr),
	.InstOut     (Instruction)
	);

// Register file
RegFile #(.W(8),.D(4)) RF1 (
	.Clk,
	.WriteEn  		(RegWrEn),          // [OPCODE = 8765  | RaddrA = 4321 | RaddarB = 0 ]
	.RaddrA   		(Instruction[4:1]), //  RaddrA = 4321 bits of instruction
	.RaddrB   		(Instruction[0:0]), //  RaddarB = 0   bits of instruction
	//.Waddr    ( (Instruction[8:5] == 4'b1000 ) ? {3'b000, Instruction[0:0]} : Instruction[4:1] ), // if ( move high to low ) -> rs write reg else rd write reg
	.DataIn   		(RegWriteValue),
	.OP 			(Instruction[8:5]),
	.ALUzero		(Zero),
	.DataOutA 		(ReadA),
	.DataOutB 		(ReadB),
	.MemWriteValue 	(MemWriteValue),
	.r0IsZeroFlag	(r0IsZeroFlag),
	// .JumpNeq		(JumpNeq),
	.r1Val			(r1Val)
	);

// ALU
ALU ALU1 (
	.InputA (InA),
	.InputB (InB),
	// .InputA (ReadA),
	// .InputB (ReadB),
	.OP     (Instruction[8:5]), // grab entire opcode and send it into ALU
	.Out    (ALU_out),          // regWriteValue
	.Zero
	);

LUT_Imm LUT_IMM(
    .index     (Instruction[4:0]), // everything but the opcode 5 bit number [0-31]
    // .immediate (MemWriteValue)
    .immediate (ImmReadValue)
);

// We'll need to decide what index pertains to what instruction (addresses) 
// so that PCTarg points to the correct next instruction
// The default index points to random jibberish if none of the occupied indices
// are chosen by instruction bits [4:0]
LUT_Add LUT_ADD(
	.index		(Instruction[4:0]), 
	.address	(PCTarg)
);

// .DataAddress ( LoadInst ? RF1.Registers[Instruction[3:0]] : MemWriteValue ),

// Data memory
DataMem DM1 (
		// .DataAddress ( DataAddr ),
		.Clk         (Clk),
		.Reset		 (Reset),
		.WriteEn     (MemWrite),
		.DataAddress (MemWriteValue),
		.DataIn      (r1Val), // Note: DataIn is only used for STORE inst. so we can hard set value to r1
		.DataOut     (MemReadValue)
	);

// count number of instructions executed
always_ff @(posedge Clk)
	if (Start == 1)	 // if (start)
		CycleCt <= 0;
	else if (Ack == 0) // if (!halt)
		CycleCt <= CycleCt + 16'b1;

endmodule
