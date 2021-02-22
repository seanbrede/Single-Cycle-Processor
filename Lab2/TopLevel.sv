// Create Date: 2018.04.05
// Design Name: BasicProcessor
// Module Name: TopLevel
// CSE141L
// partial only
module TopLevel (		  // you will have the same 3 ports
	input        Reset, // init/reset, active high
			       Start, // start next program
	             Clk,	  // clock -- posedge used inside design
	output logic Ack	  // done flag from DUT
	);

wire [9:0] PgmCtr, // program counter
			  PCTarg; // for jump

wire [8:0] Instruction;  // our 9-bit opcode
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
           BranchEn;	// to program counter: branch enable

logic [15:0] CycleCt; // standalone; NOT PC!

assign LoadInst = (Instruction[8:5] == 4'b0110); // calls out load specially
assign Ack      = &Instruction;                  // TODO:: what is the comparator

assign InA = ReadA; // connect RF out to ALU in
assign InB = ReadB;

assign RegWriteValue = LoadInst? MemReadValue : ALU_out; // 2:1 switch into reg_file

// Instruction fetch
InstFetch InstFetch1 (
	.Reset       (Reset),
	.Start       (Start),    // SystemVerilg shorthand for .halt(halt),
	.Clk         (Clk),      // (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs   (Jump),     // jump enable
	.BranchRelEn (BranchEn), // branch enable
	.ALU_flag	 (Zero),
	.Target      (PCTarg),
	.ProgCtr     (PgmCtr)	 // program count = index to instruction memory
	);

// Control decoder
Ctrl Ctrl1 (
	.Instruction (Instruction), // from instr_ROM
	.BranchEn    (BranchEn),	 // to PC
	.MemWrite    (MemWrite),
	.RegWrite    (RegWrEn)
	);

// Instruction ROM
InstROM #(.W(9)) InstROM1 (
	.InstAddress (PgmCtr),
	.InstOut     (Instruction)
	);

// Register file
RegFile #(.W(8),.D(4)) RegFile1 (
	.Clk,
	.WriteEn  (RegWrEn),
	.RaddrA   (Instruction[4:1]), //concatenate with 0 to give us 4 bits
	.RaddrB   (Instruction[0:0]),
	.Waddr    ( (Instruction[8:5] == 4'b1000 ) ? Instruction[0:0] : Instruction[4:1] ), // mux above
	.DataIn   (RegWriteValue),
	.DataOutA (ReadA),
	.DataOutB (ReadB)
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
DataMem DataMem1 (
		.DataAddress (ReadA),
		.WriteEn     (MemWrite),
		.DataIn      (MemWriteValue),
		.DataOut     (MemReadValue),
		.Clk,
		.Reset		 (Reset)
	);

// count number of instructions executed
always_ff @(posedge Clk)
	if (Start == 1)	 // if (start)
		CycleCt <= 0;
	else if (Ack == 0) // if (!halt)
		CycleCt <= CycleCt + 16'b1;

endmodule