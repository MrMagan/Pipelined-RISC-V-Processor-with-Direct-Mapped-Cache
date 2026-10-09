`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 10/03/2024 02:18:32 PM
// Design Name: 
// Module Name: OTTER_MCU_MM_Test
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


module OTTER_MCU_MM_Test(

    );
//    logic [31:0] IO_BUS_IN_tb;
//    logic RST_tb, INTR_tb, CLK_tb;
//    logic [31:0] IOBUS_OUT_tb, IOBUS_ADDR_tb;
//    logic IOBUS_WR_tb;
    
//    OTTER_MCU mcu(.IOBUS_IN_OTTER(IO_BUS_IN_tb), .RST_OTTER(RST_tb), .INTR_OTTER(INTR_tb),
//                    .CLK_OTTER(CLK_tb), .IOBUS_OUT_OTTER(IOBUS_OUT_tb), .IOBUS_ADDR_OTTER(IOBUS_ADDR_tb),
//                    .IOBUS_WR_OTTER(IOBUS_WR_tb));
                    
//    always begin
//    #5
//    CLK_tb = 0;
//    #5
//    CLK_tb = 1;
//    end
                    
//    initial begin
//    #10
//    RST_tb = 1;
//    #10
//    RST_tb = 0;
    
//    #1_000_000_000_000;
    
//    end   
    
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
    IO_BUS_IN_tb = 32'haaaa_aaa2;
    end  
endmodule
