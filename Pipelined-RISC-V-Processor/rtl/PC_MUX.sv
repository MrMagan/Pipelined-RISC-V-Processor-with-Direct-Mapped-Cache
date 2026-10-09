`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/16/2024 12:33:24 PM
// Design Name: 
// Module Name: PC_Mux
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


module PC_MUX(
    input [31:0] PC_PlusFour,
    input [31:0] JALR, BRANCH, JAL, MTVEC, MEPC,
    input [2:0] PC_SEL,
    output logic [31:0] OUT
    );
    
    always_comb
        begin
            if (PC_SEL == 3'b000) OUT = PC_PlusFour;
            else if (PC_SEL == 3'b001) OUT = JALR;
            else if (PC_SEL == 3'b001) OUT = JALR;
            else if (PC_SEL == 3'b010) OUT = BRANCH;
            else if (PC_SEL == 3'b011) OUT = JAL;
            else if (PC_SEL == 3'b100) OUT = MTVEC;
            else if (PC_SEL == 3'b101) OUT = MEPC;
            else OUT = PC_PlusFour;
        end
endmodule
    

