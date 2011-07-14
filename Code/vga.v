module vga(input clk, input reset, input [3:0] buttons, input [7:1] switches, output red, output green, output blue, output reg hsync, output reg vsync, 
	output [7:0] deb,/* Outputs to RAM */ inout [5:0] ram_data, output [17:0] ram_addr, output ram_write, output ram_output, output ram_chipenable, output ram_upperbyte, output ram_lowerbyte);

	reg [9:0] posx;	//Bildschirmkoordinaten (nullbasiert)
	reg [9:0] posy;
	
	reg syncing;

	wire vclk;
	video_clk my_vclk(.clk(clk), .reset(reset), .vclk(vclk));
	
	//horizontal
	parameter HD = 10'd640;	//Sichtbare Pixel
	parameter HFP = 10'd16;	//Anzahl Pixel der horizontalen vorderen Schwarzschulter
	parameter HS = 10'd96;	//Anzahl Pixel des horizontalen Synchronimpulses
	parameter HBP = 10'd48;	//Anzahl Pixel der horizontalen Schwarzschulter

	//vertikal
	parameter VD = 10'd480;	//Sichtbare Zeilen
	parameter VFP = 10'd10;	//Anzahl der Zeilen der vertikalen vorderen Schwarzschulter    
	parameter VS = 10'd2;	//Anzahl der Zeilen des vertikalen Synchronimpulses
	parameter VBP = 10'd33;	//Anzahl der Zeilen der vertikalen hinteren Schwarzschulter   


	always @ (posedge vclk, posedge reset)
	begin
		if (reset)
		begin			
			posx = HD;
			posy = VD;
			hsync = 0;
			vsync = 0;
			syncing = 1;
		end
		else
		begin
			posx = posx + 1'b1;

			if (syncing)
			begin
				
				hsync = ((HD+HFP) <= posx) && (posx < (HD+HFP+HS));
					

				if (posx == (HD+HFP+HS+HBP)) //Zeile vollständig mit sync (nullbasiert)
				begin
					posx = 10'b0;
					posy = posy + 1'b1;
				end


				vsync = ((VD+VFP) < posy) && (posy < (VD+VFP+VS));

				if (posy == (VD+VFP+VS+VBP)) //Bild vollständig mit syncs
				begin
					posy = 10'b0;
				end


				syncing = (posy >= VD) || (posx >= HD);
			end
			else
			begin
				if (posx == HD) //erster Pixel ausserhalb des Bildschirms (nullbasiert)
					syncing = 1;

			end
		end
	end


	wire [18:0] write_address;
	wire [2:0] write_data;
	wire write_enable;
	
	wire [18:0] read_address;
	wire [2:0] read_data;
	assign read_address = {posy[8:0],posx[9:0]};
	
	ram graphic_ram(.clk(clk), .reset(reset), .read_addr(read_address), .read_data(read_data), .write_addr(write_address), .write_data(write_data),
	.write_enable(write_enable), .ram_data(ram_data), .ram_addr(ram_addr), .ram_write(ram_write), .ram_output(ram_output),
	.ram_chipenable(ram_chipenable), .ram_upperbyte(ram_upperbyte), .ram_lowerbyte(ram_lowerbyte),
	.readSwitch(switches[3]), .writeSwitch(switches[2]));
    

	//wire mclk = ~vclk;
	
/*	reg read_cycle;
	reg [25:0] counter;
	
	always @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			counter = 26'b0;
			read_cycle = 0;
		end
		else
		begin
			if (counter == 26'd2000)
			begin
				read_cycle = ~read_cycle;
				counter = 26'd0;
			end
			counter = counter + 1'b1;
		end
	end*/
	
	mandelbrot mandel(.iteration_clk(vclk/*read_cycle*/), .reset(reset), .direction(buttons[3:0]), .zoom(switches[7:4]), .write_address(write_address), .write_data(write_data), .write_enable(write_enable), .debug_pos(deb));


	wire [2:0] shift;
	assign shift = switches[3:1];
	wire [2:0] dot;
	assign dot = read_data;// + shift;

	assign red = syncing ? 0 : dot[2];
	assign green = syncing ? 0 : dot[1];
	assign blue = syncing ? 0 : dot[0];
	
endmodule
