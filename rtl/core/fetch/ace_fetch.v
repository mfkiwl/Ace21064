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

  output wire [63:0]             override_pc_f1_o,  // override from f1 stage for pc_gen
  output wire                    override_vld_f1_o, // override from f1 stage for pc_gen
  output wire [63:0]             nxt_pc_f0_o,       // branch target pc from f0 stage

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
);

  reg  [ 7:0]                     instvld_f0_tmp;
  reg  [ 7:0]                     instvld_f0;
  reg  [ 7:0]                     instvld_f1;
  wire [ 7:0]                     instvld_f1_tmp;

  wire                            btb_hit_f0;
  wire [ 2:0]                     btb_brpos_f0;
  wire [ 1:0]                     btb_brtyp_f0;
  wire [ 1:0]                     btb_rasctl_f0;
  wire [63:0]                     btb_data_f0;
  reg  [63:0]                     btb_br_tar_f1;
  reg                             btb_brdir_f1;

  wire                            ras_vld_f0;
  wire [63:0]                     ras_data_f0;

  wire                            bob_stall_f1;
  reg  [63:0]                     bob_brpc_f1r;
  reg                             bob_brdir_f1r;
  reg                             bob_chwe_f1r;
  reg                             bob_chbrdir_f1r;
  reg                             bob_valid_f1r;
  reg  [ 9:0]                     bob_bht_f1r;
  reg  [11:0]                     bob_bhr_f1r;
  reg  [ 3:0]                     bob_rasptr_f1r;

  reg                             brcond_vld_rt_r;
  reg                             brindir_vld_rt_r;
  reg                             brdir_rt_r;
  reg                             flush_rt_r;
  reg  [63:0]                     flush_pc_rt_r;

  wire                            pipctl_fill_f1;
  reg  [ 3:0]                     fetch_rasptr_f1;
  reg                             icache_stall_f1;
  reg  [63:0]                     pc_f1_nt;
  wire [63:0]                     pc_f1_t;
  wire                            ras_pop_f0;
  wire                            nxt_pc_f0_tmp;


// BTB instance
btb    btb_inst(
  .clock                  (clock),
  .reset_n                (reset_n),
  .pc_f0_i                (pc_f0),
  .pc_f1_i                (pc_f1),

  .brdec_brext_f1_i       (brdec_brext_f1),
  .brdec_brpos_f1_i       (brdec_brpos_f1),
  .brdec_brtyp_f1_i       (brdec_brtyp_f1),
  .brdec_brtar_f1_i       (brdec_brtar_f1),
  .brdec_rasctl_f1_i      (brdec_rasctl_f1),

  .brcond_vld_rt_i        (brcond_vld_rt_r ),
  .brindir_vld_rt_i       (brindir_vld_rt_r),
  .brdir_rt_i             (brdir_rt_r),
  .brtar_rt_i             (flush_pc_rt_r),
  .brpc_rt_i              (bob_brpc_f1r),

  .btb_hit_f0_o           (btb_hit_f0),
  .btb_brpos_f0_o         (btb_brpos_f0),
  .btb_brtyp_f0_o         (btb_brtyp_f0),
  .btb_brtar_f0_o         (btb_brtar_f0),
  .btb_brdir_f0_o         (btb_brdir_f0),
  .btb_rasctl_f0_o        (btb_rasctl_f0)
);

// RAS instance
ras    ras_inst(
  .clock                  (clock),
  .reset_n                (reset_n),
  .flush_rt_i             (flush_rt_i),
  .invalid_f1_i           (fetch_instinvld_f1),
  .icache_stall_i         (icache_stall_i),
  .bpd_override_i         (bpd_override     ),
  .brdec_brtyp_f1_i       (brdec_brtyp_f1 ),
  .brdec_rasdat_f1_i      (brdec_rasdat_f1),
  .btb_hit_f0_i           (btb_hit_f0),
  .btb_brdir_f1_i         (btb_brdir_f1      ), // attention
  .btb_rasctl_f0_i        (btb_rasctl_f0),
  .bob_rasptr_f1r_i       (bob_rasptr_f1r    ),
  .bob_vld_f1r_i          (bob_valid_f1r),
  .ras_data_f0_o          (ras_data_f0),
  .ras_vld_f0_o           (ras_vld_f0         ),
  .ras_ptr_f0_o           (ras_ptr_f0        )
);

