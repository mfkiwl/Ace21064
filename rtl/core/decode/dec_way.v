//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : dec_way.v
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

module dec_way(
    input  wire [31:0]      inst_i,

    output wire [4:0]       rs1_o,
    output wire [4:0]       rs2_o,
    output wire [4:0]       rd_o,
    output reg  [1:0]       imm_type_o,
    output reg  [1:0]       src_a_sel_o,// select alu operands
    output reg  [1:0]       src_b_sel_o,
    
    output reg              use_rs1_o,
    output reg              use_rs2_o,
    output reg              need_rd_o,
    // branch_inst
    // simple_alu
    // complex_alu
    // multiply
    // memroy_inst
    // cond_br
    // uncond_br
    // indirect_br

    output reg [3:0]        alu_op_o,
    output reg              rs_id_o,             // reservation station id
    output reg              illegal_inst_o
);

   wire [ 6:0]              opcode;
   wire [ 2:0]              funct3;
   wire [ 6:0]              funct7;
   wire [11:0]              funct12;
   reg  [ 3:0]              alu_op_arith;
   
   assign opcode      = inst_i[ 6: 0];
   assign funct3      = inst_i[14:12];
   assign funct7      = inst_i[31:25];
   assign funct12     = inst_i[31:20];
   assign rd_o        = inst_i[11: 7];
   assign rs1_o       = inst_i[19:15];
   assign rs2_o       = inst_i[24:20];
   
   always @ *
   begin
       rs_id_o               = `RESERVATION_STATION0;
       imm_type_o            = `IMM_I;
       src_a_sel_o           = `SRC_A_RS1;
       src_b_sel_o           = `SRC_B_IMM;
       need_rd_o             = 1'b0;
       use_rs1_o            = 1'b1;
       use_rs2_o            = 1'b0;
       alu_op_o              = `ALU_OP_ADD;
       illegal_inst_o = 1'b0;
      
      case (opcode)
      `RV32_LOAD :    begin
                          rs_id_o = `RESERVATION_STATION1;
                          need_rd_o = 1'b1;
                      end
      `RV32_STORE :   begin
                          rs_id_o = `RESERVATION_STATION1;
                          use_rs2_o = 1'b1;
                          imm_type_o = `IMM_S;
                      end
      // conditional branches
      `RV32I_BRANCH : begin
                         rs_id_o = `RESERVATION_STATION1;
                         use_rs2_o = 1'b1;
                         src_b_sel_o = `SRC_B_RS2;
                         case (funct3)
                           `RV32I_FUNCT3_BEQ  : alu_op_o = `ALU_OP_SEQ;
                           `RV32I_FUNCT3_BNE  : alu_op_o = `ALU_OP_SNE;
                           `RV32I_FUNCT3_BLT  : alu_op_o = `ALU_OP_SLT;
                           `RV32I_FUNCT3_BLTU : alu_op_o = `ALU_OP_SLTU;
                           `RV32I_FUNCT3_BGE  : alu_op_o = `ALU_OP_SGE;
                           `RV32I_FUNCT3_BGEU : alu_op_o = `ALU_OP_SGEU;
                           default : illegal_inst_o = 1'b1;
                         endcase
                     end

      // unconditional branches
      `RV32I_JAL :   begin
                         rs_id_o = `RESERVATION_STATION1;
                         use_rs1_o = 1'b0;
                         src_a_sel_o = `SRC_A_PC;
                         src_b_sel_o = `SRC_B_FOUR;
                         need_rd_o = 1'b1;
                     end
      `RV32I_JALR :  begin
                         rs_id_o = `RESERVATION_STATION1;
                         src_a_sel_o = `SRC_A_PC;
                         src_b_sel_o = `SRC_B_FOUR;
                         need_rd_o = 1'b1;
                         illegal_inst_o = (funct3 != 0);
                     end
/*
      `RV32I_FENCE :
      begin
           case (funct3)
           `RV32_FUNCT3_FENCE : begin
                   if ((inst_i[31:28] == 0) && (rs1_o == 0) && (reg_to_wr_DX == 0))
                     ; // most fences are no-ops
                   else
                     illegal_inst_o = 1'b1;
           end
           `RV32_FUNCT3_FENCE_I : begin
           if ((inst_i[31:20] == 0) && (rs1_o == 0) && (reg_to_wr_DX == 0))
                     fence_i = 1'b1;
           else
                     illegal_inst_o = 1'b1;
           end
           default : illegal_inst_o = 1'b1;
           endcase
      end
