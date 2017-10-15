////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : Ace21064_top.v
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
module Ace21064_top(
    input wire clock,
    input wire reset_n
);
    wire [ 63:0] pcgen_pc_f0;
    wire [ 63:0] pcgen_pc_f1;
    wire         pipe_stall;
    wire         pipe_load_fetch;
    wire         pipe_load_decode;
    wire         pipe_load_rename;
    
    wire [255:0] icache_instalign;
    wire         icache_stall;

    wire [ 11:0] l1dcache_ssitidx1;
    wire [ 11:0] l1dcache_ssitidx2;
    wire         l1dcache_ssitwe;

    wire         retire_flush;
    wire         retire_flush_r;
    wire [ 63:0] retire_flush_pc;
    wire         retire_brcond_vld;
    wire         retire_brindir_vld;
    wire         retire_brdir;
    wire         retire_lfst_invld0;
    wire         retire_lfst_invld1;
    wire [  6:0] retire_lfst_invld_idx0;
    wire [  6:0] retire_lfst_invld_idx1;
    wire [223:0] retire_archrat_data;
    wire [335:0] retire_archrfl_data;
    wire [  6:0] retire_freereg0;
    wire [  6:0] retire_freereg1;
    wire [  6:0] retire_freereg2;
    wire [  6:0] retire_freereg3;
    wire [  6:0] retire_freereg4;
    wire [  6:0] retire_freereg5;
    wire [  6:0] retire_freereg6;
    wire [  6:0] retire_freereg7;
    wire         retire_freereg0_vld;
    wire         retire_freereg1_vld;
    wire         retire_freereg2_vld;
    wire         retire_freereg3_vld;
    wire         retire_freereg4_vld;
    wire         retire_freereg5_vld;
    wire         retire_freereg6_vld;
    wire         retire_freereg7_vld;
    wire [ 63:0] fetch_override_pc_f1;
    wire         fetch_override_vld_f1;
    wire [ 63:0] fetch_nxt_pc_f0;
    wire [ 31:0] fetch_inst0_d0;
    wire [ 31:0] fetch_inst1_d0;
    wire [ 31:0] fetch_inst2_d0;
    wire [ 31:0] fetch_inst3_d0;
    wire [ 31:0] fetch_inst4_d0;
    wire [ 31:0] fetch_inst5_d0;
    wire [ 31:0] fetch_inst6_d0;
    wire [ 31:0] fetch_inst7_d0;
    wire         fetch_inst0_vld_d0;
    wire         fetch_inst1_vld_d0;
    wire         fetch_inst2_vld_d0;
    wire         fetch_inst3_vld_d0;
    wire         fetch_inst4_vld_d0;
    wire         fetch_inst5_vld_d0;
    wire         fetch_inst6_vld_d0;
    wire         fetch_inst7_vld_d0;
    wire [  4:0] decode_inst0_rs1_r0;
    wire [  4:0] decode_inst0_rs2_r0;
    wire [  4:0] decode_inst0_rd_r0;
    wire [  1:0] decode_inst0_imm_type_r0;
    wire [  1:0] decode_inst0_src1_sel_r0;
    wire [  1:0] decode_inst0_src2_sel_r0;
    wire         decode_inst0_use_rs1_r0;
    wire         decode_inst0_use_rs2_r0;
    wire         decode_inst0_use_rd_r0;
    wire         decode_inst0_write_rd_r0;
    wire [  3:0] decode_inst0_alu_op_r0;
    wire         decode_inst0_illegal_r0;
    wire         decode_inst0_memory_r0;
    wire         decode_inst0_branch_r0;
    wire         decode_inst0_simple_r0;
    wire         decode_inst0_complx_r0;
    wire [  4:0] decode_inst1_rs1_r0;
    wire [  4:0] decode_inst1_rs2_r0;
    wire [  4:0] decode_inst1_rd_r0;
    wire [  1:0] decode_inst1_imm_type_r0;
    wire [  1:0] decode_inst1_src1_sel_r0;
    wire [  1:0] decode_inst1_src2_sel_r0;
    wire         decode_inst1_use_rs1_r0;
    wire         decode_inst1_use_rs2_r0;
    wire         decode_inst1_use_rd_r0;
    wire         decode_inst1_write_rd_r0;
    wire [  3:0] decode_inst1_alu_op_r0;
    wire         decode_inst1_illegal_r0;
    wire         decode_inst1_memory_r0;
    wire         decode_inst1_branch_r0;
    wire         decode_inst1_simple_r0;
    wire         decode_inst1_complx_r0;
    wire [  4:0] decode_inst2_rs1_r0;
    wire [  4:0] decode_inst2_rs2_r0;
    wire [  4:0] decode_inst2_rd_r0;
    wire [  1:0] decode_inst2_imm_type_r0;
    wire [  1:0] decode_inst2_src1_sel_r0;
    wire [  1:0] decode_inst2_src2_sel_r0;
    wire         decode_inst2_use_rs1_r0;
    wire         decode_inst2_use_rs2_r0;
    wire         decode_inst2_use_rd_r0;
    wire         decode_inst2_write_rd_r0;
    wire [  3:0] decode_inst2_alu_op_r0;
    wire         decode_inst2_illegal_r0;
    wire         decode_inst2_memory_r0;
    wire         decode_inst2_branch_r0;
    wire         decode_inst2_simple_r0;
    wire         decode_inst2_complx_r0;
    wire [  4:0] decode_inst3_rs1_r0;
    wire [  4:0] decode_inst3_rs2_r0;
    wire [  4:0] decode_inst3_rd_r0;
    wire [  1:0] decode_inst3_imm_type_r0;
    wire [  1:0] decode_inst3_src1_sel_r0;
    wire [  1:0] decode_inst3_src2_sel_r0;
    wire         decode_inst3_use_rs1_r0;
    wire         decode_inst3_use_rs2_r0;
    wire         decode_inst3_use_rd_r0;
    wire         decode_inst3_write_rd_r0;
    wire [  3:0] decode_inst3_alu_op_r0;
    wire         decode_inst3_illegal_r0;
    wire         decode_inst3_memory_r0;
    wire         decode_inst3_branch_r0;
    wire         decode_inst3_simple_r0;
    wire         decode_inst3_complx_r0;
    wire         decode_instbuf_full_d0;
    wire         decode_instbuf_empty_d0;
    wire         rename_specrfl_stall;
    wire [  6:0] rename_inst0rs1phys_i0;
    wire [  6:0] rename_inst1rs1phys_i0;
    wire [  6:0] rename_inst2rs1phys_i0;
    wire [  6:0] rename_inst3rs1phys_i0;
    wire [  6:0] rename_inst0rs2phys_i0;
    wire [  6:0] rename_inst1rs2phys_i0;
    wire [  6:0] rename_inst2rs2phys_i0;
    wire [  6:0] rename_inst3rs2phys_i0;
    wire [  6:0] rename_inst0rdphys_i0;
    wire [  6:0] rename_inst1rdphys_i0;
    wire [  6:0] rename_inst2rdphys_i0;
    wire [  6:0] rename_inst3rdphys_i0;



