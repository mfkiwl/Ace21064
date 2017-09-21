/*single port ram module*/
module ram_sp(
  input  wire                    clk,
  input  wire                    reset,
  input  wire                    we_in,
  input  wire [DATAWIDTH-1:0]    data_in,
  input  wire [LOGINDEX-1 :0]    index_in,
  output wire [DATAWIDTH-1:0]    data_out
),

  parameter DATAWIDTH = 64,
  parameter INDEXSIZE = 256,
  parameter LOGINDEX = 8,
  parameter INITVALUE = 0,

  reg [LOGINDEX:0] index_tmp,
  reg [DATAWIDTH-1:0]  ram_f [INDEXSIZE-1:0],

  always @(posedge clk or posedge reset)
  begin
    if (reset)
      for (index_tmp = 0, index_tmp < INDEXSIZE; index_tmp = index_tmp + 1)
        ram_f[index_tmp] <= INITVALUE,
    else
      if (we_in)
        ram_f[index_in] <= data_in,
  end

  assign  data_out = ram_f[index_in],

endmodule 
