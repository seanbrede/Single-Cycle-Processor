import definitions::*; // includes package "definitions"
// Testbench of ALU: 
/*
 * Takes in InputA (8'b)
 * and InputB 
 */ 
module ALU_tb();
    reg [7:0] InputA;
    reg [7:0] InputB;
    reg [3:0] OP;
    wire [7:0] Out;
    wire Zero;

    ALU testingALU (
        .InputA(InputA), 
        .InputB(InputB),
        .OP(OP),
        .Out(Out),
        .Zero(Zero)
    );

    initial begin 
        #30ns
        // test add 
        // Out = 11
        assign InputA = 10;
        assign InputB = 1;
        assign OP = kADD;
        #30ns   
        // test reduc XOR
        // expected Out = 0
        assign InputA = 10;
        assign InputB = 10; 
        assign OP = kRXOR;
        #30ns   
        assign InputA = 2;
        assign OP = kXOR;
        // expected Out = 1
        #30ns
        // test bitwise XOR 
        assign InputA = 10;
        assign InputB = 10;
        assign OP = kXOR; 
        #30ns;
        // expected Out = 0

        // test bitwise AND 
        // Out = 10 
        assign OP = kAND; 
        #30ns   
        // test right shift
        // Out = 1
        assign InputA = 2; 
        assign InputB = 0;  
        assign OP = kLSH; 
        #30ns   
        // test SEQ 
        // Out = 1, 
        assign InputA = 4; 
        assign InputB = 4;
        assign OP = SEQ; 
        #30ns;
        // test SLT when rs (inputA) > rd (inputB)
        // Out = 1 
        assign InputA = 10;
        assign InputB = 5;
        assign OP = SLT;

        // test SLT when rd (inputB) > rs (inputA)
        // Out = 0
        #30ns;
        assign InputA = 5;
        assign InputB = 10;

        // remaining test JEQ and kACK
        // test  JEQ 
        #30ns;
        // assign InputA = 
        // assign InputB 

        #30ns $stop;
    end 

endmodule