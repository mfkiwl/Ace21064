//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : bht.v
//  Author      : ejune@aureage.com
//                
//  Description : Branch History Table for local history prediction, which
//                have the size 1024x10bits, total 1024 entries, and 10 bis to
//                record 10 recent branch direction.
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module bht (
  input  wire           clock,
  input  wire           reset_n,
  input  wire [9:0]     bht_rd_index_i,    // bht read index, from speculated pc
  input  wire [9:0]     bht_wt_index_i,    // bht write index, from committed pc
  input  wire           bht_brdir_i,    // confirmed branch direction
  input  wire           bht_brdir_se_i, // confirmed branch direction shift in enable
  output wire [9:0]     bht_br_hist_o      // branch history output, for pht index
);
  localparam INDEX_SIZE    = 1024;

  wire       bht_we;
  reg  [9:0] br_hist_o;
  reg  [9:0] bht [0:INDEX_SIZE-1];

  // read an entry
  // if the updating entry is being indexed by current pc, bypass to output.
  wire [9:0] bht_entry_tmp0 = bht[bht_rd_index_i];

  always @ *
  begin : ReadBlock
    if (bht_brdir_se_i && (bht_rd_index_i == bht_wt_index_i))
      br_hist_o  = {bht_entry_tmp0[8:0], bht_brdir_i};
    else
      br_hist_o = bht[bht_rd_index_i];
  end

  assign bht_br_hist_o = br_hist_o;

  // update an entry
  wire [9:0] bht_entry_tmp1 = bht[bht_wt_index_i];
  wire [9:0] bht_cm_update  = {bht_entry_tmp1[8:0], bht_brdir_i};
  // Partition the BHT into 32 groups of 32 ten-bit registers, can only enable
  // eatch portion on a update, rather than the entire table, to reduce power.
  genvar i;
  genvar j;

  generate
  begin : branch_history_table 
    for(i=0; i<32; i=i+1)
    begin
      assign bht_we = bht_brdir_se_i && (bht_wt_index_i[9:5] == i[4:0]);
      for(j=0; j<32; j=j+1)
      begin
        always @ (posedge clock or negedge reset_n)
        begin
          if(!reset_n)
              bht[{i[4:0],j[4:0]}] <= 10'b0;
          else if (bht_we)
              bht[{i[4:0],j[4:0]}] <= (bht_wt_index_i[9:5] == j[4:0]) ?
                                      (bht_cm_update[9:0])            :
                                       bht[{i[4:0],j[4:0]}]           ;
        end
      end
    end
  end
  endgenerate

endmodule

