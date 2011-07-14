`timescale 1ns / 1ps
module mandelbrot(
	input iteration_clk,
	input reset,
	input [3:0] direction,
	input [3:0] zoom,
	output reg [18:0] write_address,
	output reg [2:0] write_data,
	output reg write_enable,
	output [7:0] debug_pos
    );


	parameter fraction = 20; //number of fraction bits
	parameter prepare = 10; //number of fraction bits that needed to be shifted to the right before multiplying
	parameter [31:0] one = 1<<fraction;
	parameter [31:0] unit = 64; //unit length in pixels
	parameter unitlen = 6;
	parameter direction_shift = 10;
	parameter max_iter = 32;
   reg [9:0] posx;
   reg [9:0] posy;
	
	reg [31:0] x;
	reg [31:0] y;
	reg [31:0] cr;
	reg [31:0] ci;
	
	//current state
	reg [31:0] zr;
	reg [31:0] zi;
	reg lfinished;

	//next state
	wire [31:0] nzr;
	wire [31:0] nzi;
	wire nfinished;
	
	reg [2:0] result;
	
	reg [9:0] xoffset = 400;
	reg [9:0] yoffset = 240;

	reg [5:0] iter_counter;
	
	iteration i_iter(.zr(zr), .zi(zi), .cr(cr), .ci(ci), .lfinished(lfinished), .nzr(nzr), .nzi(nzi), .nfinished(nfinished)); 

	//update position
	wire new_frame = ((posx == 0) && (posy == 0));
	always @ (posedge new_frame)
	begin
		if(direction[3]) xoffset = xoffset - direction_shift; //move left
		if(direction[2]) xoffset = xoffset + direction_shift; //move right
		if(direction[1]) yoffset = yoffset + direction_shift; //move up
		if(direction[0]) yoffset = yoffset - direction_shift; //move down
	end
	
	
	//update pixel position that is currently calculated
	reg new_pixel;
	wire finished_pixel = lfinished;
	wire continue_with_pixel = (!finished_pixel)&&(!new_pixel);
	//wire new_pixel_clk = (iteration_clk && new_pixel);
	
	always @ (posedge iteration_clk, posedge reset)
	begin
		if(reset)
		begin
			posx = 0;
			posy = 0;
			iter_counter = 1;
			lfinished = 0;
			write_enable = 0;
			new_pixel = 1;
		end
		else
		begin
			//start with the calculation of a new pixel
			if(new_pixel)
			begin
				posx = posx+1;
				if(posx >= 640)
				begin
					posx = 0;
					posy = posy+1;
				end
				if(posy >= 480)
				begin
					posx = 0;
					posy = 0;
				end
				
				//calculate initial data for the new pixel
				x = posx - xoffset;
				y = yoffset - posy;
				cr = (x<<<(fraction-unitlen-zoom));
				ci = (y<<<(fraction-unitlen-zoom));
				zr = cr;
				zi = ci;
				
				//reset RAM interaction
				iter_counter = 1;
				lfinished = 0;
				write_enable = 0;
				new_pixel = 0;
			end
			
			else
			begin
				//copy next state of the FSM and proceed with next iteration
				if(continue_with_pixel)
				begin
					zr = nzr;
					zi = nzi;
					if(iter_counter == max_iter)
						lfinished = 1;
					else
						lfinished = nfinished;
					
					if(lfinished)
					begin
						result = iter_counter[2:0];
					end
					else
					begin
						iter_counter = iter_counter + 1;
					end
				end
				
				else
				begin
					//end of pixel calculation => save to RAM
					if(finished_pixel)
					begin
						write_address = {posy[8:0],posx[9:0]};
						write_data = result;
						write_enable = 1;
						new_pixel = 1;
					end
					else
					begin
						//preserve previous state
						//should never happen as simulation always has progress
					end
				end
			end
		end
	end
	
	
	//debug
	assign debug_pos = {posy[1:0],posx[5:1],new_pixel};
	

	/*
initial
	$monitor("At time %t, posx %d, x %d,  posy %d, y %d rgb was %b, cr %d, ci %d, z1r %d z1i %d, z2r %d z2i %d, abs1 %d, abs2 %d, result1 %d, result2 %d, f1 %d, f2 %d" ,$time,posx, x, posy,y,rgb,cr,ci,z1r,z1i,z2r,z2i,abs1,abs2,result1, result2,finished1,finished2);
*/

endmodule
