//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ace_fetch.v
//  Author      : ejune@aureage.com
//                
//  Description : ace21064 fetch unit which has two physical pipeline stages,  
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module ace_fetch(
  input wire                     clock,
  input wire                     reset_n,
  input wire [ 63:0]             pc_f0,      
  input wire [ 63:0]             pc_f1,
  // from icache for fatch1
  input wire [255:0]             inst_align_i,
  input wire                     icache_stall_i,
  // from instruction buffer (decode) 
  input wire                     instbuf_full_i,
  // from retire stage
  input wire                     flush_rt_i,
  input wire [ 63:0]             flush_pc_rt_i,
  input wire                     brcond_vld_rt_i,   // valid bit for cond feedback
  input wire                     brindir_vld_rt_i,  // indirect retired
  input wire                     brdir_rt_i,        // executed direction for this branch

  // pc in fetch stage1 for instruction alignment unit
  output wire [63:0]             override_pc_o,  // override from f1 stage for pc_gen
  output wire                    override_vld_o, // override from f1 stage for pc_gen
  output wire [63:0]             branch_pc_o,    // branch target pc from f0 stage

  output reg                     inst0_vld_d0_o,
  output reg                     inst1_vld_d0_o,
  output reg                     inst2_vld_d0_o,
  output reg                     inst3_vld_d0_o,
  output reg                     inst4_vld_d0_o,
  output reg                     inst5_vld_d0_o,
  output reg                     inst6_vld_d0_o,
  output reg                     inst7_vld_d0_o,
  output reg [31:0]              inst0_d0_o,
  output reg [31:0]              inst1_d0_o,
  output reg [31:0]              inst2_d0_o,
  output reg [31:0]              inst3_d0_o,
  output reg [31:0]              inst4_d0_o,
  output reg [31:0]              inst5_d0_o,
  output reg [31:0]              inst6_d0_o,
  output reg [31:0]              inst7_d0_o
//  output reg [63:0]              inst0_pc_f1_r,
//  output reg [63:0]              inst1_pc_f1_r,
//  output reg [63:0]              inst2_pc_f1_r,
//  output reg [63:0]              inst3_pc_f1_r,
//  output reg [63:0]              inst4_pc_f1_r,
//  output reg [63:0]              inst5_pc_f1_r,
//  output reg [63:0]              inst6_pc_f1_r,
//  output reg [63:0]              inst7_pc_f1_r
);

  wire                            btb_hit;
  wire [ 2:0]                     btb_br_pos;
  wire [ 1:0]                     btb_br_typ;
  wire [ 7:0]                     inst_valid;
  wire [ 1:0]                     btb_ras_ctl;

  wire                            ras_vld;
  wire [63:0]                     pc_ras;
  wire [63:0]                     bpd_override_pc;
  wire [ 7:0]                     inst_vld_tmp;
  wire [ 1:0]                     override_pc_sel;


  reg  [63:0]                     bob_pc_o_r;
  reg                             bob_brdir_o_r;
  reg                             bob_chwe_o_r;
  reg                             bob_chdir_o_r;
  reg                             bob_valid_o_r;
  reg  [ 9:0]                     bob_lochist_o_r;
  reg  [11:0]                     bob_bhr_o_r;
  reg  [ 3:0]                     bob_rasptr_o_r;
  reg                             brcond_vld_rt_r;
  reg                             brindir_vld_rt_r;
  reg                             brdir_rt_r;
  reg                             flush_rt_r;
  reg  [63:0]                     flush_pc_rt_r;
  reg                             override_vld_r;
// pipe registers
  reg  [63:0]                     btb_br_tar_f1;
  reg  [ 3:0]                     ras_ptr_f1;
  reg  [ 7:0]                     inst_vld_f1;
  reg                             btb_brdir_f1;
  reg                             icache_stall_f1;
  reg  [63:0]                     pc_f1_nt;
  wire [63:0]                     pc_f1_t;


