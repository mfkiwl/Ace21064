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
    input wire        clock,
    input wire        reset_n,
    input wire [63:0] pc_r0_i,
    input wire [ 4:0] decode_inst0rs1_i,
    input wire [ 4:0] decode_inst1rs1_i,
    input wire [ 4:0] decode_inst2rs1_i,
    input wire [ 4:0] decode_inst3rs1_i,
    input wire [ 4:0] decode_inst0rs2_i,
    input wire [ 4:0] decode_inst1rs2_i,
    input wire [ 4:0] decode_inst2rs2_i,
    input wire [ 4:0] decode_inst3rs2_i,
    input wire [ 4:0] decode_inst0rd_i,
    input wire [ 4:0] decode_inst1rd_i,
    input wire [ 4:0] decode_inst2rd_i,
    input wire [ 4:0] decode_inst3rd_i,
    input wire        decode_inst0writeRd_i,
    input wire        decode_inst1writeRd_i,
    input wire        decode_inst2writeRd_i,
    input wire        decode_inst3writeRd_i,
    input wire        decode_inst0useRd_i,
    input wire        decode_inst1useRd_i,
    input wire        decode_inst2useRd_i,
    input wire        decode_inst3useRd_i,
    input wire        decode_inst0memacc_i,
    input wire        decode_inst1memacc_i,
    input wire        decode_inst2memacc_i,
    input wire        decode_inst3memacc_i,

    input wire [ 7:0] lfst_inv0_i,
    input wire [ 7:0] lfst_inv1_i,
    input wire        retire_flush_i,
    input wire        retire_flush_r_i,
    input wire        pipe_stall_i,

    input wire [223:0] retire_archrat_data_i, //32*7
    input wire [335:0] retire_archrfl_data_i, //(80-32)*7
    input wire [ 6:0] retire_freereg0_i,
    input wire [ 6:0] retire_freereg1_i,
    input wire [ 6:0] retire_freereg2_i,
    input wire [ 6:0] retire_freereg3_i,
    input wire [ 6:0] retire_freereg4_i,
    input wire [ 6:0] retire_freereg5_i,
    input wire [ 6:0] retire_freereg6_i,
    input wire [ 6:0] retire_freereg7_i,
    input wire        retire_freereg0_vld_i,
    input wire        retire_freereg1_vld_i,
    input wire        retire_freereg2_vld_i,
    input wire        retire_freereg3_vld_i,
    input wire        retire_freereg4_vld_i,
    input wire        retire_freereg5_vld_i,
    input wire        retire_freereg6_vld_i,
    input wire        retire_freereg7_vld_i,
    input wire [11:0] l1dcache_ssitidx1_i,
    input wire [11:0] l1dcache_ssitidx2_i,
    input wire        l1dcache_ssitwe_i,

    output wire        rename_specrfl_stall_o,
    output wire  [6:0] inst0_rs1phys_r1_o,
    output wire  [6:0] inst1_rs1phys_r1_o,
    output wire  [6:0] inst2_rs1phys_r1_o,
    output wire  [6:0] inst3_rs1phys_r1_o,
    output wire  [6:0] inst0_rs2phys_r1_o,
    output wire  [6:0] inst1_rs2phys_r1_o,
    output wire  [6:0] inst2_rs2phys_r1_o,
    output wire  [6:0] inst3_rs2phys_r1_o,
    output wire  [6:0] inst0_oldrdphys_r1_o,
    output wire  [6:0] inst1_oldrdphys_r1_o,
    output wire  [6:0] inst2_oldrdphys_r1_o,
    output wire  [6:0] inst3_oldrdphys_r1_o

);

    wire [6:0] specrfl_freereg0;
    wire [6:0] specrfl_freereg1;
    wire [6:0] specrfl_freereg2;
    wire [6:0] specrfl_freereg3;
    wire       specrfl_freereg0_vld;
    wire       specrfl_freereg1_vld;
    wire       specrfl_freereg2_vld;
    wire       specrfl_freereg3_vld;
    wire [6:0] specrat_inst0_rs1phys;
    wire [6:0] specrat_inst0_rs2phys;
    wire [6:0] specrat_inst1_rs1phys;
    wire [6:0] specrat_inst1_rs2phys;
    wire [6:0] specrat_inst2_rs1phys;
    wire [6:0] specrat_inst2_rs2phys;
    wire [6:0] specrat_inst3_rs1phys;
    wire [6:0] specrat_inst3_rs2phys;

    wire [1:0] depchk_inst0_rs1sel;
    wire [1:0] depchk_inst1_rs1sel;
    wire [1:0] depchk_inst2_rs1sel;
    wire [1:0] depchk_inst3_rs1sel;
    wire [1:0] depchk_inst0_rs2sel;
    wire [1:0] depchk_inst1_rs2sel;
    wire [1:0] depchk_inst2_rs2sel;
    wire [1:0] depchk_inst3_rs2sel;
    wire [1:0] depchk_inst0_rdsel;
    wire [1:0] depchk_inst1_rdsel;
    wire [1:0] depchk_inst2_rdsel;
    wire [1:0] depchk_inst3_rdsel;

