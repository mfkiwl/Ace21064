module simple_alu(
  input  [63:0]  rs1_i,
  input  [63:0]  rs2_i,
  input  [ 5:0]  opcode,
  input  [ 6:0]  op_func,
  input  [15:0]  mem_func,
  output [63:0]  rd_o,
  output         exception_o
);


  reg [15:0] mask;
  reg [5:0] shamt;
  reg [63:0] temp;
  reg exception;

  assign rd_o = temp;
  assign exception_o = exception;

  always @ *
  begin
    temp = 0;
    exception = 1'b1;
    case (opcode)
      6'h00,
      6'hxx:begin
            // do nothing, this is a NOP
            end

  end

endmodule
