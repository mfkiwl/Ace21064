//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : ace_dispatch.v
//  Author      : ejune@aureage.com
//                
//  Description : dispatch module dispatches renamed packets to Issue Queue, Active
//                List, and Load-Store queue.
//                Before dipatching it checks if there is enough space for incoming
//                instructions in Issue Queue, Active List, and Load-Store queue.
//                Dispatch width is same as rename width 
//                
//                
//  Create Date : original_time
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////
module ace_dispatch (
    input               clock,
    input               reset_n,
    input               stall_i,
    input               rename_inst0rs1phys_i,
    input               rename_inst1rs1phys_i,
    input               rename_inst2rs1phys_i,
    input               rename_inst3rs1phys_i,
    input               rename_inst0rs2phys_i,
    input               rename_inst1rs2phys_i,
    input               rename_inst2rs2phys_i,
    input               rename_inst3rs2phys_i,
    input               rename_inst0rdphys_i,
    input               rename_inst1rdphys_i,
    input               rename_inst2rdphys_i,
    input               rename_inst3rdphys_i,
    input               rename_inst0stvld_i,
    input               rename_inst1stvld_i,
    input               rename_inst2stvld_i,
    input               rename_inst3stvld_i,
    input               rename_inst0ldvld_i,
    input               rename_inst1ldvld_i,
    input               rename_inst2ldvld_i,
    input               rename_inst3ldvld_i,
    input               decode_inst0memory_i,
    input               decode_inst1memory_i,
    input               decode_inst2memory_i,
    input               decode_inst3memory_i,
    input               decode_inst0branch_i,
    input               decode_inst1branch_i,
    input               decode_inst2branch_i,
    input               decode_inst3branch_i,
    input               decode_inst0simple_i,
    input               decode_inst1simple_i,
    input               decode_inst2simple_i,
    input               decode_inst3simple_i,
    input               decode_inst0complx_i,
    input               decode_inst1complx_i,
    input               decode_inst2complx_i,
    input               decode_inst3complx_i,
    input               execute_ldq_cnt_i,
    input               execute_stq_cnt_i,
    input               issue_rs0_cnt_i,
    input               issue_rs1_cnt_i,
    input               retire_rob_cnt_i,
    output              dispatch_rob_wdata0_o, // write data for reorder buffer
    output              dispatch_rob_wdata1_o, 
    output              dispatch_rob_wdata2_o, 
    output              dispatch_rob_wdata3_o, 
    output              dispatch_rs0_wdata0_o, // write data for reservation station 0
    output              dispatch_rs0_wdata1_o,
    output              dispatch_rs0_wdata2_o,
    output              dispatch_rs0_wdata3_o,
    output              dispatch_rs1_wdata0_o, // write data for reservation station 1
    output              dispatch_rs1_wdata1_o,
    output              dispatch_rs1_wdata2_o,
    output              dispatch_rs1_wdata3_o,
    output              dispatch_lsq_wdata0_o, // write data for load store queue 
    output              dispatch_lsq_wdata1_o,
    output              dispatch_lsq_wdata2_o,
    output              dispatch_lsq_wdata3_o,
    output              dispatch_backend_rdy_o,
    output              dispatch_frotend_stl_o
);

wire [3:0] load_num;
wire [3:0] store_num;
wire [3:0] simple_num;
wire [3:0] complx_num;
wire [3:0] branch_num;
wire       ld_stall;
wire       st_stall;
wire       rs0_stall;
wire       rs1_stall;
wire       rob_stall;

// Counts the number of different instructions in the incoming set of instructions.
assign load_num   = rename_inst0ldvld_i  + rename_inst1ldvld_i+
                    rename_inst2ldvld_i  + rename_inst3ldvld_i;
assign store_num  = rename_inst0stvld_i  + rename_inst1stvld_i+
                    rename_inst2stvld_i  + rename_inst3stvld_i;
assign simple_num = decode_inst0simple_i + decode_inst1simple_i+
                    decode_inst2simple_i + decode_inst3simple_i;
assign complx_num = decode_inst0complx_i + decode_inst1complx_i+
                    decode_inst2complx_i + decode_inst3complx_i;
assign branch_num = decode_inst0branch_i + decode_inst1branch_i+
                    decode_inst2branch_i + decode_inst3branch_i;
assign memory_num = decode_inst0memory_i + decode_inst1memory_i+
                    decode_inst2memory_i + decode_inst3memory_i;

// Checks the empty space in LSQ/RS0/RS1/ROB for new instructions
assign ld_stall   = ((execute_ldq_cnt_i +  load_num) > `LSQ_DEPTH);
assign st_stall   = ((execute_stq_cnt_i + store_num) > `LSQ_DEPTH);
assign rs0_stall  = ((issue_rs0_cnt_i   + complx_num + branch_num) > `RS0_DEPTH);
assign rs1_stall  = ((issue_rs1_cnt_i   + simple_num + memory_num) > `RS1_DEPTH);
assign rob_stall  = ((retire_rob_cnt_i  + 4) > `ROB_DEPTH);

assign dispatch_frotend_stl_o = ld_stall | st_stall | rs0_stall | rs1_stall | rob_stall;

// reorder buffer contains following information:
// 0     - valid bit
// 1     - ret_inst
// 2     - syscall_inst
// 3     - csr_inst
// 4     - store_inst
// 5     - load_inst
//       - phys_rs1
//       - phys_rs2
//       - phys_rd 
//       - pc
//       - exception
assign dispatch_rob_wdata0_o =  
assign dispatch_rob_wdata1_o = 
assign dispatch_rob_wdata2_o = 
assign dispatch_rob_wdata3_o = 

// reservation station data contains following information:
// 0     - valid bit
//       - rs_id 
//         lsq_id
//         rob_id
//         checkpoint_id
//         
//       - phys_rs1
//         phys_rs2
//         phys_rd
//         imm
//         ls_typ
//         opcode
//         pc
//         predicted target addr
//         branch prediction

assign dispatch_rs0_wdata0_o = 
assign dispatch_rs0_wdata1_o = 
assign dispatch_rs0_wdata2_o = 
assign dispatch_rs0_wdata3_o = 
assign dispatch_rs1_wdata0_o = 
assign dispatch_rs1_wdata1_o = 
assign dispatch_rs1_wdata2_o = 
assign dispatch_rs1_wdata3_o = 

// load strore queue data contains following information:
//         valid
//         store_inst
//         load_inst
assign dispatch_lsq_wdata0_o = 
assign dispatch_lsq_wdata1_o = 
assign dispatch_lsq_wdata2_o = 
assign dispatch_lsq_wdata3_o = 


endmodule
