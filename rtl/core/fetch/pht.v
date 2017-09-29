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

module pht #(
  parameter INDEX_SIZE        = 1024,
  parameter SQRT_INDEX        = 32,
  parameter LOG_INDEX         = 10,
  parameter SATCNT_WIDTH      = 2,
  parameter SATCNT_INIT       = 2'b10
)(
  input  wire                  clock,
  input  wire                  reset_n,
  input  wire [LOG_INDEX-1:0]  pht_rd_index_i, //prediction entry to access
  input  wire [LOG_INDEX-1:0]  pht_wt_index_i, // prediction entry to update
  input  wire                  pht_cm_brdir_we_i, //if we need to update a prediction entry
  input  wire                  pht_cm_brdir_i, //direction of retired branch
  output wire                  pht_br_pred_o  // predicted direction
);

  reg [SATCNT_WIDTH-1:0] pht [0:INDEX_SIZE-1];
  reg                    br_pred_o; // predicted direction
  wire                   pht_we;

  wire sat_cnt_tmp[1:0] = func_pht_update(pht_cm_brdir_i, pht[pht_rd_index_i]);

  always @ * 
  begin : ReadBlock
    //sat_cnt_tmp = pht[pht_rd_index_i];
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

  genvar i;
  genvar j;

  generate 
  begin
    for (i=0; i<SQRT_INDEX; i=i+1)
    begin
      assign pht_we = pht_cm_brdir_we_i & (pht_wt_index_i[9:5] == i[4:0]);
      for (j=0; j<SQRT_INDEX; j=j+1)
      begin
        always @(posedge clock or negedge reset_n)
          if(!reset_n)
            pht[{i[4:0],j[4:0]}] <= SATCNT_INIT;
          else if (pht_we)
            pht[{i[4:0],j[4:0]}] <= (pht_wt_index_i[9:0] == j[4:0]) ?
                                    (pht_cm_update[1:0])            :
                                     pht[{i[4:0],j[4:0]}]           ;
      end    
    end
  end
  endgenerate



  // pht value update function
  function [1:0] func_pht_update;
    input       br_dir_i;
    input [1:0] cur_pht_value;

    begin
      case({cur_pht_value, br_dir_i})
        { `ST,0} : func_pht_update[1:0] = `WNT;
        { `ST,1} : func_pht_update[1:0] = `ST;
        { `WT,0} : func_pht_update[1:0] = `WNT;
        { `WT,1} : func_pht_update[1:0] = `ST;
        {`WNT,0} : func_pht_update[1:0] = `SNT;
        {`WNT,1} : func_pht_update[1:0] = `WT;
        {`SNT,0} : func_pht_update[1:0] = `SNT;
        {`SNT,1} : func_pht_update[1:0] = `WT;
        default  : func_pht_update[1:0] = 2'bxx;
      endcase
    end
  endfunction

endmodule
