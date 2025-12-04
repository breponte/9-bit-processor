// combinational -- no clock
// sample -- change as desired
module alu #(parameter D=12)(
	input[2:0] 			alu_cmd,    		// ALU instructions
	input[7:0] 			inA, inB, reg0, 	// 8-bit wide data path
	input[2:0]			lookup,				// lookup value immediate
	input[D-1:0] 		prog_ctr,			// program counter for jump
	input      			sc_i,       		// shift_carry in
	output logic[7:0] rslt,
	output logic prog_bit,
	output logic 		sc_o,     			// shift_carry out
							pari,     			// reduction XOR (output)
							zero      			// NOR (output)
);

always_comb begin
rslt = 'b0;
prog_bit = 'b0;
sc_o = sc_i;
  case(alu_cmd)
		3'b000: begin // bitwise and
		   rslt = inA & inB;
		end
		3'b001: begin // bitwise xor
		   rslt = inA ^ inB;
		end
		3'b010: begin // set less than
		   rslt = inA < inB ? 8'b00000001 : 8'b00000000;
		end
		3'b011: begin // branch not zero
		   {prog_bit, rslt} = (inB != 0) ? inA : prog_ctr + 1;
		end
		3'b100: begin // add 2 8-bit unsigned; automatically makes carry-out
			{sc_o,rslt} = inA + reg0 + inB + sc_i;
		end
		3'b101: begin // right rotate
		   rslt = (inA << (8-lookup)) | (inA >> lookup);
		end
		3'b110: begin // load word
		   rslt = inA + inB;
		end
		3'b111: begin // store word
		   rslt = reg0 + inB;
		end
	endcase
end
endmodule