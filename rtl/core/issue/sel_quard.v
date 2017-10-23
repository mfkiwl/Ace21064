module sel_quard(
    input wire req0_i,
    input wire req1_i,
    input wire req2_i,
    input wire req3_i,

    /* The grant signal coming in from the next stage of the select tree */
    input wire grant_i,

    output wire grant0_o,
    output wire grant1_o,
    output wire grant2_o,
    output wire grant3_o,
    /* OR of the request signals, used as req_i for next stage of the select tree */
    output wire req_o
);

wire [3:0] req;
wire [3:0] grant;
reg  [3:0] mask;

/* Code to deal with vectors instead of individual wires */
assign req   = {req3_i, req2_i, req1_i, req0_i};
assign req_o = |req;

/* Gate the current grant output with the grant_i from the next stage of the select tree */
assign grant0_o = grant[0] & grant_i;
assign grant1_o = grant[1] & grant_i;
assign grant2_o = grant[2] & grant_i;
assign grant3_o = grant[3] & grant_i;

integer j;
always @ *
begin: encoder 
    mask[0] = 1'b1;
    for(j=1; j<4; j=j+1)
    begin
        if(req[j-1] == 1'b1)
            mask[j] = 0;
        else
            mask[j] = mask[j-1];
    end
end
assign grant = req & mask;

endmodule

