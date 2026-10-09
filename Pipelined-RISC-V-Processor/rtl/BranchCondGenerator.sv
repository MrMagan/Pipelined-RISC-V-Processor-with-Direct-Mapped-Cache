`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/06/2024 07:30:58 PM
// Design Name: 
// Module Name: Branch_Cond_Generator
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


module BranchCondGenerator(
    input [31:0] IN1, IN2,
    input [6:0] opcode, 
    input [2:0] funct3,
//    input int_taken, //Might need if we use interrupts later(look at dcdr for logic)
    output logic [2:0] PC_SEL,
    output logic flush
    );
    
    logic br_eq, br_lt, br_ltu;
    
    //opcode numbers
    const logic [6:0] RType_OPCODE = 7'b0110011; //Arithmetic
    const logic [6:0] IType_OPCODE = 7'b0010011; //Arithmetic w/ Immed
    const logic [6:0] ITypeJalr_OPCODE = 7'b1100111; //jalr
    const logic [6:0] ITypeLoad_OPCODE = 7'b0000011; //Load
    const logic [6:0] SType_OPCODE = 7'b0100011; //Store
    const logic [6:0] BType_OPCODE = 7'b1100011; //Branch
    const logic [6:0] UType1_OPCODE = 7'b0110111; //lui
    const logic [6:0] UType2_OPCODE = 7'b0010111; //auipc
    const logic [6:0] JType_OPCODE = 7'b1101111; //jal
    const logic [6:0] CSR_OPCODE = 7'b1110011; //interrupt instructions(CSR and MRET)
    always_comb begin
        if (IN1 == IN2) //equal signed or unsigned
            br_eq = 1;
        else
            br_eq = 0;
        if ($signed(IN1) < $signed(IN2)) //indicate signed because unsigned default
            br_lt = 1;                   //less than signed
        else
            br_lt = 0;
        if (IN1 < IN2) //less than unsigned
            br_ltu = 1;
        else
            br_ltu = 0;
    end
    
    //New Pipeline PC source moved logic from dcdr because we cannot use
    //dcdr in EX stage and we need to know pc source at EX stage.
    always_comb begin
        //initalize output to 0
        PC_SEL = 3'b000;
        flush = 1'b0;
        case(opcode) 
            (RType_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (IType_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (ITypeJalr_OPCODE): begin
                PC_SEL = 3'b001;
                flush = 1'b1;
            end
            (ITypeLoad_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (SType_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (BType_OPCODE): begin
                //All branches should default to 000
                //(if not branch go to next instruction)
                PC_SEL = 3'b000;
                flush = 1'b0;
       
                
                case(funct3)
                    //beq
                    (3'b000): begin
                        if (br_eq == 1'b1) begin
                            PC_SEL = 3'b010; 
                            flush = 1'b1;  
                        end                     
                    end
                    //bge
                    (3'b101): begin
                        if (br_lt == 1'b0) begin
                            PC_SEL = 3'b010;    
                            flush = 1'b1;    
                        end                
                    end
                    //bgeu
                    (3'b111): begin
                        if (br_ltu == 1'b0) begin
                            PC_SEL = 3'b010;  
                            flush = 1'b1;    
                        end                  
                    end
                    //blt
                    (3'b100): begin
                        if (br_lt == 1'b1) begin
                            PC_SEL = 3'b010; 
                            flush = 1'b1;       
                        end                
                    end
                    //bltu
                    (3'b110): begin
                        if (br_ltu == 1'b1) begin
                            PC_SEL = 3'b010;
                            flush = 1'b1;
                        end
                    end
                    //bne
                    (3'b001): begin
                        if (br_eq == 1'b0) begin
                            PC_SEL = 3'b010;
                            flush = 1'b1;
                        end
                    end
                    default: begin end //shouldn't get here
                endcase
            end
            (UType1_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (UType2_OPCODE): begin
                PC_SEL = 3'b000;
                flush = 1'b0;
            end
            (JType_OPCODE): begin
                PC_SEL = 3'b011;
                flush = 1'b1;
            end
            (CSR_OPCODE): begin 
                case(funct3) 
                    //CSRRW
                    3'b001: begin
                        PC_SEL = 3'b000;
                        flush = 1'b0;
                    end
                    //CSRRC
                    3'b011: begin
                        PC_SEL = 3'b000;
                        flush = 1'b0;
                    end
                    //CSRRS
                    3'b010: begin
                        PC_SEL = 3'b000;
                        flush = 1'b0;
                    end
                    //MRET
                    3'b000: begin                     
                        PC_SEL = 3'b101;
                        flush = 1'b1;
                    end
                    default: begin end //default funct3 shouldn't get here
                endcase
            end
            default: begin end //default opcode shouldn't get here
        endcase
    end
endmodule
