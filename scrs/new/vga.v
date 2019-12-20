`timescale 1ns / 1ps

module vga(
	input clk,            
	input rst,            
	output vgaclk,        
	output [8:0]row,      
	output [9:0]column,   
	input [7:0]color,     
	output [1:0]vgaRed,   
	output [2:0]vgaGreen, 
	output [2:0]vgaBlue,  
	output vgaHsync,      
	output vgaVsync       
);

	
	parameter CLKF = 50;      
	parameter H_SYNC = 96;    
	parameter H_BEGIN = 144;  
	parameter H_END = 784;    
	parameter H_PERIOD = 800; 
	parameter V_SYNC = 2;     
	parameter V_BEGIN = 31;   
	parameter V_END = 511;    
	parameter V_PERIOD = 521; 

	assign vgaclk = clk ;

	wire [9:0]hcount;
	counter16 hc(vgaclk, rst, H_PERIOD, hcount);
	assign vgaHsync = (hcount < H_SYNC) ? 0 : 1;
	assign column = hcount - H_BEGIN;

	wire [9:0]vcount;
	counter16 vc(~(hcount[9]), rst, V_PERIOD, vcount);
	assign vgaVsync = (vcount < V_SYNC) ? 0 : 1;
	assign row = vcount - V_BEGIN;

	wire de;
	assign de = (vcount >= V_BEGIN) && (vcount < V_END) && (hcount >= H_BEGIN) && (hcount < H_END);
	assign vgaRed = de ? color[7:6] : 0;
	assign vgaGreen = de ? color[5:3] : 0;
	assign vgaBlue = de ? color[2:0] : 0;

endmodule
