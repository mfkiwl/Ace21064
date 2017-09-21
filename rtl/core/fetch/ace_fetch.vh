////////////////////////////////////////////////////////////////////////
// ACE21064 Microprocessor macro defination
////////////////////////////////////////////////////////////////////////
// fetch

//branch predictor
`define ST  2'b00 // Strong Taken
`define WT  2'b01 // Weak Taken
`define WNT 2'b10 // Week Not-taken
`define SNT 2'b11 // Strong Not-taken

// branch types
`define BR_COND		    2'b00  // conditional jump
`define BR_UNCOND	    2'b01  // unconditional jump
`define BR_INDIR_PC	    2'b10  // indirectory jump, PC relative
`define BR_INDIR_RAS	2'b11  // indirectory jump, RAS relative

