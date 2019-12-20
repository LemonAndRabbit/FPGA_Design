`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/12 11:12:46
// Design Name: 
// Module Name: seg7
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


    module seg7(
    output [7:0] anwire,
    output [6:0] ca,
    input clk,
    input [13:0] score
        );
    //Show score usingn seg7
    reg [14:0] segclk_counter;
    reg [3:0] score_1,score_2,score_3,score_4;
    reg [1:0] switch_light;
    reg [3:0] search;
    wire [7:0] temp;
    reg [7:0] an;
    assign anwire=an;
    always@(*)
    begin
        score_4=score/1000;
        score_3=(score/100)%10;
        score_2=(score/10)%10;
        score_1=score%10;
    end
    
    always@(posedge clk)
    begin
        if(segclk_counter<10000)
            segclk_counter<=segclk_counter+1;
        else
        begin
            segclk_counter<=0;
            switch_light<=switch_light+1;
        end            
    end
    
    always@(posedge clk)
    begin
        case(switch_light)
            2'b00  :   an<=8'b11111110;
            2'b01  :   an<=8'b11111101;
            2'b10  :   an<=8'b11111011;
            2'b11  :   an<=8'b11110111;
        endcase  
        case(switch_light)
            2'b00  :   search<=score_1;
            2'b01  :   search<=score_2;
            2'b10  :   search<=score_3;
            2'b11  :   search<=score_4;
        endcase  
    end
    assign ca=~temp[6:0];
    dist_mem_gen_0 myseg7(search,temp);
    endmodule
