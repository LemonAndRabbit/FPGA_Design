`timescale 1ns / 1ps

module background(
input clk,
input [8:0] row,
input [9:0] column,
output [7:0] color
);
reg [18:0] pos;
always@(*)
    pos=row*640+column;
blk_mem_gen_0(.addra(pos),.clka(clk),.douta(color));


endmodule
