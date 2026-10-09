`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 10/29/2024 03:32:13 PM
// Design Name: 
// Module Name: Fwd_Mux_A
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

module Fwd_Mux_A(
    input [31:0] ALU_MUX_A_OUT, MEM_ALU_OUT, WB_ALU_DOUT2_OUT,
    input [1:0] FWD_A_SEL,
    output logic [31:0] OUT_FWD_MUX_A
    );
    always_comb begin
        case(FWD_A_SEL)
            (2'b00):
                OUT_FWD_MUX_A = ALU_MUX_A_OUT;                
            (2'b01):
                OUT_FWD_MUX_A = MEM_ALU_OUT;
            (2'b10):
                OUT_FWD_MUX_A = WB_ALU_DOUT2_OUT;
            default: 
                OUT_FWD_MUX_A = 32'h0000_DEAD;
        endcase
    end
endmodule
