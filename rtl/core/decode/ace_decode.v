//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ace_decode.v
//  Author      : ejune@aureage.com
//                
//  Description : 
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module ace_decode (
    input  wire         clock,
    input  wire         reset_n,
    input  wire         retire_flush_i,
    input  wire         pipe_load_decode_i,

    input  wire [31:0]  fetch_inst0_i,
    input  wire [31:0]  fetch_inst1_i,
    input  wire [31:0]  fetch_inst2_i,
    input  wire [31:0]  fetch_inst3_i,
    input  wire [31:0]  fetch_inst4_i,
    input  wire [31:0]  fetch_inst5_i,
    input  wire [31:0]  fetch_inst6_i,
    input  wire [31:0]  fetch_inst7_i,
    input  wire         fetch_inst0_vld_i,
    input  wire         fetch_inst1_vld_i,
    input  wire         fetch_inst2_vld_i,
    input  wire         fetch_inst3_vld_i,
    input  wire         fetch_inst4_vld_i,
    input  wire         fetch_inst5_vld_i,
    input  wire         fetch_inst6_vld_i,
    input  wire         fetch_inst7_vld_i,

    output wire [4:0]   inst0_rs1_r0_o,
    output wire [4:0]   inst0_rs2_r0_o,
    output wire [4:0]   inst0_rd_r0_o,
    output wire [1:0]   inst0_imm_type_r0_o,
    output wire [1:0]   inst0_src_a_sel_r0_o,// select alu operands
    output wire [1:0]   inst0_src_b_sel_r0_o,
    output wire         inst0_use_rs1_r0_o,
    output wire         inst0_use_rs2_r0_o,
    output wire         inst0_use_rd_r0_o,
    output wire         inst0_write_rd_r0_o,
    output wire [3:0]   inst0_alu_op_r0_o,
    output wire         inst0_rs_id_r0_o,    // reservation station id
    output wire         inst0_illegal_r0_o,
    output wire         inst0_memacc_r0_o,

    output wire [4:0]   inst1_rs1_r0_o,
    output wire [4:0]   inst1_rs2_r0_o,
    output wire [4:0]   inst1_rd_r0_o,
    output wire [1:0]   inst1_imm_type_r0_o,
    output wire [1:0]   inst1_src_a_sel_r0_o,// select alu operands
    output wire [1:0]   inst1_src_b_sel_r0_o,
    output wire         inst1_use_rs1_r0_o,
    output wire         inst1_use_rs2_r0_o,
    output wire         inst1_use_rd_r0_o,
    output wire         inst1_write_rd_r0_o,
    output wire [3:0]   inst1_alu_op_r0_o,
    output wire         inst1_rs_id_r0_o,    // reservation station id
    output wire         inst1_illegal_r0_o,
    output wire         inst1_memacc_r0_o,

    output wire [4:0]   inst2_rs1_r0_o,
    output wire [4:0]   inst2_rs2_r0_o,
    output wire [4:0]   inst2_rd_r0_o,
    output wire [1:0]   inst2_imm_type_r0_o,
    output wire [1:0]   inst2_src_a_sel_r0_o,// select alu operands
    output wire [1:0]   inst2_src_b_sel_r0_o,
    output wire         inst2_use_rs1_r0_o,
    output wire         inst2_use_rs2_r0_o,
    output wire         inst2_use_rd_r0_o,
    output wire         inst2_write_rd_r0_o,
    output wire [3:0]   inst2_alu_op_r0_o,
    output wire         inst2_rs_id_r0_o,    // reservation station id
    output wire         inst2_illegal_r0_o,
    output wire         inst2_memacc_r0_o,

    output wire [4:0]   inst3_rs1_r0_o,
    output wire [4:0]   inst3_rs2_r0_o,
    output wire [4:0]   inst3_rd_r0_o,
    output wire [1:0]   inst3_imm_type_r0_o,
    output wire [1:0]   inst3_src_a_sel_r0_o,// select alu operands
    output wire [1:0]   inst3_src_b_sel_r0_o,
    output wire         inst3_use_rs1_r0_o,
    output wire         inst3_use_rs2_r0_o,
    output wire         inst3_use_rd_r0_o,
    output wire         inst3_write_rd_r0_o,
    output wire [3:0]   inst3_alu_op_r0_o,
    output wire         inst3_rs_id_r0_o,    // reservation station id
    output wire         inst3_illegal_r0_o,
    output wire         inst3_memacc_r0_o,

    output wire         instbuf_full_d0_o,
    output wire         instbuf_empty_d0_o
 
);

wire [31:0]   buf_dec_inst0_d1;
wire [31:0]   buf_dec_inst1_d1;
wire [31:0]   buf_dec_inst2_d1;
wire [31:0]   buf_dec_inst3_d1;

