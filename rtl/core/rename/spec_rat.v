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
  input wire              clock,
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
  output reg [6:0]            inst0_prs1_o,
  output reg [6:0]            inst1_prs1_o,
  output reg [6:0]            inst2_prs1_o,
  output reg [6:0]            inst3_prs1_o,

  output reg [6:0]            inst0_prs2_o,
  output reg [6:0]            inst1_prs2_o,
  output reg [6:0]            inst2_prs2_o,
  output reg [6:0]            inst3_prs2_o,

  output reg [6:0]            inst0_ard_o,
  output reg [6:0]            inst1_ard_o,
  output reg [6:0]            inst2_ard_o,
  output reg [6:0]            inst3_ard_o
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

    inst0_ard_o  = rat_mem[inst0_ard_i];
    inst1_ard_o  = rat_mem[inst1_ard_i];
    inst2_ard_o  = rat_mem[inst2_ard_i];
    inst3_ard_o  = rat_mem[inst3_ard_i];

end

// write port
wire [3:0] rat_rd_we;
assign rat_rd_we = {(inst0_rd_we_i & ~arch_stall_i),
                    (inst1_rd_we_i & ~arch_stall_i),
                    (inst2_rd_we_i & ~arch_stall_i),
                    (inst3_rd_we_i & ~arch_stall_i)};

always @ (posedge clock)
begin
    if (arch_rat_rec_i)
    begin
        rat_mem[0]  <= arch_rat_rec_data_i[6:0];
        rat_mem[1]  <= arch_rat_rec_data_i[13:7];
        rat_mem[2]  <= arch_rat_rec_data_i[20:14];
        rat_mem[3]  <= arch_rat_rec_data_i[27:21];
        rat_mem[4]  <= arch_rat_rec_data_i[34:28];
        rat_mem[5]  <= arch_rat_rec_data_i[41:35];
        rat_mem[6]  <= arch_rat_rec_data_i[48:42];
        rat_mem[7]  <= arch_rat_rec_data_i[55:49];
        rat_mem[8]  <= arch_rat_rec_data_i[62:56];
        rat_mem[9]  <= arch_rat_rec_data_i[69:63];
        rat_mem[10] <= arch_rat_rec_data_i[76:70];
        rat_mem[11] <= arch_rat_rec_data_i[83:77];
        rat_mem[12] <= arch_rat_rec_data_i[90:84];
        rat_mem[13] <= arch_rat_rec_data_i[97:91];
        rat_mem[14] <= arch_rat_rec_data_i[104:98];
        rat_mem[15] <= arch_rat_rec_data_i[111:105];
        rat_mem[16] <= arch_rat_rec_data_i[118:112];
        rat_mem[17] <= arch_rat_rec_data_i[125:119];
        rat_mem[18] <= arch_rat_rec_data_i[132:126];
        rat_mem[19] <= arch_rat_rec_data_i[139:133];
        rat_mem[20] <= arch_rat_rec_data_i[146:140];
        rat_mem[21] <= arch_rat_rec_data_i[153:147];
        rat_mem[22] <= arch_rat_rec_data_i[160:154];
        rat_mem[23] <= arch_rat_rec_data_i[167:161];
        rat_mem[24] <= arch_rat_rec_data_i[174:168];
        rat_mem[25] <= arch_rat_rec_data_i[181:175];
        rat_mem[26] <= arch_rat_rec_data_i[188:182];
        rat_mem[27] <= arch_rat_rec_data_i[195:189];
        rat_mem[28] <= arch_rat_rec_data_i[202:196];
        rat_mem[29] <= arch_rat_rec_data_i[209:203];
        rat_mem[30] <= arch_rat_rec_data_i[216:210];
        rat_mem[31] <= arch_rat_rec_data_i[223:217];
    end
    else 
        case (rat_rd_we)
        4'b0001 : rat_mem[inst0_ard_i] <= inst0_prd_i;
        4'b001? : rat_mem[inst1_ard_i] <= inst1_prd_i;
        4'b01?? : rat_mem[inst2_ard_i] <= inst2_prd_i;
        4'b1??? : rat_mem[inst3_ard_i] <= inst3_prd_i;
        default : ;
        endcase
end

`ifdef SIM
integer i;
initial
begin
    for (i = 0; i < 32; i = i + 1)
        rat_mem[i] = i; //0-31 Arch maps to 0-31 Phys Initially
end
`endif


endmodule
