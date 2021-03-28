module LUT_Imm (
	input        [4:0] index,
	output logic [7:0] immediate
);
always_comb
	case (index)
		5'd0:    immediate = 8'd61;
		5'd1:    immediate = 8'd62;
		5'd2:    immediate = 8'd63;
		5'd3:    immediate = 8'd0;
		5'd4:    immediate = 8'd64;
		5'd5:    immediate = 8'd128;
		5'd6:    immediate = 8'd10;
		5'd7:    immediate = 8'd26;
		5'd8:    immediate = 8'd32;
		5'd9:    immediate = 8'd1;
		5'd10:   immediate = 8'd127;
		5'd11:   immediate = 8'd75;
		5'd12:   immediate = 8'd65;
		5'd13:   immediate = 8'd74;
		5'd14:   immediate = 8'd73;
		default: immediate = 8'd255;
	endcase
endmodule