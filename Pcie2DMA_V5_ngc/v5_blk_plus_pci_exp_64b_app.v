module  pci_exp_64b_app (

                          trn_clk,
                        trn_reset_n,
                        trn_lnk_up_n,

                        trn_td,
                        trn_trem,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tdst_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_dsc_n,
                        trn_terrfwd_n,
                        trn_tbuf_av,

                        trn_rd,
                        trn_rrem,
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rerrfwd_n,
                        trn_rnp_ok_n,
                        trn_rbar_hit_n,
                        trn_rfc_nph_av,
                        trn_rfc_npd_av,
                        trn_rfc_ph_av,
                        trn_rfc_pd_av,
                        trn_rcpl_streaming_n,
                        cfg_do,
                        cfg_rd_wr_done_n,
                        cfg_di,
                        cfg_byte_en_n,
                        cfg_dwaddr,
                        cfg_wr_en_n,
                        cfg_rd_en_n,
                        cfg_err_cor_n,
                        cfg_err_ur_n,
                        cfg_err_cpl_rdy_n,
                        cfg_err_ecrc_n,
                        cfg_err_cpl_timeout_n,
                        cfg_err_cpl_abort_n,
                        cfg_err_cpl_unexpect_n,
                        cfg_err_posted_n,
                        cfg_err_tlp_cpl_header,
                        cfg_interrupt_n,
                        cfg_interrupt_rdy_n,
                        cfg_interrupt_assert_n,
                        cfg_interrupt_di,
                        cfg_interrupt_do,
                        cfg_interrupt_mmenable,
                        cfg_interrupt_msienable,
                        cfg_turnoff_ok_n,
                        cfg_to_turnoff_n,
                        cfg_pm_wake_n,
                        cfg_status,
                        cfg_command,
                        cfg_dstatus,
                        cfg_dcommand,
                        cfg_lstatus,
                        cfg_lcommand,

                        cfg_bus_number,
                        cfg_device_number,
                        cfg_function_number,
                        cfg_pcie_link_state_n,
                        cfg_dsn,
                        cfg_trn_pending_n,

								ureg_addr, 	
								ureg_wren, 	
								ureg_wr_data,
								ureg_rden,
								ureg_rd_data,

								uDMA_wrclk,//TX
								uDMA_almost_full,
								uDMA_wren,	 
								uDMA_data,	
								txbuffer_clr,  

								uDMA_rdclk,//RX	 
								uDMA_empty,	 
								uDMA_rden,		 
								uDMA_q,	
								rxbuffer_clr, 

								debug_tx,
								debug_rx,
								debug_access
                        );


 // Common

input                                             trn_clk;
input                                             trn_reset_n;
input                                             trn_lnk_up_n;

  // Tx


output [63:0]          trn_td;
output [7:0]           trn_trem;
output                                            trn_tsof_n;
output                                            trn_teof_n;
output                                            trn_tsrc_rdy_n;
input                                             trn_tdst_rdy_n;
output                                            trn_tsrc_dsc_n;
input                                             trn_tdst_dsc_n;
output                                            trn_terrfwd_n;
input  [(4 - 1):0]        trn_tbuf_av;

  // Rx

input  [63:0]          trn_rd;
input  [7:0]           trn_rrem;
input                                             trn_rsof_n;
input                                             trn_reof_n;
input                                             trn_rsrc_rdy_n;
input                                             trn_rsrc_dsc_n;
output                                            trn_rdst_rdy_n;
input                                             trn_rerrfwd_n;
output                                            trn_rnp_ok_n;

input  [6:0]       trn_rbar_hit_n;
input  [7:0]        trn_rfc_nph_av;
input  [11:0]       trn_rfc_npd_av;
input  [7:0]        trn_rfc_ph_av;
input  [11:0]       trn_rfc_pd_av;



output                                            trn_rcpl_streaming_n;


  // Host (CFG) Interface


input  [31:0]          cfg_do;
output [31:0]          cfg_di;
output [3:0]        cfg_byte_en_n;
output [9:0]          cfg_dwaddr;

input                                             cfg_rd_wr_done_n;
output                                            cfg_wr_en_n;
output                                            cfg_rd_en_n;
output                                            cfg_err_cor_n;
output                                            cfg_err_ur_n;
input                                             cfg_err_cpl_rdy_n;
output                                            cfg_err_ecrc_n;
output                                            cfg_err_cpl_timeout_n;
output                                            cfg_err_cpl_abort_n;
output                                            cfg_err_cpl_unexpect_n;
output                                            cfg_err_posted_n;
output                                            cfg_interrupt_n;
input                                             cfg_interrupt_rdy_n;
output                                            cfg_interrupt_assert_n;
output [7:0]                                      cfg_interrupt_di;
input  [7:0]                                      cfg_interrupt_do;
input  [2:0]                                      cfg_interrupt_mmenable;
input                                             cfg_interrupt_msienable;
output                                            cfg_turnoff_ok_n;
input                                             cfg_to_turnoff_n;
output                                            cfg_pm_wake_n;

output [47:0]        cfg_err_tlp_cpl_header;
input  [15:0]           cfg_status;
input  [15:0]           cfg_command;
input  [15:0]           cfg_dstatus;
input  [15:0]           cfg_dcommand;
input  [15:0]           cfg_lstatus;
input  [15:0]           cfg_lcommand;
input  [7:0]        cfg_bus_number;
input  [4:0]        cfg_device_number;
input  [2:0]        cfg_function_number;
input  [2:0]         cfg_pcie_link_state_n;
output               cfg_trn_pending_n;
output [63:0]           cfg_dsn;          

  output [29:0]  									   	 ureg_addr; 	
  output         									 		 ureg_wren; 	
  output [31:0]  									 		 ureg_wr_data;
  output  												 	 ureg_rden;
  input  [31:0]  									 		 ureg_rd_data;
								
  input														 uDMA_wrclk;//TX
  output														 uDMA_almost_full;
  input														 uDMA_wren;	 
  input	[63:0]											 uDMA_data;	
  input														 txbuffer_clr;  
								
  input 													 	 uDMA_rdclk;//RX	 
  output														 uDMA_empty;	 
  input													  	 uDMA_rden;		 
  output	[63:0]										 	 uDMA_q;	
  input														 rxbuffer_clr; 
  
  output [255:0]											 debug_tx;
  output [255:0]											 debug_rx;
  output [255:0]											 debug_access;

endmodule // pci_exp_64b_app



