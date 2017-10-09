//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : inst_buf.v
//  Author      : ejune@aureage.com
//                
//  Description : decoupling buffer between the frontend and the backand
//                8 instructions input 4 instructions ouput
//                32x32bit main queue entry
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module inst_buf(	
  // inputs
  input	 wire         clock,
  input	 wire         reset_n,
  input	 wire         flush_i,
  input  wire [31:0]  inst0_i,
  input  wire [31:0]  inst1_i,
  input  wire [31:0]  inst2_i,
  input  wire [31:0]  inst3_i,
  input  wire [31:0]  inst4_i,
  input  wire [31:0]  inst5_i,
  input  wire [31:0]  inst6_i,
  input  wire [31:0]  inst7_i,
  input  wire         inst0_vld_i,
  input  wire         inst1_vld_i,
  input  wire         inst2_vld_i,
  input  wire         inst3_vld_i,
  input  wire         inst4_vld_i,
  input  wire         inst5_vld_i,
  input  wire         inst6_vld_i,
  input  wire         inst7_vld_i,
  // outputs
  output wire [31:0]  buf_inst0_o,
  output wire [31:0]  buf_inst1_o,
  output wire [31:0]  buf_inst2_o,
  output wire [31:0]  buf_inst3_o,
  output wire         buf_full_o,
  output wire         buf_empty_o
);

  // internal storage
  reg  [31:0] buf_entry [31:0];
  reg  [31:0] buf_entry_vld;

  reg  [ 4:0] write_ptr;
  reg  [ 4:0] read_ptr;

  reg  [ 5:0] buffer_inst_num;

  wire [ 7:0] vld_inst_array;
  wire [ 5:0] output_inst_num;

  // valid instruction in current instruction bundle.
  assign vld_inst_array ={inst7_vld_i,inst6_vld_i,inst5_vld_i,inst4_vld_i,
                          inst3_vld_i,inst2_vld_i,inst1_vld_i,inst0_vld_i};

  // total ouput instruction number in current cycle.
  assign output_inst_num = (buffer_inst_num > 4) ? 4 : buffer_inst_num;

  // total instruction number in the instruction buffer.
  always @ (posedge clock or negedge reset_n) 
  begin
      if(!reset_n)
          buffer_inst_num <= 6'b000000;
      else
          buffer_inst_num <= buffer_inst_num + 8 - output_inst_num;
  end

  // instruction buffer write pointer register
  always @ (posedge clock or negedge reset_n) 
  begin
      if(!reset_n)
          write_ptr <= 5'b00000;
      else if (flush_i)
          write_ptr <= 5'b00000;
      else if (24 > buffer_inst_num) 
          if(24 > write_ptr) 
              // write pointer needn't cross boundary
              write_ptr <= write_ptr + 8;
          else 
              // write pointer cross boundary
              write_ptr <= 8 - (31 - write_ptr);
      else 
          // instruction buffer is almost full and can't afford new instruction bundles
          // fetch stage should be stalled
          write_ptr <= write_ptr;
  end

  // instruction buffer main entry and valid bit register.
  // instruction buffer entry valid bit.
  integer i;
  always @ (posedge clock or negedge reset_n) 
  begin : buf_valid_bit_block
      if(!reset_n)
        for (i=0; i<32; i=i+1)
          buf_entry_vld[i] <= 1'b0;
      else if (flush_i)
        for (i=0; i<32; i=i+1)
          buf_entry_vld[i] <= 1'b0;
      else
        for (i=0; i < 8; i=i+1)
          buf_entry_vld[nxt_ptr(i,write_ptr)] <= vld_inst_array[i];
  end
  // instruction buffer main block.
  integer ii;
  always @ (posedge clock) 
  begin : buf_write_block
    for (ii=0; ii < 8; ii=ii+1)
    begin
      case(ii)
        0 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst0_i; 
        1 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst1_i; 
        2 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst2_i; 
        3 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst3_i; 
        4 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst4_i; 
        5 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst5_i; 
        6 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst6_i; 
        7 : buf_entry[nxt_ptr(ii,write_ptr)] <= inst7_i; 
      default:;
      endcase
    end
  end

  // instruction buffer read pointer register
  always @ (posedge clock or negedge reset_n) 
  begin
    if(!reset_n)
      read_ptr <= 5'b00000;
    else if (flush_i)
      read_ptr <= 5'b00000;
    else if (4 <= buffer_inst_num)
      read_ptr <= read_ptr + 4;
    else
      read_ptr <= read_ptr;
  end

  // instruction buffer read block
  assign buf_inst0_o = (4 <= buffer_inst_num) ?  buf_entry[nxt_ptr(0,read_ptr)] : 32'h0;
  assign buf_inst1_o = (4 <= buffer_inst_num) ?  buf_entry[nxt_ptr(1,read_ptr)] : 32'h0;
  assign buf_inst2_o = (4 <= buffer_inst_num) ?  buf_entry[nxt_ptr(2,read_ptr)] : 32'h0;
  assign buf_inst3_o = (4 <= buffer_inst_num) ?  buf_entry[nxt_ptr(3,read_ptr)] : 32'h0;

  assign buf_full_o = (buffer_inst_num < 24) ? 1'b0 : 1'b1; // less than entry entry empty
  assign buf_empty_o= (buffer_inst_num == 0) ? 1'b1 : 1'b0;
  ////////////////////////////////////////////////////////////////////
  // Functions used in current module
  //
  // circular buffer write pointer generator
  function [5:0] nxt_ptr;
      input [5:0] k;
      input [5:0] cur_ptr;
      begin
          if(cur_ptr + k < 32)
              nxt_ptr = cur_ptr + k;
          else
              nxt_ptr = cur_ptr + k - 32;
      end
  endfunction

endmodule 
