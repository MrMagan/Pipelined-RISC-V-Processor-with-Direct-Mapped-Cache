`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 10/29/2024 03:54:26 PM
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input [6:0] EX_OPCODE,
    input [4:0] WB_RD, EX_RS1, EX_RS2, MEM_RD, DEC_RS1, DEC_RS2, EX_RD,
    input WB_RD_USED, EX_RS1_USED, EX_RS2_USED, DEC_RS1_USED, DEC_RS2_USED, MEM_RD_USED, FLUSH_COMPLETE,
    output logic [1:0] FWD_A_SEL, FWD_B_SEL, SW_FWD_SEL,
    output logic STALL
    );
    
    const logic [6:0] ITypeLoad_OPCODE = 7'b0000011; //Load
    const logic [6:0] SType_OPCODE = 7'b0100011; //Store

    always_comb begin
        
        //Init outputs
        FWD_A_SEL = 2'b00;
        FWD_B_SEL = 2'b00;
        STALL = 1'b0;
        SW_FWD_SEL = 2'b00;
        
        // FLUSH COMPLETE for case where there is a data hazard right after a flush either 1 instr. above or 2. We
        // do not want to forward / change selects in this case.
        if (!FLUSH_COMPLETE) begin
            // Detecting need for stalling. If LW 1 instr. above. (read same pc)
            //Add rd used and rs1 and rs2 used!!
            if (EX_OPCODE == ITypeLoad_OPCODE && ((DEC_RS1_USED && DEC_RS1 == EX_RD) || (DEC_RS2_USED && DEC_RS2 == EX_RD)) ) begin
                STALL = 1'b1;
            end
            
            //1 instr. above data hazard fwd data from mem for rs1
            if (EX_RS1_USED && MEM_RD_USED && EX_RS1 == MEM_RD && MEM_RD != 5'b0) begin
                FWD_A_SEL = 2'b01;
            end
            
            //2 instr. above data hazard fw data from wb for rs1
            else if (EX_RS1_USED && WB_RD_USED && EX_RS1 == WB_RD && WB_RD != 5'b0) begin
                //Don't need to check if its a load or not, data is determined by rf mux.
                FWD_A_SEL = 2'b10;
            end
            
            
            //1 instr. above data hazard fwd data from mem for rs2
            if (EX_RS2_USED && MEM_RD_USED && EX_RS2 == MEM_RD && MEM_RD != 5'b0) begin
                if (EX_OPCODE != SType_OPCODE) begin
                    FWD_B_SEL = 2'b01;
                end
                else begin
                    FWD_B_SEL = 2'b00;
                    SW_FWD_SEL = 2'b01;
                end
            end
            //2 instr. above data hazard fw data from wb for rs2
            else if (EX_RS2_USED && WB_RD_USED && EX_RS2 == WB_RD && WB_RD != 5'b0) begin
                //Don't need to check if its a load or not, data is determined by rf mux.
                if (EX_OPCODE != SType_OPCODE) begin
                    FWD_B_SEL = 2'b10;
                end
                else begin
                    FWD_B_SEL = 2'b00;
                    SW_FWD_SEL = 2'b10;
                end
                
            end
        end
    end
endmodule
