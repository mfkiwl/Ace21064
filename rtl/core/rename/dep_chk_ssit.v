////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ssit.v
//  Author      : ejune@aureage.com
//                
//  Description : This file identifies intra instruction bundle dependencies for
//                store set ids.
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module dep_chk_ssit(
    input [6:0] ssid0_i,
    input [6:0] ssid1_i,
    input [6:0] ssid2_i,
    input [6:0] ssid3_i,
    input       ssid0_vld_i,
    input       ssid1_vld_i,
    input       ssid2_vld_i,
    input       ssid3_vld_i,
    
    input       type0_i;        // 1 for stores
    input       type1_i;        // 1 for stores
    input       type2_i;        // 1 for stores
    
    output reg       ssid1sel_o;
    output reg [1:0] ssid2sel_o;
    output reg [1:0] ssid3sel_o;
);

// generate ssid1sel_o
always @ *
begin
  if ((ssid0_i == ssid1_i) && type0_i && ssid0_vld_i && ssid1_vld_i)
    ssid1sel_o = 1'b0;
  else
    ssid1sel_o = 1'b1;
end

// generate ssid2sel_o
always @ *
begin
  if ((ssid1_i == ssid2_i) && type1_i && ssid1_vld_i && ssid2_vld_i)
    ssid2sel_o = 2'b01;
  else if ((ssid0_i == ssid2_i) && type0_i && ssid0_vld_i && ssid2_vld_i)
    ssid2sel_o = 2'b00;
  else
    ssid2sel_o = 2'b10;
end

// generate ssid3sel_o
always @ *
begin
  if ((ssid2_i == ssid3_i) && type2_i && ssid2_vld_i && ssid3_vld_i)
    ssid3sel_o = 2'b10;
  else if ((ssid1_i == ssid3_i) && type1_i && ssid1_vld_i && ssid3_vld_i)
    ssid3sel_o = 2'b01;
  else if ((ssid0_i == ssid3_i) && type0_i && ssid0_vld_i && ssid3_vld_i)
    ssid3sel_o = 2'b00;
  else
    ssid3sel_o = 2'b11;
end

endmodule

