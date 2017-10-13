module Ace21064(
    input wire clock,
    input wire reset_n,
);
    wire [ 63:0] pcgen_pc_f0;
    wire [ 63:0] pcgen_pc_f1;
    wire         pipe_stall;
    
    wire [255:0] icache_instalign
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
    wire         fetch_override_vld_f1
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
    wire [  4:0] decode_inst0_rs1;
    wire [  4:0] decode_inst0_rs2;
    wire [  4:0] decode_inst0_rd;
    wire [  1:0] decode_inst0_imm_type;
    wire [  1:0] decode_inst0_src_a_sel;
    wire [  1:0] decode_inst0_src_b_sel;
    wire         decode_inst0_use_rs1;
    wire         decode_inst0_use_rs2;
    wire         decode_inst0_use_rd;
    wire         decode_inst0_write_rd;
    wire [  3:0] decode_inst0_alu_op;
    wire         decode_inst0_rs_id;
    wire         decode_inst0_illegal;
    wire         decode_inst0_memacc;
    wire [  4:0] decode_inst1_rs1;
    wire [  4:0] decode_inst1_rs2;
    wire [  4:0] decode_inst1_rd;
    wire [  1:0] decode_inst1_imm_type;
    wire [  1:0] decode_inst1_src_a_sel;
    wire [  1:0] decode_inst1_src_b_sel;
    wire         decode_inst1_use_rs1;
    wire         decode_inst1_use_rs2;
    wire         decode_inst1_use_rd;
    wire         decode_inst1_write_rd;
    wire [  3:0] decode_inst1_alu_op;
    wire         decode_inst1_rs_id;
    wire         decode_inst1_illegal;
    wire         decode_inst1_memacc;
    wire [  4:0] decode_inst2_rs1;
    wire [  4:0] decode_inst2_rs2;
    wire [  4:0] decode_inst2_rd;
    wire [  1:0] decode_inst2_imm_type;
    wire [  1:0] decode_inst2_src_a_sel;
    wire [  1:0] decode_inst2_src_b_sel;
    wire         decode_inst2_use_rs1;
    wire         decode_inst2_use_rs2;
    wire         decode_inst2_use_rd;
    wire         decode_inst2_write_rd;
    wire [  3:0] decode_inst2_alu_op;
    wire         decode_inst2_rs_id;
    wire         decode_inst2_illegal;
    wire         decode_inst2_memacc;
    wire [  4:0] decode_inst3_rs1;
    wire [  4:0] decode_inst3_rs2;
    wire [  4:0] decode_inst3_rd;
    wire [  1:0] decode_inst3_imm_type;
    wire [  1:0] decode_inst3_src_a_sel;
    wire [  1:0] decode_inst3_src_b_sel;
    wire         decode_inst3_use_rs1;
    wire         decode_inst3_use_rs2;
    wire         decode_inst3_use_rd;
    wire         decode_inst3_write_rd;
    wire [  3:0] decode_inst3_alu_op;
    wire         decode_inst3_rs_id;
    wire         decode_inst3_illegal;
    wire         decode_inst3_memacc;
    wire         decode_instbuf_full;
    wire         decode_instbuf_empty;
    wire         rename_specrfl_stall;
    wire [  6:0] rename_inst0rs1phys_r1;
    wire [  6:0] rename_inst1rs1phys_r1;
    wire [  6:0] rename_inst2rs1phys_r1;
    wire [  6:0] rename_inst3rs1phys_r1;
    wire [  6:0] rename_inst0rs2phys_r1;
    wire [  6:0] rename_inst1rs2phys_r1;
    wire [  6:0] rename_inst2rs2phys_r1;
    wire [  6:0] rename_inst3rs2phys_r1;
    wire [  6:0] rename_inst0oldrdphys_r1;
    wire [  6:0] rename_inst1oldrdphys_r1;
    wire [  6:0] rename_inst2oldrdphys_r1;
    wire [  6:0] rename_inst3oldrdphys_r1;



