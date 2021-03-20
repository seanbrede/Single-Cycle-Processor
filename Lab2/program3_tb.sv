// Version: 2021.03.04
// program3_tb
// testbench for programmable message decryption, space removal (Program #3)
// CSE141L  
// encrypts / decrypts a message, with occasional one-bit corruption
module decrypt_depad_tb ()        ;
  logic      clk   = 1'b0   ,      // advances simulation step-by-step
             init  = 1'b1   ,      // init (reset) command to DUT
             start = 1'b1   ;      // req (start program) command to DUT
  wire       done           ;      // done flag returned by DUT
  logic[4:0] pre_length     ;  	   // space char. bytes before first char. in message, limited 10-26
  logic[7:0] message1[54]   ,      // original raw message, in binary
             msg_padded1[128],      // original message, plus pre- and post-padding w/ ASCII spaces
             msg_crypto1[64];      // encrypted message according to the DUT
  logic[6:0] lfsr_ptrn      ,      // chosen one of 9 maximal length 7-tap shift reg. ptrns
             LFSR_ptrn[16]  ,      // the 9 candidate maximal-length 7-bit LFSR tap ptrns
             lfsr1[64]      ,      // states of program 1 encrypting LFSR
             LFSR_init      ;      // one of 127 possible NONZERO starting states
  int        score          ;      // count of correct encyrpted characters
// our original American Standard Code for Information Interchange message follows
// note in practice your design should be able to handle ANY ASCII string that is
//  restricted to characters between space (0x20) and script f (0x9f) and shorter than 
//  53 characters in length
  string     str1  = "Mr. Watson, come here. I want to see you.";     // sample program 1 input
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // alternative inputs
//  string     str1  = "  01234546789abcdefghijklmnopqrstuvwxyz. ";   //   (make up your own,
//  string     str1  = "          A joke is a very serious thing.";   // 	as well)
//  string     str1  = "                           Ajok          ";   // 
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // 

// displayed encrypted string will go here:
  string      str_enc1[64];          // program 1 desired output will go here
  int         strlen;                // incoming string length 
  int         perfect_score;   
  logic[ 3:0] pt_no1;				 // LFSR pattern index 16 possible
  logic[ 7:0] pt_no;                 // select LFSR pattern, value 0 through 255
  int         file_no;               // write to file
  int         space;                 // counts leading space characters in message
  logic[ 5:0] flipper; 			     // corruptor -- bit flip
  logic[127:0] flipped = 'b0;        // tracks which word got a bit flipped
// the 8 possible maximal-length feedback tap patterns from which to choose
  assign LFSR_ptrn[ 0] = 7'h60;	     // 110_0000  
  assign LFSR_ptrn[ 1] = 7'h48;
  assign LFSR_ptrn[ 2] = 7'h78;
  assign LFSR_ptrn[ 3] = 7'h72;
  assign LFSR_ptrn[ 4] = 7'h6A;
  assign LFSR_ptrn[ 5] = 7'h69;						
  assign LFSR_ptrn[ 6] = 7'h5C;
  assign LFSR_ptrn[ 7] = 7'h7E;
  assign LFSR_ptrn[ 8] = 7'h7B;
  assign LFSR_ptrn[ 9] = 7'h48;		 // same as LFSR_ptrn[1]
  assign LFSR_ptrn[10] = 7'h78;		 //     ...
  assign LFSR_ptrn[11] = 7'h72;
  assign LFSR_ptrn[12] = 7'h6A;
  assign LFSR_ptrn[13] = 7'h69;
  assign LFSR_ptrn[14] = 7'h5C;
  assign LFSR_ptrn[15] = 7'h7E;		 // same as LFSR_ptrn[7]
// select an LFSR feedback tap pattern
  always_comb begin
    pt_no = 0; //$random>>22;        // specific pattern for debug, random for verification
    pt_no1 = pt_no[3:0];
    lfsr_ptrn = LFSR_ptrn[pt_no1];    // engage the selected pattern
  end
// select a starting LFSR state -- any nonzero value will do
  always_comb begin					   
    LFSR_init = 7'b1; //$random>>2;  // specific value for debug, random for verification
    if(!LFSR_init) LFSR_init = 7'b1; // prevents illegal starting state = 7'b0; 
  end

// set preamble lengths for the program  (always > 9 but < 16)
  always_comb begin
    pre_length = $random>>10 ;             // program 1 run
    if(pre_length < 10) pre_length = 10;   // prevents pre_length < 10
    else if(pre_length > 26) pre_length = 26;
  end

// ***** instantiate your own top level design here *****
  top_level dut(
    .clk     (clk  ),   // input: use your own port names, if different
    .init    (init ),   // input: some prefer to call this ".reset"
    .req     (start),   // input: launch program
    .ack     (done )    // output: "program run complete"
  );

  initial begin
