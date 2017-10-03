//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : brdec_way.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains the module definition for a branch decoder.
//                Eight of these are used in fetch 1 to determine the target
//                and other information about a branch.
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module brdec_way(
  input wire  [31:0]      inst_i,
  input wire  [63:0]      pc_f1_i,
  input wire  [63:0]      ras_data_i,

  output reg              br_flag_o,
  output reg  [ 1:0]      br_typ_o,
  output reg  [63:0]      br_tar_o,
  output reg  [ 1:0]      ras_ctl_o
);

  localparam RAS_NOACT    = 2'b00;
  localparam RAS_PUSHPC   = 2'b01;
  localparam RAS_POPPC    = 2'b10;
  localparam RAS_POPPUSH  = 2'b11;

  wire [ 6:0]   opcode;
  wire [ 2:0]   funct3;
  wire [11:0]   funct12;
  wire [63:0]   br_offset_s;    // conditional branch signed offset
  wire [63:0]   br_offset_u;    // conditional branch unsigned offset 
  wire [63:0]   jal_offset_s;   // unconditional jump signed offset 
  wire [63:0]   jalr_offset_s;  // unconditional jump signed offset 

  assign opcode        = inst_i[ 6: 0];
  assign funct3        = inst_i[14:12];
  assign funct12       = inst_i[31:20];
  assign br_offset_s   = {{52{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
  assign br_offset_u   = {{51{1'b0}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
  assign jal_offset_s  = {{44{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
  assign jalr_offset_s = {{52{inst_i[31]}},inst_i[31:20]};

  always @ *
  begin
      br_flag_o  = 1'b0;
      br_typ_o   = 2'b00;
      br_tar_o   = 64'b0;
      ras_ctl_o  = 2'b00;

      case (opcode)
        // conditional branches
        // BEQ/BNE/BLT/BLTU/BGE/BGEU
        `RV32I_BRANCH: begin
                         br_typ_o      = `BR_COND;
                         ras_ctl_o     = 2'b00; // RAS no action
                         case(funct3)
                           `RV32I_FUNCT3_BEQ,
                           `RV32I_FUNCT3_BNE,
                           `RV32I_FUNCT3_BLT,
                           `RV32I_FUNCT3_BGE:  begin
                                                 br_flag_o = 1'b1;
                                                 br_tar_o  = pc_f1_i + br_offset_u;
                                               end
                           `RV32I_FUNCT3_BLTU,
                           `RV32I_FUNCT3_BGEU: begin
                                                 br_flag_o = 1'b1;
                                                 br_tar_o  = pc_f1_i + br_offset_s;
                                               end
                           default:            begin // 2 reserved funct3 encode
                                                 br_flag_o = 1'b0; 
                                                 br_tar_o  = 64'b0;
                                               end
                         endcase
                       end
        // unconditional jumps
        // JAL/JALR
        `RV32I_JAL:  begin
                       br_flag_o       = 1'b1;
                       br_typ_o        = `BR_UNCOND;
                       br_tar_o        = pc_f1_i + jal_offset_s;
                       ras_ctl_o       = 2'b01;	// RAS: push PC (near call) 
                     end
        `RV32I_JALR: begin
                       br_flag_o       = 1'b1;
                       br_typ_o        = `BR_INDIR;
                       //br_tar_o        = rs1_data_i + jalr_offset_s;
                       br_tar_o        = jalr_offset_s; // this br_tar may not be used
                       ras_ctl_o       = 2'b01;	// RAS: push PC (far call)
                     end
        // user mode system return
        `RV32_SYSTEM:begin
                       if(funct3 == `RV32I_FUNCT3_PRIV && funct12 == `RV32I_FUNCT12_URET)
                       begin
                         br_flag_o     = 1'b1;
                         br_typ_o      = `BR_INDIRRET;
                         br_tar_o      = ras_data_i;
                         ras_ctl_o     = 2'b10;	// RAS: pop 
                       end
                     end
        default:     ; 
      endcase
  end

endmodule
