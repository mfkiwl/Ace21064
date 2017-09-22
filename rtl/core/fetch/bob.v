//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : bob.v
//  Author      : ejune@aureage.com
//                
//  Description : Branch Ordering Buffer
//                width 93, depth 16, Keeps CPU status for misprediction
//                recovery
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module bob(
  // inputs
  input  wire             clock,
  input  wire             reset_n,
  input  wire             flush,
  input  wire             bob_re_i,
  input  wire             bob_we_i,

  input  wire [63:0]      pc_f1_i,
  input  wire             bob_brdir_i,
  input  wire             bob_ch_we_i,
  input  wire             bob_ch_ud_i,
  input  wire [ 9:0]      bob_lochist_i,
  input  wire [11:0]      bob_bhr_i,
  input  wire [ 3:0]      bob_rasptr_i,
  // outputs
  output wire [63:0]      bob_pc_o,
  output wire             bob_brdir_o,
  output wire             bob_ch_we_o,
  output wire             bob_ch_dir_o, //choice pht update
  output wire [ 9:0]      bob_lochist_o,
  output wire [11:0]      bob_bhr_o,
  output wire [ 3:0]      bob_rasptr_o,

  output wire             bob_valid_o,
  output wire             bob_stall_o
);

  wire                    bob_re;
  wire                    bob_we;
  wire        [92:0]      bob_rdata;
  wire        [92:0]      bob_wdata;

  // pointers
  reg         [ 3:0]      bob_rindex;
  reg         [ 3:0]      bob_windex;
  reg         [15:0]      entry_valid;

  // assign outputs
  assign bob_pc_o         = bob_rdata[92:29];
  assign bob_ch_we_o      = bob_rdata[28];
  assign bob_ch_dir_o     = bob_rdata[27];
  assign bob_brdir_o      = bob_rdata[26];
  assign bob_lochist_o    = bob_rdata[25:16];
  assign bob_bhr_o        = bob_rdata[15: 4];
  assign bob_rasptr_o     = bob_rdata[ 3: 0];


  ram_dp  #(
          .DATAWIDTH   (93        ),
          .INDEXSIZE   (16        ),
          .LOGINDEX    (4         ),
          .INITVALUE   (0         ))
  bob_array(
          .clock       (clock     ),
          .reset_n     (reset_n   ),
          // read port
          .we1_in      (1'b0      ),
          .index1_in   (bob_rindex),
          .data1_in    (          ),
          .data1_out   (bob_rdata ),
          // write port
          .we2_in      (bob_we    ),
          .index2_in   (bob_windex),
          .data2_in    (bob_wdata ),
          .data2_out   (          )
         );

  // instantiate other modules
  assign bob_wdata ={pc_f1_i, bob_ch_we_i, bob_ch_ud_i, bob_brdir_i, bob_lochist_i, bob_bhr_i, bob_rasptr_i};

  always @ (posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0 || flush == 1'b1) begin
      bob_rindex  <= 4'b0000;
      bob_windex  <= 4'b0000;
      entry_valid <= 16'h0;
    end
    else if (bob_we)begin
      // if fetch is trying to insert an entry and we're not full
        entry_valid[bob_windex] <= 1'b1;
        bob_windex <= (bob_windex + 1'b1) % 16;
    end
    else if (bob_re) begin
        entry_valid[bob_rindex] <= 4'b0;
        bob_rindex <= (bob_rindex + 1'b1) % 16;
    end
    else begin
        entry_valid[bob_rindex] <= entry_valid[bob_rindex];
        bob_windex <= bob_windex;
        bob_rindex <= bob_rindex;
    end
  end

  assign bob_we    = bob_we_i && (~(&bob_windex)); // write in valid, and bob not
  assign bob_re    = bob_re_i && entry_valid[bob_rindex];

  assign bob_stall_o = &bob_windex;
  assign bob_valid_o = entry_valid[bob_rindex];

endmodule