// BPD instance
bpd bpd_inst(
  .clock                 (clock                 ),
  .reset_n               (reset_n               ),
  .pc_f0_i               (pc_f0                 ),
  .pc_f1_i               (pc_f1                 ),
  .pipctl_flush_rt_i     (flush_rt_r            ),
  .pipctl_fill_f1_i      (pipctl_fill_f1        ),

  .brdec_brtyp_i         (brdec_brtyp_f1        ),
  .brdec_brext_i         (brdec_brext_f1        ),
  .fetch_instinvld_i     (fetch_instinvld_f1    ),

  .brcond_vld_rt_i       (brcond_vld_rt_r       ),
  .brindir_vld_rt_i      (brindir_vld_rt_r      ),
  .brdir_rt_i            (brdir_rt_r            ),

  .bob_brpc_i            (bob_brpc_f1r          ),
  .bob_valid_i           (bob_valid_f1r         ),

  .bob_chwe_i            (bob_chwe_f1r          ),
  .bob_chbrdir_i         (bob_chbrdir_f1r       ),
  .bob_bhr_i             (bob_bhr_f1r           ),
  .bob_bht_i             (bob_bht_f1r           ),

  .bpd_chwe_o            (bpd_chwe_f1           ),
  .bpd_chbrdir_o         (bpd_chbrdir_f1        ),
  .bpd_bhr_o             (bpd_bhr_f1            ),
  .bpd_bht_o             (bpd_bht_f1            ),

  .bpd_final_pred_o      (bpd_pred_f1           )
);

