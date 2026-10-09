`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/18/2024 11:44:31 AM
// Design Name: 
// Module Name: Adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC_ADDER(
    input logic [31:0] ADDER_IN,
    output logic [31:0] PC_OUT_MUX,
    output logic [31:0] PC_OUT_PLUS_FOUR
    );
    assign PC_OUT_MUX = ADDER_IN + 32'h0000_0004;
    assign PC_OUT_PLUS_FOUR = ADDER_IN + 32'h0000_0004;
    
endmodule
