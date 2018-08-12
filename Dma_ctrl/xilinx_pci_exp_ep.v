//case : 
//(register read op) 
//always @(posedge utrn_clk) begin 
//  if(rst)
//     ureg_rd_data <=  {32{1'bz}};
//  else 
//		case (ureg_addr) 
//			16'h0220	:	begin ureg_rd_data		<=	DATA;	end
//			     :
//				  :
//			default	: begin	ureg_rd_data		<=	{32{1'bz}}; end
//		endcase
//	end
//
//(register write op) 
//always @(posedge utrn_clk) begin 
//  if(ureg_wren)
//		case (ureg_addr) 
//			16'h0220	:	begin 	DATA{n}	<= ureg_wr_data;	end
//			     :
//				  :			
//		endcase
//	end
//------------------------------------------------------------------------------
module     xilinx_pci_exp_ep #(
	parameter			PCI_EXP_LINK_WIDTH		= 8 ,
   parameter 			DEBUG_PORT					= "ON"
)
(
  output  [PCI_EXP_LINK_WIDTH - 1:0]    pci_exp_txp,
  output  [PCI_EXP_LINK_WIDTH - 1:0]    pci_exp_txn,
  input   [PCI_EXP_LINK_WIDTH - 1:0]    pci_exp_rxp,
  input   [PCI_EXP_LINK_WIDTH - 1:0]    pci_exp_rxn,
  input            sys_clk_p,//100MHz
  input            sys_clk_n,
  input            sys_reset_n//SYS_RST,PC


//  input            CLK_P,
//  input            CLK_N	
//  output				 utrn_clk,
//  output [29:0]  	 ureg_addr,
//  output         	 ureg_wren, 	
//  output [31:0]  	 ureg_wr_data,
//  output  			 ureg_rden,
//  input  [31:0]  	 ureg_rd_data,//  
 
//  input				 uDMA_wrclk,//TX
//  output				 uDMA_almost_full,
//  input				 uDMA_wren,	 
//  input	[63:0]	 uDMA_data,	
//  input            txbuffer_clr,   
					
//  input 				 uDMA_rdclk,//RX	 
//  output				 uDMA_empty,	 
//  input				 uDMA_rden,		 
//  output	[63:0]	 uDMA_q,
//  input	          rxbuffer_clr,
//  output [255:0]	 debug_tx,  
//  output [255:0]	 debug_rx,
//  output [255:0]   debug_access 
);
  wire				 utrn_clk;
  wire [29:0]  	 ureg_addr; 	
  wire         	 ureg_wren; 	
  wire [31:0]  	 ureg_wr_data;
  wire  			    ureg_rden;
  reg  [31:0]  	 ureg_rd_data;
  //TX					
  wire				 uDMA_wrclk;
  wire				 uDMA_almost_full;
  wire				 uDMA_wren;	 
  wire	[63:0]	 uDMA_data;			 
  wire				 txbuffer_clr;
  //RX
  wire 				 uDMA_rdclk;	 
  wire				 uDMA_empty;	 
  wire				 uDMA_rden;		 
  wire	[63:0]	 uDMA_q ;
  wire				 rxbuffer_clr;
  //DEBUG
  wire [255:0]	 	 debug_tx;  
  wire [255:0]	 	 debug_rx;
  wire [255:0]   	 debug_access; 

    //-------------------------------------------------------
    // Local Wires
    //-------------------------------------------------------
    wire                                              sys_reset_n_c;
    wire                                              sys_clk_c;
    wire                                              trn_clk_c;//synthesis attribute max_fanout of trn_clk_c is "100000"
    wire                                              trn_reset_n_c;
    wire                                              trn_lnk_up_n_c;
    wire                                              cfg_trn_pending_n_c;
    wire [(64 - 1):0]             cfg_dsn_n_c;
    wire                                              trn_tsof_n_c;
    wire                                              trn_teof_n_c;
    wire                                              trn_tsrc_rdy_n_c;
    wire                                              trn_tdst_rdy_n_c;
    wire                                              trn_tsrc_dsc_n_c;
    wire                                              trn_terrfwd_n_c;
    wire                                              trn_tdst_dsc_n_c;
    wire    [(64 - 1):0]         trn_td_c;
    wire    [7:0]          trn_trem_n_c;
    wire    [( 4 -1 ):0]       trn_tbuf_av_c;

    wire                                              trn_rsof_n_c;
    wire                                              trn_reof_n_c;
    wire                                              trn_rsrc_rdy_n_c;
    wire                                              trn_rsrc_dsc_n_c;
    wire                                              trn_rdst_rdy_n_c;
    wire                                              trn_rerrfwd_n_c;
    wire                                              trn_rnp_ok_n_c;

    wire    [(64 - 1):0]         trn_rd_c;
    wire    [7:0]          trn_rrem_n_c;
    wire    [6:0]      trn_rbar_hit_n_c;
    wire    [7:0]       trn_rfc_nph_av_c;
    wire    [11:0]      trn_rfc_npd_av_c;
    wire    [7:0]       trn_rfc_ph_av_c;
    wire    [11:0]      trn_rfc_pd_av_c;
    wire                                              trn_rcpl_streaming_n_c;

    wire    [31:0]         cfg_do_c;
    wire    [31:0]         cfg_di_c;
    wire    [9:0]         cfg_dwaddr_c;
    wire    [3:0]       cfg_byte_en_n_c;
    wire    [47:0]       cfg_err_tlp_cpl_header_c;

    wire                                              cfg_wr_en_n_c;
    wire                                              cfg_rd_en_n_c;
    wire                                              cfg_rd_wr_done_n_c;
    wire                                              cfg_err_cor_n_c;
    wire                                              cfg_err_ur_n_c;
    wire                                              cfg_err_cpl_rdy_n_c;
    wire                                              cfg_err_ecrc_n_c;
    wire                                              cfg_err_cpl_timeout_n_c;
    wire                                              cfg_err_cpl_abort_n_c;
    wire                                              cfg_err_cpl_unexpect_n_c;
    wire                                              cfg_err_posted_n_c;
    wire                                              cfg_err_locked_n_c;
    wire                                              cfg_interrupt_n_c;
    wire                                              cfg_interrupt_rdy_n_c;

    wire                                              cfg_interrupt_assert_n_c;
    wire [7 : 0]                                      cfg_interrupt_di_c;
    wire [7 : 0]                                      cfg_interrupt_do_c;
    wire [2 : 0]                                      cfg_interrupt_mmenable_c;
    wire                                              cfg_interrupt_msienable_c;

    wire                                              cfg_turnoff_ok_n_c;
    wire                                              cfg_to_turnoff_n;
    wire                                              cfg_pm_wake_n_c;
    wire    [2:0]        cfg_pcie_link_state_n_c;
    wire    [7:0]       cfg_bus_number_c;
    wire    [4:0]       cfg_device_number_c;
    wire    [2:0]       cfg_function_number_c;
    wire    [15:0]          cfg_status_c;
    wire    [15:0]          cfg_command_c;
    wire    [15:0]          cfg_dstatus_c;
    wire    [15:0]          cfg_dcommand_c;
    wire    [15:0]          cfg_lstatus_c;
    wire    [15:0]          cfg_lcommand_c;
    
  wire	[29:0]				ureg_addr_match;
  wire							sys_clk_pll;
  
  wire							sys_clk_ref;
  
  wire							CLKFBOUT,CLKFBIN;
  reg        			      up_rst = 1'b0;
  reg		[25:0]		   	up_wait_cnt = 26'b0;	
  //-------------------------------------------------------
  //degug
  wire	[35:0] 	CONTROL0,CONTROL1;
  wire				Trig_clk0;
  wire	[31:0]	Trig_event;
  wire	[255:0]	Trig_signal;
  	 wire  [255:0]	Trig_d;
	 wire  [31:0]	Trig_ev;	 
  
  	 reg	[63:0]			cnt;
	 reg						twr;
	 reg	[4:0]				clk_cnt;

  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------
  IBUF sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));
  
