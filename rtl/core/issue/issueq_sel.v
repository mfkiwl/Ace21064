module issueq_sel(
    input wire [31:0]  req_vec_i,

    output wire        grant_vld_o,
    output wire [31:0] grant_vec_o,    /* One-hot grant vector */
    output wire [4:0]  grant_idx_o     /* Encoded form of grant_vec_o */
);

wire [31:0] grant_vec;
wire [ 4:0] grant_idx;

wire sel_oct_0;
wire sel_oct_1;
wire sel_oct_2;
wire sel_oct_3;
wire sel_quard;

/* grantIn signals propagating backwards from the front of the select tree */
wire grant_quard_0;
wire grand_quard_1;
wire grand_quard_2;
wire grand_quard_3;

assign grant_vld_o = sel_quard;
assign grant_vec_o = grant_vec;
assign grant_idx_o = grant_idx;

// Stage 0 (deals with 32 -> 8 conversion) *
sel_oct  i_sel_oct0_0(
    .req0_i(req_vec_i[0]),
    .req1_i(req_vec_i[1]),
    .req2_i(req_vec_i[2]),
    .req3_i(req_vec_i[3]),
    .req4_i(req_vec_i[4]),
    .req5_i(req_vec_i[5]),
    .req6_i(req_vec_i[6]),
    .req7_i(req_vec_i[7]),
    .grant_i(grant_quard_0),
    .grant0_o(grant_vec[0]),
    .grant1_o(grant_vec[1]),
    .grant2_o(grant_vec[2]),
    .grant3_o(grant_vec[3]),
    .grant4_o(grant_vec[4]),
    .grant5_o(grant_vec[5]),
    .grant6_o(grant_vec[6]),
    .grant7_o(grant_vec[7]),
    .req_o(sel_oct_0)
);

sel_oct  i_sel_oct0_1(
    .req0_i(req_vec_i[8]),
    .req1_i(req_vec_i[9]),
    .req2_i(req_vec_i[10]),
    .req3_i(req_vec_i[11]),
    .req4_i(req_vec_i[12]),
    .req5_i(req_vec_i[13]),
    .req6_i(req_vec_i[14]),
    .req7_i(req_vec_i[15]),
    .grant_i(grand_quard_1),
    .grant0_o(grant_vec[8]),
    .grant1_o(grant_vec[9]),
    .grant2_o(grant_vec[10]),
    .grant3_o(grant_vec[11]),
    .grant4_o(grant_vec[12]),
    .grant5_o(grant_vec[13]),
    .grant6_o(grant_vec[14]),
    .grant7_o(grant_vec[15]),
    .req_o(sel_oct_1)
);

sel_oct  i_sel_oct0_2(
    .req0_i(req_vec_i[16]),
    .req1_i(req_vec_i[17]),
    .req2_i(req_vec_i[18]),
    .req3_i(req_vec_i[19]),
    .req4_i(req_vec_i[20]),
    .req5_i(req_vec_i[21]),
    .req6_i(req_vec_i[22]),
    .req7_i(req_vec_i[23]),
    .grant_i(grand_quard_2),
    .grant0_o(grant_vec[16]),
    .grant1_o(grant_vec[17]),
    .grant2_o(grant_vec[18]),
    .grant3_o(grant_vec[19]),
    .grant4_o(grant_vec[20]),
    .grant5_o(grant_vec[21]),
    .grant6_o(grant_vec[22]),
    .grant7_o(grant_vec[23]),
    .req_o(sel_oct_2)
);

sel_oct  i_sel_oct0_3(
    .req0_i(req_vec_i[24]),
    .req1_i(req_vec_i[25]),
    .req2_i(req_vec_i[26]),
    .req3_i(req_vec_i[27]),
    .req4_i(req_vec_i[28]),
    .req5_i(req_vec_i[29]),
    .req6_i(req_vec_i[30]),
    .req7_i(req_vec_i[31]),
    .grant_i(grand_quard_3),
    .grant0_o(grant_vec[24]),
    .grant1_o(grant_vec[25]),
    .grant2_o(grant_vec[26]),
    .grant3_o(grant_vec[27]),
    .grant4_o(grant_vec[28]),
    .grant5_o(grant_vec[29]),
    .grant6_o(grant_vec[30]),
    .grant7_o(grant_vec[31]),
    .req_o(sel_oct_3)
);

// Stage 1 (deals with 4 -> 1 conversion) 

sel_quard  i_sel_quard1_0(
    .req0_i(sel_oct_0),
    .req1_i(sel_oct_1),
    .req2_i(sel_oct_2),
    .req3_i(sel_oct_3),
    .grant_i(1'b1),/* Enable signal for the select tree */
    .grant0_o(grant_quard_0),
    .grant1_o(grand_quard_1),
    .grant2_o(grand_quard_2),
    .grant3_o(grand_quard_3),
    .req_o(sel_quard)
);

encoder #(32, 5) 
grant_encoder(
    .vector_i(grant_vec),
    .encoded_o(grant_idx)
);


endmodule
