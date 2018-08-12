//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_64_TX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Transmit Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_CPLD_FMT_TYPE   7'b10_01010
`define BMD_64_MWR_FMT_TYPE    7'b10_00000
`define BMD_64_MWR64_FMT_TYPE  7'b11_00000
`define BMD_64_MRD_FMT_TYPE    7'b00_00000
`define BMD_64_MRD64_FMT_TYPE  7'b01_00000

`define BMD_64_TX_RST_STATE    8'b00000001
`define BMD_64_TX_CPLD_QW1     8'b00000010
`define BMD_64_TX_CPLD_WIT     8'b00000100
`define BMD_64_TX_MWR_QW1      8'b00001000
`define BMD_64_TX_MWR64_QW1    8'b00010000
`define BMD_64_TX_MWR_QWN      8'b00100000
`define BMD_64_TX_MRD_QW1      8'b01000000
`define BMD_64_TX_MRD_QWN      8'b10000000

module BMD_TX_ENGINE (

                        clk,
                        rst_n,

                        trn_td,
                        trn_trem_n,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tdst_dsc_n,
                        trn_tbuf_av,

                        req_compl_i,    
                        compl_done_o,  

                        req_tc_i,     
                        req_td_i,    
                        req_ep_i,   
                        req_attr_i,
                        req_len_i,         
                        req_rid_i,        
                        req_tag_i,       
                        req_be_i,
                        req_addr_i,     

                        // BMD Read Access

                        rd_addr_o,   
                        rd_be_o,    
                        rd_data_i,


                        // Initiator Reset
          
                        init_rst_i,

                        // Write Initiator

                        mwr_start_i,
                        mwr_int_dis_i,
                        mwr_len_i,
                        mwr_tag_i,
                        mwr_lbe_i,
                        mwr_fbe_i,
                        mwr_addr_i,
                        mwr_data_i,
                        mwr_count_i,
                        mwr_done_o,
                        mwr_tlp_tc_i,
                        mwr_64b_en_i,
                        mwr_phant_func_dis1_i,
                        mwr_up_addr_i,
                        mwr_relaxed_order_i,
                        mwr_nosnoop_i,
                        mwr_wrr_cnt_i,

                        // Read Initiator

                        mrd_start_i,
                        mrd_int_dis_i,
                        mrd_len_i,
                        mrd_tag_i,
                        mrd_lbe_i,
                        mrd_fbe_i,
                        mrd_addr_i,
                        mrd_count_i,
                        mrd_done_i,
                        mrd_tlp_tc_i,
                        mrd_64b_en_i,
                        mrd_phant_func_dis1_i,
                        mrd_up_addr_i,
                        mrd_relaxed_order_i,
                        mrd_nosnoop_i,
                        mrd_wrr_cnt_i,

                        cur_mrd_count_o,

                        cfg_msi_enable_i,
                        cfg_interrupt_n_o,
                        cfg_interrupt_assert_n_o,
                        cfg_interrupt_rdy_n_i,
                        cfg_interrupt_legacyclr,

                        completer_id_i,
                        cfg_ext_tag_en_i,
                        cfg_bus_mstr_enable_i,
                        cfg_phant_func_en_i,
                        cfg_phant_func_supported_i,
								
								user_fifo_wrclk,
								user_fifo_data,
								user_fifo_wren,
								user_fifo_almost_full,
								txbuffer_clr,
								
								rx_tlp_plus,

								debug
                        );

    input               clk;
    input               rst_n;
 
    output [63:0]       trn_td;
    output [7:0]        trn_trem_n;
    output              trn_tsof_n;
    output              trn_teof_n;
    output              trn_tsrc_rdy_n;
    output              trn_tsrc_dsc_n;
    input               trn_tdst_rdy_n;
    input               trn_tdst_dsc_n;
    input [5:0]         trn_tbuf_av;

    input               req_compl_i;//完成包请求
    output              compl_done_o;

    input [2:0]         req_tc_i;
    input               req_td_i;
    input               req_ep_i;
    input [1:0]         req_attr_i;
    input [9:0]         req_len_i;
    input [15:0]        req_rid_i;
    input [7:0]         req_tag_i;
    input [7:0]         req_be_i; //请求字节使能
    input [29:0]        req_addr_i;//请求地址
    
    output [6:0]        rd_addr_o;
    output [3:0]        rd_be_o;
    input  [31:0]       rd_data_i;

    input               init_rst_i;

    input               mwr_start_i;
    input               mwr_int_dis_i;
    input  [31:0]       mwr_len_i;
    input  [7:0]        mwr_tag_i;
    input  [3:0]        mwr_lbe_i;
    input  [3:0]        mwr_fbe_i;
    input  [31:0]       mwr_addr_i;
    input  [31:0]       mwr_data_i;
    input  [31:0]       mwr_count_i;
    output              mwr_done_o;
    input  [2:0]        mwr_tlp_tc_i;
    input               mwr_64b_en_i;
    input               mwr_phant_func_dis1_i;
    input  [7:0]        mwr_up_addr_i;
    input               mwr_relaxed_order_i;
    input               mwr_nosnoop_i;
    input  [7:0]        mwr_wrr_cnt_i;


    input               mrd_start_i;
    input               mrd_int_dis_i;
    input  [31:0]       mrd_len_i;
    input  [7:0]        mrd_tag_i;
    input  [3:0]        mrd_lbe_i;
    input  [3:0]        mrd_fbe_i;
    input  [31:0]       mrd_addr_i;
    input  [31:0]       mrd_count_i;
    input               mrd_done_i;
    input  [2:0]        mrd_tlp_tc_i;
    input               mrd_64b_en_i;
    input               mrd_phant_func_dis1_i;
    input  [7:0]        mrd_up_addr_i;
    input               mrd_relaxed_order_i;
    input               mrd_nosnoop_i;
    input  [7:0]        mrd_wrr_cnt_i;

    output [15:0]       cur_mrd_count_o;

    input               cfg_msi_enable_i;
    output              cfg_interrupt_n_o;
    output              cfg_interrupt_assert_n_o;
    input               cfg_interrupt_rdy_n_i;
    input               cfg_interrupt_legacyclr;

    input [15:0]        completer_id_i;
    input               cfg_ext_tag_en_i;
    input               cfg_bus_mstr_enable_i;

    input               cfg_phant_func_en_i;
    input [1:0]         cfg_phant_func_supported_i;
	 
	 input					user_fifo_wrclk;
	 output					user_fifo_almost_full;		 
	 input					user_fifo_wren;
	 input	[63:0]		user_fifo_data;
	 input					txbuffer_clr;
	 
	 input 					rx_tlp_plus;
	 
	 output	[255:0]		debug;


    // Local registers

    reg [63:0]          trn_td;
    reg [7:0]           trn_trem_n;
    reg                 trn_tsof_n;
    reg                 trn_teof_n;
    reg                 trn_tsrc_rdy_n;
    reg                 trn_tsrc_dsc_n;
 
    reg [11:0]          byte_count;
    reg [06:0]          lower_addr;

    reg                 req_compl_q;                 

    reg [7:0]           bmd_64_tx_state;

    reg                 compl_done_o;
    reg                 mwr_done_o;

    reg                 mrd_done;

    reg [15:0]          cur_wr_count;
    reg [15:0]          cur_rd_count;
   
    reg [9:0]           cur_mwr_dw_count;
  
    reg [12:0]          mwr_len_byte;
    reg [12:0]          mrd_len_byte;

    reg [31:0]          pmwr_addr;
    reg [31:0]          pmrd_addr;

    reg [31:0]          tmwr_addr;
    reg [31:0]          tmrd_addr;

    reg [15:0]          rmwr_count;
    reg [15:0]          rmrd_count;

    reg                 serv_mwr;
    reg                 serv_mrd;

    reg  [7:0]          tmwr_wrr_cnt;
    reg  [7:0]          tmrd_wrr_cnt;

    // Local wires
   
    wire [15:0]         cur_mrd_count_o = cur_rd_count;
    wire                cfg_bm_en = cfg_bus_mstr_enable_i;
    wire [31:0]         mwr_addr  = mwr_addr_i;
    wire [31:0]         mrd_addr  = mrd_addr_i;
