`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      Cetc52 
// Create Date:    08:25:08 04/03/2012
// Design Name:    Ben(xsz)
// Module Name:    ben_addr_ctrl.v   
// Revision:       Ver1.00 
//////////////////////////////////////////////////////////////////////////////////
// NOTE WHEN USE THIS MODULE  !!!!!!!!!!!!
// If change the value of CH_NUM , the codes marked by "CHANGE WITH CH_NUM" should
// be modified to work with changed CH_NUM . 
// If change the length of ddr2 for each CH, the codes marked by "CHANGE WITH DDR2"  
// should be modified to work with changed ddr2 length.
//////////////////////////////////////////////////////////////////////////////////
module ben_addr_ctrl #(
   parameter CH_NUM = 2, //CH >= 2
   parameter ADDR_WIDTH = 31,
   parameter ADDR_PER_DMA_WIDTH = 8 //unit:64b  / DMA=2KB=256*64b=2^8*64b  单位是DDR2的物理位宽64b  
   )
  (  
    input                       clk,
    input                       rst,
    
    //RAM IF
    input       [CH_NUM-1:0]          wr_ram_ready,
    
    output  reg [CH_NUM-1:0]          wr_ch_sel_i,   
    output  reg [ADDR_WIDTH-1:0]      wr_addr,
    output  reg                       wr_addr_valid, //1CC
    input                             wr_busy_n,   
    
      //RAM IF
    input       [CH_NUM-1:0]          rd_ram_ready, 
    
    output  reg [CH_NUM-1:0]          rd_ch_sel_i,   
    output  reg [ADDR_WIDTH-1:0]      rd_addr,
    output  reg                       rd_addr_valid, //1CC
    input                             rd_busy_n,

    output        [255:0]             ddr3_addr_dbg
    );

//------------------------------------------------------------------
//addr signal 
wire [CH_NUM*ADDR_WIDTH-1:0] addr_base,addr_len;
reg  [CH_NUM*ADDR_WIDTH-1:0] wr_addr_cur,rd_addr_cur;
wire [ADDR_WIDTH-1:0]        wr_addr_w,rd_addr_w;
reg  [CH_NUM-1:0]            wr_ready,wr_addr_ready;
reg  [CH_NUM-1:0]            rd_ready,rd_addr_ready;

localparam  WR_IDLE   = 4'b0001; //judge ram state of all ch , if wr_busy_n delay and ram is ok , jump to send
localparam  WR_START  = 4'b0010;
localparam  WR_WAIT   = 4'b0100;
localparam  WR_STOP   = 4'b1000;
reg  [CH_NUM-1:0]  wr_sel;

reg [3:0] wr_state  = WR_IDLE; 
reg [2:0] wr_ddr2_rdy;// to assume ram state is updated -- but waste ddr2 write bandwidth
reg [3:0] wr_wait; // less cc than one dma  -- ONE DMA IS 2^6=64 CC


localparam  RD_IDLE   = 4'b0001; //judge ram state of all ch , if wr_busy_n delay and ram is ok , jump to send
localparam  RD_START  = 4'b0010;
localparam  RD_WAIT   = 4'b0100;
localparam  RD_STOP   = 4'b1000;
reg [CH_NUM-1:0]  rd_sel;

reg [3:0] rd_state  = RD_IDLE; 
reg [2:0] rd_ddr2_rdy;// to assume ram state is updated -- but waste ddr2 read bandwidth
reg [3:0] rd_wait; // less cc than one dma  -- ONE DMA IS 2^6=64 CC
 
//-------------------------------------------------------------------
//ch ddr2 addr base and len
//80MB = ( (20*1024*1024) / 8 ) * 32b (2 chip ddr phy addr width) 

// "CHANGE WITH CH_NUM" | "CHANGE WITH DDR2"
assign  addr_base[ADDR_WIDTH*1-1:ADDR_WIDTH*0]    = 31'h0000_0000;
assign  addr_base[ADDR_WIDTH*2-1:ADDR_WIDTH*1]    = 31'h1000_0000;
//assign  addr_base[ADDR_WIDTH*3-1:ADDR_WIDTH*2]    = 31'h0280_0000; 
//assign  addr_base[ADDR_WIDTH*4-1:ADDR_WIDTH*3]    = 31'h03C0_0000; 
//assign  addr_base[ADDR_WIDTH*5-1:ADDR_WIDTH*4]    = 31'h0500_0000; 
//assign  addr_base[ADDR_WIDTH*6-1:ADDR_WIDTH*5]    = 31'h0640_0000; 
//assign  addr_base[ADDR_WIDTH*7-1:ADDR_WIDTH*6]    = 31'h0780_0000; 
//assign  addr_base[ADDR_WIDTH*8-1:ADDR_WIDTH*7]    = 31'h08C0_0000; 
//assign  addr_base[ADDR_WIDTH*9-1:ADDR_WIDTH*8]    = 31'h0A00_0000; 

// "CHANGE WITH CH_NUM" | "CHANGE WITH DDR2"
//max used is (addr_len - 1 dma) AND must be interger of dma
assign  addr_len[ADDR_WIDTH*1-1:ADDR_WIDTH*0]   = 31'h1000_0000; // 2GB
assign  addr_len[ADDR_WIDTH*2-1:ADDR_WIDTH*1]   = 31'h1f00_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*3-1:ADDR_WIDTH*2]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*4-1:ADDR_WIDTH*3]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*5-1:ADDR_WIDTH*4]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*6-1:ADDR_WIDTH*5]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*7-1:ADDR_WIDTH*6]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*8-1:ADDR_WIDTH*7]   = 31'h0140_0000; // 80MB
//assign  addr_len[ADDR_WIDTH*9-1:ADDR_WIDTH*8]   = 31'h0600_0000; //384MB

//-------------------------------------------------------------------
//wr data to ddr2  -- wr addr process

//wr_addr tx
always @(posedge clk or posedge rst) begin
  if(rst) begin
    wr_ch_sel_i   <=    {CH_NUM{1'b0}};
    wr_addr       <=    {ADDR_WIDTH{1'b0}};
    wr_addr_valid <=    1'b0;
  end else begin
    if(wr_state==WR_START)  begin
      wr_ch_sel_i   <=  wr_sel;
      wr_addr       <=  wr_addr_w;
      wr_addr_valid <=  1'b1;
    end else begin
      wr_addr_valid <=  1'b0;
    end
  end
end

genvar i0;
generate
  for(i0=0;i0<CH_NUM;i0=i0+1) begin : wr_addr_w_gen
    assign  wr_addr_w = wr_sel[i0]  ? wr_addr_cur[ADDR_WIDTH*(i0+1)-1:ADDR_WIDTH*i0] + addr_base[ADDR_WIDTH*(i0+1)-1:ADDR_WIDTH*i0] : {ADDR_WIDTH{1'bz}}; 
  end
endgenerate

//wr_state machine delay process 
always @(posedge clk or posedge rst) begin
  if(rst) begin
    wr_ddr2_rdy   <=  3'b0;
    wr_wait     <=  4'b0;
  end else begin
    if(wr_busy_n) begin
      if(!(&wr_ddr2_rdy)) begin
        wr_ddr2_rdy <=  wr_ddr2_rdy + 1'b1;
      end
    end else begin
      wr_ddr2_rdy   <=  3'b0;
    end
    
    if(wr_state==WR_WAIT) begin
      if(!(&wr_wait)) begin
        wr_wait     <=  wr_wait + 1'b1;
      end 
    end else begin
      wr_wait     <=  4'b0;
    end
  end
end 

//wr_state addr process -- update ch wr addr when all data wrote to ddr2 ,which happen in WR_CHX_STOP
genvar i1;
generate
  for(i1=0;i1<CH_NUM;i1=i1+1) begin : wr_addr_cur_gen
    always @(posedge clk or posedge rst) begin
      if(rst) begin
        wr_addr_cur[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1]  <=  {ADDR_WIDTH{1'b0}}; 
      end else begin
        if( (wr_state==WR_STOP) && wr_sel[i1] && wr_busy_n) begin
          if( (wr_addr_cur[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1+ADDR_PER_DMA_WIDTH] + 1'b1) == addr_len[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1+ADDR_PER_DMA_WIDTH]) begin       
            wr_addr_cur[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1]  <=  {ADDR_WIDTH{1'b0}};
          end else begin
            wr_addr_cur[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1+ADDR_PER_DMA_WIDTH]   <=  wr_addr_cur[ADDR_WIDTH*(i1+1)-1:ADDR_WIDTH*i1+ADDR_PER_DMA_WIDTH]  + 1'b1;  
          end   
        end 
      end
    end       
  end
endgenerate

//wr_ready update
genvar i2;
generate
  for(i2=0;i2<CH_NUM;i2=i2+1) begin : wr_ready_gen
    always @(posedge clk or posedge rst) begin
      if(rst) begin
        wr_ready[i2]      <=  1'b0;
        wr_addr_ready[i2]   <=  1'b0; 
      end else begin
        wr_ready[i2]      <=  wr_ram_ready[i2] & wr_addr_ready[i2];
        
        if( (wr_addr_cur[ADDR_WIDTH*(i2+1)-1:ADDR_WIDTH*i2+ADDR_PER_DMA_WIDTH] + 1'b1) == addr_len[ADDR_WIDTH*(i2+1)-1:ADDR_WIDTH*i2+ADDR_PER_DMA_WIDTH])  begin
          if(rd_addr_cur[ADDR_WIDTH*(i2+1)-1:ADDR_WIDTH*i2+ADDR_PER_DMA_WIDTH]=={(ADDR_WIDTH-ADDR_PER_DMA_WIDTH){1'b0}}) begin
            wr_addr_ready[i2] <=  1'b0;
          end else begin
            wr_addr_ready[i2] <=  1'b1;
          end
        end else begin
          if( (wr_addr_cur[ADDR_WIDTH*(i2+1)-1:ADDR_WIDTH*i2+ADDR_PER_DMA_WIDTH] + 1'b1) == rd_addr_cur[ADDR_WIDTH*(i2+1)-1:ADDR_WIDTH*i2+ADDR_PER_DMA_WIDTH])  begin
            wr_addr_ready[i2] <=  1'b0;
          end else begin
            wr_addr_ready[i2] <=  1'b1;
          end
        end 
      end
    end 
  end
endgenerate

//wr_state machine
always @(posedge clk or posedge rst) begin
  if(rst) begin
    wr_state    <=  WR_IDLE;
    wr_sel     <= {CH_NUM{1'b0}}; 
  end else begin
    (* PARALLEL_CASE *) case (wr_state)
      WR_IDLE : begin
        if(&wr_ddr2_rdy) begin
//          case (wr_ready)  // "CHANGE WITH CH_NUM" 
//            2'b01 : wr_sel    <=  2'b01;
//            2'b11 : wr_sel    <=  2'b01;
//            2'b10 : wr_sel    <=  2'b10;
//            default : wr_sel  <=  2'b00;
//
//            9'b?_????_???1  : wr_sel  <=  9'b0_0000_0001;
//            9'b?_????_??10  : wr_sel  <=  9'b0_0000_0010;
//            9'b?_????_?100  : wr_sel  <=  9'b0_0000_0100;
//            9'b?_????_1000  : wr_sel  <=  9'b0_0000_1000;
//            9'b?_???1_0000  : wr_sel  <=  9'b0_0001_0000;
//            9'b?_??10_0000  : wr_sel  <=  9'b0_0010_0000;
//            9'b?_?100_0000  : wr_sel  <=  9'b0_0100_0000;
//            9'b?_1000_0000  : wr_sel  <=  9'b0_1000_0000;
//            9'b1_0000_0000  : wr_sel  <=  9'b1_0000_0000;
//            default :     wr_sel  <=  9'b0_0000_0000;
//          endcase

			 if(wr_ready[0]) begin
            wr_sel  <=  9'b000000001;
          end else if(wr_ready[1]) begin
            wr_sel  <=  9'b000000010;
////          end else if(wr_ready[2]) begin //deleted by hhp
////            wr_sel  <=  9'b000000100;
////          end else if(wr_ready[3]) begin
////            wr_sel  <=  9'b000001000;
////          end else if(wr_ready[4]) begin
////            wr_sel  <=  9'b000010000;
////          end else if(wr_ready[5]) begin
////            wr_sel  <=  9'b000100000;
////          end else if(wr_ready[6]) begin
////            wr_sel  <=  9'b001000000;
////          end else if(wr_ready[7]) begin
////            wr_sel  <=  9'b010000000;
////          end else if(wr_ready[8]) begin
////            wr_sel  <=  9'b100000000;
          end
          
          if(wr_ready) begin
            wr_state    <=  WR_START;
          end 
        end  
      end 
       
      WR_START  : begin
        wr_state    <=  WR_WAIT;
      end
      
      WR_WAIT : begin
        if(&wr_wait) begin
          wr_state    <=  WR_STOP;
        end
      end
      
      WR_STOP : begin
        if(wr_busy_n) begin
          wr_state    <=  WR_IDLE;
        end
      end
      
      default :  begin
        wr_state    <=  WR_IDLE;
        wr_sel     <= {CH_NUM{1'b0}}; 
      end
    endcase
  end
end    


//----------------------------------------------------------------------------------------
//rd addr process

//rd_addr tx
always @(posedge clk or posedge rst) begin
  if(rst) begin
    rd_ch_sel_i   <=  {CH_NUM{1'b0}};
    rd_addr     <=  {ADDR_WIDTH{1'b0}};
    rd_addr_valid <=  1'b0;
  end else begin
    if(rd_state == RD_START) begin
      rd_ch_sel_i   <=  rd_sel;
      rd_addr     <=  rd_addr_w;
      rd_addr_valid <=  1'b1;
    end else begin
      rd_addr_valid <=  1'b0;
    end
  end
end 

genvar j0;
generate
  for(j0=0;j0<CH_NUM;j0=j0+1) begin : rd_addr_w_gen
    assign  rd_addr_w = rd_sel[j0]  ? rd_addr_cur[ADDR_WIDTH*(j0+1)-1:ADDR_WIDTH*j0] + addr_base[ADDR_WIDTH*(j0+1)-1:ADDR_WIDTH*j0] : {ADDR_WIDTH{1'bz}}; 
  end
endgenerate

//rd_state machine delay process 
always @(posedge clk or posedge rst) begin
  if(rst) begin
    rd_ddr2_rdy   <=  3'b0;
    rd_wait     <=  4'b0;
  end else begin
    if(rd_busy_n) begin
      if(!(&rd_ddr2_rdy)) begin
        rd_ddr2_rdy <=  rd_ddr2_rdy + 1'b1;
      end
    end else begin
      rd_ddr2_rdy   <=  3'b0;
    end
    
    if(rd_state==RD_WAIT) begin
      if(!(&rd_wait)) begin
        rd_wait     <=  rd_wait + 1'b1;
      end 
    end else begin
      rd_wait     <=  4'b0;
    end
  end
end 

//rd_state addr process -- update ch rd addr when all data read cmd wrote to ddr2 ,which happen in RD_CHX_STOP
genvar j1;
generate
  for(j1=0;j1<CH_NUM;j1=j1+1) begin : rd_addr_cur_gen
    always @(posedge clk or posedge rst) begin
      if(rst) begin
        rd_addr_cur[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1]  <=  {ADDR_WIDTH{1'b0}}; 
      end else begin
        if( (rd_state==RD_STOP) && rd_sel[j1] && rd_busy_n ) begin
          if( (rd_addr_cur[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1+ADDR_PER_DMA_WIDTH] + 1'b1) == addr_len[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1+ADDR_PER_DMA_WIDTH]) begin       
            rd_addr_cur[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1]  <=  {ADDR_WIDTH{1'b0}};
          end else begin
            rd_addr_cur[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1+ADDR_PER_DMA_WIDTH]   <=  rd_addr_cur[ADDR_WIDTH*(j1+1)-1:ADDR_WIDTH*j1+ADDR_PER_DMA_WIDTH]  + 1'b1;  
          end   
        end 
      end
    end     
  end
endgenerate 

//rd_ready update
genvar j2;
generate
  for(j2=0;j2<CH_NUM;j2=j2+1) begin : rd_ready_gen
    always @(posedge clk or posedge rst) begin
      if(rst) begin
        rd_ready[j2]      <=  1'b0;
        rd_addr_ready[j2]   <=  1'b0; 
      end else begin
        rd_ready[j2]      <=  rd_ram_ready[j2] & rd_addr_ready[j2];
        
        if( rd_addr_cur[ADDR_WIDTH*(j2+1)-1:ADDR_WIDTH*j2+ADDR_PER_DMA_WIDTH] == wr_addr_cur[ADDR_WIDTH*(j2+1)-1:ADDR_WIDTH*j2+ADDR_PER_DMA_WIDTH])  begin
          rd_addr_ready[j2] <=  1'b0;
        end else begin
          rd_addr_ready[j2] <=  1'b1;
        end 
      end
    end 
  end
endgenerate 

//rd_state machine
always @(posedge clk or posedge rst) begin
  if(rst) begin
    rd_state    <=  RD_IDLE;
    rd_sel    <=  {CH_NUM{1'b0}};
  end else begin
    (* PARALLEL_CASE *) case (rd_state)
      RD_IDLE : begin
        if(&rd_ddr2_rdy) begin
//          case (rd_ready) // "CHANGE WITH CH_NUM" 
//            2'b01 : rd_sel    <=  2'b01;
//            2'b11 : rd_sel    <=  2'b01;
//            2'b10 : rd_sel    <=  2'b10;
//            default : rd_sel  <=  2'b00;
//
//            9'b?_????_???1  : rd_sel  <=  9'b0_0000_0001;
//            9'b?_????_??10  : rd_sel  <=  9'b0_0000_0010;
//            9'b?_????_?100  : rd_sel  <=  9'b0_0000_0100;
//            9'b?_????_1000  : rd_sel  <=  9'b0_0000_1000;
//            9'b?_???1_0000  : rd_sel  <=  9'b0_0001_0000;
//            9'b?_??10_0000  : rd_sel  <=  9'b0_0010_0000;
//            9'b?_?100_0000  : rd_sel  <=  9'b0_0100_0000;
//            9'b?_1000_0000  : rd_sel  <=  9'b0_1000_0000;
//            9'b1_0000_0000  : rd_sel  <=  9'b1_0000_0000;
//            default :     rd_sel  <=  9'b0_0000_0000;
//          endcase
			 if(rd_ready[0]) begin
            rd_sel  <=  9'b000000001;
          end else if(rd_ready[1]) begin
            rd_sel  <=  9'b000000010;
//          end else if(rd_ready[2]) begin //deleted by hhp
//            rd_sel  <=  9'b000000100;
//          end else if(rd_ready[3]) begin
//            rd_sel  <=  9'b000001000;
//          end else if(rd_ready[4]) begin
//            rd_sel  <=  9'b000010000;
//          end else if(rd_ready[5]) begin
//            rd_sel  <=  9'b000100000;
//          end else if(rd_ready[6]) begin
//            rd_sel  <=  9'b001000000;
//          end else if(rd_ready[7]) begin
//            rd_sel  <=  9'b010000000;
//          end else if(rd_ready[8]) begin
//            rd_sel  <=  9'b100000000;
          end
          
          if(rd_ready) begin
            rd_state    <=  RD_START;
          end
        end  
      end 
       
      RD_START  : begin
        rd_state    <=  RD_WAIT;
      end
      
      RD_WAIT : begin
        if(&rd_wait) begin
          rd_state    <=  RD_STOP;
        end
      end
      
      RD_STOP : begin
        if(rd_busy_n) begin
          rd_state    <=  RD_IDLE;
        end
      end
       
      default :  begin
        rd_state    <=  RD_IDLE;
        rd_sel    <=  {CH_NUM{1'b0}};
      end
    endcase
  end
end    


assign ddr3_addr_dbg[8:0]    = wr_ch_sel_i;
assign ddr3_addr_dbg[37:9]   = wr_addr;
assign ddr3_addr_dbg[38]     = wr_addr_valid;
assign ddr3_addr_dbg[39]     = wr_busy_n;
assign ddr3_addr_dbg[48:40]  = rd_ch_sel_i;
assign ddr3_addr_dbg[77:49]  = rd_addr;
assign ddr3_addr_dbg[78]     = rd_addr_valid;
assign ddr3_addr_dbg[79]     = rd_busy_n;

assign ddr3_addr_dbg[83:80]    = wr_state;
assign ddr3_addr_dbg[86:84]    = wr_ddr2_rdy;
assign ddr3_addr_dbg[90:87]    = wr_wait;
assign ddr3_addr_dbg[94:91]    = rd_state;
assign ddr3_addr_dbg[97:95]    = rd_ddr2_rdy;
assign ddr3_addr_dbg[101:98]   = rd_wait;

assign ddr3_addr_dbg[110:102]  = wr_ready;
assign ddr3_addr_dbg[119:111]  = wr_addr_ready;
assign ddr3_addr_dbg[128:120]  = rd_ready;
assign ddr3_addr_dbg[137:129]  = rd_addr_ready;

assign ddr3_addr_dbg[139:138]  = rd_ram_ready[0:0];
assign ddr3_addr_dbg[171:140]  = wr_addr_cur[31:0];
assign ddr3_addr_dbg[203:172]  = rd_addr_cur[31:0];



 
endmodule
