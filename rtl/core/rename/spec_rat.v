//////////////////////////////////////////////////////////////////////////////////////////
//
//  File Name   : spec_rat.v
//  Author      : ejune@aureage.com
//                
//  Description : speculative register alias table
//                this module keeps the register alias info which are renamed
//       
//                
//                
//                
//  Create Date : Apr 30 2017 
//  Version     : v0.1 
//
//////////////////////////////////////////////////////////////////////////////////////////

module spec_rat(
  input wire              clock
  // source operands
  input wire [4:0]        inst0_ars1_i, 
  input wire [4:0]        inst0_ars2_i,     
  // arch reg that needs to have a new remapping because of new writing to it
  input wire [4:0]        inst0_ard_i,
  // a free phy reg to replace the old register mapping for corresponding arch reg
  input wire [6:0]        inst0_prd_i,
  // a valid signal for each arch/phy pair, tells the rat to write new data or not
  input wire              inst0_rd_we_i,

  input wire [4:0]        inst1_ars1_i,     
  input wire [4:0]        inst1_ars2_i,     
  input wire [4:0]        inst1_ard_i,  
  input wire [6:0]        inst1_prd_i,  
  input wire              inst1_rd_we_i,

  input wire [4:0]        inst2_ars1_i,     
  input wire [4:0]        inst2_ars2_i,     
  input wire [4:0]        inst2_ard_i,  
  input wire [6:0]        inst2_prd_i,  
  input wire              inst2_rd_we_i,

  input wire [4:0]        inst3_ars1_i,     
  input wire [4:0]        inst3_ars2_i,     
  input wire [4:0]        inst3_ard_i,  
  input wire [6:0]        inst3_prd_i,  
  input wire              inst3_rd_we_i,

  // recover signal, set high on branch misprediction
  // where the rat contents get set to the parallel input
  // coming from the arch_rat.
  input wire              arch_rat_rec_i,  
  //the contents of the arch_rat, combined into one bus
  input wire [32*7-1 : 0] arch_rat_rec_data_i,
  input wire              arch_stall_i,
  // physical mapping for each source operands, determined by the rat
  output [6:0]            inst0_prs1_o,
  output [6:0]            inst1_prs1_o,
  output [6:0]            inst2_prs1_o,
  output [6:0]            inst3_prs1_o,

  output [6:0]            inst0_prs2_o,
  output [6:0]            inst1_prs2_o,
  output [6:0]            inst2_prs2_o,
  output [6:0]            inst3_prs2_o,

  output [6:0]            inst0_ard_o,
  output [6:0]            inst1_ard_o,
  output [6:0]            inst2_ard_o,
  output [6:0]            inst3_ard_o
);

// RAT memory file data width 7, data depth 32
reg [6:0] rat_mem [0:31];
//read port
always @ ( * )
begin
    inst0_prs1_o = rat_mem[inst0_ars1_i]; 
    inst0_prs2_o = rat_mem[inst0_ars2_i]; 
    inst1_prs1_o = rat_mem[inst1_ars1_i]; 
    inst1_prs2_o = rat_mem[inst1_ars2_i]; 
    inst2_prs1_o = rat_mem[inst2_ars1_i]; 
    inst2_prs2_o = rat_mem[inst2_ars2_i]; 
    inst3_prs1_o = rat_mem[inst3_ars1_i]; 
    inst3_prs2_o = rat_mem[inst3_ars2_i]; 
end

// write port
wire [3:0] rat_wt_we;
assign rat_rd_we = {(inst0_rd_we_i & ~arch_stall_i),
                    (inst1_rd_we_i & ~arch_stall_i),
                    (inst2_rd_we_i & ~arch_stall_i),
                    (inst3_rd_we_i & ~arch_stall_i)};

always @ (posedge clock)
begin
    case (rat_rd_we)
    4'b0001 : rat_mem[inst0_ard_i] <= inst0_prd_i;
    4'b001? : rat_mem[inst1_ard_i] <= inst1_prd_i;
    4'b01?? : rat_mem[inst2_ard_i] <= inst2_prd_i;
    4'b1??? : rat_mem[inst3_ard_i] <= inst3_prd_i;
    default : ;
    endcase
end

