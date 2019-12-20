`timescale 1ns / 1ps

module counter16(
	input clk,             // ����ʱ��
	input rst,             // ��λ�ź�
	input [15:0]range,     // ������Χ
	output reg [15:0]value // �������
);

always@(posedge clk or posedge rst) 
begin
	if(rst) value <= 0;
	else if(value == range - 1) value <= 0;
	else value <= value + 1;
end

endmodule