// two pipeline stages in fetch, signals in these stages are suffixed with
// "_f0" or "_f1"
ace_fetch i_ace_fetch(
    .clock                   (clock                ),
    .reset_n                 (reset_n              ),
    .pcgen_pc_f0             (pcgen_pc_f0          ),
    .pcgen_pc_f1             (pcgen_pc_f1          ),
    .icache_instalign_i      (icache_instalign     ),
    .icache_stall_i          (icache_stall         ),
    .decode_instbuf_full_i   (decode_instbuf_full_d0  ),
    .retire_flush_i          (retire_flush         ),
    .retire_flush_pc_i       (retire_flush_pc      ),
    .retire_brcond_vld_i     (retire_brcond_vld    ),
    .retire_brindir_vld_i    (retire_brindir_vld   ),
    .retire_brdir_i          (retire_brdir         ),
    .override_pc_f1_o        (fetch_override_pc_f1 ),
    .override_vld_f1_o       (fetch_override_vld_f1),
    .nxt_pc_f0_o             (fetch_nxt_pc_f0      ),
    .inst0_vld_d0_o          (fetch_inst0_vld_d0   ),
    .inst1_vld_d0_o          (fetch_inst1_vld_d0   ),
    .inst2_vld_d0_o          (fetch_inst2_vld_d0   ),
    .inst3_vld_d0_o          (fetch_inst3_vld_d0   ),
    .inst4_vld_d0_o          (fetch_inst4_vld_d0   ),
    .inst5_vld_d0_o          (fetch_inst5_vld_d0   ),
    .inst6_vld_d0_o          (fetch_inst6_vld_d0   ),
    .inst7_vld_d0_o          (fetch_inst7_vld_d0   ),
    .inst0_d0_o              (fetch_inst0_d0       ),
    .inst1_d0_o              (fetch_inst1_d0       ),
    .inst2_d0_o              (fetch_inst2_d0       ),
    .inst3_d0_o              (fetch_inst3_d0       ),
    .inst4_d0_o              (fetch_inst4_d0       ),
    .inst5_d0_o              (fetch_inst5_d0       ),
    .inst6_d0_o              (fetch_inst6_d0       ),
    .inst7_d0_o              (fetch_inst7_d0       )
);