wire [6:0] specrat_inst0_rdarch, specrat_inst1_rdarch, specrat_inst2_rdarch, specrat_inst3_rdarch;

wire [6:0] ssid0_out, ssid1_out, ssid2_out, ssid3_out;
wire ssid0_v_out, ssid1_v_out, ssid2_v_out, ssid3_v_out;
wire ssid1sel_out;
wire [1:0] ssid2sel_out, ssid3sel_out;

wire [6:0] map_inst0_rs1phys, map_inst1_rs1phys, map_inst2_rs1phys, map_inst3_rs1phys;
wire [6:0] map_inst0_rs2phys, map_inst1_rs2phys, map_inst2_rs2phys, map_inst3_rs2phys;
wire [6:0] lfs0_out, lfs1_out, lfs2_out, lfs3_out;
wire [6:0] map_inst0_rdphys, map_inst1_rdphys, map_inst2_rdphys, map_inst3_rdphys;
wire valid0_out, valid1_out, valid2_out, valid3_out;

wire [6:0] lfs0_sel, lfs1_sel, lfs2_sel, lfs3_sel;
wire lfs0_v, lfs1_v, lfs2_v, lfs3_v;
// pipe registers
reg  [1:0]     depchk_inst0rdsel_r1;
reg  [1:0]     depchk_inst1rdsel_r1;
reg  [1:0]     depchk_inst2rdsel_r1;
reg  [1:0]     depchk_inst3rdsel_r1;
reg  [1:0]     depchk_inst0rs1sel_r1;
reg  [1:0]     depchk_inst1rs1sel_r1;
reg  [1:0]     depchk_inst2rs1sel_r1;
reg  [1:0]     depchk_inst3rs1sel_r1;
reg  [1:0]     depchk_inst0rs2sel_r1;
reg  [1:0]     depchk_inst1rs2sel_r1;
reg  [1:0]     depchk_inst2rs2sel_r1;
reg  [1:0]     depchk_inst3rs2sel_r1;
reg  [6:0]     specrat_inst0rs1phys_r1;
reg  [6:0]     specrat_inst1rs1phys_r1;
reg  [6:0]     specrat_inst2rs1phys_r1;
reg  [6:0]     specrat_inst3rs1phys_r1;
reg  [6:0]     specrat_inst0rs2phys_r1;
reg  [6:0]     specrat_inst1rs2phys_r1;
reg  [6:0]     specrat_inst2rs2phys_r1;
reg  [6:0]     specrat_inst3rs2phys_r1;
reg  [6:0]     specrfl_inst0freereg_r1;
reg  [6:0]     specrfl_inst1freereg_r1;
reg  [6:0]     specrfl_inst2freereg_r1;
reg  [6:0]     specrfl_inst3freereg_r1;
reg  [6:0]     specrat_inst0rdarch_r1;
reg  [6:0]     specrat_inst1rdarch_r1;
reg  [6:0]     specrat_inst2rdarch_r1;
reg  [6:0]     specrat_inst3rdarch_r1;
reg  [6:0]     ssit_inst0ssid_r1;
reg  [6:0]     ssit_inst1ssid_r1;
reg  [6:0]     ssit_inst2ssid_r1;
reg  [6:0]     ssit_inst3ssid_r1;
reg            ssit_inst0ssidvld_r1;
reg            ssit_inst1ssidvld_r1;
reg            ssit_inst2ssidvld_r1;
reg            ssit_inst3ssidvld_r1;
reg  [1:0]     depchkssit_inst0ssidsel_r1;
reg  [1:0]     depchkssit_inst1ssidsel_r1;
reg  [1:0]     depchkssit_inst2ssidsel_r1;
reg  [1:0]     depchkssit_inst3ssidsel_r1;

