//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : 
//  Author      : ejune@aureage.com
//                
//  Description : 
//                
//                
//                
//  Create Date : 2016-11-05
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module bpd1 (
  input wire                          clock,
  input wire                          reset_n,
  input wire                          flush,
  input wire                          bpd_chdir_i,
  input wire [ 9:0]                   bpd_lochist_i,
  input wire [63:0]                   pc_f1_i,
  input wire                          btb_brdir_i,
  input wire                          cond_br_i, // well, if it's not a conditional branch, these tables are worthless
  input wire                          bpd_rt_ud_i,
  input wire                          bpd_rt_brdir_i,
  input wire                          pdir_in,   // not used
  input wire [ 9:0]                   bob_lochist_i,
  input wire [63:0]                   bob_pc_r_i,
  input wire [11:0]                   bob_bhr_r_i,
  input wire                          bob_valid_r_i,
  // outputs
  output wire                         bpd_final_pred_o,
  output wire                         bpd_ch_we_o,
  output wire                         bpd_ch_ud_o,
  output wire [11:0]                  bpd_bhr_o,
  output wire                         bpd_override_o,
  output wire [63:0]                  bpd_override_pc_o
);

  // internal vars
  wire                        local_pred;
  wire                        global_pred;
  reg [11:0]                  bhr;
  reg [11:0]                  gIndex;
  reg [11:0]                  ugIndex;

  // assign outputs
  assign bpd_override_o = (btb_brdir_i ^ bpd_final_pred_o) & cond_br_i;




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
    .INDEXSIZE         (4096 ),
    .LOGINDEXSIZE      (12   ),
    .SATCNTWIDTH       (2    ),
    .SATCNTINIT        (2'b01))
  pht_inst1(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (gIndex),
    .pht_wt_index_i    (ugIndex),
    .pht_cm_brdir_we_i (bpd_rt_ud_i),
    .pht_cm_brdir_i    (bpd_rt_brdir_i),
    .pht_br_pred_o     (global_pred)
  );
  // local2 predictor
  pht #(
    .INDEXSIZE         (1024  ),
    .LOGINDEXSIZE      (10    ),
    .SATCNTWIDTH       (3     ),
    .SATCNTINIT        (3'b011))
  pht_inst2(
    .clock             (clock),
    .reset_n           (reset_n),
    .pht_rd_index_i    (bpd_lochist_i),
    .pht_wt_index_i    (bob_lochist_i),
    .pht_cm_brdir_we_i (bpd_rt_ud_i),
    .pht_cm_brdir_i    (bpd_rt_brdir_i),
    .pht_br_pred_o     (local_pred)
  );
  // figure out what the not-taken PC is
  always @ (*)
  begin
    case (btb_brpos_brdec2btb)
    3'b000: pc_f1_nt = pc_f1 + 64'h00;
    3'b001: pc_f1_nt = pc_f1 + 64'h04;
    3'b010: pc_f1_nt = pc_f1 + 64'h08;
    3'b011: pc_f1_nt = pc_f1 + 64'h0c;
    3'b100: pc_f1_nt = pc_f1 + 64'h10;
    3'b101: pc_f1_nt = pc_f1 + 64'h14;
    3'b110: pc_f1_nt = pc_f1 + 64'h18;
    3'b111: pc_f1_nt = pc_f1 + 64'h1c;
    endcase
  end
  // figure out what the taken PC is
  assign pc_f1_t = ((btb_brtyp_brdec2btb==`BR_INDIR_RAS)&br_exist) ? 
                    btb_br_tar_f1 : btb_brtar_brdec2btb;

  assign bpd_final_pred_o  = bpd_chdir_i ? global_pred : local_pred;
  assign bpd_override_pc_o = bpd_final_pred_o ? pc_f1_t : pc_f1_nt;

  // generate read index
  assign gIndex = pc_f1_i[13:2] ^ bhr;

  // generate write index
  assign ugIndex = bob_pc_r_i[13:2] ^ bob_bhr_r_i;

  always @(posedge clock or posedge reset_n)
  begin
    if (!reset_n)
      bhr = 'b0;
    else
      if (bpd_rt_ud_i == 1'b1 && flush)
        bhr <= { bob_bhr_r_i[10:0], bpd_rt_brdir_i };
      else if (flush)
        if ( bob_valid_r_i ) 
          bhr <= bob_bhr_r_i;
      else if (cond_br_i == 1'b1)
        bhr <= { bhr[10:0], bpd_final_pred_o };
  end

endmodule