ace_fetch i_ace_fetch(
    .clock                   (clock                ),
    .reset_n                 (reset_n              ),
    .pcgen_pc_f0             (pcgen_pc_f0          ),
    .pcgen_pc_f1             (pcgen_pc_f1          ),
    .icache_instalign_i      (icache_instalign     ),
    .icache_stall_i          (icache_stall         ),
    .decode_instbuf_full_i   (decode_instbuf_full  ),
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

ace_decode i_ace_decode(
    .clock                   (clock                      ),
    .reset_n                 (reset_n                    ),

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

    .inst0_rs1_o             (decode_inst0_rs1             ),
    .inst0_rs2_o             (decode_inst0_rs2             ),
    .inst0_rd_o              (decode_inst0_rd              ),
    .inst0_imm_type_o        (decode_inst0_imm_type        ),
    .inst0_src_a_sel_o       (decode_inst0_src_a_sel       ),
    .inst0_src_b_sel_o       (decode_inst0_src_b_sel       ),
    .inst0_use_rs1_o         (decode_inst0_use_rs1         ),
    .inst0_use_rs2_o         (decode_inst0_use_rs2         ),
    .inst0_use_rd_o          (decode_inst0_use_rd         ),
    .inst0_write_rd_o        (decode_inst0_write_rd         ),
    .inst0_alu_op_o          (decode_inst0_alu_op          ),
    .inst0_rs_id_o           (decode_inst0_rs_id           ),
    .inst0_illegal_o         (decode_inst0_illegal         ),
    .inst0_memacc_o          (decode_inst0_memacc),

    .inst1_rs1_o             (decode_inst1_rs1             ),
    .inst1_rs2_o             (decode_inst1_rs2             ),
    .inst1_rd_o              (decode_inst1_rd              ),
    .inst1_imm_type_o        (decode_inst1_imm_type        ),
    .inst1_src_a_sel_o       (decode_inst1_src_a_sel       ),
    .inst1_src_b_sel_o       (decode_inst1_src_b_sel       ),
    .inst1_use_rs1_o         (decode_inst1_use_rs1         ),
    .inst1_use_rs2_o         (decode_inst1_use_rs2         ),
    .inst1_use_rd_o          (decode_inst1_use_rd         ),
    .inst1_write_rd_o        (decode_inst1_write_rd         ),
    .inst1_alu_op_o          (decode_inst1_alu_op          ),
    .inst1_rs_id_o           (decode_inst1_rs_id           ),
    .inst1_illegal_o         (decode_inst1_illegal         ),
    .inst1_memacc_o          (decode_inst1_memacc),
    .inst2_rs1_o             (decode_inst2_rs1             ),
    .inst2_rs2_o             (decode_inst2_rs2             ),
    .inst2_rd_o              (decode_inst2_rd              ),
    .inst2_imm_type_o        (decode_inst2_imm_type        ),
    .inst2_src_a_sel_o       (decode_inst2_src_a_sel       ),
    .inst2_src_b_sel_o       (decode_inst2_src_b_sel       ),
    .inst2_use_rs1_o         (decode_inst2_use_rs1         ),
    .inst2_use_rs2_o         (decode_inst2_use_rs2         ),
    .inst2_use_rd_o          (decode_inst2_use_rd         ),
    .inst2_write_rd_o        (decode_inst2_write_rd         ),
    .inst2_alu_op_o          (decode_inst2_alu_op          ),
    .inst2_rs_id_o           (decode_inst2_rs_id           ),
    .inst2_illegal_o         (decode_inst2_illegal         ),
    .inst2_memacc_o          (decode_inst2_memacc),
    .inst3_rs1_o             (decode_inst3_rs1             ),
    .inst3_rs2_o             (decode_inst3_rs2             ),
    .inst3_rd_o              (decode_inst3_rd              ),
    .inst3_imm_type_o        (decode_inst3_imm_type        ),
    .inst3_src_a_sel_o       (decode_inst3_src_a_sel       ),
    .inst3_src_b_sel_o       (decode_inst3_src_b_sel       ),
    .inst3_use_rs1_o         (decode_inst3_use_rs1         ),
    .inst3_use_rs2_o         (decode_inst3_use_rs2         ),
    .inst3_use_rd_o          (decode_inst3_use_rd         ),
    .inst3_write_rd_o        (decode_inst3_write_rd         ),
    .inst3_alu_op_o          (decode_inst3_alu_op          ),
    .inst3_rs_id_o           (decode_inst3_rs_id           ),
    .inst3_illegal_o         (decode_inst3_illegal         ),
    .inst3_memacc_o          (decode_inst3_memacc),
    .instbuf_full_o          (decode_instbuf_full          ),
    .instbuf_empty_o         (decode_instbuf_empty         )
);


ace_rename i_ace_rename(
    .clock                   (clock),
    .reset_n                 (reset_n),
    .pc_r0_i                 (pcgen_pc_r0),
    .decode_inst0rs1_i          (decode_inst0_rs1    ),
    .decode_inst1rs1_i          (decode_inst1_rs1    ),
    .decode_inst2rs1_i          (decode_inst2_rs1    ),
    .decode_inst3rs1_i          (decode_inst3_rs1    ),
    .decode_inst0rs2_i          (decode_inst0_rs2    ),
    .decode_inst1rs2_i          (decode_inst1_rs2    ),
    .decode_inst2rs2_i          (decode_inst2_rs2    ),
    .decode_inst3rs2_i          (decode_inst3_rs2    ),
    .decode_inst0rd_i           (decode_inst0_rd     ),
    .decode_inst1rd_i           (decode_inst1_rd     ),
    .decode_inst2rd_i           (decode_inst2_rd     ),
    .decode_inst3rd_i           (decode_inst3_rd     ),
    .decode_inst0writeRd_i      (decode_inst0_write_rd),
    .decode_inst1writeRd_i      (decode_inst1_write_rd),
    .decode_inst2writeRd_i      (decode_inst2_write_rd),
    .decode_inst3writeRd_i      (decode_inst3_write_rd),
    .decode_inst0useRd_i        (decode_inst0_use_rd  ),
    .decode_inst1useRd_i        (decode_inst1_use_rd  ),
    .decode_inst2useRd_i        (decode_inst2_use_rd  ),
    .decode_inst3useRd_i        (decode_inst3_use_rd  ),
    .decode_inst0memacc_i       (decode_inst0_memacc  ),
    .decode_inst1memacc_i       (decode_inst1_memacc  ),
    .decode_inst2memacc_i       (decode_inst2_memacc  ),
    .decode_inst3memacc_i       (decode_inst3_memacc  ),
 
    .retire_lfst_invld0_i       (retire_lfst_invld0    ),
    .retire_lfst_invld1_i       (retire_lfst_invld1    ),
    .retire_lfst_invld_idx0_i   (retire_lfst_invld_idx0),
    .retire_lfst_invld_idx1_i   (retire_lfst_invld_idx1),
    .retire_flush_i             (retire_flush          ),
    .retire_flush_r_i           (retire_flush_r        ),
    .pipe_stall_i               (pipe_stall            ),

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
    .rename_inst0rs1phys_r1_o   (rename_inst0rs1phys_r1  ),
    .rename_inst1rs1phys_r1_o   (rename_inst1rs1phys_r1  ),
    .rename_inst2rs1phys_r1_o   (rename_inst2rs1phys_r1  ),
    .rename_inst3rs1phys_r1_o   (rename_inst3rs1phys_r1  ),
    .rename_inst0rs2phys_r1_o   (rename_inst0rs2phys_r1  ),
    .rename_inst1rs2phys_r1_o   (rename_inst1rs2phys_r1  ),
    .rename_inst2rs2phys_r1_o   (rename_inst2rs2phys_r1  ),
    .rename_inst3rs2phys_r1_o   (rename_inst3rs2phys_r1  ),
    .rename_inst0oldrdphys_r1_o (rename_inst0oldrdphys_r1),
    .rename_inst1oldrdphys_r1_o (rename_inst1oldrdphys_r1),
    .rename_inst2oldrdphys_r1_o (rename_inst2oldrdphys_r1),
    .rename_inst3oldrdphys_r1_o (rename_inst3oldrdphys_r1)
);

endmodule
