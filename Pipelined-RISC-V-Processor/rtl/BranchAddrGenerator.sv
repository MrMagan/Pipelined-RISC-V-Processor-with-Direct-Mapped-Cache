`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/06/2024 07:32:28 PM
// Design Name: 
// Module Name: Branch_Addr_Generator
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


module BranchAddrGenerator(
    input [31:0] PC, J_Type, B_Type, I_Type, RS1,
    output logic [31:0] JALR, BRANCH, JAL
    );
    
    always_comb begin
        BRANCH = PC + B_Type; 
        JAL = PC + J_Type; 
        JALR = RS1 + I_Type; 
    end
endmodule
