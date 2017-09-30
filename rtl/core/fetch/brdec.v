//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : brdec.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains 8 br_flag decoders and produces the values to
//                be written into the BTB for a packet of insts           
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module brdec (
  input  wire [63:0] pc_f1_i,
  input  wire [31:0] inst0_i,     // fetched instructions
  input  wire [31:0] inst1_i,
  input  wire [31:0] inst2_i,
  input  wire [31:0] inst3_i,
  input  wire [31:0] inst4_i,
  input  wire [31:0] inst5_i,
  input  wire [31:0] inst6_i,
  input  wire [31:0] inst7_i,
  input  wire [63:0] ras_pcdata_f0_i,
  input  wire        flush_vld_i,
  output reg  [63:0] brdec_rasdat_f1_o,
  output reg  [ 1:0] brdec_rasctl_f1_o,
  output wire        brdec_brext_f1_o,
  output wire [ 2:0] brdec_brpos_f1_o,
  output reg  [ 1:0] brdec_brtyp_f1_o,
  output reg  [63:0] brdec_brtar_f1_o,
  output reg  [ 7:0] brdec_instvld_f1_o
);
  // internal vars
  wire [ 7:0] br_flag; // indicates this inst is an branch instruction.
  wire [ 1:0] type7, type6, type5, type4, type3, type2, type1, type0;
  wire [ 1:0] ras_ctl7, ras_ctl6, ras_ctl5, ras_ctl4, ras_ctl3, ras_ctl2, ras_ctl1, ras_ctl0;
  wire [63:0] ta7, ta6, ta5, ta4, ta3, ta2, ta1, ta0;
  reg  [ 2:0] br_pos;

  wire pc0_i[63:0] = pc_f1_i + 64'h00;
  wire pc1_i[63:0] = pc_f1_i + 64'h04;
  wire pc2_i[63:0] = pc_f1_i + 64'h08;
  wire pc3_i[63:0] = pc_f1_i + 64'h0c;
  wire pc4_i[63:0] = pc_f1_i + 64'h10;
  wire pc5_i[63:0] = pc_f1_i + 64'h14;
  wire pc6_i[63:0] = pc_f1_i + 64'h18;
  wire pc7_i[63:0] = pc_f1_i + 64'h1c;


  brdec_way brdec_way0(
  .inst_i             (inst0_i),
  .pc_f1_i            (pc0_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[0]),
  .br_typ_o           (type0),
  .br_tar_o           (ta0),
  .ras_ctl_o          (ras_ctl0));

  brdec_way brdec_way1(
  .inst_i             (inst1_i),
  .pc_f1_i            (pc1_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[1]),
  .br_typ_o           (type1),
  .br_tar_o           (ta1),
  .ras_ctl_o          (ras_ctl1));

  brdec_way brdec_way2(
  .inst_i             (inst2_i),
  .pc_f1_i            (pc2_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[2]),
  .br_typ_o           (type2),
  .br_tar_o           (ta2),
  .ras_ctl_o          (ras_ctl2));

  brdec_way brdec_way3(
  .inst_i             (inst3_i),
  .pc_f1_i            (pc3_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[3]),
  .br_typ_o           (type3),
  .br_tar_o           (ta3),
  .ras_ctl_o          (ras_ctl3));

  brdec_way brdec_way4(
  .inst_i             (inst4_i),
  .pc_f1_i            (pc4_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[4]),
  .br_typ_o           (type4),
  .br_tar_o           (ta4),
  .ras_ctl_o          (ras_ctl4));

  brdec_way brdec_way5(
  .inst_i             (inst5_i),
  .pc_f1_i            (pc5_i),
  .ras_data_i(ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[5]),
  .br_typ_o           (type5),
  .br_tar_o           (ta5),
  .ras_ctl_o          (ras_ctl5));

  brdec_way brdec_way6(
  .inst_i             (inst6_i),
  .pc_f1_i            (pc6_i),
  .ras_data_i         (ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[6]),
  .br_typ_o           (type6),
  .br_tar_o           (ta6),
  .ras_ctl_o          (ras_ctl6));

  brdec_way brdec_way7(
  .inst_i             (inst7_i),
  .pc_f1_i            (pc7_i),
  .ras_data_i         (ras_pcdata_f0_i         ),
  .rs1_data_i         (),
  .rs1_idx_o          (),
  .rs1_req_o          (),
  .br_flag_o          (br_flag[7]),
  .br_typ_o           (type7),
  .br_tar_o           (ta7),
  .ras_ctl_o          (ras_ctl7));


  // encoder

  always @ (*)
  begin
    casez ({flush_vld_i,br_flag})   // only one branch instruction is permitted in one fetch bundle
      9'b1???????? : begin 
                       br_pos       = 3'b000;
                       brdec_instvld_f1_o = 8'b00000000;
                     end 
      9'b000000001 : begin 
                       br_pos       = 3'b000;
                       brdec_instvld_f1_o = 8'b00000001;
                     end
      9'b00000001? : begin
                       br_pos       = 3'b001;
                       brdec_instvld_f1_o = 8'b00000011;
                     end
      9'b0000001?? : begin
                       br_pos       = 3'b010;
                       brdec_instvld_f1_o = 8'b00000111;
                     end
      9'b000001??? : begin
                       br_pos       = 3'b011;
                       brdec_instvld_f1_o = 8'b00001111;
                     end
      9'b00001???? : begin
                       br_pos       = 3'b100;
                       brdec_instvld_f1_o = 8'b00011111;
                     end
      9'b0001????? : begin
                       br_pos       = 3'b101;
                       brdec_instvld_f1_o = 8'b00111111;
                     end
      9'b001?????? : begin
                       br_pos       = 3'b110;
                       brdec_instvld_f1_o = 8'b01111111;
                     end
      9'b01??????? : begin
                       br_pos       = 3'b111;
                       brdec_instvld_f1_o = 8'b11111111;
                     end
      default      : begin
                       br_pos       = 3'b000;
                       brdec_instvld_f1_o = 8'b11111111;
                     end
    endcase
  end


  always @ (*)
  begin
    case (br_pos)
      3'b000: begin
                brdec_brtyp_f1_o = type0;
                brdec_brtar_f1_o = ta0;
                brdec_rasctl_f1_o   = ras_ctl0;
                brdec_rasdat_f1_o   = pc0_i;
              end
      3'b001: begin
                brdec_brtyp_f1_o = type1;
                brdec_brtar_f1_o = ta1;
                brdec_rasctl_f1_o   = ras_ctl1;
                brdec_rasdat_f1_o   = pc1_i;
              end
      3'b010: begin
                brdec_brtyp_f1_o = type2;
                brdec_brtar_f1_o = ta2;
                brdec_rasctl_f1_o   = ras_ctl2;
                brdec_rasdat_f1_o   = pc2_i;
              end
      3'b011: begin
                brdec_brtyp_f1_o = type3;
                brdec_brtar_f1_o = ta3;
                brdec_rasctl_f1_o   = ras_ctl3;
                brdec_rasdat_f1_o   = pc3_i;
              end
      3'b100: begin
                brdec_brtyp_f1_o = type4;
                brdec_brtar_f1_o = ta4;
                brdec_rasctl_f1_o   = ras_ctl4;
                brdec_rasdat_f1_o   = pc4_i;
              end
      3'b101: begin
                brdec_brtyp_f1_o = type5;
                brdec_brtar_f1_o = ta5;
                brdec_rasctl_f1_o   = ras_ctl5;
                brdec_rasdat_f1_o   = pc5_i;
              end
      3'b110: begin
                brdec_brtyp_f1_o = type6;
                brdec_brtar_f1_o = ta6;
                brdec_rasctl_f1_o   = ras_ctl6;
                brdec_rasdat_f1_o   = pc6_i;
              end
      3'b111: begin
                brdec_brtyp_f1_o = type7;
                brdec_brtar_f1_o = ta7;
                brdec_rasctl_f1_o   = ras_ctl7;
                brdec_rasdat_f1_o   = pc7_i;
              end
      default:begin
              end
    endcase
  end

  assign brdec_brext_f1_o     = |br_flag && !flush_vld_i;
  assign brdec_brpos_f1_o = br_pos;

endmodule
