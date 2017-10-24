module free_sel(input [15:0] blockVector_i,
	output freeingScalar_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate_o   			
);

reg freeingScalar;
reg [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate;

assign freeingCandidate_o = freeingCandidate;
assign freeingScalar_o = freeingScalar;

always @(*)
begin:FIND_FREEING_CANDIDATE_0
	casex({blockVector_i[15], blockVector_i[14], blockVector_i[13], blockVector_i[12], blockVector_i[11], blockVector_i[10], blockVector_i[9], blockVector_i[8], blockVector_i[7], blockVector_i[6], blockVector_i[5], blockVector_i[4], blockVector_i[3], blockVector_i[2], blockVector_i[1], blockVector_i[0]})
		16'bxxxxxxxxxxxxxxx1:
		begin
			freeingCandidate = 6'b000000;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxxxxxxx10:
		begin
			freeingCandidate = 6'b000001;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxxxxxx100:
		begin
			freeingCandidate = 6'b000010;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxxxxx1000:
		begin
			freeingCandidate = 6'b000011;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxxxx10000:
		begin
			freeingCandidate = 6'b000100;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxxx100000:
		begin
			freeingCandidate = 6'b000101;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxxx1000000:
		begin
			freeingCandidate = 6'b000110;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxxx10000000:
		begin
			freeingCandidate = 6'b000111;
			freeingScalar = 1'b1;
		end
		16'bxxxxxxx100000000:
		begin
			freeingCandidate = 6'b001000;
			freeingScalar = 1'b1;
		end
		16'bxxxxxx1000000000:
		begin
			freeingCandidate = 6'b001001;
			freeingScalar = 1'b1;
		end
		16'bxxxxx10000000000:
		begin
			freeingCandidate = 6'b001010;
			freeingScalar = 1'b1;
		end
		16'bxxxx100000000000:
		begin
			freeingCandidate = 6'b001011;
			freeingScalar = 1'b1;
		end
		16'bxxx1000000000000:
		begin
			freeingCandidate = 6'b001100;
			freeingScalar = 1'b1;
		end
		16'bxx10000000000000:
		begin
			freeingCandidate = 6'b001101;
			freeingScalar = 1'b1;
		end
		16'bx100000000000000:
		begin
			freeingCandidate = 6'b001110;
			freeingScalar = 1'b1;
		end
		16'b1000000000000000:
		begin
			freeingCandidate = 6'b001111;
			freeingScalar = 1'b1;
		end
 		default:
 		begin
  			freeingCandidate = 0;
  			freeingScalar = 0;
  		end
	endcase
end

endmodule

