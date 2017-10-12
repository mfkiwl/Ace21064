////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : map.v
//  Author      : ejune@aureage.com
//                
//  Description : This module takes the dependance information received from
//                rename stage0, and makes updates to source registers if necessary.
//                
//    instx_rsxsel_i the select bits for the
//                    mux for each source register, which signifies whether or
//                    not to use the mapping given from the RAT file, or the 
//                    mapping of an earlier instruction's destination if there
//                    is a dependency. If the select bit is the same number as
//                    the instruction number, it should use the mapping from
//                    the ratfile, otherwise the number signifies which
//                    instruction's destination mapping should be used.
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module map (
    input  [6:0] inst0_rs1phys_i,
    input  [6:0] inst1_rs1phys_i,
    input  [6:0] inst2_rs1phys_i,
    input  [6:0] inst3_rs1phys_i,
    input  [6:0] inst0_rs2phys_i,
    input  [6:0] inst1_rs2phys_i,
    input  [6:0] inst2_rs2phys_i,
    input  [6:0] inst3_rs2phys_i,
    input  [6:0] inst0_rdphys_i,
    input  [6:0] inst1_rdphys_i,
    input  [6:0] inst2_rdphys_i,
    input  [6:0] inst3_rdphys_i,
    input  [6:0] inst0_oldrdphys_i,
    input  [6:0] inst1_oldrdphys_i,
    input  [6:0] inst2_oldrdphys_i,
    input  [6:0] inst3_oldrdphys_i,
    input  [1:0] inst0_rs1sel_i,
    input  [1:0] inst1_rs1sel_i,
    input  [1:0] inst2_rs1sel_i,
    input  [1:0] inst3_rs1sel_i,
    input  [1:0] inst0_rs2sel_i,
    input  [1:0] inst1_rs2sel_i,
    input  [1:0] inst2_rs2sel_i,
    input  [1:0] inst3_rs2sel_i,
    input  [1:0] inst0_rdsel_i,
    input  [1:0] inst1_rdsel_i,
    input  [1:0] inst2_rdsel_i,
    input  [1:0] inst3_rdsel_i,
    output [6:0] inst0_rs1phys_o,
    output [6:0] inst1_rs1phys_o,
    output [6:0] inst2_rs1phys_o,
    output [6:0] inst3_rs1phys_o,
    output [6:0] inst0_rs2phys_o,
    output [6:0] inst1_rs2phys_o,
    output [6:0] inst2_rs2phys_o,
    output [6:0] inst3_rs2phys_o,
    output [6:0] inst0_rdphys_o,
    output [6:0] inst1_rdphys_o,
    output [6:0] inst2_rdphys_o,
    output [6:0] inst3_rdphys_o
);


    assign inst0_rs1phys_o = inst0_rs1phys_i;
    assign inst0_rs2phys_o = inst0_rs2phys_i;
    assign inst1_rs1phys_o = inst1_rs1sel_i[1] ? 7'bxxxxxxx      : 
                            (inst1_rs1sel_i[0] ? inst1_rs1phys_i : inst0_rdphys_i);
    assign inst1_rs2phys_o = inst1_rs2sel_i[1] ? 7'bxxxxxxx      : 
                            (inst1_rs2sel_i[0] ? inst1_rs2phys_i : inst0_rdphys_i);
    assign inst2_rs1phys_o = inst2_rs1sel_i[1] ? 
                            (inst2_rs1sel_i[0] ? 7'bxxxxxxx      : inst2_rs1phys_i):
                            (inst2_rs1sel_i[0] ? inst1_rdphys_i  : inst0_rdphys_i );
    assign inst2_rs2phys_o = inst2_rs2sel_i[1] ? 
                            (inst2_rs2sel_i[0] ? 7'bxxxxxxx      : inst2_rs2phys_i):
                            (inst2_rs2sel_i[0] ? inst1_rdphys_i  : inst0_rdphys_i );
    assign inst3_rs1phys_o = inst3_rs1sel_i[1] ?
                            (inst3_rs1sel_i[0] ? inst3_rs1phys_i : inst2_rdphys_i):
                            (inst3_rs1sel_i[0] ? inst1_rdphys_i  : inst0_rdphys_i);
    assign inst3_rs2phys_o = inst3_rs2sel_i[1] ?
                            (inst3_rs2sel_i[0] ? inst3_rs2phys_i : inst2_rdphys_i):
                            (inst3_rs2sel_i[0] ? inst1_rdphys_i  : inst0_rdphys_i);
                
    assign inst0_rdphys_o  = inst0_oldrdphys_i; 
    assign inst1_rdphys_o  = inst1_rdsel_i[1] ? 7'bxxxxxxx       :
                            (inst1_rdsel_i[0] ? inst1_oldrdphys_i: inst0_rdphys_i); 
    assign inst2_rdphys_o  = inst2_rdsel_i[1] ? 
                            (inst2_rdsel_i[0] ? 7'bxxxxxxx       : inst2_oldrdphys_i):
                            (inst2_rdsel_i[0] ? inst1_rdphys_i   : inst0_rdphys_i   );
    assign inst3_rdphys_o  = inst3_rdsel_i[1] ?
                            (inst3_rdsel_i[0] ? inst3_oldrdphys_i: inst2_rdphys_i):
                            (inst3_rdsel_i[0] ? inst1_rdphys_i   : inst0_rdphys_i);                     

endmodule
