//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ras.v
//  Author      : ejune@aureage.com
//                
//  Description : return address stack
//                the ras have 16 entries in current design, which with width
//                64(pc width) 
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module ras(
  input  wire           clock,
  input  wire           reset_n,
  input  wire           flush_rt_i,
  input  wire           invalid_f1_i,

  input  wire           br_uncond_f1_i, // JAL;JALR which will be used as func call

  input  wire           bpd_pred_f1_i,
  input  wire [63:0]    brdec_rasdat_f1_i,       // The data to be pushed into stack.

  input  wire           btb_hit_f0_i,
  input  wire           btb_brdir_f1_i, 
  input  wire [ 1:0]    btb_rasctl_f0_i,         // Push pop control signal.

  input  wire [ 3:0]    bob_rasptr_f1r_i,
  input  wire           bob_entryvld_f1r_i,

  output wire [63:0]    ras_data_f0_o,           // The data on top of stack.
  output wire [ 3:0]    ras_ptr_f0_o             // kept in bob
);

  localparam NOOP    = 3'b00;       // No operation
  localparam PUSH    = 3'b01;       // Push stack
  localparam POP     = 3'b10;       // Pop stack
  localparam POPPUSH = 3'b11;       // Pop then push

  reg  [ 3:0] ras_idx_cur;
  reg  [ 3:0] ras_idx_nxt;
  wire [63:0] ras_data_tmp;
  wire        ras_we;
  wire        ras_op;
  wire        ras_override;
  wire        ras_flush;
  wire [ 1:0] ras_ctl;
  reg  [ 3:0] ras_ptr_tmp;

  assign ras_override = bpd_pred_f1_i & br_uncond_f1_i & ~invalid_f1_i ;
  assign ras_ctl      = btb_rasctl_f0_i & {2{btb_hit_f0_i}};
  assign ras_flush    = flush_rt_i & bob_entryvld_f1r_i;
  assign ras_we       = ras_ctl[0] & ~ras_override; 
  assign ras_op       = (ras_ctl & {2{~ras_override}});

  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      ras_idx_cur <= 4'h0;
    else 
      ras_idx_cur <= ras_idx_nxt;
  end

  always @ *
  begin
      case (ras_op)
      NOOP    : begin
                  if (ras_flush)
                    ras_idx_nxt =  bob_rasptr_f1r_i;
                  else
                    ras_idx_nxt =  ras_idx_cur;           
                end
      PUSH    : begin
                  if (ras_flush)
                    ras_idx_nxt = (bob_rasptr_f1r_i+1)%16;
                  else
                    ras_idx_nxt = (ras_idx_cur+1)%16;
                end
      POP     : begin
                  if (ras_flush)
                    ras_idx_nxt = (bob_rasptr_f1r_i-1)%16;
                  else
                    ras_idx_nxt = (ras_idx_cur-1)%16;
                end
      POPPUSH : begin
                  if (ras_flush)
                    ras_idx_nxt =  bob_rasptr_f1r_i;
                  else
                    ras_idx_nxt =  ras_idx_cur;
                end
      default :;
      endcase
  end

  ram_sp #(64,16,4,0)
  stack_ram(
    .clock       (clock),
    .reset_n     (reset_n),
    .we_in       (ras_we),
    .index_in    (ras_idx_cur),
    .data_in     (brdec_rasdat_f1_i),
    .data_out    (ras_data_tmp)
  );

  assign ras_ptr_tmp = ras_ctl[1] ? (ras_ctl[0] ? ras_idx_cur : ras_idx_cur-1)
                                  : (ras_ctl[0] ? ras_idx_cur+1 : ras_idx_cur);

  assign ras_ptr_f0_o     = ras_flush ? bob_rasptr_f1r_i  : ras_ptr_tmp;
  assign ras_data_f0_o    = ras_we    ? brdec_rasdat_f1_i : ras_data_tmp;

endmodule
