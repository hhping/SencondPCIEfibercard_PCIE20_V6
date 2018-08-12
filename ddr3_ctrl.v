`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:07:36 07/26/2012 
// Design Name: 
// Module Name:    ddr3_ctrl 
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

`timescale 1ns/1ps

module ddr3_ctrl #
  (
    // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    // board design). Actual values may be different. Actual parameters values 
    // are passed from design top module test module. Please refer to
    // the test module for actual values.
    parameter BANK_WIDTH    = 2,
    parameter COL_WIDTH     = 10,
    parameter DM_WIDTH      = 9,
    parameter DQ_WIDTH      = 72,
    parameter ROW_WIDTH     = 14,
    parameter APPDATA_WIDTH = 144,
    parameter ECC_ENABLE    = 0,
    parameter BURST_LEN     = 4,
    parameter CS_WIDTH    = 1,
    parameter ADDR_WIDTH    = 28,

    parameter CH_NUM            = 38, //通道数
    parameter STATE_CNT          = 64, //1次DMA的BURST数  //数据量：64*128b*2 //建议取512B~2KB //读延时最大为25CC
    parameter STATE_CNT_WIDTH   = 6, 
    parameter DATA_CNT_WIDTH     = 7   //1次DMA的有效时钟，2^7=128,单位是DDR2的LOCAL位宽128b  
   )
  (
    input                          clk0,
    input                          rst0,
    input                          app_rdy,
    input                          app_wdf_rdy,
    input                          phy_init_done,
    //read data                    
    input                          app_rd_data_valid,
    input [APPDATA_WIDTH-1:0]      app_rd_data_fifo_out,  
    //addr , ctrl                  
    output                         app_af_wren,
    output reg[2:0]                app_af_cmd,
    output reg[30:0]               app_af_addr,
    //write data                   
    output                         app_wdf_wren,
    output [APPDATA_WIDTH-1:0]     app_wdf_data,
    output [(APPDATA_WIDTH/8)-1:0] app_wdf_mask_data,
    output                         app_wdf_end,
    //user interface               
    input  [CH_NUM-1:0]            wr_ch_sel_i,   
    input  [ADDR_WIDTH-1:0]        wr_addr,
    input                          wr_addr_valid, //1CC
    output                         wr_busy_n,   
                                   
    input  [APPDATA_WIDTH-1:0]     wr_data,
    output                         wr_data_valid, //3CC后采数据-接 standard FIFO + 1 D latch
    output reg [CH_NUM-1:0]        wr_ch_sel_o,
                                   
    input  [CH_NUM-1:0]            rd_ch_sel_i,   
    input  [ADDR_WIDTH-1:0]        rd_addr,
    input                          rd_addr_valid, //1CC
    output                         rd_busy_n, 
                                   
    output reg [APPDATA_WIDTH-1:0] rd_data,
    output reg                     rd_data_valid, 
    output reg [CH_NUM-1:0]        rd_ch_sel_o,
	   output [ADDR_WIDTH-1 :0]       ddr2_buffer_o, //nbm
                                   
    output [511:0]                  ddr3_ctrl_debug,
    input                          vio_ctr
   );

  localparam BURST_LEN_DIV2 = 3;//# = ceil(log2(BURST_LEN))

  localparam TB_IDLE          = 9'b000000001;
  localparam TB_ARBITRATION1  = 9'b000000010;
  localparam TB_ARBITRATION2  = 9'b000000100;
  localparam TB_WRITE       = 9'b000001000;
  localparam TB_WRITE2      = 9'b000010000;  
  localparam TB_READ        = 9'b000100000;
  localparam TB_READ2       = 9'b001000000;  
  localparam TB_WAIT_WRITE  = 9'b010000000;  
  localparam TB_WAIT_READ   = 9'b100000000;  
  
  reg [7:0]                 d_cnt;
  reg                       phy_init_done_tb_r;
  wire                      phy_init_done_r;
  reg                       rst_r;                        
  reg                       rst_r1;                         
  reg [8:0]                 state;
  reg [STATE_CNT_WIDTH:0]   state_cnt; 
  
  //
  reg [STATE_CNT_WIDTH+1:0] state_wait_read_cnt;
  
  reg                       data_en;
  reg                       data_valid_WRITE;
  reg                       data_valid_READ;
  reg                       rd_addr_en;  
  wire                      rd_fifo_en;
  reg                       wr_addr_en;
  reg                       wr_data_en;
  reg  [ADDR_WIDTH-1 :0]    wr_addr_r;
  reg  [ADDR_WIDTH-1 :0]    rd_addr_r;
  wire [ADDR_WIDTH-1 :0]    len_addr;
  reg  [ADDR_WIDTH-1 :0]    ddr2_buffer;
  reg                       app_rd_data_valid_r;
  reg  [APPDATA_WIDTH-1:0]  app_rd_data_r;
  reg  [DATA_CNT_WIDTH-1:0] rd_data_cnt;  
  reg                       rd_cmd1_f_n,rd_cmd2_f_n;
  reg                       rd_busy_r_n;
  reg  [CH_NUM-1:0]         rd_ch_sel_r,rd_ch_sel_d;  
  reg                       wr_busy_r_n;
  reg  [CH_NUM-1:0]         wr_ch_sel_r; 
                           
  wire                      sof,eof;
  
