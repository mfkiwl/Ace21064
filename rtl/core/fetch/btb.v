//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : btb.v
//  Author      : ejune@aureage.com
//                
//  Description : Branch Target Buffer
//                BTB is a 4way-associative cache, 129x256 for eatch way.
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module btb (
  // inputs
  input wire                      clock,
  input wire                      reset_n,
  // read BTB
  input wire [ 63:0]              pc_f0_i,
  // update BTB -- fetch1
  input wire               btb_sp_we_i,
  input wire [ 2:0]        btb_sp_brpos_i,
  input wire [ 1:0]        btb_sp_brtyp_i,
  input wire [63:0]        btb_sp_brpc_i,
  input wire [63:0]        btb_sp_brtar_i,

  input wire [ 1:0]        ras_ctrl_in,
  // update BTB -- retire/fetch1
  input wire                      btb_rt_we_i,
  input wire                      btb_rt_brdir_i,
  input wire [63:0]               btb_rt_brpc_i,

  input wire [ 63:0]              taken_addr_in,
  // outputs
  output reg                      btb_hit_o,       // btb hit flag
  output reg [  2:0]              btb_br_pos_o,    // branch instruction position in a fetch bundle
  output reg [  1:0]              btb_br_typ_o,    // branch type
  output reg [ 63:0]              btb_br_tar_o,    // branch target
  output reg [  1:0]              btb_ras_ctl_o,
  output reg                      btb_br_dir_o     // branch direction(condition)
);

  integer i;

  // wires coming back from the banks
  wire [ 2:0] pos0,         pos1,         pos2,         pos3;
  wire [ 1:0] ras0,         ras1,         ras2,         ras3;
  wire [ 1:0] type0,        type1,        type2,        type3;
  wire [63:0] addr0,        addr1,        addr2,        addr3;
  wire        pred0,        pred1,        pred2,        pred3;
  wire        btb_hit_f0_0, btb_hit_f0_1, btb_hit_f0_2, btb_hit_f0_3;
  wire        btb_hit_f1_0, btb_hit_f1_1, btb_hit_f1_2, btb_hit_f1_3;

  // lru state
  reg [255:0] lru1;  // btb(129x256) depth 
  reg [255:0] lru01; // btb(129x256) depth 
  reg [255:0] lru23; // btb(129x256) depth 
  reg btb_we_f1_0;
  reg btb_we_f1_1;
  reg btb_we_f1_2;
  reg btb_we_f1_3;

  wire [7:0] index_f1 = btb_sp_brpc_i[9:2];
  wire [7:0] index_f0 = pc_f0_i[9:2];

  // instantiate the four ways
  btb_way btb_way_inst0(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_sp_we_i       (btb_we_f1_0),
    .btb_sp_brpos_i    (btb_sp_brpos_i),
    .btb_sp_brtyp_i    (btb_sp_brtyp_i),
    .btb_sp_brpc_i     (btb_sp_brpc_i ),
    .btb_sp_brtar_i    (btb_sp_brtar_i),
    .ras_ctl_i         (ras_ctrl_in     ),
    .btb_rt_we_i       (btb_rt_we_i   ),
    .btb_rt_brdir_i    (btb_rt_brdir_i),
    .btb_rt_brpc_i     (btb_rt_brpc_i ),
    .taken_addr_i      (taken_addr_in   ),
    .btb_hit_f0_o      (btb_hit_f0_0            ),
    .btb_br_pos_o      (pos0            ),
    .btb_br_typ_o      (type0           ),
    .btb_br_tar_o  (addr0           ),
    .btb_ras_ctl_o     (ras0            ),
    .btb_br_dir_o        (pred0           ),
    .btb_hit_f1_o      (btb_hit_f1_0        )
  );

  btb_way btb_way_inst1(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_sp_we_i       (btb_we_f1_1),
    .btb_sp_brpos_i    (btb_sp_brpos_i),
    .btb_sp_brtyp_i    (btb_sp_brtyp_i),
    .btb_sp_brpc_i     (btb_sp_brpc_i ),
    .btb_sp_brtar_i    (btb_sp_brtar_i),
    .ras_ctl_i         (ras_ctrl_in     ),
    .btb_rt_we_i       (btb_rt_we_i   ),
    .btb_rt_brdir_i    (btb_rt_brdir_i),
    .btb_rt_brpc_i     (btb_rt_brpc_i ),
    .taken_addr_i      (taken_addr_in   ),
    .btb_hit_f0_o      (btb_hit_f0_1            ),
    .btb_br_pos_o      (pos1            ),
    .btb_br_typ_o      (type1           ),
    .btb_br_tar_o  (addr1           ),
    .btb_ras_ctl_o     (ras1            ),
    .btb_br_dir_o        (pred1           ),
    .btb_hit_f1_o      (btb_hit_f1_1        )
  );

  btb_way btb_way_inst2(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_sp_we_i       (btb_we_f1_2),
    .btb_sp_brpos_i    (btb_sp_brpos_i),
    .btb_sp_brtyp_i    (btb_sp_brtyp_i),
    .btb_sp_brpc_i     (btb_sp_brpc_i ),
    .btb_sp_brtar_i    (btb_sp_brtar_i),
    .ras_ctl_i         (ras_ctrl_in     ),
    .btb_rt_we_i       (btb_rt_we_i   ),
    .btb_rt_brdir_i    (btb_rt_brdir_i),
    .btb_rt_brpc_i     (btb_rt_brpc_i ),
    .taken_addr_i      (taken_addr_in   ),
    .btb_hit_f0_o      (btb_hit_f0_2            ),
    .btb_br_pos_o      (pos2            ),
    .btb_br_typ_o      (type2           ),
    .btb_br_tar_o  (addr2           ),
    .btb_ras_ctl_o     (ras2            ),
    .btb_br_dir_o        (pred2           ),
    .btb_hit_f1_o      (btb_hit_f1_2        )
  );

  btb_way btb_way_inst3(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_sp_we_i       (btb_we_f1_3),
    .btb_sp_brpos_i    (btb_sp_brpos_i),
    .btb_sp_brtyp_i    (btb_sp_brtyp_i),
    .btb_sp_brpc_i     (btb_sp_brpc_i ),
    .btb_sp_brtar_i    (btb_sp_brtar_i),
    .ras_ctl_i         (ras_ctrl_in     ),
    .btb_rt_we_i       (btb_rt_we_i   ),
    .btb_rt_brdir_i    (btb_rt_brdir_i),
    .btb_rt_brpc_i     (btb_rt_brpc_i ),
    .taken_addr_i      (taken_addr_in   ),
    .btb_hit_f0_o      (btb_hit_f0_3            ),
    .btb_br_pos_o      (pos3            ),
    .btb_br_typ_o      (type3           ),
    .btb_br_tar_o  (addr3           ),
    .btb_ras_ctl_o     (ras3            ),
    .btb_br_dir_o        (pred3           ),
    .btb_hit_f1_o      (btb_hit_f1_3        )
  );

  // route the outputs according to the hit signals
  always @(*)
  begin
    case ({btb_hit_f0_0,btb_hit_f0_1,btb_hit_f0_2,btb_hit_f0_3})
      4'b0000: begin
        btb_hit_o          = 1'b0;
        btb_br_pos_o    = 3'b000;
        btb_br_typ_o   = 2'b00;
        btb_br_tar_o = 64'b0;
        btb_ras_ctl_o     = 2'b0;
        btb_br_dir_o   = 1'b0;
      end
      4'b1000: begin
        btb_hit_o          = 1'b1;
        btb_br_pos_o    = pos0;
        btb_br_typ_o   = type0;
        btb_br_tar_o = addr0;
        btb_ras_ctl_o     = ras0;
        btb_br_dir_o   = pred0;
      end
      4'b0100: begin
        btb_hit_o          = 1'b1;
        btb_br_pos_o    = pos1;
        btb_br_typ_o   = type1;
        btb_br_tar_o = addr1;
        btb_ras_ctl_o     = ras1;
        btb_br_dir_o   = pred1;
      end
      4'b0010: begin
        btb_hit_o          = 1'b1;
        btb_br_pos_o    = pos2;
        btb_br_typ_o   = type2;
        btb_br_tar_o = addr2;
        btb_ras_ctl_o     = ras2;
        btb_br_dir_o   = pred2;
      end
      4'b0001: begin
        btb_hit_o          = 1'b1;
        btb_br_pos_o    = pos3;
        btb_br_typ_o   = type3;
        btb_br_tar_o = addr3;
        btb_ras_ctl_o     = ras3;
        btb_br_dir_o   = pred3;
      end
      default: begin
        // if the current read bundlepc is the same as the new entry to be written,
        // all the banks will match, since they'll all bypass the data.  so gate
        // the error message with this check
        if (pc_f0_i != btb_sp_brpc_i)
        btb_hit_o = 1'b0;
        btb_br_pos_o = 3'b000;
        btb_br_typ_o = 2'b00;
        btb_br_tar_o = 64'b0;
        btb_ras_ctl_o = 2'b00;
        btb_br_dir_o = 1'b0;
        end
    endcase
  end

  // based on whether any of the ways have the new entry already,
  // set the write bits for each way
  always @( * )
  begin
    btb_we_f1_0 = 1'b0;
    btb_we_f1_1 = 1'b0;
    btb_we_f1_2 = 1'b0;
    btb_we_f1_3 = 1'b0;
    if (btb_sp_we_i)
      casex ({btb_hit_f1_0,btb_hit_f1_1,btb_hit_f1_2,btb_hit_f1_3,lru1[index_f1],lru01[index_f1],lru23[index_f1]})
        // write miss LRU strategy used. 
        7'b000000?: btb_we_f1_0 = 1'b1; //
        7'b000001?: btb_we_f1_1 = 1'b1;
        7'b00001?0: btb_we_f1_2 = 1'b1;
        7'b00001?1: btb_we_f1_3 = 1'b1;
        // write hit, just replace current entry.
        7'b0001???: btb_we_f1_3 = 1'b1;
        7'b0010???: btb_we_f1_2 = 1'b1;
        7'b0100???: btb_we_f1_1 = 1'b1;
        7'b1000???: btb_we_f1_0 = 1'b1;
        default   : begin
                    btb_we_f1_0 = 1'b0;
                    btb_we_f1_1 = 1'b0;
                    btb_we_f1_2 = 1'b0;
                    btb_we_f1_3 = 1'b0;
        end 
      endcase
  end

  // set the lru bits
  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      lru1 <= 256'h0;
    else if (btb_we_f1_0 || btb_we_f1_1)
      lru1[index_f1] <= 1'b1;
    else if (btb_we_f1_2 || btb_we_f1_3)
      lru1[index_f1] <= 1'b0;
    else if (btb_hit_f0_0 || btb_hit_f0_1)
      lru1[index_f0] <= 1'b1;
    else if (btb_hit_f0_2 || btb_hit_f0_3)
      lru1[index_f0] <= 1'b0;
  end

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      lru01 <= 256'h0;
    else if (btb_we_f1_0)
      lru01[index_f1] <= 1'b1;
    else if (btb_we_f1_1)
      lru01[index_f1] <= 1'b0;
    else if (btb_hit_f0_0)
      lru01[index_f0] <= 1'b1;
    else if (btb_hit_f0_1)
      lru01[index_f0] <= 1'b0;
  end

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      lru23 <= 256'h0;
    else if (btb_we_f1_2)
      lru23[index_f1] <= 1'b1;
    else if (btb_we_f1_3)
      lru23[index_f1] <= 1'b0;
    else if (btb_hit_f0_2)
      lru23[index_f0] <= 1'b1;
    else if (btb_hit_f0_3)
      lru23[index_f0] <= 1'b0;
  end

endmodule

