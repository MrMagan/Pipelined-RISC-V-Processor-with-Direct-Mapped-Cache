`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/25/2024 10:43:36 PM
// Design Name: 
// Module Name: ArithmeticLogicUnit
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


module ArithmeticLogicUnit(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output logic [31:0] alu_result
    );
    
    always_comb begin
        case (alu_fun) 
            //add and sub do not need to be indicated as signed
            //just including for consistency with assembler manual
            4'b0000: alu_result = $signed(srcA) + $signed(srcB); //add
            4'b1000: alu_result = $signed(srcA) - $signed(srcB); //sub
            4'b0110: alu_result = srcA | srcB; //OR
            4'b0111: alu_result = srcA & srcB; //AND
            4'b0100: alu_result = srcA ^ srcB; //XOR
            4'b0101: alu_result = srcA >> srcB[4:0]; //Logical Shift Right lower 5 bits srcB
            
            4'b0001: alu_result = srcA << srcB[4:0]; //Logical Shift Left Lower 5 bits srcB
            4'b1101: alu_result = $signed(srcA) >>> $signed(srcB[4:0]); //Arithmetic Shift Right Lower 5 bits srcB
            4'b0010: begin //Set if Less Than (signed)
                if ($signed(srcA) < $signed(srcB)) alu_result = 1;
                else alu_result = 0;
            end
            4'b0011: begin //Set if Less Than Unsigned
                if (srcA < srcB) alu_result = 1;
                else alu_result = 0;
            end            
            4'b1001: alu_result = srcA; //LUI-COPY copy over srcA
            default: alu_result = 32'h0000_DEAD;
        endcase
    end
    
endmodule
