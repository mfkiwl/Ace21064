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
  input	 wire         rm_inst_i,
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
  output wire [31:0]  buf_inst2_o,
  output wire [31:0]  buf_inst2_o,
  output wire [31:0]  buf_inst3_o,
  output wire         buf_full_o,
  output wire         buf_empty_o
);

  // internal storage
  reg [31:0] buf_entry [31:0];
  reg [31:0] buf_entry_vld;

  reg [ 4:0] write_ptr;
  reg [ 4:0] read_ptr;

  reg [ 4:0] inst0_loc;

  wire [ 7:0] vld_inst_array;
  wire [ 5:0] input_inst_num;
  wire [ 5:0] output_inst_num;

  // valid instruction in current instruction bundle.
  assign vld_inst_array ={inst7_vld_i,inst6_vld_i,inst5_vld_i,inst4_vld_i,
                          inst3_vld_i,inst2_vld_i,inst1_vld_i,inst0_vld_i};

  // total valid instruction number in current cycle.
  assign input_inst_num = inst7_vld_i+inst6_vld_i+inst5_vld_i+inst4_vld_i+
                          inst3_vld_i+inst2_vld_i+inst1_vld_i+inst0_vld_i;

  // total ouput instruction number in current cycle.
  assign output_inst_num = (buffer_inst_num > 4) ? 4 : buffer_inst_num;

  // total instruction number in the instruction buffer.
  reg [5:0] buffer_inst_num;
  always @ (posedge clock or negedge reset_n) 
  begin
      if(!reset_n)
          buffer_inst_num = 6'b000000;
      else
          buffer_inst_num = buffer_inst_num + input_inst_num - ouput_inst_num;
  end

  // instruction buffer write pointer register
  always @ (posedge clock or negedge reset_n) 
  begin
      if(!reset_n)
          write_ptr <= 5'b00000;
      else if (flush_i)
          write_ptr <= 5'b00000;
      else if ((buffer_inst_num < 24) && (write_ptr < 24))
          write_ptr <= write_ptr + input_inst_num;
      else if ((buffer_inst_num < 24) && (write_ptr > 24))
          write_ptr <= input_inst_num - (31 - write_ptr);
  end

  // instruction buffer write pointer register
  always @ (posedge clock or negedge reset_n) 
  begin
    if(!reset_n)
      read_ptr <= 5'b00000;
    else if (flush_i)
      read_ptr <= 5'b00000;
    else
      read_ptr <= read_ptr + ;
  end

  // instruction buffer main entry and valid bit register.
  integer i;
  always @ (posedge clock or negedge reset_n) 
  begin : buf_write_block
      if(!reset_n)
          for (i=0; i<32; i++)
              buf_entry_vld[i] = 1'b0;
      else if (flush_i)
          for (i=0; i<32; i++)
              buf_entry_vld[i] = 1'b0;
      else
      begin
          for (i=0; i<input_inst_num; i++)
          begin
              if(inst0_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst0_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst1_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst1_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst2_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst2_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst3_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst3_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst4_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst4_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst5_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst5_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst6_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst6_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
              if(inst7_vld_i)
              begin
                  buf_entry[write_ptr+i]     = inst7_i; 
                  buf_entry_vld[write_ptr+i] = 1'b1;
              end
          end
      end
  end
  // instruction buffer read block
  reg [31:0] dec_inst0;
  reg [31:0] dec_inst1;
  reg [31:0] dec_inst2;
  reg [31:0] dec_inst3;
  always @ *
  begin
      
  end

  assign buf_full_o = (buffer_inst_num < 24) ? 1'b0 : 1'b1; // less than 8 entry empty

endmodule 
