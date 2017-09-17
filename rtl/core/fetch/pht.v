//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : pht.v
//  Author      : ejune@aureage.com
//                
//  Description : Pattern History Table for local history prediction, which
//                have the size 1024x2bits, total 1024 entries, and 2 bis to
//                record 10 recent branch direction.
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

`include "fetch/util.v"
module pht(
  input  wire                     clock,
  input  wire                     reset_n,
  input  wire [LOGINDEXSIZE-1:0]  pht_rd_index_i, //prediction entry to access
  input  wire [LOGINDEXSIZE-1:0]  pht_wt_index_i, // prediction entry to update
  input  wire                     pht_cm_brdir_we_i, //if we need to update a prediction entry
  input  wire                     pht_cm_brdir_i, //direction of retired branch
  output wire                     pht_br_pred_o  // predicted direction
);

  integer i;
  parameter INDEXSIZE         = 4096;
  parameter LOGINDEXSIZE      = 12;
  parameter SATCNTWIDTH       = 2;
  parameter SATCNTINIT        = 2'b10;

  reg [SATCNTWIDTH-1:0] pht [0:INDEXSIZE-1];
  reg                   br_pred_o; // predicted direction
  wire                  pht_we;

  wire sat_cnt_tmp[1:0] = func_pht_update(pht_cm_brdir_i, pht[pht_rd_index_i]);
  always @( * )
  begin : ReadBlock
    sat_cnt_tmp = pht[pht_rd_index_i];
    if (pht_cm_brdir_we_i)
      br_pred_o = sat_cnt_tmp[1];
    else
      br_pred_o = sat_cnt_tmp[1];	// MSB of counter
  end

  assign pht_br_pred_o = br_pred_o;

//  // update an entry
//  always @(posedge clock or posedge reset_n)
//  begin : WriteBlock
//    if (reset_n)
//      for (i=0 ; i<INDEXSIZE ; i=i+1)
//        pht[i] = SATCNTINIT;
//    else
//      if (pht_cm_bridr_i & pht_cm_brdir_we_i)
//        pht[pht_wt_index_i] <= incs(pht[pht_wt_index_i]);
//      else if (pht_cm_brdir_we_i)
//        pht[pht_wt_index_i] <= decs(pht[pht_wt_index_i]);
//      else
//        pht[pht_wt_index_i] <= pht[pht_wt_index_i];
//
//  end

  wire pht_cm_update[1:0] = func_pht_update(pht_cm_brdir_i, pht[pht_wt_index_i]);
  generate 
    for (i=0, i<32,i=i+1)
    begin
      pht_we = pht_cm_brdir_we_i & (pht_wt_index_i[9:5] == i[4:0]);
      for (j=0, j<32, j=j+1)
      begin
        always @(posedge clock or negedge reset_n)
          if(!reset_n)
            pht[{i[4:0],j[4:0]}] <= SATCNTINIT;
          else if (pht_we)
            pht[{i[4:0],j[4:0]}] <= (pht_wt_index_i[9:0] == j[4:0]) ?
                                    (pht_cm_update[1:0])            :
                                     pht[{i[4:0],j[4:0]}]           ;
      end    
    end
  endgenerate



  // pht value update function
  function func_pht_update;
    input br_dir_i;
    input cur_pht_value;

    begin
      case({cur_ph_value, br_dir_i})
        { `ST,0} : pht_cm_update[1:0] = `WNT;
        { `ST,1} : pht_cm_update[1:0] = `ST;
        { `WT,0} : pht_cm_update[1:0] = `WNT;
        { `WT,1} : pht_cm_update[1:0] = `ST;
        {`WNT,0} : pht_cm_update[1:0] = `SNT;
        {`WNT,1} : pht_cm_update[1:0] = `WT;
        {`SNT,0} : pht_cm_update[1:0] = `SNT;
        {`SNT,1} : pht_cm_update[1:0] = `WT;
        default  : pht_cm_update[1:0] = 2'bxx;
      endcase
    end
  endfunction

endmodule