*/
      `RV32_ALU_IMM: begin
                         need_rd_o = 1'b1;
                         alu_op_o = alu_op_arith;
                     end
      `RV32_ALU :    begin
                         use_rs2_o = 1'b1;
                         src_b_sel_o = `SRC_B_RS2;
                         alu_op_o = alu_op_arith;
                         need_rd_o = 1'b1;
                     end
/*
      `RV32I_SYSTEM : begin
         wb_src_sel_DX = `WB_SRC_CSR;
         need_rd_o = (funct3 != `RV32I_FUNCT3_PRIV);
         case (funct3)
           `RV32I_FUNCT3_PRIV : begin
              if ((rs1_o == 0) && (reg_to_wr_DX == 0)) begin
                 case (funct12)
                   `RV32I_FUNCT12_ECALL : ecall = 1'b1;
                   `RV32I_FUNCT12_EBREAK : ebreak = 1'b1;
                   `RV32I_FUNCT12_ERET : begin
                      if (prv == 0)
                        illegal_inst_o = 1'b1;
                      else
                        eret_unkilled = 1'b1;
                   end
                   default : illegal_inst_o = 1'b1;
                 endcase
              end
           end
           `RV32I_FUNCT3_CSRRW : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_WRITE;
           `RV32I_FUNCT3_CSRRS : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_SET;
           `RV32I_FUNCT3_CSRRC : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_CLEAR;
           `RV32I_FUNCT3_CSRRWI : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_WRITE;
           `RV32I_FUNCT3_CSRRSI : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_SET;
           `RV32I_FUNCT3_CSRRCI : csr_cmd = (rs1_o == 0) ? `CSR_READ : `CSR_CLEAR;
           default : illegal_inst_o = 1'b1;
         endcase
      end
*/
     `RV32I_AUIPC: begin
                      use_rs1_o = 1'b0;
                      src_a_sel_o = `SRC_A_PC;
                      imm_type_o = `IMM_U;
                      need_rd_o = 1'b1;
                   end
     `RV32I_LUI :  begin
                      use_rs1_o = 1'b0;
                      src_a_sel_o = `SRC_A_ZERO;
                      imm_type_o = `IMM_U;
                      need_rd_o = 1'b1;
                   end
     default :     illegal_inst_o = 1'b1;
     endcase
   end

   // RV32I arithmatic function decode
   always @ *
   begin
       case (funct3)
           `RV32I_FUNCT3_ADD_SUB : alu_op_arith = ((opcode == `RV32_ALU) && (funct7[5])) ?
                                                  `ALU_OP_SUB : `ALU_OP_ADD;
           `RV32I_FUNCT3_SLL     : alu_op_arith = `ALU_OP_SLL;
           `RV32I_FUNCT3_SLT     : alu_op_arith = `ALU_OP_SLT;
           `RV32I_FUNCT3_SLTU    : alu_op_arith = `ALU_OP_SLTU;
           `RV32I_FUNCT3_XOR     : alu_op_arith = `ALU_OP_XOR;
           `RV32I_FUNCT3_SRA_SRL : alu_op_arith = (funct7[5]) ?
                                                  `ALU_OP_SRA : `ALU_OP_SRL;
           `RV32I_FUNCT3_OR      : alu_op_arith = `ALU_OP_OR;
           `RV32I_FUNCT3_AND     : alu_op_arith = `ALU_OP_AND;
           default               : alu_op_arith = `ALU_OP_ADD;
       endcase
   end

   // RV32I/RV64I load operation decode
   always @ *
   begin
       case (funct3)
           `RV32I_FUNCT3_LB:  begin
                              end
           `RV32I_FUNCT3_LH:  begin
                              end
           `RV32I_FUNCT3_LW:  begin
                              end
           `RV64I_FUNCT3_LD:  begin
                              end
           `RV32I_FUNCT3_LBU: begin
                              end
           `RV32I_FUNCT3_LHU: begin
                              end
           `RV64I_FUNCT3_LWU: begin
                              end
           default:;
       endcase
   end

   // RV32I/RV64I store operation decode
   always @ *
   begin
       case (funct3)
           `RV32I_FUNCT3_SB : begin
                              end
           `RV32I_FUNCT3_SH : begin
                              end
           `RV32I_FUNCT3_SW : begin
                              end
           `RV64I_FUNCT3_SD : begin
                              end
           default:;
       endcase
   end

   // RV32M function decode
   always @ *
   begin
       case (funct3)
           `RV32M_FUNCT3_MUL    : begin
                                  end
           `RV32M_FUNCT3_MULH   : begin
                                  end
           `RV32M_FUNCT3_MULHSU : begin
                                  end
           `RV32M_FUNCT3_MULHU  : begin
                                  end
           `RV32M_FUNCT3_DIV    : begin
                                  end
           `RV32M_FUNCT3_DIVU   : begin
                                  end
           `RV32M_FUNCT3_REM    : begin
                                  end
           `RV32M_FUNCT3_REMU   : begin
                                  end
       endcase
   end

endmodule
