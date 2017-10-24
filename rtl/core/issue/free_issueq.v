
module free_issueq(
	input clock,
	input reset_n,
		    
	/* control execution flags from the Writeback Stage. if
	* ctrlMispredict_i is 1, there has been a mis-predict. */
	input ctrlVerified_i,
	input ctrlMispredict_i,
	
	/* mispredicted vector is set of issue queue entries 
	* invalidated due to branch misprediction. These entries
	* should be inserted into issue queue free list. */
	input [`SIZE_ISSUEQ-1:0] mispredictVector_i,

	/* 4 entries being freed once they have been issued. */
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry0_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry1_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry2_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry3_i,

	input grantedValid0_i,
	input grantedValid1_i,
	input grantedValid2_i,
	input grantedValid3_i,

	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry0_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry1_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry2_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry3_o,

	output freedValid0_o,
	output freedValid1_o,
	output freedValid2_o,
	output freedValid3_o
);

reg [`SIZE_ISSUEQ-1:0] freedVector;

/* wires and regs declaration for combinational logic. */
reg [`SIZE_ISSUEQ-1:0] freedVector_t;

wire freeingScalar00;
wire freeingScalar01;
wire freeingScalar02;
wire freeingScalar03;

wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate00;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate01;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate02;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate03;

reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry0;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry1;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry2;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry3;

reg freedValid0;
reg freedValid1;
reg freedValid2;
reg freedValid3;

reg [`SIZE_ISSUEQ-1:0] freedVector_t1;

assign freedValid0_o = freedValid0;
assign freedValid1_o = freedValid1;
assign freedValid2_o = freedValid2;
assign freedValid3_o = freedValid3;

assign freedEntry0_o = freedEntry0;
assign freedEntry1_o = freedEntry1;
assign freedEntry2_o = freedEntry2;
assign freedEntry3_o = freedEntry3;

/* Following combinational logic updates the freedValid vector based on:
 *	1. if there are instructions issued this cycle from issue queue 
 *	  (they need to be freed)
 *      2. if there is a branch mispredict this cycle, freedVector need to
 *	   be updated with mispredictVector.
 *	3. if a issue queue entry has been freed this cycle, its corresponding
 *	   bit in the freedVector should be set to 0. */

always @(*)
begin: UPDATE_FREED_VECTOR
	integer i;

	freedValid0 = freeingScalar00;
	freedValid1 = freeingScalar01;
	freedValid2 = freeingScalar02;
	freedValid3 = freeingScalar03;

	if(freeingScalar00)
		freedEntry0 = 6'd0 + freeingCandidate00;
	else
		freedEntry0 = 6'd0;

	if(freeingScalar01)
		freedEntry1 = 6'd16 + freeingCandidate01;
	else
		freedEntry1 = 6'd0;

	if(freeingScalar02)
		freedEntry2 = 6'd32 + freeingCandidate02;
	else
		freedEntry2 = 6'd0;

	if(freeingScalar03)
		freedEntry3 = 6'd48 + freeingCandidate03;
	else
		freedEntry3 = 6'd0;

	if(ctrlMispredict_i)
		freedVector_t1 = freedVector | mispredictVector_i;
	else
		freedVector_t1 = freedVector;
		
	for(i=0;i<`SIZE_ISSUEQ;i=i+1)	
	begin
		if((grantedValid0_i && (i == grantedEntry0_i)) ||
		(grantedValid1_i && (i == grantedEntry1_i)) ||
		(grantedValid2_i && (i == grantedEntry2_i)) ||
		(grantedValid3_i && (i == grantedEntry3_i)))
			freedVector_t[i] = 1'b1;
		else if((freedValid0 && (i == freedEntry0)) ||
		(freedValid1 && (i == freedEntry1)) ||
		(freedValid2 && (i == freedEntry2)) ||
		(freedValid3 && (i == freedEntry3)))
			freedVector_t[i] = 1'b0;
		else
			freedVector_t[i] = freedVector_t1[i];
	end
end

/* Following writes newly computed freed vector to freedVector register every cycle. */
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
	begin
		freedVector <= 0;
	end
	else
	begin
		freedVector <= freedVector_t;
	end	 	
end

/* Following instantiate "selectFromBlock" module to get upto 4 freed issue queue
 * entries this cycle. */
free_sel selectFromBlock00_l1(
    .blockVector_i(freedVector[15:0]),
	.freeingScalar_o(freeingScalar00),
	.freeingCandidate_o(freeingCandidate00)
);

free_sel selectFromBlock01_l1(
    .blockVector_i(freedVector[31:16]),
	.freeingScalar_o(freeingScalar01),
	.freeingCandidate_o(freeingCandidate01)
);

free_sel selectFromBlock02_l1(
    .blockVector_i(freedVector[47:32]),
	.freeingScalar_o(freeingScalar02),
	.freeingCandidate_o(freeingCandidate02)
);

free_sel selectFromBlock03_l1(
    .blockVector_i(freedVector[63:48]),
	.freeingScalar_o(freeingScalar03),
	.freeingCandidate_o(freeingCandidate03)
);

endmodule
