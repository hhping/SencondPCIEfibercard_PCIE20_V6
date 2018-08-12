/****************************************************************************** 
//MODULE NAME : veri_incr
//Copyright   : CETC52
//Creater     : Pumpkin Xie
//Date Creater: 2016-08-20
******************************************************************************/ 

module veri_incr_32_add4#(
    parameter   INCR_NUM    =   2,       //数据宽度,单位32bit
//    parameter   SYNC_VLD    =   "YES"     //数据与有效信号同周期
    parameter   SYNC_VLD    =   "NO"    //数据与有效信号同周期
    )(
    input                           data_clk,
    input                           sys_rst,
    input                           data_vld,
    input       [INCR_NUM*32-1:0]   data,
    output  reg                     result,
	   output  [255:0]						veri_debug
    );
    reg     [INCR_NUM*32-1:0]       data_reg;
    reg                             data_vld_r;
    wire                            data_valid;
    reg                             data_valid_r;
    reg                             data_valid_rr;
	 reg     [63:0]                  data_cnt;

   FDRE #(.INIT(1'b0)) veri_rst   (.Q(rst),  .C(data_clk),.CE(1'b1),.R(1'b0),.D(sys_rst));

    always @(posedge data_clk)
        data_vld_r  <=  data_vld;
        
    if(SYNC_VLD == "YES")
        assign data_valid   = data_vld;
    else
        assign data_valid   = data_vld_r;
		  
    always @(posedge data_clk)
    begin
        if (rst)
			  begin
					data_cnt        <= 64'h0;
			  end
        else if(data_valid)    
			  begin
					data_cnt        <= data_cnt + 64'h1;			  
			  end
        else
        begin
					data_cnt        <= data_cnt;			  
        end
    end		  
        
    
    always @(posedge data_clk)
    begin
        if (rst)
        begin
            data_reg        <= 64'h0;
            data_valid_r    <= 1'b0;
            data_valid_rr   <= 1'b0;
        end
        else if(data_valid)    
        begin
            data_reg        <= data;
            data_valid_r    <= data_valid;
            data_valid_rr   <= data_valid_r;
        end
        else
        begin
            data_reg        <= data_reg; 
            data_valid_r    <= data_valid_r;
            data_valid_rr   <= data_valid_rr;
        end
    end

    //两拍数据正确性
    always @(posedge data_clk)
    begin
        if (rst)
        begin
            result <= 1'b0;
        end
        else if((data_cnt > 64'h1)  && data_valid)
        begin
////				if(data_reg==64'hffffffffffffffff && data ==64'h00000000000)
//				if(data_reg[31:0]==64'hffffffffffffffff && data ==64'h00000000000)
//				       	result <= 1'b0; 
            if((data[31:0] == data_reg[31:0] + 32'h00000008) && (data[63:32] == data_reg[63:32] + 32'h00000008))
                result <= 1'b0;            
            else 
                result <= 1'b1; //error occur
            end    
        else 
            result <= 1'b0;    
    end

assign veri_debug[31:0] = data;    
assign veri_debug[63:32] = data_reg;    
assign veri_debug[64] = data_valid;    
assign veri_debug[65] = data_valid_r;    
assign veri_debug[66] = data_valid_rr;    
assign veri_debug[67] = result;   
assign veri_debug[127:68] = data_cnt; 

    
endmodule    