// top level design
module top_level(
	input        clk, reset,
	output logic done);
	parameter 		D = 12,             						// program counter width
						A = 3;             						// ALU command bit width
	logic[D-1:0] 			  							// jump 
						prog_ctr;
	logic        	RegWrite;
	logic [7:0]   	datA, datB, reg0,		  					// from RegFile
						muxB, muxWrite, datOut, 
						immed, rslt;
	logic 			sc_in = 'b0,  									// shift/carry out from/to ALU
						pariQ,            						// registered parity flag from ALU
						zeroQ;            						// registered zero flag from ALU 
	logic				absj;
	logic  			pari,
						zero, prog_bit,
						sc_clr,
						sc_en = 'b1,
						MemtoReg,
						MemWrite,
						InPlace,
						ALUSrc;		      						// immediate switch
	logic [A-1:0] 	alu_cmd;
	logic [8:0]   	mach_code;        						// machine code
	logic [2:0]	opcode;
	logic [2:0] 	rd_addrA, rd_addrB;						// address pointers to reg_file

	assign opcode = mach_code[8:6];
	assign rd_addrA = mach_code[5:3];
	assign rd_addrB = mach_code[2:0];

	// fetch subassembly
	PC #(.D(D)) 					  								// D sets program counter width
		pc1 (	.reset            ,
				.clk              ,
				.absjump_en (absj),
				.target     (rslt), .prog_bit,
				.prog_ctr          );


	// contains machine code
	instr_ROM ir1(	.prog_ctr,
						.mach_code);

	// control decoder
	Control ctl1(	.instr	(opcode)  ,
						.Branch  (absj)    ,
						.MemWrite 		    , 
						.ALUSrc   		    , 
						.RegWrite   	    ,     
						.MemtoReg		    ,
						.InPlace,
						.ALUOp 	(alu_cmd));
	
	always_comb muxWrite = MemtoReg ? datOut : rslt;

	reg_file #(.pw(3)) rf1(.dat_in  (muxWrite),	   	// loads, most ops
								  .clk         		,
								  .InPlace,
								  .wr_en   (RegWrite),
								  .rd_addrA(rd_addrA),
								  .rd_addrB(rd_addrB),
								  .wr_addr(rd_addrA),      	// in place operation
								  .datA_out(datA)		,
								  .datB_out(datB)		,
								  .reg0					); 
	
	immed_LUT lut1(.ALUSrc			  ,
						.immed (rd_addrB),
						.datB  			  ,
						.inB	 	 (muxB));

	alu alu1(.alu_cmd		  		,
				.inA    		(datA),
				.inB    		(muxB),
				.reg0					,
				.lookup (rd_addrB),
				.prog_ctr	  		,
				.sc_i   	 	  (sc_in),   							// output from sc register
				.rslt        	   ,
				.sc_o   		(sc_o), 								// input to sc register
				.pari  	 		   ,
				.zero, .prog_bit);  

	dm dm(.dat_in(datA)  	,  						// from reg_file
					.clk           	,
					.wr_en  (MemWrite), 							// stores
					.addr   (rslt)		,
					.dat_out(datOut)	);

	// registered flags from ALU
	always_ff @(posedge clk) begin
		pariQ <= pari;
		zeroQ <= zero;
		if(sc_clr)
			sc_in <= 'b0;
		else if(sc_en)
			sc_in <= sc_o;
	end

	assign done = prog_ctr == 276; // 276
 
endmodule