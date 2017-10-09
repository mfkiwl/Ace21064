module Ace21064(
    input wire clock,
    input wire reset_n,
);
    wire [ 63:0] pcgen_pc_f0;
    wire [ 63:0] pcgen_pc_f1;
    
    wire [255:0] icache_instalign
    wire         icache_stall;
    wire         retire_flush;
    wire [ 63:0] retire_flush_pc;
    wire         retire_brcond_vld;
    wire         retire_brindir_vld;
    wire         retire_brdir;
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
    wire         decode_inst0_need_rd;
    wire [  3:0] decode_inst0_alu_op;
    wire         decode_inst0_rs_id;
    wire         decode_inst0_illegal;
    wire [  4:0] decode_inst1_rs1;
    wire [  4:0] decode_inst1_rs2;
    wire [  4:0] decode_inst1_rd;
    wire [  1:0] decode_inst1_imm_type;
    wire [  1:0] decode_inst1_src_a_sel;
    wire [  1:0] decode_inst1_src_b_sel;
    wire         decode_inst1_use_rs1;
    wire         decode_inst1_use_rs2;
    wire         decode_inst1_need_rd;
    wire [  3:0] decode_inst1_alu_op;
    wire         decode_inst1_rs_id;
    wire         decode_inst1_illegal;
    wire [  4:0] decode_inst2_rs1;
    wire [  4:0] decode_inst2_rs2;
    wire [  4:0] decode_inst2_rd;
    wire [  1:0] decode_inst2_imm_type;
    wire [  1:0] decode_inst2_src_a_sel;
    wire [  1:0] decode_inst2_src_b_sel;
    wire         decode_inst2_use_rs1;
    wire         decode_inst2_use_rs2;
    wire         decode_inst2_need_rd;
    wire [  3:0] decode_inst2_alu_op;
    wire         decode_inst2_rs_id;
    wire         decode_inst2_illegal;
    wire [  4:0] decode_inst3_rs1;
    wire [  4:0] decode_inst3_rs2;
    wire [  4:0] decode_inst3_rd;
    wire [  1:0] decode_inst3_imm_type;
    wire [  1:0] decode_inst3_src_a_sel;
    wire [  1:0] decode_inst3_src_b_sel;
    wire         decode_inst3_use_rs1;
    wire         decode_inst3_use_rs2;
    wire         decode_inst3_need_rd;
    wire [  3:0] decode_inst3_alu_op;
    wire         decode_inst3_rs_id;
    wire         decode_inst3_illegal;
    wire         decode_instbuf_full;
    wire         decode_instbuf_empty;


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
    .inst0_need_rd_o         (decode_inst0_need_rd         ),
    .inst0_alu_op_o          (decode_inst0_alu_op          ),
    .inst0_rs_id_o           (decode_inst0_rs_id           ),
    .inst0_illegal_o         (decode_inst0_illegal         ),
    .inst1_rs1_o             (decode_inst1_rs1             ),
    .inst1_rs2_o             (decode_inst1_rs2             ),
    .inst1_rd_o              (decode_inst1_rd              ),
    .inst1_imm_type_o        (decode_inst1_imm_type        ),
    .inst1_src_a_sel_o       (decode_inst1_src_a_sel       ),
    .inst1_src_b_sel_o       (decode_inst1_src_b_sel       ),
    .inst1_use_rs1_o         (decode_inst1_use_rs1         ),
    .inst1_use_rs2_o         (decode_inst1_use_rs2         ),
    .inst1_need_rd_o         (decode_inst1_need_rd         ),
    .inst1_alu_op_o          (decode_inst1_alu_op          ),
    .inst1_rs_id_o           (decode_inst1_rs_id           ),
    .inst1_illegal_o         (decode_inst1_illegal         ),
    .inst2_rs1_o             (decode_inst2_rs1             ),
    .inst2_rs2_o             (decode_inst2_rs2             ),
    .inst2_rd_o              (decode_inst2_rd              ),
    .inst2_imm_type_o        (decode_inst2_imm_type        ),
    .inst2_src_a_sel_o       (decode_inst2_src_a_sel       ),
    .inst2_src_b_sel_o       (decode_inst2_src_b_sel       ),
    .inst2_use_rs1_o         (decode_inst2_use_rs1         ),
    .inst2_use_rs2_o         (decode_inst2_use_rs2         ),
    .inst2_need_rd_o         (decode_inst2_need_rd         ),
    .inst2_alu_op_o          (decode_inst2_alu_op          ),
    .inst2_rs_id_o           (decode_inst2_rs_id           ),
    .inst2_illegal_o         (decode_inst2_illegal         ),
    .inst3_rs1_o             (decode_inst3_rs1             ),
    .inst3_rs2_o             (decode_inst3_rs2             ),
    .inst3_rd_o              (decode_inst3_rd              ),
    .inst3_imm_type_o        (decode_inst3_imm_type        ),
    .inst3_src_a_sel_o       (decode_inst3_src_a_sel       ),
    .inst3_src_b_sel_o       (decode_inst3_src_b_sel       ),
    .inst3_use_rs1_o         (decode_inst3_use_rs1         ),
    .inst3_use_rs2_o         (decode_inst3_use_rs2         ),
    .inst3_need_rd_o         (decode_inst3_need_rd         ),
    .inst3_alu_op_o          (decode_inst3_alu_op          ),
    .inst3_rs_id_o           (decode_inst3_rs_id           ),
    .inst3_illegal_o         (decode_inst3_illegal         ),
    .instbuf_full_o          (decode_instbuf_full          ),
    .instbuf_empty_o         (decode_instbuf_empty         )
);

endmodule
