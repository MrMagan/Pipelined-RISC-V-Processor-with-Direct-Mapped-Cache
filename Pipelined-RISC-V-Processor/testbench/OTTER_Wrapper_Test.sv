`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/25/2024 10:08:03 PM
// Design Name: 
// Module Name: OTTER_Wrapper_Test
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


module OTTER_Wrapper_Test(

    );
    logic CLK, BTNC; 
    logic [15:0] SWITCHES, LEDS;
    logic [7:0] CATHODES;
    logic [3:0] ANODES;
    
    OTTER_Wrapper wrapper(.CLK(CLK), .SWITCHES(SWITCHES), .LEDS(LEDS),
                            .CATHODES(CATHODES), .ANODES(ANODES));
    
    always begin
    #5
    CLK = 0;
    #5
    CLK = 1;
    end
    
    initial begin
    end
endmodule
