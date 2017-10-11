////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ace_rename.v
//  Author      : ejune@aureage.com
//                
//  Description : 
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module ace_rename(
    input     decode_inst0rs1_i,
    input     decode_inst1rs1_i,
    input     decode_inst2rs1_i,
    input     decode_inst3rs1_i,
    input     decode_inst0rs2_i,
    input     decode_inst1rs2_i,
    input     decode_inst2rs2_i,
    input     decode_inst3rs2_i,
    input     decode_inst0rd_i,
    input     decode_inst1rd_i,
    input     decode_inst2rd_i,
    input     decode_inst3rd_i,
    input     decode_inst0writeRd_i,
    input     decode_inst1writeRd_i,
    input     decode_inst2writeRd_i,
    input     decode_inst3writeRd_i,
    input     decode_inst0useRd_i,
    input     decode_inst1useRd_i,
    input     decode_inst2useRd_i,
    input     decode_inst3useRd_i,
    input     decode_inst0_memacc_i,
    input     decode_inst1_memacc_i,
    input     decode_inst2_memacc_i,
    input     decode_inst3_memacc_i,

    input [7:0] lfst_inv0_i;
    input [7:0] lfst_inv1_i;
    input flush_in;
    input clock,
    input reset_n,
    input Reset_in,
    input Stall_in,

    input [63:0] pc_r0_i,
    input [32*7-1:0] Retire_Mapping_in,
    input [(80-32)*7-1:0] RetireFreeList_in,
    input [6:0] FreedReg0_in,
    input [6:0] FreedReg1_in,
    input [6:0] FreedReg2_in,
    input [6:0] FreedReg3_in,
    input [6:0] FreedReg4_in,
    input [6:0] FreedReg5_in,
    input [6:0] FreedReg6_in,
    input [6:0] FreedReg7_in,
    input FreedValid0_in,
    input FreedValid1_in,
    input FreedValid2_in,
    input FreedValid3_in,
    input FreedValid4_in,
    input FreedValid5_in,
    input FreedValid6_in,
    input FreedValid7_in,
    input [6:0] rob_id0,
    input [6:0] rob_id1,
    input [6:0] rob_id2,
    input [6:0] rob_id3,
    input [11:0] update_ssit_index1_in,
    input [11:0] update_ssit_index2_in,
    input  update_ssid_v_in,
    output Cause_Stall_out
);

wire [6:0] free_reg0, free_reg1, free_reg2, free_reg3;
wire free_valid0, free_valid1, free_valid2, free_valid3;
wire [6:0] srcA0phys, srcB0phys, srcA1phys, srcB1phys, 
           srcA2phys, srcB2phys, srcA3phys, srcB3phys;

wire [1:0] srcA0sel_out, srcA1sel_out, srcA2sel_out, srcA3sel_out,
           srcB0sel_out, srcB1sel_out, srcB2sel_out, srcB3sel_out,
           dest0sel_out, dest1sel_out, dest2sel_out, dest3sel_out;

wire [6:0] old_dest0_out, old_dest1_out, old_dest2_out, old_dest3_out;

