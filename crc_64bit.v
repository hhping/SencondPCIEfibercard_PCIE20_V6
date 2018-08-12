`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:49:48 06/11/2012 
// Design Name: 
// Module Name:    crc 
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
module crc_64bit
	(
		input 								t_clk,
		input 								rst,
		input									check_start,
		input 								check_en,
		input 			[63:0]			data,
		output 	reg 						erro,
		output	reg	[31:0]			err_cnt,
		
		output	reg 	[63:0] 			regc
		
    );

	
	always @(posedge t_clk)
	begin
		if(rst)	
			regc <= 64'h0000_0002_0000_0001;
		else
			if(check_en & check_start)
				regc <= data[63:0] + 64'h0000_0002_0000_0002;
			else
				regc <= regc;
	end

	always @(posedge t_clk)
	begin
		if(rst)
			erro <= 1'b0;
		else
			if(check_en & check_start)
				if(data[63:0] != regc)
					if((data == 64'h0000_0001_0000_0000) || (data == 64'h0000_0002_0000_0001))
						erro <= 1'b0;
					else
						erro <= 1'b1;
				else
					erro <= 1'b0;
			else
				erro <= 1'b0;
	end
	
	always @(posedge t_clk)
	begin
		if(rst) begin
			err_cnt	<=	32'h0;
		end
		else begin
			if(err_cnt == 32'hffff_ffff) begin
				err_cnt	<=	err_cnt;
			end
			else if(erro) begin
				err_cnt	<=	err_cnt + 1'b1;
			end
			else begin
				err_cnt	<= err_cnt;
			end
		end
	end
		
endmodule

