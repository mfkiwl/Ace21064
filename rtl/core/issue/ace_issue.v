//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ace_issue.v
//  Author      : ejune@aureage.com
//                
//  Description : data to be stored in issue queue
//               (14) Branch mask:
//               (13) Issue Queue ID:
//               (12) Src Reg-1:
//               (11) Src Reg-2:
//               (10) LD/ST Queue ID:
//               (9)  Active List ID:
//               (8)  Checkpoint ID:
//               (7)  Destination Reg:
//               (6)  Immediate data:
//               (5)  LD/ST Type:
//               (4)  Opcode:
//               (3)  Program Counter:
//               (2)  Predicted Target Addr:
//               (1)  CTI Queue ID:
//               (0)  Branch Prediction:	
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module ace_issue(
	input clock,
	input reset_n,

	input backEndReady_i,	

	input [3+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket0_i,
	input [3+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket1_i,
	input [3+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket2_i,
	input [3+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket3_i,

	input [`SIZE_ACTIVELIST_LOG-1:0] inst0_robidx_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst1_robidx_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst2_robidx_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst3_robidx_i,

	input [`SIZE_LSQ_LOG-1:0] inst0_lsqidx_i,
	input [`SIZE_LSQ_LOG-1:0] inst1_lsqidx_i,
	input [`SIZE_LSQ_LOG-1:0] inst2_lsqidx_i,
	input [`SIZE_LSQ_LOG-1:0] inst3_lsqidx_i,

	/* Register File Valid bits */
	input [`SIZE_PHYSICAL_TABLE-1:0] phy_reg_vld_i,

	/* Bypass tags + valid bit for LD/ST */
	input [`SIZE_PHYSICAL_LOG:0]  rsr3Tag_i,

	/* Control execution flags from the bypass path */
	input ctrlVerified_i,
	/*  if 1, there has been a mis-predict previous cycle */
	input ctrlMispredict_i,

	/* SMT id of the mispredicted branch */
	input [`CHECKPOINTS_LOG-1:0] ctrlSMTid_i,

	/* Count of Valid Issue Q Entries goes to Dispatch */
	output [`SIZE_ISSUEQ_LOG:0] cntInstIssueQ_o,

	/* Note: These have to be sent directly to the PRF (RSR
	 * broadcast to ensure ready bits are set for the PRF
	 * entries)
	 */
	output [`SIZE_PHYSICAL_LOG-1:0] rsr0Tag_o,
	output rsr0TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr1Tag_o,
	output rsr1TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr2Tag_o,
	output rsr2TagValid_o,

	/* Payload and Destination of instructions */
	output grantedValid0_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_o,
	output grantedValid1_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_o,
	output grantedValid2_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_o,
	output grantedValid3_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_o
);

//  Instantiating issue queue and payload ram for all the functional units. 
//  This is a unified structure.
reg [31:0] rs1_vld;
reg [31:0] rs2_vld;

// issueq_fu: FU type of the instructions in the Issue Queue. This information is 
//        used for selecting ready instructions for scheduling per functional
//            unit.	 	
reg [`INST_TYPES_LOG-1:0] issueq_fu [31:0];

// branch_msk: Branch tag of the instructions in the Issue Queue, assigned during 
//         renaming. Branch tag is used during the branch mis-prediction recovery process.
reg [`CHECKPOINTS-1:0]   branch_msk [31:0];

// issueq_schdg: 1-bit indicating whether the issue queue entry has been issued 
//  	     for execution.
reg [31:0]   issueq_schdg;
//  issueq_vld: 1-bit indicating validity of each entry in the Issue Queue.
reg [31:0]    issueq_vld;

wire issueq_free_vld0;
wire issueq_free_vld1;
wire issueq_free_vld2;
wire issueq_free_vld3;

wire [4:0] issueq_free_idx0;
wire [4:0] issueq_free_idx1;
wire [4:0] issueq_free_idx2;
wire [4:0] issueq_free_idx3;

/* Issue queue entries popped from the freeList */
wire [4:0] issueq_rels_idx0;
wire [4:0] issueq_rels_idx1;
wire [4:0] issueq_rels_idx2;
wire [4:0] issueq_rels_idx3;

reg [31:0] issueqValid_normal;
reg [31:0] issueqValid_mispre;
reg [31:0] freedValid_mispre;

reg [31:0] issueqSchedule_normal;

/* instSource is used to extract source registers from the dispatched instruction. */
reg [`SIZE_PHYSICAL_LOG:0] inst0_rs1;
reg [`SIZE_PHYSICAL_LOG:0] inst0_rs2;
reg [`SIZE_PHYSICAL_LOG:0] inst1_rs1;
reg [`SIZE_PHYSICAL_LOG:0] inst1_rs2;
reg [`SIZE_PHYSICAL_LOG:0] inst2_rs1;
reg [`SIZE_PHYSICAL_LOG:0] inst2_rs2;
reg [`SIZE_PHYSICAL_LOG:0] inst3_rs1;
reg [`SIZE_PHYSICAL_LOG:0] inst3_rs2;

reg [`CHECKPOINTS-1:0] inst0_br_msk;
reg [`CHECKPOINTS-1:0] inst1_br_msk;
reg [`CHECKPOINTS-1:0] inst2_br_msk;
reg [`CHECKPOINTS-1:0] inst3_br_msk;
reg [`CHECKPOINTS-1:0] update_mask;

/* newInsReady is used to store ready bit computed on the dispatched instruction. */
reg newInsReady01;
reg newInsReady02;
reg newInsReady11;
reg newInsReady12;
reg newInsReady21;
reg newInsReady22;
reg newInsReady31;
reg newInsReady32;

/* Wires to handle next rs1_vld and rs2_vld bits */
wire [31:0] src0RegValid_t0;
wire [31:0] src1RegValid_t0;
reg [31:0] src0RegValid_t1;
reg [31:0] src1RegValid_t1;

reg [31:0] requestVector0;
reg [31:0] requestVector1;
reg [31:0] requestVector2;
reg [31:0] requestVector3;

wire grantedValid0;
wire grantedValid1;
wire grantedValid2;
wire grantedValid3;

wire [4:0] grantedEntry0;
wire [4:0] grantedEntry1;
wire [4:0] grantedEntry2;
wire [4:0] grantedEntry3;

wire grantedValid0_t;
wire grantedValid1_t;
wire grantedValid2_t;
wire grantedValid3_t;

	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_t;

wire freedValid02;
wire freedValid12;
wire freedValid22;

wire [4:0] freedEntry02;
wire [4:0] freedEntry12;
wire [4:0] freedEntry22;

wire [`SIZE_PHYSICAL_LOG-1:0] rsr0Tag;
wire rsr0TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr1Tag;
wire rsr1TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr2Tag;
wire rsr2TagValid;

wire [`SIZE_PHYSICAL_LOG-1:0] granted0Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted1Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted2Dest;

wire [4:0] granted0Entry;
wire [4:0] granted1Entry;
wire [4:0] granted2Entry;

/* Wires to "alias" the RSR + valid bit*/
wire [`SIZE_PHYSICAL_LOG:0]  rsr0Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr1Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr2Tag_t;

/* Wires for Issue Queue Payload RAM */
`define SIZE_PAYLOAD_WIDTH (2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1)

wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData0;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData1;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData2;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData3;

wire payloadRAMwe0;
wire payloadRAMwe1;
wire payloadRAMwe2;
wire payloadRAMwe3;

wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr0;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr1;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr2;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr3;

/* Wires for wakeup_lat CAM */
wire [31:0] src0_matchLines0;
wire [31:0] src0_matchLines1;
wire [31:0] src0_matchLines2;
wire [31:0] src0_matchLines3;

wire [31:0] src1_matchLines0;
wire [31:0] src1_matchLines1;
wire [31:0] src1_matchLines2;
wire [31:0] src1_matchLines3;

wire CAM0we0;
wire CAM0we1;
wire CAM0we2;
wire CAM0we3;

wire CAM1we0;
wire CAM1we1;
wire CAM1we2;
wire CAM1we3;

/* Correctly "alias" rsr0Tag_t */
assign rsr0Tag_t = {rsr0Tag, rsr0TagValid};
assign rsr1Tag_t = {rsr1Tag, rsr1TagValid};
assign rsr2Tag_t = {rsr2Tag, rsr2TagValid};

/* Assign to output the rsrTags */
assign rsr0TagValid_o = rsr0TagValid;
assign rsr1TagValid_o = rsr1TagValid;
assign rsr2TagValid_o = rsr2TagValid;

assign rsr0Tag_o = rsr0Tag;
assign rsr1Tag_o = rsr1Tag;
assign rsr2Tag_o = rsr2Tag;

/************************************************************************************
* ISSUEQ_PAYLOAD: Has all the necessary information required by function unit to 
		  execute the instruction. Implemented as payloadRAM
	       (Source registers, LD/ST queue ID, Active List ID, Shadow Map ID, Destination register, 
		   Immediate data, LD/ST data size, Opcode, Program counter, Predicted
		   Target Address, Ctiq Tag, Predicted Branch direction)	  
************************************************************************************/
assign payloadRAMwe0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign payloadRAMwe1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign payloadRAMwe2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign payloadRAMwe3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);

assign payloadRAMDataWr0 = {inst0_rs2[`SIZE_PHYSICAL_LOG:1],inst0_rs1[`SIZE_PHYSICAL_LOG:1],
	inst0_lsqidx_i,inst0_robidx_i,
	dispatchPacket0_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr1 = {inst1_rs2[`SIZE_PHYSICAL_LOG:1],inst1_rs1[`SIZE_PHYSICAL_LOG:1],
	inst1_lsqidx_i,inst1_robidx_i,
	dispatchPacket1_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr2 = {inst2_rs2[`SIZE_PHYSICAL_LOG:1],inst2_rs1[`SIZE_PHYSICAL_LOG:1],
	inst2_lsqidx_i,inst2_robidx_i,
	dispatchPacket2_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr3 = {inst3_rs2[`SIZE_PHYSICAL_LOG:1],inst3_rs1[`SIZE_PHYSICAL_LOG:1],
	inst3_lsqidx_i,inst3_robidx_i,
	dispatchPacket3_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};


SRAM_4R4W_PAYLOAD #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG,`SIZE_PAYLOAD_WIDTH) payloadRAM(.clock(clock),
	.reset_n(reset_n),
	.addr0_i(grantedEntry0),
	.addr1_i(grantedEntry1),
	.addr2_i(grantedEntry2),
	.addr3_i(grantedEntry3),
	.addr0wr_i(issueq_rels_idx0),
	.addr1wr_i(issueq_rels_idx1),
	.addr2wr_i(issueq_rels_idx2),
	.addr3wr_i(issueq_rels_idx3),
	.we0_i(payloadRAMwe0),
	.we1_i(payloadRAMwe1),
	.we2_i(payloadRAMwe2),
	.we3_i(payloadRAMwe3),
	.data0wr_i(payloadRAMDataWr0),
	.data1wr_i(payloadRAMDataWr1),
	.data2wr_i(payloadRAMDataWr2),
	.data3wr_i(payloadRAMDataWr3),
	.data0_o(payloadRAMData0),
	.data1_o(payloadRAMData1),
	.data2_o(payloadRAMData2),
	.data3_o(payloadRAMData3)
);

/************************************************************************************
* WAKEUP CAM: Has the source physical registers that try to match tags broadcasted by the RSR
************************************************************************************/
assign src0RegValid_t0 = issueq_vld & (~issueq_schdg) & (rs1_vld | src0_matchLines0 | src0_matchLines1 | src0_matchLines2 | src0_matchLines3);
assign src1RegValid_t0 = issueq_vld & (~issueq_schdg) & (rs2_vld | src1_matchLines0 | src1_matchLines1 | src1_matchLines2 | src1_matchLines3);

assign CAM0we0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM0we1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM0we2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM0we3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);

assign CAM1we0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM1we1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM1we2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM1we3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);

/* Instantiate the CAM for the 2nd source operand */
CAM_4R4W #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG, `SIZE_PHYSICAL_LOG) src1cam (.clock(clock),
	.reset_n(reset_n),
	.tag0_i(rsr0Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag1_i(rsr1Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag2_i(rsr2Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag3_i(rsr3Tag_i[`SIZE_PHYSICAL_LOG:1]),
	.addr0wr_i(issueq_rels_idx0),
	.addr1wr_i(issueq_rels_idx1),
	.addr2wr_i(issueq_rels_idx2),
	.addr3wr_i(issueq_rels_idx3),
	.we0_i(CAM1we0),
	.we1_i(CAM1we1),
	.we2_i(CAM1we2),
	.we3_i(CAM1we3),
	.tag0wr_i(inst0_rs2[`SIZE_PHYSICAL_LOG:1]),
	.tag1wr_i(inst1_rs2[`SIZE_PHYSICAL_LOG:1]),
	.tag2wr_i(inst2_rs2[`SIZE_PHYSICAL_LOG:1]),
	.tag3wr_i(inst3_rs2[`SIZE_PHYSICAL_LOG:1]),
	.match0_o(src1_matchLines0),
	.match1_o(src1_matchLines1),
	.match2_o(src1_matchLines2),
	.match3_o(src1_matchLines3)
);

/* Instantiate the CAM for the 1st source operand */
CAM_4R4W #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG, `SIZE_PHYSICAL_LOG) src0cam (.clock(clock),
	.reset_n(reset_n),
	.tag0_i(rsr0Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag1_i(rsr1Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag2_i(rsr2Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag3_i(rsr3Tag_i[`SIZE_PHYSICAL_LOG:1]),
	.addr0wr_i(issueq_rels_idx0),
	.addr1wr_i(issueq_rels_idx1),
	.addr2wr_i(issueq_rels_idx2),
	.addr3wr_i(issueq_rels_idx3),
	.we0_i(CAM0we0),
	.we1_i(CAM0we1),
	.we2_i(CAM0we2),
	.we3_i(CAM0we3),
	.tag0wr_i(inst0_rs1[`SIZE_PHYSICAL_LOG:1]),
	.tag1wr_i(inst1_rs1[`SIZE_PHYSICAL_LOG:1]),
	.tag2wr_i(inst2_rs1[`SIZE_PHYSICAL_LOG:1]),
	.tag3wr_i(inst3_rs1[`SIZE_PHYSICAL_LOG:1]),
	.match0_o(src0_matchLines0),
	.match1_o(src0_matchLines1),
	.match2_o(src0_matchLines2),
	.match3_o(src0_matchLines3)
);

/************************************************************************************ 
* Instantiate the Issue Queue Free List. 
* Issue queue free list is a circular buffer and keeps tracks of free entries.  
************************************************************************************/
issueq_fl i_issueq_fl(.clock(clock),
	.reset_n(reset_n),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.mispredictVector_i(freedValid_mispre),
	.backEndReady_i(backEndReady_i),
	/* 4 entries being freed once they have been executed. */
	.grantedEntry0_i(grantedEntry0),
	.grantedEntry1_i(grantedEntry1),
	.grantedEntry2_i(grantedEntry2),
	.grantedEntry3_i(grantedEntry3),
	.grantedValid0_i(grantedValid0_t),
	.grantedValid1_i(grantedValid1_t),
	.grantedValid2_i(grantedValid2_t),
	.grantedValid3_i(grantedValid3_t),
	.freedEntry0_o(issueq_free_idx0),
	.freedEntry1_o(issueq_free_idx1),
	.freedEntry2_o(issueq_free_idx2),
	.freedEntry3_o(issueq_free_idx3),
	.freedValid0_o(issueq_free_vld0),
	.freedValid1_o(issueq_free_vld1),
	.freedValid2_o(issueq_free_vld2),
	.freedValid3_o(issueq_free_vld3),
	/* 4 free Issue Queue entries for the new coming instructions. */
	.freeEntry0_o(issueq_rels_idx0),
	.freeEntry1_o(issueq_rels_idx1),
	.freeEntry2_o(issueq_rels_idx2),
	.freeEntry3_o(issueq_rels_idx3),
	/* Count of Valid Issue Q Entries goes to Dispatch */
	.cntInstIssueQ_o(cntInstIssueQ_o)
);

/************************************************************************************ 
*   If the Issue Queue enrtry has been granted execution then the Instruction
*   Payload and Destination Tags should be pushed down the pipeline with proper
*   valid bit set.
*   
*   Granted Valid is also checked for any branch misprediction this cycles. So
*   that instruction from the wrong path is not issued for execution.
************************************************************************************/
assign grantedValid0_t  = grantedValid0 && ~(ctrlMispredict_i && branch_msk[grantedEntry0][ctrlSMTid_i]);
assign grantedValid1_t  = grantedValid1 && ~(ctrlMispredict_i && branch_msk[grantedEntry1][ctrlSMTid_i]);
assign grantedValid2_t  = grantedValid2 && ~(ctrlMispredict_i && branch_msk[grantedEntry2][ctrlSMTid_i]);
assign grantedValid3_t  = grantedValid3 && ~(ctrlMispredict_i && branch_msk[grantedEntry3][ctrlSMTid_i]);

assign grantedPacket0_t = {branch_msk[grantedEntry0], grantedEntry0, payloadRAMData0};
assign grantedPacket1_t = {branch_msk[grantedEntry1], grantedEntry1, payloadRAMData1};
assign grantedPacket2_t = {branch_msk[grantedEntry2], grantedEntry2, payloadRAMData2};
assign grantedPacket3_t = {branch_msk[grantedEntry3], grantedEntry3, payloadRAMData3};

assign grantedValid0_o  = grantedValid0_t;
assign grantedValid1_o  = grantedValid1_t;
assign grantedValid2_o  = grantedValid2_t;
assign grantedValid3_o  = grantedValid3_t;

assign grantedPacket0_o  = grantedPacket0_t;
assign grantedPacket1_o  = grantedPacket1_t;
assign grantedPacket2_o  = grantedPacket2_t;
assign grantedPacket3_o  = grantedPacket3_t;

/************************************************************************************ 
*  Logic to check new instructions source operand Ready for dispached 
*  instruction from rename stage. 
************************************************************************************/
always @(*)
begin:CHECK_NEW_INSTS_SOURCE_OPERAND

	/* Extracting source registers and branch mask from the dispatched packet */
	inst0_rs1 = dispatchPacket0_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst0_rs2 = dispatchPacket0_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst1_rs1 = dispatchPacket1_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst1_rs2 = dispatchPacket1_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst2_rs1 = dispatchPacket2_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst2_rs2 = dispatchPacket2_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst3_rs1 = dispatchPacket3_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst3_rs2 = dispatchPacket3_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst0_br_msk = dispatchPacket0_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst1_br_msk = dispatchPacket1_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst2_br_msk = dispatchPacket2_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst3_br_msk = dispatchPacket3_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	/************************************************************************************ 
	 * Index into the Physical Register File valid bit vector to check if the source operand 
	 * is ready, or check the broadcasted RSR tags if there is any match to set the ready bit.
	 * This is the common "If reading a location being written into this cycle, bypass the 
	 * 'being written into' value instead of reading the currently stored value" logic.
	************************************************************************************/
	newInsReady01 = (phy_reg_vld_i[inst0_rs1[`SIZE_PHYSICAL_LOG:1]] ||
		                          (inst0_rs1 == rsr0Tag_t) ||
                                  (inst0_rs1 == rsr1Tag_t) ||
                                  (inst0_rs1 == rsr2Tag_t) ||
                                  (inst0_rs1 == rsr3Tag_i) || ~inst0_rs1[0]) ? 1'b1 : 1'b0;

	newInsReady02 = (phy_reg_vld_i[inst0_rs2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst0_rs2 == rsr0Tag_t) || (inst0_rs2 == rsr1Tag_t) || (inst0_rs2 == rsr2Tag_t) || (inst0_rs2 == rsr3Tag_i)
		 || ~inst0_rs2[0]) ? 1'b1:0;

	newInsReady11 = (phy_reg_vld_i[inst1_rs1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst1_rs1 == rsr0Tag_t) || (inst1_rs1 == rsr1Tag_t) || (inst1_rs1 == rsr2Tag_t) || (inst1_rs1 == rsr3Tag_i)
		 || ~inst1_rs1[0]) ? 1'b1:0;

	newInsReady12 = (phy_reg_vld_i[inst1_rs2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst1_rs2 == rsr0Tag_t) || (inst1_rs2 == rsr1Tag_t) || (inst1_rs2 == rsr2Tag_t) || (inst1_rs2 == rsr3Tag_i)
		 || ~inst1_rs2[0]) ? 1'b1:0;

	newInsReady21 = (phy_reg_vld_i[inst2_rs1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst2_rs1 == rsr0Tag_t) || (inst2_rs1 == rsr1Tag_t) || (inst2_rs1 == rsr2Tag_t) || (inst2_rs1 == rsr3Tag_i)
		 || ~inst2_rs1[0]) ? 1'b1:0;

	newInsReady22 = (phy_reg_vld_i[inst2_rs2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst2_rs2 == rsr0Tag_t) || (inst2_rs2 == rsr1Tag_t) || (inst2_rs2 == rsr2Tag_t) || (inst2_rs2 == rsr3Tag_i)
		 || ~inst2_rs2[0]) ? 1'b1:0;

	newInsReady31 = (phy_reg_vld_i[inst3_rs1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst3_rs1 == rsr0Tag_t) || (inst3_rs1 == rsr1Tag_t) || (inst3_rs1 == rsr2Tag_t) || (inst3_rs1 == rsr3Tag_i)
		 || ~inst3_rs1[0]) ? 1'b1:0;

	newInsReady32 = (phy_reg_vld_i[inst3_rs2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst3_rs2 == rsr0Tag_t) || (inst3_rs2 == rsr1Tag_t) || (inst3_rs2 == rsr2Tag_t) || (inst3_rs2 == rsr3Tag_i)
		 || ~inst3_rs2[0]) ? 1'b1:0;

end

/************************************************************************************ 
 * Generate the update_mask vector to unset the SMT id bit in the BRANCH MASK table.
************************************************************************************/
always @(*)
begin: UPDATE_BRANCH_MASK
	integer k;
 
	for(k=0; k<`CHECKPOINTS; k=k+1)
	begin
		if(ctrlVerified_i && (k==ctrlSMTid_i))
			update_mask[k] = 1'b0;
		else
			update_mask[k] = 1'b1;
	end
end


/************************************************************************************ 
* Following updates the Ready bit in the Issue Queue after matching bypassed Tags 
* from RSR.
* Each source's physical tag compares with the 4 bypassed tags to set its Ready bit
*
* On a mispredict, rs1_vld and rs2_vld arrays must not be affected by the
* dispatch instructions. When not a mispredict, next_src0Ready_normal is the same as
* next_src0Rea_mispre, except that bits of the dispatched instructions are updated
************************************************************************************/
always @(*)
begin: UPDATE_SRC_READY_BIT
	integer i;
	integer j;

	src0RegValid_t1 = 0; 
	src1RegValid_t1 = 0;

	for(j=0;j<`SIZE_ISSUEQ;j=j+1)
	begin
		if(backEndReady_i && (j == issueq_rels_idx0))
		begin
			src0RegValid_t1[j]  =  newInsReady01;
			src1RegValid_t1[j]  =  newInsReady02;
		end
		else if(backEndReady_i && (j == issueq_rels_idx1))
		begin
			src0RegValid_t1[j]  =  newInsReady11;
			src1RegValid_t1[j]  =  newInsReady12;
		end
		else if(backEndReady_i && (j == issueq_rels_idx2))
		begin
			src0RegValid_t1[j]  =  newInsReady21;
			src1RegValid_t1[j]  =  newInsReady22;
		end
		else if(backEndReady_i && (j == issueq_rels_idx3))
		begin
			src0RegValid_t1[j]  =  newInsReady31;
			src1RegValid_t1[j]  =  newInsReady32;
		end
		else 
		begin
			src0RegValid_t1[j]  =  src0RegValid_t0[j];
			src1RegValid_t1[j]  =  src1RegValid_t0[j];
		end
	end
end

/************************************************************************************
* Logic to prepare Issue Queue valid array for next cycle during the normal 
* operation, i.e. there is no branch mis-prediction or exception this cycle.
* [i] New Entry position should be set to 1
* [ii] Freed Entry should be set to 0
************************************************************************************/
always @(*)
begin: PREPARE_VALID_ARRAY_NORMAL
	integer i;
	integer k;
	
	reg [31:0] issueqValid_tmp;

	issueqValid_tmp     = 0;
	issueqValid_normal  = 0;

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(backEndReady_i && ((i == issueq_rels_idx0) || (i == issueq_rels_idx1) || (i == issueq_rels_idx2) || (i == issueq_rels_idx3)))
			issueqValid_tmp[i] = 1'b1;
		else
			issueqValid_tmp[i] = issueq_vld[i];
	end

	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		if((issueq_free_vld0 && k == issueq_free_idx0) || (issueq_free_vld1 && k == issueq_free_idx1) || (issueq_free_vld2 && k == issueq_free_idx2) || (issueq_free_vld3 && k == issueq_free_idx3))
			issueqValid_normal[k] = 1'b0;
		else
			issueqValid_normal[k] = issueqValid_tmp[k];
	end
end

/************************************************************************************
* Logic to prepare Issue Queue valid array for next cycle during mis-prediction
* operation.
************************************************************************************/
always @(*)
begin: PREPARE_VALID_ARRAY_MISPRED
	integer i;
	integer k;
	reg [31:0] issueqValid_t;

	issueqValid_mispre = 0;
	freedValid_mispre  = 0;

	/* Unset the valid bit of the entries being freed this cycle. */
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		if((issueq_free_vld0 && k == issueq_free_idx0) || (issueq_free_vld1 && k == issueq_free_idx1) || (issueq_free_vld2 && k == issueq_free_idx2) || (issueq_free_vld3 && k == issueq_free_idx3))
			issueqValid_t[k] = 1'b0;
		else
			issueqValid_t[k] = issueq_vld[k];
	end

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(ctrlVerified_i && ctrlMispredict_i)    /* Unnecessary logic? */
		begin
			if(branch_msk[i][ctrlSMTid_i])
			begin
				issueqValid_mispre[i] = 1'b0;
				if(issueq_vld[i]) 
					freedValid_mispre[i]  = 1'b1;
			end
			else
				issueqValid_mispre[i] = issueqValid_t[i];
		end
	end
end

/************************************************************************************
* Logic to prepare Issue Queue scheduled array for next cycle during the normal
* operation, i.e. there is no branch mis-prediction or exception this cycle.
*	[i]  New Entry position should be set to 0
*	[ii] Granted Entry position should be set 1 
************************************************************************************/
always @(*)
begin: PREPARE_SCHEDULE_ARRAY
	integer i;
	reg [31:0] issueqSchedule_tmp;	

	issueqSchedule_tmp     = 0;
	issueqSchedule_normal  = 0;

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(backEndReady_i && ((i == issueq_rels_idx0) || (i == issueq_rels_idx1) || (i == issueq_rels_idx2) || (i == issueq_rels_idx3)))
			issueqSchedule_tmp[i] = 1'b0;
		else
			issueqSchedule_tmp[i] = issueq_schdg[i];
	end

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if((grantedValid0_t && i == grantedEntry0) || (grantedValid1_t && i == grantedEntry1) || (grantedValid2_t && i == grantedEntry2) || (grantedValid3_t && i == grantedEntry3))
			issueqSchedule_normal[i] = 1'b1;
		else
			issueqSchedule_normal[i] = issueqSchedule_tmp[i];
	end
end

/************************************************************************************
*  Update issueq_vld and issueq_schdg array every cycle. Update is based on
*  the either normal execution or branch mis-prediction.
************************************************************************************/
always @(posedge clock)
begin
	if(reset_n)
	begin
		issueq_vld <= 0;
		issueq_schdg <= 0;
	end 
	else
	begin
		if(ctrlVerified_i && ctrlMispredict_i)
		begin
			issueq_vld <= issueqValid_mispre;
		end
		else
		begin
			issueq_vld <= issueqValid_normal;
		end
	
		issueq_schdg <= issueqSchedule_normal;
	end
end

/************************************************************************************
* Writing new instruction into Issue Queue (payload already taken care of by the RAM)
* Write to Issue Queue is made only if backEndReady (from the dispatch) is high 
* and there is no control mis-predict. 
************************************************************************************/
always @(posedge clock)
begin: newInstructions
	integer i;

	if(reset_n)
	begin
		for(i=0;i<`SIZE_ISSUEQ;i=i+1)
		begin
			issueq_fu[i] <= 0;
		end
	end
	else
	begin
		if(backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i))
		begin
			issueq_fu[issueq_rels_idx0] <= dispatchPacket0_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
			issueq_fu[issueq_rels_idx1] <= dispatchPacket1_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
			issueq_fu[issueq_rels_idx2] <= dispatchPacket2_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
			issueq_fu[issueq_rels_idx3] <= dispatchPacket3_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
		end

		`ifdef VERIFY
		if(issueq_free_vld0)
		begin
			issueq_fu[issueq_free_idx0] <= 0;
		end

		if(issueq_free_vld1)
		begin
			issueq_fu[issueq_free_idx1] <= 0;
		end

		if(issueq_free_vld2)
		begin
			issueq_fu[issueq_free_idx2] <= 0;
		end

		if(issueq_free_vld3)
		begin
			issueq_fu[issueq_free_idx3] <= 0;
		end
		`endif
	end
end

/************************************************************************************ 
* Update the branch mask table every cycle with the new incominig instruction and
* also update it if a branch resolves correctly.
************************************************************************************/ 
always @(posedge clock)
begin:UPDATE_BRANCH_MASK_POSEDGE_CLK
	integer l;

	if(reset_n)
	begin
		for(l=0; l<`SIZE_ISSUEQ; l=l+1)
		begin
			branch_msk[l] <= 0;
		end
	end
	else
	begin
		for(l=0;l<`SIZE_ISSUEQ;l=l+1)
		begin
			if(backEndReady_i && (l == issueq_rels_idx0))
			begin
				branch_msk[l] <= inst0_br_msk;
			end
			else if(backEndReady_i && (l == issueq_rels_idx1))
			begin
				branch_msk[l] <= inst1_br_msk;
			end
			else if(backEndReady_i && (l == issueq_rels_idx2))
			begin
				branch_msk[l] <= inst2_br_msk;
			end
			else if(backEndReady_i && (l == issueq_rels_idx3))
			begin
				branch_msk[l] <= inst3_br_msk;
			end
			`ifdef VERIFY
			 else if((issueq_free_vld0 && (l == issueq_free_idx0)) || (issueq_free_vld1 && (l == issueq_free_idx1)) || (issueq_free_vld2 && (l == issueq_free_idx2)) || (issueq_free_vld3 && (l == issueq_free_idx3)))
				branch_msk[l] <= 0;
			`endif
			else
				branch_msk[l] <= branch_msk[l] & update_mask;
		end
	end
end

/************************************************************************************
*  Update rs1_vld and rs2_vld based on rsrTag match. 
*  Update is based on the either normal execution or branch mis-prediction.
************************************************************************************/
always @(posedge clock)
begin
	if(reset_n)
	begin
		rs1_vld  <= 0;
		rs2_vld  <= 0;
	end
	else if(ctrlVerified_i && ctrlMispredict_i)
	begin
		rs1_vld  <= src0RegValid_t0;
		rs2_vld  <= src1RegValid_t0;
	end
	else
	begin	
		rs1_vld  <= src0RegValid_t1;
		rs2_vld  <= src1RegValid_t1;	
	end
end

/************************************************************************************ 
*  Logic to select 4 Ready instructions and issue them for execution. For
*  each FU one instruction will be selected. 
************************************************************************************/

/* Following selects 1 instruction(s) of type0 */
always @(*)
begin: preparing_request_vector_for_FU0
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector0[k] = (issueq_vld[k] & ~issueq_schdg[k] & rs1_vld[k] & rs2_vld[k] & (issueq_fu[k] == 2'b00)) ? 1'b1:1'b0;
	end
end

issueq_sel select0(
	.req_vec_i(requestVector0),
	.grant_idx_o(grantedEntry0),
	.grant_vld_o(grantedValid0),
    .grant_vec_o()
);

/* Following selects 1 instruction(s) of type1 */
always @(*)
begin: preparing_request_vector_for_FU1
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector1[k] = (issueq_vld[k] & ~issueq_schdg[k] & rs1_vld[k] & rs2_vld[k] & (issueq_fu[k] == 2'b01)) ? 1'b1:1'b0;
	end
end

issueq_sel select1(
	.req_vec_i(requestVector1),
	.grant_idx_o(grantedEntry1),
	.grant_vld_o(grantedValid1),
    .grant_vec_o()
);

/* Following selects 1 instruction(s) of type2 */
always @(*)
begin: preparing_request_vector_for_FU2
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector2[k] = (issueq_vld[k] & ~issueq_schdg[k] & rs1_vld[k] & rs2_vld[k] & (issueq_fu[k] == 2'b10)) ? 1'b1:1'b0;
	end
end

issueq_sel select2(
	.req_vec_i(requestVector2),
	.grant_idx_o(grantedEntry2),
	.grant_vld_o(grantedValid2),
    .grant_vec_o()
);

/* Following selects 1 instruction(s) of type3 */
always @(*)
begin: preparing_request_vector_for_FU3
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector3[k] = (issueq_vld[k] & ~issueq_schdg[k] & rs1_vld[k] & rs2_vld[k] & (issueq_fu[k] == 2'b11)) ? 1'b1:1'b0;
	end
end

issueq_sel select3(
	.req_vec_i(requestVector3),
	.grant_idx_o(grantedEntry3),
	.grant_vld_o(grantedValid3),
    .grant_vec_o()
);

/****************************
 * RSR INSIDE ISSUEQ MODULE *
 * *************************/

	assign granted0Dest  = grantedPacket0_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted1Dest  = grantedPacket1_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted2Dest  = grantedPacket2_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

	assign granted0Entry = grantedPacket0_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted1Entry = grantedPacket1_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted2Entry = grantedPacket2_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

wakeup_lat i_wakeup_lat(
	.clock(clock),
	.reset_n(reset_n),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.ctrlSMTid_i(ctrlSMTid_i),
	.validPacket0_i(grantedValid0_t),
	.validPacket1_i(grantedValid1_t),
	.validPacket2_i(grantedValid2_t),

	.granted0Dest_i(granted0Dest),
	.granted1Dest_i(granted1Dest),
	.granted2Dest_i(granted2Dest),

	.branchMask0_i(branch_msk[grantedEntry0]),
	.branchMask1_i(branch_msk[grantedEntry1]),
	.branchMask2_i(branch_msk[grantedEntry2]),

	.rsr0Tag_o(rsr0Tag),   
	.rsr0TagValid_o(rsr0TagValid),
	.rsr1Tag_o(rsr1Tag),   
	.rsr1TagValid_o(rsr1TagValid),
	.rsr2Tag_o(rsr2Tag),   
	.rsr2TagValid_o(rsr2TagValid)

);

endmodule