// two pipeline stages in decode, signals in these stages are suffixed with
// "_d0" or "_d1"
ace_decode i_ace_decode(
    .clock                   (clock                      ),
    .reset_n                 (reset_n                    ),
    .pipe_load_decode_i      (pipe_load_decode_i         ),
    .retire_flush_i          (retire_flush               ),
    .fetch_inst0_i           (fetch_inst0_d0             ),
    .fetch_inst1_i           (fetch_inst1_d0             ),
    .fetch_inst2_i           (fetch_inst2_d0             ),
    .fetch_inst3_i           (fetch_inst3_d0             ),
    .fetch_inst4_i           (fetch_inst4_d0             ),
    .fetch_inst5_i           (fetch_inst5_d0             ),
    .fetch_inst6_i           (fetch_inst6_d0             ),
    .fetch_inst7_i           (fetch_inst7_d0             ),
    .fetch_inst0_vld_i       (fetch_inst0_vld_d0         ),
    .fetch_inst1_vld_i       (fetch_inst1_vld_d0         ),
    .fetch_inst2_vld_i       (fetch_inst2_vld_d0         ),
    .fetch_inst3_vld_i       (fetch_inst3_vld_d0         ),
    .fetch_inst4_vld_i       (fetch_inst4_vld_d0         ),
    .fetch_inst5_vld_i       (fetch_inst5_vld_d0         ),
    .fetch_inst6_vld_i       (fetch_inst6_vld_d0         ),
    .fetch_inst7_vld_i       (fetch_inst7_vld_d0         ),

    .inst0_rs1_r0_o            (decode_inst0_rs1_r0 ),
    .inst0_rs2_r0_o            (decode_inst0_rs2_r0 ),
    .inst0_rd_r0_o             (decode_inst0_rd_r0 ),
    .inst0_imm_type_r0_o       (decode_inst0_imm_type_r0 ),
    .inst0_src1_sel_r0_o      (decode_inst0_src1_sel_r0 ),
    .inst0_src2_sel_r0_o      (decode_inst0_src2_sel_r0 ),
    .inst0_use_rs1_r0_o        (decode_inst0_use_rs1_r0 ),
    .inst0_use_rs2_r0_o        (decode_inst0_use_rs2_r0 ),
    .inst0_use_rd_r0_o         (decode_inst0_use_rd_r0 ),
    .inst0_write_rd_r0_o       (decode_inst0_write_rd_r0 ),
    .inst0_alu_op_r0_o         (decode_inst0_alu_op_r0 ),
    .inst0_illegal_r0_o        (decode_inst0_illegal_r0 ),
    .inst0_memory_r0_o         (decode_inst0_memory_r0 ),
    .inst0_branch_r0_o         (decode_inst0_branch_r0 ),
    .inst0_simple_r0_o         (decode_inst0_simple_r0 ),
    .inst0_complx_r0_o         (decode_inst0_complx_r0 ),
    .inst1_rs1_r0_o            (decode_inst1_rs1_r0 ),
    .inst1_rs2_r0_o            (decode_inst1_rs2_r0 ),
    .inst1_rd_r0_o             (decode_inst1_rd_r0 ),
    .inst1_imm_type_r0_o       (decode_inst1_imm_type_r0 ),
    .inst1_src1_sel_r0_o      (decode_inst1_src1_sel_r0 ),
    .inst1_src2_sel_r0_o      (decode_inst1_src2_sel_r0 ),
    .inst1_use_rs1_r0_o        (decode_inst1_use_rs1_r0 ),
    .inst1_use_rs2_r0_o        (decode_inst1_use_rs2_r0 ),
    .inst1_use_rd_r0_o         (decode_inst1_use_rd_r0 ),
    .inst1_write_rd_r0_o       (decode_inst1_write_rd_r0 ),
    .inst1_alu_op_r0_o         (decode_inst1_alu_op_r0 ),
    .inst1_illegal_r0_o        (decode_inst1_illegal_r0 ),
    .inst1_memory_r0_o         (decode_inst1_memory_r0 ),
    .inst1_branch_r0_o         (decode_inst1_branch_r0 ),
    .inst1_simple_r0_o         (decode_inst1_simple_r0 ),
    .inst1_complx_r0_o         (decode_inst1_complx_r0 ),
    .inst2_rs1_r0_o            (decode_inst2_rs1_r0 ),
    .inst2_rs2_r0_o            (decode_inst2_rs2_r0 ),
    .inst2_rd_r0_o             (decode_inst2_rd_r0 ),
    .inst2_imm_type_r0_o       (decode_inst2_imm_type_r0 ),
    .inst2_src1_sel_r0_o      (decode_inst2_src1_sel_r0 ),
    .inst2_src2_sel_r0_o      (decode_inst2_src2_sel_r0 ),
    .inst2_use_rs1_r0_o        (decode_inst2_use_rs1_r0 ),
    .inst2_use_rs2_r0_o        (decode_inst2_use_rs2_r0 ),
    .inst2_use_rd_r0_o         (decode_inst2_use_rd_r0 ),
    .inst2_write_rd_r0_o       (decode_inst2_write_rd_r0 ),
    .inst2_alu_op_r0_o         (decode_inst2_alu_op_r0 ),
    .inst2_illegal_r0_o        (decode_inst2_illegal_r0 ),
    .inst2_memory_r0_o         (decode_inst2_memory_r0 ),
    .inst2_branch_r0_o         (decode_inst2_branch_r0 ),
    .inst2_simple_r0_o         (decode_inst2_simple_r0 ),
    .inst2_complx_r0_o         (decode_inst2_complx_r0 ),

    .inst3_rs1_r0_o            (decode_inst3_rs1_r0 ),
    .inst3_rs2_r0_o            (decode_inst3_rs2_r0 ),
    .inst3_rd_r0_o             (decode_inst3_rd_r0 ),
    .inst3_imm_type_r0_o       (decode_inst3_imm_type_r0 ),
    .inst3_src1_sel_r0_o       (decode_inst3_src1_sel_r0 ),
    .inst3_src2_sel_r0_o       (decode_inst3_src2_sel_r0 ),
    .inst3_use_rs1_r0_o        (decode_inst3_use_rs1_r0 ),
    .inst3_use_rs2_r0_o        (decode_inst3_use_rs2_r0 ),
    .inst3_use_rd_r0_o         (decode_inst3_use_rd_r0 ),
    .inst3_write_rd_r0_o       (decode_inst3_write_rd_r0 ),
    .inst3_alu_op_r0_o         (decode_inst3_alu_op_r0 ),
    .inst3_illegal_r0_o        (decode_inst3_illegal_r0 ),
    .inst3_memory_r0_o         (decode_inst3_memory_r0 ),
    .inst3_branch_r0_o         (decode_inst3_branch_r0 ),
    .inst3_simple_r0_o         (decode_inst3_simple_r0 ),
    .inst3_complx_r0_o         (decode_inst3_complx_r0 ),
    .instbuf_full_d0_o         (decode_instbuf_full_d0          ),
    .instbuf_empty_d0_o        (decode_instbuf_empty_d0         )
);

