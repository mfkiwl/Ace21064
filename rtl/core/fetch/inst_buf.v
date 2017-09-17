//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : inst_buf.v
//  Author      : ejune@aureage.com
//                
//  Description : 3rd stage of instruction fetch unit, which is a instruction
//                buffer between instruction fetch and instruction decoder 
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

/*
attention about cmov instruction in alpha instruction
*/
module inst_buf(	
  input	wire        clock,
  input	wire        reset_n,
  input	wire        pc_f2_i,
  input	wire        flush_rt_i,

  input wire [31:0] inst0_i,
  input wire [31:0] inst1_i,
  input wire [31:0] inst2_i,
  input wire [31:0] inst3_i,
  input wire [31:0] inst4_i,
  input wire [31:0] inst5_i,
  input wire [31:0] inst6_i,
  input wire [31:0] inst7_i,
  input wire [ 7:0] inst_vld_i,
//  input wire        inst0_vld_i,
//  input wire        inst1_vld_i,
//  input wire        inst2_vld_i,
//  input wire        inst3_vld_i,
//  input wire        inst4_vld_i,
//  input wire        inst5_vld_i,
//  input wire        inst6_vld_i,
//  input wire        inst7_vld_i,
  input	wire        removeInstructions_in,

  output reg  [160:0] inst0_out,
  output reg  [160:0] inst1_out,
  output reg  [160:0] inst2_out,
  output reg  [160:0] inst3_out,
  output wire                       inst_q_full_o,
  output wire                       inst_q_empty_o
);

  // internal storage
  reg [ 31:0] q_valid_f;
  reg [160:0] q_entry_f [31:0];

  reg [  1:0] count_f;

  // one-hot pointers
  reg [31:0] q_head_f;
  reg [31:0] q_tail_f;

  // instruction insertion pointers
  wire [31:0] q_tail1, q_tail2, q_tail3, q_tail4, q_tail5, q_tail6, q_tail7, q_tail8, q_tail9;
  // instruction removal pointers
  wire [31:0] q_head1, q_head2, q_head3, q_head4, q_head5;

  // next state wireregs
  reg [31:0] q_head_new;
  reg [31:0] nxt_tail;

  // insert and remove command wires
  reg [31:0] insert1, insert2, insert3, insert4, insert5, insert6, insert7, insert8;
  reg [31:0] remove1, remove2, remove3, remove4;

  reg tmpbit;

  integer i;
  reg [ 3:0] is_entry_num;
  reg [ 3:0] rm_entry_num;
  reg [ 5:0] vld_entry_num;

  assign inst_q_empty_o = (vld_entry_num == 0) ? 1'b1 : 1'b0;
  assign inst_q_full_o  = (vld_entry_num > 32 - 8) ? 1'b1 : 1'b0;

  // generate instruction insertion pointers
  assign q_tail1 = q_tail_f;
  assign q_tail2 = {q_tail1[30:0], q_tail1[31]};
  assign q_tail3 = {q_tail2[30:0], q_tail2[31]};
  assign q_tail4 = {q_tail3[30:0], q_tail3[31]};
  assign q_tail5 = {q_tail4[30:0], q_tail4[31]};
  assign q_tail6 = {q_tail5[30:0], q_tail5[31]};
  assign q_tail7 = {q_tail6[30:0], q_tail6[31]};
  assign q_tail8 = {q_tail7[30:0], q_tail7[31]};
  assign q_tail9 = {q_tail8[30:0], q_tail8[31]};
  // generate instruction removal pointers
  assign q_head1 = q_head_f;
  assign q_head2 = {q_head1[30:0], q_head1[31]};
  assign q_head3 = {q_head2[30:0], q_head2[31]};
  assign q_head4 = {q_head3[30:0], q_head3[31]};
  assign q_head5 = {q_head4[30:0], q_head4[31]};

  assign inst0_pc_f2[63:0] = pc_f2 + 64'h00;
  assign inst1_pc_f2[63:0] = pc_f2 + 64'h04;
  assign inst2_pc_f2[63:0] = pc_f2 + 64'h08;
  assign inst3_pc_f2[63:0] = pc_f2 + 64'h0c;
  assign inst4_pc_f2[63:0] = pc_f2 + 64'h10;
  assign inst5_pc_f2[63:0] = pc_f2 + 64'h14;
  assign inst6_pc_f2[63:0] = pc_f2 + 64'h18;
  assign inst7_pc_f2[63:0] = pc_f2 + 64'h1c;

  always @(posedge clock or negedge reset_n)
  begin : UpdateBlock
    if (!reset_n) begin
      count_f       <= 2'b10;
      q_valid_f     <= 32'h0;
      q_head_f      <= 32'h1;
      q_tail_f      <= 32'h1;
      vld_entry_num <= 0;
    end
    else if (flush_rt_i) begin
      count_f       <= 2'b10;
      q_valid_f     <= 0;
      q_head_f      <= 1;
      q_tail_f      <= 1;
      vld_entry_num <= 0;
    end
    else begin
      if (count_f != 0)
        count_f <= count_f - 1;
      vld_entry_num <= vld_entry_num + is_entry_num - rm_entry_num;
      q_tail_f <= nxt_tail;
      q_head_f <= q_head_new;

      for (i=0; i<32; i=i+1)
      begin
        if (removeInstructions_in && (remove1[i] || remove2[i] || remove3[i] || remove4[i]))
          q_valid_f[i] <= 1'b0;
        else if (!inst_q_full_o) begin
          if (insert1[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction0_in;
          end
          else if (insert2[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction1_in;
          end
          else if (insert3[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction2_in;
          end
          else if (insert4[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction3_in;
          end
          else if (insert5[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction4_in;
          end
          else if (insert6[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction5_in;
          end
          else if (insert7[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction6_in;
          end
          else if (insert8[i]) begin
            q_valid_f[i] <= 1'b1;
            q_entry_f[i] <= instruction7_in;
          end
        end // if
      end // for
    end // if
  end

  // figure out where to insert new instructions
  always @ (*)
  begin : InsertBlock
    if ((count_f == 0) && !inst_q_full_o) begin
/*
 *inst_vld_i[7] is the valid bit of inst7
 *inst_vld_i[6] is the valid bit of inst6
 *inst_vld_i[5] is the valid bit of inst5
 *inst_vld_i[4] is the valid bit of inst4
 *inst_vld_i[3] is the valid bit of inst3
 *inst_vld_i[2] is the valid bit of inst2
 *inst_vld_i[1] is the valid bit of inst1
 *inst_vld_i[0] is the valid bit of inst0
 */
        casex (inst_vld_i)
        8'b11111111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = q_tail4;
                       insert5      = q_tail5;
                       insert6      = q_tail6;
                       insert7      = q_tail7;
                       insert8      = q_tail8;
                       is_entry_num = 4'h8;
                       nxt_tail     = q_tail9;
                     end
        8'b01111111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = q_tail4;
                       insert5      = q_tail5;
                       insert6      = q_tail6;
                       insert7      = q_tail7;
                       insert8      = 32'h0;
                       is_entry_num = 4'h7;
                       nxt_tail     = q_tail8;
                     end
        8'b?0111111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = q_tail4;
                       insert5      = q_tail5;
                       insert6      = q_tail6;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h6;
                       nxt_tail     = q_tail7;
                     end
        8'b??011111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = q_tail4;
                       insert5      = q_tail5;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h5;
                       nxt_tail     = q_tail6;
                     end
        8'b???01111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = q_tail4;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h4;
                       nxt_tail     = q_tail5;
                     end
        8'b????0111: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = q_tail3;
                       insert4      = 32'h0;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h3;
                       nxt_tail     = q_tail4;
                     end
        8'b?????011: begin
                       insert1      = q_tail1;
                       insert2      = q_tail2;
                       insert3      = 32'h0;
                       insert4      = 32'h0;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h2;
                       nxt_tail     = q_tail3;
                     end
        8'b??????01: begin
                       insert1      = q_tail1;
                       insert2      = 32'h0;
                       insert3      = 32'h0;
                       insert4      = 32'h0;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h1;
                       nxt_tail     = q_tail2;
                     end
        8'b???????0: begin
                       insert1      = 32'h0;
                       insert2      = 32'h0;
                       insert3      = 32'h0;
                       insert4      = 32'h0;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h0;
                       nxt_tail     = q_tail1;
                     end
        default:     begin
                       insert1      = 32'h0;
                       insert2      = 32'h0;
                       insert3      = 32'h0;
                       insert4      = 32'h0;
                       insert5      = 32'h0;
                       insert6      = 32'h0;
                       insert7      = 32'h0;
                       insert8      = 32'h0;
                       is_entry_num = 4'h0;
                       nxt_tail     = q_tail1;
                     end
      endcase
    end
  else
    begin
    insert1      = 32'h0;
    insert2      = 32'h0;
    insert3      = 32'h0;
    insert4      = 32'h0;
    insert5      = 32'h0;
    insert6      = 32'h0;
    insert7      = 32'h0;
    insert8      = 32'h0;
    is_entry_num = 4'h0;
    nxt_tail     = q_tail1;
    end
  end

  // find which instructions to remove
  always @ (*)
  begin : RemoveBlock
  if (removeInstructions_in)
    casex ({(q_valid_f & q_head1) == 0 ? 1'b0 : 1'b1,
            (q_cmov_f  & q_head1) == 0 ? 1'b0 : 1'b1,
            (q_valid_f & q_head2) == 0 ? 1'b0 : 1'b1,
            (q_cmov_f  & q_head2) == 0 ? 1'b0 : 1'b1,
            (q_valid_f & q_head3) == 0 ? 1'b0 : 1'b1,
            (q_cmov_f  & q_head3) == 0 ? 1'b0 : 1'b1,
            (q_valid_f & q_head4) == 0 ? 1'b0 : 1'b1,
            (q_cmov_f  & q_head4) == 0 ? 1'b0 : 1'b1})
      // remove cmov at head of queue
      8'b11??????: begin
                   remove1 = q_head1;
                   remove2 = 0;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 1;
                   q_head_new = q_head2;
                   end
      // remove up to first cmov
      8'b1011????: begin
                   remove1 = q_head1;
                   remove2 = 0;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 1;
                   q_head_new = q_head2;
                   end
      8'b101011??: begin
                   remove1 = q_head1;
                   remove2 = q_head2;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 2;
                   q_head_new = q_head3;
                   end
      8'b10101011: begin
                   remove1 = q_head1;
                   remove2 = q_head2;
                   remove3 = q_head3;
                   remove4 = 0;
                   rm_entry_num = 3;
                   q_head_new = q_head4;
                   end
      // no cmov's so remove as many as you can
      8'b0???????: begin
                   remove1 = 0;
                   remove2 = 0;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 0;
                   q_head_new = q_head1;
                   end
      8'b100?????: begin
                   remove1 = q_head1;
                   remove2 = 0;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 1;
                   q_head_new = q_head2;
                   end
      8'b10100???: begin
                   remove1 = q_head1;
                   remove2 = q_head2;
                   remove3 = 0;
                   remove4 = 0;
                   rm_entry_num = 2;
                   q_head_new = q_head3;
                   end
      8'b1010100?: begin
                   remove1 = q_head1;
                   remove2 = q_head2;
                   remove3 = q_head3;
                   remove4 = 0;
                   rm_entry_num = 3;
                   q_head_new = q_head4;
                   end
      8'b10101010: begin
                   remove1 = q_head1;
                   remove2 = q_head2;
                   remove3 = q_head3;
                   remove4 = q_head4;
                   rm_entry_num = 4;
                   q_head_new = q_head5;
                   end
      default:     begin
                   $display("Error in fetch2: rm_entry_num");
                   rm_entry_num = 0;
                   q_head_new = q_head1;
                   end
    endcase
  else
    begin
    remove1 = 0;
    remove2 = 0;
    remove3 = 0;
    remove4 = 0;
    rm_entry_num = 0;
    q_head_new = q_head1;
    end
  end

  // generate instruction outputs
  always @(*)
  begin : OutputBlock
    inst0_out = 0;
    inst1_out = 0;
    inst2_out = 0;
    inst3_out = 0;
    if (remove1 != 0)
      for (i=0; i<32; i=i+1)
        if (q_head1[i]) inst0_out = q_entry_f[i];
    if (remove2 != 0)
      for (i=0; i<32; i=i+1)
        if (q_head2[i]) inst1_out = q_entry_f[i];
    if (remove3 != 0)
      for (i=0; i<32; i=i+1)
        if (q_head3[i]) inst2_out = q_entry_f[i];
    if (remove4 != 0)
      for (i=0; i<32; i=i+1)
        if (q_head4[i]) inst3_out = q_entry_f[i];
  end


endmodule 
