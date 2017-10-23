module sel_oct(
    input wire req0_i,
    input wire req1_i,
    input wire req2_i,
    input wire req3_i,
    input wire req4_i,
    input wire req5_i,
    input wire req6_i,
    input wire req7_i,

    /* The grant signal coming in from the next stage of the select tree */
    input wire grant_i,

    output wire grant0_o,
    output wire grant1_o,
    output wire grant2_o,
    output wire grant3_o,
    output wire grant4_o,
    output wire grant5_o,
    output wire grant6_o,
    output wire grant7_o,
    /* OR of the request signals, used as req_i for next stage of the select tree */
    output wire req_o
);

wire [7:0] req;
wire [7:0] grant;
reg  [7:0] mask;

/* Code to deal with vectors instead of individual wires */
assign req   = {req7_i, req6_i, req5_i, req4_i, req3_i, req2_i, req1_i, req0_i};
assign req_o = |req;

/* Gate the current grant output with the grant_i from the next stage of the select tree */
assign grant0_o = grant[0] & grant_i;
assign grant1_o = grant[1] & grant_i;
assign grant2_o = grant[2] & grant_i;
assign grant3_o = grant[3] & grant_i;
assign grant4_o = grant[4] & grant_i;
assign grant5_o = grant[5] & grant_i;
assign grant6_o = grant[6] & grant_i;
assign grant7_o = grant[7] & grant_i;

integer j;
always @ *
begin: encoder 
    mask[0] = 1'b1;
    for(j=1; j<8; j=j+1)
    begin
        if(req[j-1] == 1'b1)
            mask[j] = 0;
        else
            mask[j] = mask[j-1];
    end
end
assign grant = req & mask;

endmodule

