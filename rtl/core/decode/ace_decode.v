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
    input  wire         flush_i,
    input  wire         rm_inst_i,

    input  wire [31:0]  inst0_i,
    input  wire [31:0]  inst1_i,
    input  wire [31:0]  inst2_i,
    input  wire [31:0]  inst3_i,
    input  wire [31:0]  inst4_i,
    input  wire [31:0]  inst5_i,
    input  wire [31:0]  inst6_i,
    input  wire [31:0]  inst7_i,
    input  wire         inst0_vld_i,
    input  wire         inst1_vld_i,
    input  wire         inst2_vld_i,
    input  wire         inst3_vld_i,
    input  wire         inst4_vld_i,
    input  wire         inst5_vld_i,
    input  wire         inst6_vld_i,
    input  wire         inst7_vld_i,

    output wire [4:0]   inst0_rs1,
    output wire [4:0]   inst0_rs2,
    output wire [4:0]   inst0_rd,
    output wire [1:0]   inst0_imm_type,
    output wire [1:0]   inst0_src_a_sel,// select alu operands
    output wire [1:0]   inst0_src_b_sel,
    output wire         inst0_uses_rs1,
    output wire         inst0_uses_rs2,
    output wire         inst0_need_rd,
    output wire [3:0]   inst0_alu_op,
    output wire         inst0_rs_id,    // reservation station id
    output wire         inst0_illegal,

    output wire [4:0]   inst1_rs1,
    output wire [4:0]   inst1_rs2,
    output wire [4:0]   inst1_rd,
    output wire [1:0]   inst1_imm_type,
    output wire [1:0]   inst1_src_a_sel,// select alu operands
    output wire [1:0]   inst1_src_b_sel,
    output wire         inst1_uses_rs1,
    output wire         inst1_uses_rs2,
    output wire         inst1_need_rd,
    output wire [3:0]   inst1_alu_op,
    output wire         inst1_rs_id,    // reservation station id
    output wire         inst1_illegal,

    output wire [4:0]   inst2_rs1,
    output wire [4:0]   inst2_rs2,
    output wire [4:0]   inst2_rd,
    output wire [1:0]   inst2_imm_type,
    output wire [1:0]   inst2_src_a_sel,// select alu operands
    output wire [1:0]   inst2_src_b_sel,
    output wire         inst2_uses_rs1,
    output wire         inst2_uses_rs2,
    output wire         inst2_need_rd,
    output wire [3:0]   inst2_alu_op,
    output wire         inst2_rs_id,    // reservation station id
    output wire         inst2_illegal,

    output wire [4:0]   inst3_rs1,
    output wire [4:0]   inst3_rs2,
    output wire [4:0]   inst3_rd,
    output wire [1:0]   inst3_imm_type,
    output wire [1:0]   inst3_src_a_sel,// select alu operands
    output wire [1:0]   inst3_src_b_sel,
    output wire         inst3_uses_rs1,
    output wire         inst3_uses_rs2,
    output wire         inst3_need_rd,
    output wire [3:0]   inst3_alu_op,
    output wire         inst3_rs_id,    // reservation station id
    output wire         inst3_illegal
);

wire [31:0]   buf_dec_inst0;
wire [31:0]   buf_dec_inst1;
wire [31:0]   buf_dec_inst2;
wire [31:0]   buf_dec_inst3;

