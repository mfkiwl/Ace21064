////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ssit.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains a store set Identifier table (SSIT) for memory
//                dependence prediction, which contains the store sets using
//                a common tag for each load and the stores in store set
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module ssit(
    input         clock,
    input         reset_n,
    input [11:0]  inst0_ssit_ridx_i,
    input [11:0]  inst1_ssit_ridx_i,
    input [11:0]  inst2_ssit_ridx_i,
    input [11:0]  inst3_ssit_ridx_i,
    input [11:0]  inst0_ssit_widx_i,
    input [11:0]  inst1_ssit_widx_i,
    input         ssit_we_i,
    
    output [6:0]  inst0_ssid_o,
    output [6:0]  inst1_ssid_o,
    output [6:0]  inst2_ssid_o,
    output [6:0]  inst3_ssid_o,
    output        inst0_ssid_vld_o,
    output        inst1_ssid_vld_o,
    output        inst2_ssid_vld_o,
    output        inst3_ssid_vld_o
);


endmodule
