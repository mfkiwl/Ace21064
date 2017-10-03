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
  input  wire           icache_stall_i,
  input  wire           invalid_f1_i,

  input  wire           br_uncond_f1_i, // JAL;JALR which will be used as func call

  input  wire           bpd_pred_f1_i,
  input  wire [63:0]    brdec_rasdat_f1_i,       // The data to be pushed into stack.

  input  wire           btb_hit_f0_i,
  input  wire           btb_brdir_f1_i, 
  input  wire [ 1:0]    btb_rasctl_f0_i,         // Push pop control signal.

  input  wire [ 3:0]    bob_rasptr_f1r_i,
  input  wire           bob_vld_f1r_i,

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
  wire        ras_index_sel;
  wire        ras_override;
  wire        ras_flush;
  wire [ 1:0] ras_ctl;
  wire [ 3:0] ras_ptr_tmp;

  always @ (posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      ras_op_cur <= 2'h0;
    else 
      ras_op_cur <= ras_op_nxt;
  end

  always @ *
  begin
    ras_op_nxt = 2'hx;
    case (ras_op_cur)
    NOOP : begin
             if()
           end
         
    

  end


  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      ras_idx_cur <= 4'h0;
    else 
      ras_idx_cur <= ras_idx_nxt;
  end

  assign ras_ctl = btb_rasctl_f0_i & {2{~icache_stall_i & btb_hit_f0_i}};

  assign ras_override     = bpd_pred_f1_i | br_uncond_f1_i |
                          ((ras_ctl != 2'b00) & ~btb_brdir_f1_i & ~invalid_f1_i);
  assign ras_flush        = flush_rt_i & bob_vld_f1r_i;
  assign ras_we           = ras_ctl[0] & ~invalid_f1_i & ~ras_override; 
  assign ras_index_sel    = (ras_ctl & {2{~ras_override}});

  always @ *
  begin
      if (ras_flush)
        case (ras_index_sel)
          NOOP   : ras_idx_nxt =  bob_rasptr_f1r_i;
          PUSH   : ras_idx_nxt = (bob_rasptr_f1r_i+1)%16;
          POP    : ras_idx_nxt = (bob_rasptr_f1r_i-1)%16;
          PUSHPOP   : ras_idx_nxt =  bob_rasptr_f1r_i;
          default:;
        endcase
      else
        case (ras_index_sel)
          NOOP   : ras_idx_nxt =  ras_idx_cur;           
          PUSH   : ras_idx_nxt = (ras_idx_cur+1)%16;
          POP    : ras_idx_nxt = (ras_idx_cur-1)%16;
          PUSHPOP   : ras_idx_nxt =  ras_idx_cur;
          default:;
        endcase
  end

  always @ *
  begin
      case (ras_ctl)
      2'b00 : ras_ptr_tmp = ras_idx_cur;
      2'b01 : ras_ptr_tmp = ras_idx_cur + 1;
      2'b10 : ras_ptr_tmp = ras_idx_cur - 1;
      2'b11 : ras_ptr_tmp = ras_idx_cur;
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

  assign ras_ptr_f0_o     = ras_flush ? bob_rasptr_f1r_i  : ras_ptr_tmp;
  assign ras_data_f0_o    = ras_we    ? brdec_rasdat_f1_i : ras_data_tmp;

endmodule