// two pipeline stages in rename, signals in these stages are suffixed with
// "_r0" or "_r1"
ace_rename i_ace_rename(
    .clock                   (clock),
    .reset_n                 (reset_n),
    .pc_r0_i                 (pcgen_pc_r0),
    .decode_inst0rs1_i          (decode_inst0_rs1_r0    ),
    .decode_inst1rs1_i          (decode_inst1_rs1_r0    ),
    .decode_inst2rs1_i          (decode_inst2_rs1_r0    ),
    .decode_inst3rs1_i          (decode_inst3_rs1_r0    ),
    .decode_inst0rs2_i          (decode_inst0_rs2_r0    ),
    .decode_inst1rs2_i          (decode_inst1_rs2_r0    ),
    .decode_inst2rs2_i          (decode_inst2_rs2_r0    ),
    .decode_inst3rs2_i          (decode_inst3_rs2_r0    ),
    .decode_inst0rd_i           (decode_inst0_rd_r0     ),
    .decode_inst1rd_i           (decode_inst1_rd_r0     ),
    .decode_inst2rd_i           (decode_inst2_rd_r0     ),
    .decode_inst3rd_i           (decode_inst3_rd_r0     ),
    .decode_inst0writeRd_i      (decode_inst0_write_rd_r0),
    .decode_inst1writeRd_i      (decode_inst1_write_rd_r0),
    .decode_inst2writeRd_i      (decode_inst2_write_rd_r0),
    .decode_inst3writeRd_i      (decode_inst3_write_rd_r0),
    .decode_inst0useRd_i        (decode_inst0_use_rd_r0  ),
    .decode_inst1useRd_i        (decode_inst1_use_rd_r0  ),
    .decode_inst2useRd_i        (decode_inst2_use_rd_r0  ),
    .decode_inst3useRd_i        (decode_inst3_use_rd_r0  ),
    .decode_inst0memory_i       (decode_inst0_memory_r0  ),
    .decode_inst1memory_i       (decode_inst1_memory_r0  ),
    .decode_inst2memory_i       (decode_inst2_memory_r0  ),
    .decode_inst3memory_i       (decode_inst3_memory_r0  ),
 
    .retire_lfst_invld0_i       (retire_lfst_invld0    ),
    .retire_lfst_invld1_i       (retire_lfst_invld1    ),
    .retire_lfst_invld_idx0_i   (retire_lfst_invld_idx0),
    .retire_lfst_invld_idx1_i   (retire_lfst_invld_idx1),
    .retire_flush_i             (retire_flush          ),
    .retire_flush_r_i           (retire_flush_r        ),
    .pipe_stall_i               (pipe_stall            ),
    .pipe_load_rename_i         (pipe_load_rename),

    .retire_archrat_data_i      (retire_archrat_data  ),
    .retire_archrfl_data_i      (retire_archrfl_data  ),
    .retire_freereg0_i          (retire_freereg0      ),
    .retire_freereg1_i          (retire_freereg1      ),
    .retire_freereg2_i          (retire_freereg2      ),
    .retire_freereg3_i          (retire_freereg3      ),
    .retire_freereg4_i          (retire_freereg4      ),
    .retire_freereg5_i          (retire_freereg5      ),
    .retire_freereg6_i          (retire_freereg6      ),
    .retire_freereg7_i          (retire_freereg7      ),
    .retire_freereg0_vld_i      (retire_freereg0_vld  ),
    .retire_freereg1_vld_i      (retire_freereg1_vld  ),
    .retire_freereg2_vld_i      (retire_freereg2_vld  ),
    .retire_freereg3_vld_i      (retire_freereg3_vld  ),
    .retire_freereg4_vld_i      (retire_freereg4_vld  ),
    .retire_freereg5_vld_i      (retire_freereg5_vld  ),
    .retire_freereg6_vld_i      (retire_freereg6_vld  ),
    .retire_freereg7_vld_i      (retire_freereg7_vld  ),
    .l1dcache_ssitidx1_i        (l1dcache_ssitidx1    ),
    .l1dcache_ssitidx2_i        (l1dcache_ssitidx2    ),
    .l1dcache_ssitwe_i          (l1dcache_ssitwe      ),

    .rename_specrfl_stall_o     (rename_specrfl_stall    ),
    .rename_inst0rs1phys_i0_o   (rename_inst0rs1phys_i0  ),
    .rename_inst1rs1phys_i0_o   (rename_inst1rs1phys_i0  ),
    .rename_inst2rs1phys_i0_o   (rename_inst2rs1phys_i0  ),
    .rename_inst3rs1phys_i0_o   (rename_inst3rs1phys_i0  ),
    .rename_inst0rs2phys_i0_o   (rename_inst0rs2phys_i0  ),
    .rename_inst1rs2phys_i0_o   (rename_inst1rs2phys_i0  ),
    .rename_inst2rs2phys_i0_o   (rename_inst2rs2phys_i0  ),
    .rename_inst3rs2phys_i0_o   (rename_inst3rs2phys_i0  ),
    .rename_inst0rdphys_i0_o    (rename_inst0rdphys_i0),
    .rename_inst1rdphys_i0_o    (rename_inst1rdphys_i0),
    .rename_inst2rdphys_i0_o    (rename_inst2rdphys_i0),
    .rename_inst3rdphys_i0_o    (rename_inst3rdphys_i0)
);

// two pipeline stages in issue, signals in these stages are suffixed with
// "_i0" or "_i1"

endmodule
