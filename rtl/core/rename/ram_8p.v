module ram_8p #(
  parameter DATAWIDTH = 64,
  parameter INDEXSIZE = 256,
  parameter LOGINDEX  = 8,
  parameter INITVALUE = 0
)(
  input                clock,
  input                reset_n,
  input                we1_in,
  input                we2_in,
  input                we3_in,
  input                we4_in,
  input                we5_in,
  input                we6_in,
  input                we7_in,
  input                we8_in,
  input [DATAWIDTH-1:0] data1_in,
  input [DATAWIDTH-1:0] data2_in,
  input [DATAWIDTH-1:0] data3_in,
  input [DATAWIDTH-1:0] data4_in,
  input [DATAWIDTH-1:0] data5_in,
  input [DATAWIDTH-1:0] data6_in,
  input [DATAWIDTH-1:0] data7_in,
  input [DATAWIDTH-1:0] data8_in,
  input [LOGINDEX-1:0] index1_in,
  input [LOGINDEX-1:0] index2_in,
  input [LOGINDEX-1:0] index3_in,
  input [LOGINDEX-1:0] index4_in,
  input [LOGINDEX-1:0] index5_in,
  input [LOGINDEX-1:0] index6_in,
  input [LOGINDEX-1:0] index7_in,
  input [LOGINDEX-1:0] index8_in,
  output [DATAWIDTH-1:0] data1_out,
  output [DATAWIDTH-1:0] data2_out,
  output [DATAWIDTH-1:0] data3_out,
  output [DATAWIDTH-1:0] data4_out,
  output [DATAWIDTH-1:0] data5_out,
  output [DATAWIDTH-1:0] data6_out,
  output [DATAWIDTH-1:0] data7_out,
  output [DATAWIDTH-1:0] data8_out
);

  reg [DATAWIDTH-1:0] data1_out;
  reg [DATAWIDTH-1:0] data2_out;
  reg [DATAWIDTH-1:0] data3_out;
  reg [DATAWIDTH-1:0] data4_out;
  reg [DATAWIDTH-1:0] data5_out;
  reg [DATAWIDTH-1:0] data6_out;
  reg [DATAWIDTH-1:0] data7_out;
  reg [DATAWIDTH-1:0] data8_out;

  reg [DATAWIDTH-1:0] ram_f [INDEXSIZE-1:0];
  reg [LOGINDEX:0] index_tmp;

  always @(negedge reset_n or posedge clock)
  begin
    if (!reset_n)
      for (index_tmp = 0; index_tmp < INDEXSIZE; index_tmp = index_tmp + 1)
        ram_f[index_tmp] = INITVALUE;
    else
      begin
      if (we1_in)
        ram_f[index1_in] <= data1_in;
      if (we2_in)
        ram_f[index2_in] <= data2_in;
      if (we3_in)
        ram_f[index3_in] <= data3_in;
      if (we4_in)
        ram_f[index4_in] <= data4_in;
      if (we5_in)
        ram_f[index5_in] <= data5_in;
      if (we6_in)
        ram_f[index6_in] <= data6_in;
      if (we7_in)
        ram_f[index7_in] <= data7_in;
      if (we8_in)
        ram_f[index8_in] <= data8_in;
      end
  end

  always @ *
  begin
    data1_out = ram_f[index1_in];
    data2_out = ram_f[index2_in];
    data3_out = ram_f[index3_in];
    data4_out = ram_f[index4_in];
    data5_out = ram_f[index5_in];
    data6_out = ram_f[index6_in];
    data7_out = ram_f[index7_in];
    data8_out = ram_f[index8_in];
  end

endmodule
