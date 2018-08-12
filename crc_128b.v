`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:40:29 03/07/2014 
// Design Name: 
// Module Name:    crc_64b 
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
module crc_128b(

		input 							clk_usr,
		input								rst, 

		input				[127:0]		usr_rx,
		input								usr_rx_valid, 
		
		output	reg					err,
		output	reg		[127:0]	check
		
    );
 
 
  
always @(posedge clk_usr or posedge rst) begin
	if(rst) begin
		err			<=	1'b0;
		check			<=	128'h0000_0004_0000_0003_0000_0002_0000_0001; 
	end else begin 
		if(usr_rx_valid) begin
			check		<=	usr_rx 	+	128'h0000_0004_0000_0004_0000_0004_0000_0004;
			if(usr_rx==check) begin
				err	<=	1'b0;
			end else begin
				err	<=	1'b1;
			end
		end else begin 
			err	<=	1'b0;
		end
	end
end 
			 
endmodule
