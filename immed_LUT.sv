module immed_LUT(
	input		 			ALUSrc,
	input[2:0]			immed ,
	input[7:0] 			datB  ,
	output logic[7:0] inB	);

	reg[7:0]					value;
	  
	always_comb begin
		value = 8'b00000000;

		// immediate lookup table
		case(immed)
			3'b000: value = 8'b00000000;			// 0
			3'b001: value = 8'b00000001;			// 1
			3'b010: value = 8'b00000010;			// 2
			3'b011: value = 8'b00000100;			// 4
			3'b100: value = 8'b00001000;			// 8
			3'b101: value = 8'b11111111;			// -1
			3'b110: value = 8'b11111110;			// -2
			3'b111: value = 8'b11111100;			// -4
		endcase

		inB = ALUSrc? value : datB;
	end

endmodule