reg            decode_inst0writeRd_r1;
reg            decode_inst1writeRd_r1;
reg            decode_inst2writeRd_r1;
reg            decode_inst3writeRd_r1;
reg            decode_inst0memAcc_r1;
reg            decode_inst1memAcc_r1;
reg            decode_inst2memAcc_r1;
reg            decode_inst3memAcc_r1;


spec_rat i_spec_rat(
    .clock                       (clock), 
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
    .inst0_prd_i                 (specrfl_freereg0),
    .inst1_prd_i                 (specrfl_freereg1), 
    .inst2_prd_i                 (specrfl_freereg2), 
    .inst3_prd_i                 (specrfl_freereg3), 
    .inst0_rd_we_i               (specrfl_freereg0_vld&&decode_inst0writeRd_i),
    .inst1_rd_we_i               (specrfl_freereg1_vld&&decode_inst1writeRd_i),
    .inst2_rd_we_i               (specrfl_freereg2_vld&&decode_inst2writeRd_i),
    .inst3_rd_we_i               (specrfl_freereg3_vld&&decode_inst3writeRd_i),
    .arch_rat_rec_i              (retire_flush_r_i), 
    .arch_rat_rec_data_i         (retire_archrat_data_i), 
    .arch_stall_i                (pipe_stall_i),
    .inst0_prs1_o                (specrat_inst0_rs1phys), 
    .inst1_prs1_o                (specrat_inst1_rs1phys), 
    .inst2_prs1_o                (specrat_inst2_rs1phys), 
    .inst3_prs1_o                (specrat_inst3_rs1phys), 
    .inst0_prs2_o                (specrat_inst0_rs2phys), 
    .inst1_prs2_o                (specrat_inst1_rs2phys), 
    .inst2_prs2_o                (specrat_inst2_rs2phys), 
    .inst3_prs2_o                (specrat_inst3_rs2phys),
    .inst0_ard_o                 (specrat_inst0_rdarch), 
    .inst1_ard_o                 (specrat_inst1_rdarch), 
    .inst2_ard_o                 (specrat_inst2_rdarch), 
    .inst3_ard_o                 (specrat_inst3_rdarch)
);



spec_rfl   i_spec_rfl(
    .clock                       (clock),
    .reset_n                     (reset_n),
    .arch_fl_rec_i               (retire_flush_r_i),
    .arch_fl_rec_data_i          (retire_archrfl_data_i),
    .inst0_rd_req_i              (decode_inst0useRd_i),
    .inst1_rd_req_i              (decode_inst1useRd_i),
    .inst2_rd_req_i              (decode_inst2useRd_i),
    .inst3_rd_req_i              (decode_inst3useRd_i),
    .retire0_rls_rd_i            (retire_freereg0_i),
    .retire1_rls_rd_i            (retire_freereg1_i),
    .retire2_rls_rd_i            (retire_freereg2_i),
    .retire3_rls_rd_i            (retire_freereg3_i),
    .retire4_rls_rd_i            (retire_freereg4_i),
    .retire5_rls_rd_i            (retire_freereg5_i),
    .retire6_rls_rd_i            (retire_freereg6_i),
    .retire7_rls_rd_i            (retire_freereg7_i),
    .retire0_rls_rd_vld_i        (retire_freereg0_vld_i),
    .retire1_rls_rd_vld_i        (retire_freereg1_vld_i),
    .retire2_rls_rd_vld_i        (retire_freereg2_vld_i),
    .retire3_rls_rd_vld_i        (retire_freereg3_vld_i),
    .retire4_rls_rd_vld_i        (retire_freereg4_vld_i),
    .retire5_rls_rd_vld_i        (retire_freereg5_vld_i),
    .retire6_rls_rd_vld_i        (retire_freereg6_vld_i),
    .retire7_rls_rd_vld_i        (retire_freereg7_vld_i),
    .arch_stall_i                (pipe_stall_i),
    .spec_rfl_stall_o            (rename_specrfl_stall_o),
    .inst0_freereg_o             (specrfl_freereg0),
    .inst1_freereg_o             (specrfl_freereg1),
    .inst2_freereg_o             (specrfl_freereg2),
    .inst3_freereg_o             (specrfl_freereg3),
    .inst0_freereg_vld_o         (specrfl_freereg0_vld),
    .inst1_freereg_vld_o         (specrfl_freereg1_vld),
    .inst2_freereg_vld_o         (specrfl_freereg2_vld),
    .inst3_freereg_vld_o         (specrfl_freereg3_vld)
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
    .inst0_rs1_sel_o             (depchk_inst0_rs1sel),
    .inst1_rs1_sel_o             (depchk_inst1_rs1sel),
    .inst2_rs1_sel_o             (depchk_inst2_rs1sel),
    .inst3_rs1_sel_o             (depchk_inst3_rs1sel),
    .inst0_rs2_sel_o             (depchk_inst0_rs2sel),
    .inst1_rs2_sel_o             (depchk_inst1_rs2sel),
    .inst2_rs2_sel_o             (depchk_inst2_rs2sel),
    .inst3_rs2_sel_o             (depchk_inst3_rs2sel),
    .inst0_rd_sel_o              (depchk_inst0_rdsel),
    .inst1_rd_sel_o              (depchk_inst1_rdsel),
    .inst2_rd_sel_o              (depchk_inst2_rdsel),
    .inst3_rd_sel_o              (depchk_inst3_rdsel)
);