//	always @(posedge sys_clk_ref) begin //2012-07-30
//		if(up_wait_cnt<26'h3_ff_ff_f0) begin
//			up_rst <= 1'b1;
//			up_wait_cnt <= up_wait_cnt + 1'b1;
//		end else begin
//			up_rst <= 1'b0;
//		end
//	end
//	
//	assign sys_reset_n_c = ~up_rst;
//-------------------------------------------------------
// Virtex5-FX Global Clock Buffer
//-------------------------------------------------------
  IBUFDS refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));  // 100 MHz

//   IBUFDS  refclk_ibuf(.O(sys_clk_ref), .I(CLK_P), .IB(CLK_N));//125MHz for LS2000 ,150MHz for VPX Board
//   BUFG    sys_refclk_ibuf(.O(sys_clk_c), .I(sys_clk_pll));//100MHz

//	assign CLKFBIN = CLKFBOUT;
//   PLL_BASE #(
//      .BANDWIDTH("OPTIMIZED"),  // "HIGH", "LOW" or "OPTIMIZED" 
//      .CLKFBOUT_MULT(8),        // Multiplication factor for all output clocks
//      .CLKFBOUT_PHASE(0.0),     // Phase shift (degrees) of all output clocks
//      .CLKIN_PERIOD(8),     // Clock period (ns) of input clock on CLKIN
//      .CLKOUT0_DIVIDE(10),       // Division factor for CLKOUT0 (1 to 128)
//      .CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
//      .CLKOUT0_PHASE(0.0),      // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
//      .CLKOUT1_DIVIDE(10),       // Division factor for CLKOUT1 (1 to 128)
//      .CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
//      .CLKOUT1_PHASE(0.0),      // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
//      .CLKOUT2_DIVIDE(10),       // Division factor for CLKOUT2 (1 to 128)
//      .CLKOUT2_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT2 (0.01 to 0.99)
//      .CLKOUT2_PHASE(0.0),      // Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
//      .CLKOUT3_DIVIDE(10),       // Division factor for CLKOUT3 (1 to 128)
//      .CLKOUT3_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT3 (0.01 to 0.99)
//      .CLKOUT3_PHASE(0.0),      // Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
//      .CLKOUT4_DIVIDE(10),       // Division factor for CLKOUT4 (1 to 128)
//      .CLKOUT4_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT4 (0.01 to 0.99)
//      .CLKOUT4_PHASE(0.0),      // Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
//      .CLKOUT5_DIVIDE(10),       // Division factor for CLKOUT5 (1 to 128)
//      .CLKOUT5_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT5 (0.01 to 0.99)
//      .CLKOUT5_PHASE(0.0),      // Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
//      .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS", 
//                                //   "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", 
//                                //   "DCM2PLL", "PLL2DCM" 
//      .DIVCLK_DIVIDE(1),        // Division factor for all clocks (1 to 52)
//      .REF_JITTER(0.100)        // Input reference jitter (0.000 to 0.999 UI%)
//   ) PLL_BASE_inst (
//      .CLKFBOUT(CLKFBOUT),      // General output feedback signal
//      .CLKOUT0(sys_clk_pll),        // One of six general clock output signals
//      .CLKOUT1(),        // One of six general clock output signals
//      .CLKOUT2(),        // One of six general clock output signals
//      .CLKOUT3(),        // One of six general clock output signals
//      .CLKOUT4(),        // One of six general clock output signals
//      .CLKOUT5(),        // One of six general clock output signals
//      .LOCKED(),          // Active high PLL lock signal
//      .CLKFBIN(CLKFBIN),        // Clock feedback input
//      .CLKIN(sys_clk_ref),            // Clock input
//      .RST(!sys_reset_n_c)                 // Asynchronous PLL reset
//   );
  //-------------------------------------------------------
  // Endpoint Implementation Application
  //-------------------------------------------------------
