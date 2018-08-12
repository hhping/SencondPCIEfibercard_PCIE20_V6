`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:08 11/24/2016 
// Design Name: 
// Module Name:    gtx_kcode_check 
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
module gtx_kcode_check
	(
		input						rst,
		input						clk,
		input		[1:0]			charisk,
		input		[15:0]		gtx_rx,
		output	reg			err
		
	 );
	 
	 always @(posedge clk)
	 begin
		if(rst) begin
			err	<=	1'b0;
		end
		else begin
			if(charisk == 2'b11) begin
				if((gtx_rx == 16'hBCDC) || (gtx_rx == 16'hFEFE) || (gtx_rx == 16'h1C1C) || (gtx_rx == 16'h3C3C) ||
					(gtx_rx == 16'h5C5C)	|| (gtx_rx == 16'h7C7C) || (gtx_rx == 16'h9C9C) || (gtx_rx == 16'h7C9C) ||
					(gtx_rx == 16'h9C7C)) begin
					err	<=	1'b0;
				end
				else begin
					err	<=	1'b1;
				end
			end
			else begin
				err	<=	err;
			end
		end
	 end
	 
	 
	 
	 


endmodule
