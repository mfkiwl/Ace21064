//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : bpd.v
//  Author      : ejune@aureage.com
//                
//  Description : tourament branch prediction first stage, contains:
//                local branch history table(bht) 1024x10bits 
//                choice predictor pht 4096x2bits 
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module bpd(
  input  wire                     clock,
  input  wire                     reset_n,
  input  wire [63:0]              pc_f0_i,      
  input  wire [63:0]              pc_f1_i,
  input  wire                     pipctl_flush_rt_i,
  input  wire                     pipctl_fill_f1_i,
  // bhr shift enable
  input  wire                     brdec_brtyp_i,
  input  wire                     brdec_brext_i,
  input  wire                     fetch_instinvld_i,
  // from retire stage, which offers cert information about branch
  input  wire                     brcond_vld_rt_i,
  input  wire                     brindir_vld_rt_i,
  input  wire                     brdir_rt_i,

  input  wire [63:0]              bob_pc_r_i,       // from bob
  input  wire                     bob_valid_r_i,    // from bob

  input  wire [11:0]              bob_bhr_r_i,      // from bob
  input  wire [ 9:0]              bob_lochist_i,    // from bob
  input  wire                     bob_ch_we_i,      // from bob
  input  wire                     bob_ch_brdir_i,   // from bob

  output wire [11:0]              bpd_bhr_o,          // to bob global history
  output wire [ 9:0]              bpd_bht_o,          // to bob local history
  output wire                     bpd_ch_we_o,        // to bob
  output wire                     bpd_ch_brdir_o,     // to bob

  output wire                     bpd_final_pred_o

);



  wire [11:0]  pht_idx_spec;
  wire [11:0]  pht_idx_cert;
  wire [ 9:0]  bht_idx_spec;
  wire [ 9:0]  bht_idx_cert;
  wire         bht_brdir_cert;
  wire         bpd_ch_brdir;
  wire [ 9:0]  bht_loc_hist;
  wire         bpd_brdir_we_cert;
  wire         bpd_brdir_cert;
  wire         bpd_ch_we_cert;

  wire         local_pred;
  wire         global_pred;


  reg  [11:0]  bhr;
  reg  [11:0]  global_pht_rd_idx;
  reg  [11:0]  global_pht_wt_idx;
  reg  [ 9:0]  local_pht_rd_idx;
  reg  [ 9:0]  local_pht_wt_idx;

  reg  [ 9:0]  bht_lochist_f1;
  reg          pht_choice_f1;


  assign  pht_idx_spec = pc_f0_i[13:2];
  assign  pht_idx_cert = bob_pc_r_i[13:2];
  assign  bht_idx_spec = pc_f0_i[11:2];
  assign  bht_idx_cert = bob_pc_r_i[11:2];

  assign  bpd_brdir_we_cert = brcond_vld_rt_i | brindir_vld_rt_i;
  assign  bpd_brdir_cert    = brdir_rt_i;

  assign  bht_brdir_cert    = bpd_brdir_cert & bpd_brdir_we_cert; 
  assign  bpd_ch_brdir      = bpd_brdir_cert ^ bob_ch_brdir_i;
  assign  bpd_ch_we_cert    = bob_ch_we_i    & bpd_brdir_we_cert;

  // choice pht for the tourament branch predictor
  pht #(
    .INDEX_SIZE         (4096 ),
    .SQRT_INDEX         (64   ),
    .LOG_INDEX          (12   ),
    .SATCNT_WIDTH       (2    ),
    .SATCNT_INIT        (2'b10))
  pht_inst0(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (pht_idx_spec),
    .pht_wt_index_i    (pht_idx_cert),
    .pht_brdir_i       (bpd_ch_brdir),
    .pht_brdir_we_i    (bpd_ch_we_cert), // the update is non-speculative update
    .pht_br_pred_o     (pht_ch_brdir)
  );

  // branch history table for local branch prediction
  bht bht_inst(
    .clock             (clock),
    .reset_n           (reset_n),
    .bht_rd_index_i    (bht_idx_spec),
    .bht_wt_index_i    (bht_idx_cert),
    .bht_brdir_i       (bht_brdir_cert),
    .bht_brdir_se_i    (bpd_brdir_we_cert),  // the update is non-speculative update
    .bht_br_hist_o     (bht_loc_hist)
  );
  // these are pipeline registers which separate one logical stage(fetch) into
  // two physical pipeline stages
  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n) begin
      pht_choice_f1  <= 1'b0;
      bht_lochist_f1 <= 10'h0;
    end
    else if (pipctl_fill_f1_i) begin
      pht_choice_f1  <= pht_ch_brdir;
      bht_lochist_f1 <= bht_loc_hist;
    end
  end

  always @(posedge clock or posedge reset_n)
  begin
    if (!reset_n)
      bhr <= 12'b0;
    else
      if (bpd_brdir_we_cert == 1'b1 && pipctl_flush_rt_i)
        bhr <= { bob_bhr_r_i[10:0], bpd_brdir_cert };
      else if (pipctl_flush_rt_i)
        if ( bob_valid_r_i ) 
          bhr <= bob_bhr_r_i;
      else if ((brdec_brtyp_i== `BR_COND) & brdec_brext_i & (!fetch_instinvld_i))
        bhr <= { bhr[10:0], bpd_final_pred_o };
  end

  // global predictor 
  pht #(
    .INDEX_SIZE        (4096 ),
    .SQRT_INDEX        (64   ),
    .LOG_INDEX         (12   ),
    .SATCNT_WIDTH      (2    ),
    .SATCNT_INIT       (2'b01))
  pht_inst1(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (global_pht_rd_idx),
    .pht_wt_index_i    (global_pht_wt_idx),
    .pht_brdir_we_i    (bpd_brdir_we_cert),
    .pht_brdir_i       (bpd_brdir_cert),
    .pht_br_pred_o     (global_pred)
  );

  // local2 predictor
  pht #(
    .INDEX_SIZE        (1024  ),
    .SQRT_INDEX        (32   ),
    .LOG_INDEX         (10    ),
    .SATCNT_WIDTH      (3     ),
    .SATCNT_INIT       (3'b011))
  pht_inst2(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (local_pht_rd_idx),
    .pht_wt_index_i    (local_pht_wt_idx),
    .pht_brdir_we_i    (bpd_brdir_we_cert),
    .pht_brdir_i       (bpd_brdir_cert),
    .pht_br_pred_o     (local_pred)
  );

  assign global_pht_rd_idx = pc_f1_i[13:2] ^ bhr;
  assign global_pht_wt_idx = bob_pc_r_i[13:2] ^ bob_bhr_r_i;
  assign local_pht_rd_idx  = bht_lochist_f1; 
  assign local_pht_wt_idx  = bob_lochist_i; 

  assign bpd_final_pred_o  = pht_choice_f1 ? global_pred : local_pred;

/* 
 * truth table for choice predictor update
 *         branch dir | 00001111
 *        global pred | 00110011
 *         local pred | 01010101
 * -------------------+----------
 * update choice pred | 01100110 (signal bpd_ch_we_o)
 *   update direction | x10xx01x (signal bpd_ch_brdir_o)
 * 
 * 1 = choose global predictor,
 * 0 = choose local predictor
 * 
 * So, update the choice predictor on (global_pred ^ local_pred) 
 *            the direction is (branch_dir ^ local_pred)
 */
  assign bpd_ch_we_o = global_pred ^ local_pred;
  assign bpd_ch_brdir_o = local_pred;

  assign bpd_bhr_o = bhr;
  assign bpd_bht_o = bht_lochist_f1; 

endmodule
