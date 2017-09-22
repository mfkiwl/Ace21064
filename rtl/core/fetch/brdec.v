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
  input wire         pc_f1,
  input wire [31:0]  inst7_i,     // fetched instructions
  input wire [31:0]  inst6_i,
  input wire [31:0]  inst5_i,
  input wire [31:0]  inst4_i,
  input wire [31:0]  inst3_i,
  input wire [31:0]  inst2_i,
  input wire [31:0]  inst1_i,
  input wire [31:0]  inst0_i,
  input wire [63:0]  ras_data_i,
  input wire         valid_override_i,
  // outputs
  output reg  [63:0] ras_data_o,
  output reg  [ 1:0] ras_ctrl_o,
  output wire        br_exist_o,
  output wire        btb_we_o,
  output wire [2:0]  btb_br_pos_o,
  output reg  [1:0]  btb_br_typ_o,
  output reg  [63:0] btb_br_tar_o,
  output reg  [7:0]  inst_valid_o
);
  // internal vars
  wire [ 7:0] br_flag; // indicates this inst is an branch instruction.
  wire [ 1:0] type7, type6, type5, type4, type3, type2, type1, type0;
  wire [ 1:0] ras_ctl7, ras_ctl6, ras_ctl5, ras_ctl4, ras_ctl3, ras_ctl2, ras_ctl1, ras_ctl0;
  wire [63:0] ta7, ta6, ta5, ta4, ta3, ta2, ta1, ta0;
  reg  [ 2:0] br_pos;

  wire pc0_i[63:0] = pc_f1 + 64'h00;
  wire pc1_i[63:0] = pc_f1 + 64'h04;
  wire pc2_i[63:0] = pc_f1 + 64'h08;
  wire pc3_i[63:0] = pc_f1 + 64'h0c;
  wire pc4_i[63:0] = pc_f1 + 64'h10;
  wire pc5_i[63:0] = pc_f1 + 64'h14;
  wire pc6_i[63:0] = pc_f1 + 64'h18;
  wire pc7_i[63:0] = pc_f1 + 64'h1c;


  brdec_way brdec_way0(
  .inst_i             (inst0_i),
  .pc_f1_i            (pc0_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[0]),
  .br_typ_o           (type0),
  .br_tar_o           (ta0),
  .ras_ctl_o          (ras_ctl0));

  brdec_way brdec_way1(
  .inst_i             (inst1_i),
  .pc_f1_i            (pc1_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[1]),
  .br_typ_o           (type1),
  .br_tar_o           (ta1),
  .ras_ctl_o          (ras_ctl1));

  brdec_way brdec_way2(
  .inst_i             (inst2_i),
  .pc_f1_i            (pc2_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[2]),
  .br_typ_o           (type2),
  .br_tar_o           (ta2),
  .ras_ctl_o          (ras_ctl2));

  brdec_way brdec_way3(
  .inst_i             (inst3_i),
  .pc_f1_i            (pc3_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[3]),
  .br_typ_o           (type3),
  .br_tar_o           (ta3),
  .ras_ctl_o          (ras_ctl3));

  brdec_way brdec_way4(
  .inst_i             (inst4_i),
  .pc_f1_i            (pc4_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[4]),
  .br_typ_o           (type4),
  .br_tar_o           (ta4),
  .ras_ctl_o          (ras_ctl4));

  brdec_way brdec_way5(
  .inst_i             (inst5_i),
  .pc_f1_i            (pc5_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[5]),
  .br_typ_o           (type5),
  .br_tar_o           (ta5),
  .ras_ctl_o          (ras_ctl5));

  brdec_way brdec_way6(
  .inst_i             (inst6_i),
  .pc_f1_i            (pc6_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[6]),
  .br_typ_o           (type6),
  .br_tar_o           (ta6),
  .ras_ctl_o          (ras_ctl6));

  brdec_way brdec_way7(
  .inst_i             (inst7_i),
  .pc_f1_i            (pc7_i),
  .ras_data_i         (ras_data_i),
  .br_flag_o          (br_flag[7]),
  .br_typ_o           (type7),
  .br_tar_o           (ta7),
  .ras_ctl_o          (ras_ctl7));


  // encoder

  always @ (*)
  begin
    casez ({valid_override_i,br_flag})   // only one branch instruction is permitted in one fetch bundle
      9'b1???????? : begin 
                       br_pos       = 3'b000;
                       inst_valid_o = 8'b00000000;
                     end 
      9'b000000001 : begin 
                       br_pos       = 3'b000;
                       inst_valid_o = 8'b00000001;
                     end
      9'b00000001? : begin
                       br_pos       = 3'b001;
                       inst_valid_o = 8'b00000011;
                     end
      9'b0000001?? : begin
                       br_pos       = 3'b010;
                       inst_valid_o = 8'b00000111;
                     end
      9'b000001??? : begin
                       br_pos       = 3'b011;
                       inst_valid_o = 8'b00001111;
                     end
      9'b00001???? : begin
                       br_pos       = 3'b100;
                       inst_valid_o = 8'b00011111;
                     end
      9'b0001????? : begin
                       br_pos       = 3'b101;
                       inst_valid_o = 8'b00111111;
                     end
      9'b001?????? : begin
                       br_pos       = 3'b110;
                       inst_valid_o = 8'b01111111;
                     end
      9'b01??????? : begin
                       br_pos       = 3'b111;
                       inst_valid_o = 8'b11111111;
                     end
      default      : begin
                       br_pos       = 3'b000;
                       inst_valid_o = 8'b11111111;
                     end
    endcase
  end


  always @ (*)
  begin
    case (br_pos)
      3'b000: begin
                btb_br_typ_o = type0;
                btb_br_tar_o = ta0;
                ras_ctrl_o   = ras_ctl0;
                ras_data_o   = pc0_i;
              end
      3'b001: begin
                btb_br_typ_o = type1;
                btb_br_tar_o = ta1;
                ras_ctrl_o   = ras_ctl1;
                ras_data_o   = pc1_i;
              end
      3'b010: begin
                btb_br_typ_o = type2;
                btb_br_tar_o = ta2;
                ras_ctrl_o   = ras_ctl2;
                ras_data_o   = pc2_i;
              end
      3'b011: begin
                btb_br_typ_o = type3;
                btb_br_tar_o = ta3;
                ras_ctrl_o   = ras_ctl3;
                ras_data_o   = pc3_i;
              end
      3'b100: begin
                btb_br_typ_o = type4;
                btb_br_tar_o = ta4;
                ras_ctrl_o   = ras_ctl4;
                ras_data_o   = pc4_i;
              end
      3'b101: begin
                btb_br_typ_o = type5;
                btb_br_tar_o = ta5;
                ras_ctrl_o   = ras_ctl5;
                ras_data_o   = pc5_i;
              end
      3'b110: begin
                btb_br_typ_o = type6;
                btb_br_tar_o = ta6;
                ras_ctrl_o   = ras_ctl6;
                ras_data_o   = pc6_i;
              end
      3'b111: begin
                btb_br_typ_o = type7;
                btb_br_tar_o = ta7;
                ras_ctrl_o   = ras_ctl7;
                ras_data_o   = pc7_i;
              end
      default:begin
              end
    endcase
  end

  assign btb_we_o     = |br_flag && !valid_override_i;
  assign br_exist_o   = |br_flag & ~valid_override_i;
  assign btb_br_pos_o = br_pos;

endmodule
