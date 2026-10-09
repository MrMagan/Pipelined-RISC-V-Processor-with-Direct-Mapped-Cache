`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 10/13/2024 06:52:28 PM
// Design Name: 
// Module Name: pipline_test
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


module pipline_test(

    );
    
    logic [31:0] IO_BUS_IN_tb;
    logic RST_tb, INTR_tb, CLK_tb;
    logic [31:0] IOBUS_OUT_tb, IOBUS_ADDR_tb;
    logic IOBUS_WR_tb;
    
    OTTER_MCU mcu(.IOBUS_IN(IO_BUS_IN_tb), .RESET(RST_tb), .INTR(INTR_tb),
                    .CLK(CLK_tb), .IOBUS_OUT(IOBUS_OUT_tb), .IOBUS_ADDR(IOBUS_ADDR_tb),
                    .IOBUS_WR(IOBUS_WR_tb));
                    
    always begin
    #5
    CLK_tb = 0;
    #5
    CLK_tb = 1;
    end
                    
    initial begin
    #10
    RST_tb = 1;
    #10
    RST_tb = 0;
    
    end  
endmodule
