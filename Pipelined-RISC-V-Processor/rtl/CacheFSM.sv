`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 11/12/2024 03:39:41 PM
// Design Name: 
// Module Name: CacheFSM
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


module CacheFSM(input hit, input miss, input CLK, input RST, output logic update, output logic pc_stall);
//TODO: stall in the top level, when the pc_stall is high.
typedef enum{
    ST_READ_CACHE,
    ST_READ_MEM
} state_type;

state_type PS, NS;
always_ff @(posedge CLK) begin
    if(RST == 1)
        PS <= ST_READ_MEM;
    else
        PS <= NS;
end

always_comb begin
    update = 1'b0;
    pc_stall = 1'b1;
    if (!RST) begin
        update = 1'b1;
        pc_stall = 1'b0;
        case (PS)
            (ST_READ_CACHE): begin
                update = 1'b0;
                if(hit) begin
                    NS = ST_READ_CACHE;
                end
                else if(miss) begin
                    pc_stall = 1'b1;
                    NS = ST_READ_MEM;
                end
                else NS = ST_READ_CACHE;
            end
            (ST_READ_MEM): begin
                pc_stall = 1'b1; 
                NS = ST_READ_CACHE;
            end
            default: NS = ST_READ_CACHE;
        endcase
    end
end

endmodule
