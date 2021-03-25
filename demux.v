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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	

`define send 0
`define waiting 2
	
	
reg [SYS_DWIDTH - 1 : 0] t1,t2,t3,t4;
reg [7:0] counter=0, countAux=0, i=0,i_next=0;;
reg [3:0] state, next_state=`waiting, next_valid;
reg [1:0] selectAux=0;
reg [3:0] endTr1=0, endTr2=0, endTr3=0, endTr4=0;
reg [3:0] endTr=0;


always @(posedge clk_sys)	//se analizeaza pe rand cele 4 caractere si in functie de select sunt trimise pe data(0/1/2) si bitul de enable este pus pe 1 pentru output-ul respectiv
begin

if(valid_i && endTr==0)	//se asteapta identificarea caracterului 0xFA, moment in care endTr devine 1 si se opreste trimiterea urmatoarelor date
	case(counter)
		0:begin 				//i=0		
			case(select)
				0: begin  data0_o<=data_i[31:24]; valid0_o<=1; if(data_i[31:24]==8'hFA) endTr<=1; end
				1:	begin  data1_o<=data_i[31:24]; valid1_o<=1; if(data_i[31:24]==8'hFA) endTr<=1; end
				2: begin  data2_o<=data_i[31:24]; valid2_o<=1; if(data_i[31:24]==8'hFA) endTr<=1; end
			endcase
			counter<=counter+1;
		end

		1:begin 				//i=1
			case(select)
				0: begin  data0_o<=t2; valid0_o<=1; if(t2==8'hFA) endTr<=1; end
				1:	begin  data1_o<=t2; valid1_o<=1; if(t2==8'hFA) endTr<=1; end
				2: begin  data2_o<=t2; valid2_o<=1; if(t2==8'hFA) endTr<=1; end
			endcase
			counter<=counter+1;
		end
		
		2:begin  			//i=2
			case(select)
				0: begin  data0_o<=t3; valid0_o<=1; if(t3==8'hFA) endTr<=1; end
				1:	begin  data1_o<=t3; valid1_o<=1; if(t3==8'hFA) endTr<=1; end
				2: begin  data2_o<=t3; valid2_o<=1; if(t3==8'hFA) endTr<=1; end
			endcase
			counter<=counter+1;
		end
		
		3:begin  		//i=3
		
			case(select)
				0: begin  data0_o<=t4; valid0_o<=1; if(t4==8'hFA) endTr<=1; end
				1:	begin  data1_o<=t4; valid1_o<=1; if(t4==8'hFA) endTr<=1; end
				2: begin  data2_o<=t4; valid2_o<=1; if(t4==8'hFA) endTr<=1; end
			endcase
			counter<=0;
		end
	endcase
	
	
if(endTr)	//se trec semnalele de valid_o pe 0 pentru ca a fost gasit caracterul 0xFA
begin
valid0_o<=0;
valid1_o<=0;
valid2_o<=0;
end

if(endTr && valid_i==0)	//se reseteaza in intregime pentru a pregati demuxul pentru urmatorul sir de caractere
begin
endTr<=0;
counter<=0;
end

	
end


always @(posedge clk_mst)	//se stocheaza cele 4 caractere
begin

if(valid_i)
begin
t1<=data_i[31:24];
t2<=data_i[23:16];
t3<=data_i[15:8];
t4<=data_i[7:0];
end

end

endmodule
