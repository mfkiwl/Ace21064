//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ras.v
//  Author      : ejune@aureage.com
//                
//  Description : return address stack
//                64x16 
//                
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module ras(
  input  wire           clock,
  input  wire           reset_n,
//  input  wire           ras_flush, //flush signal come from retire stage
  input  wire           flush_rt_i,
  input  wire           icache_stall_i,
  input  wire           bob_vld_i,

//  input  wire           ras_we,
  input  wire           invalid_f1_i,

//  input  wire           ras_override,
  input  wire           bpd_override_i,
  input  wire           btb_brtyp_i,
  input  wire           btb_brdir_r_i, 

  input  wire [63:0]    ras_data_i,            // The data to be pushed into stack.

  input  wire [ 1:0]    btb_rasctl_i,            // Push pop control signal.
  input  wire           btb_hit_i,

  input  wire [ 3:0]    ras_ptr_rt_i,

  output wire [63:0]    ras_data_o,           // The data on top of stack.
  output wire           ras_valid_o,
  output wire [ 3:0]    ras_ptr_o
);

  localparam NOAC = 3'b000; // No action.
  localparam PUSH = 3'b001; // Push stack.
  localparam POP  = 3'b010; // Pop stack.
  localparam POPU = 3'b011; // Pop then push.
  localparam FLUSH_NOAC = 3'b100; // No action.
  localparam FLUSH_PUSH = 3'b101; // Push stack.
  localparam FLUSH_POP  = 3'b110; // Pop stack.
  localparam FLUSH_POPU = 3'b111; // Pop then push.

  // internal vars
  reg  [ 3:0] ras_index;
  reg  [ 3:0] ras_index_tmp;
  wire [63:0] ras_data_tmp;
  wire        ras_we;
  wire        ras_index_sel;
  wire        ras_override;
  wire        ras_flush;
  wire [ 1:0] ras_ctl;
  wire [ 3:0] ras_ptr_tmp;

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      ras_index <= 4'h0;
    else 
      ras_index <= ras_index_tmp;
  end

  always @ ( * )
  begin
      case (ras_index_sel)
        NOAC         : ras_index_tmp = ras_index;           
        PUSH         : ras_index_tmp = (ras_index+1)%16;
        POP          : ras_index_tmp = (ras_index-1)%16;
        POPU         : ras_index_tmp = ras_index;
        FLUSH_NOAC   : ras_index_tmp = ras_ptr_rt_i;
        FLUSH_PUSH   : ras_index_tmp = (ras_ptr_rt_i+1)%16;
        FLUSH_POP    : ras_index_tmp = (ras_ptr_rt_i-1)%16;
        FLUSH_POPU   : ras_index_tmp = ras_ptr_rt_i;
        default:;
      endcase
  end

  ram_sp #(64,16,4,0)
  stack_ram(
    .clock       (clock),
    .reset_n     (reset_n),
    .we_in       (ras_we),
    .data_in     (ras_data_i),
    .index_in    (ras_index),
    .data_out    (ras_data_tmp)
  );

  assign ras_ctl          = btb_rasctl_i & {2{~icache_stall_i & btb_hit_i}};
  assign ras_override     = bpd_override_i | 
                          ((btb_brtyp_i == `BR_UNCOND) & ~btb_brdir_r_i & ~invalid_f1_i) |
                          ((ras_ctl != 2'b00) & ~btb_brdir_r_i & ~invalid_f1_i);

  assign ras_flush        = flush_rt_i & bob_vld_i;
  assign ras_we           = ras_ctl[0] & ~invalid_f1_i & ~ras_override; 

  assign ras_index_sel    = {ras_flush,(ras_ctl & {2{~ras_override}})};

  assign ras_ptr_tmp[3:0] = ras_ctl[1] ? 
                           (ras_ctl[0] ? ras_index   : ras_index-1):
                           (ras_ctl[0] ? ras_index+1 : ras_index  );

  assign ras_ptr_o        = ras_flush ? ras_ptr_rt_i : ras_ptr_tmp;
  assign ras_data_o       = ras_we    ? ras_data_i   : ras_data_tmp;
  assign ras_valid_o      = 1'b1;

endmodule
