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

//��ʱ���������źŵĴ�����ȥ������̬
always @(posedge clk or posedge rst_in)begin
	if(rst_in) begin
		request_r1	<=	1'b0;
		request_r	  <=	1'b0;
	end else begin
		request_r1	<=	request;
		request_r	  <=	request_r1;
	end 
end

//���ݸ�λ���󣬲���10ms�ĸ�λ���塣�������Ч��	
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

//��λ�źų�������ʱ5�����״̬��������źš�
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
