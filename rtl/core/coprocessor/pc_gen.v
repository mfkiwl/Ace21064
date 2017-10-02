//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : pc_gen.v
//  Author      : ejune@aureage.com
//                
//  Description : ace21064 pc generator
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module pc_gen (
  input wire         clock,
  input wire         reset_n,
  input wire         flush_vld_rt_i,
  input wire [63:0]  flush_pc_rt_i,
  input wire         override_vld_f1_i,
  input wire [63:0]  override_pc_f1_i,
  input wire [63:0]  branch_pc_f0_i,

  output wire [63:0] pc_s0_o,
  output wire [63:0] pc_s1_o,
  output wire [63:0] pc_s2_o,
  output wire [63:0] pc_s3_o,
  output wire [63:0] pc_s4_o,
  output wire [63:0] pc_s5_o,
  output wire [63:0] pc_s6_o,
  output wire [63:0] pc_s7_o,
  output wire [63:0] pc_s8_o,
  output wire [63:0] pc_s9_o,
  output wire [63:0] pc_s10_o,
  output wire [63:0] pc_s11_o
);

  reg [1:0] pc_sel;
  
  always @ (posedge clock or negedge reset_n)
  begin
    else if (!reset_n)
      pc_sel = 2'b00;
    else if (flush_vld_rt_i)
      pc_sel = 2'b01;
    else if (override_vld_f1_i)
      pc_sel = 2'b10;
    else
      pc_sel = 2'b11;
  end

  always @ *
  begin
    case(pc_sel)
      2'b00 : pc_s0_o = `RESET_PC;
      2'b01 : pc_s0_o = flush_pc_rt_i;
      2'b10 : pc_s0_o = overrride_pc_f1_i;
      2'b11 : pc_s0_o = branch_pc_f0_i;
    endcase
  end
  
  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n) begin
      pc_s1_o  <= 64'b0;
      pc_s2_o  <= 64'b0;
      pc_s3_o  <= 64'b0;
      pc_s4_o  <= 64'b0;
      pc_s5_o  <= 64'b0;
      pc_s6_o  <= 64'b0;
      pc_s7_o  <= 64'b0;
      pc_s8_o  <= 64'b0;
      pc_s9_o  <= 64'b0;
      pc_s10_o <= 64'b0;
      pc_s11_o <= 64'b0;
    end else begin
      pc_s1_o  <= pc_s0_o;
      pc_s2_o  <= pc_s1_o;
      pc_s3_o  <= pc_s2_o;
      pc_s4_o  <= pc_s3_o;
      pc_s5_o  <= pc_s4_o;
      pc_s6_o  <= pc_s5_o;
      pc_s7_o  <= pc_s6_o;
      pc_s8_o  <= pc_s7_o;
      pc_s9_o  <= pc_s8_o;
      pc_s10_o <= pc_s9_o;
      pc_s11_o <= pc_s10_o;
    end
  end

endmodule
