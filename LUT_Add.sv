module LUT_Add (
	input        [4:0] index,
	output logic [9:0] address
);
always_comb
	case (index)
		5'd0:    address = 10'd33;
		5'd1:    address = 10'd40;
		5'd2:    address = 10'd44;
		5'd3:    address = 10'd79;
		5'd4:    address = 10'd120;
		5'd5:    address = 10'd133;
		5'd6:    address = 10'd39;
		5'd7:    address = 10'd51;
		5'd8:    address = 10'd95;
		5'd9:    address = 10'd105;
		5'd10:   address = 10'd111;
		5'd11:   address = 10'd125;
		5'd12:   address = 10'd148;
		5'd13:   address = 10'd160;
		5'd14:   address = 10'd41;
		5'd15:   address = 10'd53;
		5'd16:   address = 10'd95;
		5'd17:   address = 10'd105;
		5'd18:   address = 10'd111;
		5'd19:   address = 10'd127;
		5'd20:   address = 10'd145;
		5'd21:   address = 10'd156;
		5'd22:   address = 10'd182;
		5'd23:   address = 10'd186;
		5'd24:   address = 10'd202;
		5'd25:   address = 10'd215;
		5'd26:   address = 10'd222;
		5'd27:   address = 10'd229;
		5'd28:   address = 10'd259;
		default: address = 10'd1023;
	endcase
endmodule