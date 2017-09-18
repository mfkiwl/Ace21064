////////////////////////////////////////////////////////////////////////
// ACE21064 Microprocessor macro defination
////////////////////////////////////////////////////////////////////////
//// fetch unit
//branch predictor
`define ST  2'b00 // Strong Taken
`define WT  2'b01 // Weak Taken
`define WNT 2'b10 // Week Not-taken
`define SNT 2'b11 // Strong Not-taken

// This file is for collecting tweakable parameters
//
// Convention:
//  *_SIZE - the actual size, used as [THING_SIZE-1:0]
//  *_LEN  - 1 less than the actual size, used as [THING_LEN:0]

// *** fetch ***

// branch types
`define BR_COND		    2'b00  // conditional jump
`define BR_UNCOND	    2'b01  // unconditional jump
`define BR_INDIR_PC	    2'b10  // indirectory jump, PC relative
`define BR_INDIR_RAS	2'b11  // indirectory jump, RAS relative

// internal fetch data bundles
  // RAS feedback: F1 -> F0
`define RAS_CTRL		0 //  2 bits
`define RAS_ADDR		2 // 64 bits
`define RAS_UPDATE_LEN	64 + 2 - 1
  // BTB add entry: F1 -> F0
`define BTB_NEW_WRITE		0  //  1 bit
`define BTB_NEW_BRPOS		1  //  3 bits
`define BTB_NEW_BRTYPE		4  //  2 bits
`define BTB_NEW_BUNDLEPC	6  // 64 bits
`define BTB_NEW_TAKENPC		70 // 64 bits
`define BTB_NEW_LEN		64 + 64 + 2 + 3 + 1 - 1

  // Predictor update: WB -> F1 -> F0
`define PRED_UPDATE_WRITE	0  //  1 bit
`define PRED_UPDATE_BRDIR	1  //  1 bit
`define PRED_UPDATE_CWRITE	2
`define PRED_UPDATE_CDIR	`PRED_UPDATE_CWRITE + 1
`define PRED_UPDATE_BUNDLEPC	`PRED_UPDATE_CDIR + 1
`define PRED_UPDATE_BOB_VALID   `PRED_UPDATE_BUNDLEPC + `PC_LEN + 1
`define PRED_UPDATE_RAS_PTR     `PRED_UPDATE_BOB_VALID + 1
`define PRED_UPDATE_LEN	`PRED_UPDATE_RAS_PTR + `RAS_STACK_LOGSIZE - 1
`define PRED_BTB_WRITE		0 //  1 bit
`define PRED_BTB_BRDIR		1 //  1 bit
`define PRED_BTB_BUNDLEPC	2 // 64 bits
`define BTB_RETIRE_LEN	64 + 1 + 1 + 1 - 1
`define BOB_SIZE        16
`define BOB_SIZE_LOG        4
`define FETCH2_QUEUE_SIZE    32
`define FETCH2_QUEUE_SIZE_LOG    5
`define RAS_STACK_SIZE        16
`define RAS_STACK_LOGSIZE       4

`define BOB_ARRAY_RAS           0
`define   BOB_ARRAY_RAS_LEN     `RAS_STACK_LOGSIZE - 1
`define BOB_ARRAY_GSHARE        `BOB_ARRAY_RAS + `BOB_ARRAY_RAS_LEN + 1
`define   BOB_ARRAY_GSHARE_LEN  `GSHARE_LOGHIST_LEN
`define BOB_ARRAY_LOCAL         `BOB_ARRAY_GSHARE + `BOB_ARRAY_GSHARE_LEN + 1
`define   BOB_ARRAY_LOCAL_LEN   `LOCAL_HISTBITS_LEN
`define BOB_ARRAY_PREDDIR       `BOB_ARRAY_LOCAL + `BOB_ARRAY_LOCAL_LEN + 1
`define BOB_ARRAY_CHOICEUP      `BOB_ARRAY_PREDDIR + 1
`define BOB_ARRAY_CHOICEWR      `BOB_ARRAY_CHOICEUP + 1
`define BOB_ARRAY_PC            `BOB_ARRAY_CHOICEWR + 1
`define   BOB_ARRAY_PC_LEN      63
`define BOB_ARRAY_LEN           `BOB_ARRAY_PC + `BOB_ARRAY_PC_LEN

  // BTB
`define BTB_SIZE             256        // number of entries in BTB
`define BTB_LOG2_SIZE        8
`define BTB_TAG_SIZE         64 - `BTB_LOG2_SIZE - `BTB_START_BIT // number of bits stored as the tag 
`define BTB_TAG_LEN         `BTB_TAG_SIZE - 1
`define BTB_INDEX_LEN       `BTB_LOG2_SIZE - 1
`define BTB_TAG_START       `BTB_START_BIT + `BTB_LOG2_SIZE
`define BTB_COUNTER_INIT     2'b01
`define BTB_START_BIT        2  //// which bit to start indexing from
  // Tournament predictor
`define PC_OFFSET        2            // # of PC bits to skip over, starting from the LSB
`define PHR_LEN            `GSHARE_LOGHIST_LEN + BOB_SIZE
  // - Local History Table
`define LOCAL_HIST_SIZE        1024            // # entries in the Local History Table
`define LOCAL_LOGHIST_LEN    9            // log2(`LOCAL_HIST_SIZE)-1
`define LOCAL_HISTBITS_LEN    9            // # of bits of history to track - 1
`define LOCAL_HISTREG_INIT    10'b0            // initial shift register value
  // - Local Predictor Table
`define LOCAL_PRED_SIZE        1024            // 2^(`LOCAL_HISTBITS_LEN+1)
`define LOCAL_LOGPRED_LEN    `LOCAL_HISTBITS_LEN
`define LOCAL_COUNTER_LEN    2            // (# of counter bits)-1
`define LOCAL_COUNTER_INIT    3'b011            // initial counter value
  // - Gshare Predictor Table
`define GSHARE_HIST_SIZE    4096            // # of entries in the Global Predictor Table
`define GSHARE_LOGHIST_LEN    11            // log2(`GSHARE_HISTORY_SIZE)-1
`define GSHARE_COUNTER_LEN    1            // (# of counter bits)-1
`define GSHARE_COUNTER_INIT    2'b01            // initial counter value
  // - Choice Predictor Table
`define CHOICE_TABLE_SIZE    4096            // # of entries in the Choice Predictor Table
`define CHOICE_LOGTABLE_LEN    11            // log2(`CHOICE_TABLE_SIZE)-1
`define CHOICE_COUNTER_LEN    1            // (# of counter bits)-1
`define CHOICE_COUNTER_INIT    2'b10            // initial counter value