wire [`LFST_LOG_SIZE - 1:0] ssid0_out, ssid1_out, ssid2_out, ssid3_out;
wire ssid0_v_out, ssid1_v_out, ssid2_v_out, ssid3_v_out;
wire ssid1sel_out;
wire [1:0] ssid2sel_out, ssid3sel_out;

spec_rat i_spec_rat(
    .clock                       (clock), 
    .inst0_ars1_i,               (decode_inst0rs1_i),
    .inst1_ars1_i,               (decode_inst1rs1_i),
    .inst2_ars1_i,               (decode_inst2rs1_i),
    .inst3_ars1_i,               (decode_inst3rs1_i),
    .inst0_ars2_i                (decode_inst0rs2_i),
    .inst1_ars2_i                (decode_inst1rs2_i),
    .inst2_ars2_i                (decode_inst2rs2_i),
    .inst3_ars2_i                (decode_inst3rs2_i),
    .inst0_ard_i                 (decode_inst0rd_i),
    .inst1_ard_i                 (decode_inst1rd_i),
    .inst2_ard_i                 (decode_inst2rd_i),
    .inst3_ard_i                 (decode_inst3rd_i),
    .inst0_prd_i                 (free_reg0),
    .inst1_prd_i                 (free_reg1), 
    .inst2_prd_i                 (free_reg2), 
    .inst3_prd_i                 (free_reg3), 
    .inst0_rd_we_i               (free_valid0&&decode_inst0writeRd_i),
    .inst1_rd_we_i               (free_valid1&&decode_inst1writeRd_i),
    .inst2_rd_we_i               (free_valid2&&decode_inst2writeRd_i),
    .inst3_rd_we_i               (free_valid3&&decode_inst3writeRd_i),
    .arch_rat_rec_i              (Reset_in), 
    .arch_rat_rec_data_i         (Retire_Mapping_in), 
    .arch_stall_i                (Stall_in),
    .inst0_prs1_o                (srcA0phys), 
    .inst1_prs1_o                (srcA1phys), 
    .inst2_prs1_o                (srcA2phys), 
    .inst3_prs1_o                (srcA3phys), 
    .inst0_prs2_o                (srcB0phys), 
    .inst1_prs2_o                (srcB1phys), 
    .inst2_prs2_o                (srcB2phys), 
    .inst3_prs2_o                (srcB3phys),
    .inst0_ard_o                 (old_dest0_out), 
    .inst1_ard_o                 (old_dest1_out), 
    .inst2_ard_o                 (old_dest2_out), 
    .inst3_ard_o                 (old_dest3_out)
);



spec_rfl   i_spec_rfl(
    .clock                       (clock),
    .reset_n                     (reset_n),
    .arch_fl_rec_i               (Reset_in),
    .arch_fl_rec_data_i          (RetireFreeList_in),
    .inst0_rd_req_i              (decode_inst0useRd_i),
    .inst1_rd_req_i              (decode_inst1useRd_i),
    .inst2_rd_req_i              (decode_inst2useRd_i),
    .inst3_rd_req_i              (decode_inst3useRd_i),
    .retire0_rls_rd_i            (FreedReg0_in),
    .retire1_rls_rd_i            (FreedReg1_in),
    .retire2_rls_rd_i            (FreedReg2_in),
    .retire3_rls_rd_i            (FreedReg3_in),
    .retire4_rls_rd_i            (FreedReg4_in),
    .retire5_rls_rd_i            (FreedReg5_in),
    .retire6_rls_rd_i            (FreedReg6_in),
    .retire7_rls_rd_i            (FreedReg7_in),
    .retire0_rls_rd_vld_i        (FreedValid0_in),
    .retire1_rls_rd_vld_i        (FreedValid1_in),
    .retire2_rls_rd_vld_i        (FreedValid2_in),
    .retire3_rls_rd_vld_i        (FreedValid3_in),
    .retire4_rls_rd_vld_i        (FreedValid4_in),
    .retire5_rls_rd_vld_i        (FreedValid5_in),
    .retire6_rls_rd_vld_i        (FreedValid6_in),
    .retire7_rls_rd_vld_i        (FreedValid7_in),
    .arch_stall_i                (Stall_in),
    .spec_rfl_stall_o            (Cause_Stall_out),
    .inst0_freereg_o             (free_reg0),
    .inst1_freereg_o             (free_reg1),
    .inst2_freereg_o             (free_reg2),
    .inst3_freereg_o             (free_reg3),
    .inst0_freereg_vld_o         (free_valid0),
    .inst1_freereg_vld_o         (free_valid1),
    .inst2_freereg_vld_o         (free_valid2),
    .inst3_freereg_vld_o         (free_valid3)
);



dep_chk i_dep_chk(
    .inst0_ars1_i                (decode_inst0rs1_i),
    .inst1_ars1_i                (decode_inst1rs1_i),
    .inst2_ars1_i                (decode_inst2rs1_i),
    .inst3_ars1_i                (decode_inst3rs1_i),
    .inst0_ars2_i                (decode_inst0rs2_i),
    .inst1_ars2_i                (decode_inst1rs2_i),
    .inst2_ars2_i                (decode_inst2rs2_i),
    .inst3_ars2_i                (decode_inst3rs2_i),
    .inst0_ard_i                 (decode_inst0rd_i),
    .inst1_ard_i                 (decode_inst1rd_i),
    .inst2_ard_i                 (decode_inst2rd_i),
    .inst3_ard_i                 (decode_inst3rd_i), 
    .inst0_ard_vld_i             (decode_inst0writeRd_i),
    .inst1_ard_vld_i             (decode_inst1writeRd_i),
    .inst2_ard_vld_i             (decode_inst2writeRd_i),
    .inst3_ard_vld_i             (decode_inst3writeRd_i),
    .inst0_rs1_sel_o             (srcA0sel_out),
    .inst1_rs1_sel_o             (srcA1sel_out),
    .inst2_rs1_sel_o             (srcA2sel_out),
    .inst3_rs1_sel_o             (srcA3sel_out),
    .inst0_rs2_sel_o             (srcB0sel_out),
    .inst1_rs2_sel_o             (srcB1sel_out),
    .inst2_rs2_sel_o             (srcB2sel_out),
    .inst3_rs2_sel_o             (srcB3sel_out),
    .inst0_rd_sel_o              (dest0sel_out),
    .inst1_rd_sel_o              (dest1sel_out),
    .inst2_rd_sel_o              (dest2sel_out),
    .inst3_rd_sel_o              (dest3sel_out)
);

ssit i_ssit(
    .clock                       (clock),
    .reset_n                     (reset_n),
    .index0_in                   (pc_r0_i[13:2]),
    .index1_in                   (pc_r0_i[13:2]),
    .index2_in                   (pc_r0_i[13:2]),
    .index3_in                   (pc_r0_i[13:2]),
    .update_index1_in            (update_ssit_index1_in),
    .update_index2_in            (update_ssit_index2_in),
    .update_v_in                 (update_ssid_v_in),
    .ssid0_out                   (ssid0_out),
    .ssid1_out                   (ssid1_out),
    .ssid2_out                   (ssid2_out),
    .ssid3_out                   (ssid3_out),
    .valid0_out                  (ssid0_v_out),
    .valid1_out                  (ssid1_v_out),
    .valid2_out                  (ssid2_v_out),
    .valid3_out                  (ssid3_v_out),
);

dep_chk_ssit   i_dep_chk_ssit(
    .ssid0_i                 (ssid0_out),
    .ssid1_i                 (ssid1_out),
    .ssid2_i                 (ssid2_out),
    .ssid3_i                 (ssid3_out),
    .ssid0_vld_i             (ssid0_v_out),
    .ssid1_vld_i             (ssid1_v_out),
    .ssid2_vld_i             (ssid2_v_out),
    .ssid3_vld_i             (ssid3_v_out),
    .type0_i                 (decode_inst0memacc_i & ~decode_inst0writeRd_i),
    .type1_i                 (decode_inst1memacc_i & ~decode_inst0writeRd_i),
    .type2_i                 (decode_inst2memacc_i & ~decode_inst0writeRd_i),
    .ssid1sel_o              (ssid1sel_out),
    .ssid2sel_o              (ssid2sel_out),
    .ssid3sel_o              (ssid3sel_out),
);


// pipe registers between rename stage0 and rename stage1
//
always @ (posedge clock or negedge reset_n)
begin
    if(!reset_n)
    begin
        inst0_rdsel_r1     <= 'b0;
        inst1_rdsel_r1     <= 'b0;
        inst2_rdsel_r1     <= 'b0;
        inst3_rdsel_r1     <= 'b0;
        inst0_rs1sel_r1    <= 'b0;
        inst1_rs1sel_r1    <= 'b0;
        inst2_rs1sel_r1    <= 'b0;
        inst3_rs1sel_r1    <= 'b0;
        inst0_rs2sel_r1    <= 'b0;
        inst1_rs2sel_r1    <= 'b0;
        inst2_rs2sel_r1    <= 'b0;
        inst3_rs2sel_r1    <= 'b0;
        inst0_rs1phys_r1   <= 'b0;
        inst1_rs1phys_r1   <= 'b0;
        inst2_rs1phys_r1   <= 'b0;
        inst3_rs1phys_r1   <= 'b0;
        inst0_rs2phys_r1   <= 'b0;
        inst1_rs2phys_r1   <= 'b0;
        inst2_rs2phys_r1   <= 'b0;
        inst3_rs2phys_r1   <= 'b0;
        inst0_rdphys_r1    <= 'b0;
        inst1_rdphys_r1    <= 'b0;
        inst2_rdphys_r1    <= 'b0;
        inst3_rdphys_r1    <= 'b0;
        inst0_oldrdphys_r1 <= 'b0;
        inst1_oldrdphys_r1 <= 'b0;
        inst2_oldrdphys_r1 <= 'b0;
        inst3_oldrdphys_r1 <= 'b0;
        inst0_ssid_r1      <= 'b0;
        inst1_ssid_r1      <= 'b0;
        inst2_ssid_r1      <= 'b0;
        inst3_ssid_r1      <= 'b0;
        inst0_ssidvld_r1   <= 'b0;
        inst1_ssidvld_r1   <= 'b0;
        inst2_ssidvld_r1   <= 'b0;
        inst3_ssidvld_r1   <= 'b0;
        inst0_ssidsel_r1   <= 'b0;
        inst1_ssidsel_r1   <= 'b0;
        inst2_ssidsel_r1   <= 'b0;
        inst3_ssidsel_r1   <= 'b0;
    end
    else if(load)
    begin
        inst0_rdsel_r1     <= dest0sel_out;
        inst1_rdsel_r1     <= dest1sel_out;
        inst2_rdsel_r1     <= dest2sel_out;
        inst3_rdsel_r1     <= dest3sel_out;
        inst0_rs1sel_r1    <= srcA0sel_out;
        inst1_rs1sel_r1    <= srcA1sel_out;
        inst2_rs1sel_r1    <= srcA2sel_out;
        inst3_rs1sel_r1    <= srcA3sel_out;
        inst0_rs2sel_r1    <= srcB0sel_out;
        inst1_rs2sel_r1    <= srcB1sel_out;
        inst2_rs2sel_r1    <= srcB2sel_out;
        inst3_rs2sel_r1    <= srcB3sel_out;
        inst0_rs1phys_r1   <= srcA0phys;
        inst1_rs1phys_r1   <= srcA1phys;
        inst2_rs1phys_r1   <= srcA2phys;
        inst3_rs1phys_r1   <= srcA3phys;
        inst0_rs2phys_r1   <= srcB0phys;
        inst1_rs2phys_r1   <= srcB1phys;
        inst2_rs2phys_r1   <= srcB2phys;
        inst3_rs2phys_r1   <= srcB3phys;
        inst0_rdphys_r1    <= free_reg0;
        inst1_rdphys_r1    <= free_reg1;
        inst2_rdphys_r1    <= free_reg2;
        inst3_rdphys_r1    <= free_reg3;
        inst0_oldrdphys_r1 <= old_dest0_out;
        inst1_oldrdphys_r1 <= old_dest1_out;
        inst2_oldrdphys_r1 <= old_dest2_out;
        inst3_oldrdphys_r1 <= old_dest3_out;
        inst0_ssid_r1      <= ssid0_out;
        inst1_ssid_r1      <= ssid1_out;
        inst2_ssid_r1      <= ssid2_out;
        inst3_ssid_r1      <= ssid3_out;
        inst0_ssidvld_r1   <= ssid0_v_out;
        inst1_ssidvld_r1   <= ssid1_v_out;
        inst2_ssidvld_r1   <= ssid2_v_out;
        inst3_ssidvld_r1   <= ssid3_v_out;
        inst0_ssidsel_r1   <= 2'b0;
        inst1_ssidsel_r1   <= {1'b0, ssid1sel_out};
        inst2_ssidsel_r1   <= ssid2sel_out;
        inst3_ssidsel_r1   <= ssid3sel_out;
    end
end

always @ (posedge clock or negedge reset_n)
begin
    if(!reset_n)
    begin
        inst0_writeRd_r1 <= 'b0;
        inst1_writeRd_r1 <= 'b0;
        inst2_writeRd_r1 <= 'b0;
        inst3_writeRd_r1 <= 'b0;
        inst0_memacc_r1  <= 'b0;
        inst1_memacc_r1  <= 'b0;
        inst2_memacc_r1  <= 'b0;
        inst3_memacc_r1  <= 'b0;
    end
    else if(load)
    begin
        inst0_writeRd_r1 <= decode_inst0writeRd_i;
        inst1_writeRd_r1 <= decode_inst1writeRd_i;
        inst2_writeRd_r1 <= decode_inst2writeRd_i;
        inst3_writeRd_r1 <= decode_inst3writeRd_i;
        inst0_memacc_r1  <= decode_inst0_memacc_i;
        inst1_memacc_r1  <= decode_inst1_memacc_i;
        inst2_memacc_r1  <= decode_inst2_memacc_i;
        inst3_memacc_r1  <= decode_inst3_memacc_i;
    end
end
///
wire [6:0] srca0_out, srca1_out, srca2_out, srca3_out;
wire [6:0] srcb0_out, srcb1_out, srcb2_out, srcb3_out;
wire [6:0] old_dest0_out, old_dest1_out, old_dest2_out, old_dest3_out;
wire [6:0] lfs0_out, lfs1_out, lfs2_out, lfs3_out;
wire valid0_out, valid1_out, valid2_out, valid3_out;

wire [6:0] lfs0_sel, lfs1_sel, lfs2_sel, lfs3_sel;
wire lfs0_v, lfs1_v, lfs2_v, lfs3_v;

map  i_map_override(
    .inst0_rs1phys_i          (inst0_rs1phys_r1),
    .inst1_rs1phys_i          (inst1_rs1phys_r1),
    .inst2_rs1phys_i          (inst2_rs1phys_r1),
    .inst3_rs1phys_i          (inst3_rs1phys_r1),                 
    .inst0_rs2phys_i          (inst0_rs2phys_r1),
    .inst1_rs2phys_i          (inst1_rs2phys_r1),
    .inst2_rs2phys_i          (inst2_rs2phys_r1),
    .inst3_rs2phys_i          (inst3_rs2phys_r1),
    .inst0_rdphys_i           (inst0_rdphys_r1),
    .inst1_rdphys_i           (inst1_rdphys_r1),
    .inst2_rdphys_i           (inst2_rdphys_r1),
    .inst3_rdphys_i           (inst3_rdphys_r1),
    .inst0_oldrdphys_i        (inst0_oldrdphys_r1),
    .inst1_oldrdphys_i        (inst1_oldrdphys_r1),
    .inst2_oldrdphys_i        (inst2_oldrdphys_r1),
    .inst3_oldrdphys_i        (inst3_oldrdphys_r1),
    .inst0_rs1sel_i           (inst0_rs1sel_r1),
    .inst1_rs1sel_i           (inst1_rs1sel_r1),
    .inst2_rs1sel_i           (inst2_rs1sel_r1),
    .inst3_rs1sel_i           (inst3_rs1sel_r1),
    .inst0_rs2sel_i           (inst0_rs2sel_r1),
    .inst1_rs2sel_i           (inst1_rs2sel_r1),
    .inst2_rs2sel_i           (inst2_rs2sel_r1),
    .inst3_rs2sel_i           (inst3_rs2sel_r1),
    .inst0_rdsel_i            (inst0_rdsel_r1),
    .inst1_rdsel_i            (inst1_rdsel_r1),
    .inst2_rdsel_i            (inst2_rdsel_r1),
    .inst3_rdsel_i            (inst3_rdsel_r1),
    .inst0_rs1phys_o          (srca0_out),
    .inst1_rs1phys_o          (srca1_out),
    .inst2_rs1phys_o          (srca2_out),
    .inst3_rs1phys_o          (srca3_out),
    .inst0_rs2phys_o          (srcb0_out),
    .inst1_rs2phys_o          (srcb1_out),
    .inst2_rs2phys_o          (srcb2_out),
    .inst3_rs2phys_o          (srcb3_out),
    .inst0_rdphys_o           (old_dest0_out),
    .inst1_rdphys_o           (old_dest1_out),
    .inst2_rdphys_o           (old_dest2_out),
    .inst3_rdphys_o           (old_dest3_out)
);

lfst i_lfst(
    .clock                 (clock),
    .reset_n               (reset_n),
    .flush_in              (flush_in),
    .ssid0_in              (inst0_ssid_r1),
    .ssid1_in              (inst1_ssid_r1),
    .ssid2_in              (inst2_ssid_r1),
    .ssid3_in              (inst3_ssid_r1),
    .valid0_in             (inst0_ssidvld_r1),
    .valid1_in             (inst1_ssidvld_r1),
    .valid2_in             (inst2_ssidvld_r1),
    .valid3_in             (inst3_ssidvld_r1),
    // update the LFST entry with a new dest register if the
    // instruction is a store and it hit in the SSIT table the
    // previous cycle
    .update0_in            ({inst0_ssid_r1,inst0_rdphys_r1,(inst0_ssidvld_r1 && inst0_memacc_r1 && !inst0_writeRd_r1 ) }),
    .update1_in            ({inst1_ssid_r1,inst1_rdphys_r1,(inst1_ssidvld_r1 && inst1_memacc_r1 && !inst1_writeRd_r1 ) }),
    .update2_in            ({inst2_ssid_r1,inst2_rdphys_r1,(inst2_ssidvld_r1 && inst2_memacc_r1 && !inst2_writeRd_r1 ) }),
    .update3_in            ({inst3_ssid_r1,inst3_rdphys_r1,(inst3_ssidvld_r1 && inst3_memacc_r1 && !inst3_writeRd_r1 ) }),
    // invalidate the LSFT entry if the store is retiring               (and the
    // mapping is still its own)
    .invalidate0_in        (lfst_inv0_i),
    .invalidate1_in        (lfst_inv1_i),
    .lfs0_out              (lfs0_out),
    .lfs1_out              (lfs1_out),
    .lfs2_out              (lfs2_out),
    .lfs3_out              (lfs3_out),
    .valid0_out            (valid0_out),
    .valid1_out            (valid1_out),
    .valid2_out            (valid2_out),
    .valid3_out            (valid3_out)
);
// perform the override for intra instruction bundle dependencies for
// store set predictions
assign lfs0_sel = lfs0_out;

assign lfs1_sel = inst1_ssidsel_r1 ? lfs1_out : inst0_rdphys_r1;
assign lfs2_sel = inst2_ssidsel_r1[1] ? 
                 (inst2_ssidsel_r1[0] ? lfs3_out        : lfs2_out):
                 (inst2_ssidsel_r1[0] ? inst1_rdphys_r1 : inst0_rdphys_r1);
assign lfs3_sel = inst3_ssidsel_r1[1] ?
                 (inst3_ssidsel_r1[0] ? lfs3_out        : inst2_rdphys_r1):
                 (inst3_ssidsel_r1[0] ? inst1_rdphys_r1 : inst0_rdphys_r1);

// do the same thing for the valid bits.  if the same bundle isn't selected,
// then we know that a store in the same bundle is predicted to alias
assign lfs0_v = valid0_out;
assign lfs1_v = inst1_ssidsel_r1 ? valid1_out : 1'b1;
assign lfs2_v = inst2_ssidsel_r1[1] ? (inst2_ssidsel_r1[0] ? 1'b1 : valid2_out) : 1'b1;
assign lfs3_v = inst3_ssidsel_r1[1] ? (inst3_ssidsel_r1[0] ? valid3_out : 1'b1) : 1'b1;

// if a load is predicted to alias, place the aliasing store's destination
// register into the srca field to order them
assign inst0_rs1phys_r1_o = (inst0_memacc_r1 && inst0_writeRd_r1 && lfs0_v && inst0_ssidvld_r1 ) ?lfs0_sel : srca0_out;
assign inst1_rs1phys_r1_o = (inst1_memacc_r1 && inst1_writeRd_r1 && lfs1_v && inst1_ssidvld_r1 ) ?lfs1_sel : srca1_out;
assign inst2_rs1phys_r1_o = (inst2_memacc_r1 && inst2_writeRd_r1 && lfs2_v && inst2_ssidvld_r1 ) ?lfs2_sel : srca2_out;
assign inst3_rs1phys_r1_o = (inst3_memacc_r1 && inst3_writeRd_r1 && lfs3_v && inst3_ssidvld_r1 ) ?lfs3_sel : srca3_out;

assign inst0_rs2phys_r1_o = srcb0_out;
assign inst1_rs2phys_r1_o = srcb1_out;
assign inst2_rs2phys_r1_o = srcb2_out;
assign inst3_rs2phys_r1_o = srcb3_out;

// if the instruction doesn't write to its destination, when it
// retires, free the register it was given (stores)
assign inst0_oldrdphys_r1_o = !(inst0_memacc_r1 && !inst0_writeRd_r1) ? old_dest0_out : inst0_rdphys_r1;
assign inst1_oldrdphys_r1_o = !(inst1_memacc_r1 && !inst1_writeRd_r1) ? old_dest1_out : inst1_rdphys_r1;
assign inst2_oldrdphys_r1_o = !(inst2_memacc_r1 && !inst2_writeRd_r1) ? old_dest2_out : inst2_rdphys_r1;
assign inst3_oldrdphys_r1_o = !(inst3_memacc_r1 && !inst3_writeRd_r1) ? old_dest3_out : inst3_rdphys_r1;

endmodule