inst_buf i_inst_buf(
    .clock              (clock              ),
    .reset_n            (reset_n            ),
    .flush_i            (flush_i            ),
    .rm_inst_i          (rm_inst_i          ),
    .inst0_i            (inst0_i            ),
    .inst1_i            (inst1_i            ),
    .inst2_i            (inst2_i            ),
    .inst3_i            (inst3_i            ),
    .inst4_i            (inst4_i            ),
    .inst5_i            (inst5_i            ),
    .inst6_i            (inst6_i            ),
    .inst7_i            (inst7_i            ),
    .inst0_vld_i        (inst0_vld_i        ),
    .inst1_vld_i        (inst1_vld_i        ),
    .inst2_vld_i        (inst2_vld_i        ),
    .inst3_vld_i        (inst3_vld_i        ),
    .inst4_vld_i        (inst4_vld_i        ),
    .inst5_vld_i        (inst5_vld_i        ),
    .inst6_vld_i        (inst6_vld_i        ),
    .inst7_vld_i        (inst7_vld_i        ),
    .buf_inst0_o        (buf_dec_inst0      ),
    .buf_inst1_o        (buf_dec_inst1      ),
    .buf_inst2_o        (buf_dec_inst2      ),
    .buf_inst3_o        (buf_dec_inst3      ),
    .buf_full_o         (buf_full_o         ),
    .buf_empty_o        (buf_empty_o        )
);


decoder inst_decoder0(
    .inst_i               (buf_dec_inst0  ),
    .rs1_o                (inst0_rs1      ),
    .rs2_o                (inst0_rs2      ),
    .rd_o                 (inst0_rd       ),
    .imm_type_o           (inst0_imm_type ),
    .src_a_sel_o          (inst0_src_a_sel),
    .src_b_sel_o          (inst0_src_b_sel),
    .uses_rs1_o           (inst0_uses_rs1 ),
    .uses_rs2_o           (inst0_uses_rs2 ),
    .need_rd_o            (inst0_need_rd  ),
    .alu_op_o             (inst0_alu_op   ),
    .rs_id_o              (inst0_rs_id    ),
    .illegal_inst_o       (inst0_illegal  )
);

decoder inst_decoder1(
    .inst_i               (buf_dec_inst1  ),
    .rs1_o                (inst1_rs1      ),
    .rs2_o                (inst1_rs2      ),
    .rd_o                 (inst1_rd       ),
    .imm_type_o           (inst1_imm_type ),
    .src_a_sel_o          (inst1_src_a_sel),
    .src_b_sel_o          (inst1_src_b_sel),
    .uses_rs1_o           (inst1_uses_rs1 ),
    .uses_rs2_o           (inst1_uses_rs2 ),
    .need_rd_o            (inst1_need_rd  ),
    .alu_op_o             (inst1_alu_op   ),
    .rs_id_o              (inst1_rs_id    ),
    .illegal_inst_o       (inst1_illegal  )
);

decoder inst_decoder2(
    .inst_i               (buf_dec_inst2  ),
    .rs1_o                (inst2_rs1      ),
    .rs2_o                (inst2_rs2      ),
    .rd_o                 (inst2_rd       ),
    .imm_type_o           (inst2_imm_type ),
    .src_a_sel_o          (inst2_src_a_sel),
    .src_b_sel_o          (inst2_src_b_sel),
    .uses_rs1_o           (inst2_uses_rs1 ),
    .uses_rs2_o           (inst2_uses_rs2 ),
    .need_rd_o            (inst2_need_rd  ),
    .alu_op_o             (inst2_alu_op   ),
    .rs_id_o              (inst2_rs_id    ),
    .illegal_inst_o       (inst2_illegal  )
);

decoder inst_decoder3(
    .inst_i               (buf_dec_inst3  ),
    .rs1_o                (inst3_rs1      ),
    .rs2_o                (inst3_rs2      ),
    .rd_o                 (inst3_rd       ),
    .imm_type_o           (inst3_imm_type ),
    .src_a_sel_o          (inst3_src_a_sel),
    .src_b_sel_o          (inst3_src_b_sel),
    .uses_rs1_o           (inst3_uses_rs1 ),
    .uses_rs2_o           (inst3_uses_rs2 ),
    .need_rd_o            (inst3_need_rd  ),
    .alu_op_o             (inst3_alu_op   ),
    .rs_id_o              (inst3_rs_id    ),
    .illegal_inst_o       (inst3_illegal  )
);

endmodule