inst_buf i_inst_buf(
    .clock              (clock              ),
    .reset_n            (reset_n            ),
    .flush_i            (retire_flush_i            ),
    .pipe_load_decode_i (pipe_load_decode_i       ),
    .inst0_i            (fetch_inst0_i            ),
    .inst1_i            (fetch_inst1_i            ),
    .inst2_i            (fetch_inst2_i            ),
    .inst3_i            (fetch_inst3_i            ),
    .inst4_i            (fetch_inst4_i            ),
    .inst5_i            (fetch_inst5_i            ),
    .inst6_i            (fetch_inst6_i            ),
    .inst7_i            (fetch_inst7_i            ),
    .inst0_vld_i        (fetch_inst0_vld_i        ),
    .inst1_vld_i        (fetch_inst1_vld_i        ),
    .inst2_vld_i        (fetch_inst2_vld_i        ),
    .inst3_vld_i        (fetch_inst3_vld_i        ),
    .inst4_vld_i        (fetch_inst4_vld_i        ),
    .inst5_vld_i        (fetch_inst5_vld_i        ),
    .inst6_vld_i        (fetch_inst6_vld_i        ),
    .inst7_vld_i        (fetch_inst7_vld_i        ),
    .buf_inst0_r_o        (buf_dec_inst0_d1      ),
    .buf_inst1_r_o        (buf_dec_inst1_d1      ),
    .buf_inst2_r_o        (buf_dec_inst2_d1      ),
    .buf_inst3_r_o        (buf_dec_inst3_d1      ),
    .buf_full_o         (instbuf_full_d0_o     ),
    .buf_empty_o        (instbuf_empty_d0_o    )
);


dec_way decoder_way0(
    .inst_i               (buf_dec_inst0_d1    ),
    .rs1_r0_o               (inst0_rs1_r0_o        ),
    .rs2_r0_o               (inst0_rs2_r0_o        ),
    .rd_r0_o                (inst0_rd_r0_o         ),
    .imm_type_r0_o          (inst0_imm_type_r0_o   ),
    .src_a_sel_r0_o         (inst0_src_a_sel_r0_o  ),
    .src_b_sel_r0_o         (inst0_src_b_sel_r0_o  ),
    .use_rs1_r0_o           (inst0_use_rs1_r0_o    ),
    .use_rs2_r0_o           (inst0_use_rs2_r0_o    ),
    .use_rd_r0_o            (inst0_use_rd_r0_o     ),
    .write_rd_r0_o          (inst0_write_rd_r0_o   ),
    .alu_op_r0_o            (inst0_alu_op_r0_o     ),
    .rs_id_r0_o             (inst0_rs_id_r0_o      ),
    .illegal_inst_r0_o      (inst0_illegal_r0_o    ),
    .memory_inst_r0_o       (inst0_memacc_r0_o     )
);

dec_way decoder_way1(
    .inst_i               (buf_dec_inst1_d1    ),
    .rs1_r0_o               (inst1_rs1_r0_o      ),
    .rs2_r0_o               (inst1_rs2_r0_o      ),
    .rd_r0_o                (inst1_rd_r0_o       ),
    .imm_type_r0_o          (inst1_imm_type_r0_o ),
    .src_a_sel_r0_o         (inst1_src_a_sel_r0_o),
    .src_b_sel_r0_o         (inst1_src_b_sel_r0_o),
    .use_rs1_r0_o           (inst1_use_rs1_r0_o  ),
    .use_rs2_r0_o           (inst1_use_rs2_r0_o  ),
    .use_rd_r0_o            (inst1_use_rd_r0_o ),
    .write_rd_r0_o          (inst1_write_rd_r0_o ),
    .alu_op_r0_o            (inst1_alu_op_r0_o  ),
    .rs_id_r0_o             (inst1_rs_id_r0_o   ),
    .illegal_inst_r0_o      (inst1_illegal_r0_o ),
    .memory_inst_r0_o       (inst1_memacc_r0_o )
);

dec_way decoder_way2(
    .inst_i               (buf_dec_inst2_d1    ),
    .rs1_r0_o               (inst2_rs1_r0_o        ),
    .rs2_r0_o               (inst2_rs2_r0_o        ),
    .rd_r0_o                (inst2_rd_r0_o         ),
    .imm_type_r0_o          (inst2_imm_type_r0_o   ),
    .src_a_sel_r0_o         (inst2_src_a_sel_r0_o  ),
    .src_b_sel_r0_o         (inst2_src_b_sel_r0_o  ),
    .use_rs1_r0_o           (inst2_use_rs1_r0_o    ),
    .use_rs2_r0_o           (inst2_use_rs2_r0_o    ),
    .use_rd_r0_o            (inst2_use_rd_r0_o ),
    .write_rd_r0_o          (inst2_write_rd_r0_o ),
    .alu_op_r0_o            (inst2_alu_op_r0_o  ),
    .rs_id_r0_o             (inst2_rs_id_r0_o   ),
    .illegal_inst_r0_o      (inst2_illegal_r0_o ),
    .memory_inst_r0_o       (inst2_memacc_r0_o )
);

dec_way decoder_way3(
    .inst_i               (buf_dec_inst3_d1    ),
    .rs1_r0_o               (inst3_rs1_r0_o        ),
    .rs2_r0_o               (inst3_rs2_r0_o        ),
    .rd_r0_o                (inst3_rd_r0_o         ),
    .imm_type_r0_o          (inst3_imm_type_r0_o   ),
    .src_a_sel_r0_o         (inst3_src_a_sel_r0_o  ),
    .src_b_sel_r0_o         (inst3_src_b_sel_r0_o  ),
    .use_rs1_r0_o           (inst3_use_rs1_r0_o    ),
    .use_rs2_r0_o           (inst3_use_rs2_r0_o    ),
    .use_rd_r0_o            (inst3_use_rd_r0_o ),
    .write_rd_r0_o          (inst3_write_rd_r0_o ),
    .alu_op_r0_o            (inst3_alu_op_r0_o  ),
    .rs_id_r0_o             (inst3_rs_id_r0_o   ),
    .illegal_inst_r0_o      (inst3_illegal_r0_o ),
    .memory_inst_r0_o       (inst3_memacc_r0_o )
);

endmodule
