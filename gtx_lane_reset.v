`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:48 07/30/2013 
// Design Name: 
// Module Name:    GTX_Lane_Det_Rst 
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
module gtx_lane_reset1 #
	(
		parameter	rst_clk_freq	=	100000000,
		parameter	gtx_clk_freq	=	156250000
	)
	(
		input						rst_clk,				
		input						gtx_clk,				
				
		input						gtx_rst_in,
		output					gtx_rst_out,		
		
		input						rxdisperr_gtx,		
		input						rxlossofsync_gtx,	
		
		output	[9:0]			rst_debug			
		
		
	 );
	
	wire					rst_i;
	wire					start_i;
	wire					request1;
	wire					request2;
	wire					request3;
	wire					request4;
	
assign	request			=	request1 | request2 | request3 | request4;
assign	gtx_rst_out		=	rst_i;

assign	rst_debug[0]	=	rst_i;
assign	rst_debug[1]	=	start_i;

assign	rst_debug[2]	=	request1;
assign	rst_debug[3]	=	request2;
assign	rst_debug[4]	=	request3;
assign	rst_debug[5]	=	request4;

assign	rst_debug[6]	=	request;
assign	rst_debug[7]	=	gtx_rst_out;

assign	rst_debug[8]	=	rxdisperr_gtx;
assign	rst_debug[9]	=	rxlossofsync_gtx;
	
	//-- rx dissperr
	gtx_detect1 #
		(
			.clk_freq			(gtx_clk_freq),
			.timer				(1),
			.req_num				(30)
		)
	gtx_detect_dissperr1
		(
			.rst_in				(rst_i),
			.clk					(gtx_clk),
			
			.state				(rxdisperr_gtx),
			.start				(start_i),
			
			.request				(request1) //output
			
		);
	
	gtx_detect1 #
		(
			.clk_freq			(gtx_clk_freq),
			.timer				(30),
			.req_num				(30)
		)
	gtx_detect_dissperr2
		(
			.rst_in				(rst_i),
			.clk					(gtx_clk),
			
			.state				(rxdisperr_gtx),
			.start				(start_i),
			
			.request				(request2)
			
		);
	
	//-- rx lossofsync
	gtx_detect1 #
		(
			.clk_freq			(gtx_clk_freq),
			.timer				(1),
			.req_num				(30)
		)
	gtx_detect_lossofsync1
		(
			.rst_in				(rst_i),
			.clk					(gtx_clk),
			
			.state				(rxlossofsync_gtx),
			.start				(start_i),
			
			.request				(request3)
			
		);
	
	gtx_detect1 #
		(
			.clk_freq			(gtx_clk_freq),
			.timer				(30),
			.req_num				(30)
		)
	gtx_detect_lossofsync2
		(
			.rst_in				(rst_i),
			.clk					(gtx_clk),
			
			.state				(rxlossofsync_gtx),
			.start				(start_i),
			
			.request				(request4)
			
		);
	
	//-- GTX RESET
	gtx_reset1 #
		(
			.clk_freq			(rst_clk_freq),
			.delay_timer		(1)
			
		)
	gtx_reset_i
		(
			.rst_in				(gtx_rst_in),
			.clk					(rst_clk),
			
			.request				(request),
			.start				(start_i),
			.rst_out				(rst_i)//output
			
		);





endmodule