//////////////////////////////////////////////////////////////////////////////////////////
// BTB instance
//////////////////////////////////////////////////////////////////////////////////////////
btb    btb_inst(
  .clock                  (clock),
  .reset_n                (reset_n),
  .pc_f0_i                (pc_f0),

  .btb_sp_we_i            (btb_we_brdec2btb    ),
  .btb_sp_brpos_i         (btb_brpos_brdec2btb ),
  .btb_sp_brtyp_i         (brtyp_brdec2x ),
  .btb_sp_brtar_i         (btb_brtar_brdec2btb ),
  .btb_sp_brpc_i          (pc_f1),
 
  .ras_ctrl_in            (ras_ctrl_brdec2x),

  .btb_rt_we_i            (bpd_rt_we),
  .btb_rt_brpc_i          (bob_pc_o_r),
  .btb_rt_brdir_i         (brdir_rt_r),

  .taken_addr_in          (flush_pc_rt_r),
  .btb_hit_o              (btb_hit),
  .btb_br_pos_o           (btb_br_pos),
  .btb_br_typ_o           (btb_br_typ),
  .btb_br_tar_o           (btb_br_tar_f0),
  .btb_ras_ctl_o          (btb_ras_ctl),
  .btb_br_dir_o           (btb_br_dir_f0)
);

//////////////////////////////////////////////////////////////////////////////////////////
// RAS instance
//////////////////////////////////////////////////////////////////////////////////////////
ras    ras_inst(
  .clock                  (clock),
  .reset_n                (reset_n),
//  .ras_flush_rt_i         (ras_flush),
  .flush_rt_i             (flush_rt_i),
  .invalid_f1_i           (inst_invld_f1),
  .ras_bob_valid_i        (bob_valid_o_r),

  .ras_data_i             (ras_data_brdec2ras),

  .icache_stall_i         (icache_stall_i),
  .btb_hit_i              (btb_hit),
  .btb_rasctl_i           (btb_ras_ctl),
//  .ras_we_f1_i            (ras_we),
  .ras_ptr_rt_i           (bob_rasptr_o_r    ),
//  .ras_override_f1_i      (ras_override    ),
  .bpd_override_i         (bpd1_override     ),
  .btb_brtyp_i            (brtyp_brdec2x     ),
  .btb_brdir_r_i          (btb_brdir_f1       ),

  .ras_data_o             (pc_ras),
  .ras_valid_o            (ras_vld         ),
  .ras_ptr_o              (ras_ptr_f0        )
);

//////////////////////////////////////////////////////////////////////////////////////////
// BPD0 instance
//////////////////////////////////////////////////////////////////////////////////////////
bpd0 bpd0_inst(
  .clock                  (clock),
  .reset_n                (reset_n),
  .load_fetch_i           (load_fetch),
  .bpd_rt_we_i            (bpd_rt_we),
  .bpd_rt_brdir_i         (brdir_rt_r),
  .bpd_ch_we_i            (bob_chwe_o_r),
  .bpd_ch_brdir_i         (bob_chdir_o_r),
  .sp_pc_i                (pc_f0),
  .cm_pc_i                (bob_pc_o_r),
  .bpd_pht_choice_f1      (bpd_pht_choice_f1),
  .bpd_bht_lochist_f1     (bpd_bht_lochist_f1)
);


// if we hit in the BTB and predict taken, then use the predicted taken address as the next PC
// if we miss in the BTB, go to the fall through address(+32).
// if we hit and predict not taken, redirect to the address after the branch
// if we hit and predict taken, redirect to the predicted taken address
wire [63:0] pc_btb;
assign pc_btb = btb_hit ? (btb_br_dir_f0 ? btb_br_tar_f0
                : (pc_f0 + (btb_br_pos << 2) + 4))
                :  pc_f0+32;
