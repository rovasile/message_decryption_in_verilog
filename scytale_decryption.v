`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			
			output reg busy
    );

`define reset 0
`define waiting 2
`define decode 4
`define busy 6
`define final 8
`define thxverilog 10

reg[3:0] state, next_state=`waiting;
reg[D_WIDTH - 1:0] array[MAX_NOF_CHARS-1:0];
reg[5:0] count=0, countAux=0, factor, current=0;
reg[7:0] i=0, i_next=0;
always @(posedge clk)
begin
state<=next_state;

if(data_i!=START_DECRYPTION_TOKEN && valid_i==1)
	begin array[count]<=data_i; count<=count+1;  end
else
	if(data_i==START_DECRYPTION_TOKEN && valid_i==1)
	begin countAux<=count-1; state<=`thxverilog; count<=0; end

	i <= i_next;

if (rst_n==0)
state<=`reset;
end

always @(*)
begin

case(state)
		`reset:begin data_o=0; valid_o=0; busy=0; end
		`thxverilog: begin next_state=`busy;    end	//se amana cu un frotn de ceas executia
		`busy: begin  busy=1; next_state=`decode; end
		`decode: begin 
						valid_o=1;
						if(i<=countAux)
							begin 

							factor=current+key_N;
							repeat(50)
							begin
								if (factor >=key_N*key_M-1)
									begin
										factor=factor-key_N*key_M+1;
									end
							end

								data_o=array[factor]; 
							//	$display("i=%d si data_o=%c si factor=%d si count=%d si key_N=%d",i,data_o, factor, count, key_N); 

								current=factor;
								
								//formula prin care se determina ordinea termenilor este o progresie de forma current=(current+key_N)%(key_N*key_M-1) cu valoare initiala current=0
								
								if(i==0)
									begin 
										data_o=array[0]; 
										current=0;
									end
								i_next = i + 1; 
								if(i_next-1==countAux) 
									begin
										data_o=array[countAux]; 
										 next_state=`final;
										 i_next=0;
									end
							end
					end				
		`final: begin  busy=0; valid_o=0; i_next=0; end

endcase

end

endmodule