//    wire [31:0]         mwr_data_i_sw = {mwr_data_i[07:00],
//                                         mwr_data_i[15:08],
//                                         mwr_data_i[23:16],
//                                         mwr_data_i[31:24]};
//add by mxp
	 wire						RST;	 
	 wire						almost_full_L;
	 wire						almost_full_H;
	 wire						q_rden;
	 wire						q_rden_L;
	 wire						q_rden_H;	 
	 wire 					user_fifo_empty_L;
	 wire 					user_fifo_empty_H;
	 wire [31:0]         user_fifo_q_L;
	 wire [31:0]         user_fifo_q_H;
	 wire	[9:0]				FRAME_RDCOUNT,FRAME_WRCOUNT;
    wire [31:0]         mwr_data_i_sw_L = {user_fifo_q_L[07:00],
                                         user_fifo_q_L[15:08],
                                         user_fifo_q_L[23:16],
                                         user_fifo_q_L[31:24]};
    wire [31:0]         mwr_data_i_sw_H = {user_fifo_q_H[07:00],
                                         user_fifo_q_H[15:08],
                                         user_fifo_q_H[23:16],
                                         user_fifo_q_H[31:24]};

	 reg						data_frame_valid;	
reg [7:0]tmrd_wrr_cnt_r;
reg [7:0]rx_flow_cnt_r;
	wire  [15:0] 				rx_flow_cnt	 ;
	reg						plus;
