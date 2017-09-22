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
  input wire [31:0]      inst_i,
  input wire [63:0]      pc_f1_i,
  input wire [63:0]      ras_data_i,

  output reg             br_flag_o,
  output reg [ 1:0]      br_typ_o,
  output reg [63:0]      br_tar_o,
  output reg [ 1:0]      ras_ctl_o
);
  wire [5:0]   opcode;
  wire [20:0]  disp;
  wire [1:0]   jmpType;
  wire [13:0]  jmpDisp;

  assign opcode  = inst_i[6:0];
  assign disp    = inst_i[20:0];
  assign jmpType = inst_i[15:14];
  assign jmpDisp = inst_i[13:0];


  // if the instruction is not a branch, set br_flag_o to 0
  // otherwise, set br_flag_o to 1 and calculate the other values
  always @ *
  begin
    case (opcode)
      // conditional branches
      // target = PC + 4 * sext(disp)
      6'h39, 6'h3e, 6'h3f, 6'h38, 6'h3c, 6'h3b, 6'h3a, 6'h3d: begin
        br_flag_o       = 1'b1;
        br_typ_o   = `BR_COND;
        br_tar_o = pc_f1_i + sext23({disp,2'b0});
        ras_ctl_o     = 2'b00;
      end
      // unconditional branches
      // the target address = PC = 4 * sext(disp)
      6'h30, 6'h34: begin
        br_flag_o       = 1'b1;
        br_typ_o   = `BR_UNCOND;
        br_tar_o = pc_f1_i + sext23({disp,2'b0});
        if (opcode == 6'h30)
          ras_ctl_o     = 2'b00;
        else
          ras_ctl_o     = 2'b01;
      end
      // unconditional jumps
      // for JMP and JSR, the predicted target = PC + 4 * sext(disp)
      // for RET and JSR_COROUTINE, the predicted target is the top of the RAS
      `RV32I_JAL: begin
            br_flag_o       = 1'b1;
            br_typ_o   = `BR_INDIR_PC;
            br_tar_o = pc_f1_i + sext16({disp[13:0],2'b0});
            ras_ctl_o     = 2'b00;	// RAS: no action
          end
          // JSR
          2'b01: begin
            br_flag_o       = 1'b1;
            br_typ_o   = `BR_INDIR_PC;
            br_tar_o = pc_f1_i + sext16({disp[13:0],2'b0});
            ras_ctl_o     = 2'b01;	// RAS: push PC
          end
          // RET
          2'b10: begin
            br_flag_o       = 1'b1;
            br_typ_o   = `BR_INDIR_RAS;
            br_tar_o = ras_data_i;
            ras_ctl_o     = 2'b10;	// RAS: pop
          end
          // JSR_COROUTINE
          2'b11: begin
            br_flag_o       = 1'b1;
            br_typ_o   = `BR_INDIR_RAS;
            br_tar_o = ras_data_i;
            ras_ctl_o     = 2'b11;	// RAS: pop, push PC
          end
        endcase // case (jmpType)
      end
      default: begin
        br_flag_o       = 1'b0;
        br_typ_o   = 2'b00;
        br_tar_o = 64'b0;
        ras_ctl_o     = 2'b00;
      end
    endcase // case (opcode)
  end

endmodule
