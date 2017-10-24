/***************************************************************************

  Assumption:  4-instructions can be issued and 
  4(?)-instructions will retire in one cycle from Active List.
	
There are 4 ways and upto 4 issue queue entries
can be freed in a clock cycle.

***************************************************************************/

module issueq_fl(
	input clock,
	input reset_n,

	/* control execution flags from the Writeback Stage. If 
	* ctrlMispredict_i is 1, there has been a mis-predict. */
	input ctrlVerified_i,                    
	input ctrlMispredict_i,
	input [`SIZE_ISSUEQ-1:0] mispredictVector_i,

	input backEndReady_i,

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
	output freedValid3_o,

	/* 4 free Issue Queue entries for the new coming 
	* instructions. */
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry0_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry1_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry2_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry3_o,

/* Count of Valid Issue Q Entries goes to Dispatch */
	output [`SIZE_ISSUEQ_LOG:0] cntInstIssueQ_o
);

/***************************************************************************/
/* Instantiating SPEC FREE LIST Table & head/tail pointers */
reg [`SIZE_ISSUEQ_LOG-1:0] ISSUEQ_FREELIST [`SIZE_ISSUEQ-1:0];
reg [`SIZE_ISSUEQ_LOG-1:0] headPtr;
reg [`SIZE_ISSUEQ_LOG-1:0] tailPtr;

reg [`SIZE_ISSUEQ_LOG:0] issueQCount;	

/* Declaring wires and regs for Combinational Logic */
reg [`SIZE_ISSUEQ_LOG:0] issueQCount_f;
reg [`SIZE_ISSUEQ_LOG-1:0] headptr_f;
reg [`SIZE_ISSUEQ_LOG-1:0] tailptr_f;

integer i;

wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry0;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry1;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry2;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry3;

wire freedValid0;
wire freedValid1;
wire freedValid2;
wire freedValid3;

wire [`SIZE_ISSUEQ_LOG-1:0] wr_index0;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index1;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index2;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index3;

reg [`SIZE_ISSUEQ_LOG-1:0] rd_index0;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index1;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index2;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index3;


assign freedValid0_o = freedValid0;
assign freedValid1_o = freedValid1;
assign freedValid2_o = freedValid2;
assign freedValid3_o = freedValid3;

assign freedEntry0_o = freedEntry0;
assign freedEntry1_o = freedEntry1;
assign freedEntry2_o = freedEntry2;
assign freedEntry3_o = freedEntry3;

/* Sending Issue Queue occupied entries to Dispatch. */
assign cntInstIssueQ_o 	= issueQCount;

/* Pops 4 free Issue Queue entries from the FREE LIST for the new coming
* instructions. */
assign freeEntry0_o = ISSUEQ_FREELIST[rd_index0];
assign freeEntry1_o = ISSUEQ_FREELIST[rd_index1];
assign freeEntry2_o = ISSUEQ_FREELIST[rd_index2];
assign freeEntry3_o = ISSUEQ_FREELIST[rd_index3];

/* Generates read addresses for the FREELIST FIFO, using head pointer. */
always @(*)
begin
	rd_index0 = headPtr + 0;
	rd_index1 = headPtr + 1;
	rd_index2 = headPtr + 2;
	rd_index3 = headPtr + 3;
end
always @(*)
begin: ISSUEQ_COUNT
	reg isWrap1;
	reg [`SIZE_ISSUEQ_LOG:0] diff1;
	reg [`SIZE_ISSUEQ_LOG:0] diff2;
	reg [`ISSUE_WIDTH-1:0] totalFreed;

	headptr_f = (backEndReady_i) ? (headPtr+`DISPATCH_WIDTH) : headPtr;
	tailptr_f = (tailPtr + (freedValid3 + freedValid2 + freedValid1 + freedValid0));
	totalFreed = (freedValid3 + freedValid2 + freedValid1 + freedValid0);
	issueQCount_f = (issueQCount+ ((backEndReady_i) ? `DISPATCH_WIDTH:0)) - totalFreed;
end

/* Following updates the Free List Head Pointer, only if there is no control
* mispredict. */
always @(posedge clock or negedge reset_n)
begin
	if(!reset_n)
	begin
		headPtr <= 0;
	end
	else
	begin
		if(~ctrlMispredict_i)
			headPtr <= headptr_f;
	end
end


/* Follwoing maintains the issue queue occupancy count each cycle. */
always @(posedge clock or negedge reset_n)
begin
	if(!reset_n)
	begin
		issueQCount <= 0;
	end
	else
	begin
		issueQCount <= issueQCount_f;
	end
end

/* Following updates the FREE LIST counter and pushes the freed Issue 
*  Queue entry into the FREE LIST. */
assign wr_index0 = tailPtr + 0;
assign wr_index1 = tailPtr + 1;
assign wr_index2 = tailPtr + 2;
assign wr_index3 = tailPtr + 3;

always @ (posedge clock or negedge reset_n)
begin: WRITE_FREELIST
	if(!reset_n)
	begin
		for (i=0;i<`SIZE_ISSUEQ;i=i+1)
			ISSUEQ_FREELIST[i] <= i;

		tailPtr <= 0;
	end
	else
	begin
		tailPtr	<= tailptr_f;		

		case({freedValid3, freedValid2, freedValid1, freedValid0})
			4'b0001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
			end
			4'b0010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
			end
			4'b0011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
			end
			4'b0100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
			end
			4'b0101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
			end
			4'b0110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
			end
			4'b0111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
			end
			4'b1000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry3;
			end
			4'b1001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			4'b1010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			4'b1011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			4'b1100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			4'b1101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			4'b1110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			4'b1111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry3;
			end
		endcase
	end
end

FreeIssueq freeIq (.clock(clock),
	.reset_n(reset_n),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.mispredictVector_i(mispredictVector_i),
	.grantedEntry0_i(grantedEntry0_i),
	.grantedEntry1_i(grantedEntry1_i),
	.grantedEntry2_i(grantedEntry2_i),
	.grantedEntry3_i(grantedEntry3_i),

	.grantedValid0_i(grantedValid0_i),
	.grantedValid1_i(grantedValid1_i),
	.grantedValid2_i(grantedValid2_i),
	.grantedValid3_i(grantedValid3_i),

	.freedEntry0_o(freedEntry0),
	.freedEntry1_o(freedEntry1),
	.freedEntry2_o(freedEntry2),
	.freedEntry3_o(freedEntry3),

	.freedValid0_o(freedValid0),
	.freedValid1_o(freedValid1),
	.freedValid2_o(freedValid2),
	.freedValid3_o(freedValid3)
);

endmodule

