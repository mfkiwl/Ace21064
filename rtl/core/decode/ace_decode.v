
/******************************************************************************

  File: Decode.v

  Description: This file instantiates 4 decoders for the decode stage of
        the pipeline, and is all of the logic that goes between the
        pipeline registers of the decode stage. 

******************************************************************************/

module ace_decode (instruction0_decode_in, instruction1_decode_in, 
               instruction2_decode_in, instruction3_decode_in,
               instruction0_decode_out, instruction1_decode_out, 
               instruction2_decode_out, instruction3_decode_out);

wire [`SIZE_AFTER_FETCH:0] inst0_split_out, inst1_split_out;

input [`SIZE_AFTER_FETCH:0] instruction0_decode_in, instruction1_decode_in;
input [`SIZE_AFTER_FETCH:0] instruction2_decode_in, instruction3_decode_in;

output [`SIZE_AFTER_DECODE:0] instruction0_decode_out, instruction1_decode_out;
output [`SIZE_AFTER_DECODE:0] instruction2_decode_out, instruction3_decode_out;

decoder D0(inst0_split_out, instruction0_decode_out);
decoder D1(inst1_split_out, instruction1_decode_out);
decoder D2(instruction2_decode_in, instruction2_decode_out);
decoder D3(instruction3_decode_in, instruction3_decode_out);

endmodule