assign len_addr = {ADDR_WIDTH{1'b1}};

always @(posedge clk0) begin
 rst_r  <= rst0;
 rst_r1 <= rst_r;
end

FDRSE ff_phy_init_done(.Q(phy_init_done_r),.C(clk0),.CE(1'b1),.D(phy_init_done),.R(1'b0),.S(1'b0));

always @(posedge clk0) begin
 if (rst_r1) begin
  phy_init_done_tb_r  <= 1'bx;
end  else begin
  phy_init_done_tb_r  <= phy_init_done_r;
end
end
  //***************************************************************************
  // 检测写请求,接收1条指令 
  //***************************************************************************
  assign wr_busy_n         = wr_busy_r_n & phy_init_done_tb_r;

  always @(posedge clk0) begin
    if (rst_r1) begin              
      wr_busy_r_n         <= 1'b1;
    end else begin            
      if(wr_busy_r_n && wr_addr_valid) begin 
        wr_busy_r_n       <= 1'b0;   
      end else      
      if(state == TB_WRITE2 && state_cnt == STATE_CNT && app_rdy) begin
        wr_busy_r_n       <= 1'b1;   
      end    
    end 
  end
  
  always @(posedge clk0) begin
    if (rst_r1) begin 
      wr_ch_sel_r         <= {CH_NUM{1'b0}};       
    end else begin 
      if(wr_busy_r_n && wr_addr_valid) begin
        wr_ch_sel_r       <= wr_ch_sel_i;      
      end        
    end 
  end  
  
  always @(posedge clk0) begin
    if (rst_r1) 
       wr_ch_sel_o         <= {CH_NUM{1'b0}};      
    else 
       wr_ch_sel_o       <= wr_ch_sel_r;       
  end        
      
  //***************************************************************************
  // 检测读请求,最多接收2条指令,1条读数据，1条写命令
  //***************************************************************************
  assign rd_busy_n         = rd_busy_r_n & phy_init_done_tb_r & rd_cmd1_f_n;
  
  always @(posedge clk0) begin
    if (rst0) begin 
      rd_ch_sel_r         <= {CH_NUM{1'b0}};
      rd_ch_sel_d         <= {CH_NUM{1'b0}};
      rd_cmd1_f_n         <= 1'b1;
      rd_cmd2_f_n         <= 1'b1;
      rd_busy_r_n         <= 1'b1;
    end else begin  
      if(rd_cmd1_f_n && rd_busy_r_n && rd_addr_valid) begin
        rd_cmd1_f_n       <= 1'b0;
        rd_ch_sel_r       <= rd_ch_sel_i;
      end else if( (rd_cmd2_f_n && ~rd_cmd1_f_n) || (app_rd_data_valid_r && (rd_data_cnt=={DATA_CNT_WIDTH{1'b1}}) && ~rd_cmd1_f_n) ) begin
        rd_cmd1_f_n       <= 1'b1;
      end
      
      if(app_rd_data_valid_r && (rd_data_cnt=={DATA_CNT_WIDTH{1'b1}})) begin 
        if(~rd_cmd1_f_n) begin //已收到第2条读指令的情况：表现为第2条地址指令已发但第1条指令数据未取完，通道选择保持
          rd_cmd2_f_n     <= 1'b0;  
          rd_ch_sel_d     <= rd_ch_sel_r;
        end else begin
          rd_cmd2_f_n     <= 1'b1;
        end
      end else if(rd_cmd2_f_n && ~rd_cmd1_f_n) begin //只收到1条读指令的情况
        rd_cmd2_f_n     <= 1'b0; 
        rd_ch_sel_d     <= rd_ch_sel_r;
      end 
      
      if(rd_cmd1_f_n && rd_busy_r_n && rd_addr_valid)begin 
        rd_busy_r_n       <= 1'b0;
      end else if(state == TB_READ2 && state_cnt == STATE_CNT && app_rdy) begin
        rd_busy_r_n       <= 1'b1;
      end
    end   
  end 
  //***************************************************************************
  // State Machine for writing to WRITE DATA & ADDRESS FIFOs
  // state machine changed for low FIFO threshold values
  //***************************************************************************

always @(posedge clk0) begin
 if (rst_r1 | !phy_init_done_tb_r) begin
  state <= TB_IDLE;
 end else 
 begin   
  case (state)
    TB_IDLE: 
    begin
     if (phy_init_done_tb_r)
      state <= TB_ARBITRATION1;
     else
      state <= TB_IDLE; 
    end
    
    TB_ARBITRATION1: 
    begin
     if (!wr_busy_r_n)
      state <= TB_WRITE;
     else if(!rd_busy_r_n)
      state <= TB_READ;
     else
      state <= TB_ARBITRATION1;
    end

    TB_ARBITRATION2: 
    begin
     if(!rd_busy_r_n)
      state <= TB_READ;
     else  if (!wr_busy_r_n)
      state <= TB_WRITE;
     else
      state <= TB_ARBITRATION2;
    end
    
    TB_WRITE: 
      state <= TB_WRITE2;
      
    TB_WRITE2: 
    begin
     if (app_rdy)
      if (state_cnt == STATE_CNT)
        state <= TB_WAIT_WRITE;
      else
        state <= TB_WRITE;
     else
      state <= TB_WRITE2;
    end
    
    TB_WAIT_WRITE:      
      state <= TB_ARBITRATION2;       

    TB_READ: 
      state <= TB_READ2;
    
    TB_READ2: 
    begin        
     if (app_rdy) 
      if (state_cnt == STATE_CNT)
        state <= TB_WAIT_READ;
      else
        state <= TB_READ;         
     else
      state <= TB_READ2;  
    end
    
    TB_WAIT_READ:
//      if(app_rd_data_valid)
//        state   <= TB_ARBITRATION1;
//      else
//        state   <= TB_WAIT_READ;
    begin
    if(state_wait_read_cnt == (STATE_CNT + STATE_CNT))
        state   <= TB_ARBITRATION1;
      else
        state   <= TB_WAIT_READ;
    end
    default:
      state <= TB_IDLE; 
      
  endcase
 end
end 
/*wait cnt--add 2013*/
  always @(posedge clk0)
  begin
      if (rst_r1) begin
        state_wait_read_cnt  <=  'h0;
    end
    else begin
        if((state == TB_READ) |(state == TB_READ2) |(state == TB_WAIT_READ)) begin
           if(app_rd_data_valid) begin
              state_wait_read_cnt <= state_wait_read_cnt + 1'b1;
          end
          else begin
              state_wait_read_cnt <= state_wait_read_cnt;
          end
       end
       else begin
            state_wait_read_cnt <= 'h0;
       end
     end
  end 
/**/
   
//数据帧计算
always @(posedge clk0)  
begin
if(rst_r1)
  state_cnt <= 'b0;
else
  if(state == TB_WRITE)
    state_cnt <= state_cnt + 'b1;
  else if(state == TB_READ) 
    state_cnt <= state_cnt + 'b1;
  else if(state == TB_ARBITRATION1 || state == TB_ARBITRATION2)
    state_cnt <= 'b0;
end
//命令
always @(posedge clk0)  
begin
if(state == TB_WRITE)
  app_af_cmd <= 3'b000;
else
  if(state == TB_READ)
    app_af_cmd <= 3'b001;
end
//地址写使能
always @(posedge clk0)
begin
if(rst_r1)
  wr_addr_en <= 1'b0;
else begin
  if(state == TB_WRITE)
    wr_addr_en <= 1'b1;
  else if(app_rdy)
    wr_addr_en <= 1'b0;
end
end
//地址读使能
always @(posedge clk0)
begin
if(rst_r1)
  rd_addr_en <= 1'b0;
else begin
  if(state == TB_READ)
    rd_addr_en <= 1'b1;
  else if(app_rdy)
    rd_addr_en <= 1'b0;
end
end 
assign app_af_wren = wr_addr_en | rd_addr_en;
//DMA有效阶段使能
always @(posedge clk0) 
begin
  if(rst_r1)
    data_valid_WRITE <= 1'b1;
  else if(state == TB_WRITE)
    data_valid_WRITE <= 1'b0;
  else if(state == TB_WAIT_WRITE)
    data_valid_WRITE <= 1'b1;
end
always @(posedge clk0) 
begin
  if(rst_r1)
    data_valid_READ <= 1'b1;
  else if(state == TB_READ)
    data_valid_READ <= 1'b0;
  else if(state == TB_WAIT_READ)
    data_valid_READ <= 1'b1;
end
//写地址
always @(posedge clk0) 
begin
if(rst_r1)
  wr_addr_r <= 'b0;
else
   if(wr_busy_r_n && wr_addr_valid) begin //刷新地址
    wr_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)]         <= wr_addr[ADDR_WIDTH - 1:(BURST_LEN_DIV2)];   
  end else 
    if(state == TB_WRITE)
    wr_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)] <= wr_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)] + 'b1;
end
//读地址 
always @(posedge clk0) 
begin
if(rst_r1)
  rd_addr_r <= 'b0;
else
  if(rd_cmd1_f_n && rd_busy_r_n && rd_addr_valid)//刷新地址  
        rd_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)]         <= rd_addr[ADDR_WIDTH - 1:(BURST_LEN_DIV2)];
  else 
    if(state == TB_READ)
    rd_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)] <= rd_addr_r[ADDR_WIDTH - 1:(BURST_LEN_DIV2)] + 'b1;
end 
//读写地址选通
always @(posedge clk0)  
begin
if(rst_r1)
  app_af_addr <= 'b0;
else
  if(state == TB_WRITE)
    app_af_addr <= {{(31 - ADDR_WIDTH){1'b0}},wr_addr_r};
  else
    if(state == TB_READ)
      app_af_addr <= {{(31 - ADDR_WIDTH){1'b0}},rd_addr_r};
end
//数据从外部读入，写DDR3
assign app_wdf_mask_data  = {(APPDATA_WIDTH/8){1'b0}};
assign rd_fifo_en       = data_en & app_wdf_rdy;
assign app_wdf_wren       = rd_fifo_en;
assign app_wdf_data       = wr_data;
assign wr_data_valid      = rd_fifo_en;//FIFO FW MODE
//assign wr_data_valid    = sof | ((~eof) & rd_fifo_en) ;//FIFO STAND MODE,PRE DATA
assign sof            = (state == TB_WRITE) && data_valid_WRITE;
assign eof            = ((d_cnt == STATE_CNT + STATE_CNT - 1) && (app_wdf_rdy == 1'b1));

//Burst_End 脉冲
always @(posedge clk0) 
begin
  if(rst_r1)
    data_en <= 1'b0;
  else
    if(state == TB_WRITE && data_valid_WRITE == 1'b1)
      data_en <= 1'b1;
    else if(d_cnt == STATE_CNT + STATE_CNT - 1 && app_wdf_rdy == 1'b1)
      data_en <= 1'b0;
end
always @(posedge clk0) 
begin
  if(rst_r1)
    d_cnt <= 'b0;
  else
    if(rd_fifo_en)
      d_cnt <= d_cnt + 'b1;
    else if(data_en == 1'b0)
      d_cnt <= 'b0;
end
assign app_wdf_end = d_cnt[0];
//读数据 
always @(posedge clk0) begin 
  if (rst_r1) begin  
    app_rd_data_valid_r  <= 1'b0;
    app_rd_data_r        <= {APPDATA_WIDTH{1'b0}};    
    rd_data_cnt          <= {DATA_CNT_WIDTH{1'b0}};
  end else begin  
    app_rd_data_valid_r <= app_rd_data_valid;
    app_rd_data_r       <= app_rd_data_fifo_out;    
    if(app_rd_data_valid_r) begin  
      rd_data_cnt <= rd_data_cnt + 1'b1;  
    end    
  end
end
always @(posedge clk0) begin
  if (rst0) begin   
    rd_data_valid       <= 1'b0;
    rd_data             <= {APPDATA_WIDTH{1'b0}}; 
     
    rd_ch_sel_o         <= {CH_NUM{1'b0}}; 
  end else begin   
    rd_data_valid       <= app_rd_data_valid_r;
    rd_data             <= app_rd_data_r;  
    
    rd_ch_sel_o         <= rd_ch_sel_d;  
  end
end
//--------------------------------------------------------
//ddr2_buffer_o上报给软件，告诉可读数据量
//--------------------------------------------------------
always @(posedge clk0) 
begin
  if(rst_r1)
    ddr2_buffer <= 'b0;
  else
    if(wr_addr_r >= rd_addr_r)
      ddr2_buffer <= wr_addr_r - rd_addr_r;
    else
      ddr2_buffer <= wr_addr_r + (len_addr - rd_addr_r);  //+ 1----->4*8=32Byte 
end 
assign ddr2_buffer_o = ddr2_buffer;	 

 assign ddr3_ctrl_debug[8:0] = state;
 assign ddr3_ctrl_debug[16:9] = d_cnt;
 assign ddr3_ctrl_debug[17] = app_rdy;
 assign ddr3_ctrl_debug[18] = app_wdf_rdy;
 assign ddr3_ctrl_debug[19] = wr_data_en;
 assign ddr3_ctrl_debug[20] = wr_addr_en;
 assign ddr3_ctrl_debug[21] = rd_addr_en;
 assign ddr3_ctrl_debug[22] = rd_fifo_en;
 assign ddr3_ctrl_debug[23] = wr_addr_valid;
 assign ddr3_ctrl_debug[24] = wr_busy_n;  
 assign ddr3_ctrl_debug[25] = rd_addr_valid;
 assign ddr3_ctrl_debug[26] = rd_busy_n;
 assign ddr3_ctrl_debug[27] = data_en;
 assign ddr3_ctrl_debug[28] = data_valid_WRITE;
 assign ddr3_ctrl_debug[40:29] = state_cnt;
 assign ddr3_ctrl_debug[41] = rd_cmd1_f_n;
 assign ddr3_ctrl_debug[42] = rd_cmd2_f_n;
 assign ddr3_ctrl_debug[43] = data_valid_READ;
 assign ddr3_ctrl_debug[44] = rd_busy_r_n;
 assign ddr3_ctrl_debug[45] = phy_init_done;
 assign ddr3_ctrl_debug[76:46] = wr_addr_r;
 assign ddr3_ctrl_debug[107:77] = rd_addr_r;
 assign ddr3_ctrl_debug[138:108] = ddr2_buffer_o;

 assign ddr3_ctrl_debug[395:139] = vio_ctr ? {app_rd_data_fifo_out,app_rd_data_valid} : {app_wdf_data,app_wdf_wren};
 assign ddr3_ctrl_debug[399:396] = {app_af_cmd,app_af_wren};
 assign ddr3_ctrl_debug[430:400] = {app_af_addr};
  
endmodule

