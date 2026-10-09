`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/23/2024 10:00:05 PM
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input en,
    input [4:0] adr1,
    input [4:0] adr2,
    input [4:0] w_adr,
    input [31:0] w_data,
    input CLK,
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    logic [31:0] registers [0:31]; //32, 32-bit registers
    
    initial 
        begin
            registers[0] = 0; //0 reg functionality
        end
        
    always_comb //2 registers are always being read
        begin
            rs1 = registers[adr1];
            rs2 = registers[adr2];
        end
        
    //negedge when dealing with data hazards
    always_ff @(negedge CLK) //only 1 register can be written to
        begin                //cannot override 0 reg
            if (en && (w_adr == 5'b0)) 
                registers[w_adr] <= 32'b0;
            else if (en)
                registers[w_adr] <= w_data;
        end
    
    
endmodule
