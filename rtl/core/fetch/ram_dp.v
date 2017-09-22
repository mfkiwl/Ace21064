module ram_dp#(
  parameter DATAWIDTH = 64,
  parameter INDEXSIZE = 256,
  parameter LOGINDEX = 8,
  parameter INITVALUE = 0
)(
  input wire                  clock,
  input wire                  reset_n,
  input wire                  we1_in,
  input wire                  we2_in,
  input wire  [DATAWIDTH-1:0] data1_in,
  input wire  [DATAWIDTH-1:0] data2_in,
  input wire  [LOGINDEX-1 :0] index1_in,
  input wire  [LOGINDEX-1 :0] index2_in,
  output reg  [DATAWIDTH-1:0] data1_out,
  output reg  [DATAWIDTH-1:0] data2_out
);


  reg [LOGINDEX   :0] index_tmp;

  reg [DATAWIDTH-1:0] ram_f [INDEXSIZE-1:0];

  always @ *
  begin
    data1_out = ram_f[index1_in];
  end

  always @ *
  begin
    data2_out = ram_f[index2_in];
  end

  always @(posedge clock or negedge reset_n)
  begin
    if (!reset_n)
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
