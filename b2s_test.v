/******************************************************************************************
Author:		Bob Liu
E-mail：	shuangfeiyanworld@163.com
Function: 	b2s功能测试：通过b2s transmitter模块将预置的32bit数据进行发送,然后通过b2s 							
			receiver模块进行接收解码,将解码出的32bit数据分批输出到8个led上显示
Version:	2013-5-13 v1.0
********************************************************************************************/

module b2s_test
(
	input			clk,
	output	[7:0]	led		//显示解码后的32bit数据(分批次,每次显示8bit)
);
parameter	WIDTH=32;		//设定b2s发送和接收数据位数


//==============================================================
//预置待发送数据 - just for test
//==============================================================
/**/
wire	[WIDTH-1:0]	din;
assign	din='b01010101_00111100_11011100_11001111;


//================================
//b2s_transmitter module instance
//================================
wire b2s_dout;
b2s_transmitter		
#
(
	.WIDTH(WIDTH)		//自定义发送数据位数
) 
b2s_transmitter_isnt0
(
	.clk(clk),			//时钟基准,不限频率大小,但必须与接收端一致
	.din(din),			//待发送数据
	.b2s_dout(b2s_dout)	//b2s数据输出端口
);


//================================
//b2s_receiver module instance
//================================
wire [WIDTH-1:0]	dout;
b2s_receiver		
#
(
	.WIDTH(WIDTH)		//自定义接收数据位数
)
b2s_receiver_inst0
(
	.clk(clk),			//时钟基准,不限频率大小,但必须与发送端一致
	.b2s_din(b2s_dout),	//b2s发送端发送过来的信号
	.dout(dout)			//b2s接收端解码出的数据
);


//================================
//通过8个LED显示解码后的32bit数据(分批次,每次显示8bit)
//================================
assign	led=dout[23:16];


endmodule	
