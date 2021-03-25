`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
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
module caesar_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
            output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

`define reset 0
`define waiting 2

reg[3:0] state, next_state=`waiting;
reg[D_WIDTH - 1:0] dataAux=87;
reg validAux=0;

always @(posedge clk)
begin
	state<=next_state;
	data_o<=dataAux;	//output-ul pentru caracterul decodat e intarziat cu un front de ceas
	valid_o<=validAux;

	if (valid_i==1)
		begin
			dataAux<=data_i-key;	//caracterul decodat
			validAux<=1;
		end

	if(valid_i==0)
		begin
			validAux<=0;
		end 

	if(rst_n==0)
		begin
			;	
		end
end



endmodule