/*
  RAM_12P #(
       7,    // Data width
      32,    // index size
       5,    // log(index size)
       0     // iniitial value
  )
  ratfile_ram(
           .clock(clock),
           .reset(1'b0),
           // read ports
           // 8 read ports, becaurse of 8 source register for 4 instructions
           // in worst case
           .data1_in(),
           .index1_in(inst0_ars1_i),
           .we1_in(1'b0),
           .data2_in(),
           .index2_in(inst0_ars2_i),
           .we2_in(1'b0),
           .data3_in(),
           .index3_in(inst1_ars1_i),
           .we3_in(1'b0),
           .data4_in(),
           .index4_in(inst1_ars2_i),
           .we4_in(1'b0),
           .data5_in(),
           .index5_in(inst2_ars1_i),
           .we5_in(1'b0),
           .data6_in(),
           .index6_in(inst2_ars2_i),
           .we6_in(1'b0),
           .data7_in(),
           .index7_in(inst3_ars1_i),
           .we7_in(1'b0),
           .data8_in(),
           .index8_in(inst3_ars2_i),
           .we8_in(1'b0),
           // write ports
           // 4 write ports, 4 dest register for 4 instructions in worst case
           .data9_in  (inst0_prd_i),
           .index9_in (inst0_ard_i),
           .we9_in    (inst0_rd_we_i & ~arch_stall_i),

           .data10_in (inst1_prd_i),
           .index10_in(inst1_ard_i),
           .we10_in   (inst1_rd_we_i & ~arch_stall_i),
           .data11_in (inst2_prd_i),
           .index11_in(inst2_ard_i),
           .we11_in   (inst2_rd_we_i & ~arch_stall_i),
           .data12_in (inst3_prd_i),
           .index12_in(inst3_ard_i),
           .we12_in   (inst3_rd_we_i & ~arch_stall_i),

           .data1_out (inst0_prs1_o),
           .data2_out (inst0_prs2_o),
           .data3_out (inst1_prs1_o),
           .data4_out (inst1_prs2_o),
           .data5_out (inst2_prs1_o),
           .data6_out (inst2_prs2_o),
           .data7_out (inst3_prs1_o),
           .data8_out (inst3_prs2_o),
           .data9_out (inst0_ard_o),
           .data10_out(inst1_ard_o),
           .data11_out(inst2_ard_o),
           .data12_out(inst3_ard_o)
          );
*/

`ifdef SIM
integer TempInt;
initial
begin
    for (TempInt = 0; TempInt < 32; TempInt = TempInt + 1)
        ratfile_ram.ram_f[TempInt] = TempInt; //0-31 Arch maps to 0-31 Phys Initially
end
`endif

  always @ (posedge clock)
  begin
    if (arch_rat_rec_i)
      begin
// hack
#1
`ifdef ACE_RENAME_ASSERT
        $display("Mapping before reset");
        for (TempInt=0; TempInt<32; TempInt=TempInt+1)
          $display("%d: %d", TempInt, ratfile[TempInt]);
`endif // ACE_RENAME_ASSERT
        ratfile_ram.ram_f[0]  = arch_rat_rec_data_i[6:0];
        ratfile_ram.ram_f[1]  = arch_rat_rec_data_i[13:7];
        ratfile_ram.ram_f[2]  = arch_rat_rec_data_i[20:14];
        ratfile_ram.ram_f[3]  = arch_rat_rec_data_i[27:21];
        ratfile_ram.ram_f[4]  = arch_rat_rec_data_i[34:28];
        ratfile_ram.ram_f[5]  = arch_rat_rec_data_i[41:35];
        ratfile_ram.ram_f[6]  = arch_rat_rec_data_i[48:42];
        ratfile_ram.ram_f[7]  = arch_rat_rec_data_i[55:49];
        ratfile_ram.ram_f[8]  = arch_rat_rec_data_i[62:56];
        ratfile_ram.ram_f[9]  = arch_rat_rec_data_i[69:63];
        ratfile_ram.ram_f[10] = arch_rat_rec_data_i[76:70];
        ratfile_ram.ram_f[11] = arch_rat_rec_data_i[83:77];
        ratfile_ram.ram_f[12] = arch_rat_rec_data_i[90:84];
        ratfile_ram.ram_f[13] = arch_rat_rec_data_i[97:91];
        ratfile_ram.ram_f[14] = arch_rat_rec_data_i[104:98];
        ratfile_ram.ram_f[15] = arch_rat_rec_data_i[111:105];
        ratfile_ram.ram_f[16] = arch_rat_rec_data_i[118:112];
        ratfile_ram.ram_f[17] = arch_rat_rec_data_i[125:119];
        ratfile_ram.ram_f[18] = arch_rat_rec_data_i[132:126];
        ratfile_ram.ram_f[19] = arch_rat_rec_data_i[139:133];
        ratfile_ram.ram_f[20] = arch_rat_rec_data_i[146:140];
        ratfile_ram.ram_f[21] = arch_rat_rec_data_i[153:147];
        ratfile_ram.ram_f[22] = arch_rat_rec_data_i[160:154];
        ratfile_ram.ram_f[23] = arch_rat_rec_data_i[167:161];
        ratfile_ram.ram_f[24] = arch_rat_rec_data_i[174:168];
        ratfile_ram.ram_f[25] = arch_rat_rec_data_i[181:175];
        ratfile_ram.ram_f[26] = arch_rat_rec_data_i[188:182];
        ratfile_ram.ram_f[27] = arch_rat_rec_data_i[195:189];
        ratfile_ram.ram_f[28] = arch_rat_rec_data_i[202:196];
        ratfile_ram.ram_f[29] = arch_rat_rec_data_i[209:203];
        ratfile_ram.ram_f[30] = arch_rat_rec_data_i[216:210];
        ratfile_ram.ram_f[31] = arch_rat_rec_data_i[223:217];

`ifdef ACE_RENAME_ASSERT
        $display("Mapping after reset");
        for (TempInt=0; TempInt<32; TempInt=TempInt+1)
          $display("%d: %d", TempInt, ratfile[TempInt]);
`endif // ACE_RENAME_ASSERT
      end
    end        

  endmodule
