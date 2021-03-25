`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	 

	 wire busy_caesar, busy_scytale, busy_zigzag;
	wire [SYS_DWIDTH-1:0] data_o_aux;
	wire valid_o_aux;
	
	wire[SYS_DWIDTH-1:0] demux_caesar, demux_scytale, demux_zigzag;
	wire 						demux_caesar_valid, demux_valid_scyale, demux_valid_zigzag; 	
	
	wire[SYS_DWIDTH-1:0] data_o_caesar; 
	wire valid_o_caesar;	

	wire[SYS_DWIDTH-1:0] data_o_scytale; 
	wire valid_o_scytale;
	
	wire[SYS_DWIDTH-1:0] data_o_zigzag; 
	wire valid_o_zigzag;
	
	wire[reg_width - 1 : 0] rdata_regs, caesar_key_regs, scytale_key_regs, zigzag_key_regs;
	wire[reg_width - 1 : 0] select_regs;
	wire done_regs, error_regs;
	
	
	mux m(
	.clk(clk_sys),
	.rst_n(rst_n),
	.select(select_regs),
	.data0_i(data_o_caesar),
	.data1_i(data_o_scytale),
	.data2_i(data_o_zigzag),
	.valid0_i(valid_o_caesar),
	.valid1_i(valid_o_scytale),
	.valid2_i(valid_o_zigzag),
	.data_o(data_o_aux),
	.valid_o(valid_o_aux)
	);

	demux dem(
	.clk_sys(clk_sys),
	.clk_mst(clk_mst),
	.rst_n(rst_n),
	.select(select_regs),
	.data_i(data_i),
	.valid_i(valid_i),
	.data0_o(demux_caesar),
	.data1_o(demux_scytale),
	.data2_o(demux_zigzag),
	.valid0_o(demux_caesar_valid),
	.valid1_o(demux_valid_scyale),
	.valid2_o(demux_valid_zigzag)
	);

	
	caesar_decryption caesar(
	.clk(clk_sys),
	.rst_n(rst_n),
	.data_i(demux_caesar),
	.valid_i(demux_caesar_valid),
	.key(caesar_key_regs),
	.busy(busy_caesar),
	.data_o(data_o_caesar),
	.valid_o(valid_o_caesar)
	);

	
	scytale_decryption scytale(
	.clk(clk_sys),
	.rst_n(rst_n),
	.data_i(demux_scytale),
	.valid_i(demux_valid_scyale),
	.key_N(scytale_key_regs[15:8]),
	.key_M(scytale_key_regs[7:0]),
	.busy(busy_scytale),
	.data_o(data_o_scytale),
	.valid_o(valid_o_scytale)
	);
	

	
	zigzag_decryption zigzag(
	.clk(clk_sys),
	.rst_n(rst_n),
	.data_i(demux_zigzag),
	.valid_i(demux_valid_zigzag),
	.key(zigzag_key_regs),
	.busy(busy_zigzag),
	.data_o(data_o_zigzag),
	.valid_o(valid_o_zigzag)	
	);
	

	decryption_regfile regs(
	.clk(clk_sys),
	.rst_n(rst_n),
	.addr(addr),
	.read(read),
	.write(write),
	.wdata(wdata),
	.rdata(rdata_regs),	//outputs
	.done(done_regs),
	.error(error_regs),
	.select(select_regs),
	.caesar_key(caesar_key_regs),
	.scytale_key(scytale_key_regs),
	.zigzag_key(zigzag_key_regs)
	);
	
	
	assign busy= busy_caesar || busy_scytale || busy_zigzag;
	assign rdata=rdata_regs;
	assign done=done_regs;
	assign error=error_regs;
	
	assign data_o=data_o_aux;
	assign valid_o=valid_o_aux;
	

endmodule