//
    wire  [2:0]         mwr_func_num = (!mwr_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_wr_count[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_wr_count[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_wr_count[10:8]} : 3'b000) : 3'b000;

    wire  [2:0]         mrd_func_num = (!mrd_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_rd_count[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_rd_count[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_rd_count[10:8]} : 3'b000) : 3'b000;

    /*
     * Present address and byte enable to memory module
     */

    assign rd_addr_o = req_addr_i[10:2];
    assign rd_be_o =   req_be_i[3:0];

    /*
     * Calculate byte count based on byte enable
     */

    always @ (rd_be_o) begin

      casex (rd_be_o[3:0])
      
        4'b1xx1 : byte_count = 12'h004;
        4'b01x1 : byte_count = 12'h003;
        4'b1x10 : byte_count = 12'h003;
        4'b0011 : byte_count = 12'h002;
        4'b0110 : byte_count = 12'h002;
        4'b1100 : byte_count = 12'h002;
        4'b0001 : byte_count = 12'h001;
        4'b0010 : byte_count = 12'h001;
        4'b0100 : byte_count = 12'h001;
        4'b1000 : byte_count = 12'h001;
        4'b0000 : byte_count = 12'h001;

      endcase

    end

    /*
     * Calculate lower address based on  byte enable
     */

    always @ (rd_be_o or req_addr_i) begin

      casex (rd_be_o[3:0])
      
        4'b0000 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxxx1 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxx10 : lower_addr = {req_addr_i[4:0], 2'b01};
        4'bx100 : lower_addr = {req_addr_i[4:0], 2'b10};
        4'b1000 : lower_addr = {req_addr_i[4:0], 2'b11};

      endcase

    end

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          req_compl_q <= 1'b0;

        end else begin 

          req_compl_q <= req_compl_i;

        end

    end

    /*
     *  Interrupt Controller
     */
	 wire mrd_int_dis_i_r;
	 wire mwr_int_dis_i_r;
	 
	 assign mrd_int_dis_i_r = 1'b1;
	 assign mwr_int_dis_i_r = 1'b1;

    BMD_INTR_CTRL BMD_INTR_CTRL  (

      .clk(clk),                                     // I
      .rst_n(rst_n),                                 // I

      .init_rst_i(init_rst_i),                       // I

      .mrd_done_i(mrd_done_i & !mrd_int_dis_i_r),      // I  mrd_int_dis_i
      .mwr_done_i(mwr_done_o & !mwr_int_dis_i_r),      // I  mwr_int_dis_i

      .msi_on(cfg_msi_enable_i),                     // I

      .cfg_interrupt_rdy_n_i(cfg_interrupt_rdy_n_i), // I
      .cfg_interrupt_assert_n_o(cfg_interrupt_assert_n_o), // O
      .cfg_interrupt_n_o(cfg_interrupt_n_o),        // O
      .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr) // I

    );


    /*
     *  Tx State Machine 
     */

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          trn_tsof_n        <= 1'b1;
          trn_teof_n        <= 1'b1;
          trn_tsrc_rdy_n    <= 1'b1;
          trn_tsrc_dsc_n    <= 1'b1;
          trn_td            <= 64'b0;
          trn_trem_n        <= 8'b0;
 
          cur_mwr_dw_count  <= 10'b0;

          compl_done_o      <= 1'b0;
          mwr_done_o        <= 1'b0;

          mrd_done          <= 1'b0;

          cur_wr_count      <= 16'b0;
          cur_rd_count      <= 16'b1;

          mwr_len_byte      <= 13'b0;
          mrd_len_byte      <= 13'b0;

          pmwr_addr         <= 32'b0;
          pmrd_addr         <= 32'b0;

          rmwr_count        <= 16'b0;
          rmrd_count        <= 16'b0;

          serv_mwr          <= 1'b1;
          serv_mrd          <= 1'b1;

          tmwr_wrr_cnt      <= 8'h00;
          tmrd_wrr_cnt      <= 8'h00;

          bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;			 
			 
			 plus 				 <= 1'b0;
        end else begin 

         
          if (init_rst_i ) begin

            trn_tsof_n        <= 1'b1;
            trn_teof_n        <= 1'b1;
            trn_tsrc_rdy_n    <= 1'b1;
            trn_tsrc_dsc_n    <= 1'b1;
            trn_td            <= 64'b0;
            trn_trem_n        <= 8'b0;
   
            cur_mwr_dw_count  <= 10'b0;
  
            compl_done_o      <= 1'b0;
            mwr_done_o        <= 1'b0;

            mrd_done          <= 1'b0;
  
            cur_wr_count      <= 16'b0;
            cur_rd_count      <= 16'b1;

            mwr_len_byte      <= 13'b0;
            mrd_len_byte      <= 13'b0;

            pmwr_addr         <= 32'b0;
            pmrd_addr         <= 32'b0;

            rmwr_count        <= 16'b0;
            rmrd_count        <= 16'b0;

            serv_mwr          <= 1'b1;
            serv_mrd          <= 1'b1;

            tmwr_wrr_cnt      <= 8'h00;
            tmrd_wrr_cnt      <= 8'h00;

            bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;
				
				plus 				 <= 1'b0;

          end

          mwr_len_byte        <= 4 * mwr_len_i[10:0];
          mrd_len_byte        <= 4 * mrd_len_i[10:0];
          rmwr_count          <= mwr_count_i[15:0];
          rmrd_count          <= mrd_count_i[15:0];
			 plus 				 <= 1'b0;
			
          case ( bmd_64_tx_state ) 

            `BMD_64_TX_RST_STATE : begin

              compl_done_o       <= 1'b0;
				  
              // PIO read completions always get highest priority

              if (req_compl_q && 
                  !compl_done_o &&
                  !trn_tdst_rdy_n &&
                  trn_tdst_dsc_n) begin

                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_CPLD_FMT_TYPE, 
                                      {1'b0}, 
                                      req_tc_i, 
                                      {4'b0}, 
                                      req_td_i, 
                                      req_ep_i, 
                                      req_attr_i, 
                                      {2'b0}, 
                                      req_len_i,
                                      completer_id_i, 
                                      {3'b0}, 
                                      {1'b0}, 
                                      byte_count };
                trn_trem_n        <= 8'b0;

                bmd_64_tx_state   <= `BMD_64_TX_CPLD_QW1;

              end else if (data_frame_valid &&//keep 1 frame count data ,mxp
									mwr_start_i && 
                           !mwr_done_o &&
                           serv_mwr &&
                           !trn_tdst_rdy_n &&
                           trn_tdst_dsc_n && 
                           cfg_bm_en) begin
             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      {mwr_64b_en_i ? 
                                       `BMD_64_MWR64_FMT_TYPE :  
                                       `BMD_64_MWR_FMT_TYPE}, 
                                      {1'b0}, 
                                      mwr_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mwr_relaxed_order_i, mwr_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      mwr_len_i[9:0],
                                      {completer_id_i[15:3], mwr_func_num}, 
                                      cfg_ext_tag_en_i ? cur_wr_count[7:0] : {3'b0, cur_wr_count[4:0]},
                                      (mwr_len_i[9:0] == 1'b1) ? 4'b0 : mwr_lbe_i,
                                      mwr_fbe_i};
                trn_trem_n        <= 8'b0;
                cur_mwr_dw_count  <= mwr_len_i[9:0];
                
                // Weighted Round Robin
                if (mwr_start_i && !mwr_done_o && (tmwr_wrr_cnt != mwr_wrr_cnt_i)) begin
                  serv_mwr        <= 1'b1;
                  serv_mrd        <= 1'b0;
                  tmwr_wrr_cnt    <= tmwr_wrr_cnt + 1'b1;
                end else if (mrd_start_i && !mrd_done) begin
                  serv_mwr        <= 1'b0;
                  serv_mrd        <= 1'b1;
                  tmwr_wrr_cnt    <= 8'h00;
                end else begin
                  serv_mwr        <= 1'b0;
                  serv_mrd        <= 1'b0;
                  tmwr_wrr_cnt    <= 8'h00;
                end
                
                if (mwr_64b_en_i)
				  bmd_64_tx_state   <= `BMD_64_TX_MWR64_QW1;
                else
				  bmd_64_tx_state   <= `BMD_64_TX_MWR_QW1;
                

              end else if (mrd_start_i && 
                           !mrd_done &&
                           serv_mrd &&
                           !trn_tdst_rdy_n &&
                           trn_tdst_dsc_n && 
                           cfg_bm_en && (rx_flow_cnt < 16'h2)) begin
             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      {mrd_64b_en_i ? 
                                       `BMD_64_MRD64_FMT_TYPE : 
                                       `BMD_64_MRD_FMT_TYPE}, 
                                      {1'b0}, 
                                      mrd_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mrd_relaxed_order_i, mrd_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      mrd_len_i[9:0],
                                      {completer_id_i[15:3], mrd_func_num}, 
                                      cfg_ext_tag_en_i ? cur_rd_count[7:0] : {3'b0, cur_rd_count[4:0]},
                                      (mrd_len_i[9:0] == 1'b1) ? 4'b0 : mrd_lbe_i,
                                      mrd_fbe_i};
                trn_trem_n        <= 8'b0;
						plus 				 <= 1'b1;	
                // Weighted Round Robin
                if (mrd_start_i && !mrd_done && (tmrd_wrr_cnt != mrd_wrr_cnt_i)) begin
                  serv_mrd        <= 1'b1;
                  serv_mwr        <= 1'b0;
                  tmrd_wrr_cnt    <= tmrd_wrr_cnt + 1'b1;
											
                end else if (mwr_start_i && !mwr_done_o) begin
                  serv_mrd        <= 1'b0;
                  serv_mwr        <= 1'b1;
                  tmrd_wrr_cnt    <= 8'h00;						
                end else begin
                  serv_mrd        <= 1'b0;
                  serv_mwr        <= 1'b0;
                  tmrd_wrr_cnt    <= 8'h00;						
                end

                bmd_64_tx_state   <= `BMD_64_TX_MRD_QW1;
                
              end else  begin

                if(!trn_tdst_rdy_n) begin

                  trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
                  trn_tsrc_rdy_n    <= 1'b1;
                  trn_tsrc_dsc_n    <= 1'b1;
                  trn_td            <= 64'b0;
                  trn_trem_n        <= 8'b0;

                  serv_mwr          <= ~serv_mwr;
                  serv_mrd          <= ~serv_mrd;

                end
 
                bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

              end

            end

            `BMD_64_TX_CPLD_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { req_rid_i, 
                                      req_tag_i, 
                                      {1'b0}, 
                                      lower_addr,
                                      rd_data_i };
                trn_trem_n       <= 8'h00;
                compl_done_o     <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_QW1;

            end

            `BMD_64_TX_CPLD_WIT : begin

              if ( (!trn_tdst_rdy_n) || (!trn_tdst_dsc_n) ) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_tsrc_dsc_n   <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

            end

            `BMD_64_TX_MWR_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_wr_count == 0)
                  tmwr_addr       = mwr_addr;
                else 
                  tmwr_addr       = pmwr_addr + mwr_len_byte;
                trn_td           <= {{tmwr_addr[31:2], 2'b00}, mwr_data_i_sw_L};
                pmwr_addr        <= tmwr_addr;

                  cur_wr_count <= cur_wr_count + 1'b1;

                if (cur_mwr_dw_count == 1'h1) begin

                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  trn_trem_n       <= 8'h00;

                  if (cur_wr_count == (rmwr_count - 1'b1))  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;

                  end

                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                end else begin

                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  trn_trem_n       <= 8'hFF;
                  bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

                end

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QW1;

            end

            `BMD_64_TX_MWR64_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_wr_count == 0)
                  tmwr_addr       = mwr_addr;
                else 
                  tmwr_addr       = {pmwr_addr[31:24], pmwr_addr[23:0] + mwr_len_byte};
                trn_td           <= {{24'b0},mwr_up_addr_i,tmwr_addr[31:2],{2'b0}};
                pmwr_addr        <= tmwr_addr;

                cur_wr_count <= cur_wr_count + 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR64_QW1;

            end

            `BMD_64_TX_MWR_QWN : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin//				

                trn_tsrc_rdy_n   <= 1'b0;
					 
                if (cur_mwr_dw_count == 1'h1) begin

                  trn_td           <= {mwr_data_i_sw_H, 32'hd0_da_d0_da};
                  trn_trem_n       <= 8'h0F;
                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                  if (cur_wr_count == rmwr_count)  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;						

                  end 

                end else if (cur_mwr_dw_count == 2'h2) begin

                  trn_td           <= {mwr_data_i_sw_H, mwr_data_i_sw_L};
                  trn_trem_n       <= 8'h00;
                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 2'h2; 
                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                  if (cur_wr_count == rmwr_count)  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;

                  end

                end else begin

                  trn_td           <= {mwr_data_i_sw_H, mwr_data_i_sw_L};
                  trn_trem_n       <= 8'hFF;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 2'h2; 
                  bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

                end					

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QWN;

            end

            `BMD_64_TX_MRD_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_rd_count == 1)
                  tmrd_addr       = mrd_addr;
                else 
                  tmrd_addr       = {pmrd_addr[31:24], pmrd_addr[23:0] + mrd_len_byte};
                if (mrd_64b_en_i) begin
                  trn_td         <= {{24'b0},{mrd_up_addr_i},{tmrd_addr[31:2],2'b0}};
                  trn_trem_n     <= 8'h00;
                end else begin
                  trn_td         <= {{tmrd_addr[31:2], 2'b00}, 32'hd0_da_d0_da};
                  trn_trem_n     <= 8'h0F;
                end
                pmrd_addr        <= tmrd_addr;

                if (cur_rd_count == rmrd_count) begin

                  cur_rd_count   <= 0; 
                  mrd_done       <= 1'b1;

                end else 
                  cur_rd_count <= cur_rd_count + 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n   <= 1'b0;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_MRD_QW1;

            end

          endcase

        end

    end
	 
// add by mxp
//   FIFO18_36 #(
//      .SIM_MODE("SAFE"),  // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
//      .ALMOST_FULL_OFFSET(9'h080),      // Sets almost full threshold
//      .ALMOST_EMPTY_OFFSET(9'h080),     // Sets the almost empty threshold
//      .DO_REG(1),                       // Enable output register (0 or 1)
//                                        //   Must be 1 if EN_SYN = "FALSE" 
//      .EN_SYN("FALSE"),                 // Specifies FIFO as Asynchronous ("FALSE") 
//                                        //   or Synchronous ("TRUE")
//      .FIRST_WORD_FALL_THROUGH("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE" 
//   ) FIFO18_36_LowOut_inst (
//      .ALMOSTEMPTY(), // 1-bit almost empty output flag
//      .ALMOSTFULL(almost_full_L),   // 1-bit almost full output flag
//      .DO(user_fifo_q_L),                   // 32-bit data output
//      .DOP(),                 // 4-bit parity data output
//      .EMPTY(user_fifo_empty_L),             // 1-bit empty output flag
//      .FULL(),               // 1-bit full output flag
//      .RDCOUNT(FRAME_RDCOUNT),         // 9-bit read count output
//      .RDERR(),             // 1-bit read error output
//      .WRCOUNT(FRAME_WRCOUNT),         // 9-bit write count output
//      .WRERR(),             // 1-bit write error
//      .DI(user_fifo_data[31:0]),                   // 32-bit data input
//      .DIP(),                 // 4-bit parity input
//      .RDCLK(clk),             // 1-bit read clock input
//      .RDEN(q_rden_L),               // 1-bit read enable input
//      .RST(RST),                 // 1-bit reset input
//      .WRCLK(user_fifo_wrclk),             // 1-bit write clock input
//      .WREN(user_fifo_wren)                // 1-bit write enable input
//   ); 
//
//   FIFO18_36 #(
//      .SIM_MODE("SAFE"),  // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
//      .ALMOST_FULL_OFFSET(9'h080),      // Sets almost full threshold
//      .ALMOST_EMPTY_OFFSET(9'h080),     // Sets the almost empty threshold
//      .DO_REG(1),                       // Enable output register (0 or 1)
//                                        //   Must be 1 if EN_SYN = "FALSE" 
//      .EN_SYN("FALSE"),                 // Specifies FIFO as Asynchronous ("FALSE") 
//                                        //   or Synchronous ("TRUE")
//      .FIRST_WORD_FALL_THROUGH("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE" 
//   ) FIFO18_36_HigOut_inst (
//      .ALMOSTEMPTY(), // 1-bit almost empty output flag
//      .ALMOSTFULL(almost_full_H),   // 1-bit almost full output flag
//      .DO(user_fifo_q_H),                   // 32-bit data output
//      .DOP(),                 // 4-bit parity data output
//      .EMPTY(user_fifo_empty_H),             // 1-bit empty output flag
//      .FULL(),               // 1-bit full output flag
//      .RDCOUNT(),         // 9-bit read count output
//      .RDERR(),             // 1-bit read error output
//      .WRCOUNT(),         // 9-bit write count output
//      .WRERR(),             // 1-bit write error
//      .DI(user_fifo_data[63:32]),                   // 32-bit data input
//      .DIP(),                 // 4-bit parity input
//      .RDCLK(clk),             // 1-bit read clock input
//      .RDEN(q_rden_H),               // 1-bit read enable input
//      .RST(RST),                 // 1-bit reset input
//      .WRCLK(user_fifo_wrclk),             // 1-bit write clock input
//      .WREN(user_fifo_wren)                // 1-bit write enable input
//   ); 

DMA_Buffer_FWFT FIFO18_36_LowOut_inst (
  .rst(RST), // input rst
  .wr_clk(user_fifo_wrclk), // input wr_clk
  .rd_clk(clk), // input rd_clk
  .din(user_fifo_data[31:0]), // input [31 : 0] din
  .wr_en(user_fifo_wren), // input wr_en
  .rd_en(q_rden_L), // input rd_en
  .dout(user_fifo_q_L), // output [31 : 0] dout
  .full(), // output full
  .almost_full(almost_full_L), // output almost_full
  .empty(user_fifo_empty_L), // output empty
  .almost_empty(),
  .rd_data_count(FRAME_RDCOUNT), // output [8 : 0] rd_data_count
  .wr_data_count(FRAME_WRCOUNT) // output [8 : 0] wr_data_count
);

DMA_Buffer_FWFT FIFO18_36_HigOut_inst (
  .rst(RST), // input rst
  .wr_clk(user_fifo_wrclk), // input wr_clk
  .rd_clk(clk), // input rd_clk
  .din(user_fifo_data[63:32]), // input [31 : 0] din
  .wr_en(user_fifo_wren), // input wr_en
  .rd_en(q_rden_H), // input rd_en
  .dout(user_fifo_q_H), // output [31 : 0] dout
  .full(), // output full
  .almost_full(almost_full_H), // output almost_full
  .empty(user_fifo_empty_H), // output empty
  .almost_empty(),
  .rd_data_count(), // output [8 : 0] rd_data_count
  .wr_data_count() // output [8 : 0] wr_data_count
);


assign RST = ~rst_n | txbuffer_clr;
assign q_rden = (!trn_tdst_rdy_n) && (trn_tdst_dsc_n);
assign q_rden_L = ((bmd_64_tx_state == `BMD_64_TX_MWR_QW1) && q_rden) || ((bmd_64_tx_state == `BMD_64_TX_MWR_QWN) && (cur_mwr_dw_count != 1'h1) && q_rden);
assign q_rden_H = (bmd_64_tx_state == `BMD_64_TX_MWR_QWN) && q_rden;
//assign user_fifo_almost_full = almost_full_L | almost_full_H;
assign user_fifo_almost_full = (FRAME_WRCOUNT >= 10'h0F0) ? 1'b1 : 1'b0;

always @ ( posedge clk ) begin
	if(FRAME_RDCOUNT >= mwr_len_i[31:1])//FRAME_RDCOUNT ---> 64bit,mwr_len_i -->32bit
		data_frame_valid <= 1'b1;
	else
		data_frame_valid <= 1'b0;
end

//rx flowing control   -- rx_tlp_plus
reg [15:0]  req_tlp_plus_cnt;
reg [15:0]  rx_tlp_plus_cnt;
always @ ( posedge clk ) begin
  if (!rst_n | init_rst_i | !mrd_start_i) begin   		 
	 req_tlp_plus_cnt       <= 16'h0000;
  end else begin 
	if(mrd_done)
		req_tlp_plus_cnt       <= 16'h0000;		 
	else if(plus)
		req_tlp_plus_cnt     <= req_tlp_plus_cnt + 16'h1;
	else req_tlp_plus_cnt     <= req_tlp_plus_cnt;
  end
end 

always @ ( posedge clk ) begin
  if (!rst_n | init_rst_i | !mrd_start_i) begin   		 
	 rx_tlp_plus_cnt       <= 16'h0000;
  end else begin 
	if(mrd_done)
		rx_tlp_plus_cnt       <= 16'h0000;		 
	else if(rx_tlp_plus)
		rx_tlp_plus_cnt     <= rx_tlp_plus_cnt + 16'h1;
	else rx_tlp_plus_cnt     <= rx_tlp_plus_cnt;
  end
end 

assign rx_flow_cnt = req_tlp_plus_cnt - rx_tlp_plus_cnt;            

//debug

always @( posedge clk ) begin
	tmrd_wrr_cnt_r <= tmrd_wrr_cnt;
	rx_flow_cnt_r <= rx_flow_cnt;
end 

assign	debug[7:0] = bmd_64_tx_state;
assign	debug[8] = trn_tsof_n;
assign	debug[9] = trn_teof_n;
assign	debug[10] = trn_tsrc_rdy_n;
assign	debug[74:11] = trn_td;
assign	debug[84:75] = FRAME_RDCOUNT;//cur_mwr_dw_count;
assign	debug[85] = mwr_start_i;
assign	debug[86] = mwr_done_o;
assign	debug[94:87] = tmwr_wrr_cnt;
assign	debug[102:95] = mwr_wrr_cnt_i;
assign	debug[103] = mwr_64b_en_i;
assign	debug[104] = mrd_start_i;
assign	debug[105] = serv_mrd;
assign	debug[106] = trn_tdst_rdy_n;
assign	debug[107] = cfg_bm_en;
assign	debug[108] = q_rden;
assign	debug[109] = q_rden_L;
assign	debug[110] = q_rden_H;
assign	debug[111] = user_fifo_empty_L;
assign	debug[112] = user_fifo_empty_H;
assign	debug[113] = data_frame_valid;
assign   debug[122:114] = FRAME_WRCOUNT;
assign   debug[138:123] = rx_tlp_plus_cnt;
assign   debug[154:139] = req_tlp_plus_cnt;


assign   debug[190:187] = req_be_i[3:0];
assign   debug[198:191] = tmrd_wrr_cnt_r;
assign   debug[206:199] = rx_flow_cnt_r;
assign   debug[207] = rx_tlp_plus;
assign   debug[208] = plus;
assign   debug[224:209] = rmrd_count;
assign   debug[240:225] = cur_rd_count;
assign   debug[241] = mrd_done;


endmodule // BMD_64_TX_ENGINE

