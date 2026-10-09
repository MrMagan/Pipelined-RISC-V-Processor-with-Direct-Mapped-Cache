`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 11/12/2024 03:43:34 PM
// Design Name: 
// Module Name: Cache
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


module Cache(
    input [31:0] PC,input CLK,input update, input stall, input load_stall,
    input logic [31:0] w0,input logic [31:0] w1,
    input logic [31:0] w2, input logic [31:0] w3,
    input logic [31:0] w4, input logic [31:0] w5,
    input logic [31:0] w6, input logic [31:0] w7,
    output logic [31:0] rd,output logic hit, output logic miss
);

parameter NUM_BLOCKS = 16;
parameter BLOCKS_PER_SET = 4;
parameter BLOCK_SIZE = 4; // Words per block
parameter INDEX_SIZE = 2;  
parameter WORD_OFFSET_SIZE = 2;
parameter BYTE_OFFSET = 2;
parameter TAG_SIZE = 32 - INDEX_SIZE - WORD_OFFSET_SIZE - BYTE_OFFSET;

logic [31:0] data_set1[BLOCKS_PER_SET-1:0][BLOCK_SIZE-1:0]; //blocks are now seperated into sets so there are only 4 valid bits and tags per set
logic [31:0] data_set2[BLOCKS_PER_SET-1:0][BLOCK_SIZE-1:0];
logic [31:0] data_set3[BLOCKS_PER_SET-1:0][BLOCK_SIZE-1:0];
logic [31:0] data_set4[BLOCKS_PER_SET-1:0][BLOCK_SIZE-1:0];
logic [TAG_SIZE-1:0] tags_set1[BLOCKS_PER_SET-1:0];
logic [TAG_SIZE-1:0] tags_set2[BLOCKS_PER_SET-1:0];
logic [TAG_SIZE-1:0] tags_set3[BLOCKS_PER_SET-1:0];
logic [TAG_SIZE-1:0] tags_set4[BLOCKS_PER_SET-1:0];
logic valid_bits_set1[BLOCKS_PER_SET-1:0]; 
logic valid_bits_set2[BLOCKS_PER_SET-1:0];
logic valid_bits_set3[BLOCKS_PER_SET-1:0];
logic valid_bits_set4[BLOCKS_PER_SET-1:0];
logic [INDEX_SIZE-1:0] index;

logic [TAG_SIZE-1:0]cache_tag, pc_tag; 
logic [2:0] pc_offset;

initial begin
    int i;
    int j;
    for(i = 0; i < BLOCKS_PER_SET; i = i + 1) begin //initializing RAM to 0
        for(j=0; j < BLOCK_SIZE; j = j + 1)
        data_set1[i][j] = 32'b0;
        data_set2[i][j] = 32'b0;
        data_set3[i][j] = 32'b0;
        data_set4[i][j] = 32'b0;
        tags_set1[i] = 32'b0;
        tags_set2[i] = 32'b0;
        tags_set3[i] = 32'b0;
        tags_set4[i] = 32'b0;
        valid_bits_set1[i] = 1'b0;
        valid_bits_set2[i] = 1'b0;
        valid_bits_set3[i] = 1'b0;
        valid_bits_set4[i] = 1'b0;
    end
end

//set select that determines data and if there is a hit
logic sel_set1 = (validity1 && (cache_tag1 == pc_tag));
logic sel_set2 = (validity2 && (cache_tag2 == pc_tag));
logic sel_set3 = (validity3 && (cache_tag3 == pc_tag));
logic sel_set4 = (validity4 && (cache_tag4 == pc_tag));

assign index = PC[8:5];
assign validity1 = valid_bits_set1[index]; //validity of each set
assign validity2 = valid_bits_set2[index];
assign validity3 = valid_bits_set3[index];
assign validity4 = valid_bits_set4[index];
assign cache_tag1 = tags_set1[index];
assign cache_tag2 = tags_set2[index];
assign cache_tag3 = tags_set3[index];
assign cache_tag4 = tags_set4[index];
assign pc_offset = PC[4:2];
assign pc_tag = PC[31:9];

assign data_sel = sel_set1 ? 2'b00 :    //data selector
                 sel_set2 ? 2'b01 :
                 sel_set3 ? 2'b10 :
                 sel_set4 ? 2'b11 : 2'b00; // Default to set1 if no match

assign hit = sel_set1 || sel_set2|| sel_set3 || sel_set4; //check for hit in each set
assign miss = !hit;

always_ff @(posedge CLK) begin
    
    rd = 32'h00000013; //nop
    if(hit && !stall && !load_stall) //check if stall so we dont pass instr twice into pipeline.
    rd = data_sel == 2'b00 ? data_set1[index][pc_offset]:
         data_sel == 2'b01 ? data_set2[index][pc_offset]:
         data_sel == 2'b10 ? data_set3[index][pc_offset]:
         data_sel == 2'b00 ? data_set4[index][pc_offset]: 2'b00;
end

always_ff @(negedge CLK) begin
    if(update) begin
        if (data_sel == 2'b00)begin
            data_set1[index][0] <= w0;
            data_set1[index][1] <= w1;
            data_set1[index][2] <= w2;
            data_set1[index][3] <= w3;
            data_set1[index][4] <= w4;
            data_set1[index][5] <= w5;  
            data_set1[index][6] <= w6;
            data_set1[index][7] <= w7;
            valid_bits_set1[index] <= 1'b1;
            tags_set1[index] <= pc_tag; //Update tag as well.
        end
        else if  (data_sel == 2'b01)begin
            data_set2[index][0] <= w0;
            data_set2[index][1] <= w1;
            data_set2[index][2] <= w2;
            data_set2[index][3] <= w3;
            data_set2[index][4] <= w4;
            data_set2[index][5] <= w5;
            data_set2[index][6] <= w6;
            data_set2[index][7] <= w7;
            valid_bits_set2[index] <= 1'b1;
            tags_set2[index] <= pc_tag; //Update tag as well.
        end
        else if  (data_sel == 2'b10)begin
            data_set3[index][0] <= w0;
            data_set3[index][1] <= w1;
            data_set3[index][2] <= w2;
            data_set3[index][3] <= w3;
            data_set3[index][4] <= w4;
            data_set3[index][5] <= w5;
            data_set3[index][6] <= w6;
            data_set3[index][7] <= w7;
            valid_bits_set3[index] <= 1'b1;
            tags_set3[index] <= pc_tag; //Update tag as well.
        end
        else if  (data_sel == 2'b11)begin
            data_set4[index][0] <= w0;
            data_set4[index][1] <= w1;
            data_set4[index][2] <= w2;
            data_set4[index][3] <= w3;
            data_set4[index][4] <= w4;
            data_set4[index][5] <= w5;
            data_set4[index][6] <= w6;
            data_set4[index][7] <= w7;
            valid_bits_set4[index] <= 1'b1;
            tags_set4[index] <= pc_tag; //Update tag as well.
        end
    end
end



endmodule
