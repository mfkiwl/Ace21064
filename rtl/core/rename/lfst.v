////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : lfst.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains a last fetched store table for memory
//                dependence prediction.
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module lfst(
    input        clock,
    input        reset_n,
    input        flush_in,
    input [ 6:0] ssid0_in,
    input [ 6:0] ssid1_in,
    input [ 6:0] ssid2_in,
    input [ 6:0] ssid3_in,
    input        valid0_in,
    input        valid1_in,
    input        valid2_in,
    input        valid3_in,
    input [14:0] update0_in,//[14:8] - ssid to update;[ 7:1] - register number to update with;0:vld
    input [14:0] update1_in,
    input [14:0] update2_in,
    input [14:0] update3_in,
    input [ 7:0] invalidate0_in,// [7:1] - register number to invalidate; 0 - valid bit
    input [ 7:0] invalidate1_in,
    	
    output wire [6:0] lfs0_out,
    output wire [6:0] lfs1_out,
    output wire [6:0] lfs2_out,
    output wire [6:0] lfs3_out,
    output reg        valid0_out,
    output reg        valid1_out,
    output reg        valid2_out,
    output reg        valid3_out
);


integer i;

reg [127 : 0] lfs_v_f;

  ram_8p #(7,128,7,0) lfst_ram(
          .data1_in(),
          .index1_in(ssid0_in),
          .we1_in(1'b0),
          .data2_in(),
          .index2_in(ssid1_in),
          .we2_in(1'b0),
          .data3_in(),
          .index3_in(ssid2_in),
          .we3_in(1'b0),
          .data4_in(),
          .index4_in(ssid3_in),
          .we4_in(1'b0),
          .data5_in(update0_in[7:1]),
          .index5_in(update0_in[14:8]),
          .we5_in(update0_in[0]),
          .data6_in(update1_in[7:1]),
          .index6_in(update1_in[14:8]),
          .we6_in(update1_in[0]),
          .data7_in(update2_in[7:1]),
          .index7_in(update2_in[14:8]),
          .we7_in(update2_in[0]),
          .data8_in(update3_in[7:1]),
          .index8_in(update3_in[14:8]),
          .we8_in(update3_in[0]),
          .clock(clock),
          .reset_n(reset_n),
          .data1_out(lfs0_out),
          .data2_out(lfs1_out),
          .data3_out(lfs2_out),
          .data4_out(lfs3_out),
          .data5_out(),
          .data6_out(),
          .data7_out(),
          .data8_out()
         );

always @ *
begin
  valid0_out = lfs_v_f[ssid0_in] && valid0_in;
  valid1_out = lfs_v_f[ssid1_in] && valid1_in;
  valid2_out = lfs_v_f[ssid2_in] && valid2_in;
  valid3_out = lfs_v_f[ssid3_in] && valid3_in;
end

always @(posedge clock or negedge reset_n)
begin
  if (!reset_n)
    lfs_v_f <= 128'b0;
  // on any flush, invalidate all entries
  else if (flush_in)
    lfs_v_f <= 128'b0;
  else
    begin
    if (update0_in[0])
      lfs_v_f[update0_in[14:8]] <= 1'b1;
    if (update1_in[0])
      lfs_v_f[update1_in[14:8]] <= 1'b1;
    if (update2_in[0])
      lfs_v_f[update2_in[14:8]] <= 1'b1;
    if (update3_in[0])
      lfs_v_f[update3_in[14:8]] <= 1'b1;
    end
end

/* similar code as above, but probably much more readable

always @ *
begin
  lfs0_out = lfs_f[ssid0_in];
  valid0_out = lfs_v_f[ssid0_in] && valid0_in;
  lfs1_out = lfs_f[ssid1_in];
  valid1_out = lfs_v_f[ssid1_in] && valid1_in;
  lfs2_out = lfs_f[ssid2_in];
  valid2_out = lfs_v_f[ssid2_in] && valid2_in;
  lfs3_out = lfs_f[ssid3_in];
  valid3_out = lfs_v_f[ssid3_in] && valid3_in;
end

always @(posedge clock or negedge reset_n)
begin
  if (!reset_n)
    for (i=0; i<128; i=i+1)
      begin
      lfs_f[i] <= 0;
      lfs_v_f[i] <= 1'b0;
      end
  // on any flush, invalidate all entries
  else if (flush_in)
    for (i=0; i<128; i=i+1)
      lfs_v_f[i] <= 1'b0;
  else
    for (i=0; i<128; i=i+1)
      begin
      // if a store is trying to update the LFST entry, let it
      // later stores in this instruction bundle have priority
      if (update3_in[0] && (update3_in[14:8] == i))
        begin
        lfs_f[i] <= update3_in[7:1];
        lfs_v_f[i] <= 1'b1;
        end
      else if (update2_in[0] && (update2_in[14:8] == i))
        begin
        lfs_f[i] <= update2_in[7:1];
        lfs_v_f[i] <= 1'b1;
        end
      else if (update1_in[0] && (update1_in[14:8] == i))
        begin
        lfs_f[i] <= update1_in[7:1];
        lfs_v_f[i] <= 1'b1;
        end
      else if (update0_in[0] && (update0_in[14:8] == i))
        begin
        lfs_f[i] <= update0_in[7:1];
        lfs_v_f[i] <= 1'b1;
        end
      // if a retiring store is trying to invalidate its entry..
      else if ((invalidate0_in[0] && (invalidate0_in[7:1] == lfs_f[i])) ||
               (invalidate1_in[0] && (invalidate1_in[7:1] == lfs_f[i])))
        lfs_v_f[i] <= 1'b0;
      end
end
*/


endmodule