ssit i_ssit(
    .clock                       (clock),
    .reset_n                     (reset_n),
    .index0_in                   (pc_r0_i[13:2]),
    .index1_in                   (pc_r0_i[13:2]),
    .index2_in                   (pc_r0_i[13:2]),
    .index3_in                   (pc_r0_i[13:2]),
    .update_index1_in            (l1dcache_ssitidx1_i),
    .update_index2_in            (l1dcache_ssitidx2_i),
    .update_v_in                 (l1dcache_ssitwe_i),
    .ssid0_out                   (ssid0_out),
    .ssid1_out                   (ssid1_out),
    .ssid2_out                   (ssid2_out),
    .ssid3_out                   (ssid3_out),
    .valid0_out                  (ssid0_v_out),
    .valid1_out                  (ssid1_v_out),
    .valid2_out                  (ssid2_v_out),
    .valid3_out                  (ssid3_v_out)
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
    .ssid3sel_o              (ssid3sel_out)
);


// pipe registers between rename stage0 and rename stage1
//
always @ (posedge clock or negedge reset_n)
begin
    if(!reset_n)
    begin
        depchk_inst0rdsel_r1      <= 2'b0;
        depchk_inst1rdsel_r1      <= 2'b0;
        depchk_inst2rdsel_r1      <= 2'b0;
        depchk_inst3rdsel_r1      <= 2'b0;
        depchk_inst0rs1sel_r1     <= 2'b0;
        depchk_inst1rs1sel_r1     <= 2'b0;
        depchk_inst2rs1sel_r1     <= 2'b0;
        depchk_inst3rs1sel_r1     <= 2'b0;
        depchk_inst0rs2sel_r1     <= 2'b0;
        depchk_inst1rs2sel_r1     <= 2'b0;
        depchk_inst2rs2sel_r1     <= 2'b0;
        depchk_inst3rs2sel_r1     <= 2'b0;
        specrat_inst0rs1phys_r1   <= 7'b0;
        specrat_inst1rs1phys_r1   <= 7'b0;
        specrat_inst2rs1phys_r1   <= 7'b0;
        specrat_inst3rs1phys_r1   <= 7'b0;
        specrat_inst0rs2phys_r1   <= 7'b0;
        specrat_inst1rs2phys_r1   <= 7'b0;
        specrat_inst2rs2phys_r1   <= 7'b0;
        specrat_inst3rs2phys_r1   <= 7'b0;
        specrfl_inst0freereg_r1   <= 7'b0;
        specrfl_inst1freereg_r1   <= 7'b0;
        specrfl_inst2freereg_r1   <= 7'b0;
        specrfl_inst3freereg_r1   <= 7'b0;
        specrat_inst0rdarch_r1    <= 7'b0;
        specrat_inst1rdarch_r1    <= 7'b0;
        specrat_inst2rdarch_r1    <= 7'b0;
        specrat_inst3rdarch_r1    <= 7'b0;
        ssit_inst0ssid_r1         <= 7'b0;
        ssit_inst1ssid_r1         <= 7'b0;
        ssit_inst2ssid_r1         <= 7'b0;
        ssit_inst3ssid_r1         <= 7'b0;
        ssit_inst0ssidvld_r1      <= 1'b0;
        ssit_inst1ssidvld_r1      <= 1'b0;
        ssit_inst2ssidvld_r1      <= 1'b0;
        ssit_inst3ssidvld_r1      <= 1'b0;
        depchkssit_inst0ssidsel_r1<= 2'b0;
        depchkssit_inst1ssidsel_r1<= 2'b0;
        depchkssit_inst2ssidsel_r1<= 2'b0;
        depchkssit_inst3ssidsel_r1<= 2'b0;
    end
    else if(load)
    begin
        depchk_inst0rdsel_r1      <= depchk_inst0_rdsel;
        depchk_inst1rdsel_r1      <= depchk_inst1_rdsel;
        depchk_inst2rdsel_r1      <= depchk_inst2_rdsel;
        depchk_inst3rdsel_r1      <= depchk_inst3_rdsel;
        depchk_inst0rs1sel_r1     <= depchk_inst0_rs1sel;
        depchk_inst1rs1sel_r1     <= depchk_inst1_rs1sel;
        depchk_inst2rs1sel_r1     <= depchk_inst2_rs1sel;
        depchk_inst3rs1sel_r1     <= depchk_inst3_rs1sel;
        depchk_inst0rs2sel_r1     <= depchk_inst0_rs2sel;
        depchk_inst1rs2sel_r1     <= depchk_inst1_rs2sel;
        depchk_inst2rs2sel_r1     <= depchk_inst2_rs2sel;
        depchk_inst3rs2sel_r1     <= depchk_inst3_rs2sel;
        specrat_inst0rs1phys_r1   <= specrat_inst0_rs1phys;
        specrat_inst1rs1phys_r1   <= specrat_inst1_rs1phys;
        specrat_inst2rs1phys_r1   <= specrat_inst2_rs1phys;
        specrat_inst3rs1phys_r1   <= specrat_inst3_rs1phys;
        specrat_inst0rs2phys_r1   <= specrat_inst0_rs2phys;
        specrat_inst1rs2phys_r1   <= specrat_inst1_rs2phys;
        specrat_inst2rs2phys_r1   <= specrat_inst2_rs2phys;
        specrat_inst3rs2phys_r1   <= specrat_inst3_rs2phys;
        specrfl_inst0freereg_r1   <= specrfl_freereg0;
        specrfl_inst1freereg_r1   <= specrfl_freereg1;
        specrfl_inst2freereg_r1   <= specrfl_freereg2;
        specrfl_inst3freereg_r1   <= specrfl_freereg3;
        specrat_inst0rdarch_r1    <= specrat_inst0_rdarch;
        specrat_inst1rdarch_r1    <= specrat_inst1_rdarch;
        specrat_inst2rdarch_r1    <= specrat_inst2_rdarch;
        specrat_inst3rdarch_r1    <= specrat_inst3_rdarch;
        ssit_inst0ssid_r1         <= ssid0_out;
        ssit_inst1ssid_r1         <= ssid1_out;
        ssit_inst2ssid_r1         <= ssid2_out;
        ssit_inst3ssid_r1         <= ssid3_out;
        ssit_inst0ssidvld_r1      <= ssid0_v_out;
        ssit_inst1ssidvld_r1      <= ssid1_v_out;
        ssit_inst2ssidvld_r1      <= ssid2_v_out;
        ssit_inst3ssidvld_r1      <= ssid3_v_out;
        depchkssit_inst0ssidsel_r1<= 2'b0;
        depchkssit_inst1ssidsel_r1<= {1'b0, ssid1sel_out};
        depchkssit_inst2ssidsel_r1<= ssid2sel_out;
        depchkssit_inst3ssidsel_r1<= ssid3sel_out;
    end
end

always @ (posedge clock or negedge reset_n)
begin
    if(!reset_n)
    begin
        decode_inst0writeRd_r1 <= 1'b0;
        decode_inst1writeRd_r1 <= 1'b0;
        decode_inst2writeRd_r1 <= 1'b0;
        decode_inst3writeRd_r1 <= 1'b0;
        decode_inst0memAcc_r1  <= 1'b0;
        decode_inst1memAcc_r1  <= 1'b0;
        decode_inst2memAcc_r1  <= 1'b0;
        decode_inst3memAcc_r1  <= 1'b0;
    end
    else if(load)
    begin
        decode_inst0writeRd_r1 <= decode_inst0writeRd_i;
        decode_inst1writeRd_r1 <= decode_inst1writeRd_i;
        decode_inst2writeRd_r1 <= decode_inst2writeRd_i;
        decode_inst3writeRd_r1 <= decode_inst3writeRd_i;
        decode_inst0memAcc_r1  <= decode_inst0memacc_i;
        decode_inst1memAcc_r1  <= decode_inst1memacc_i;
        decode_inst2memAcc_r1  <= decode_inst2memacc_i;
        decode_inst3memAcc_r1  <= decode_inst3memacc_i;
    end
end
///

map  i_map_override(
    .inst0_rs1phys_i          (specrat_inst0rs1phys_r1),
    .inst1_rs1phys_i          (specrat_inst1rs1phys_r1),
    .inst2_rs1phys_i          (specrat_inst2rs1phys_r1),
    .inst3_rs1phys_i          (specrat_inst3rs1phys_r1),                 
    .inst0_rs2phys_i          (specrat_inst0rs2phys_r1),
    .inst1_rs2phys_i          (specrat_inst1rs2phys_r1),
    .inst2_rs2phys_i          (specrat_inst2rs2phys_r1),
    .inst3_rs2phys_i          (specrat_inst3rs2phys_r1),
    .inst0_rdphys_i           (specrfl_inst0freereg_r1),
    .inst1_rdphys_i           (specrfl_inst1freereg_r1),
    .inst2_rdphys_i           (specrfl_inst2freereg_r1),
    .inst3_rdphys_i           (specrfl_inst3freereg_r1),
    .inst0_oldrdphys_i        (specrat_inst0rdarch_r1),
    .inst1_oldrdphys_i        (specrat_inst1rdarch_r1),
    .inst2_oldrdphys_i        (specrat_inst2rdarch_r1),
    .inst3_oldrdphys_i        (specrat_inst3rdarch_r1),
    .inst0_rs1sel_i           (depchk_inst0rs1sel_r1),
    .inst1_rs1sel_i           (depchk_inst1rs1sel_r1),
    .inst2_rs1sel_i           (depchk_inst2rs1sel_r1),
    .inst3_rs1sel_i           (depchk_inst3rs1sel_r1),
    .inst0_rs2sel_i           (depchk_inst0rs2sel_r1),
    .inst1_rs2sel_i           (depchk_inst1rs2sel_r1),
    .inst2_rs2sel_i           (depchk_inst2rs2sel_r1),
    .inst3_rs2sel_i           (depchk_inst3rs2sel_r1),
    .inst0_rdsel_i            (depchk_inst0rdsel_r1),
    .inst1_rdsel_i            (depchk_inst1rdsel_r1),
    .inst2_rdsel_i            (depchk_inst2rdsel_r1),
    .inst3_rdsel_i            (depchk_inst3rdsel_r1),
    .inst0_rs1phys_o          (map_inst0_rs1phys),
    .inst1_rs1phys_o          (map_inst1_rs1phys),
    .inst2_rs1phys_o          (map_inst2_rs1phys),
    .inst3_rs1phys_o          (map_inst3_rs1phys),
    .inst0_rs2phys_o          (map_inst0_rs2phys),
    .inst1_rs2phys_o          (map_inst1_rs2phys),
    .inst2_rs2phys_o          (map_inst2_rs2phys),
    .inst3_rs2phys_o          (map_inst3_rs2phys),
    .inst0_rdphys_o           (map_inst0_rdphys),
    .inst1_rdphys_o           (map_inst1_rdphys),
    .inst2_rdphys_o           (map_inst2_rdphys),
    .inst3_rdphys_o           (map_inst3_rdphys)
);

lfst i_lfst(
    .clock                 (clock),
    .reset_n               (reset_n),
    .flush_in              (retire_flush_i),
    .ssid0_in              (ssit_inst0ssid_r1),
    .ssid1_in              (ssit_inst1ssid_r1),
    .ssid2_in              (ssit_inst2ssid_r1),
    .ssid3_in              (ssit_inst3ssid_r1),
    .valid0_in             (ssit_inst0ssidvld_r1),
    .valid1_in             (ssit_inst1ssidvld_r1),
    .valid2_in             (ssit_inst2ssidvld_r1),
    .valid3_in             (ssit_inst3ssidvld_r1),
    // update the LFST entry with a new dest register if the
    // instruction is a store and it hit in the SSIT table the
    // previous cycle
    .update0_in            ({ssit_inst0ssid_r1,specrfl_inst0freereg_r1,(ssit_inst0ssidvld_r1 && decode_inst0memAcc_r1 && !decode_inst0writeRd_r1 ) }),
    .update1_in            ({ssit_inst1ssid_r1,specrfl_inst1freereg_r1,(ssit_inst1ssidvld_r1 && decode_inst1memAcc_r1 && !decode_inst1writeRd_r1 ) }),
    .update2_in            ({ssit_inst2ssid_r1,specrfl_inst2freereg_r1,(ssit_inst2ssidvld_r1 && decode_inst2memAcc_r1 && !decode_inst2writeRd_r1 ) }),
    .update3_in            ({ssit_inst3ssid_r1,specrfl_inst3freereg_r1,(ssit_inst3ssidvld_r1 && decode_inst3memAcc_r1 && !decode_inst3writeRd_r1 ) }),
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

assign lfs1_sel = depchkssit_inst1ssidsel_r1    ? lfs1_out                : specrfl_inst0freereg_r1;
assign lfs2_sel = depchkssit_inst2ssidsel_r1[1] ? 
                 (depchkssit_inst2ssidsel_r1[0] ? lfs3_out                : lfs2_out):
                 (depchkssit_inst2ssidsel_r1[0] ? specrfl_inst1freereg_r1 : specrfl_inst0freereg_r1);
assign lfs3_sel = depchkssit_inst3ssidsel_r1[1] ?
                 (depchkssit_inst3ssidsel_r1[0] ? lfs3_out                : specrfl_inst2freereg_r1):
                 (depchkssit_inst3ssidsel_r1[0] ? specrfl_inst1freereg_r1 : specrfl_inst0freereg_r1);

// do the same thing for the valid bits.  if the same bundle isn't selected,
// then we know that a store in the same bundle is predicted to alias
assign lfs0_v = valid0_out;
assign lfs1_v = depchkssit_inst1ssidsel_r1 ? valid1_out : 1'b1;
assign lfs2_v = depchkssit_inst2ssidsel_r1[1] ? (depchkssit_inst2ssidsel_r1[0] ? 1'b1 : valid2_out) : 1'b1;
assign lfs3_v = depchkssit_inst3ssidsel_r1[1] ? (depchkssit_inst3ssidsel_r1[0] ? valid3_out : 1'b1) : 1'b1;

// if a load is predicted to alias, place the aliasing store's destination
// register into the srca field to order them
assign inst0_rs1phys_r1_o = (decode_inst0memAcc_r1 && decode_inst0writeRd_r1 && lfs0_v && ssit_inst0ssidvld_r1 ) ? lfs0_sel : map_inst0_rs1phys;
assign inst1_rs1phys_r1_o = (decode_inst1memAcc_r1 && decode_inst1writeRd_r1 && lfs1_v && ssit_inst1ssidvld_r1 ) ? lfs1_sel : map_inst1_rs1phys;
assign inst2_rs1phys_r1_o = (decode_inst2memAcc_r1 && decode_inst2writeRd_r1 && lfs2_v && ssit_inst2ssidvld_r1 ) ? lfs2_sel : map_inst2_rs1phys;
assign inst3_rs1phys_r1_o = (decode_inst3memAcc_r1 && decode_inst3writeRd_r1 && lfs3_v && ssit_inst3ssidvld_r1 ) ? lfs3_sel : map_inst3_rs1phys;

assign inst0_rs2phys_r1_o = map_inst0_rs2phys;
assign inst1_rs2phys_r1_o = map_inst1_rs2phys;
assign inst2_rs2phys_r1_o = map_inst2_rs2phys;
assign inst3_rs2phys_r1_o = map_inst3_rs2phys;

// if the instruction doesn't write to its destination, when it
// retires, free the register it was given (stores)
assign inst0_oldrdphys_r1_o = !(decode_inst0memAcc_r1 && !decode_inst0writeRd_r1) ? map_inst0_rdphys : specrfl_inst0freereg_r1;
assign inst1_oldrdphys_r1_o = !(decode_inst1memAcc_r1 && !decode_inst1writeRd_r1) ? map_inst1_rdphys : specrfl_inst1freereg_r1;
assign inst2_oldrdphys_r1_o = !(decode_inst2memAcc_r1 && !decode_inst2writeRd_r1) ? map_inst2_rdphys : specrfl_inst2freereg_r1;
assign inst3_oldrdphys_r1_o = !(decode_inst3memAcc_r1 && !decode_inst3writeRd_r1) ? map_inst3_rdphys : specrfl_inst3freereg_r1;

endmodule

