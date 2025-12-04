// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(parameter pw=3)(
  input[7:0] 			dat_in,
  input      			clk,
  input      			wr_en, InPlace,          	// write enable
  input[pw-1:0] 		wr_addr,		  		// write address pointer
							rd_addrA,		  	// read address pointers
							rd_addrB,
  output logic[7:0] 	datA_out, 			// read data
							datB_out,
							reg0		);

  logic[7:0] core[2**pw];    				// 2-dim array  8 wide  8 deep

// reads are combinational
  assign datA_out = core[rd_addrA];
  assign datB_out = core[rd_addrB];
  assign reg0	  = core[3'b000];

// writes are sequential (clocked)
  always_ff @(posedge clk)
    if(wr_en)				   				// anything but stores or no ops
      if (InPlace)
        core[wr_addr] <= dat_in; 
      else 
        core[3'b000] <= dat_in;

endmodule