////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ssit.v
//  Author      : ejune@aureage.com
//                
//  Description : This file contains a store set ID table for memory dependence prediction
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
/////////////////////////////////////////////////////////////////////////////////////////
module ssit(
    input         clock,
    input         reset_n,
    input [11:0]  index0_in,
    input [11:0]  index1_in,
    input [11:0]  index2_in,
    input [11:0]  index3_in,
    input [11:0]  update_index1_in,
    input [11:0]  update_index2_in,
    input         update_v_in,
    
    output [6:0]  ssid0_out,
    output [6:0]  ssid1_out,
    output [6:0]  ssid2_out,
    output [6:0]  ssid3_out,
    output        valid0_out,
    output        valid1_out,
    output        valid2_out,
    output        valid3_out
);
// next ssid to be allocated
reg [6:0] ssid_f;
// regs for SSIT table update
reg        update_stage_f;
reg [6:0]  tmp_ssid1;
reg [6:0]  tmp_ssid2;
reg        tmp_ssid1_v;
reg        tmp_ssid2_v;
reg [11:0] tmp_index1;
reg [11:0] tmp_index2;

wire [6:0] update_port0_data;
wire [6:0] update_port1_data;
wire       update_port0_we;
wire       update_port1_we;
wire [6:0] ssid_new;

reg [6:0] ssit_f [4096-1 :0];
reg       ssit_v_f [4096-1 :0];


/* 
 * This is the more readable version of the above code, except this version
 * deletes all old entries in the SSIT that have the same data as a newly inserted
 * store set (in the "invalidate all current entries with new ssid" code)
 */
assign ssid0_out  = ssit_f[index0_in];
assign ssid1_out  = ssit_f[index1_in];
assign ssid2_out  = ssit_f[index2_in];
assign ssid3_out  = ssit_f[index3_in];

assign valid0_out = ssit_v_f[index0_in];
assign valid1_out = ssit_v_f[index1_in];
assign valid2_out = ssit_v_f[index2_in];
assign valid3_out = ssit_v_f[index3_in];

integer i;
always @(posedge clock or negedge reset_n)
begin
  if (!reset_n)
    for (i=0; i< 4096 ; i=i+1)
    begin
      ssit_f[i] <= 0;
      ssid_f    <= 0;
      ssit_v_f[i] <= 1'b0;
      update_stage_f <= 1'b0;
    end
  // if in the second stage of the update, do it!
  else if (update_stage_f)
    begin
    update_stage_f <= 1'b0;
    case ({tmp_ssid1_v, tmp_ssid2_v})
      2'b00:
            begin
            // invalidate all current entries with new ssid
            for (i=0; i<4096; i=i+1)
              if (ssit_f[i] == ssid_f)
                ssit_v_f[i] <= 1'b0;
            // create new store set group
            ssit_f[tmp_index1] <= ssid_f;
            ssit_f[tmp_index2] <= ssid_f;
            ssit_v_f[tmp_index1] <= 1'b1;
            ssit_v_f[tmp_index2] <= 1'b1;
            // increment the new ssid pointer
            ssid_f <= ssid_f + 1;
            end
      2'b01:
            begin
            ssit_f[tmp_index1] <= tmp_ssid2;
            ssit_v_f[tmp_index1] <= 1'b1;
            end
      2'b10:
            begin
            ssit_f[tmp_index2] <= tmp_ssid1;
            ssit_v_f[tmp_index2] <= 1'b1;
            end
      2'b11:
            begin
            if (tmp_ssid1 < tmp_ssid2)
              ssit_f[tmp_index2] <= tmp_ssid1;
            else
              ssit_f[tmp_index1] <= tmp_ssid2;
            end
      default: $display("Error in updating the SSIT");
    endcase
    end
  // update the SSIT!
  else if (update_v_in)
    begin
    update_stage_f <= 1'b1;
    // update_index1_in -> load index
    // update_index2_in -> store index
    // but it really doesn't matter
    tmp_index1 <= update_index1_in;
    tmp_index2 <= update_index2_in;
    tmp_ssid1 <= ssit_f[update_index1_in];
    tmp_ssid2 <= ssit_f[update_index2_in];
    tmp_ssid1_v <= ssit_v_f[update_index1_in];
    tmp_ssid2_v <= ssit_v_f[update_index2_in];
    $storesets_verif(update_index1_in, update_index2_in);
    end
end

endmodule
