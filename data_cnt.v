`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:51:47 01/06/2017 
// Design Name: 
// Module Name:    data_cnt 
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
module data_cnt
	(
		input							rst,
		input							clk,
		
		input							en,
		output	reg	[47:0]	cnt
		
		
	);


always @(posedge clk)
begin
	if(rst) begin
		cnt	<=	48'h0;
	end
	else begin
		if(en) begin
			cnt	<=	cnt + 1'b1;
		end
		else begin
			cnt	<=	cnt;
		end
	end
end











endmodule
