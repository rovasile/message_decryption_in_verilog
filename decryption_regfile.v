`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );
	 reg[reg_width -1 : 0] wdataAux;
 reg[reg_width - 1 : 0] selectAux;
 reg[reg_width - 1 : 0] caesarAux;
 reg[reg_width - 1 : 0] scytaleAux;
 reg[reg_width - 1 : 0] zigzagAux;
reg[addr_witdth - 1:0] addrAux=0;
reg[4:0] state=11, next_state=11;
reg op;
`define READ 0
`define WRITE 2
`define DONE 4
`define ERROR 6
`define RESET 8
`define WAITING 10
`define INIT 11

always @(posedge clk)
	begin

state<=`RESET;
if (rst_n!=0)
state<=next_state;
	end



always @(*)
begin


	case(state)
		`INIT:
				begin rdata=0; error=0; done=0; 
				next_state=`WAITING;
				end 				
		`READ:
				begin

				case(addrAux)
					8'h00:begin next_state=`WAITING;  rdata=selectAux; done=1; $display("read at %h",8'h00); end
					8'h10:begin  next_state=`WAITING; rdata=caesarAux; done=1; $display("read at %h",8'h10); end
					8'h12:begin next_state=`WAITING; rdata = scytaleAux; done=1; $display("read at %h",8'h12); end
					8'h14:begin next_state=`WAITING; rdata = zigzagAux; done=1; $display("read at %h",8'h14); end
					default:begin next_state=`WAITING;  done=1; error=1; $display("read(error) at %h",addr); end 
				endcase
				end
				
		`ERROR: begin  error=1; done=1; next_state=`ERROR+1; end 
		
		`ERROR+1: begin  error=0; done=0; next_state=`WAITING;  end 
		
		`DONE: begin  											
				done=1; next_state=`DONE+1; 
				end 
				
		`DONE+1: begin  done=0; next_state=`WAITING; end 
		
		`WRITE:
				case(addrAux)
					8'h00:begin next_state=`WAITING;  selectAux=0; done=1; $display("write at %h value %h",addrAux,wdataAux); end //modificare selectAux=0 conform Albertp
					8'h10:begin  next_state=`WAITING;  caesarAux=wdataAux; done=1; $display("write at %h value %h",addrAux,wdataAux); end
					8'h12:begin  next_state=`WAITING;  scytaleAux=wdataAux; done=1; $display("write at %h value %h",addrAux,wdataAux); end
					8'h14:begin next_state=`WAITING;   zigzagAux=wdataAux; done=1; $display("write at %h value %h",addrAux,wdataAux); end
					default:begin next_state=`WAITING;  done=1; error=1; $display("write at %h value %h",addrAux,wdata); end 
					endcase
		`RESET: begin $display("RESET TRIGGERED"); selectAux=16'h0;  caesarAux=16'h0;   scytaleAux=16'hFFFF;   zigzagAux=16'h2; next_state=`WAITING; end
				
		`WAITING: begin        
				error=0;
				done=0;					
					if (read==1 && write!=1)
						begin next_state=`READ; addrAux=addr; end
						
					if (write==1 && read!=1)
						begin next_state=`WRITE; addrAux=addr; $display("addraux=%h and addr=%h", addrAux, addr); wdataAux=wdata; end
					
						end		
				
	endcase
	
	
select=selectAux;
caesar_key=caesarAux;
scytale_key=scytaleAux;
zigzag_key=zigzagAux;
end



	
endmodule
