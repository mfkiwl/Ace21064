//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : btb_way.v
//  Author      : ejune@aureage.com
//                
//  Description : Branch Target Buffer
//                Maintain a table of branch targets and other information
//                about recently branches
//                width 129
// (valid,tag,branch position,branch type,branch taken addr, 2bit counter, ras conrtol)
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
  // read BTB
  input wire [63:0]      pc_f0_i,      // The PC value to be used to access the BTB
  // update BTB -- fetch1
  input wire            btb_sp_we_i,     // btb speculate write enable
  input wire [ 2:0]     btb_sp_brpos_i,  // btb speculate branch position
  input wire [ 1:0]     btb_sp_brtyp_i,  // btb speculate branch type
  input wire [63:0]     btb_sp_brpc_i,   // btb speculate pc_in from fetch1
  input wire [63:0]     btb_sp_brtar_i,  // btb speculate branch taken address
  input wire [1:0]      ras_ctl_i,

  input wire            btb_rt_we_i,     // btb retire write enable
  input wire            btb_rt_brdir_i,  // btb retire branch directory
  input wire [63:0]     btb_rt_brpc_i,   // btb retire bundle pc


  input wire [63:0]      taken_addr_i,
  output reg [ 2:0]      btb_br_pos_o,     // the position of the first branch in the bundle
  output reg [ 1:0]      btb_br_typ_o,     // the type of branch
  output reg [63:0]      btb_br_tar_o,     // the previously calculated target of the branch
  output reg             btb_br_dir_o,     // branch direction(condition) speculation
  output reg [ 1:0]      btb_ras_ctl_o,
  output reg             btb_hit_f0_o,     // indicates whether an entry exists for this PC
  output wire            btb_hit_f1_o
);
  integer   i;
  localparam BTB_CNT_INIT=2'b01;

  // these are the values stored in the BTB
  reg [0:255]           btb_valid;
  reg [53:0]            btb_tag        [0:255];  // also called BIA
  reg [2:0]             btb_br_pos     [0:255];
  reg [1:0]             btb_br_typ     [0:255];
  reg [63:0]            btb_br_tar     [0:255];  // also called BTA
  reg [1:0]             btb_cnt        [0:255];
  reg [1:0]             btb_ras_ctl    [0:255];

  wire index[7:0]       = pc_f0_i[9:2];
  wire tag[53:0]        = pc_f0_i[63:10];
  // set temp variables for new entries from fetch1
  wire pc_fetch1[63:0]    = btb_sp_brpc_i;
  wire index_fetch1[7:0]  = pc_fetch1[9:2];
  wire tag_fetch1[53:0]   = pc_fetch1[63:10];
  // set temp variables for btb updates from retire stage
  wire pc_retire[63:0] = btb_rt_brpc_i;
  wire index_retire[7:0]  = pc_retire[2+7:2];
  wire tag_retire[53:0]   = pc_retire[63:10];

  // new entry coming in that matches requested entry, bypass it
  wire btb_sp_bypass_en =   (btb_sp_we_i == 1'b1) &&
                           ((btb_valid[index_fetch1] != 1'b1) ||
                            (tag_fetch1 != btb_tag[index_fetch1])) && 
                            (pc_f0_i == pc_fetch1);
                       
  // entry being updated, pass along the info
  wire btb_cm_bypass_en =   (btb_rt_we_i == 1'b1) &&
                            (pc_f0_i == pc_retire) &&
                           ((btb_valid[index_retire] == 1'b1) &&
                            (btb_tag[index_retire] == tag));

  // if this PC's tag matches the tag stored in the BTB then it is a hit
  wire btb_hit_valid   =    (tag == btb_tag[index]) && btb_valid[index];

  // cm bypass btb prediction result // only decrement on NT conditional branches
  wire btb_cm_pred[1:0]=  (btb_rt_brdir_i == 1'b1) ? incs(btb_cnt[index])
                         :(btb_br_typ[index] == `BR_COND) ? decs(btb_cnt[index])
                         : btb_cnt[index];

  // only decrement on NT conditional branches
  wire btb_rt_pred[1:0]=  (btb_rt_brdir_i == 1'b1) ? incs(btb_cnt[index_retire])
                         :(btb_br_typ[index_retire] == `BR_COND) ? decs(btb_cnt[index_retire])
                         : btb_cnt[index_retire];

  // whenever the pc_f0_i changes, read from the BTB
  // and calculate new output signals
  always @ ( * )
  begin: BTBReadBlock
    if (btb_sp_bypass_en) begin
      btb_hit_f0_o  = 1'b1;
      btb_br_pos_o  = btb_sp_brpos_i;
      btb_br_typ_o  = btb_sp_brtyp_i;
      btb_br_tar_o  = btb_sp_brtar_i;
      btb_ras_ctl_o = ras_ctl_i;
      btb_br_dir_o  = (BTB_CNT_INIT >= 2'b10) ? 1'b1 : 1'b0;
    end
    else if (btb_cm_bypass_en) begin
      btb_hit_f0_o          = 1'b1;
      btb_br_pos_o       = btb_br_pos[index];
      btb_br_typ_o       = btb_br_typ[index];
      btb_br_tar_o   = taken_addr_i;
      btb_ras_ctl_o      = btb_ras_ctl[index];
      btb_br_dir_o         = btb_cm_pred[1];
    end
    else if (btb_hit_valid) begin
      btb_hit_f0_o          = 1'b1;
      btb_br_pos_o       = btb_br_pos[index];
      btb_br_typ_o       = btb_br_typ[index];
      btb_br_tar_o   = btb_br_tar[index];
      btb_ras_ctl_o      = btb_ras_ctl[index];
      btb_br_dir_o         = (btb_cnt[index] >= 2'b10) ? 1'b1 : 1'b0; 
    end
    else begin
      btb_hit_f0_o          =  1'b0;
      btb_br_pos_o       =  3'h0;
      btb_br_typ_o       =  2'h0;
      btb_br_tar_o   = 64'h0;
      btb_ras_ctl_o      =  2'h0;
      btb_br_dir_o         =  1'b0;
    end
  end

  // if there's no valid entry OR the tags are different, write the entry
  wire btb_sp_we = btb_sp_we_i && // btb write enable
                  (!btb_valid[index_fetch1] || (tag_fetch1 != btb_tag[index_fetch1]));

  // if the entry is valid and the tags match, update the entry
  wire btb_cm_we = btb_rt_we_i && // btb update enable
                  (btb_valid[index_retire] && (btb_tag[index_retire] == tag_retire));

  // add or update a btb entry
  always @(posedge clock or negedge reset_n)
  begin: BTBWriteBlock
    if (!reset_n)
      for (i = 0; i < 256; i=i+1) begin
        btb_valid[i]    <=  1'b0;
        btb_tag[i]      <= 54'h0;
        btb_br_pos[i]   <=  3'h0;
        btb_br_typ[i]   <=  2'h0;
        btb_br_tar[i]   <= 64'h0;
        btb_cnt[i]      <= BTB_CNT_INIT;
        btb_ras_ctl[i]  <=  2'h0;
      end
    else if (btb_sp_we) begin // write a new entry into the btb
      btb_valid[index_fetch1]       <= 1'b1;
      btb_tag[index_fetch1]         <= tag_fetch1;
      btb_br_pos[index_fetch1]      <= btb_sp_brpos_i;
      btb_br_typ[index_fetch1]      <= btb_sp_brtyp_i;
      btb_br_tar[index_fetch1]      <= btb_sp_brtar_i;
      btb_ras_ctl[index_fetch1]     <= ras_ctl_i;
      btb_cnt[index_fetch1]         <= (btb_sp_brtyp_i == `BR_COND) ? BTB_CNT_INIT : 2'b11;
      // any non-conditional branch is always taken
    end
    else if (btb_cm_we) begin // whenever retire wants to update an entry
      btb_cnt[index_retire] <= btb_rt_pred;
      // we only need to update the taken addr if it's a register jump
      if (btb_br_typ[index_retire] == `BR_INDIR_RAS || btb_br_typ[index_retire] == `BR_INDIR_PC)
        btb_br_tar[index_retire] <= taken_addr_i;
    end
  end

  assign btb_hit_f1_o = btb_valid[index_fetch1] && ( btb_tag[index_fetch1] == tag_fetch1 );



// helper function: saturated increment
function [1:0] incs;
  input [1:0] prev;
  reg [1:0] temp;
  begin
    temp = prev + 1;
    if (temp != 'b0)
      incs = temp;      // increment
    else
      incs = prev;      // saturate
  end
endfunction

// helper function: saturated decrement
function [1:0] decs;
  input [1:0] prev;
  begin
    if (prev != 'b0)
      decs = prev - 1;      // decrement
    else
      decs = prev;      // saturate
  end
endfunction

endmodule

