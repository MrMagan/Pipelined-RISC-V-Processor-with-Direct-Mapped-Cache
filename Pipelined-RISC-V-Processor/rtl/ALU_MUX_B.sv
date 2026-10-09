`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/18/2024 06:01:59 PM
// Design Name: 
// Module Name: ALU_MUX_B
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


module ALU_MUX_B(
    input [31:0] signal_0_MuxB, signal_1_MuxB, signal_2_MuxB, 
                    signal_3_MuxB, signal_4_MuxB,
    input [2:0] srcB_SEL,
    output logic [31:0] out_MuxB
    );
    always_comb begin
        case(srcB_SEL)
            (3'b000):
                out_MuxB = signal_0_MuxB;
            (3'b001):
                out_MuxB = signal_1_MuxB;
            (3'b010):
                out_MuxB = signal_2_MuxB;
            (3'b011):
                out_MuxB = signal_3_MuxB;
            (3'b100):
                out_MuxB = signal_4_MuxB;
             default:
                out_MuxB = 32'h0000_DEAD;
        endcase
    end
endmodule
