`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 11/09/2024 05:08:39 PM
// Design Name: 
// Module Name: Sw_Fwd_Mux
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


module Sw_Fwd_Mux(
    input [31:0] EX_RS2, MEM_ALU_OUT, WB_ALU_OUT,
    input [1:0] SW_FWD_SEL,
    output logic [31:0] OUT_SW_FWD_MUX
    );
    always_comb begin
        case(SW_FWD_SEL)
            (2'b00):
                OUT_SW_FWD_MUX = EX_RS2;                
            (2'b01):
                OUT_SW_FWD_MUX = MEM_ALU_OUT;
            (2'b10):
                OUT_SW_FWD_MUX = WB_ALU_OUT;
            default: 
                OUT_SW_FWD_MUX = 32'h0000_DEAD;
        endcase
    end
endmodule
