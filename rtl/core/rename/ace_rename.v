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
    input wire        decode_inst0memory_i,
    input wire        decode_inst1memory_i,
    input wire        decode_inst2memory_i,
    input wire        decode_inst3memory_i,

    input wire        retire_lfst_invld0_i,
    input wire        retire_lfst_invld1_i,
    input wire [ 6:0] retire_lfst_invld_idx0_i,
    input wire [ 6:0] retire_lfst_invld_idx1_i,
    input wire        retire_flush_i,
    input wire        retire_flush_r_i,
    input wire        pipe_stall_i,
    input wire        pipe_load_rename_i,

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
    output wire  [6:0] rename_inst0rs1phys_i0_o,
    output wire  [6:0] rename_inst1rs1phys_i0_o,
    output wire  [6:0] rename_inst2rs1phys_i0_o,
    output wire  [6:0] rename_inst3rs1phys_i0_o,
    output wire  [6:0] rename_inst0rs2phys_i0_o,
    output wire  [6:0] rename_inst1rs2phys_i0_o,
    output wire  [6:0] rename_inst2rs2phys_i0_o,
    output wire  [6:0] rename_inst3rs2phys_i0_o,
    output wire  [6:0] rename_inst0rdphys_i0_o,
    output wire  [6:0] rename_inst1rdphys_i0_o,
    output wire  [6:0] rename_inst2rdphys_i0_o,
    output wire  [6:0] rename_inst3rdphys_i0_o

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

    wire [6:0] specrat_inst0_rdarch;
    wire [6:0] specrat_inst1_rdarch;
    wire [6:0] specrat_inst2_rdarch;
    wire [6:0] specrat_inst3_rdarch;
    
    wire [6:0] ssid0_out;
    wire [6:0] ssid1_out;
    wire [6:0] ssid2_out;
    wire [6:0] ssid3_out;
    wire       ssid0_v_out;
    wire       ssid1_v_out;
    wire       ssid2_v_out;
    wire       ssid3_v_out;
    wire       ssid1sel_out;
    wire [1:0] ssid2sel_out;
    wire [1:0] ssid3sel_out;
    
    wire [6:0] map_inst0_rs1phys;
    wire [6:0] map_inst1_rs1phys;
    wire [6:0] map_inst2_rs1phys;
    wire [6:0] map_inst3_rs1phys;
    wire [6:0] map_inst0_rs2phys;
    wire [6:0] map_inst1_rs2phys;
    wire [6:0] map_inst2_rs2phys;
    wire [6:0] map_inst3_rs2phys;
    wire [6:0] map_inst0_rdphys;
    wire [6:0] map_inst1_rdphys;
    wire [6:0] map_inst2_rdphys;
    wire [6:0] map_inst3_rdphys;

    wire [6:0] lfst_inst0lfs;
    wire [6:0] lfst_inst1lfs;
    wire [6:0] lfst_inst2lfs;
    wire [6:0] lfst_inst3lfs;
    wire       lfst_inst0lfsvld;
    wire       lfst_inst1lfsvld;
    wire       lfst_inst2lfsvld;
    wire       lfst_inst3lfsvld;
    
    wire [6:0] inst0_lfs;
    wire [6:0] inst1_lfs;
    wire [6:0] inst2_lfs;
    wire [6:0] inst3_lfs;
    wire       inst0_lfs_vld;
    wire       inst1_lfs_vld;
    wire       inst2_lfs_vld;
    wire       inst3_lfs_vld;
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
    
    reg            inst0_st_vld_r1;
    reg            inst1_st_vld_r1;
    reg            inst2_st_vld_r1;
    reg            inst3_st_vld_r1;
    reg            inst0_ld_vld_r1;
    reg            inst1_ld_vld_r1;
    reg            inst2_ld_vld_r1;
    reg            inst3_ld_vld_r1;

    wire inst0_st_vld = !decode_inst0writeRd_i & decode_inst0memory_i;
    wire inst1_st_vld = !decode_inst1writeRd_i & decode_inst1memory_i;
    wire inst2_st_vld = !decode_inst2writeRd_i & decode_inst2memory_i;
    wire inst3_st_vld = !decode_inst3writeRd_i & decode_inst3memory_i;
    wire inst0_ld_vld =  decode_inst0writeRd_i & decode_inst0memory_i;
    wire inst1_ld_vld =  decode_inst1writeRd_i & decode_inst1memory_i;
    wire inst2_ld_vld =  decode_inst2writeRd_i & decode_inst2memory_i;
    wire inst3_ld_vld =  decode_inst3writeRd_i & decode_inst3memory_i;

    wire [6:0] rename_inst0rs1phys_r1;
    wire [6:0] rename_inst1rs1phys_r1;
    wire [6:0] rename_inst2rs1phys_r1;
    wire [6:0] rename_inst3rs1phys_r1;
    wire [6:0] rename_inst0rs2phys_r1;
    wire [6:0] rename_inst1rs2phys_r1;
    wire [6:0] rename_inst2rs2phys_r1;
    wire [6:0] rename_inst3rs2phys_r1;
    wire [6:0] rename_inst0oldrdphys_r1;
    wire [6:0] rename_inst1oldrdphys_r1;
    wire [6:0] rename_inst2oldrdphys_r1;
    wire [6:0] rename_inst3oldrdphys_r1;



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
    .inst0_ssit_ridx_i           (pc_r0_i[13:2]),
    .inst1_ssit_ridx_i           (pc_r0_i[13:2]),
    .inst2_ssit_ridx_i           (pc_r0_i[13:2]),
    .inst3_ssit_ridx_i           (pc_r0_i[13:2]),
    .inst0_ssit_widx_i           (l1dcache_ssitidx1_i),
    .inst1_ssit_widx_i           (l1dcache_ssitidx2_i),
    .ssit_we_i                   (l1dcache_ssitwe_i),
    .inst0_ssid_o                (ssid0_out),
    .inst1_ssid_o                (ssid1_out),
    .inst2_ssid_o                (ssid2_out),
    .inst3_ssid_o                (ssid3_out),
    .inst0_ssid_vld_o            (ssid0_v_out),
    .inst1_ssid_vld_o            (ssid1_v_out),
    .inst2_ssid_vld_o            (ssid2_v_out),
    .inst3_ssid_vld_o            (ssid3_v_out)
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
    .type0_i                 (inst0_st_vld),
    .type1_i                 (inst1_st_vld),
    .type2_i                 (inst2_st_vld),
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
    else if(pipe_load_rename_i)
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
        inst0_st_vld_r1 <= 1'b0;
        inst1_st_vld_r1 <= 1'b0;
        inst2_st_vld_r1 <= 1'b0;
        inst3_st_vld_r1 <= 1'b0;
        inst0_ld_vld_r1 <= 1'b0;
        inst1_ld_vld_r1 <= 1'b0;
        inst2_ld_vld_r1 <= 1'b0;
        inst3_ld_vld_r1 <= 1'b0;
    end
    else if(pipe_load_rename_i)
    begin
        inst0_st_vld_r1 <= inst0_st_vld;
        inst1_st_vld_r1 <= inst1_st_vld;
        inst2_st_vld_r1 <= inst2_st_vld;
        inst3_st_vld_r1 <= inst3_st_vld;
        inst0_ld_vld_r1 <= inst0_ld_vld;
        inst1_ld_vld_r1 <= inst1_ld_vld;
        inst2_ld_vld_r1 <= inst2_ld_vld;
        inst3_ld_vld_r1 <= inst3_ld_vld;
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
    .flush_i               (retire_flush_i),
    .inst0_ssid_i          (ssit_inst0ssid_r1),
    .inst1_ssid_i          (ssit_inst1ssid_r1),
    .inst2_ssid_i          (ssit_inst2ssid_r1),
    .inst3_ssid_i          (ssit_inst3ssid_r1),
    .inst0_ssid_vld_i      (ssit_inst0ssidvld_r1),
    .inst1_ssid_vld_i      (ssit_inst1ssidvld_r1),
    .inst2_ssid_vld_i      (ssit_inst2ssidvld_r1),
    .inst3_ssid_vld_i      (ssit_inst3ssidvld_r1),
    // update the LFST entry with a new dest register if the
    // instruction is a store and it hits in the SSIT table
    .inst0_lfst_we_i            (ssit_inst0ssidvld_r1 & inst0_st_vld_r1),
    .inst1_lfst_we_i            (ssit_inst1ssidvld_r1 & inst1_st_vld_r1),
    .inst2_lfst_we_i            (ssit_inst2ssidvld_r1 & inst2_st_vld_r1),
    .inst3_lfst_we_i            (ssit_inst3ssidvld_r1 & inst3_st_vld_r1),
    .inst0_lfst_data_i          (specrfl_inst0freereg_r1),
    .inst1_lfst_data_i          (specrfl_inst1freereg_r1),
    .inst2_lfst_data_i          (specrfl_inst2freereg_r1),
    .inst3_lfst_data_i          (specrfl_inst3freereg_r1),
    .inst0_lfst_idx_i           (ssit_inst0ssid_r1),
    .inst1_lfst_idx_i           (ssit_inst1ssid_r1),
    .inst2_lfst_idx_i           (ssit_inst2ssid_r1),
    .inst3_lfst_idx_i           (ssit_inst3ssid_r1),
    // invalidate the LSFT entry if the store is retiring (and the mapping is still its own)
    .inst0_lfst_invld_i         (retire_lfst_invld0_i),
    .inst1_lfst_invld_i         (retire_lfst_invld1_i),
    .inst0_lfst_invld_idx_i     (retire_lfst_invld_idx0_i),
    .inst1_lfst_invld_idx_i     (retire_lfst_invld_idx1_i),
    .inst0_lfs_o                (lfst_inst0lfs),
    .inst1_lfs_o                (lfst_inst1lfs),
    .inst2_lfs_o                (lfst_inst2lfs),
    .inst3_lfs_o                (lfst_inst3lfs),
    .inst0_lfs_vld_o            (lfst_inst0lfsvld),
    .inst1_lfs_vld_o            (lfst_inst1lfsvld),
    .inst2_lfs_vld_o            (lfst_inst2lfsvld),
    .inst3_lfs_vld_o            (lfst_inst3lfsvld)
);
// perform the override for intra instruction bundle dependencies for
// store set predictions
assign inst0_lfs     = lfst_inst0lfs;
assign inst1_lfs     = depchkssit_inst1ssidsel_r1    ? lfst_inst1lfs           : specrfl_inst0freereg_r1;
assign inst2_lfs     = depchkssit_inst2ssidsel_r1[1] ? 
                      (depchkssit_inst2ssidsel_r1[0] ? lfst_inst3lfs           : lfst_inst2lfs):
                      (depchkssit_inst2ssidsel_r1[0] ? specrfl_inst1freereg_r1 : specrfl_inst0freereg_r1);
