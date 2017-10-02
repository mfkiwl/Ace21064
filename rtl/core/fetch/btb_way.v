//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : btb_way.v
//  Author      : ejune@aureage.com
//                
//  Description : Branch Target Buffer
//                Maintain a table of branch targets and other information
//                about recently branches
//                data array width 73
//                tag array width 18 (64-8)/4
// (valid,tag_f0,branch position,branch type,branch taken addr, 2bit counter, ras conrtol)
//                depth 256 (2^8)
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module btb_way (
  input wire             clock,
  input wire             reset_n,
  input wire [63:0]      pc_f0_i,           // The PC value to be used to access the BTB
  input wire             btb_we_spec_i,     // btb speculate write enable
  input wire [ 2:0]      btb_brpos_spec_i,  // btb speculate branch position
  input wire [ 1:0]      btb_brtyp_spec_i,  // btb speculate branch type
  input wire [63:0]      btb_brpc_spec_i,   // btb speculate pc_in from fetch1
  input wire [63:0]      btb_brtar_spec_i,  // btb speculate branch taken address

  input wire             btb_we_cert_i,     // btb retire write enable
  input wire             btb_brdir_cert_i,  // btb retire branch directory
  input wire [63:0]      btb_brtar_cert_i,  // btb retire branch target
  input wire [63:0]      btb_brpc_cert_i,   // btb retire branch pc

  input wire [ 1:0]      btb_rasctl_i,

  output reg [ 1:0]      btb_rasctl_f0_o,
  output reg [ 2:0]      btb_brpos_f0_o,     // the position of the first branch in the bundle
  output reg [ 1:0]      btb_brtyp_f0_o,     // the type of branch
  output reg [63:0]      btb_brtar_f0_o,     // the previously calculated target of the branch
  output reg             btb_brdir_f0_o,     // branch direction(condition) speculation
  output reg             btb_hit_f0_o,       // indicates whether an entry exists for this PC
  output wire            btb_hit_f1_o
);
  integer   i;
  localparam BTB_CNT_INIT=2'b01;

  // these are the values stored in the BTB
  //
  // Also named BIA (branch instruction address)
  // which should be 64-10 = 54 bits, to reduce area and improve
  // performance the tag(BIA) is xored by each 18bits
  reg [17:  0] btb_tag     [0:255];  
  reg [ 0:255] btb_valid;
  reg [ 1:  0] btb_ras_ctl [0:255];
  reg [ 1:  0] btb_cnt     [0:255];
  reg [ 2:  0] btb_br_pos  [0:255];
  reg [ 1:  0] btb_br_typ  [0:255];
  reg [63:  0] btb_br_tar  [0:255];  // also called BTA (branch target address)

  wire idx_f0[7:0]    = pc_f0_i[9:2];   // 256 entries each way (one instruction per entry)
  wire tag_f0[17:0]   = {pc_f0_i[63:46] ^ pc_f0_i[45:28] ^ pc_f0_i[27:10]}; // least used as tag_f0 data

  // set temp variables for new entries from fetch1
  wire idx_spec[7:0]    = btb_brpc_spec_i[ 9: 2];
  wire tag_spec[53:0]   = btb_brpc_spec_i[63:10];
  // set temp variables for btb updates from retire stage
  wire idx_cert[7:0]    = btb_brpc_cert_i[ 9: 2];
  wire tag_cert[53:0]   = btb_brpc_cert_i[63:10];

  // new entry coming in that matches requested entry, bypass it
  // speculative update btb enable, and 
  wire btb_bypass_spec = (btb_we_spec_i == 1'b1) && (pc_f0_i == btb_brpc_spec_i) &&
                          ((btb_valid[idx_spec] != 1'b1) || (tag_spec != btb_tag[idx_spec]));                       
  // entry being updated, pass along the info
  wire btb_bypass_cert = (btb_we_cert_i == 1'b1) && (pc_f0_i == btb_brpc_cert_i) &&
                          ((btb_valid[idx_cert] == 1'b1) && (btb_tag[idx_cert] == tag_f0));

  // if this PC's tag matches the tag stored in the BTB then it is a hit
  wire btb_hit      = (tag_f0 == btb_tag[idx_f0]) && btb_valid[idx_f0];

  // cm bypass btb prediction result, only decrement on NT conditional branches
  wire btb_pred_f0[1:0] = (btb_brdir_cert_i == 1'b1) ? sat_inc(btb_cnt[idx_f0]) :
                          ((btb_br_typ[idx_f0] == `BR_COND) ? sat_dec(btb_cnt[idx_f0])
                                                            : btb_cnt[idx_f0]);

  // only decrement on NT conditional branches
  wire btb_pred_cert[1:0] = (btb_brdir_cert_i == 1'b1) ? sat_inc(btb_cnt[idx_cert]) :
                          ((btb_br_typ[idx_cert] == `BR_COND) ? sat_dec(btb_cnt[idx_cert])
                                                            : btb_cnt[idx_cert]);

  // whenever the pc_f0_i changes, read from the BTB
  // and calculate new output signals
  always @ * 
  begin: BTBReadBlock
    btb_hit_f0_o   =  1'b0;
    btb_rasctl_f0_o  =  2'h0;
    btb_brpos_f0_o   =  3'h0;
    btb_brtyp_f0_o   =  2'h0;
    btb_brtar_f0_o   = 64'h0;
    btb_brdir_f0_o   =  1'b0;
    if (btb_bypass_spec) begin
      btb_hit_f0_o  = 1'b1;
      btb_rasctl_f0_o = btb_rasctl_i;
      btb_brpos_f0_o  = btb_brpos_spec_i;
      btb_brtyp_f0_o  = btb_brtyp_spec_i;
      btb_brtar_f0_o  = btb_brtar_spec_i;
      btb_brdir_f0_o  = (BTB_CNT_INIT >= 2'b10) ? 1'b1 : 1'b0;
    end
    else if (btb_bypass_cert) begin
      btb_hit_f0_o  = 1'b1;
      btb_brtar_f0_o  = btb_brtar_cert_i;
      btb_brpos_f0_o  = btb_br_pos[idx_f0];
      btb_brtyp_f0_o  = btb_br_typ[idx_f0];
      btb_rasctl_f0_o = btb_ras_ctl[idx_f0];
      btb_brdir_f0_o  = btb_pred_f0[1];
    end
    else if (btb_hit) begin
      btb_hit_f0_o  = 1'b1;
      btb_rasctl_f0_o = btb_ras_ctl[idx_f0];
      btb_brpos_f0_o  = btb_br_pos[idx_f0];
      btb_brtyp_f0_o  = btb_br_typ[idx_f0];
      btb_brtar_f0_o  = btb_br_tar[idx_f0];
      btb_brdir_f0_o  = (btb_cnt[idx_f0] >= 2'b10) ? 1'b1 : 1'b0; 
    end
  end

  // if there's no valid entry OR the tags are different, write the entry
  wire btb_we_spec = btb_we_spec_i && // btb write enable
                    (!btb_valid[idx_spec] || (tag_spec != btb_tag[idx_spec]));

  // if the entry is valid and the tags match, update the entry
  wire btb_we_cert = btb_we_cert_i && // btb update enable
                    (btb_valid[idx_cert] && (tag_cert == btb_tag[idx_cert]));

  // add or update a btb entry
  always @(posedge clock or negedge reset_n)
  begin: BTBWriteBlock
    if (!reset_n)
      for (i = 0; i < 256; i=i+1) begin
        btb_tag[i]      <= 54'h0;
        btb_valid[i]    <=  1'b0;
        btb_cnt[i]      <= BTB_CNT_INIT;
        btb_ras_ctl[i]  <=  2'h0;
        btb_br_pos[i]   <=  3'h0;
        btb_br_typ[i]   <=  2'h0;
        btb_br_tar[i]   <= 64'h0;
      end
    else if (btb_we_spec) begin // write a new entry into the btb
      btb_tag[idx_spec]         <= tag_spec;
      btb_valid[idx_spec]       <= 1'b1;
      btb_cnt[idx_spec]         <= (btb_brtyp_spec_i == `BR_COND) ? BTB_CNT_INIT : 2'b11;
      btb_ras_ctl[idx_spec]     <= btb_rasctl_i;
      btb_br_pos[idx_spec]      <= btb_brpos_spec_i;
      btb_br_typ[idx_spec]      <= btb_brtyp_spec_i;
      btb_br_tar[idx_spec]      <= btb_brtar_spec_i;
      // any non-conditional branch is always taken
    end
    else if (btb_we_cert) begin // whenever retire wants to update an entry
      btb_cnt[idx_cert] <= btb_pred_cert;
      // we only need to update the taken addr if it's a register jump
      if (btb_br_typ[idx_cert] == `BR_INDIRRET || btb_br_typ[idx_cert] == `BR_INDIR)
        btb_br_tar[idx_cert] <= btb_brtar_cert_i;
    end
  end

  assign btb_hit_f1_o = btb_valid[idx_spec] && ( btb_tag[idx_spec] == tag_spec );

  /////////////////////////////////////////////////////////////
  // saturated increment
  function [1:0] sat_inc;
    input [1:0] prev;
    reg [1:0] temp;
    begin
      temp = prev + 1;
      if (temp != 'b0)
        sat_inc = temp;      // increment
      else
        sat_inc = prev;      // saturate
    end
  endfunction
  
  // saturated decrement
  function [1:0] sat_dec;
    input [1:0] prev;
    begin
      if (prev != 'b0)
        sat_dec = prev - 1;  // decrement
      else
        sat_dec = prev;      // saturate
    end
  endfunction

endmodule

