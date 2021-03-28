// program2_tb
// testbench for programmable message decryption (Program #2)
// CSE141L  
// runs program 2 (decrypt a message)
module decrypt_tb;

  bit      Clk   = 'b1   ,      // advances simulation step-by-step
           Init  = 'b1   ,      // init (reset) command to DUT
           Req   = 'b1   ;      // req (start program) command to DUT

  wire       Ack           ;      // done flag returned by DUT
  logic[3:0] pre_length     ;      // space char. bytes before first char. in message  
  logic[7:0] message1[54]   ,      // original raw message, in binary
             msg_padded1[64],      // original message, plus pre- and post-padding w/ ASCII spaces
             msg_crypto1[64];      // encrypted message according to the DUT
  logic[6:0] lfsr_ptrn      ,      // index of chosen one of 9 maximal length 7-tap shift reg. ptrns
             LFSR_ptrn[9]   ,      // the 9 candidate maximal-length 7-bit LFSR tap ptrns
             lfsr1[64]      ,      // states of program 1 encrypting LFSR
             LFSR_init      ;      // one of 127 possible NONZERO starting states
  int        score          ;      // count of correct encyrpted characters

 logic[6:0] dummy;

// our original American Standard Code for Information Interchange message follows
// note in practice your design should be able to handle ANY ASCII string that is
//  restricted to characters between space (0x20) and script f (0x9f) and shorter than 
//  53 characters in length
  //string     str1  = "Mr. Watson, come here. I want to see you.";     // sample program 1 input
   //string       str1  = "qwertyuiopasdfghjklzxcvbnm";
   string       str1  = "  Two  spaces  in  between  ,  2  . ";
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // alternative inputs
//  string     str1  = "  01234546789abcdefghijklmnopqrstuvwxyz. ";   //   (make up your own,
//  string     str1  = "  f       A joke is a very serious thing.";   // 	as well)
//  string     str1  = "                           Ajok          ";   // 
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // 

// displayed encrypted string will go here:
  string     str_enc1[64];            // program 1 desired output will go here
  int strlen;                         // incoming string length 
  int pt_no;                          // select LFSR pattern, value 0 through 8
  int file_no;                        // write to file
// the 8 possible maximal-length feedback tap patterns from which to choose
  assign LFSR_ptrn[0] = 7'h60;	       // 110_0000  
  assign LFSR_ptrn[1] = 7'h48;
  assign LFSR_ptrn[2] = 7'h78;
  assign LFSR_ptrn[3] = 7'h72;
  assign LFSR_ptrn[4] = 7'h6A;
  assign LFSR_ptrn[5] = 7'h69;
  assign LFSR_ptrn[6] = 7'h5C;
  assign LFSR_ptrn[7] = 7'h7E;
  assign LFSR_ptrn[8] = 7'h7B;


  always_comb begin
    pt_no = 0;
    if(pt_no>8) pt_no = pt_no[2:0];	       // restrict to 0 through 8 (our legal patterns)
    $display("pt_no = %d",pt_no);
  end    
  assign lfsr_ptrn = LFSR_ptrn[pt_no];     // engage the selected pattern

// now select a starting LFSR state -- any nonzero value will do
  always_comb begin
    LFSR_init =  17;//$random>>2;                // or set a value, such as 7'b1, for debug  //TODO:: change to random
    if(!LFSR_init) LFSR_init = 7'b1;       // prevents illegal starting state = 7'b0; 
  end

// set preamble lengths for the four program runs (always > 9 but < 16)
  always_comb begin
    pre_length =  27;//$random>>10 ;             // program 1 run  //TPDP chang e back
    if(pre_length < 10) pre_length = 10;   // prevents pre_length < 10
    else if(pre_length > 26) pre_length = 26; 
  end

// ***** instantiate your own top level design here *****
 TopLevel dut(
    .Clk     (Clk ),   // input: use your own port names, if different
    .Reset   (Init),   // input: some prefer to call this ".reset"
    .Start   (Req),   // input: launch program
    .Ack     (Ack)    // output: "program run complete"
  );

  initial begin
   #10ns Init = 'b0;
   #10ns Req  = 'b1;

	// initialize DUT's data memory
	#10ns for (int i=0; i<256; i++)
		dut.DM1.Core[i] = 8'h0;	     // clear data_mem

    dut.DM1.Core[128] = 7'h60;	     // 110_0000
    dut.DM1.Core[129] = 7'h48;
    dut.DM1.Core[130] = 7'h78;
    dut.DM1.Core[131] = 7'h72;
    dut.DM1.Core[132] = 7'h6A;
    dut.DM1.Core[133] = 7'h69;
    dut.DM1.Core[134] = 7'h5C;
    dut.DM1.Core[135] = 7'h7E;
    dut.DM1.Core[136] = 7'h7B;

	// initialize DUT's register file
	for(int j=0; j<16; j++)
		dut.RF1.Registers[j] = 8'b0;    // default -- clear it

