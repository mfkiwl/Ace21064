////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : lfst.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains a last fetched store table (LFST) which
//                maintains dynamic information about the most recently
//                fetched store for each store set, the information in this
//                table is the inum of the store, which is a hardware pointer
//                that uniquely identifies the instance of each instruction in
//                flight 
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module lfst(
    input wire        clock,
    input wire        reset_n,
    input wire        flush_i,
    input wire [ 6:0] inst0_ssid_i,
    input wire [ 6:0] inst1_ssid_i,
    input wire [ 6:0] inst2_ssid_i,
    input wire [ 6:0] inst3_ssid_i,
    input wire        inst0_ssid_vld_i,
    input wire        inst1_ssid_vld_i,
    input wire        inst2_ssid_vld_i,
    input wire        inst3_ssid_vld_i,
    input wire        inst0_lfst_we_i,
    input wire        inst1_lfst_we_i,
    input wire        inst2_lfst_we_i,
    input wire        inst3_lfst_we_i,
    input wire [ 6:0] inst0_lfst_data_i,
    input wire [ 6:0] inst1_lfst_data_i,
    input wire [ 6:0] inst2_lfst_data_i,
    input wire [ 6:0] inst3_lfst_data_i,
    input wire [ 6:0] inst0_lfst_idx_i,
    input wire [ 6:0] inst1_lfst_idx_i,
    input wire [ 6:0] inst2_lfst_idx_i,
    input wire [ 6:0] inst3_lfst_idx_i,
    input wire        inst0_lfst_invld_i,
    input wire        inst1_lfst_invld_i,
    input wire [ 6:0] inst0_lfst_invld_idx_i,
    input wire [ 6:0] inst1_lfst_invld_idx_i,
    	
    output reg [ 6:0] inst0_lfs_o,
    output reg [ 6:0] inst1_lfs_o,
    output reg [ 6:0] inst2_lfs_o,
    output reg [ 6:0] inst3_lfs_o,
    output reg        inst0_lfs_vld_o,
    output reg        inst1_lfs_vld_o,
    output reg        inst2_lfs_vld_o,
    output reg        inst3_lfs_vld_o
);



reg [127:0] lfst_vld;
reg [127:0] lfst_array [0:6];


always @ *
begin
  inst0_lfs_o     = lfst_array[inst0_ssid_i];
  inst1_lfs_o     = lfst_array[inst1_ssid_i];
  inst2_lfs_o     = lfst_array[inst2_ssid_i];
  inst3_lfs_o     = lfst_array[inst3_ssid_i];

  inst0_lfs_vld_o = lfst_vld[inst0_ssid_i] && inst0_ssid_vld_i;
  inst1_lfs_vld_o = lfst_vld[inst1_ssid_i] && inst1_ssid_vld_i;
  inst2_lfs_vld_o = lfst_vld[inst2_ssid_i] && inst2_ssid_vld_i;
  inst3_lfs_vld_o = lfst_vld[inst3_ssid_i] && inst3_ssid_vld_i;
end

integer i;
always @ ( posedge clock or negedge reset_n )
begin
    if (!reset_n)
        for (i=0; i<128; i=i+1)
        begin
            lfst_vld[i]   <= 1'b0;
            lfst_array[i] <= 7'b0;
        end
    // on any flush, invalidate all entries
    else if (flush_i)
        for (i=0; i<128; i=i+1)
            lfst_vld[i] <= 1'b0;
    else
        for (i=0; i<128; i=i+1)
        begin
            // if a store is trying to update the LFST entry, let it
            // later stores in this instruction bundle have priority
            if (inst3_lfst_we_i && (inst3_lfst_idx_i == i))
            begin
              lfst_vld[i]   <= 1'b1;
              lfst_array[i] <= inst3_lfst_data_i;
            end
            else if (inst2_lfst_we_i && (inst2_lfst_idx_i == i))
            begin
              lfst_vld[i]   <= 1'b1;
              lfst_array[i] <= inst2_lfst_data_i;
            end
            else if (inst1_lfst_we_i && (inst1_lfst_idx_i == i))
            begin
              lfst_vld[i]   <= 1'b1;
              lfst_array[i] <= inst1_lfst_data_i;
            end
            else if (inst0_lfst_we_i && (inst0_lfst_idx_i == i))
            begin
              lfst_vld[i]   <= 1'b1;
              lfst_array[i] <= inst0_lfst_data_i;
            end
            // if a retiring store is trying to invalidate its entry..
            else if ((inst0_lfst_invld_i && (inst0_lfst_invld_idx_i == lfst_array[i])) ||
                     (inst1_lfst_invld_i && (inst1_lfst_invld_idx_i == lfst_array[i])))
              lfst_vld[i]   <= 1'b0;
        end
end

endmodule
