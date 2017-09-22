module ram_dp(
  clk,
  reset,
  we1_in,
  we2_in,
  data1_in,
  data2_in,
  index1_in,
  index2_in,
  data1_out,
  data2_out
);

  parameter DATAWIDTH = 64;
  parameter INDEXSIZE = 256;
  parameter LOGINDEX = 8;
  parameter INITVALUE = 0;

  input                  clk;
  input                  reset;
  input                  we1_in;
  input                  we2_in;
  input  [DATAWIDTH-1:0] data1_in;
  input  [DATAWIDTH-1:0] data2_in;
  input  [LOGINDEX-1 :0] index1_in;
  input  [LOGINDEX-1 :0] index2_in;
  output [DATAWIDTH-1:0] data1_out;
  output [DATAWIDTH-1:0] data2_out;

  reg [LOGINDEX   :0] index_tmp;
  reg [DATAWIDTH-1:0] data1_out, data2_out;

  reg [DATAWIDTH-1:0] ram_f [INDEXSIZE-1:0];

  always @(ram_f[index1_in])
  begin
    data1_out = ram_f[index1_in];
  end

  always @(ram_f[index2_in])
  begin
    data2_out = ram_f[index2_in];
  end

  always @(posedge reset or posedge clk)
  begin
    if (reset)
      for (index_tmp = 0; index_tmp < INDEXSIZE; index_tmp = index_tmp + 1)
        ram_f[index_tmp] <= INITVALUE;
    else
      begin
      if (we1_in)
        ram_f[index1_in] <= data1_in;
      if (we2_in)
        ram_f[index2_in] <= data2_in;
      end
  end

endmodule
