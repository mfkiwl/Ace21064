module encoder#(
    parameter ENCODER_WIDTH = 32,
    parameter ENCODER_WIDTH_LOG = 5,
)(
    input  wire [ENCODER_WIDTH-1:0] vector_i,
    output wire [ENCODER_WIDTH_LOG-1:0] encoded_o
);

reg [ENCODER_WIDTH_LOG-1:0] t [ENCODER_WIDTH-1:0];
reg [ENCODER_WIDTH-1:0]     u [ENCODER_WIDTH_LOG-1:0];
reg [ENCODER_WIDTH_LOG-1:0] encoded;

integer i;
integer j;

always @ * 
begin: encoder 
	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		if(vector_i[i] == 1'b1)
			t[i] = i;
		else
			t[i] = 0;
	end

	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
		begin
			u[j][i] = t[i][j];
		end
	end

	for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
	begin
		encoded[j] = |u[j];
	end
end

assign encoded_o = encoded;

endmodule

