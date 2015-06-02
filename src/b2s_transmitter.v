/******************************************************************************************
Author:		Bob Liu
E-mail：	shuangfeiyanworld@163.com
File Name:	b2s_transmitter.v
Function: 	b2s发送端(b2s为bob原创单总线传输协议),默认发送32bit数据
Version:	2013-5-13 v1.0
********************************************************************************************/
 
module	b2s_transmitter
(
	clk,			//时钟基准,不限频率大小,但必须与接收端一致
	din,			//待发送数据
	b2s_dout		//b2s数据输出端口
);
parameter	WIDTH=32;	//★设定b2s发送数据位数

input				clk;
input	[WIDTH-1:0]	din;
output				b2s_dout;


//==============================================================
//b2s数据发送时序
//==============================================================
reg			b2s_dout_r;
reg	[3:0]	state;
reg	[9:0]	cnt;
reg	[4:0]	count;	//★与发送数据位数保持一致(如发送32bit数据时,count宽度为5;发送8bit时,count宽度为4)
always @ (posedge clk)
begin
	case(state)
//初始化
	0:	begin
			count<=0;
			b2s_dout_r<=1;
			if(cnt==19)		//b2s_dout_r高电平持续20个时钟
				begin
					state<=1;
					cnt<=0;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end

//开始信号时序
	1:	begin
			b2s_dout_r<=0;
			if(cnt==19)		//b2s_dout_r低电平持续20个时钟
				begin
					state<=2;
					cnt<=0;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end
	2:	begin
			b2s_dout_r<=1;
			if(cnt==19)		//b2s_dout_r高电平持续20个时钟
				begin
					cnt<=0;
					state<=3;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end

//待发送数据的逻辑电平判断
	3:	begin
			if(din[count]==1)
				state<=4;
			else
				state<=8;
		end

//逻辑1的发送时序
	4:	begin
			b2s_dout_r<=0;
			if(cnt==9)		//b2s_dout_r低电平持续10个时钟
				begin
					cnt<=0;
					state<=5;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end
	5:	begin
			b2s_dout_r<=1;
			if(cnt==29)		//b2s_dout_r高电平持续30个时钟
				begin
					cnt<=0;
					state<=6;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end

//逻辑0的发送时序
	8:	begin
			b2s_dout_r<=0;
			if(cnt==29)		//b2s_dout_r低电平持续30个时钟
				begin
					cnt<=0;
					state<=9;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end
	9:	begin
			b2s_dout_r<=1;
			if(cnt==9)		//b2s_dout_r高电平持续10个时钟
				begin
					cnt<=0;
					state<=6;
				end
			else
				begin
					cnt<=cnt+1;
				end
		end

//统计已发送数据位数
	6:	begin
			count<=count+1'b1;
			state<=7;
		end
	7:	begin
			if(count==WIDTH)	//当一组数据所有位发送完毕,返回并继续下一次发送
				begin
					b2s_dout_r<=1;
					if(cnt==999)	//b2s_dout_r高电平持续1000个时钟
						begin
							cnt<=0;
							state<=0;
						end
					else
						begin
							cnt<=cnt+1;
						end
				end
			else				//当一组数据未发送完毕,则继续此组下一位数据的发送
				state<=3;
		end
		
//default值设定
	default:	begin
					state<=0;
					cnt<=0;
					count<=0;
				end
	endcase
end

assign	b2s_dout=b2s_dout_r;

endmodule	
