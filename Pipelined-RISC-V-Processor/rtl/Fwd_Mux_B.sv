`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 10/29/2024 03:32:13 PM
// Design Name: 
// Module Name: Fwd_Mux_B
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

module Fwd_Mux_B(
    input [31:0] ALU_MUX_B_OUT, MEM_ALU_OUT, WB_ALU_DOUT2_OUT,
    input [1:0] FWD_B_SEL,
    output logic [31:0] OUT_FWD_MUX_B
    );
    always_comb begin
        case(FWD_B_SEL)
            (2'b00):
                OUT_FWD_MUX_B = ALU_MUX_B_OUT;                
            (2'b01):
                OUT_FWD_MUX_B = MEM_ALU_OUT;
            (2'b10):
                OUT_FWD_MUX_B = WB_ALU_DOUT2_OUT;
            default: 
                OUT_FWD_MUX_B = 32'h0000_DEAD;
        endcase
    end
endmodule