assign inst3_lfs     = depchkssit_inst3ssidsel_r1[1] ?
                      (depchkssit_inst3ssidsel_r1[0] ? lfst_inst3lfs           : specrfl_inst2freereg_r1):
                      (depchkssit_inst3ssidsel_r1[0] ? specrfl_inst1freereg_r1 : specrfl_inst0freereg_r1);

assign inst0_lfs_vld = lfst_inst0lfsvld;
assign inst1_lfs_vld = depchkssit_inst1ssidsel_r1 ? lfst_inst1lfsvld : 1'b1;
assign inst2_lfs_vld = depchkssit_inst2ssidsel_r1[1] ? (depchkssit_inst2ssidsel_r1[0] ? 1'b1 : lfst_inst2lfsvld) : 1'b1;
assign inst3_lfs_vld = depchkssit_inst3ssidsel_r1[1] ? (depchkssit_inst3ssidsel_r1[0] ? lfst_inst3lfsvld : 1'b1) : 1'b1;

// if a load is predicted to alias, place the aliasing store's destination
// register into the srca field to order them
assign rename_inst0rs1phys_r1 = (inst0_ld_vld_r1 && inst0_lfs_vld && ssit_inst0ssidvld_r1 ) ? inst0_lfs : map_inst0_rs1phys;
assign rename_inst1rs1phys_r1 = (inst1_ld_vld_r1 && inst1_lfs_vld && ssit_inst1ssidvld_r1 ) ? inst1_lfs : map_inst1_rs1phys;
assign rename_inst2rs1phys_r1 = (inst2_ld_vld_r1 && inst2_lfs_vld && ssit_inst2ssidvld_r1 ) ? inst2_lfs : map_inst2_rs1phys;
assign rename_inst3rs1phys_r1 = (inst3_ld_vld_r1 && inst3_lfs_vld && ssit_inst3ssidvld_r1 ) ? inst3_lfs : map_inst3_rs1phys;

assign rename_inst0rs2phys_r1 = map_inst0_rs2phys;
assign rename_inst1rs2phys_r1 = map_inst1_rs2phys;
assign rename_inst2rs2phys_r1 = map_inst2_rs2phys;
assign rename_inst3rs2phys_r1 = map_inst3_rs2phys;

// if the instruction doesn't write to its destination, when it
// retires, free the register it was given (stores)
assign rename_inst0oldrdphys_r1 = inst0_st_vld_r1 ? specrfl_inst0freereg_r1 : map_inst0_rdphys;
assign rename_inst1oldrdphys_r1 = inst1_st_vld_r1 ? specrfl_inst1freereg_r1 : map_inst1_rdphys;
assign rename_inst2oldrdphys_r1 = inst2_st_vld_r1 ? specrfl_inst2freereg_r1 : map_inst2_rdphys;
assign rename_inst3oldrdphys_r1 = inst3_st_vld_r1 ? specrfl_inst3freereg_r1 : map_inst3_rdphys;

// pipe stage registers
always @ (posedge clock or negedge reset_n)
begin
    if(!reset_n)
    begin
        rename_inst0rs1phys_i0_o <= 'b0;
        rename_inst1rs1phys_i0_o <= 'b0;
        rename_inst2rs1phys_i0_o <= 'b0;
        rename_inst3rs1phys_i0_o <= 'b0;
        rename_inst0rs2phys_i0_o <= 'b0;
        rename_inst1rs2phys_i0_o <= 'b0;
        rename_inst2rs2phys_i0_o <= 'b0;
        rename_inst3rs2phys_i0_o <= 'b0;
        rename_inst0rdphys_i0_o  <= 'b0;
        rename_inst1rdphys_i0_o  <= 'b0;
        rename_inst2rdphys_i0_o  <= 'b0;
        rename_inst3rdphys_i0_o  <= 'b0;
    end
    else if(pipe_load_rename_i)
    begin
        rename_inst0rs1phys_i0_o <= rename_inst0rs1phys_r1;
        rename_inst1rs1phys_i0_o <= rename_inst1rs1phys_r1;
        rename_inst2rs1phys_i0_o <= rename_inst2rs1phys_r1;
        rename_inst3rs1phys_i0_o <= rename_inst3rs1phys_r1;
        rename_inst0rs2phys_i0_o <= rename_inst0rs2phys_r1;
        rename_inst1rs2phys_i0_o <= rename_inst1rs2phys_r1;
        rename_inst2rs2phys_i0_o <= rename_inst2rs2phys_r1;
        rename_inst3rs2phys_i0_o <= rename_inst3rs2phys_r1;
        rename_inst0rdphys_i0_o  <= rename_inst0oldrdphys_r1;
        rename_inst1rdphys_i0_o  <= rename_inst1oldrdphys_r1;
        rename_inst2rdphys_i0_o  <= rename_inst2oldrdphys_r1;
        rename_inst3rdphys_i0_o  <= rename_inst3oldrdphys_r1;
    end
end

endmodule

