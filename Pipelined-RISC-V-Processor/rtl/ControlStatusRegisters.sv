`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/03/2024 12:35:21 PM
// Design Name: 
// Module Name: ControlStatusRegisters
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


module ControlStatusRegisters(
    input RST, csr_MRET_EXEC, INT_TAKEN, csr_WE, CLK,
    input [31:20] ADDR,
    input [31:0] PC, WD,
    output logic CSR_MIE, //MSTATUS[3]
    output logic [31:0] CSR_MEPC, CSR_MTVEC, RD
    );
    logic [31:0] csr [0:2]; //3 Registers(Risc-V supports 4096)
    //[0] MTVEC usually 0x305
    //[1] MEPC usually 0x341
    //[2] MSTATUS usually 0x300
    
    always_comb begin
        CSR_MEPC = csr[1];
        CSR_MTVEC = csr[0];
        CSR_MIE = csr[2][3];
        case(ADDR)
            12'h305:
                RD = csr[0];
            12'h341:
                RD = csr[1];
            12'h300:
                RD = csr[2];
            default:
            begin
                RD = 32'h0000_DEAD;
            end
        endcase
    end
    
    always_ff @(posedge CLK) begin
        if (RST) begin
            csr[0] <= 32'b0;
            csr[1] <= 32'b0;
            csr[2] <= 32'b0;
        end
        else begin
            if (INT_TAKEN) begin
                csr[2][7] <= csr[2][3]; //copy over MIE to MPIE
                csr[2][3] <= 1'b0;      //clear 7th bit
                csr[1] <= PC;           //copy PC to MEPC
            end 
            else if (csr_MRET_EXEC) begin
                csr[2][3] <= csr[2][7]; //copy over MPIE to MIE
                csr[2][7] <= 1'b0;      //clear 7th bit
            end
            else if (csr_WE == 1'b1) begin 
                case(ADDR)
                    12'h305:
                        csr[0] <= WD;
                    12'h341:
                        csr[1] <= WD;
                    12'h300:
                        csr[2] <= WD;
                    default:
                    begin end
                endcase
            end
        end
    end
endmodule
