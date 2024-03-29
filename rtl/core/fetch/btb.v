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
  input wire               clock,
  input wire               reset_n,
  input wire [63:0]        pc_f0_i,
  input wire [63:0]        pc_f1_i,

  input wire               brdec_brext_f1_i, // btb speculative write enable
  input wire [ 2:0]        brdec_brpos_f1_i, // btb speculative write data brpos
  input wire [ 1:0]        brdec_brtyp_f1_i, // btb speculative write data brtyp
  input wire [63:0]        brdec_brtar_f1_i, // btb speculative write data brtar
  input wire [ 1:0]        brdec_rasctl_f1_i,

  input wire               brcond_vld_rt_i,
  input wire               brindir_vld_rt_i,
  input wire               brdir_rt_i,
  input wire [63:0]        brtar_rt_i,
  input wire [63:0]        brpc_rt_i, // from bob

  output reg               btb_hit_f0_o,       // btb hit flag
  output reg [ 2:0]        btb_brpos_f0_o,    // branch instruction position in a fetch bundle
  output reg [ 1:0]        btb_brtyp_f0_o,    // branch type
  output reg [63:0]        btb_brtar_f0_o,    // branch target
  output reg [ 1:0]        btb_rasctl_f0_o,
  output reg               btb_brdir_f0_o     // branch direction(condition)
);

  integer i;

  // wires coming back from the banks
  wire [ 1:0] ras_ctl_way0,    ras_ctl_way1,    ras_ctl_way2,    ras_ctl_way3;
  wire [ 2:0] br_pos_way0,     br_pos_way1,     br_pos_way2,     br_pos_way3;
  wire [ 1:0] br_typ_way0,     br_type_way1,    br_type_way2,    br_type_way3;
  wire [63:0] br_tar_way0,     br_tar_way1,     br_tar_way2,     br_tar_way3;
  wire        br_dir_way0,     br_dir_way1,     br_dir_way2,     br_dir_way3;
  wire        btb_hit_way0_f0, btb_hit_way1_f0, btb_hit_way2_f0, btb_hit_way3_f0;
  wire        btb_hit_way0_f1, btb_hit_way1_f1, btb_hit_way2_f1, btb_hit_way3_f1;

  reg         btb_sp_we_way0_f1, btb_sp_we_way1_f1, btb_sp_we_way2_f1, btb_sp_we_way3_f1;

  wire [ 7:0] idx_f1 = pc_f1_i[9:2];
  wire [ 7:0] idx_f0 = pc_f0_i[9:2];

  wire        btb_brdir_we_cert;
  wire        btb_brdir_cert;
  wire [63:0] btb_brpc_cert;
  wire [63:0] btb_brtar_cert;


  assign btb_brdir_we_cert = brcond_vld_rt_i | brindir_vld_rt_i;
  assign btb_brdir_cert    = brdir_rt_i;
  assign btb_brpc_cert     = brpc_rt_i;
  assign btb_brtar_cert    = brtar_rt_i;
  // instantiate the four ways
  btb_way btb_way0(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_we_spec_i       (btb_sp_we_way0_f1),
    .btb_brpos_spec_i    (brdec_brpos_f1_i),
    .btb_brtyp_spec_i    (brdec_brtyp_f1_i),
    .btb_brpc_spec_i     (pc_f1_i           ),
    .btb_brtar_spec_i    (brdec_brtar_f1_i),
    .btb_rasctl_i         (brdec_rasctl_f1_i     ),
    .btb_we_cert_i       (btb_brdir_we_cert ),
    .btb_brdir_cert_i    (btb_brdir_cert),
    .btb_brpc_cert_i     (btb_brpc_cert),
    .btb_brtar_cert_i    (btb_brtar_cert),
    .btb_hit_f0_o        (btb_hit_way0_f0       ),
    .btb_brpos_f0_o      (br_pos_way0           ),
    .btb_brtyp_f0_o      (br_typ_way0           ),
    .btb_brtar_f0_o      (br_tar_way0           ),
    .btb_rasctl_f0_o     (ras_ctl_way0          ),
    .btb_brdir_f0_o      (br_dir_way0           ),
    .btb_hit_f1_o        (btb_hit_way0_f1       )
  );

  btb_way btb_way1(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_we_spec_i       (btb_sp_we_way1_f1),
    .btb_brpos_spec_i    (brdec_brpos_f1_i),
    .btb_brtyp_spec_i    (brdec_brtyp_f1_i),
    .btb_brpc_spec_i     (pc_f1_i     ),
    .btb_brtar_spec_i    (brdec_brtar_f1_i),
    .btb_rasctl_i         (brdec_rasctl_f1_i     ),
    .btb_we_cert_i       (btb_brdir_we_cert),
    .btb_brdir_cert_i    (btb_brdir_cert),
    .btb_brpc_cert_i     (btb_brpc_cert ),
    .btb_brtar_cert_i    (btb_brtar_cert),
    .btb_hit_f0_o      (btb_hit_way1_f0       ),
    .btb_brpos_f0_o      (br_pos_way1           ),
    .btb_brtyp_f0_o      (br_typ_way1           ),
    .btb_brtar_f0_o      (br_tar_way1           ),
    .btb_rasctl_f0_o     (ras_ctl_way1          ),
    .btb_brdir_f0_o      (br_dir_way1           ),
    .btb_hit_f1_o      (btb_hit_way1_f1       )
  );

  btb_way btb_way2(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_we_spec_i       (btb_sp_we_way2_f1),
    .btb_brpos_spec_i    (brdec_brpos_f1_i),
    .btb_brtyp_spec_i    (brdec_brtyp_f1_i),
    .btb_brpc_spec_i     (pc_f1_i     ),
    .btb_brtar_spec_i    (brdec_brtar_f1_i),
    .btb_rasctl_i         (brdec_rasctl_f1_i     ),
    .btb_we_cert_i       (btb_brdir_we_cert),
    .btb_brdir_cert_i    (btb_brdir_cert),
    .btb_brpc_cert_i     (btb_brpc_cert ),
    .btb_brtar_cert_i    (btb_brtar_cert),
    .btb_hit_f0_o      (btb_hit_way2_f0       ),
    .btb_brpos_f0_o      (br_pos_way2           ),
    .btb_brtyp_f0_o      (br_typ_way2           ),
    .btb_brtar_f0_o      (br_tar_way2           ),
    .btb_rasctl_f0_o     (ras_ctl_way2          ),
    .btb_brdir_f0_o      (br_dir_way2           ),
    .btb_hit_f1_o      (btb_hit_way2_f1       )
  );

  btb_way btb_way3(
    .clock             (clock             ),
    .reset_n           (reset_n           ),
    .pc_f0_i           (pc_f0_i           ),
    .btb_we_spec_i       (btb_sp_we_way3_f1),
    .btb_brpos_spec_i    (brdec_brpos_f1_i),
    .btb_brtyp_spec_i    (brdec_brtyp_f1_i),
    .btb_brpc_spec_i     (pc_f1_i           ),
    .btb_brtar_spec_i    (brdec_brtar_f1_i),
    .btb_rasctl_i         (brdec_rasctl_f1_i     ),
    .btb_we_cert_i       (btb_brdir_we_cert),
    .btb_brdir_cert_i    (btb_brdir_cert),
    .btb_brpc_cert_i     (btb_brpc_cert ),
    .btb_brtar_cert_i    (btb_brtar_cert),
    .btb_hit_f0_o      (btb_hit_way3_f0       ),
    .btb_brpos_f0_o      (br_pos_way3           ),
    .btb_brtyp_f0_o      (br_typ_way3           ),
    .btb_brtar_f0_o      (br_tar_way3           ),
    .btb_rasctl_f0_o     (ras_ctl_way3          ),
    .btb_brdir_f0_o      (br_dir_way3           ),
    .btb_hit_f1_o      (btb_hit_way3_f1       )
  );

  // route the outputs according to the hit signals
  always @ *
  begin
    case ({btb_hit_way0_f0,btb_hit_way1_f0,btb_hit_way2_f0,btb_hit_way3_f0})
      4'b0000: begin
        btb_hit_f0_o      = 1'b0;
        btb_rasctl_f0_o  = 2'b0;
        btb_brpos_f0_o   = 3'b000;
        btb_brtyp_f0_o   = 2'b00;
        btb_brtar_f0_o   = 64'b0;
        btb_brdir_f0_o   = 1'b0;
      end
      4'b1000: begin
        btb_hit_f0_o      = 1'b1;
        btb_rasctl_f0_o  = ras_ctl_way0;
        btb_brpos_f0_o   = br_pos_way0;
        btb_brtyp_f0_o   = br_typ_way0;
        btb_brtar_f0_o   = br_tar_way0;
        btb_brdir_f0_o   = br_dir_way0;
      end
      4'b0100: begin
        btb_hit_f0_o      = 1'b1;
        btb_rasctl_f0_o  = ras_ctl_way1;
        btb_brpos_f0_o   = br_pos_way1;
        btb_brtyp_f0_o   = br_typ_way1;
        btb_brtar_f0_o   = br_tar_way1;
        btb_brdir_f0_o   = br_dir_way1;
      end
      4'b0010: begin
        btb_hit_f0_o      = 1'b1;
        btb_rasctl_f0_o  = ras_ctl_way2;
        btb_brpos_f0_o   = br_pos_way2;
        btb_brtyp_f0_o   = br_typ_way2;
        btb_brtar_f0_o   = br_tar_way2;
        btb_brdir_f0_o   = br_dir_way2;
      end
      4'b0001: begin
        btb_hit_f0_o      = 1'b1;
        btb_rasctl_f0_o  = ras_ctl_way3;
        btb_brpos_f0_o   = br_pos_way3;
        btb_brtyp_f0_o   = br_typ_way3;
        btb_brtar_f0_o   = br_tar_way3;
        btb_brdir_f0_o   = br_dir_way3;
      end
      default: begin
        // if the current read bundlepc is the same as the new entry to be written,
        // all the banks will match, since they'll all bypass the data.  so gate
        // the error message with this check
        if (pc_f0_i != pc_f1_i)
          btb_hit_f0_o = 1'b0;
          btb_rasctl_f0_o = 2'b00;
          btb_brpos_f0_o = 3'b000;
          btb_brtyp_f0_o = 2'b00;
          btb_brtar_f0_o = 64'b0;
          btb_brdir_f0_o = 1'b0;
        end
    endcase
  end

  // lru state
  reg   [2:0] lru_reg [0:255];
  // based on whether any of the ways have the new entry already,
  // set the write bits for each way
  always @ * 
  begin
    btb_sp_we_way0_f1 = 1'b0;
    btb_sp_we_way1_f1 = 1'b0;
    btb_sp_we_way2_f1 = 1'b0;
    btb_sp_we_way3_f1 = 1'b0;
    if (brdec_brext_f1_i)
      casex ({btb_hit_way0_f1,btb_hit_way1_f1,btb_hit_way2_f1,btb_hit_way3_f1,
              lru_reg[idx_f1]})
        // write miss LRU strategy used. 
        7'b000000?: btb_sp_we_way0_f1 = 1'b1; //
        7'b000001?: btb_sp_we_way1_f1 = 1'b1;
        7'b00001?0: btb_sp_we_way2_f1 = 1'b1;
        7'b00001?1: btb_sp_we_way3_f1 = 1'b1;
        // write hit, just replace current entry.
        7'b0001???: btb_sp_we_way3_f1 = 1'b1;
        7'b0010???: btb_sp_we_way2_f1 = 1'b1;
        7'b0100???: btb_sp_we_way1_f1 = 1'b1;
        7'b1000???: btb_sp_we_way0_f1 = 1'b1;
        default   : ; 
      endcase
  end

  // set the lru bits
  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      for (i=0; i<256; i=i+1)
        lru_reg[i] <= 3'b000;
    else if (btb_sp_we_way0_f1)
      lru_reg[idx_f1] <= 3'b110;
    else if (btb_sp_we_way1_f1)
      lru_reg[idx_f1] <= 3'b100;
    else if (btb_sp_we_way2_f1)
      lru_reg[idx_f1] <= 3'b001;
    else if (btb_sp_we_way3_f1)
      lru_reg[idx_f1] <= 3'b000;

    else if (btb_hit_way0_f0)
      lru_reg[idx_f1] <= 3'b110;
    else if (btb_hit_way1_f0)
      lru_reg[idx_f1] <= 3'b100;
    else if (btb_hit_way2_f0)
      lru_reg[idx_f1] <= 3'b001;
    else if (btb_hit_way3_f0)
      lru_reg[idx_f1] <= 3'b000;
  end

endmodule