// figure out if we need to use the RAS
assign branch_pc_o =  (btb_br_typ==`BR_INDIR_RAS)&btb_hit&ras_vld ? pc_ras : pc_btb;

// if we hit in the BTB and predict taken or are using the RAS, invalidate the instructions after the branch
assign inst_valid =  btb_br_pos[2]  
                   ?(btb_br_pos[1] ? (btb_br_pos[0] ? 8'hff : 8'h7f):(btb_br_pos[0] ? 8'h3f : 8'h1f))
                   :(btb_br_pos[1] ? (btb_br_pos[0] ? 8'h0f : 8'h07):(btb_br_pos[0] ? 8'h03 : 8'h01));
// if we hit in the BTB, invalidate the rest of the instruction bundle and redirect fetch to the instruction after the branch
assign inst_vld_f0 = btb_hit ? inst_valid : 8'hff;

//////////////////////////////////////////////////////////////////////////////////////////
// pipeline registers between fetch stage0 and fetch stage1
//////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge reset_n)
begin
  if (!reset_n) begin
    btb_br_tar_f1    <= 64'b0;
    btb_brdir_f1     <=  1'b0;
    inst_vld_f1      <=  8'b0;
    ras_ptr_f1       <=  4'b0; 
    icache_stall_f1  <=  1'b0;
  end
  else if (load_fetch) begin
    btb_br_tar_f1    <= btb_br_tar_f0;
    btb_brdir_f1     <= btb_br_dir_f0;
    inst_vld_f1      <= inst_vld_f0;
    ras_ptr_f1       <= ras_ptr_f0;
    icache_stall_f1  <= icache_stall_i;
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// brdec instance
//////////////////////////////////////////////////////////////////////////////////////////
brdec brdec_inst(
  .pc_f1              (pc_f1               ),
  .inst0_i            (inst0_f1            ),
  .inst1_i            (inst1_f1            ),
  .inst2_i            (inst2_f1            ),
  .inst3_i            (inst3_f1            ),
  .inst4_i            (inst4_f1            ),
  .inst5_i            (inst5_f1            ),
  .inst6_i            (inst6_f1            ),
  .inst7_i            (inst7_f1            ),
  .valid_override_i   (inst_invld_f1       ), // debug: is override_vld can
  .ras_data_i         (pc_ras              ),
  .ras_data_o         (ras_data_brdec2ras  ),
  .ras_ctrl_o         (ras_ctrl_brdec2x    ),
  .br_exist_o         (br_exist            ),
  .btb_we_o           (btb_we_brdec2btb    ),
  .btb_br_pos_o       (btb_brpos_brdec2btb ),
  .btb_br_typ_o       (brtyp_brdec2x       ),
  .btb_br_tar_o       (btb_brtar_brdec2btb ),
  .inst_valid_o       (inst_vld_brdec[7:0] )
);

  assign inst_invld_f1 = ~load_fetch      | 
                          icache_stall_f1 |
                          flush_rt_i      |
                          flush_rt_r      |
                          override_vld_r  |
                          bob_stall_o     ;

  // update predictors and BTB
  wire bpd_rt_we = brcond_vld_rt_r || brindir_vld_rt_r; //predictor update write
  wire load_fetch = (~instbuf_full_i & ~bob_stall_o) | flush_rt_i;
  assign stackaccess_btbmiss = (ras_ctrl_brdec2x != 2'b00) && ~btb_brdir_f1 && ~inst_invld_f1;

  // figure out what the not-taken PC is
  always @ *
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
  assign pc_f1_t = ((brtyp_brdec2x==`BR_INDIR_RAS)&br_exist) ? 
                    btb_br_tar_f1 : btb_brtar_brdec2btb;


  wire bpd_condbr_flag = (brtyp_brdec2x==`BR_COND)&br_exist&~inst_invld_f1;
  // tournament predictor
  bpd1 bpd1_inst(
    .clock                 (clock),
    .reset_n               (reset_n),
    .pc_f1_i               (pc_f1),
    .flush                 (flush_rt_r),
    .bpd_chdir_i           (bpd_pht_choice_f1),
    .bpd_lochist_i         (bpd_bht_lochist_f1),
    .btb_brdir_i           (btb_brdir_f1),
    .cond_br_i             (bpd_condbr_flag),
    .pc_f1_nt_i            (pc_f1_nt),
    .pc_f1_t_i             (pc_f1_t),
    .bpd_rt_ud_i           (brcond_vld_rt_r),
    .bpd_rt_brdir_i        (brdir_rt_r),

    .pdir_in               (bob_brdir_o_r), //not used

    .bob_lochist_i         (bob_lochist_o_r),
    .bob_pc_r_i            (bob_pc_o_r),
    .bob_bhr_r_i           (bob_bhr_o_r),
    .bob_valid_r_i         (bob_valid_o_r),

    .bpd_final_pred_o      (brdir_bpd2bob),
    .bpd_ch_we_o           (ch_we_bpd2bob),
    .bpd_ch_ud_o           (ch_ud_bpd2bob),
    .bpd_bhr_o             (bpd1_bhr_bpd2bob),
    .bpd_override_o        (bpd1_override),
    .bpd_override_pc_o     (bpd_override_pc)
  );


  wire bob_re = brcond_vld_rt_i|brindir_vld_rt_i;

  wire bob_we = (brtyp_brdec2x==`BR_COND)|
                (brtyp_brdec2x==`BR_INDIR_RAS)|
                (brtyp_brdec2x==`BR_INDIR_PC)&
                 br_exist&~inst_invld_f1&~stackaccess_btbmiss;

  bob bob_inst(
    .clock                       (clock),
    .reset_n                     (reset_n),
    .flush                       (flush_rt_i),
    .bob_re_i                    (bob_re),
    .bob_we_i                    (bob_we),

    .pc_f1_i                     (pc_f1),
    .bob_brdir_i                 (brdir_bpd2bob),
    .bob_ch_we_i                 (ch_we_bpd2bob),
    .bob_ch_ud_i                 (ch_ud_bpd2bob),
    .bob_lochist_i               (bpd_bht_lochist_f1),
    .bob_bhr_i                   (bpd1_bhr_bpd2bob),
    .bob_rasptr_i                (ras_ptr_f1),

    .bob_pc_o                    (bob_pc_o),
    .bob_brdir_o                 (bob_brdir_o),
    .bob_ch_we_o                 (bob_chwe_o),
    .bob_ch_dir_o                (bob_chdir_o),
    .bob_lochist_o               (bob_lochist_o),
    .bob_bhr_o                   (bob_bhr_o),
    .bob_rasptr_o                (bob_rasptr_o),

    .bob_valid_o                 (bob_valid_o),
    .bob_stall_o                 (bob_stall_o)
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
      brcond_vld_rt_r      <=  1'b0;
      brindir_vld_rt_r     <=  1'b0;
      brdir_rt_r           <=  1'b0;
      flush_rt_r           <=  1'b0;
      flush_pc_rt_r        <= 64'b0;
      override_vld_r       <=  1'b0;
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
      brcond_vld_rt_r      <= brcond_vld_rt_i;
      brindir_vld_rt_r     <= brindir_vld_rt_i;
      brdir_rt_r           <= brdir_rt_i;
      flush_rt_r           <= flush_rt_i;
      flush_pc_rt_r        <= flush_pc_rt_i;
      override_vld_r       <= override_vld;
    end
  end

  // figure out how many insts we're keeping
  assign inst_vld_tmp = br_exist ? inst_vld_brdec : inst_vld_f1;
  // generate override_pc_o
  assign override_pc_sel = {stackaccess_btbmiss, 
                         (brtyp_brdec2x==`BR_UNCOND) && ~btb_brdir_f1 && ~inst_invld_f1};
  
  assign override_pc_o = override_pc_sel[1] ? pc_f1 : (override_pc_sel[0] ? pc_f1_t : bpd_override_pc); 

  assign override_vld = bpd1_override | ((brtyp_brdec2x == `BR_UNCOND) && ~btb_brdir_f1 && ~inst_invld_f1) |stackaccess_btbmiss;
  assign override_vld_o = override_vld;

//  inst_align align_inst(
//    .offset_i          (pc_f1[4:2]),
//    .select_i          (pc_f1[5]),
//    .even_fetch_i      (inst_fg0_i),
//    .odd_fetch_i       (inst_fg1_i),
//    .inst_aligned_o    (inst_aligned)
//  );

  wire [31:0] inst0_f1 = inst_align_i[ 31:  0];
  wire [31:0] inst1_f1 = inst_align_i[ 63: 32];
  wire [31:0] inst2_f1 = inst_align_i[ 95: 64];
  wire [31:0] inst3_f1 = inst_align_i[127: 96];
  wire [31:0] inst4_f1 = inst_align_i[159:128];
  wire [31:0] inst5_f1 = inst_align_i[191:160];
  wire [31:0] inst6_f1 = inst_align_i[223:192];
  wire [31:0] inst7_f1 = inst_align_i[255:224];

  wire inst0_vld_f1 = inst_vld_tmp[0] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst1_vld_f1 = inst_vld_tmp[1] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst2_vld_f1 = inst_vld_tmp[2] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst3_vld_f1 = inst_vld_tmp[3] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst4_vld_f1 = inst_vld_tmp[4] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst5_vld_f1 = inst_vld_tmp[5] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst6_vld_f1 = inst_vld_tmp[6] & ~inst_invld_f1 & ~stackaccess_btbmiss;
  wire inst7_vld_f1 = inst_vld_tmp[7] & ~inst_invld_f1 & ~stackaccess_btbmiss;

// pipeline registers between fetch stage1 and decode stage0 (instruction
// buffer)
always @ (posedge clock or negedge reset_n)
begin
  if (reset_n) begin
    inst0_vld_d0_o    <=  1'b0;
    inst1_vld_d0_o    <=  1'b0;
    inst2_vld_d0_o    <=  1'b0;
    inst3_vld_d0_o    <=  1'b0;
    inst4_vld_d0_o    <=  1'b0;
    inst5_vld_d0_o    <=  1'b0;
    inst6_vld_d0_o    <=  1'b0;
    inst7_vld_d0_o    <=  1'b0;
    inst0_d0_o        <= 32'h0;
    inst1_d0_o        <= 32'h0;
    inst2_d0_o        <= 32'h0;
    inst3_d0_o        <= 32'h0;
    inst4_d0_o        <= 32'h0;
    inst5_d0_o        <= 32'h0;
    inst6_d0_o        <= 32'h0;
    inst7_d0_o        <= 32'h0;
  end
  else if (load_fetch) begin
    inst0_vld_d0_o    <= inst0_vld_f1;
    inst1_vld_d0_o    <= inst1_vld_f1;
    inst2_vld_d0_o    <= inst2_vld_f1;
    inst3_vld_d0_o    <= inst3_vld_f1;
    inst4_vld_d0_o    <= inst4_vld_f1;
    inst5_vld_d0_o    <= inst5_vld_f1;
    inst6_vld_d0_o    <= inst6_vld_f1;
    inst7_vld_d0_o    <= inst7_vld_f1;
    inst0_d0_o     <= inst0_f1;
    inst1_d0_o     <= inst1_f1;
    inst2_d0_o     <= inst2_f1;
    inst3_d0_o     <= inst3_f1;
    inst4_d0_o     <= inst4_f1;
    inst5_d0_o     <= inst5_f1;
    inst6_d0_o     <= inst6_f1;
    inst7_d0_o     <= inst7_f1;
  end
end

endmodule

