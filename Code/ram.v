`timescale 1ns / 1ps
module ram(
	 input clk,
	 input reset,
    input [18:0] read_addr,
    output reg [2:0] read_data,
	 
	 input [18:0] write_addr,
    input [2:0] write_data,
    input write_enable,
	 
	 inout [5:0] ram_data,
	 output reg [17:0] ram_addr,
	 output reg ram_write,
	 output reg ram_output,
	 output reg ram_chipenable,
	 output reg ram_upperbyte,
	 output reg ram_lowerbyte,
	input readSwitch,
	input writeSwitch
    );
	 
	 
	reg send_data;
	reg [2:0] loc_write_data;
	assign ram_data = send_data ? {loc_write_data, loc_write_data} : 6'bZ; //output


	reg fsm;
	always @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			loc_write_data = 0;

		
			send_data = 0;
			fsm = 0;
			ram_write = 1;
			ram_chipenable = 0;
			ram_output = 0;
			read_data = 3'b0;
		end
		else
		begin
		
		
			//******************************		
			//mappen upperbyte und lowerbyte auf den richtigen RAM-Port???????
			//******************************
			
			
			case (fsm)
				1'b0: 
					begin
						if(readSwitch)
							read_data = ram_addr[0] ? ram_data[5:3] : ram_data[2:0];	//read_data
						
						if(writeSwitch)
								send_data = 1;
							
						ram_write = ~(write_enable && writeSwitch); //enable ram writing (low-active) if requested
					end
				1'b1: 
					begin
						ram_write = 1; //disable
						if(readSwitch)
						begin
							send_data = 0;
							
							ram_addr = read_addr[18:1];
							ram_upperbyte = read_addr[0];
							ram_lowerbyte = ~read_addr[0];
							ram_write = 1; //low active
						end
						
						if(writeSwitch)
							begin
								ram_addr = write_addr[18:1];
								ram_upperbyte = write_addr[0];
								ram_lowerbyte = ~write_addr[0];
								loc_write_data = write_data;
							end
						
					end
				endcase
				fsm = ~fsm;
		end
	end
endmodule