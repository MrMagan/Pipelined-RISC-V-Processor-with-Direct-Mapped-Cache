`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/18/2024 06:01:45 PM
// Design Name: 
// Module Name: ALU_MUX_A
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


module ALU_MUX_A(
    input [31:0] signal_0_MuxA, signal_1_MuxA, signal_2_MuxA,
    input [1:0] srcA_SEL,
    output logic [31:0] out_MuxA
    );
    always_comb begin
        case(srcA_SEL)
            (2'b00):
                out_MuxA = signal_0_MuxA;                
            (2'b01):
                out_MuxA = signal_1_MuxA;
            (2'b10):
                out_MuxA = ~(signal_2_MuxA);
            default: 
                out_MuxA = 32'h0000_DEAD;
        endcase
    end
endmodule
