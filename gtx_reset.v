module gtx_reset1 #
	(
		parameter	clk_freq			=	100000000,
		parameter	delay_timer		=	5
	)
	(
		input						rst_in,
		input						clk,		
		input						request,
		
		output	reg			start,
		output	reg			rst_out
		
	 );

reg							request_r;
reg							request_r1;
reg	[31:0]			rst_cnt;
reg	[31:0]			delay_cnt;

//跨时钟域输入信号的处理－－去除亚稳态
always @(posedge clk or posedge rst_in)begin
	if(rst_in) begin
		request_r1	<=	1'b0;
		request_r	  <=	1'b0;
	end else begin
		request_r1	<=	request;
		request_r	  <=	request_r1;
	end 
end

//根据复位请求，产生10ms的复位脉冲。脉冲高有效。	
always @(posedge clk or posedge rst_in)begin
	if(rst_in) begin
		rst_out	<=	1'b1;
		rst_cnt	<=	32'h0;
	end	else begin		
		if(request_r) begin
			rst_out	<=	1'b1;
			rst_cnt	<=	32'h0;
		end	else begin
			if(rst_cnt < (clk_freq / 100) ) begin
//         if(rst_cnt <  200 ) begin
				rst_out	<=	1'b1;
				rst_cnt	<=	rst_cnt + 1'b1;
			end else begin
				rst_out	<=	1'b0;
				rst_cnt	<=	rst_cnt;
			end
		end
	end
end 

//复位信号撤销后延时5秒产生状态监测启动信号。
always @(posedge clk or posedge rst_in) begin
	if(rst_in) begin
		start			<=	1'b0;
		delay_cnt	<=	32'h0;
	end	else begin
		if(rst_out) begin
			start			<=	1'b0;
			delay_cnt	<=	32'h0;
		end else begin
			if(delay_cnt < (clk_freq * delay_timer)) begin
				start			<=	1'b0;
				delay_cnt	<=	delay_cnt + 1'b1;
			end else begin
				start			<=	1'b1;
				delay_cnt	<=	delay_cnt;
			end
		end 
	end
end 

endmodule