pci_exp_64b_app app (


      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // I
      .trn_reset_n( trn_reset_n_c ),           // I
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // I

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // O [63/31:0]
      .trn_trem( trn_trem_n_c ),               // O [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // O
      .trn_teof_n( trn_teof_n_c ),             // O
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // O
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // O
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // I
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // I
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // O
      .trn_tbuf_av( trn_tbuf_av_c ),           // I [4/3:0]


      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // I [63/31:0]
      .trn_rrem( trn_rrem_n_c ),               // I [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // I
      .trn_reof_n( trn_reof_n_c ),             // I
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // I
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // I
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // O
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // I
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // O
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // I [6:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // I [11:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // I [7:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // I [11:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // I [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),  // O

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                   // I [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),               // I
      .cfg_di( cfg_di_c ),                                   // O [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                     // O
      .cfg_dwaddr( cfg_dwaddr_c ),                           // O
      .cfg_wr_en_n( cfg_wr_en_n_c ),                         // O
      .cfg_rd_en_n( cfg_rd_en_n_c ),                         // O
      .cfg_err_cor_n( cfg_err_cor_n_c ),                     // O
      .cfg_err_ur_n( cfg_err_ur_n_c ),                       // O
      .cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),             // I
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                   // O
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),     // O
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),         // O
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),   // O
      .cfg_err_posted_n( cfg_err_posted_n_c ),               // O
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),   // O [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                 // O
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),         // I

      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),     // O
      .cfg_interrupt_di(cfg_interrupt_di_c),                 // O [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                 // I [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),     // I [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),   // I
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),               // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                     // O
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),     // I [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),             // O
      .cfg_dsn( cfg_dsn_n_c),                                // O [63:0]

      .cfg_bus_number( cfg_bus_number_c ),                   // I [7:0]
      .cfg_device_number( cfg_device_number_c ),             // I [4:0]
      .cfg_function_number( cfg_function_number_c ),         // I [2:0]
      .cfg_status( cfg_status_c ),                           // I [15:0]
      .cfg_command( cfg_command_c ),                         // I [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                         // I [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                       // I [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                         // I [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // I [15:0]

		  .ureg_addr(ureg_addr_match), 	
		  .ureg_wren(ureg_wren), 		
		  .ureg_wr_data(ureg_wr_data),
		  .ureg_rden(ureg_rden),
		  .ureg_rd_data(ureg_rd_data),
		  
		  .uDMA_wrclk(uDMA_wrclk),//TX
		  .uDMA_almost_full(uDMA_almost_full),
		  .uDMA_wren(uDMA_wren),
		  .uDMA_data(uDMA_data),
		  .txbuffer_clr(txbuffer_clr), 
		  
		  .uDMA_rdclk(uDMA_rdclk),//RX
		  .uDMA_empty(uDMA_empty),
		  .uDMA_rden(uDMA_rden),	
		  .uDMA_q(uDMA_q),   
		  .rxbuffer_clr(rxbuffer_clr), 
		  
		  .debug_tx(debug_tx),
		  .debug_rx(debug_rx),
		  .debug_access(debug_access)
      );


