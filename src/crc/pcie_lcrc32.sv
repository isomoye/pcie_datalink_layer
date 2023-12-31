// vim: ts=4 sw=4 expandtab

// THIS IS GENERATED VERILOG CODE.
// https://bues.ch/h/crcgen
//
// This code is Public Domain.
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
// RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.

//`ifndef CRC_V_
//`define CRC_V_

// CRC polynomial coefficients: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
//                              0x4C11DB7 (hex)
// CRC width:                   32 bits
// CRC shift direction:         left (big endian)
// Input word width:            32 bits

module pcie_lcrc32 (
    input  wire [31:0] crcIn,
    input  wire [31:0] data,
    output wire [31:0] crcOut
);
  assign crcOut[0] = crcIn[0] ^ crcIn[6] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[16] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[6] ^ data[9] ^ data[10] ^ data[12] ^ data[16] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[29] ^ data[30] ^ data[31];
  assign crcOut[1] = crcIn[0] ^ crcIn[1] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[16] ^ crcIn[17] ^ crcIn[24] ^ crcIn[27] ^ crcIn[28] ^ data[0] ^ data[1] ^ data[6] ^ data[7] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[16] ^ data[17] ^ data[24] ^ data[27] ^ data[28];
  assign crcOut[2] = crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[17] ^ crcIn[18] ^ crcIn[24] ^ crcIn[26] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[2] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[13] ^ data[14] ^ data[16] ^ data[17] ^ data[18] ^ data[24] ^ data[26] ^ data[30] ^ data[31];
  assign crcOut[3] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[14] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[19] ^ crcIn[25] ^ crcIn[27] ^ crcIn[31] ^ data[1] ^ data[2] ^ data[3] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[14] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[25] ^ data[27] ^ data[31];
  assign crcOut[4] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[8] ^ crcIn[11] ^ crcIn[12] ^ crcIn[15] ^ crcIn[18] ^ crcIn[19] ^ crcIn[20] ^ crcIn[24] ^ crcIn[25] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[8] ^ data[11] ^ data[12] ^ data[15] ^ data[18] ^ data[19] ^ data[20] ^ data[24] ^ data[25] ^ data[29] ^ data[30] ^ data[31];
  assign crcOut[5] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[10] ^ crcIn[13] ^ crcIn[19] ^ crcIn[20] ^ crcIn[21] ^ crcIn[24] ^ crcIn[28] ^ crcIn[29] ^ data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[10] ^ data[13] ^ data[19] ^ data[20] ^ data[21] ^ data[24] ^ data[28] ^ data[29];
  assign crcOut[6] = crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[11] ^ crcIn[14] ^ crcIn[20] ^ crcIn[21] ^ crcIn[22] ^ crcIn[25] ^ crcIn[29] ^ crcIn[30] ^ data[1] ^ data[2] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[11] ^ data[14] ^ data[20] ^ data[21] ^ data[22] ^ data[25] ^ data[29] ^ data[30];
  assign crcOut[7] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[15] ^ crcIn[16] ^ crcIn[21] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[28] ^ crcIn[29] ^ data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[7] ^ data[8] ^ data[10] ^ data[15] ^ data[16] ^ data[21] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[28] ^ data[29];
  assign crcOut[8] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[8] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[17] ^ crcIn[22] ^ crcIn[23] ^ crcIn[28] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[8] ^ data[10] ^ data[11] ^ data[12] ^ data[17] ^ data[22] ^ data[23] ^ data[28] ^ data[31];
  assign crcOut[9] = crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[18] ^ crcIn[23] ^ crcIn[24] ^ crcIn[29] ^ data[1] ^ data[2] ^ data[4] ^ data[5] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[18] ^ data[23] ^ data[24] ^ data[29];
  assign crcOut[10] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[19] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[9] ^ data[13] ^ data[14] ^ data[16] ^ data[19] ^ data[26] ^ data[28] ^ data[29] ^ data[31];
  assign crcOut[11] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[9] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ crcIn[16] ^ crcIn[17] ^ crcIn[20] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[9] ^ data[12] ^ data[14] ^ data[15] ^ data[16] ^ data[17] ^ data[20] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[31];
  assign crcOut[12] = crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[9] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[21] ^ crcIn[24] ^ crcIn[27] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[2] ^ data[4] ^ data[5] ^ data[6] ^ data[9] ^ data[12] ^ data[13] ^ data[15] ^ data[17] ^ data[18] ^ data[21] ^ data[24] ^ data[27] ^ data[30] ^ data[31];
  assign crcOut[13] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[10] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[18] ^ crcIn[19] ^ crcIn[22] ^ crcIn[25] ^ crcIn[28] ^ crcIn[31] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[6] ^ data[7] ^ data[10] ^ data[13] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[22] ^ data[25] ^ data[28] ^ data[31];
  assign crcOut[14] = crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[11] ^ crcIn[14] ^ crcIn[15] ^ crcIn[17] ^ crcIn[19] ^ crcIn[20] ^ crcIn[23] ^ crcIn[26] ^ crcIn[29] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[7] ^ data[8] ^ data[11] ^ data[14] ^ data[15] ^ data[17] ^ data[19] ^ data[20] ^ data[23] ^ data[26] ^ data[29];
  assign crcOut[15] = crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[12] ^ crcIn[15] ^ crcIn[16] ^ crcIn[18] ^ crcIn[20] ^ crcIn[21] ^ crcIn[24] ^ crcIn[27] ^ crcIn[30] ^ data[3] ^ data[4] ^ data[5] ^ data[7] ^ data[8] ^ data[9] ^ data[12] ^ data[15] ^ data[16] ^ data[18] ^ data[20] ^ data[21] ^ data[24] ^ data[27] ^ data[30];
  assign crcOut[16] = crcIn[0] ^ crcIn[4] ^ crcIn[5] ^ crcIn[8] ^ crcIn[12] ^ crcIn[13] ^ crcIn[17] ^ crcIn[19] ^ crcIn[21] ^ crcIn[22] ^ crcIn[24] ^ crcIn[26] ^ crcIn[29] ^ crcIn[30] ^ data[0] ^ data[4] ^ data[5] ^ data[8] ^ data[12] ^ data[13] ^ data[17] ^ data[19] ^ data[21] ^ data[22] ^ data[24] ^ data[26] ^ data[29] ^ data[30];
  assign crcOut[17] = crcIn[1] ^ crcIn[5] ^ crcIn[6] ^ crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ crcIn[18] ^ crcIn[20] ^ crcIn[22] ^ crcIn[23] ^ crcIn[25] ^ crcIn[27] ^ crcIn[30] ^ crcIn[31] ^ data[1] ^ data[5] ^ data[6] ^ data[9] ^ data[13] ^ data[14] ^ data[18] ^ data[20] ^ data[22] ^ data[23] ^ data[25] ^ data[27] ^ data[30] ^ data[31];
  assign crcOut[18] = crcIn[2] ^ crcIn[6] ^ crcIn[7] ^ crcIn[10] ^ crcIn[14] ^ crcIn[15] ^ crcIn[19] ^ crcIn[21] ^ crcIn[23] ^ crcIn[24] ^ crcIn[26] ^ crcIn[28] ^ crcIn[31] ^ data[2] ^ data[6] ^ data[7] ^ data[10] ^ data[14] ^ data[15] ^ data[19] ^ data[21] ^ data[23] ^ data[24] ^ data[26] ^ data[28] ^ data[31];
  assign crcOut[19] = crcIn[3] ^ crcIn[7] ^ crcIn[8] ^ crcIn[11] ^ crcIn[15] ^ crcIn[16] ^ crcIn[20] ^ crcIn[22] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[29] ^ data[3] ^ data[7] ^ data[8] ^ data[11] ^ data[15] ^ data[16] ^ data[20] ^ data[22] ^ data[24] ^ data[25] ^ data[27] ^ data[29];
  assign crcOut[20] = crcIn[4] ^ crcIn[8] ^ crcIn[9] ^ crcIn[12] ^ crcIn[16] ^ crcIn[17] ^ crcIn[21] ^ crcIn[23] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[30] ^ data[4] ^ data[8] ^ data[9] ^ data[12] ^ data[16] ^ data[17] ^ data[21] ^ data[23] ^ data[25] ^ data[26] ^ data[28] ^ data[30];
  assign crcOut[21] = crcIn[5] ^ crcIn[9] ^ crcIn[10] ^ crcIn[13] ^ crcIn[17] ^ crcIn[18] ^ crcIn[22] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[31] ^ data[5] ^ data[9] ^ data[10] ^ data[13] ^ data[17] ^ data[18] ^ data[22] ^ data[24] ^ data[26] ^ data[27] ^ data[29] ^ data[31];
  assign crcOut[22] = crcIn[0] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[16] ^ crcIn[18] ^ crcIn[19] ^ crcIn[23] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[31] ^ data[0] ^ data[9] ^ data[11] ^ data[12] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[23] ^ data[24] ^ data[26] ^ data[27] ^ data[29] ^ data[31];
  assign crcOut[23] = crcIn[0] ^ crcIn[1] ^ crcIn[6] ^ crcIn[9] ^ crcIn[13] ^ crcIn[15] ^ crcIn[16] ^ crcIn[17] ^ crcIn[19] ^ crcIn[20] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[6] ^ data[9] ^ data[13] ^ data[15] ^ data[16] ^ data[17] ^ data[19] ^ data[20] ^ data[26] ^ data[27] ^ data[29] ^ data[31];
  assign crcOut[24] = crcIn[1] ^ crcIn[2] ^ crcIn[7] ^ crcIn[10] ^ crcIn[14] ^ crcIn[16] ^ crcIn[17] ^ crcIn[18] ^ crcIn[20] ^ crcIn[21] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ data[1] ^ data[2] ^ data[7] ^ data[10] ^ data[14] ^ data[16] ^ data[17] ^ data[18] ^ data[20] ^ data[21] ^ data[27] ^ data[28] ^ data[30];
  assign crcOut[25] = crcIn[2] ^ crcIn[3] ^ crcIn[8] ^ crcIn[11] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[19] ^ crcIn[21] ^ crcIn[22] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[2] ^ data[3] ^ data[8] ^ data[11] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[28] ^ data[29] ^ data[31];
  assign crcOut[26] = crcIn[0] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[10] ^ crcIn[18] ^ crcIn[19] ^ crcIn[20] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[31] ^ data[0] ^ data[3] ^ data[4] ^ data[6] ^ data[10] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[31];
  assign crcOut[27] = crcIn[1] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[11] ^ crcIn[19] ^ crcIn[20] ^ crcIn[21] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ data[1] ^ data[4] ^ data[5] ^ data[7] ^ data[11] ^ data[19] ^ data[20] ^ data[21] ^ data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[29];
  assign crcOut[28] = crcIn[2] ^ crcIn[5] ^ crcIn[6] ^ crcIn[8] ^ crcIn[12] ^ crcIn[20] ^ crcIn[21] ^ crcIn[22] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ data[2] ^ data[5] ^ data[6] ^ data[8] ^ data[12] ^ data[20] ^ data[21] ^ data[22] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[30];
  assign crcOut[29] = crcIn[3] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[13] ^ crcIn[21] ^ crcIn[22] ^ crcIn[23] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[3] ^ data[6] ^ data[7] ^ data[9] ^ data[13] ^ data[21] ^ data[22] ^ data[23] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[31];
  assign crcOut[30] = crcIn[4] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[14] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ data[4] ^ data[7] ^ data[8] ^ data[10] ^ data[14] ^ data[22] ^ data[23] ^ data[24] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[30];
  assign crcOut[31] = crcIn[5] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[15] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31] ^ data[5] ^ data[8] ^ data[9] ^ data[11] ^ data[15] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[28] ^ data[29] ^ data[30] ^ data[31];
endmodule

//`endif  // CRC_V_
