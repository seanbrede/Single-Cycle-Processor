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
	   	   MemReadValue;  // data out from data_memory

wire       MemWrite,	// data_memory write enable
		     RegWrEn,	// reg_file write enable
			    Zero,		// ALU output = 0 flag
          		Jump,	   // to program counter: jump  //TODO:: get rid of ??
           BranchEn,	// to program counter: branch enable
		   JumpImm, 
		   JumpInstr;

logic [15:0] CycleCt; // standalone; NOT PC!
assign Ack      = (Instruction[8:5] == 4'b1101);
assign InA = ReadA; // connect RF out to ALU in
assign InB = ReadB;

assign LoadInst = (Instruction[8:5] == 4'b0110 || Instruction[8:5] == 4'b0101); // calls out load specially
assign RegWriteValue = LoadInst ? MemReadValue : ALU_out; //
assign Jump = (JumpInstr && JumpRdy); // when OP == JEQ && r4 == 1 (JumpRdy)


// Instruction fetch
InstFetch InstFetch1 (
	.Reset       (Reset),
	.Start       (Start),    // SystemVerilg shorthand for .halt(halt),
	.Clk         (Clk),      // (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs   (Jump),     // jump enable
	.BranchRelEn (BranchEn), // branch enable
	.ALU_flag	 (Zero),	 // Zero flag, not in use (yet)
	.Target      (PCTarg),
	.ProgCtr     (PgmCtr)	 // program count = index to instruction memory
	);

// Control decoder
Ctrl Ctrl1 (
	.Instruction (Instruction), // from instr_ROM
	.Clk         (Clk),
	.BranchEn    (BranchEn),	 // to PC
	.JumpEnable 	 (JumpInstr),
	.MemWrite    (MemWrite),
	.RegWrite    (RegWrEn)
	);

// Instruction ROM
InstROM #(.W(9)) InstROM1 (
	.InstAddress (PgmCtr),
	.InstOut     (Instruction)
	);

// Register file
RegFile #(.W(8),.D(4)) RF1 (
	.Clk,
	.WriteEn  (RegWrEn),          // [OPCODE = 8765  | RaddrA = 4321 | RaddarB = 0 ]
	.RaddrA   (Instruction[4:1]), //  RaddrA = 4321 bits of instruction
	.RaddrB   (Instruction[0:0]), //  RaddarB = 0   bits of instruction
	//.Waddr    ( (Instruction[8:5] == 4'b1000 ) ? {3'b000, Instruction[0:0]} : Instruction[4:1] ), // if ( move high to low ) -> rs write reg else rd write reg
	.DataIn   (RegWriteValue),
	.DataOutA (ReadA),
	.DataOutB (ReadB),
	.MemWriteValue (MemWriteValue),
	.JumpRdy (JumpRdy),
	.OP (Instruction[8:5])
	);

// ALU
ALU ALU1 (
	.InputA (InA),
	.InputB (InB),
	.OP     (Instruction[8:5]), // grab entire opcode and send it into ALU
	.Out    (ALU_out),          // regWriteValue
	.Zero
	);

// Data memory
DataMem DM1 (
		.DataAddress ({3'b000, Instruction[4:0]}),
		.WriteEn     (MemWrite),
		.DataIn      (RF1.Registers[3]),
		.DataOut     (MemReadValue),
		.Clk         (Clk),
		.Reset		 (Reset)
	);

// count number of instructions executed
always_ff @(posedge Clk)
	if (Start == 1)	 // if (start)
		CycleCt <= 0;
	else if (Ack == 0) // if (!halt)
		CycleCt <= CycleCt + 16'b1;

endmodule
