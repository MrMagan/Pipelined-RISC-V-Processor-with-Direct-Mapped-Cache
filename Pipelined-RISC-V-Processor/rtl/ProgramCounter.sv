`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/16/2024 12:33:54 PM
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter(
    //mux connections
    input [31:0] JALR_TL, BRANCH_TL, JAL_TL, MTVEC_TL, MEPC_TL,
    input [2:0] PC_SEL_TL,
    
    //register connections
    input CLK_TL,
    input PC_WE_TL,
    input RESET_TL,
    output [31:0] PC_OUT_TL,
    output [31:0] PC_OUT_PLUS_FOUR_TL
    );
    //will connect the mux to the register
    logic [31:0] Mux_Reg_TL;
    //will connect the output of adder to the mux
    logic [31:0] PC_Four_Mux_TL;
    
    PC_MUX mux(.PC_PlusFour(PC_Four_Mux_TL), .JALR(JALR_TL), .BRANCH(BRANCH_TL), .JAL(JAL_TL),
                .MTVEC(MTVEC_TL), .MEPC(MEPC_TL), .PC_SEL(PC_SEL_TL), .OUT(Mux_Reg_TL));
                
    PC_REGISTER register(.PC_IN(Mux_Reg_TL), .CLK(CLK_TL), .PC_WE(PC_WE_TL), .RESET(RESET_TL),
                           .PC_OUT(PC_OUT_TL));
                           
    PC_ADDER add(.ADDER_IN(PC_OUT_TL), .PC_OUT_PLUS_FOUR(PC_OUT_PLUS_FOUR_TL), .PC_OUT_MUX(PC_Four_Mux_TL));
                           
               
endmodule
