`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 11/12/2024 03:37:56 PM
// Design Name: 
// Module Name: imem
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


module imem(
    input logic [31:0] a,
    output logic [31:0] w0,
    output logic [31:0] w1,
    output logic [31:0] w2,
    output logic [31:0] w3,
    output logic [31:0] w4,
    output logic [31:0] w5,
    output logic [31:0] w6,
    output logic [31:0] w7
);
    logic [31:0] ram[0:16383];
    logic [31:0] w0_idx, w1_idx, w2_idx, w3_idx, w4_idx, w5_idx, w6_idx, w7_idx;
    initial $readmemh("otter_memory.mem", ram, 0, 16383); // initalizes memory with test_all.mem file
    
    
    // Instruction Memory is an array where each index is a Natural Number not multiples of 4. 
    // Also, when bringing mem back to the cache, we want to start at the lowest possibility for the
    // amount of bits for our Block INDEX which is 3 in this case. Therefore, 000, 001, 010, ..., 111.
    // To achieve that we can multiply the address from index 31 to 5 since that is where each grouping of 
    // 8 pc's gets incremented.
    
    //EX: First 8 pc's have a similar TAG of 0...0 and if we multiply this by 8, we can start at index 0 of ram 
    //      and work our way to the next 7 words totalling 8 words.
    //EX: Next 8 pc's have a similar TAG of 0...1 and if we multiply this by 8, we can start at index 8 of ram
    //      and work our way to the next 7 words totalling 8 words.
    
    //Therefore, if we need to bring back data to the cache somewhere in between the 8 words, we will always round down to
    //the nearest 8th word and we can ensure indexing stays conistent. 
    
    // TAG = a[31:5]
    // INDEX = a[4:2] 
    // Ignore lower 2 bits which would be the byte address but instruction memory is not byte addressable.
    always_comb begin 
        
        w0_idx = (a[31:5]*8);
        w1_idx = (a[31:5]*8)+1;
        w2_idx = (a[31:5]*8)+2;
        w3_idx = (a[31:5]*8)+3;
        w4_idx = (a[31:5]*8)+4;
        w5_idx = (a[31:5]*8)+5;
        w6_idx = (a[31:5]*8)+6;
        w7_idx = (a[31:5]*8)+7;
        
        w0 = ram[w0_idx];
        w1 = ram[w1_idx]; 
        w2 = ram[w2_idx];
        w3 = ram[w3_idx];
        w4 = ram[w4_idx];
        w5 = ram[w5_idx];
        w6 = ram[w6_idx];
        w7 = ram[w7_idx];
        
    end
    
endmodule
