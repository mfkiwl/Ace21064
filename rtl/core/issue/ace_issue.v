module ace_issue(



);

        Scheduler sched0(inst0_issue0_in[`SIZE_SCHEDULER_INPUT:0],
                         inst1_issue0_in[`SIZE_SCHEDULER_INPUT:0],
                         inst2_issue0_in[`SIZE_SCHEDULER_INPUT:0],
                         inst3_issue0_in[`SIZE_SCHEDULER_INPUT:0],
                         clk,
                         new_rob_id0, new_rob_id1, new_rob_id2, new_rob_id3,
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*1-1:(`SCHEDULER_LOGSIZE + 2)*0+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*2-1:(`SCHEDULER_LOGSIZE + 2)*1+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*3-1:(`SCHEDULER_LOGSIZE + 2)*2+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*4-1:(`SCHEDULER_LOGSIZE + 2)*3+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*5-1:(`SCHEDULER_LOGSIZE + 2)*4+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*6-1:(`SCHEDULER_LOGSIZE + 2)*5+2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*0],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*2],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*3],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*4],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*5],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*0+1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*1+1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*2+1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*3+1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*4+1],
                         sched_out[(`SCHEDULER_LOGSIZE + 2)*5+1],
                         Ready_bits, reset_or_flush, rob_or_mob_full,
                         inst0_issue0_out, inst1_issue0_out, inst2_issue0_out,
                         inst3_issue0_out, inst4_issue0_out, inst5_issue0_out,
                         scheduler_full);


        regsI_RR regsIRR(inst0_issue0_out, inst1_issue0_out,
                         inst2_issue0_out, inst3_issue0_out, 
                         inst4_issue0_out, inst5_issue0_out,
                         inst0_rr_in, inst1_rr_in,
                         inst2_rr_in, inst3_rr_in,
                         inst4_rr_in, inst5_rr_in,
                         clk, flush, reset);

        assign Rc_in = {dest_wb_in[41:28],
                        mob_finished2_out[71:65], mob_finished1_out[71:65],dest_wb_in[27:0]};
        assign write_data = {mob_finished2_out[64:1], mob_finished1_out[64:1], val_wb_in[255:192],
                             i2_wb_in[`VAL+`VAL_LEN:`VAL], i1_wb_in[`VAL+`VAL_LEN:`VAL], i0_wb_in[`VAL+`VAL_LEN:`VAL]};
        assign write_valid = {i5_wb_in[`VALID] && !i5_wb_in[`LOAD],
                              i4_wb_in[`VALID] && !i4_wb_in[`LOAD],
                              mob_finished2_out[0], mob_finished1_out[0], write_wb_in[3:0]};

        assign alu_dest_regs_in = {mob_returned_hintdestreg2,
                                   mob_returned_hintdestreg1,
                                   i3_exec_out[`DEST_PHYS+6:`DEST_PHYS],
                                   i2_exec_out[`DEST_PHYS+6:`DEST_PHYS],
                                   i1_exec_out[`DEST_PHYS+6:`DEST_PHYS],
                                   i0_exec_out[`DEST_PHYS+6:`DEST_PHYS]};

        assign alu_dest_valid_in = {mob_returned_hintvalid2,
                                    mob_returned_hintvalid1,
                                    i3_exec_out[`VALID] && i3_exec_out[`WRITES_TO_DEST],
                                    i2_exec_out[`VALID] && i2_exec_out[`WRITES_TO_DEST],
                                    i1_exec_out[`VALID] && i1_exec_out[`WRITES_TO_DEST],
                                    i0_exec_out[`VALID] && i0_exec_out[`WRITES_TO_DEST]};

        reg_read rr0   (inst0_rr_in, inst1_rr_in, inst2_rr_in,
                        inst3_rr_in, inst4_rr_in, inst5_rr_in,
                        reset, clk, dump, rf_out,
                        write_data, Rc_in, write_valid,
                        cond_val_wb_out,
                        sbmask_in,
                        alu_dest_regs_in, alu_dest_valid_in,
                        Ready_bits,
                        inst0_rr_out, inst1_rr_out, inst2_rr_out,
                        inst3_rr_out, inst4_rr_out, inst5_rr_out);

        regs_RR_EX regs_rr_ex(i0_exec_in, i1_exec_in, i2_exec_in, i3_exec_in, i4_exec_in, i5_exec_in,
                              fwd_data_to_exec, fwd_valid_to_exec, fwd_cond_to_exec,
                              clk, reset, flush,
                              inst0_rr_out, inst1_rr_out, inst2_rr_out, inst3_rr_out, inst4_rr_out, inst5_rr_out,
                              write_data, write_valid[5:0],
                              cond_val_wb_out);


endmodule
