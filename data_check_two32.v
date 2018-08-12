`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module data_check_two32 #(
	parameter		DATA_INTERVAL =	32'h2
)
(
	input 		clk_usr,
	input			rst, 

	input			[127:0]	usr_rx,
	input						usr_rx_valid, 
		
	output	reg			err
);
 
reg	[127:0]	check; 
reg	[127:0]	usr_rx_reg; 
reg	  			usr_rx_valid_reg; 
 
always @(posedge clk_usr or posedge rst) begin
	if(rst) begin
		usr_rx_reg			<=	128'b0; 
		usr_rx_valid_reg	<=	1'b0; 
	end else begin 
		usr_rx_reg			<=	usr_rx; 
		usr_rx_valid_reg	<=	usr_rx_valid; 
	end
end
 
always @(posedge clk_usr or posedge rst) begin
	if(rst) begin
		check					<=	128'b0; 
		err					<=	1'b0;
	end else begin 
		if(usr_rx_valid_reg) begin
		
			check[63:0]			<=	usr_rx_reg[63:0] 		+	DATA_INTERVAL;  
//			check[31:16]		<=	usr_rx_reg[31:16] 	+	DATA_INTERVAL; 
//			check[47:32]		<=	usr_rx_reg[47:32] 	+	DATA_INTERVAL; 
			check[127:64]		<=	usr_rx_reg[127:64] 	+	DATA_INTERVAL; 
			
			if(check[127:0] ==	usr_rx_reg[127:0]) begin
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
			 