//***** pre-load your instruction ROM here or inside itself	*****
//    $readmemb("encoder.bin", dut.instr_rom.rom);
// you may also pre-load desired constants, etc. into
//   your data_mem here -- the upper addresses are reserved for your use
//    dut.data_mem.DM[128]=8'hfe;          //whatever constants you want	
    file_no = $fopen("msg_decoder_out.txt","w");		 // create your output file
    #0ns strlen = str1.len;                // length of string 1 (# characters between " ")
    if(strlen>54) strlen = 54;             // clip message at 54 characters
// program 1 -- precompute encrypted message
    lfsr1[0]     = LFSR_init;              // any nonzero value (zero may be helpful for debug)
    $fdisplay(file_no,"run encryption program; original message = ");
    $fdisplay(file_no,"%s",str1);          // print original message in transcript window
    $fdisplay(file_no,"LFSR_ptrn = 0x%h, LFSR_init = 0x%h",lfsr_ptrn,LFSR_init);

    for(int j=0; j<64; j++)                // pre-fill message_padded with ASCII space characters
      msg_padded1[j] = 8'h20;              //   
    for(int l=0; l<strlen; l++)            // overwrite up to 52 of these spaces w/ message itself
      msg_padded1[pre_length+l] = str1[l];  //
    for (int ii=0;ii<63;ii++)	           // do the encryption
      lfsr1[ii+1] = {(lfsr1[ii][5:0]),(^(lfsr1[ii]&lfsr_ptrn))};

// encrypt the message character-by-character, then prepend the parity
//  testbench will change on falling clocks to avoid race conditions at rising clocks
    for (int i=0; i<64; i++) begin
      msg_crypto1[i]        = (msg_padded1[i] ^ lfsr1[i]);
	  msg_crypto1[i][7]     = ^msg_crypto1[i][6:0];       // prepend parity bit into MSB
      $fdisplay(file_no,"i=%d, msg_pad=0x%h, lfsr=%b msg_crypt w/ parity = 0x%h",
         i,msg_padded1[i],lfsr1[i],msg_crypto1[i]);
      str_enc1[i]           = string'(msg_crypto1[i][6:0]+8'h20);  // bias by 20 to avoid nonprinting characters
    end
	$fdisplay(file_no,"encrypted string =  "); 
	for(int jj=0; jj<64; jj++)
      $fwrite(file_no,"%s",str_enc1[jj]);
    $fdisplay(file_no,"\n");

// run encryption program first to know what to decrypt
// ***** load operands into your data memory *****
// ***** use your instance name for data memory and its internal core *****
//    for(int m=0; m<61; m++)
//	  dut.DM.core[m] = 8'h20;         // pad memory w/ ASCII space characters
//    for(int m=0; m<strlen; m++)
//      dut.DM.core[m] = str1[m];       // overwrite/copy original string into device's data memory[0:strlen-1]
     //dut.DM1.core[61] = pre_length;     // number of bytes preceding message
    // dut.DM1.core[62] = lfsr_ptrn;      // LFSR feedback tap positions (9 possible ptrns)
    // dut.DM1.core[63] = LFSR_init;      // LFSR starting state (nonzero)
    for(int n=0; n<64; n++) 			// load encrypted message into data memory
	  dut.DM1.Core[n+64] = msg_crypto1[n];


    //#20ns Init  = 1'b0;				  // suggestion: reset = 1 forces your program counter to 0
	#10ns Req    = 'b0; 			  //   request/start = 1 holds your program counter
    #60ns;                            // wait for 6 clock cycles of nominal 10ns each

    dut.DM1.Core[128] = 7'h60;	     // 110_0000
    dut.DM1.Core[129] = 7'h48;
    dut.DM1.Core[130] = 7'h78;
    dut.DM1.Core[131] = 7'h72;
    dut.DM1.Core[132] = 7'h6A;
    dut.DM1.Core[133] = 7'h69;
    dut.DM1.Core[134] = 7'h5C;
    dut.DM1.Core[135] = 7'h7E;
    dut.DM1.Core[136] = 7'h7B;



    wait(Ack);                       // wait for DUT's ack/done flag to go high
    #10ns $fdisplay(file_no,"");
    $fdisplay(file_no,"program 2:");
// ***** reads your results and compares to test bench
// ***** use your instance name for data memory and its internal core *****
    for(int n=0; n<64; n++)	begin
	  if(msg_padded1[n]==dut.DM1.Core[n])	begin
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h",
          n, msg_padded1[n], msg_padded1[n], dut.DM1.Core[n]);
		score++;
	  end
      else
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h  OOPS!",
          n, msg_padded1[n], msg_padded1[n], dut.DM1.Core[n]);
    end
    $fdisplay(file_no,"score = %d/64",score);
    #20ns $fclose(file_no);
    #20ns $stop;
  end

always begin     // continuous loop
  #5ns Clk = 'b1;  // clock tick
  #5ns Clk = 'b0;  // clock tock
end

endmodule