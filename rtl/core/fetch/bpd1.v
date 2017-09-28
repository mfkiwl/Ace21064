//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : 
//  Author      : ejune@aureage.com
//                
//  Description : tourament branch prediction first stage, contains local
//                branch history table(bht) 1024x10bits and choice predictor
//                pht 4096x2bits 
//                
//                
//                
//  Create Date : 2016-11-05
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module bpd1(
  input wire                     clock,
  input wire                     reset_n,
  input wire                     load_fetch_i,
  input wire                     bpd_ch_we_i,
  input wire                     bpd_ch_brdir_i,
  input wire                     bpd_rt_we_i,
  input wire                     bpd_rt_brdir_i,
  input wire [63:0]              sp_pc_i,           // speculated pc
  input wire [63:0]              cm_pc_i,           // non-speculative pc
  output reg                     bpd_pht_choice_f1,
  output reg [ 9:0]              bpd_bht_lochist_f1 
);
  localparam INDEXSIZE    = 4096;
  localparam LOGINDEXSIZE = 12;
  localparam SATCNTWIDTH  = 2;
  localparam SATCNTINIT   = 2'b10;

  // internal vars
  wire [11:0]  pht_sp_index;
  wire [11:0]  pht_cm_index;
  wire [ 9:0]  bht_sp_index;
  wire [ 9:0]  bht_cm_index;
  wire         bht_cm_brdir;
  wire         bpd_ch_brdir;
  wire [ 9:0]  bht_loc_hist;

  assign  pht_sp_index = sp_pc_i[13:2];
  assign  pht_cm_index = cm_pc_i[13:2];
  assign  bht_sp_index = sp_pc_i[11:2];
  assign  bht_cm_index = cm_pc_i[11:2];

  assign  bht_cm_brdir  = bpd_rt_brdir_i & bpd_rt_we_i; 
  assign  bpd_ch_brdir  = bpd_rt_brdir_i ^ bpd_ch_brdir_i;
  assign  bpd_ch_update = bpd_ch_we_i    & bpd_rt_we_i;

  // choice pht for the tourament branch predictor
  pht #(
    .INDEXSIZE         (4096 ),
    .LOGINDEXSIZE      (12   ),
    .SATCNTWIDTH       (2    ),
    .SATCNTINIT        (2'b10))
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
  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n) begin
      bpd_pht_choice_f1  <= 1'b0;
      bpd_bht_lochist_f1 <= 10'h0;
    end
    else if (load_fetch_i) begin
      bpd_pht_choice_f1  <= pht_ch_brdir;
      bpd_bht_lochist_f1 <= bht_loc_hist;
    end
  end

endmodule

