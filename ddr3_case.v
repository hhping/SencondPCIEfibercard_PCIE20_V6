//*****************************************************************************

`timescale 1ps/1ps

module ddr3_case #
  (
//   parameter REFCLK_FREQ             = 200,
//                                       // # = 200 when design frequency <= 533 MHz,
//                                       //   = 300 when design frequency > 533 MHz.
//   parameter IODELAY_GRP             = "IODELAY_MIG",
//                                       // It is associated to a set of IODELAYs with
//                                       // an IDELAYCTRL that have same IODELAY CONTROLLER
//                                       // clock frequency.
//   parameter MMCM_ADV_BANDWIDTH      = "OPTIMIZED",
//                                       // MMCM programming algorithm
//   parameter CLKFBOUT_MULT_F         = 6,
//                                       // write PLL VCO multiplier.
//   parameter DIVCLK_DIVIDE           = 2,
//                                       // write PLL VCO divisor.
//   parameter CLKOUT_DIVIDE           = 3,
//                                       // VCO output divisor for fast (memory) clocks.
//   parameter nCK_PER_CLK             = 2,
//                                       // # of memory CKs per fabric clock.
//                                       // # = 2, 1.
//   parameter tCK                     = 2500,
//                                       // memory tCK paramter.
//                                       // # = Clock Period.
//   parameter DEBUG_PORT              = "OFF",
//                                       // # = "ON" Enable debug signals/controls.
//                                       //   = "OFF" Disable debug signals/controls.
//   parameter SIM_BYPASS_INIT_CAL     = "OFF",
//                                       // # = "OFF" -  Complete memory init &
//                                       //              calibration sequence
//                                       // # = "SKIP" - Skip memory init &
//                                       //              calibration sequence
//                                       // # = "FAST" - Skip memory init & use
//                                       //              abbreviated calib sequence
   parameter SIM_INIT_OPTION         = "NONE",
//                                       // # = "SKIP_PU_DLY" - Skip the memory
//                                       //                     initilization sequence,
//                                       //   = "NONE" - Complete the memory
//                                       //              initilization sequence.
   parameter SIM_CAL_OPTION          = "NONE",
//                                       // # = "FAST_CAL" - Skip the delay
//                                       //                  Calibration process,
//                                       //   = "NONE" - Complete the delay
//                                       //              Calibration process.
//   parameter nCS_PER_RANK            = 1,
//                                       // # of unique CS outputs per Rank for
//                                       // phy.
//   parameter DQS_CNT_WIDTH           = 3,
//                                       // # = ceil(log2(DQS_WIDTH)).
//   parameter RANK_WIDTH              = 1,
//                                       // # = ceil(log2(RANKS)).
//   parameter BANK_WIDTH              = 3,
//                                       // # of memory Bank Address bits.
//   parameter CK_WIDTH                = 1,
//                                       // # of CK/CK# outputs to memory.
//   parameter CKE_WIDTH               = 1,
//                                       // # of CKE outputs to memory.
//   parameter COL_WIDTH               = 10,
//                                       // # of memory Column Address bits.
//   parameter CS_WIDTH                = 1,
//                                       // # of unique CS outputs to memory.
//   parameter DM_WIDTH                = 8,
//                                       // # of Data Mask bits.
//   parameter DQ_WIDTH                = 64,
//                                       // # of Data (DQ) bits.
//   parameter DQS_WIDTH               = 8,
//                                       // # of DQS/DQS# bits.
//   parameter ROW_WIDTH               = 15,
//                                       // # of memory Row Address bits.
//   parameter BURST_MODE              = "8",
//                                       // Burst Length (Mode Register 0).
//                                       // # = "8", "4", "OTF".
//   parameter BM_CNT_WIDTH            = 2,
//                                       // # = ceil(log2(nBANK_MACHS)).
//   parameter ADDR_CMD_MODE           = "1T" ,
//                                       // # = "2T", "1T".
//   parameter ORDERING                = "NORM",
//                                       // # = "NORM", "STRICT", "RELAXED".
//   parameter WRLVL                   = "ON",
//                                       // # = "ON" - DDR3 SDRAM
//                                       //   = "OFF" - DDR2 SDRAM.
//   parameter PHASE_DETECT            = "ON",
//                                       // # = "ON", "OFF".
//   parameter RTT_NOM                 = "60",
//                                       // RTT_NOM (ODT) (Mode Register 1).
//                                       // # = "DISABLED" - RTT_NOM disabled,
//                                       //   = "120" - RZQ/2,
//                                       //   = "60"  - RZQ/4,
//                                       //   = "40"  - RZQ/6.
//   parameter RTT_WR                  = "OFF",
//                                       // RTT_WR (ODT) (Mode Register 2).
//                                       // # = "OFF" - Dynamic ODT off,
//                                       //   = "120" - RZQ/2,
//                                       //   = "60"  - RZQ/4,
//   parameter OUTPUT_DRV              = "HIGH",
//                                       // Output Driver Impedance Control (Mode Register 1).
//                                       // # = "HIGH" - RZQ/7,
//                                       //   = "LOW" - RZQ/6.
//   parameter REG_CTRL                = "OFF",
//                                       // # = "ON" - RDIMMs,
//                                       //   = "OFF" - Components, SODIMMs, UDIMMs.
//   parameter nDQS_COL0               = 3,
//                                       // Number of DQS groups in I/O column #1.
//   parameter nDQS_COL1               = 5,
//                                       // Number of DQS groups in I/O column #2.
//   parameter nDQS_COL2               = 0,
//                                       // Number of DQS groups in I/O column #3.
//   parameter nDQS_COL3               = 0,
//                                       // Number of DQS groups in I/O column #4.
//   parameter DQS_LOC_COL0            = 24'h020100,
//                                       // DQS groups in column #1.
//   parameter DQS_LOC_COL1            = 40'h0706050403,
//                                       // DQS groups in column #2.
//   parameter DQS_LOC_COL2            = 0,
//                                       // DQS groups in column #3.
//   parameter DQS_LOC_COL3            = 0,
//                                       // DQS groups in column #4.
//   parameter tPRDI                   = 1_000_000,
//                                       // memory tPRDI paramter.
//   parameter tREFI                   = 7800000,
//                                       // memory tREFI paramter.
//   parameter tZQI                    = 128_000_000,
//                                       // memory tZQI paramter.
//   parameter ADDR_WIDTH              = 27,



   parameter REFCLK_FREQ             = 200,
                                       // # = 200 for all design frequencies of
                                       //         -1 speed grade devices
                                       //   = 200 when design frequency < 480 MHz
                                       //         for -2 and -3 speed grade devices.
                                       //   = 300 when design frequency >= 480 MHz
                                       //         for -2 and -3 speed grade devices.
   parameter IODELAY_GRP             = "IODELAY_MIG",
                                       // It is associated to a set of IODELAYs with
                                       // an IDELAYCTRL that have same IODELAY CONTROLLER
                                       // clock frequency.
   parameter MMCM_ADV_BANDWIDTH      = "OPTIMIZED",
                                       // MMCM programming algorithm
   parameter CLKFBOUT_MULT_F         = 6,
                                       // write PLL VCO multiplier.
   parameter DIVCLK_DIVIDE           = 2,
                                       // write PLL VCO divisor.
   parameter CLKOUT_DIVIDE           = 3,
                                       // VCO output divisor for fast (memory) clocks.
   parameter nCK_PER_CLK             = 2,
                                       // # of memory CKs per fabric clock.
                                       // # = 2, 1.
   parameter tCK                     = 2500,
                                       // memory tCK paramter.
                                       // # = Clock Period.
   parameter DEBUG_PORT              = "OFF",
                                       // # = "ON" Enable debug signals/controls.
                                       //   = "OFF" Disable debug signals/controls.
   parameter SIM_BYPASS_INIT_CAL     = "OFF",
                                       // # = "OFF" -  Complete memory init &
                                       //              calibration sequence
                                       // # = "SKIP" - Skip memory init &
                                       //              calibration sequence
                                       // # = "FAST" - Skip memory init & use
                                       //              abbreviated calib sequence
   parameter nCS_PER_RANK            = 1,
                                       // # of unique CS outputs per Rank for
                                       // phy.
   parameter DQS_CNT_WIDTH           = 3,
                                       // # = ceil(log2(DQS_WIDTH)).
   parameter RANK_WIDTH              = 1,
                                       // # = ceil(log2(RANKS)).
   parameter BANK_WIDTH              = 3,
                                       // # of memory Bank Address bits.
   parameter CK_WIDTH                = 1,
                                       // # of CK/CK# outputs to memory.
   parameter CKE_WIDTH               = 1,
                                       // # of CKE outputs to memory.
   parameter COL_WIDTH               = 10,
                                       // # of memory Column Address bits.
   parameter CS_WIDTH                = 1,
                                       // # of unique CS outputs to memory.
   parameter DM_WIDTH                = 8,
                                       // # of Data Mask bits.
   parameter DQ_WIDTH                = 64,
                                       // # of Data (DQ) bits.
   parameter DQS_WIDTH               = 8,
                                       // # of DQS/DQS# bits.
   parameter ROW_WIDTH               = 15,
                                       // # of memory Row Address bits.
   parameter BURST_MODE              = "8",
                                       // Burst Length (Mode Register 0).
                                       // # = "8", "4", "OTF".
   parameter BM_CNT_WIDTH            = 2,
                                       // # = ceil(log2(nBANK_MACHS)).
   parameter ADDR_CMD_MODE           = "1T" ,
                                       // # = "2T", "1T".
   parameter ORDERING                = "NORM",
                                       // # = "NORM", "STRICT".
   parameter WRLVL                   = "ON",
                                       // # = "ON" - DDR3 SDRAM
                                       //   = "OFF" - DDR2 SDRAM.
   parameter PHASE_DETECT            = "ON",
                                       // # = "ON", "OFF".
   parameter RTT_NOM                 = "60",
                                       // RTT_NOM (ODT) (Mode Register 1).
                                       // # = "DISABLED" - RTT_NOM disabled,
                                       //   = "120" - RZQ/2,
                                       //   = "60"  - RZQ/4,
                                       //   = "40"  - RZQ/6.
   parameter RTT_WR                  = "OFF",
                                       // RTT_WR (ODT) (Mode Register 2).
                                       // # = "OFF" - Dynamic ODT off,
                                       //   = "120" - RZQ/2,
                                       //   = "60"  - RZQ/4,
   parameter OUTPUT_DRV              = "HIGH",
                                       // Output Driver Impedance Control (Mode Register 1).
                                       // # = "HIGH" - RZQ/7,
                                       //   = "LOW" - RZQ/6.
   parameter REG_CTRL                = "OFF",
                                       // # = "ON" - RDIMMs,
                                       //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter nDQS_COL0               = 3,
                                       // Number of DQS groups in I/O column #1.
   parameter nDQS_COL1               = 5,
                                       // Number of DQS groups in I/O column #2.
   parameter nDQS_COL2               = 0,
                                       // Number of DQS groups in I/O column #3.
   parameter nDQS_COL3               = 0,
                                       // Number of DQS groups in I/O column #4.
   parameter DQS_LOC_COL0            = 24'h020100,
                                       // DQS groups in column #1.
   parameter DQS_LOC_COL1            = 40'h0706050403,
                                       // DQS groups in column #2.
   parameter DQS_LOC_COL2            = 0,
                                       // DQS groups in column #3.
   parameter DQS_LOC_COL3            = 0,
                                       // DQS groups in column #4.
   parameter tPRDI                   = 1_000_000,
                                       // memory tPRDI paramter.
   parameter tREFI                   = 7800000,
                                       // memory tREFI paramter.
   parameter tZQI                    = 128_000_000,
                                       // memory tZQI paramter.
   parameter ADDR_WIDTH              = 29,
                                       // # = RANK_WIDTH + BANK_WIDTH
                                       //     + ROW_WIDTH + COL_WIDTH;
   parameter ECC                     = "OFF",
   parameter ECC_TEST                = "OFF",
   parameter TCQ                     = 100,
   parameter DATA_WIDTH              = 64,
   // If parameters overrinding is used for simulation, PAYLOAD_WIDTH parameter
   // should to be overidden along with the vsim command
   parameter PAYLOAD_WIDTH           = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH,
//   parameter RST_ACT_LOW             = 1,
                                       // =1 for active low reset,
                                       // =0 for active high.
  // parameter INPUT_CLK_TYPE          = "DIFFERENTIAL",
                                       // input clock type DIFFERENTIAL or SINGLE_ENDED
   parameter STARVE_LIMIT            = 2,
                                       // # = 2,3,4.


                                       // # = RANK_WIDTH + BANK_WIDTH
                                       //     + ROW_WIDTH + COL_WIDTH;
//   parameter ECC_TEST                = "OFF",
//   parameter TCQ                     = 100,

   parameter RST_ACT_LOW             = 0,
                                       // =1 for active low reset,
                                       // =0 for active high.
   parameter INPUT_CLK_TYPE          = "DIFFERENTIAL",//"SINGLE_ENDED",
                                       // input clock type DIFFERENTIAL or SINGLE_ENDED
   parameter BURST_LEN               = 8,

   parameter CH_NUM                  = 2, //通道数
   parameter STATE_CNT               = 16,//64, //DMA数据量：STATE_CNT*BURST_LEN*DQ_WIDTH/8= 16*8*64/8=1024B //建议取512B~2KB //读延时最大为25CC
   parameter STATE_CNT_WIDTH         = 4,//6,
   parameter DATA_CNT_WIDTH          = 5,//7
	parameter APPDATA_WIDTH           = 256,	//128,
   parameter ADDR_PER_DMA_WIDTH      = 7

   )
  (
   input                                sys_rst,   // System reset
   input                                soft_rst,
   input                                clk_ref_p,     //differential iodelayctrl clk
   input                                clk_ref_n,
   input                                clk_sys_p,     //differential iodelayctrl clk
   input                                clk_sys_n,
   
   output wire                          clk_ddr3_o,

   input [CH_NUM-1:0]                   wr_ram_ready,
   input [APP_DATA_WIDTH-1:0]           wr_data,
   output                               wr_data_valid,
   output[CH_NUM-1:0]                   wr_ch_sel_o,

   input [CH_NUM-1:0]                   rd_ram_ready,
   output [APP_DATA_WIDTH-1:0]          rd_data,
   output                               rd_data_valid,
   output [CH_NUM-1:0]                  rd_ch_sel_o,
   output [ADDR_WIDTH-1 :0]		  		ddr2_buffer_o, //nbm
	
   inout  [DQ_WIDTH-1:0]                ddr3_dq,
   output [ROW_WIDTH-1:0]               ddr3_addr,
   output [BANK_WIDTH-1:0]              ddr3_ba,
   output                               ddr3_ras_n,
   output                               ddr3_cas_n,
   output                               ddr3_we_n,
   output                               ddr3_reset_n,
   output [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_cs_n,
   output [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_odt,
   output [CKE_WIDTH-1:0]               ddr3_cke,
   output [DM_WIDTH-1:0]                ddr3_dm,
   inout  [DQS_WIDTH-1:0]               ddr3_dqs_p,
   inout  [DQS_WIDTH-1:0]               ddr3_dqs_n,
   output [CK_WIDTH-1:0]                ddr3_ck_p,
   output [CK_WIDTH-1:0]                ddr3_ck_n,
   output                               phy_init_done,

   input  wire [7:0]                    ASYNC_OUT,
   output wire [511:0]                  TRIG,
   output wire [511:0]                  ddr3_ctrl_debug,
   output wire [255:0]                  ddr3_addr_dbg,
   input                                vio_ctr

   );

  localparam SYSCLK_PERIOD       = tCK * nCK_PER_CLK;//2500*2=5ns
//  localparam DATA_WIDTH          = 64;
//  localparam PAYLOAD_WIDTH       = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam APP_DATA_WIDTH      = PAYLOAD_WIDTH * 4;
  localparam APP_MASK_WIDTH      = APP_DATA_WIDTH / 8;

//  wire                                sys_rst;   // System reset
  wire                                clk_ref;
  wire                                mmcm_clk;
  wire                                iodelay_ctrl_rdy;

//  wire                                clk;
  wire                                clk_mem;
  wire                                clk_rd_base;
  wire                  uclk;
  wire                                pd_PSDONE;
  wire                                pd_PSEN;
  wire                                pd_PSINCDEC;
  wire  [(BM_CNT_WIDTH)-1:0]          bank_mach_next;
  wire                                ddr3_parity;
  wire                                app_rd_data_end;
  wire                                app_hi_pri;
  wire [APP_MASK_WIDTH-1:0]           app_wdf_mask;
  wire                                dfi_init_complete;
  wire [3:0]                          app_ecc_multiple_err_i;
  wire [ADDR_WIDTH-1:0]               app_addr;
  wire [2:0]                          app_cmd;
  wire                                app_en;
  wire                                app_rdy;
  wire [APP_DATA_WIDTH-1:0]           app_rd_data;
  wire                                app_rd_data_valid;
  wire [APP_DATA_WIDTH-1:0]           app_wdf_data;
  wire                                app_wdf_end;
  wire                                app_wdf_rdy;
  wire                                app_wdf_wren;

  wire [5*DQS_WIDTH-1:0]              dbg_cpt_first_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_second_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_tap_cnt;
  wire                                dbg_dec_cpt;
  wire                                dbg_dec_rd_dqs;
  wire                                dbg_dec_rd_fps;
  wire [5*DQS_WIDTH-1:0]              dbg_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_dqs_tap_cnt;
  wire                                dbg_inc_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_inc_dec_sel;
  wire                                dbg_inc_rd_dqs;
  wire                                dbg_inc_rd_fps;
  wire                                dbg_ocb_mon_off;
  wire                                dbg_pd_off;
  wire                                dbg_pd_maintain_off;
  wire                                dbg_pd_maintain_0_only;
  wire [4:0]                          dbg_rd_active_dly;
  wire [3*DQS_WIDTH-1:0]              dbg_rd_bitslip_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_rd_clkdly_cnt;
  wire [4*DQ_WIDTH-1:0]               dbg_rddata;
  wire [1:0]                          dbg_rdlvl_done;
  wire [1:0]                          dbg_rdlvl_err;
  wire [1:0]                          dbg_rdlvl_start;
  wire [DQS_WIDTH-1:0]                dbg_wl_dqs_inverted;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dqs_tap_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_wr_calib_clk_delay;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dq_tap_set;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dqs_tap_set;
  wire                                dbg_wr_tap_set_en;
  wire                                dbg_idel_up_all;
  wire                                dbg_idel_down_all;
  wire                                dbg_idel_up_cpt;
  wire                                dbg_idel_down_cpt;
  wire                                dbg_idel_up_rsync;
  wire                                dbg_idel_down_rsync;
  wire                                dbg_sel_all_idel_cpt;
  wire                                dbg_sel_all_idel_rsync;
  wire                                dbg_pd_inc_cpt;
  wire                                dbg_pd_dec_cpt;
  wire                                dbg_pd_inc_dqs;
  wire                                dbg_pd_dec_dqs;
  wire                                dbg_pd_disab_hyst;
  wire                                dbg_pd_disab_hyst_0;
  wire                                dbg_wrlvl_done;
  wire                                dbg_wrlvl_err;
  wire                                dbg_wrlvl_start;
  wire [4:0]                          dbg_tap_cnt_during_wrlvl;
  wire [19:0]                         dbg_rsync_tap_cnt;
  wire [255:0]                        dbg_phy_pd;
  wire [255:0]                        dbg_phy_read;
  wire [255:0]                        dbg_phy_rdlvl;
  wire [255:0]                        dbg_phy_top;
  wire [3:0]                          dbg_pd_msb_sel;
  wire [DQS_WIDTH-1:0]                dbg_rd_data_edge_detect;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_rsync;
  wire [DQS_CNT_WIDTH-1:0]            dbg_pd_byte_sel;

  wire                           clk400_ref;
  wire                           rstdiv0;
  wire                           wr_busy_n;
  wire  [CH_NUM-1:0]             wr_ch_sel_i;
  wire  [ADDR_WIDTH-1:0]         wr_addr;
  wire                           wr_addr_valid;

  wire                           rd_busy_n;
  wire   [CH_NUM-1:0]            rd_ch_sel_i;
  wire   [ADDR_WIDTH-1:0]        rd_addr;
  wire                           rd_addr_valid;

  wire                           rst0;
  reg  [ 15:0]                   cmd_cnt;
  reg                            wr_allow;
  reg                            rd_allow;
  reg                            error;
//  wire [ 255:0]                   ddr3_ctrl_debug;

  //***************************************************************************
  assign phy_init_done = dfi_init_complete;
  assign app_hi_pri    = 1'b0;
  assign app_wdf_mask  = {APP_MASK_WIDTH{1'b0}};
  assign clk_ddr3_o    = clk;
  assign rst0          = rstdiv0;
  
//  clk_gen clk_gen_u(
//  // Clock in ports
//  .CLK_IN1_P(clk_sys_p),//156.25
//  .CLK_IN1_N(clk_sys_n),
//  // Clock out ports
////  .CLK_OUT1(clk_ref),//125
//  .CLK_OUT1(clk400_ref),//125
//  // Status and control signals
//  .RESET(1'b0),
//  .LOCKED()
// );
     wire clk_ref_ibufg;
      IBUFGDS #
        (
         .DIFF_TERM ("TRUE"),
         .IBUF_LOW_PWR ("FALSE")         
         )
        clk_sys
          (
           .I  (clk_sys_p),
           .IB (clk_sys_n),
           .O  (clk_ref_ibufg)
           );     

  iodelay_ctrl #
    (
     .TCQ            (TCQ),
     .IODELAY_GRP    (IODELAY_GRP),
     .INPUT_CLK_TYPE (INPUT_CLK_TYPE),
     .RST_ACT_LOW    (RST_ACT_LOW)
     )
    u_iodelay_ctrl
      (
       .clk_ref_p        (clk_ref_p),
       .clk_ref_n        (clk_ref_n),
       .clk_ref          (clk_ref),
       .sys_rst          (sys_rst),
       .clk400_ref       (clk400_ref),//output
       .iodelay_ctrl_rdy (iodelay_ctrl_rdy)
       );

assign  mmcm_clk = clk400_ref;

  infrastructure #
    (
     .TCQ                (TCQ),
     .CLK_PERIOD         (SYSCLK_PERIOD),
     .nCK_PER_CLK        (nCK_PER_CLK),
     .MMCM_ADV_BANDWIDTH (MMCM_ADV_BANDWIDTH),
     .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
     .DIVCLK_DIVIDE      (DIVCLK_DIVIDE),
     .CLKOUT_DIVIDE      (CLKOUT_DIVIDE),
     .RST_ACT_LOW        (RST_ACT_LOW)
     )
    u_infrastructure
      (
       .clk_mem          (clk_mem),//output
       .clk              (clk),//output
       .clk_rd_base      (clk_rd_base),//output
       .uclk             (uclk),//output
       .rstdiv0          (rstdiv0),
       .mmcm_clk         (mmcm_clk),//input
       .sys_rst          (sys_rst ),//^ key_rst_n
       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),
       .PSDONE           (pd_PSDONE),
       .PSEN             (pd_PSEN),
       .PSINCDEC         (pd_PSINCDEC)
       );

  memc_ui_top #
  (
   .ADDR_CMD_MODE        (ADDR_CMD_MODE),
   .BANK_WIDTH           (BANK_WIDTH),
   .CK_WIDTH             (CK_WIDTH),
   .CKE_WIDTH            (CKE_WIDTH),
   .nCK_PER_CLK          (nCK_PER_CLK),
   .COL_WIDTH            (COL_WIDTH),
   .CS_WIDTH             (CS_WIDTH),
   .DM_WIDTH             (DM_WIDTH),
   .nCS_PER_RANK         (nCS_PER_RANK),
   .DEBUG_PORT           (DEBUG_PORT),
   .IODELAY_GRP          (IODELAY_GRP),
   .DQ_WIDTH             (DQ_WIDTH),
   .DQS_WIDTH            (DQS_WIDTH),
   .DQS_CNT_WIDTH        (DQS_CNT_WIDTH),
   .ORDERING             (ORDERING),
   .OUTPUT_DRV           (OUTPUT_DRV),
   .PHASE_DETECT         (PHASE_DETECT),
   .RANK_WIDTH           (RANK_WIDTH),
   .REFCLK_FREQ          (REFCLK_FREQ),
   .REG_CTRL             (REG_CTRL),
   .ROW_WIDTH            (ROW_WIDTH),
   .RTT_NOM              (RTT_NOM),
   .RTT_WR               (RTT_WR),
   .SIM_CAL_OPTION       (SIM_CAL_OPTION),
   .SIM_INIT_OPTION      (SIM_INIT_OPTION),
   .SIM_BYPASS_INIT_CAL  (SIM_BYPASS_INIT_CAL),
   .WRLVL                (WRLVL),
   .nDQS_COL0            (nDQS_COL0),
   .nDQS_COL1            (nDQS_COL1),
   .nDQS_COL2            (nDQS_COL2),
   .nDQS_COL3            (nDQS_COL3),
   .DQS_LOC_COL0         (DQS_LOC_COL0),
   .DQS_LOC_COL1         (DQS_LOC_COL1),
   .DQS_LOC_COL2         (DQS_LOC_COL2),
   .DQS_LOC_COL3         (DQS_LOC_COL3),
   .tPRDI                (tPRDI),
   .tREFI                (tREFI),
   .tZQI                 (tZQI),
   .BURST_MODE           (BURST_MODE),
   .BM_CNT_WIDTH         (BM_CNT_WIDTH),
   .tCK                  (tCK),
   .ADDR_WIDTH           (ADDR_WIDTH),
   .TCQ                  (TCQ),
   .ECC_TEST             (ECC_TEST),
   .PAYLOAD_WIDTH        (PAYLOAD_WIDTH)
   )
  u_memc_ui_top
  (
   .clk                      (clk),
   .clk_mem                  (clk_mem),
   .clk_rd_base              (clk_rd_base),
   .rst                      (rstdiv0),
   .ddr_addr                 (ddr3_addr),
   .ddr_ba                   (ddr3_ba),
   .ddr_cas_n                (ddr3_cas_n),
   .ddr_ck_n                 (ddr3_ck_n),
   .ddr_ck                   (ddr3_ck_p),
   .ddr_cke                  (ddr3_cke),
   .ddr_cs_n                 (ddr3_cs_n),
   .ddr_dm                   (ddr3_dm),
   .ddr_odt                  (ddr3_odt),
   .ddr_ras_n                (ddr3_ras_n),
   .ddr_reset_n              (ddr3_reset_n),
   .ddr_parity               (ddr3_parity),
   .ddr_we_n                 (ddr3_we_n),
   .ddr_dq                   (ddr3_dq),
   .ddr_dqs_n                (ddr3_dqs_n),
   .ddr_dqs                  (ddr3_dqs_p),
   .pd_PSEN                  (pd_PSEN),
   .pd_PSINCDEC              (pd_PSINCDEC),
   .pd_PSDONE                (pd_PSDONE),
   .dfi_init_complete        (dfi_init_complete),
   .bank_mach_next           (bank_mach_next),
   .app_ecc_multiple_err     (app_ecc_multiple_err_i),
   .app_rd_data              (app_rd_data),
   .app_rd_data_end          (app_rd_data_end),
   .app_rd_data_valid        (app_rd_data_valid),
   .app_rdy                  (app_rdy),
   .app_wdf_rdy              (app_wdf_rdy),
   .app_addr                 (app_addr),
   .app_cmd                  (app_cmd),
   .app_en                   (app_en),
   .app_hi_pri               (app_hi_pri),
   .app_sz                   (1'b1),
   .app_wdf_data             (app_wdf_data),
   .app_wdf_end              (app_wdf_end),
   .app_wdf_mask             (app_wdf_mask),
   .app_wdf_wren             (app_wdf_wren),

   .dbg_wr_dqs_tap_set       (dbg_wr_dqs_tap_set),
   .dbg_wr_dq_tap_set        (dbg_wr_dq_tap_set),
   .dbg_wr_tap_set_en        (dbg_wr_tap_set_en),
   .dbg_wrlvl_start          (dbg_wrlvl_start),
   .dbg_wrlvl_done           (dbg_wrlvl_done),
   .dbg_wrlvl_err            (dbg_wrlvl_err),
   .dbg_wl_dqs_inverted      (dbg_wl_dqs_inverted),
   .dbg_wr_calib_clk_delay   (dbg_wr_calib_clk_delay),
   .dbg_wl_odelay_dqs_tap_cnt(dbg_wl_odelay_dqs_tap_cnt),
   .dbg_wl_odelay_dq_tap_cnt (dbg_wl_odelay_dq_tap_cnt),
   .dbg_rdlvl_start          (dbg_rdlvl_start),
   .dbg_rdlvl_done           (dbg_rdlvl_done),
   .dbg_rdlvl_err            (dbg_rdlvl_err),
   .dbg_cpt_tap_cnt          (dbg_cpt_tap_cnt),
   .dbg_cpt_first_edge_cnt   (dbg_cpt_first_edge_cnt),
   .dbg_cpt_second_edge_cnt  (dbg_cpt_second_edge_cnt),
   .dbg_rd_bitslip_cnt       (dbg_rd_bitslip_cnt),
   .dbg_rd_clkdly_cnt        (dbg_rd_clkdly_cnt),
   .dbg_rd_active_dly        (dbg_rd_active_dly),
   .dbg_pd_off               (dbg_pd_off),
   .dbg_pd_maintain_off      (dbg_pd_maintain_off),
   .dbg_pd_maintain_0_only   (dbg_pd_maintain_0_only),
   .dbg_inc_cpt              (dbg_inc_cpt),
   .dbg_dec_cpt              (dbg_dec_cpt),
   .dbg_inc_rd_dqs           (dbg_inc_rd_dqs),
   .dbg_dec_rd_dqs           (dbg_dec_rd_dqs),
   .dbg_inc_dec_sel          (dbg_inc_dec_sel),
   .dbg_inc_rd_fps           (dbg_inc_rd_fps),
   .dbg_dec_rd_fps           (dbg_dec_rd_fps),
   .dbg_dqs_tap_cnt          (dbg_dqs_tap_cnt),
   .dbg_dq_tap_cnt           (dbg_dq_tap_cnt),
   .dbg_rddata               (dbg_rddata)
   );


ddr3_ctrl #
 (
   .BANK_WIDTH             (BANK_WIDTH),
   .COL_WIDTH              (COL_WIDTH),
   .DM_WIDTH               (DM_WIDTH),
   .DQ_WIDTH               (DQ_WIDTH),
   .ROW_WIDTH              (ROW_WIDTH),
   .BURST_LEN              (BURST_LEN),
   .APPDATA_WIDTH          (APP_DATA_WIDTH),
   .CS_WIDTH               (CS_WIDTH),
   .ADDR_WIDTH             (ADDR_WIDTH),
                           
   .CH_NUM                 (CH_NUM),
   .STATE_CNT              (STATE_CNT),
   .STATE_CNT_WIDTH        (STATE_CNT_WIDTH),
   .DATA_CNT_WIDTH         (DATA_CNT_WIDTH)
   )
u_ddr3_ctrl
(
   .rst0                 (rstdiv0|soft_rst),
   .clk0                 (clk),
   .app_rdy              (app_rdy),
   .app_wdf_rdy          (app_wdf_rdy),
   .phy_init_done        (dfi_init_complete),

   .app_rd_data_valid    (app_rd_data_valid),
   .app_rd_data_fifo_out (app_rd_data),

   .app_af_wren          (app_en),
   .app_af_cmd           (app_cmd),
   .app_af_addr          (app_addr),

   .app_wdf_wren         (app_wdf_wren),
   .app_wdf_data         (app_wdf_data),
   .app_wdf_mask_data    (app_wdf_mask),

   //DDR3
   .app_wdf_end          (app_wdf_end),

   .wr_ch_sel_i          (wr_ch_sel_i  ),//i   [CH_NUM-1:0]
   .wr_addr              (wr_addr      ),//i  [ADDR_WIDTH-1:0]
   .wr_addr_valid        (wr_addr_valid),//i
   .wr_busy_n            (wr_busy_n    ),//o
  
     //用户端口
   .wr_data              (wr_data      ),//i input  [APPDATA_WIDTH-1:0]
   .wr_data_valid        (wr_data_valid),//o
   .wr_ch_sel_o          (wr_ch_sel_o  ),//o output reg [CH_NUM-1:0]
   
   .rd_ch_sel_i          (rd_ch_sel_i  ),//i   input  [CH_NUM-1:0]
   .rd_addr              (rd_addr      ),//i  input  [ADDR_WIDTH-1:0]
   .rd_addr_valid        (rd_addr_valid),//i
   .rd_busy_n            (rd_busy_n    ),//o
       //用户端口
   .rd_data              (rd_data      ),//o output reg [APPDATA_WIDTH-1:0]
   .rd_data_valid        (rd_data_valid),//o
   .rd_ch_sel_o          (rd_ch_sel_o  ),//o output reg [CH_NUM-1:0]
   .ddr2_buffer_o        (ddr2_buffer_o),
   
   .ddr3_ctrl_debug      (ddr3_ctrl_debug        ),
   .vio_ctr              (vio_ctr)
   );

    ben_addr_ctrl #(
    .CH_NUM(CH_NUM),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ADDR_PER_DMA_WIDTH(ADDR_PER_DMA_WIDTH)
    )
  ddr_addr_ctr_u (
    .clk          (clk           ), //clk0
    .rst          (rstdiv0 |soft_rst      ), //|| rstrst0

    .wr_ram_ready (wr_ram_ready  ), //input
    .wr_ch_sel_i  (wr_ch_sel_i   ), //output
    .wr_addr      (wr_addr       ), //output
    .wr_addr_valid(wr_addr_valid ), //output
    .wr_busy_n    (wr_busy_n     ), //input

    .rd_ram_ready (rd_ram_ready  ), //input
    .rd_ch_sel_i  (rd_ch_sel_i   ), //output
    .rd_addr      (rd_addr       ), //output
    .rd_addr_valid(rd_addr_valid ), //output
    .rd_busy_n    (rd_busy_n     ), //input

    .ddr3_addr_dbg(ddr3_addr_dbg[255:0] )
  );


//  assign      wr_start_n     =  ASYNC_OUT[0];
//  assign      rd_start_n     =  ASYNC_OUT[1];
//  assign      key_rst_n      =  ASYNC_OUT[2];
//  assign      sys_rst        =  ASYNC_OUT[3];

  assign      TRIG[0]        =  wr_busy_n;
  assign      TRIG[1]        =  wr_addr_valid;
  assign      TRIG[32:2]     =  wr_addr;
  assign      TRIG[70:33]    =  wr_ch_sel_i;
  assign      TRIG[108:71]   =  wr_ch_sel_o;
  assign      TRIG[109]      =  wr_data_valid;
  assign      TRIG[237:110]  =  wr_data;
  assign      TRIG[238]      =  rd_busy_n;
  assign      TRIG[239]      =  rd_addr_valid;
  assign      TRIG[270:240]  =  rd_addr;
  assign      TRIG[308:271]  =  rd_ch_sel_i;
  assign      TRIG[346:309]  =  rd_ch_sel_o;
  assign      TRIG[347]      =  rd_data_valid;
  assign      TRIG[475:348]  =  rd_data;
  assign      TRIG[476]      =  rst0;
//  assign      TRIG[479:477]  =  wr_wait_cnt;
//  assign      TRIG[482:480]  =  rd_wait_cnt;
//  assign      TRIG[483]      =  wr_addr_flag;
//  assign      TRIG[484]      =  rd_addr_flag;
  assign      TRIG[485]      =  error;
  assign      TRIG[486]      =  phy_init_done;
  assign TRIG[487]=rstdiv0;


//  assign TRIG0[0] = dfi_init_complete;
//  assign TRIG0[1] = app_rd_data_end;
//  assign TRIG0[2] = app_rd_data_valid;
//  assign TRIG0[3] = app_rdy;
//  assign TRIG0[4] = app_wdf_rdy;
//  assign TRIG0[31:5] = app_addr;
//  assign TRIG0[34:32] = app_cmd;
//  assign TRIG0[35] = app_en;
//  assign TRIG0[36] = app_wdf_end;
//  assign TRIG0[37] = app_wdf_wren;
//  assign TRIG0[101:38] = app_wdf_data[63:0];
//  assign TRIG0[165:102] = app_rd_data[63:0];
//  assign TRIG0[166] = iodelay_ctrl_rdy;
//  assign TRIG0[167] = pd_PSDONE;
//  assign TRIG0[231:168] = debug[63:0];
//  assign TRIG0[232] = error;

  // If debug port is not enabled, then make certain control input
  // to Debug Port are disabled
  generate
    if (DEBUG_PORT == "OFF") begin: gen_dbg_tie_off
      assign dbg_wr_dqs_tap_set     = 'b0;
      assign dbg_wr_dq_tap_set      = 'b0;
      assign dbg_wr_tap_set_en      = 1'b0;
      assign dbg_pd_off             = 1'b0;
      assign dbg_pd_maintain_off    = 1'b0;
      assign dbg_pd_maintain_0_only = 1'b0;
      assign dbg_ocb_mon_off        = 1'b0;
      assign dbg_inc_cpt            = 1'b0;
      assign dbg_dec_cpt            = 1'b0;
      assign dbg_inc_rd_dqs         = 1'b0;
      assign dbg_dec_rd_dqs         = 1'b0;
      assign dbg_inc_dec_sel        = 'b0;
      assign dbg_inc_rd_fps         = 1'b0;
      assign dbg_pd_msb_sel         = 'b0 ;
      assign dbg_sel_idel_cpt       = 'b0 ;
      assign dbg_sel_idel_rsync     = 'b0 ;
      assign dbg_pd_byte_sel        = 'b0 ;
      assign dbg_dec_rd_fps         = 1'b0;
    end

  endgenerate

endmodule
