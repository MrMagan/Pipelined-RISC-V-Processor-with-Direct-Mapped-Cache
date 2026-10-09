`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/25/2024 10:43:36 PM
// Design Name: 
// Module Name: ImmediateGenerator
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


module ImmediateGenerator(
    input [31:7] Instruction,
    output logic [31:0] U_Type,
    output logic [31:0] I_Type,
    output logic [31:0] S_Type,
    output logic [31:0] B_Type,
    output logic [31:0] J_Type
    );
    
    always_comb begin
        U_Type = {Instruction[31:12], {12{1'b0}}}; // 20 bits Instruction + 12 Bits pad 0
        I_Type = {{21{Instruction[31]}}, Instruction[30:20]};
        S_Type = {{21{Instruction[31]}}, Instruction[30:25], Instruction[11:7]};
        B_Type = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
        J_Type = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
    end
endmodule
