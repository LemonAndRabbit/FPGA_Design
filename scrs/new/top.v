`timescale 1ns / 1ps

module top(
    input ps2_clk,
    input ps2_data,
    input clk,
    input rst,
    output [1:0] vgaRed,
    output [2:0] vgaGreen,
    output [2:0] vgaBlue,
    output vgaHsync,
    output vgaVsync,
    output [15:0]  LED,
    output [6:0] ca,
    output [7:0] an
);
    reg [9:0] person_x;
    reg [8:0] person_y;
    reg dead;
    reg final;
    reg [1:0] life;
    reg [13:0] score;
    reg [8:0] gravity;
    wire hard;    
//VGA MODULE
    wire vgaclk;
    wire [8:0]row0;
    wire [8:0]row;
    wire [9:0]column;
    wire [7:0]color;
    reg [1:0] temp_clk50MHz;//50MHz clk
    always@(posedge clk)    temp_clk50MHz <= temp_clk50MHz + 1;
    vga myvga(temp_clk50MHz[1], rst, vgaclk, row0, column, color, vgaRed, vgaGreen, vgaBlue, vgaHsync, vgaVsync);

//Hard mode,change the way of vga printing
    assign hard=(score>=10)?1:0;
    assign row=(hard)?(9'd479-row0):row0;

//Get the background
    wire [7:0] background_color;
    background mybackground(.clk(vgaclk),.row(row),.column(column),.color(background_color));

//Scan the keyboard and change person_x
    wire W,A,S,D;
    keyboard mykeyboard(.clk(clk),.rst(rst),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.W(W),.S(S),.A(A),.D(D));
    reg [22:0] counter_30Hz;
    reg clk_30Hz;
    parameter my30Hz=666666;
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            clk_30Hz<=1'b0;
            counter_30Hz<=23'b0;
        end
        else
        begin
            if(counter_30Hz<my30Hz)
                counter_30Hz<=counter_30Hz+1'b1;
            else
            begin
                counter_30Hz<=22'b0;
                clk_30Hz<=~clk_30Hz;
            end
        end        
    end
    always@(posedge clk_30Hz or posedge rst)
    begin
        if(rst)
        begin
            person_x<=10'b0;
//            person_y<=9'b0;
        end
        else if(D)
        begin
            if(person_x<610)
                person_x<=person_x+1'b1;
        end
        else if(A)
        begin
            if(person_x>0)
                person_x<=person_x-1'b1;
        end
    end

//Test the keyboard
    assign LED[7:0]=D?8'hff:8'h00;
    assign LED[15:8]=A?8'hff:8'h00;

//Generate and move the boards
    parameter board_speed=2000000;
    reg [23:0] board_counter;
    reg clk_board;
    reg [9:0] random_x;
    reg board_1; 
    reg [8:0] board_1_y;
    reg [9:0] board_1_x;
    reg board_2;
    reg [8:0] board_2_y;
    reg [9:0] board_2_x;
    reg board_3;
    reg [8:0] board_3_y;
    reg [9:0] board_3_x;
    reg board_4;
    reg [8:0] board_4_y;
    reg [9:0] board_4_x;

    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            clk_board<=1'b0;
            board_counter<=23'b0;
            random_x<=10'b1111101000;
        end
        else
        begin
            if(board_counter[0])
                random_x<={random_x[1]^random_x[4]^(~random_x[7]),random_x[9]^random_x[7],random_x[2]^random_x[4]^random_x[8],random_x[6:0]};
            if(board_counter<board_speed)
                board_counter<=board_counter+1;
            else
            begin
                board_counter<=22'b0;
                clk_board<=~clk_board;
            end
        end        
    end

//Move person_y
    wire on_board_1;
    wire on_board_2;
    wire on_board_3;
    wire on_board_4;
    assign on_board_1=(person_y+9'd44<=board_1_y&&person_y+9'd45+gravity>=board_1_y&&person_x+10'd20>=board_1_x&&person_x<=board_1_x+10'd239)?1:0;
    assign on_board_2=(person_y+9'd44<=board_2_y&&person_y+9'd45+gravity>=board_2_y&&person_x+10'd20>=board_2_x&&person_x<=board_2_x+10'd239)?1:0;
    assign on_board_3=(person_y+9'd44<=board_3_y&&person_y+9'd45+gravity>=board_3_y&&person_x+10'd20>=board_3_x&&person_x<=board_3_x+10'd239)?1:0;
    assign on_board_4=(person_y+9'd44<=board_4_y&&person_y+9'd45+gravity>=board_4_y&&person_x+10'd20>=board_4_x&&person_x<=board_4_x+10'd239)?1:0;
    
    
    
//Move person_y & boards_y
            
    always@(posedge clk_board or posedge rst)
    begin
        if(rst)
        begin
            board_1<=1'b1;
            board_1_y<=9'd119;
            board_1_x<=10'd199;
            board_2<=1'b1;
            board_2_y<=9'd239;
            board_2_x<=10'd0; 
            board_3<=1'b1;  
            board_3_y<=9'd359;
            board_3_x<=10'd199;  
            board_4<=1'b1;  
            board_4_y<=9'd479;
            board_4_x<=10'd299;
            
            dead<=0;
            score<=0;
            life<=2;
            final<=0;
            
            person_y<=9'd1;
            gravity<=9'd1;          
        end
        
        else if(~final)
        begin
            if(~board_1)
            begin
                score<=score+1;
                board_1<=1'b1;
                board_1_y<=9'd480;
                board_1_x<=random_x>512?(random_x-512):random_x;
            end
            else
            begin
                if(board_1_y>0)
                    board_1_y<=board_1_y-1;
                else
                    board_1<=0;    
            end
             
            if(~board_2)
            begin
                score<=score+1;
                board_2<=1'b1;
                board_2_y<=9'd480;
                board_2_x<=random_x>512?(random_x-512):random_x;                
            end
            else
            begin
                if(board_2_y>0)
                    board_2_y<=board_2_y-1;
                else
                    board_2=0;
            end
            
            if(~board_3)
            begin
                score<=score+1;
                board_3<=1'b1;
                board_3_y<=9'd480;
                board_3_x<=random_x>512?(random_x-512):random_x;                
            end
            else
            begin
                if(board_3_y>0)
                    board_3_y<=board_3_y-1;
                else
                    board_3<=0;    
            end
            
              
            if(~board_4)
            begin
                score<=score+1;
                board_4<=1'b1;
                board_4_y<=9'd480;
                board_4_x<=random_x>512?(random_x-512):random_x;                
            end
            else
            begin
                if(board_4_y>0)
                    board_4_y<=board_4_y-1;
                else
                    board_4<=0;
            end
              
            if(dead)
            begin
                if(life==0)
                    final<=1;
                else
                begin
                    person_y<=9'd2;
                    dead<=0;
                    gravity<=9'd1;
                    life<=life-1;
                end
            end
            else if(person_y==9'd0||((~on_board_1)&&(~on_board_2)&&(~on_board_3)&&(~on_board_4)&&person_y + gravity >=9'd480))
                dead<=1;
            else if(on_board_1)
            begin
                person_y<=board_1_y-9'd45;
                gravity<=9'd1;
            end
            else if(on_board_2)
            begin
                person_y<=board_2_y-9'd45;
                gravity<=9'd1;
            end
            else if(on_board_3)
            begin
                person_y<=board_3_y-9'd45;
                gravity<=9'd1;
            end
            else if(on_board_4)
            begin
                person_y<=board_4_y-9'd45;
                gravity<=9'd1;
            end
            else
            begin
                if(gravity<9'd9)
                    gravity<=gravity+2;
                person_y<=person_y+gravity;
            end           
        end
        //if final==true:Nothing to do
    
    end
    
//Show boards
    wire showboards;
    wire showboard_1;
    wire showboard_2;
    wire showboard_3;
    wire showboard_4;
    wire prepare_showboard_1;
    wire prepare_showboard_2;
    wire prepare_showboard_3;
    wire prepare_showboard_4;
    reg [18:0] location_board;
    wire [7:0] color_board;
    
    assign prepare_showboard_1=(column>=board_1_x&&column<=board_1_x+10'd239&&row>=board_1_y&&row<=board_1_y+9'd29)?1:0;
    assign prepare_showboard_2=(column>=board_2_x&&column<=board_2_x+10'd239&&row>=board_2_y&&row<=board_2_y+9'd29)?1:0;
    assign prepare_showboard_3=(column>=board_3_x&&column<=board_3_x+10'd239&&row>=board_3_y&&row<=board_3_y+9'd29)?1:0;
    assign prepare_showboard_4=(column>=board_4_x&&column<=board_4_x+10'd239&&row>=board_4_y&&row<=board_4_y+9'd29)?1:0;
    
    assign showboard_1=(column>=board_1_x+10'd7&&column<=board_1_x+10'd239&&row>=board_1_y&&row<=board_1_y+9'd29)?1:0;
    assign showboard_2=(column>=board_2_x+10'd7&&column<=board_2_x+10'd239&&row>=board_2_y&&row<=board_2_y+9'd29)?1:0;
    assign showboard_3=(column>=board_3_x+10'd7&&column<=board_3_x+10'd239&&row>=board_3_y&&row<=board_3_y+9'd29)?1:0;
    assign showboard_4=(column>=board_4_x+10'd7&&column<=board_4_x+10'd239&&row>=board_4_y&&row<=board_4_y+9'd29)?1:0;
    assign showboards=(showboard_1|showboard_2|showboard_3|showboard_4)&&(color_board!=8'hC1);
    always@(*)
    begin
        location_board=prepare_showboard_1?((row-board_1_y)*240+column-board_1_x):prepare_showboard_2?((row-board_2_y)*240+column-board_2_x):prepare_showboard_3?((row-board_3_y)*240+column-board_3_x):((row-board_4_y)*240+column-board_4_x);
    end
    blk_mem_gen_2 color_myboards(.addra(location_board[12:0]),.clka(vgaclk),.douta(color_board)); 

//Show life
    wire showlife_1,showlife_2,showlife_3;
    wire pre_showlife_1,pre_showlife_2,pre_showlife_3;
    wire showlife;
    reg [18:0] location_life;
    wire [7:0] color_life;
    assign showlife_1=(column>=10'd530)&&(column<10'd560)&&(row0>9'd1)&&(row0<9'd29)&&(life[1]);
    assign showlife_2=(column>=10'd570)&&(column<10'd600)&&(row0>9'd1)&&(row0<9'd29)&&(life[1]|life[0]);
    assign showlife_3=(column>=10'd610)&&(row0>9'd1)&&(row0<9'd29);
    
    assign pre_showlife_1=(column>=10'd522)&&(column<10'd560)&&(row0<9'd29);
    assign pre_showlife_2=(column>=10'd562)&&(column<10'd600)&&(row0<9'd29);
    assign pre_showlife_3=(column>=10'd602)&&(row0<9'd29);
    
    
    always@(*)
        location_life=pre_showlife_1?(row0*30+column-10'd530):pre_showlife_2?(row0*30+column-10'd570):(row0*30+column-10'd610);
    
    blk_mem_gen_4 mylife(.addra(location_life[9:0]),.clka(vgaclk),.douta(color_life));
    assign showlife=(showlife_1|showlife_2|showlife_3)&&(color_life!=8'hff);
//Calculate color to print
    wire showperson;
    reg [18:0] location;
    wire [7:0] color_person_l;
    wire [7:0] color_person_r;
    wire [7:0] color_person;
    always@(*)
    begin
        location=(row-person_y)*30+(column-person_x);   
    end
    blk_mem_gen_1(.addra(location[10:0]),.clka(vgaclk),.douta(color_person_r));
    blk_mem_gen_3 person_right(.addra(location[10:0]),.clka(vgaclk),.douta(color_person_l));
    assign color_person=A?color_person_l:color_person_r;
    
    assign showperson=(column>=person_x+2&&column<=person_x+10'd29&&row>=person_y&&row<=person_y+9'd44&&!(color_person==8'hC1))?1:0;
    assign color=final?8'hC1:showlife?color_life:showperson?color_person:showboards?color_board:background_color;

    //seg7
    seg7 myseg7(.anwire(an),.ca(ca),.clk(clk),.score(score));
            
endmodule
