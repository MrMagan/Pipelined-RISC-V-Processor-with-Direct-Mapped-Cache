`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/18/2024 06:01:27 PM
// Design Name: 
// Module Name: RF_MUX
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


module RF_MUX(
    input [31:0] signal_0_RFMux, signal_1_RFMux, signal_2_RFMux, signal_3_RFMux ,
    input [1:0] RF_SEL,
    output logic[31:0] RF_Mux_Out
    );
    always_comb begin
        case(RF_SEL)
            (2'b00):
                RF_Mux_Out = signal_0_RFMux;
            (2'b01):
                RF_Mux_Out = signal_1_RFMux;
            (2'b10):
                RF_Mux_Out = signal_2_RFMux;
            (2'b11):
                RF_Mux_Out = signal_3_RFMux;
        endcase
    end
endmodule
