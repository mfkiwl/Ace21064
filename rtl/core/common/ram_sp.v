/*single port ram module*/
module ram_sp #(
  parameter DATAWIDTH = 64,
  parameter INDEXSIZE = 256,
  parameter LOGINDEX = 8,
  parameter INITVALUE = 0
)(
  input  wire                    clock,
  input  wire                    reset_n,
  input  wire                    we_in,
  input  wire [DATAWIDTH-1:0]    data_in,
  input  wire [LOGINDEX-1 :0]    index_in,
  output wire [DATAWIDTH-1:0]    data_out
);

  reg [LOGINDEX:0] index_tmp;
  reg [DATAWIDTH-1:0]  ram_f [INDEXSIZE-1:0];

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
      for (index_tmp = 0; index_tmp < INDEXSIZE; index_tmp = index_tmp + 1)
        ram_f[index_tmp] <= INITVALUE;
    else
      if (we_in)
        ram_f[index_in] <= data_in;
  end

  assign  data_out = ram_f[index_in];

endmodule 