//***** pre-load your instruction ROM here or inside itself	*****
//    $readmemb("encoder.bin", dut.instr_rom.rom);
// you may also pre-load desired constants, etc. into
//   your data_mem here -- the upper addresses are reserved for your use
//    dut.data_mem.DM[128]=8'hfe;   //whatever constants you want	
    file_no = $fopen("msg_decoder_out.txt","w");		 // create your output file
    #0ns strlen = str1.len;       // length of string 1 (# characters between " ")
    if(strlen>54) strlen = 54;          // clip message at 54 characters
    for(space=0;space<26;space++)		// count leading spaces in unpadded message
	  if(str1[space]==8'h20) continue;
	  else break;
// program 1 -- precompute encrypted message
    lfsr1[0]     = LFSR_init;           // any nonzero value (zero may be helpful for debug)
    $fdisplay(file_no,"run encryption program; original message = ");
    $fdisplay(file_no,"%s",str1);       // print original message in transcript window
    $fdisplay(file_no,"space_pad_length=%d",pre_length);
    $fdisplay(file_no,"LFSR_ptrn = 0x%h, LFSR_init = 0x%h",lfsr_ptrn,LFSR_init);
    for(int j=0; j<128; j++)            // pre-fill message_padded with ASCII space characters
      msg_padded1[j] = 8'h20;          //   
    for(int l=0; l<strlen; l++)        // overwrite up to 54 of these spaces w/ message itself
      msg_padded1[l+pre_length] = str1[l];  // 
// compute the LFSR sequence
    for (int ii=0;ii<63;ii++)
      lfsr1[ii+1] = {(lfsr1[ii][5:0]),(^(lfsr1[ii]&lfsr_ptrn))};

// encrypt the message charater-by-character, then prepend the parity
//  testbench will change on falling clocks to avoid race conditions at rising clocks
    for (int i=0; i<64; i++) begin
      msg_crypto1[i]        = (msg_padded1[i] ^ lfsr1[i]);
	  msg_crypto1[i][7]     = ^msg_crypto1[i][6:0];       // prepend parity bit into MSB
      $fdisplay(file_no,"i=%d, msg_pad=0x%h, lfsr=%b msg_crypt w/ parity = 0x%h",
         i,msg_padded1[i],lfsr1[i],msg_crypto1[i]);
      str_enc1[i]           = string'(msg_crypto1[i][6:0]+8'h20); // display purposes only
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
//    dut.DM.core[61] = pre_length;     // number of bytes preceding message
//    dut.DM.core[62] = lfsr_ptrn;      // LFSR feedback tap positions (9 possible ptrns)
//    dut.DM.core[63] = LFSR_init;      // LFSR starting state (nonzero)
    for(int m=0; m<26; m++)             // load first 26 characters of encrypted message into data memory
      dut.DM.core[m+64] = msg_crypto1[m];	 // this guarantees all space prepend characters are clean
    for(int n=26; n<64; n++) begin	  	// load subsequent, possibly corrupt, encrypted message into data memory
	  flipper = $random;                // value between 0 and 63, inclusive
      dut.DM.core[n+64] = msg_crypto1[n]^(1<<flipper);
      if(flipper<8) flipped[n]=1;		// if flipper>7, it is out of range, has no impact on message
	end
    #20ns init  = 1'b0;				  // suggestion: reset = 1 forces your program counter to 0
	#10ns start = 1'b0; 			  //   request/start = 1 holds your program counter 
    #60ns;                            // wait for 6 clock cycles of nominal 10ns each
    wait(done);                       // wait for DUT's ack/done flag to go high
    #10ns $fdisplay(file_no,"");
    $fdisplay(file_no,"program 3:");
// ***** reads your results and compares to test bench
// ***** use your instance name for data memory and its internal core *****
    for(int n=0; n<64; n++)	begin
      if(flipped[n+pre_length+space]) begin
        if(dut.DM.core[n][7]) begin
		  $fwrite(file_no,"%d bench msg: %s %h dut msg: %h",
              n, msg_padded1[n+pre_length+space][6:0], msg_padded1[n][6:0], dut.DM.core[n][6:0]);
          $fdisplay(file_no,"  error successfully flagged");
          score++;
        end  
        else if(dut.DM.core[n][7]==0) begin
		  $fwrite(file_no,"%d bench msg: %s %h dut msg: %h",
              n, msg_padded1[n+pre_length+space][6:0], msg_padded1[n][6:0], dut.DM.core[n][6:0]);
          $fdisplay(file_no,"  error missed");
//          score++;
        end  
        else begin
		  $fwrite(file_no,"%d bench msg: %s %h dut msg: %h",
              n, msg_padded1[n+pre_length+space][6:0], msg_padded1[n][6:0], dut.DM.core[n][6:0]);
          $fdisplay(file_no,"  error flag not returned");
//          score++;
        end  
      end
	  else if({flipped[n+pre_length+space],msg_padded1[n+pre_length+space][6:0]}
	         == dut.DM.core[n])	begin
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h",
          n, msg_padded1[n+pre_length+space][6:0], msg_padded1[n][6:0], dut.DM.core[n][6:0]);
		score++;
	  end
      else
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h  OOPS!",
          n, msg_padded1[n+pre_length+space][6:0], msg_padded1[n][6:0], dut.DM.core[n][6:0]);
    end
    perfect_score = strlen + 10 - pre_length;      
    $fdisplay(file_no,"score = %d/%d",score,perfect_score);
    #20ns $fclose(file_no);
    #20ns $stop;
  end

always begin     // continuous loop
  #5ns clk = 1;  // clock tick
  #5ns clk = 0;  // clock tock
end

endmodule