`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/16/2024 12:34:51 PM
// Design Name: 
// Module Name: PC_Register
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


module PC_REGISTER(
    input [31:0] PC_IN,
    input CLK,
    input PC_WE,
    input RESET,
    output logic [31:0] PC_OUT
    );
    
    always_ff @(posedge CLK)
        begin
            if (RESET) PC_OUT <= 32'h0000_0000;
            else if (PC_WE) PC_OUT <= PC_IN;
        end
endmodule
