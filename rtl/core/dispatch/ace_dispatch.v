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
   

);


endmodule
