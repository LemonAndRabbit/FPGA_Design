`timescale 1ns / 1ps

module keyboard(
input clk,
input rst,
input ps2_clk,
input ps2_data,
output  W,
output  S,
output  A,
output  D
    );
reg ps2_clk_r0,ps2_clk_r1,ps2_clk_r2;
wire neg_ps2_clk;

always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        ps2_clk_r0<=1'b0;
        ps2_clk_r1<=1'b0;
        ps2_clk_r2<=1'b0;
    end
    else
    begin
        ps2_clk_r0<=ps2_clk;
        ps2_clk_r1<=ps2_clk_r0;
        ps2_clk_r2<=ps2_clk_r1;
    end
end
assign neg_ps2_clk=ps2_clk_r2&(~ps2_clk_r1);//the negedge of ps2_clk

reg [7:0] ps2_byte_r;
reg [7:0] temp_data;
reg [3:0] num;  //to record the order of keyboard input

always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        num<=4'b0;
        temp_data<=8'b0;
    end
    else if(neg_ps2_clk)
    begin
        case (num)
            4'd0:   num<=num+1'b1;
            4'd1:   begin
                    num<=num+1'b1;
                    temp_data[0]<=ps2_data;
                    end
            4'd2:   begin
                    num<=num+1'b1;
                    temp_data[1]<=ps2_data;
                    end
            4'd3:   begin
                    num<=num+1'b1;
                    temp_data[2]<=ps2_data;
                    end
            4'd4:   begin
                    num<=num+1'b1;
                    temp_data[3]<=ps2_data;
                    end 
            4'd5:   begin
                    num<=num+1'b1;
                    temp_data[4]<=ps2_data;
                    end 
            4'd6:   begin
                    num<=num+1'b1;
                    temp_data[5]<=ps2_data;
                    end
            4'd7:   begin
                    num<=num+1'b1;
                    temp_data[6]<=ps2_data;
                    end 
            4'd8:   begin
                    num<=num+1'b1;
                    temp_data[7]<=ps2_data;
                    end 
            4'd9:   begin
                    num<=num+1'b1;
                    end
            4'd10:  begin
                    num<=4'b0;
                    end
            default:num<=4'd0;
      endcase                                                                              
    end
end

reg key_f0;
reg Wr,Sr,Ar,Dr;
assign W=Wr;
assign A=Ar;
assign D=Dr;
assign S=Sr;
always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        key_f0<=1'b0;
        Wr<=1'b0;
        Sr<=1'b0;
        Ar<=1'b0;
        Dr<=1'b0;
    end
    else if (num==4'd10)
    begin
        if(temp_data==8'hf0)
            key_f0<=1'b1;
        else
        begin
            if(key_f0)
            begin
                Wr<=1'b0;
                Sr<=1'b0;
                Ar<=1'b0;
                Dr<=1'b0;
                key_f0<=1'b0;
            end
            else
            begin     
               case(temp_data)
                    8'h1d:  Wr<=1'b1;
                    8'h1b:  Sr<=1'b1;
                    8'h1c:  Ar<=1'b1;
                    8'h23:  Dr<=1'b1;
               endcase 
            end
        end
    end
end
endmodule
/*
module keyborad(
	clk, rst_n,
	ps2_clk, ps2_data,
	ps2_byte, ps2_state
    );
	
	input clk;
	input rst_n;
	input ps2_clk;
	input ps2_data;
	output [7:0] ps2_byte;	// ps2扫描值
	output ps2_state;
	
	//-----------------------------------------------------
	// 捕获PS/2键盘下降沿
	reg ps2_clk_r0,ps2_clk_r1,ps2_clk_r2;
	wire neg_ps2_clk;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			ps2_clk_r0 <= 1'b0;
			ps2_clk_r1 <= 1'b0;
			ps2_clk_r2 <= 1'b0;
		end
		else begin
			ps2_clk_r0 <= ps2_clk;
			ps2_clk_r1 <= ps2_clk_r0;
			ps2_clk_r2 <= ps2_clk_r1;
		end	
	end // end always
	
	assign neg_ps2_clk = ps2_clk_r2 & (~ps2_clk_r1);
	
	//------------------------------------------------------
	// 接受来自PS/2键盘的数据存储器
	reg [7:0] ps2_byte_r;		// 来自PS/2的数据寄存器
	reg [7:0] temp_data;			// 当前接受数据寄存器
	reg [3:0] num;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			num <= 4'd0;
			temp_data <= 8'd0;
		end
		else if (neg_ps2_clk) begin
			case (num)
				4'd0: begin
					num <= num + 1'b1;
				end
				4'd1: begin
					num <= num + 1'b1;
					temp_data[0] <= ps2_data;
				end
				4'd2: begin
					num <= num + 1'b1;
					temp_data[1] <= ps2_data;
				end
				4'd3: begin
					num <= num + 1'b1;
					temp_data[2] <= ps2_data;
				end
				4'd4: begin
					num <= num + 1'b1;
					temp_data[3] <= ps2_data;
				end
				4'd5: begin
					num <= num + 1'b1;
					temp_data[4] <= ps2_data;
				end
				4'd6: begin
					num <= num + 1'b1;
					temp_data[5] <= ps2_data;
				end
				4'd7: begin
					num <= num + 1'b1;
					temp_data[6] <= ps2_data;
				end
				4'd8: begin
					num <= num + 1'b1;
					temp_data[7] <= ps2_data;
				end
				4'd9: begin
					num <= num + 1'b1;
				end
				4'd10: begin
					num <= 4'b0;
				end
				default: num <= 4'd0;
			endcase
		end
	end // end always
	
	
	//-------------------------------------
	reg key_f0;				// 松键标志位
	reg ps2_state_r;		// 当前状态,高电平表示有键按下
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			key_f0 <= 1'b0;
			ps2_state_r <= 1'b0;
			ps2_byte_r <= 8'd0;
		end
		else if (num == 4'd10) begin	// 刚传输一个字节
			if (temp_data == 8'hf0)	begin // 断码的第一个字节
				key_f0 <= 1'b1;
			end	
			else begin
				if (key_f0) begin	// 存储通码
					ps2_state_r <= 1'b1;
					ps2_byte_r <= temp_data;
					key_f0 <= 1'b0;
				end
				else begin
					ps2_state_r <= 1'b0;
					key_f0 <= 1'b0;
				end
			end	
		end
		else	ps2_state_r <= 1'b0;
	end // end always
	
	//---------------------------------------
	reg [7:0] ps2_ascii;	//接受相应的asciiI
	
	always @(posedge clk) begin
		case (ps2_byte_r)
			8'h15: ps2_ascii = 8'h51;	//Q
			8'h1d: ps2_ascii = 8'h57;	//W
			8'h24: ps2_ascii = 8'h45;	//E
			8'h2d: ps2_ascii = 8'h52;	//R
			8'h2c: ps2_ascii = 8'h54;	//T
			8'h35: ps2_ascii = 8'h59;	//Y
			8'h3c: ps2_ascii = 8'h55;	//U
			8'h43: ps2_ascii = 8'h49;	//I
			8'h44: ps2_ascii = 8'h4f;	//O
			8'h4d: ps2_ascii = 8'h50;	//P				  	
			8'h1c: ps2_ascii = 8'h41;	//A
			8'h1b: ps2_ascii = 8'h53;	//S
			8'h23: ps2_ascii = 8'h44;	//D
			8'h2b: ps2_ascii = 8'h46;	//F
			8'h34: ps2_ascii = 8'h47;	//G
			8'h33: ps2_ascii = 8'h48;	//H
			8'h3b: ps2_ascii = 8'h4a;	//J
			8'h42: ps2_ascii = 8'h4b;	//K
			8'h4b: ps2_ascii = 8'h4c;	//L
			8'h1a: ps2_ascii = 8'h5a;	//Z
			8'h22: ps2_ascii = 8'h58;	//X
			8'h21: ps2_ascii = 8'h43;	//C
			8'h2a: ps2_ascii = 8'h56;	//V
			8'h32: ps2_ascii = 8'h42;	//B
			8'h31: ps2_ascii = 8'h4e;	//N
			8'h3a: ps2_ascii = 8'h4d;	//M
			default	ps2_ascii = 8'hfe;
		endcase	
	end
	
	assign ps2_byte = ps2_ascii;
	assign ps2_state = ps2_state_r;

endmodule
*/