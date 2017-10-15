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
    input  wire             clock,
    input  wire             reset_n,
    input  wire             pipe_load_decode_i

    input  wire [31:0]      inst_i,

    output wire [4:0]       rs1_r0_o,
    output wire [4:0]       rs2_r0_o,
    output wire [4:0]       rd_r0_o,
    output reg  [1:0]       imm_type_r0_o,
    output reg  [1:0]       src1_sel_r0_o,// select alu operands
    output reg  [1:0]       src2_sel_r0_o,
    
    output reg              use_rs1_r0_o,
    output reg              use_rs2_r0_o,
    output reg              use_rd_r0_o,
    output reg              write_rd_r0_o,
    output reg [3:0]        alu_op_r0_o,
    output reg              illegal_inst_r0_o
    output reg              memory_inst_r0_o,
    output reg              branch_inst_r0_o,
    output reg              simple_inst_r0_o,
    output reg              complx_inst_r0_o,

    // multiply
    // cond_br
    // uncond_br
    // indirect_br

);

   wire [ 6:0]              opcode;
   wire [ 2:0]              funct3;
   wire [ 6:0]              funct7;
   wire [11:0]              funct12;
   reg  [ 3:0]              alu_op_arith;
   
   reg  [ 1:0]              imm_type;
   reg  [ 1:0]              src1_sel;
   reg  [ 1:0]              src2_sel;
   reg                      use_rs1;
   reg                      use_rs2;
   reg                      use_rd;
   reg                      write_rd;
   reg  [ 3:0]              alu_op;
   reg                      illegal_inst;
   reg                      memory_inst;
   reg                      branch_inst;
   reg                      simple_inst;
   reg                      complx_inst;

   assign opcode      = inst_i[ 6: 0];
   assign funct3      = inst_i[14:12];
   assign funct7      = inst_i[31:25];
   assign funct12     = inst_i[31:20];
   assign rd          = inst_i[11: 7];
   assign rs1         = inst_i[19:15];
   assign rs2         = inst_i[24:20];

   always @ *
   begin
       imm_type            = `IMM_I;
       src1_sel           = `SRC1_RS1;
       src2_sel           = `SRC2_IMM;
       use_rs1             = 1'b1;
       use_rs2             = 1'b0;
       use_rd              = 1'b0;
       write_rd            = 1'b0;
       alu_op              = `ALU_OP_ADD;
       illegal_inst        = 1'b0;
       memory_inst         = 1'b0;
       branch_inst         = 1'b0;
       simple_inst         = 1'b0;
       complx_inst         = 1'b0;
      
      case (opcode)
      `RV32_LOAD :    begin
                          use_rd      = 1'b1;
                          write_rd    = 1'b1;
                          memory_inst = 1'b1;
                      end
      `RV32_STORE :   begin
                          use_rs2     = 1'b1;
                          imm_type    = `IMM_S;
                          memory_inst = 1'b1;
                      end
      // conditional branches
      `RV32I_BRANCH : begin
                          use_rs2     = 1'b1;
                          src2_sel   = `SRC2_RS2;
                          branch_inst = 1'b1;
                          case (funct3)
                            `RV32I_FUNCT3_BEQ  : alu_op = `ALU_OP_SEQ;
                            `RV32I_FUNCT3_BNE  : alu_op = `ALU_OP_SNE;
                            `RV32I_FUNCT3_BLT  : alu_op = `ALU_OP_SLT;
                            `RV32I_FUNCT3_BLTU : alu_op = `ALU_OP_SLTU;
                            `RV32I_FUNCT3_BGE  : alu_op = `ALU_OP_SGE;
                            `RV32I_FUNCT3_BGEU : alu_op = `ALU_OP_SGEU;
                            default : illegal_inst = 1'b1;
                          endcase
                     end

      // unconditional branches
      `RV32I_JAL :   begin
                          use_rs1     = 1'b0;
                          src1_sel   = `SRC1_PC;
                          src2_sel   = `SRC2_FOUR;
                          use_rd      = 1'b1;
                          write_rd    = 1'b1;
                          branch_inst = 1'b1;
                     end
      `RV32I_JALR :  begin
                          src1_sel    = `SRC1_PC;
                          src2_sel    = `SRC2_FOUR;
                          use_rd       = 1'b1;
                          write_rd     = 1'b1;
                          illegal_inst = (funct3 != 0);
                          branch_inst  = 1'b1;
                     end
/*
      `RV32I_FENCE :
      begin
           case (funct3)
           `RV32_FUNCT3_FENCE : begin
                   if ((inst_i[31:28] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                     ; // most fences are no-ops
                   else
                     illegal_inst = 1'b1;
           end
           `RV32_FUNCT3_FENCE_I : begin
           if ((inst_i[31:20] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                     fence_i = 1'b1;
           else
                     illegal_inst = 1'b1;
           end
           default : illegal_inst = 1'b1;
           endcase
      end
*/
      `RV32_ALU_IMM: begin
                         use_rd      = 1'b1;
                         write_rd    = 1'b1;
                         alu_op      = alu_op_arith;
                         simple_inst = 1'b1;
                     end
      `RV32_ALU :    begin
                         use_rs2     = 1'b1;
                         src2_sel   = `SRC2_RS2;
                         alu_op      = alu_op_arith;
                         use_rd      = 1'b1;
                         write_rd    = 1'b1;
                         simple_inst = 1'b1;
                     end
/*
      `RV32I_SYSTEM : begin
         wb_src_sel_DX = `WB_SRC_CSR;
         use_rd = (funct3 != `RV32I_FUNCT3_PRIV);
         case (funct3)
           `RV32I_FUNCT3_PRIV : begin
              if ((rs1 == 0) && (reg_to_wr_DX == 0)) begin
                 case (funct12)
                   `RV32I_FUNCT12_ECALL : ecall = 1'b1;
                   `RV32I_FUNCT12_EBREAK : ebreak = 1'b1;
                   `RV32I_FUNCT12_ERET : begin
                      if (prv == 0)
                        illegal_inst = 1'b1;
                      else
                        eret_unkilled = 1'b1;
                   end
                   default : illegal_inst = 1'b1;
                 endcase
              end
           end
           `RV32I_FUNCT3_CSRRW : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
           `RV32I_FUNCT3_CSRRS : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
           `RV32I_FUNCT3_CSRRC : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
           `RV32I_FUNCT3_CSRRWI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
           `RV32I_FUNCT3_CSRRSI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
           `RV32I_FUNCT3_CSRRCI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
           default : illegal_inst = 1'b1;
         endcase
      end
*/
     `RV32I_AUIPC: begin
                       use_rs1     = 1'b0;
                       src1_sel   = `SRC1_PC;
                       imm_type    = `IMM_U;
                       use_rd      = 1'b1;
                       write_rd    = 1'b1;
                       simple_inst = 1'b1;
                   end
     `RV32I_LUI :  begin
                       use_rs1     = 1'b0;
                       src1_sel   = `SRC1_ZERO;
                       imm_type    = `IMM_U;
                       use_rd      = 1'b1;
                       write_rd    = 1'b1;
                       simple_inst = 1'b1;
                   end
     default :     illegal_inst = 1'b1;
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

  always @ (posedge clock or negedge reset_n)
  begin
      if(!reset_n)
      begin
          rs1_r0_o          <= 5'b0;
          rs2_r0_o          <= 5'b0;
          rd_r0_o           <= 5'b0;
          imm_type_r0_o     <= 2'b0;
          src1_sel_r0_o    <= 2'b0;
          src2_sel_r0_o    <= 2'b0;
                                    
          use_rs1_r0_o      <= 1'b0;
          use_rs2_r0_o      <= 1'b0;
          use_rd_r0_o       <= 1'b0;
          write_rd_r0_o     <= 1'b0;
          alu_op_r0_o       <= 4'b0;
          illegal_inst_r0_o <= 1'b0;
          memory_inst_r0_o  <= 1'b0;
          branch_inst_r0_o  <= 1'b0;
          simple_inst_r0_o  <= 1'b0;
          complx_inst_r0_o  <= 1'b0;
      end
      else if(pipe_load_decode_i)
      begin
          rs1_r0_o          <= rs1;
          rs2_r0_o          <= rs2;
          rd_r0_o           <= rd;
          imm_type_r0_o     <= imm_type;
          src1_sel_r0_o    <= src1_sel;
          src2_sel_r0_o    <= src2_sel;
          
          use_rs1_r0_o      <= use_rs1;
          use_rs2_r0_o      <= use_rs2;
          use_rd_r0_o       <= use_rd;
          write_rd_r0_o     <= write_rd;
          alu_op_r0_o       <= alu_op;
          illegal_inst_r0_o <= illegal_inst;
          memory_inst_r0_o  <= memory_inst;
          branch_inst_r0_o  <= branch_inst;
          simple_inst_r0_o  <= simple_inst;
          complx_inst_r0_o  <= complx_inst;
      end
  end


endmodule
