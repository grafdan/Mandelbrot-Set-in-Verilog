`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Graf
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:35:43 05/09/2011 
// Design Name: 
// Module Name:    iteration 
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
			
			wire [31:0] zh0r = zr[31] ? {10'b1111111111, zr[31:10]} : {10'b0000000000, zr[31:10]};
			wire [31:0] zh0i = zi[31] ? {10'b1111111111, zi[31:10]} : {10'b0000000000, zi[31:10]};
			
			assign nzr = (zh0r*zh0r) - (zh0i*zh0i) + cr;
			assign nzi = ((zh0r*zh0i)<<<1) + ci;
			
			wire [31:0] zh1r = nzr[31] ? {10'b1111111111, nzr[31:10]} : {10'b0000000000, nzr[31:10]};
			wire [31:0] zh1i = nzi[31] ? {10'b1111111111, nzi[31:10]} : {10'b0000000000, nzi[31:10]};
			wire [31:0] z1a = (zh1r*zh1r)+(zh1i*zh1i);
			wire z1b = (z1a > 4*one) ? 1 : 0;
			assign nfinished = lfinished | z1b;

endmodule