// figure out current instruction is an xRET or not
assign ras_pop_f0  = (btb_brtyp_f0==`BR_INDIRRET) & btb_hit_f0 & ras_vld_f0;

// btb hit, predict taken, redirect to the predicted taken address
// btb hit, predict not-taken, redirect to the address after the branch
assign btb_data_f0 = btb_brdir_f0 ? btb_brtar_f0 : (pc_f0 + (btb_brpos_f0 << 2) + 4);

// miss in btb, go to the fall through address(pc_f0+32).
assign nxt_pc_f0_tmp   = btb_hit_f0 ? btb_data_f0 : pc_f0+32;

// ras_pop_f0 enabled, current instruction is an xRET, the next pc comes from RAS
assign nxt_pc_f0_o = ras_pop_f0 ? ras_data_f0 : nxt_pc_f0_tmp;

// btb hit, predict taken or using the RAS, invalidate the instructions after the branch
always @ *
begin
  case (btb_brpos_f0)
      3'b000 : instvld_f0_tmp = 8'h01; 
      3'b001 : instvld_f0_tmp = 8'h03; 
      3'b010 : instvld_f0_tmp = 8'h07; 
      3'b011 : instvld_f0_tmp = 8'h0f; 
      3'b100 : instvld_f0_tmp = 8'h1f; 
      3'b101 : instvld_f0_tmp = 8'h3f; 
      3'b110 : instvld_f0_tmp = 8'h7f; 
      3'b111 : instvld_f0_tmp = 8'hff; 
  endcase
end
assign instvld_f0 = btb_hit_f0 ? instvld_f0_tmp : 8'hff;

/* pipeline registers between fetch stage0 and fetch stage1 */
always @ (posedge clock or negedge reset_n)
begin
  if (!reset_n) begin
    btb_br_tar_f1    <= 64'b0;
    btb_brdir_f1     <=  1'b0;
    instvld_f1       <=  8'b0;
    fetch_rasptr_f1  <=  4'b0; 
    icache_stall_f1  <=  1'b0;
  end
  else if (pipctl_fill_f1) begin
    btb_br_tar_f1    <= btb_brtar_f0;
    btb_brdir_f1     <= btb_brdir_f0;
    instvld_f1       <= instvld_f0;
    fetch_rasptr_f1  <= ras_ptr_f0;
    icache_stall_f1  <= icache_stall_i;
  end
end

// brdec instance
brdec brdec_inst(
  .pc_f1_i            (pc_f1               ),
  .inst0_i            (inst0_f1            ),
  .inst1_i            (inst1_f1            ),
  .inst2_i            (inst2_f1            ),
  .inst3_i            (inst3_f1            ),
  .inst4_i            (inst4_f1            ),
  .inst5_i            (inst5_f1            ),
  .inst6_i            (inst6_f1            ),
  .inst7_i            (inst7_f1            ),
  .flush_vld_i        (fetch_instinvld_f1  ), // debug: is override_vld can
  .ras_pcdata_f0_i    (ras_data_f0         ),
  .brdec_rasdat_f1_o  (brdec_rasdat_f1     ),
  .brdec_rasctl_f1_o  (brdec_rasctl_f1     ),
  .brdec_brext_f1_o   (brdec_brext_f1      ),
  .brdec_brpos_f1_o   (brdec_brpos_f1      ),
  .brdec_brtyp_f1_o   (brdec_brtyp_f1      ),
  .brdec_brtar_f1_o   (brdec_brtar_f1      ),
  .brdec_instvld_f1_o (brdec_instvld_f1[7:0] )
);

bob bob_inst(
  .clock              (clock),
  .reset_n            (reset_n),
  .flush              (flush_rt_i),
  .pc_f1_i            (pc_f1),
  .brcond_vld_rt_i    (brcond_vld_rt_r ),
  .brindir_vld_rt_i   (brindir_vld_rt_r),
  .brdec_brtyp_i      (brdec_brtyp_f1),
  .brdec_brext_i      (brdec_brext_f1  ),
  .fetch_instinvld_i  (fetch_instinvld_f1),
  .fetch_btbmiss_i    (fetch_rasacc_btbmis),

  .bob_brdir_i        (bpd_pred_f1),
  .bob_chwe_i         (bpd_chwe_f1),
  .bob_chbrdir_i      (bpd_chbrdir_f1),
  .bob_bht_i          (bpd_bht_f1),
  .bob_bhr_i          (bpd_bhr_f1),
  .bob_rasptr_i       (fetch_rasptr_f1),

  .bob_brpc_o         (bob_brpc_f1),
  .bob_brdir_o        (bob_brdir_f1),
  .bob_chwe_o         (bob_chwe_f1),
  .bob_chbrdir_o      (bob_chdir_f1),
  .bob_bht_o          (bob_bht_f1),
  .bob_bhr_o          (bob_bhr_f1),
  .bob_rasptr_o       (bob_rasptr_f1),

  .bob_valid_o        (bob_valid_f1),
  .bob_stall_o        (bob_stall_f1)
);

/* pipeline registers between fetch stage0 and fetch stage1 */
  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n) begin
      bob_brpc_f1r        <= 64'b0;
      bob_brdir_f1r       <=  1'b0;
      bob_chwe_f1r        <=  1'b0;
      bob_chbrdir_f1r     <=  1'b0;
      bob_valid_f1r       <=  1'b0;
      bob_bht_f1r         <= 10'b0;
      bob_bhr_f1r         <= 12'b0;
      bob_rasptr_f1r      <=  4'b0;
      brcond_vld_rt_r     <=  1'b0;
      brindir_vld_rt_r    <=  1'b0;
      brdir_rt_r          <=  1'b0;
      flush_rt_r          <=  1'b0;
      flush_pc_rt_r       <= 64'b0;
    end
    else begin
      bob_brpc_f1r        <= bob_brpc_f1;
      bob_brdir_f1r       <= bob_brdir_f1;
      bob_chwe_f1r        <= bob_chwe_f1;
      bob_chbrdir_f1r     <= bob_chdir_f1;
      bob_valid_f1r       <= bob_valid_f1;
      bob_bht_f1r         <= bob_bht_f1;
      bob_bhr_f1r         <= bob_bhr_f1;
      bob_rasptr_f1r      <= bob_rasptr_f1;
      brcond_vld_rt_r     <= brcond_vld_rt_i;
      brindir_vld_rt_r    <= brindir_vld_rt_i;
      brdir_rt_r          <= brdir_rt_i;
      flush_rt_r          <= flush_rt_i;
      flush_pc_rt_r       <= flush_pc_rt_i;
    end
  end

  // figure out what the taken PC is
  assign pc_f1_t = ((brdec_brtyp_f1==`BR_INDIRRET) & brdec_brext_f1) ? btb_br_tar_f1 : brdec_brtar_f1;

  always @ *
  begin
    case (brdec_brpos_f1)
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
  // fetch stage pipeline enable control
  assign pipctl_fill_f1     = (~instbuf_full_i & ~bob_stall_f1) | flush_rt_i;
  assign fetch_instinvld_f1 = ~pipctl_fill_f1    | icache_stall_f1
                              |flush_rt_i        | flush_rt_r
                              |override_vld_f1_o | bob_stall_f1;

  assign fetch_rasacc_btbmis = (brdec_rasctl_f1 != 2'b00) & ~btb_brdir_f1 & ~fetch_instinvld_f1;

  assign br_uncond     = (brdec_brtyp_f1 == `BR_UNCOND) & ~btb_brdir_f1   & ~fetch_instinvld_f1;
  assign br_cond       = (brdec_brtyp_f1 == `BR_COND)   &  brdec_brext_f1 & ~fetch_instinvld_f1;
  assign override_pc_f1_o  = fetch_rasacc_btbmis ? pc_f1 : (br_uncond ? pc_f1_t : bpd_pred_f1 ? pc_f1_t : pc_f1_nt); 
  assign override_vld_f1_o = (bpd_pred_f1^btb_brdir_f1) & br_uncond | br_cond | fetch_rasacc_btbmis;


  // figure out how many insts we're keeping
  assign instvld_f1_tmp = brdec_brext_f1 ? brdec_instvld_f1 : instvld_f1;

  wire [31:0] inst0_f1 = inst_align_i[ 31:  0];
  wire [31:0] inst1_f1 = inst_align_i[ 63: 32];
  wire [31:0] inst2_f1 = inst_align_i[ 95: 64];
  wire [31:0] inst3_f1 = inst_align_i[127: 96];
  wire [31:0] inst4_f1 = inst_align_i[159:128];
  wire [31:0] inst5_f1 = inst_align_i[191:160];
  wire [31:0] inst6_f1 = inst_align_i[223:192];
  wire [31:0] inst7_f1 = inst_align_i[255:224];

  wire inst0_vld_f1 = instvld_f1_tmp[0] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst1_vld_f1 = instvld_f1_tmp[1] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst2_vld_f1 = instvld_f1_tmp[2] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst3_vld_f1 = instvld_f1_tmp[3] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst4_vld_f1 = instvld_f1_tmp[4] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst5_vld_f1 = instvld_f1_tmp[5] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst6_vld_f1 = instvld_f1_tmp[6] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;
  wire inst7_vld_f1 = instvld_f1_tmp[7] & ~fetch_instinvld_f1 & ~fetch_rasacc_btbmis;

/* pipeline registers between fetch stage1 and decode stage0 (instruction buffer) */
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
  else if (pipctl_fill_f1) begin
    inst0_vld_d0_o    <= inst0_vld_f1;
    inst1_vld_d0_o    <= inst1_vld_f1;
    inst2_vld_d0_o    <= inst2_vld_f1;
    inst3_vld_d0_o    <= inst3_vld_f1;
    inst4_vld_d0_o    <= inst4_vld_f1;
    inst5_vld_d0_o    <= inst5_vld_f1;
    inst6_vld_d0_o    <= inst6_vld_f1;
    inst7_vld_d0_o    <= inst7_vld_f1;
    inst0_d0_o        <= inst0_f1;
    inst1_d0_o        <= inst1_f1;
    inst2_d0_o        <= inst2_f1;
    inst3_d0_o        <= inst3_f1;
    inst4_d0_o        <= inst4_f1;
    inst5_d0_o        <= inst5_f1;
    inst6_d0_o        <= inst6_f1;
    inst7_d0_o        <= inst7_f1;
  end
end

endmodule

