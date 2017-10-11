//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : spec_rfl.v
//  Author      : ejune@aureage.com
//                
//  Description : speculative free register list 
//                This module holds the list of physical registers which
//                are not in use. The module must output up to 4 of its oldest
//                free registers, and be able to add up to 6 registers to the end
//                of the queue. These new free registers are received from retirement.
//
//                Note: if new registers are requested in instruction slots 0 and 4 
//                only, registers in queue locations 0 and 1 must be given to
//                instructions 0 and 3 respectively. This must be done to keep 
//                this speculative free register list in sync with the retirement
//                free register queue.
//                
//  Create Date : Apr 30 2017 
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module spec_rfl(
  input wire            clock,
  input wire            reset_n,
  // recover signal, set high on branch misprediction
  // where the rat contents get set to the parallel input
  // coming from the arch_freelist.
  input wire            arch_fl_rec_i,
  //the contents of the arch_freelist, combined in one bus
  // total 80 physical registers,
  // 32 Architecture registers,
  // 48 physical registers
  input wire [48*7-1:0] arch_fl_rec_data_i, 
  //set for each instruction being renamed, 
  //if it writes to a destination register or needs a free register for other purpose
  input wire            inst0_rd_req_i,
  input wire            inst1_rd_req_i,
  input wire            inst2_rd_req_i,
  input wire            inst3_rd_req_i,
  // the reg being freed by retirement that need to be added to the free register list
  input wire [6:0]      retire0_rls_rd_i,
  input wire [6:0]      retire1_rls_rd_i, 
  input wire [6:0]      retire2_rls_rd_i, 
  input wire [6:0]      retire3_rls_rd_i, 
  input wire [6:0]      retire4_rls_rd_i, 
  input wire [6:0]      retire5_rls_rd_i, 
  input wire [6:0]      retire6_rls_rd_i, 
  input wire [6:0]      retire7_rls_rd_i, 
  // the input freed register is valid or not
  input wire            retire0_rls_rd_vld_i,
  input wire            retire1_rls_rd_vld_i, 
  input wire            retire2_rls_rd_vld_i, 
  input wire            retire3_rls_rd_vld_i, 
  input wire            retire4_rls_rd_vld_i, 
  input wire            retire5_rls_rd_vld_i, 
  input wire            retire6_rls_rd_vld_i, 
  input wire            retire7_rls_rd_vld_i, 
  input wire            arch_stall_i,
  // output register contains free register if requested
  output                spec_rfl_stall_o,
  output [6:0]          inst0_freereg_o,
  output [6:0]          inst1_freereg_o,
  output [6:0]          inst2_freereg_o,
  output [6:0]          inst3_freereg_o,
  // to indicate the output register is valid or not
  output                inst0_freereg_vld_o,
  output                inst1_freereg_vld_o,
  output                inst2_freereg_vld_o,
  output                inst3_freereg_vld_o
);

  reg [5:0] cur_head_ptr;
  reg [5:0] cur_tail_ptr;
  reg [5:0] free_pr_cnt;        // number of available free regs
  reg [5:0] freereg_req_total;	// total freeregister request in current cycle 
  reg [5:0] freereg_ret_total;  // total register freeed in retire stage current cycle

  // RAM port wires
  reg [5:0] wport0_idx; // write port0 index 
  reg [6:0] wport0_data;  // write port0 data
  reg       wport0_we;
  reg [5:0] wport1_idx;
  reg [6:0] wport1_data;
  reg       wport1_we;
  reg [5:0] wport2_idx;
  reg [6:0] wport2_data;
  reg       wport2_we;
  reg [5:0] wport3_idx;
  reg [6:0] wport3_data;
  reg       wport3_we;
  reg [5:0] wport4_idx;
  reg [6:0] wport4_data;
  reg       wport4_we;
  reg [5:0] wport5_idx;
  reg [6:0] wport5_data;
  reg       wport5_we;
  reg [5:0] wport6_idx;
  reg [6:0] wport6_data;
  reg       wport6_we;
  reg [5:0] wport7_idx;
  reg [6:0] wport7_data;
  reg       wport7_we;

  reg [5:0] rport0_idx; // read port
  reg [5:0] rport1_idx;
  reg [5:0] rport2_idx;
  reg [5:0] rport3_idx;

  // next state head and tail pointers
  reg [5:0] nxt_head_ptr;
  reg [5:0] nxt_tail_ptr;

  // Register freelist memory
  // with 4 read/8 write ports
  /////////////////////////////////////////////////////////
  reg [6:0] rfl_mem [0:47];
  //read port
  //4 read ports for target register renameing 
  always @ ( * )
  begin
      inst0_freereg_o = rfl_mem[rport0_idx];
      inst1_freereg_o = rfl_mem[rport1_idx];
      inst2_freereg_o = rfl_mem[rport2_idx];
      inst3_freereg_o = rfl_mem[rport3_idx];
  end
  // write ports
  // 8 write ports for 8 width retire,(get free register)
  always @ ( posedge clock )
  begin
      case (we[7:0])
      8'b00000001 : rfl_mem[wport0_idx] <= data[0]; 
      8'b0000001? : rfl_mem[wport1_idx] <= data[1]; 
      8'b000001?? : rfl_mem[wport2_idx] <= data[2]; 
      8'b00001??? : rfl_mem[wport3_idx] <= data[3]; 
      8'b0001???? : rfl_mem[wport4_idx] <= data[4]; 
      8'b001????? : rfl_mem[wport5_idx] <= data[5]; 
      8'b01?????? : rfl_mem[wport6_idx] <= data[6]; 
      8'b1??????? : rfl_mem[wport7_idx] <= data[7]; 
      default     : ;
      endcase
  end
  /////////////////////////////////////////////////////////


  always @ ( * )
  begin
      nxt_head_ptr = cur_head_ptr;
      rport0_idx = 0;
      rport1_idx = 0;
      rport2_idx = 0;
      rport3_idx = 0;
      if (inst0_rd_req_i)
        begin
        rport0_idx = nxt_head_ptr;
        nxt_head_ptr = (nxt_head_ptr + 1) % 48;
        end
      if (inst1_rd_req_i)
        begin
        rport1_idx = nxt_head_ptr;
        nxt_head_ptr = (nxt_head_ptr + 1) % 48;
        end
      if (inst2_rd_req_i)
        begin
        rport2_idx = nxt_head_ptr;
        nxt_head_ptr = (nxt_head_ptr + 1) % 48;
        end
      if (inst3_rd_req_i)
        begin
        rport3_idx = nxt_head_ptr;
        nxt_head_ptr = (nxt_head_ptr + 1) % 48;
        end
      if (arch_stall_i)
        nxt_head_ptr = cur_head_ptr;
  end

  always @ ( * )
  begin
    nxt_tail_ptr = cur_tail_ptr;
    if (retire0_rls_rd_vld_i)
      begin
      wport0_idx  = nxt_tail_ptr;
      wport0_data = retire0_rls_rd_i;
      wport0_we   = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire1_rls_rd_vld_i)
      begin
      wport1_idx  = nxt_tail_ptr;
      wport1_data = retire1_rls_rd_i;
      wport1_we   = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire2_rls_rd_vld_i)
      begin
      wport2_idx  = nxt_tail_ptr;
      wport2_data = retire2_rls_rd_i;
      wport2_we   = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire3_rls_rd_vld_i)
      begin
      wport3_idx  = nxt_tail_ptr;
      wport3_data = retire3_rls_rd_i;
      wport3_we   = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire4_rls_rd_vld_i)
      begin
      wport4_idx   = nxt_tail_ptr;
      wport4_data  = retire4_rls_rd_i;
      wport4_we    = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire5_rls_rd_vld_i)
      begin
      wport5_idx   = nxt_tail_ptr;
      wport5_data  = retire5_rls_rd_i;
      wport5_we    = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire6_rls_rd_vld_i)
      begin
      wport6_idx   = nxt_tail_ptr;
      wport6_data  = retire6_rls_rd_i;
      wport6_we    = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
    if (retire7_rls_rd_vld_i)
      begin
      wport7_idx   = nxt_tail_ptr;
      wport7_data  = retire7_rls_rd_i;
      wport7_we    = 1'b1;
      nxt_tail_ptr = (nxt_tail_ptr + 1) % 48;
      end
  end

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
    begin
      cur_head_ptr      = 6'b0;
      cur_tail_ptr      = 6'b0;
      free_pr_cnt = 48;
    end
    else if (arch_fl_rec_i)
    begin
      cur_head_ptr <= nxt_tail_ptr;
      cur_tail_ptr <= nxt_tail_ptr;
      free_pr_cnt <= (`NUM_PHYS_REGS-32);
    end
    else
    begin
      cur_head_ptr <= nxt_head_ptr;
      cur_tail_ptr <= nxt_tail_ptr;
      free_pr_cnt <= free_pr_cnt + freereg_ret_total 
                                 - inst0_freereg_vld_o 
                                 - inst1_freereg_vld_o 
                                 - inst2_freereg_vld_o 
                                 - inst3_freereg_vld_o;
    end
  end

  assign freereg_req_total = inst0_rd_req_i + inst1_rd_req_i
                           + inst2_rd_req_i + inst3_rd_req_i;

  assign freereg_ret_total = retire0_rls_rd_vld_i + retire1_rls_rd_vld_i 
                           + retire2_rls_rd_vld_i + retire3_rls_rd_vld_i
                           + retire4_rls_rd_vld_i + retire5_rls_rd_vld_i 
                           + retire6_rls_rd_vld_i + retire7_rls_rd_vld_i;

  assign spec_rfl_stall_o = (free_pr_cnt < (freereg_req_total)) ? 1'b1 : 1'b0;

  assign inst0_freereg_vld_o = inst0_rd_req_i & ~spec_rfl_stall_o & ~arch_stall_i;
  assign inst1_freereg_vld_o = inst1_rd_req_i & ~spec_rfl_stall_o & ~arch_stall_i;
  assign inst2_freereg_vld_o = inst2_rd_req_i & ~spec_rfl_stall_o & ~arch_stall_i;
  assign inst3_freereg_vld_o = inst3_rd_req_i & ~spec_rfl_stall_o & ~arch_stall_i;

endmodule
