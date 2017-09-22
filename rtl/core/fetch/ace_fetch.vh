////////////////////////////////////////////////////////////////////////
// ACE21064 Microprocessor macro defination
////////////////////////////////////////////////////////////////////////
// fetch

//branch predictor
`define ST                2'b00 // Strong Taken
`define WT                2'b01 // Weak Taken
`define WNT               2'b10 // Week Not-taken
`define SNT               2'b11 // Strong Not-taken

// branch types
`define BR_COND		      2'b00  // conditional jump
`define BR_UNCOND	      2'b01  // unconditional jump
`define BR_INDIR_PC	      2'b10  // indirectory jump, PC relative
`define BR_INDIR_RS	      2'b11  // indirectory jump, RS relative

`define BR_INDIR_RAS	  2'b11  // temporary 


`define RV32I_BRANCH      7'b1100011
`define RV32I_JAL         7'b1101111
`define RV32I_JALR        7'b1100111

`define RV32I_FUNCT3_BEQ           0
`define RV32I_FUNCT3_BNE           1
`define RV32I_FUNCT3_BLT           4
`define RV32I_FUNCT3_BGE           5
`define RV32I_FUNCT3_BLTU          6
`define RV32I_FUNCT3_BGEU          7


