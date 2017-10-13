////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : dep_chk.v
//  Author      : ejune@aureage.com
//                
//  Description :This module does Dependance checking between the
//               4 instructions currently in rename stage0. 
//               to determine if any source register physical mappings
//               need to be updated because 4 instructions were renamed in
//               parallel, so the source mappings of later instructions of the 4
//               dont reflect a new mapping made by an earlier instruction in
//               the same cycle. 
//                                                                               
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////

module dep_chk(
    input  [4:0] inst0_ars1_i,
    input  [4:0] inst1_ars1_i,
    input  [4:0] inst2_ars1_i,
    input  [4:0] inst3_ars1_i,
    input  [4:0] inst0_ars2_i,
    input  [4:0] inst1_ars2_i,
    input  [4:0] inst2_ars2_i,
    input  [4:0] inst3_ars2_i,
    input  [4:0] inst0_ard_i,
    input  [4:0] inst1_ard_i,
    input  [4:0] inst2_ard_i,
    input  [4:0] inst3_ard_i,
    input        inst0_ard_vld_i,
    input        inst1_ard_vld_i,
    input        inst2_ard_vld_i,
    input        inst3_ard_vld_i,

    output [1:0] inst0_rs1_sel_o, // select bits to be used for the mux in rename stage1
    output [1:0] inst1_rs1_sel_o, // if the select bits are the same as the instruction num
    output [1:0] inst2_rs1_sel_o, // there should b no overriting done of the physical source
    output [1:0] inst3_rs1_sel_o, // and destination, if the value is not equal to instruction num
    output [1:0] inst0_rs2_sel_o, // that num describes which instruction's destination physical
    output [1:0] inst1_rs2_sel_o, // mapping should b used for the source register mapping
    output [1:0] inst2_rs2_sel_o, //
    output [1:0] inst3_rs2_sel_o, //  
    output [1:0] inst0_rd_sel_o,
    output [1:0] inst1_rd_sel_o,
    output [1:0] inst2_rd_sel_o,
    output [1:0] inst3_rd_sel_o
);

    wire dep_inst1rs1_inst0rd;
    wire dep_inst1rs2_inst0rd;
    wire dep_inst2rs1_inst0rd;
    wire dep_inst2rs2_inst0rd;
    wire dep_inst2rs1_inst1rd;
    wire dep_inst2rs2_inst1rd;
    wire dep_inst3rs1_inst0rd;
    wire dep_inst3rs2_inst0rd;
    wire dep_inst3rs1_inst1rd;
    wire dep_inst3rs2_inst1rd;
    wire dep_inst3rs1_inst2rd;
    wire dep_inst3rs2_inst2rd;
    wire dep_inst1rd_inst0rd;
    wire dep_inst2rd_inst0rd;
    wire dep_inst2rd_inst1rd;
    wire dep_inst3rd_inst0rd;
    wire dep_inst3rd_inst1rd;
    wire dep_inst3rd_inst2rd;

    assign dep_inst1rs1_inst0rd = (inst1_ars1_i == inst0_ard_i); // RAW between inst0 and inst1
    assign dep_inst1rs2_inst0rd = (inst1_ars2_i == inst0_ard_i); // RAW between inst0 and inst1
    assign dep_inst2rs1_inst0rd = (inst2_ars1_i == inst0_ard_i); // RAW between inst0 and inst2
    assign dep_inst2rs2_inst0rd = (inst2_ars2_i == inst0_ard_i); // RAW between inst0 and inst2
    assign dep_inst2rs1_inst1rd = (inst2_ars1_i == inst1_ard_i); // RAW between inst1 and inst2
    assign dep_inst2rs2_inst1rd = (inst2_ars2_i == inst1_ard_i); // RAW between inst1 and inst2
    assign dep_inst3rs1_inst0rd = (inst3_ars1_i == inst0_ard_i); // RAW between inst0 and inst3
    assign dep_inst3rs2_inst0rd = (inst3_ars2_i == inst0_ard_i); // RAW between inst0 and inst3
    assign dep_inst3rs1_inst1rd = (inst3_ars1_i == inst1_ard_i); // RAW between inst1 and inst3
    assign dep_inst3rs2_inst1rd = (inst3_ars2_i == inst1_ard_i); // RAW between inst1 and inst3
    assign dep_inst3rs1_inst2rd = (inst3_ars1_i == inst2_ard_i); // RAW between inst2 and inst3
    assign dep_inst3rs2_inst2rd = (inst3_ars2_i == inst2_ard_i); // RAW between inst2 and inst3

    assign dep_inst1rd_inst0rd = (inst1_ard_i == inst0_ard_i); //WAW between inst0 and inst1
    assign dep_inst2rd_inst0rd = (inst2_ard_i == inst0_ard_i); //WAW between inst0 and inst2
    assign dep_inst2rd_inst1rd = (inst2_ard_i == inst1_ard_i); //WAW between inst1 and inst2
    assign dep_inst3rd_inst0rd = (inst3_ard_i == inst0_ard_i); //WAW between inst0 and inst3
    assign dep_inst3rd_inst1rd = (inst3_ard_i == inst1_ard_i); //WAW between inst1 and inst3
    assign dep_inst3rd_inst2rd = (inst3_ard_i == inst2_ard_i); //WAW between inst2 and inst3
    
    assign inst0_rs1_sel_o = 2'b00; //never overwritten
    assign inst0_rs2_sel_o = 2'b00; //never overwritten
    assign inst0_rd_sel_o  = 2'b00; //never overwritten

    assign inst1_rs1_sel_o = (dep_inst1rs1_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b01;
    assign inst1_rs2_sel_o = (dep_inst1rs2_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b01;
    assign inst1_rd_sel_o  = (dep_inst1rd_inst0rd  && inst0_ard_vld_i) ? 2'b00 : 2'b01;

    assign inst2_rs1_sel_o = (dep_inst2rs1_inst1rd && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst2rs1_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b10;
    assign inst2_rs2_sel_o = (dep_inst2rs2_inst1rd && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst2rs2_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b10;
    assign inst2_rd_sel_o  = (dep_inst2rd_inst1rd  && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst2rd_inst0rd  && inst0_ard_vld_i) ? 2'b00 : 2'b10;

    assign inst3_rs1_sel_o = (dep_inst3rs1_inst2rd && inst2_ard_vld_i) ? 2'b10 :
                             (dep_inst3rs1_inst1rd && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst3rs1_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b11;
    assign inst3_rs2_sel_o = (dep_inst3rs2_inst2rd && inst2_ard_vld_i) ? 2'b10 :
                             (dep_inst3rs2_inst1rd && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst3rs2_inst0rd && inst0_ard_vld_i) ? 2'b00 : 2'b11;
    assign inst3_rd_sel_o  = (dep_inst3rd_inst2rd  && inst2_ard_vld_i) ? 2'b10 :
                             (dep_inst3rd_inst1rd  && inst1_ard_vld_i) ? 2'b01 :
                             (dep_inst3rd_inst0rd  && inst0_ard_vld_i) ? 2'b00 : 2'b11;

endmodule
