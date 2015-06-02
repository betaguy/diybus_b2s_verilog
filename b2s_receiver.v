/******************************************************************************************
Author:		Bob Liu
E-mail：	        shuangfeiyanworld@163.com
File Name:	b2s_receiver.v
Function: 	b2s接收端(b2s为bob原创单总线传输协议),默认接收32bit数据
Version:	2013-5-13 v1.0
********************************************************************************************/

module	b2s_receiver
(
	clk,		//时钟基准,不限频率大小,但必须与发送端一致
	b2s_din,	//b2s发送端发送过来的信号
	dout		//b2s接收端解码出的数据
);
parameter	WIDTH=32;	//★设定b2s接收数据位数

input				clk;
input				b2s_din;
output	[WIDTH-1:0]     	dout;


//==================================================
//b2s_din信号边沿检测
//==================================================
reg	[1:0]	b2s_din_edge=2'b01;
always @ (posedge clk)
begin
	b2s_din_edge[0] <= b2s_din;
	b2s_din_edge[1] <= b2s_din_edge[0];
end


//==================================================
//time_cnt - 存储b2c_din信号下降沿及其最近的下一个上升沿之间的时间
//==================================================
reg	[1:0]	state0;
reg	[5:0]	time_cnt_r;
always @ (posedge clk)
begin
	case(state0)
	0:	begin
			time_cnt_r<=0;
			state0<=1;
		end
	1:	begin
			if(b2s_din_edge==2'b10)
				state0<=2;
			else
				state0<=state0;
		end
	2:	begin
			if(b2s_din_edge==2'b01)
				begin
					state0<=0;
				end
			else 
				time_cnt_r<=time_cnt_r+1'b1;
		end
	default:	begin
					time_cnt_r<=0;
					state0<=0;
				end
	endcase
end


wire [5:0]	time_cnt;
assign	time_cnt=(b2s_din_edge==2'b01)?time_cnt_r:'b0;	//当b2s_din上升沿瞬间,读取time_cnt_r的值


//==================================================
//b2s解码时序
//==================================================
reg	[2:0]		state;
reg	[4:0]		count;	//★与接收数据位数保持一致(如接收32bit数据时,count宽度为5;接收8bit时,count宽度为4)
reg	[WIDTH-1:0]	dout_r;
always @ (posedge clk)
begin
	case(state)
	0:	begin
			count<=WIDTH;
			if((time_cnt>15)&&(time_cnt<25))	//判断起始信号
				state<=1;
			else
				state<=state;
		end
	1:	begin
			if((time_cnt>5)&&(time_cnt<15))		//逻辑1的条件
				begin
					dout_r[WIDTH-1]<=1;
					state<=2;
				end
			else if((time_cnt>25)&&(time_cnt<35))//逻辑0的条件
				begin
					dout_r[WIDTH-1]<=0;
					state<=2;
				end
			else
				begin
					state<=state;
				end
		end
	2:	begin
			count<=count-1'b1;	//每读取一个bit,count减1
			state<=3;
		end
	3:	if(count==0)			//数据读取完毕,返回并继续下一组数据的读取
			begin
				state<=0;
			end
		else
			state<=4;			//数据未读取完毕,则进行移位
	4:	begin
			dout_r<=(dout_r>>1);//数据右移1位
			state<=1;
		end
	default:	begin
					state<=0;
					count<=WIDTH;
				end
	endcase
end

assign	dout=(count==0)?dout_r:dout;	//每当一组数据读取完毕,则更新一次dout的值

endmodule	
