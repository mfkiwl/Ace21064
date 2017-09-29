//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : bpd.v
//  Author      : ejune@aureage.com
//                
//  Description :   
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
  input  wire                     flush,
  input  wire [63:0]              pc_f1_t_i,
  input  wire [63:0]              pc_f1_nt_i,
  input  wire                     pipe_ctrl_fetch_i,

  input  wire                     btb_brdir_f1_i,
  input  wire                     bpd_condbr_flag,

  input  wire [63:0]              bob_pc_r_i,
  input  wire [ 9:0]              bob_lochist_i,
  input  wire [11:0]              bob_bhr_r_i,
  input  wire                     bob_valid_r_i,

  input  wire                     bpd_condbr_i,
  input  wire                     bpd_rt_we_i,
  input  wire                     bpd_rt_update_i,
  input  wire                     bpd_rt_brdir_i,
  input  wire                     bpd_ch_we_i,
  input  wire                     bpd_ch_brdir_i,
  output wire                     bpd_final_pred_o,
  output wire                     bpd_ch_we_o,
  output wire                     bpd_ch_ud_o,
  output wire [11:0]              bpd_bhr_o,
  output wire                     bpd_override_o,
  output wire [63:0]              bpd_override_pc_o,
  output reg  [ 9:0]              bpd_bht_lochist_f1 


);



//  branch prediction stage0 instance
//  Description : tourament branch prediction first stage, contains:
//                local branch history table(bht) 1024x10bits 
//                choice predictor pht 4096x2bits 

  // internal vars
  wire [11:0]  pht_sp_index;
  wire [11:0]  pht_cm_index;
  wire [ 9:0]  bht_sp_index;
  wire [ 9:0]  bht_cm_index;
  wire         bht_cm_brdir;
  wire         bpd_ch_brdir;
  wire [ 9:0]  bht_loc_hist;

  assign  pht_sp_index = pc_f0_i[13:2];
  assign  pht_cm_index = bob_pc_r_i[13:2];
  assign  bht_sp_index = pc_f0_i[11:2];
  assign  bht_cm_index = bob_pc_r_i[11:2];

  assign  bht_cm_brdir  = bpd_rt_brdir_i & bpd_rt_we_i; 
  assign  bpd_ch_brdir  = bpd_rt_brdir_i ^ bpd_ch_brdir_i;
  assign  bpd_ch_update = bpd_ch_we_i    & bpd_rt_we_i;

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
    .pht_rd_index_i    (pht_sp_index),
    .pht_wt_index_i    (pht_cm_index),
    .pht_cm_brdir_i    (bpd_ch_brdir),
    .pht_cm_brdir_we_i (bpd_ch_update), // the update is non-speculative update
    .pht_br_pred_o     (pht_ch_brdir)
  );

  // branch history table for local branch prediction
  bht bht_inst(
    .clock             (clock),
    .reset_n           (reset_n),
    .bht_rd_index_i    (bht_sp_index),
    .bht_wt_index_i    (bht_cm_index),
    .bht_cm_brdir_i    (bht_cm_brdir),
    .bht_cm_brdir_se_i (bpd_rt_we_i),  // the update is non-speculative update
    .bht_br_hist_o     (bht_loc_hist)
  );
  // these are pipeline registers which separate one logical stage(fetch) into
  // two physical pipeline stages
  reg bpd_pht_choice_f1;
  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n) begin
      bpd_pht_choice_f1  <= 1'b0;
      bpd_bht_lochist_f1 <= 10'h0;
    end
    else if (pipe_ctrl_fetch_i) begin
      bpd_pht_choice_f1  <= pht_ch_brdir;
      bpd_bht_lochist_f1 <= bht_loc_hist;
    end
  end

  // internal vars
  wire                        local_pred;
  wire                        global_pred;
  reg [11:0]                  bhr;
  reg [11:0]                  gIndex;
  reg [11:0]                  ugIndex;

  // assign outputs
  assign bpd_override_o = (btb_brdir_f1_i ^ bpd_final_pred_o) & bpd_condbr_i;

  // see bottom of file for analysis of these signals
/* truth table for choice predictor update
        branch dir | 00001111
       global pred | 00110011
        local pred | 01010101
-------------------+----------
update choice pred | 01100110 (signal bpd_ch_we_o)
  update direction | x10xx01x (signal bpd_ch_ud_o)

1 = choose global predictor,
0 = choose local predictor

So, we update the choice predictor on (global_pred ^ local_pred) and the direction is (branch_dir ^ local_pred)
*/
  assign bpd_ch_we_o = global_pred ^ local_pred;
  assign bpd_ch_ud_o = local_pred;

  assign bpd_bhr_o = bhr;

  // global gshare
  pht #(
    .INDEX_SIZE        (4096 ),
    .SQRT_INDEX        (64   ),
    .LOG_INDEX         (12   ),
    .SATCNT_WIDTH      (2    ),
    .SATCNT_INIT       (2'b01))
  pht_inst1(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (gIndex),
    .pht_wt_index_i    (ugIndex),
    .pht_cm_brdir_we_i (bpd_rt_update_i),
    .pht_cm_brdir_i    (bpd_rt_brdir_i),
    .pht_br_pred_o     (global_pred)
  );
  // local2 predictor
  // choise pht
  pht #(
    .INDEX_SIZE        (1024  ),
    .SQRT_INDEX        (32   ),
    .LOG_INDEX         (10    ),
    .SATCNT_WIDTH      (3     ),
    .SATCNT_INIT       (3'b011))
  pht_inst2(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (bpd_bht_lochist_f1),
    .pht_wt_index_i    (bob_lochist_i),
    .pht_cm_brdir_we_i (bpd_rt_update_i),
    .pht_cm_brdir_i    (bpd_rt_brdir_i),
    .pht_br_pred_o     (local_pred)
  );

  assign bpd_final_pred_o  = bpd_pht_choice_f1 ? global_pred : local_pred;
  assign bpd_override_pc_o = bpd_final_pred_o ? pc_f1_t_i : pc_f1_nt_i;

  // generate read index
  assign gIndex = pc_f1_i[13:2] ^ bhr;

  // generate write index
  assign ugIndex = bob_pc_r_i[13:2] ^ bob_bhr_r_i;

  always @(posedge clock or posedge reset_n)
  begin
    if (!reset_n)
      bhr <= 12'b0;
    else
      if (bpd_rt_update_i == 1'b1 && flush)
        bhr <= { bob_bhr_r_i[10:0], bpd_rt_brdir_i };
      else if (flush)
        if ( bob_valid_r_i ) 
          bhr <= bob_bhr_r_i;
      else if (bpd_condbr_i == 1'b1)
        bhr <= { bhr[10:0], bpd_final_pred_o };
  end

endmodule