endpoint_blk_plus_v1_15  
#(
   .PCI_EXP_LINK_WIDTH( PCI_EXP_LINK_WIDTH )
) 
	ep (


      //
      // PCI Express Fabric Interface
      //

      .pci_exp_txp( pci_exp_txp ),             // O [7/3/0:0]
      .pci_exp_txn( pci_exp_txn ),             // O [7/3/0:0]
      .pci_exp_rxp( pci_exp_rxp ),             // O [7/3/0:0]
      .pci_exp_rxn( pci_exp_rxn ),             // O [7/3/0:0]


      //
      // System ( SYS ) Interface
      //

      .sys_clk( sys_clk_c ),                                 // I

      .sys_reset_n( sys_reset_n_c ),                         // I
      .refclkout( ),       // O



      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // O
      .trn_reset_n( trn_reset_n_c ),           // O
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // O

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // I [63/31:0]
        .trn_trem_n( trn_trem_n_c ),             // I [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // I
      .trn_teof_n( trn_teof_n_c ),             // I
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // I
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // I
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // O
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // O
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // I
      .trn_tbuf_av( trn_tbuf_av_c ),           // O [4/3:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // O [63/31:0]
        .trn_rrem_n( trn_rrem_n_c ),             // O [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // O
      .trn_reof_n( trn_reof_n_c ),             // O
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // O
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // O
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // I
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // O
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // I
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // O [6:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // O [11:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // O [7:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // O [11:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // O [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),       // I

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                    // O [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),                // O
      .cfg_di( cfg_di_c ),                                    // I [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                      // I [3:0]
      .cfg_dwaddr( cfg_dwaddr_c ),                            // I [9:0]
      .cfg_wr_en_n( cfg_wr_en_n_c ),                          // I
      .cfg_rd_en_n( cfg_rd_en_n_c ),                          // I

      .cfg_err_cor_n( cfg_err_cor_n_c ),                      // I
      .cfg_err_ur_n( cfg_err_ur_n_c ),                        // I
      .cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),              // O
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                    // I
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),      // I
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),          // I
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),    // I
      .cfg_err_posted_n( cfg_err_posted_n_c ),                // I
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),    // I [47:0]
      .cfg_err_locked_n( 1'b1 ),                // I
      .cfg_interrupt_n( cfg_interrupt_n_c ),                  // I
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),          // O

      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),      // I
      .cfg_interrupt_di(cfg_interrupt_di_c),                  // I [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                  // O [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),      // O [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),    // O
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),                // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                      // I
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),      // O [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),              // I
      .cfg_bus_number( cfg_bus_number_c ),                    // O [7:0]
      .cfg_device_number( cfg_device_number_c ),              // O [4:0]
      .cfg_function_number( cfg_function_number_c ),          // O [2:0]
      .cfg_status( cfg_status_c ),                            // O [15:0]
      .cfg_command( cfg_command_c ),                          // O [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                          // O [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                        // O [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                          // O [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // O [15:0]
      .cfg_dsn( cfg_dsn_n_c),                                // I [63:0]


       // The following is used for simulation only.  Setting
       // the following core input to 1 will result in a fast
       // train simulation to happen.  This bit should not be set
       // during synthesis or the core may not operate properly.
       `ifdef SIMULATION
       .fast_train_simulation_only(1'b1)
       `else
       .fast_train_simulation_only(1'b0)
       `endif

);
assign ureg_addr[18:0] = ureg_addr_match[18:0];//2M ,BAR0 = FFE00000,Addr/4
assign ureg_addr[29:19] = 0;
assign utrn_clk = trn_clk_c;
//debug
generate
if (DEBUG_PORT == "ON") begin: debug_inst	
assign Trig_clk0 = debug_tx[255];

assign Trig_event[10:0] = debug_tx[10:0];
assign Trig_event[11] = debug_tx[85];
assign Trig_event[12] = debug_tx[86];
assign Trig_event[13] = debug_tx[104];
assign Trig_event[21:14] = debug_rx[7:0];
assign Trig_event[22] = debug_rx[8];
assign Trig_event[23] = debug_rx[9];
assign Trig_event[24] = debug_rx[10];
assign Trig_event[25] = debug_rx[11];
assign Trig_event[26] = debug_access[7];

assign Trig_signal[107:0] = debug_tx[107 :0];
assign Trig_signal[114:108] = trn_rbar_hit_n_c;	
assign Trig_signal[126:115] = debug_rx[11:0];

assign Trig_signal[198:127] =  debug_access[71:0];

assign Trig_signal[214:199] =  cfg_lstatus_c;

	icon icon_inst (
		 .CONTROL0(CONTROL0), // INOUT BUS [35:0]
		 .CONTROL1(CONTROL1)
		 
	);

	ila ila_inst (
		 .CONTROL(CONTROL0), // INOUT BUS [35:0]
		 .CLK(Trig_clk0), // IN
		 .DATA(Trig_signal), // IN BUS [255:0]
		 .TRIG0(Trig_event) // IN BUS [31:0]
	);
	
	assign Trig_ev[0] = 	ureg_wren;
	assign Trig_ev[1] = 	ureg_rden;
	assign Trig_ev[2] =  debug_tx[85];//mwr_start_i
	assign Trig_ev[3] =  debug_tx[104];//mrd_start_i
	assign Trig_ev[4] =  debug_tx[109];
	assign Trig_ev[5] =  debug_tx[86];//mwr_done_o
	assign Trig_ev[6] =  debug_tx[187];//mrd_done_i

	assign Trig_d[29:0] = ureg_addr;
	assign Trig_d[30] = ureg_wren;
	assign Trig_d[62:31] = ureg_wr_data;
	assign Trig_d[63] = ureg_rden;
	assign Trig_d[95:64] = ureg_rd_data;
	assign Trig_d[159:96] = debug_rx[75:12];
	assign Trig_d[223:160] = debug_rx[142:79];
	assign Trig_d[224] = debug_rx[143];//user_fifo_rden

	ila ila_inst1 (
		 .CONTROL(CONTROL1), // INOUT BUS [35:0]
		 .CLK(Trig_clk0), // IN
		 .DATA(Trig_d), // IN BUS [255:0]
		 .TRIG0(Trig_ev) // IN BUS [31:0]
	);
end 

   

always @ ( posedge trn_clk_c ) begin
	clk_cnt <= clk_cnt + 1;
end

assign uDMA_wrclk = trn_clk_c;//clk_cnt[4];

always @ ( posedge uDMA_wrclk ) begin
  if (!trn_reset_n_c | trn_lnk_up_n_c ) begin  
  	 cnt <= 64'b0;
	 twr <= 1'b0;
  end else begin 
  if(debug_tx[85])begin
			if(!uDMA_almost_full)begin
			 cnt <= cnt + 64'b1;
			 twr <= 1'b1;
			end else begin
			cnt <= cnt;
			twr <= 1'b0;
			end
	end else begin
		  	cnt <= cnt;
			twr <= 1'b0;
			end
  end
end

assign uDMA_data = cnt;
assign uDMA_wren = twr;

assign uDMA_rdclk = trn_clk_c;
assign uDMA_rden = ~uDMA_empty;

assign txbuffer_clr = !trn_reset_n_c | trn_lnk_up_n_c;
assign rxbuffer_clr = !trn_reset_n_c | trn_lnk_up_n_c;

endgenerate

always @(posedge utrn_clk) begin 
  if(!trn_reset_n_c | trn_lnk_up_n_c)
     ureg_rd_data <=  {32{1'bz}};
  else 
		case (ureg_addr[17:2]) 
			16'h0220	:	begin ureg_rd_data		<=	32'h8888_7777;	end
			default	: begin	ureg_rd_data		<=	{32{1'bz}}; end
		endcase
	end


endmodule // XILINX_PCI_EXP_EP
