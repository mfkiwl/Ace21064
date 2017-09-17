//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : tbpd.v
//  Author      : ejune@aureage.com
//                
//  Description : tourament branch predictor, which have two physical pipe stages
//                bpd0 and bpd1
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module tbpd(
  input wire                     clock,
  input wire                     reset_n,
  input wire                     flush_rt_i,
  input wire [ 63:0]             flush_pc_rt_i,
//  input wire                     override_f1_i,
  input wire                     stall_f1_i, //fixme pay more attention
  input wire [ 63:0]             pc_f0_i,              // from FETCH(-1)

  //from fetch stage2 for registers between f0 and f1
  input wire                     load_fetch_i,
  // from retire stage
  input                                    bpd_rt_condbr_val_i,   // valid bit for cond feedback
  input                                    bpd_rt_indirbr_val_i,  // indirect retired
  input                                    bpd_rt_brdir_i,        // executed direction for this branch


);

//////////////////////////////////////////////////
// bpd0 instance
//////////////////////////////////////////////////
  wire bpd_rt_we = bpd_rt_condbr_val_r|bpd_rt_indirbr_val_r; //predictor update write
  
  bpd0 bpd0_inst(
    .clock                  (clock),
    .reset_n                (reset_n),
    .load_fetch_i           (load_fetch_i),
    .bpd_rt_we_i            (bpd_rt_we),
    .bpd_rt_bridr_i         (bpd_rt_brdir_r),
    .bpd_ch_we_i            (bob_chwe_o_r),
    .bpd_ch_brdir_i         (bob_chdir_o_r),
    .sp_pc_i                (pc_f0_i),
    .cm_pc_i                (bob_pc_o_r),
    .bpd_pht_choice_f1      (bpd_pht_choice_f1),
    .bpd_bht_lochist_f1     (bpd_bht_lochist_f1)
  );


// pipeline registers between fetch stage0 and fetch stage1
always @ (posedge clock or negedge reset_n)
begin
  if (!reset_n) begin
    pc_f1            <= 64'b0;
    btb_br_tar_f1    <= 64'b0;
    btb_brdir_r      <=  1'b0;
    inst_valid_f1    <=  8'b0;
    ras_ptr_r        <=  4'b0; 
  end
  else if (load_fetch_i) begin
    pc_f1            <= pc_f0_i;
    btb_br_tar_f1    <= btb_br_tar_o;
    btb_brdir_r      <= btb_br_dir_o;
    inst_valid_f1    <= inst_valid_o;
    ras_ptr_r        <= ras_ptr_o;
  end
end


  assign f1_invalid = invalid_in | valid_override_in | bob_stall_o;

  assign stall_out = bob_stall_o;


  assign stackaccess_btbmiss = (ras_ctrl_brdec2x != 2'b00) && ~btb_brdir_r && ~f1_invalid;



  wire bpd_condbr_flag = (btb_brtyp_brdec2btb==`BR_COND)&br_exist&~f1_invalid;
  // tournament predictor
bpd1 bpd1_inst(
    .clock                 (clock),
    .reset_n               (reset_n),
    .pc_f1_i               (pc_f1),
    .flush                 (flush_rt_r),
    // from bpd stage0
    .bpd_chdir_i           (bpd_pht_choice_f1),
    .bpd_lochist_i         (bpd_bht_lochist_f1),

    .btb_brdir_i           (btb_brdir_r        ),
    .cond_br_i             (bpd_condbr_flag    ),
    .bpd_rt_ud_i           (bpd_rt_condbr_val_r),
    .bpd_rt_brdir_i        (bpd_rt_brdir_r     ),

    .pdir_in               (bob_brdir_o_r      ), //not used

    .bob_lochist_i         (bob_lochist_o_r    ),
    .bob_pc_r_i            (bob_pc_o_r         ),
    .bob_bhr_r_i           (bob_bhr_o_r        ),
    .bob_valid_r_i         (bob_valid_o_r      ),

    .bpd_final_pred_o      (brdir_bpd2bob      ),
    .bpd_ch_we_o           (ch_we_bpd2bob      ),
    .bpd_ch_ud_o           (ch_ud_bpd2bob      ),
    .bpd_bhr_o             (bpd1_bhr_bpd2bob   ),
    .bpd_override_o        (bpd_override       ),
    .bpd_override_pc_o     (bpd_override_pc    )
);



always @ (posedge clock or negedge reset_n)
begin
  if (!reset_n) begin
    bob_pc_o_r           <= 64'b0;
    bob_brdir_o_r        <=  1'b0;
    bob_chwe_o_r         <=  1'b0;
    bob_chdir_o_r        <=  1'b0;
    bob_valid_o_r        <=  1'b0;
    bob_lochist_o_r      <= 10'b0;
    bob_bhr_o_r          <= 12'b0;
    bob_rasptr_o_r       <=  4'b0;
    bpd_rt_condbr_val_r  <=  1'b0;
    bpd_rt_indirbr_val_r <=  1'b0;
    bpd_rt_brdir_r       <=  1'b0;
    flush_rt_r           <=  1'b0;
    flush_pc_rt_r        <= 64'b0;
  end
  else begin
    bob_pc_o_r           <= bob_pc_o;
    bob_brdir_o_r        <= bob_brdir_o;
    bob_chwe_o_r         <= bob_chwe_o;
    bob_chdir_o_r        <= bob_chdir_o;
    bob_valid_o_r        <= bob_valid_o;
    bob_lochist_o_r      <= bob_lochist_o;
    bob_bhr_o_r          <= bob_bhr_o;
    bob_rasptr_o_r       <= bob_rasptr_o;
    bpd_rt_condbr_val_r  <= bpd_rt_condbr_val_i;
    bpd_rt_indirbr_val_r <= bpd_rt_indirbr_val_i;
    bpd_rt_brdir_r       <= bpd_rt_brdir_i;
    flush_rt_r           <= flush_rt_i;
    flush_pc_rt_r        <= flush_pc_rt_i;
  end
end

  // figure out how many insts we're keeping
  assign inst_valid_tmp = br_exist ? inst_val_brdec : insns_valid_in;
  // generate override_pc_o
  wire [1:0] override_pc_sel;
  wire override_pc_sel = {stackaccess_btbmiss, 
                         (btb_brtyp_brdec2btb==`BR_UNCOND) && ~btb_brdir_r && ~f1_invalid},
  
  wire override_pc_o = override_pc_sel[1] ? pc_f1 : (override_pc_sel[0] ? pc_f1_t : bpd_override_pc); 


endmodule

