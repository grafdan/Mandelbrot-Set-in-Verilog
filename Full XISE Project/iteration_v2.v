`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Graf
//
//////////////////////////////////////////////////////////////////////////////////

module iteration(
    input [31:0] zr, // input z value from the previous iteration
    input [31:0] zi,
    input [31:0] cr, // constant starting value c
    input [31:0] ci,
	 input lfinished, // finished flag of last iteration
    output [31:0] nzr, // new z value
    output [31:0] nzi,
    output nfinished  // flag if absolute value reached > 2
    );

	parameter fraction = 20; //number of fraction bits
	parameter prepare = 10; //number of fraction bits that needed to be shifted to the right before multiplying
	parameter [31:0] one = 1<<fraction;
	parameter [31:0] four = 1<<(fraction+2);
			/*
			wire [31:0] zh0r = z0r[31] ? {10'b1111111111, z0r[31:10]} : {10'b0000000000, z0r[31:10]};
			wire [31:0] zh0i = z0i[31] ? {10'b1111111111, z0i[31:10]} : {10'b0000000000, z0i[31:10]};
			
			assign z1r = (zh0r*zh0r) - (zh0i*zh0i) + cr;
			*/
			wire [41:0] zr2 = (zr*zr);//[41:10];
			wire [41:0] zi2 = (zi*zi);//[41:10];
			wire [41:0] zrzi = (zr*zi);//[41:10];
			
			assign nzr = zr2[41:10] - zi2[41:10] + cr;
			
			//assign nzi = ((zh0r*zh0i)<<<1) + ci;
			assign nzi = zrzi[40:9] + ci;

/*
			wire [31:0] zh1r = z1r[31] ? {10'b1111111111, z1r[31:10]} : {10'b0000000000, z1r[31:10]};
			wire [31:0] zh1i = z1i[31] ? {10'b1111111111, z1i[31:10]} : {10'b0000000000, z1i[31:10]};
			wire [31:0] z1a = (zh1r*zh1r)+(zh1i*zh1i);
			*/
			
			wire [31:0] nzabs = zr2[41:10] + zi2[41:10]; //calculate last abs as the squares have already been built
			
			wire nzabs_comp = (nzabs > four) ? 1 : 0;
			
			assign nfinished = lfinished | nzabs_comp;

endmodule
