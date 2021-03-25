`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
            output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );


`define reset 0
`define waiting 2
`define decode 4
`define busy 6
`define final 8
`define make_array 10
`define thxVerilog 12

reg[7:0] state, next_state=`waiting;
reg[D_WIDTH - 1:0] array[MAX_NOF_CHARS-1:0];
reg[7:0] order[MAX_NOF_CHARS-1:0];
reg[7:0] count=0, countAux=0;
reg[7:0] i, i_next=0, i_decode=0, i_decode_next=1;
reg[7:0] cycle=0, base=0, lines=0,columns=0, r=0, nrLin1=0, nrLin2=0, nrLin3=0;
reg[7:0] c1=0,c2,c3,c4;
reg[7:0] c1_next=0, c2_next=0, c3_next=0, c4_next=0, ic1=0, ic2=0, ic3=0, ic4=0, first, next_first=0;
reg[KEY_WIDTH - 1 : 0] keyAux;


//LEGENDA VARIABILE:
// 	i_decode (i_decode_next) se folosesc in starea de decriptare a mesajului pentru a parcurge vectorul cu caractere
//		count numara caracterele introduse, numar salvat in countAux
// 	i (i_next) se foloseste in starea care construieste vectorul cu ordinea corecta a elementelor (incepe de la 1)
// 	cycle, base, r, lines, columns sunt caracteristici ale cifrului, derivate din numarul de caractere si din cheie
// 	nrLin1, nrLin2, nrLin3 contin numarul de termeni de pe fiecare linie, in functie de baza,r si cheie
// 	c1, c2, c3, c4 (c1_next, c2_next, c3_next, c4_next) sunt variabilele folosite pentru a parcurge ciclurile din cifru; cheie=3 -> 4 coloane pe fiecare ciclu, cheie=2 -> 2 coloane pe fiecare ciclu
// 	ic1, ic2, ic3, ic4 sunt variatii ale lui i -> (i+1), (i+2), (i+3), (i+4) pentru a reduce numarul de fronturi de ceas petrecute in starea de formare a vectorului
// si pentru a evita folosirea unui algoritm de obtinere a restului in inca un loc.
//		first (next_first) se folosesc pentru a seta 		c1_next=0;		c2_next=c1+nrLin1;		c3_next=c1+nrLin1+nrLin2;			c4_next=c1+nrLin1+2'b1;
// doar in prima executie a starii de formare a vectorului.
//
// Toate aceste lucruri supracomplicate au fost rezultate in urma evitarii limitarilor pe care le presupune sintetizarea. 



always @(posedge clk)
begin
	state<=next_state;
	i_decode<=i_decode_next;
	i<=i_next;
	c1<=c1_next;
	c2<=c2_next;
	c3<=c3_next;
	c4<=c4_next;
	first<=next_first;
	
	if(data_i!=START_DECRYPTION_TOKEN && valid_i==1)	//se salveaza caracterele in vector si se numara
		begin 
			array[count]<=data_i; 
			count<=count+1'b1; 
			keyAux<=key[7:0]; 
		end
	else
		if(data_i==START_DECRYPTION_TOKEN && valid_i==1)
		begin 
			countAux<=count-1'b1; 
			state<=`thxVerilog; 
			count<=0; 
		end
	if (rst_n==0)
	state<=`reset;
end

always @(*)
begin

	case(state)
		`reset: begin data_o=0; valid_o=0; end
		`thxVerilog: begin next_state=`make_array; end //Aman cu un front de ceas inceperea propriu-zisa a executiei
		`make_array:
				begin
						//$display("---------------------a------------");
						busy=1;
						
						lines=keyAux;
						cycle=keyAux*2'b10-2'b10;	
						
							r=(countAux+1'b1);	//algoritm de impartire unde r=rest si base=catul
							base=0;
							repeat(26)
							begin
								if (r >= cycle)
									begin
										r=r-cycle;
										base=base+1'b1;
									end
							end
						
						//base, cycle si restul sunt caracteristici ale configuratiei cifrului, in functie de numarul de termeni si de cheie (wikipedia)
						
						//$display("nr_caractere=%d linii=%d cycle=%d base=%d r=%d keyAux=%d",countAux+1,lines, cycle, base,r, keyAux);
						case(keyAux)		//in functie de r, liniile vor avea un numar diferit de termeni si se configureaza asta aici
							3:	begin
									case(r)						
										0:begin nrLin1=base; nrLin2=base*2'b10; nrLin3=base; end
										1:begin nrLin1=base+1'b1; nrLin2=base*2'b10; nrLin3=base; end
										2:begin nrLin1=base+1'b1; nrLin2=base*2'b10+1'b1; nrLin3=base; end
										3:begin nrLin1=base+1'b1; nrLin2=base*2'b10+1'b1; nrLin3=base+1'b1; end
									endcase
									

											ic1=i+3'b1;
											ic2=i+3'b10;
											ic3=i+3'b11;
											ic4=i+3'b100;
											
												if(i<=countAux)
												begin 
												order[ic1]=c1; //i=i+2'b1; 
												//$display("c1=%d", c1); 
												end
												
												if(i<=countAux)
												begin 
												order[ic2]=c2; // i=i+2'b1; 
												//$display("c2=%d", c2); 
												end	
												
												if(i<=countAux)
												begin 
												order[ic3]=c3; //i=i+2'b1; 
												//$display("c3=%d", c3); 
												end
												
												if(i<=countAux)
												begin 
												order[ic4]=c4; //i=i+2'b1; 
												//$display("c4=%d", c4); 
												end	

										if (i==0 && first==0)
											begin
												c1_next=0;
												c2_next=c1+nrLin1;
												c3_next=c1+nrLin1+nrLin2;
												c4_next=c1+nrLin1+2'b1;
												next_first=1;
											end
										else
											begin
													c1_next=c1+2'b1;				
													c2_next=c2+2'b10;
													c3_next=c3+2'b1;
													c4_next=c4+2'b10;
													i_next=i+4;
											end

								end
								
							2: begin
									case(r)						
										0:begin nrLin1=base; nrLin2=base; end
										1:begin nrLin1=base+1'b1; nrLin2=base;end
									endcase

											
											ic1=i+2'b1;
											ic2=i+2'b10;
											
												if(i<=countAux)
												begin order[ic1]=c1; //i=i+2'b1; 
												end
												
												if(i<=countAux)
												begin order[ic2]=c2; //i=i+2'b1; 
												end
												
									if (i==0 && first==0)
									begin
										c1_next=0;
										c2_next=c1+nrLin1;
										next_first=1;
									end
									else
										begin
											c1_next=c1+2'b1;
											c2_next=c2+2'b1;
											i_next=i+2;
										end

										
								end
						endcase
						
						ic1=0; ic2=0; ic3=0; ic4=0;

				//		k2ic1=0; k2ic2=0; k2ic3=0; k2ic4=0;

						if (i_next>countAux)
						begin
						//$display("a ajuns in next state");
						next_state=`decode;
						//c1=0;c2=0;c3=0;c4=0; 
						i_next=0; r=0; 
						c1_next=0;				
						c2_next=0;
						c3_next=0;
						c4_next=0;
						next_first=0;	//resetare variabile pentru urmatoarea decriptare
						end
						
						
				end
		
		`decode: 
				begin 
					valid_o=1;
					repeat(50)
					begin
						if (i_decode<=countAux+1)
						begin
							data_o=array[order[i_decode]];	//citire caractere in ordinea corecta, obtinuta in starea anterioara.
							i_decode_next=i_decode+2'b1;
						end
						else
							begin valid_o=0; busy=0; i_decode_next=1; next_state=`waiting; end
					end
 				end
		`waiting:
		begin
			;
		end

	endcase
end

endmodule
