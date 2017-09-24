////////////////////////////////////////////////////////////////////////
// ACE21064 Microprocessor macro defination
////////////////////////////////////////////////////////////////////////
// decode

`define RV_NOP          32'b0010011

// Opcodes
`define RV32_LOAD        7'b0000011
`define RV32_STORE       7'b0100011
`define RV32I_BRANCH     7'b1100011

`define RV32F_FLW        7'b0000111
`define RV32F_FSW        7'b0100111 
`define RV32F_FMSUB      7'b1000111
`define RV32F_FNMSUB     7'b1001011
`define RV32F_FNMADD     7'b1001111

`define RV32I_JAL        7'b1101111
`define RV32I_JALR       7'b1100111


`define RV32I_FENCE      7'b0001111
`define RV_ATOMIC        7'b0101111

`define RV32_ALU_IMM     7'b0010011
`define RV32_ALU         7'b0110011
`define RV32F_ALU        7'b1010011
`define RV32_SYSTEM      7'b1110011

`define RV32I_AUIPC       7'b0010111
`define RV32I_LUI         7'b0110111

`define RV64I_ALU_IMM    7'b0011011
`define RV64I_ALU        7'b0111011

// Arithmetic FUNCT3 encodings
`define RV32I_FUNCT3_ADD_SUB       0
`define RV32I_FUNCT3_SLL           1
`define RV32I_FUNCT3_SLT           2
`define RV32I_FUNCT3_SLTU          3
`define RV32I_FUNCT3_XOR           4
`define RV32I_FUNCT3_SRA_SRL       5
`define RV32I_FUNCT3_OR            6
`define RV32I_FUNCT3_AND           7

// Branch FUNCT3 encodings
`define RV32I_FUNCT3_BEQ           0
`define RV32I_FUNCT3_BNE           1
`define RV32I_FUNCT3_BLT           4
`define RV32I_FUNCT3_BGE           5
`define RV32I_FUNCT3_BLTU          6
`define RV32I_FUNCT3_BGEU          7

// MISC-MEM FUNCT3 encodings
`define RV32I_FUNCT3_FENCE         0
`define RV32I_FUNCT3_FENCE_I       1

// SYSTEM FUNCT3 encodings
`define RV32I_FUNCT3_PRIV          0
`define RV32I_FUNCT3_CSRRW         1
`define RV32I_FUNCT3_CSRRS         2
`define RV32I_FUNCT3_CSRRC         3
`define RV32I_FUNCT3_CSRRWI        5
`define RV32I_FUNCT3_CSRRSI        6
`define RV32I_FUNCT3_CSRRCI        7

// PRIV FUNCT12 encodings
`define RV32I_FUNCT12_ECALL        12'b000000000000
`define RV32I_FUNCT12_EBREAK       12'b000000000001
`define RV32I_FUNCT12_URET         12'b000000000010
`define RV32I_FUNCT12_SRET         12'b000100000010
`define RV32I_FUNCT12_MRET         12'b001100000010
`define RV32I_FUNCT12_WFI          12'b000100000101

// RV32M encodings
`define RV32M_FUNCT3_MUL        3'd0
`define RV32M_FUNCT3_MULH       3'd1
`define RV32M_FUNCT3_MULHSU     3'd2
`define RV32M_FUNCT3_MULHU      3'd3
`define RV32M_FUNCT3_DIV        3'd4
`define RV32M_FUNCT3_DIVU       3'd5
`define RV32M_FUNCT3_REM        3'd6
`define RV32M_FUNCT3_REMU       3'd7

// RV32/64I load encodings
`define RV32I_FUNCT3_LB        3'd0
`define RV32I_FUNCT3_LH        3'd1
`define RV32I_FUNCT3_LW        3'd2
`define RV64I_FUNCT3_LD        3'd3
`define RV32I_FUNCT3_LBU       3'd4
`define RV32I_FUNCT3_LHU       3'd5
`define RV64I_FUNCT3_LWU       3'd6
// RV32/64I store encodings
`define RV32I_FUNCT3_SB        3'd0
`define RV32I_FUNCT3_SH        3'd1
`define RV32I_FUNCT3_SW        3'd2
`define RV64I_FUNCT3_SD        3'd3

`define ALU_OP_ADD             4'd0
`define ALU_OP_SLL             4'd1
`define ALU_OP_XOR             4'd4
`define ALU_OP_OR              4'd6
`define ALU_OP_AND             4'd7
`define ALU_OP_SRL             4'd5
`define ALU_OP_SEQ             4'd8
`define ALU_OP_SNE             4'd9
`define ALU_OP_SUB             4'd10
`define ALU_OP_SRA             4'd11
`define ALU_OP_SLT             4'd12
`define ALU_OP_SGE             4'd13
`define ALU_OP_SLTU            4'd14
`define ALU_OP_SGEU            4'd15

// immediate type
`define IMM_I                  2'd0
`define IMM_S                  2'd1
`define IMM_U                  2'd2
`define IMM_J                  2'd3

//src_a
`define SRC_A_RS1              2'd0
`define SRC_A_PC               2'd1
`define SRC_A_ZERO             2'd2

//src_b
`define SRC_B_RS2              2'd0
`define SRC_B_IMM              2'd1
`define SRC_B_FOUR             2'd2
`define SRC_B_ZERO             2'd3

`define MD_OP_MUL              2'd0
`define MD_OP_DIV              2'd1
`define MD_OP_REM              2'd2
// reservation station id
`define RESERVATION_STATION0   1'b0
`define RESERVATION_STATION1   1'b1
