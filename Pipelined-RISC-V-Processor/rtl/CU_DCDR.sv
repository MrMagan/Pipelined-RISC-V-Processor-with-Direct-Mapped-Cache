`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 04/18/2024 01:48:21 PM
// Design Name: 
// Module Name: CU_DCDR
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


module CU_DCDR(
    input [6:0] opcode,
    input [2:0] funct3,
    input bit30, flush,
    input int_taken, 
//    input br_eq, br_lt, br_ltu, //don't need bc of control hazard
    output logic memRDEN2, memWE, RF_WE, //Add logic for pipeline
    output logic [3:0] ALU_FUN,
    output logic [1:0] srcA_SEL,
    output logic [2:0] srcB_SEL, 
//    output logic [2:0] PC_SEL,
    output logic [1:0] RF_SEL
    );
    
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
        //initalize all outputs to 0
        ALU_FUN = 4'b0000;
        srcA_SEL = 2'b00;
        srcB_SEL = 3'b000;
//        PC_SEL = 3'b000;
        RF_SEL = 2'b00;
        
        //Pipeline
        memRDEN2 = 1'b0;
        memWE = 1'b0;
        RF_WE = 1'b0;
        
        // If we use interrupts this may be an issue later
        //always check in case we go to interrupt state
        if (int_taken == 1'b1) begin
//            PC_SEL = 3'b100;
        end
        //don't want previous instruction to overwrite PC_SEL
        else begin 
            case(opcode)
                //Arithmetic
                (RType_OPCODE): begin
                    //All share same srcA, srcB, PC_SEL, and RF_SEL
                    srcA_SEL = 2'b00;
                    srcB_SEL = 3'b000;
//                    PC_SEL = 3'b000;
                    RF_SEL = 2'b11;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                    
                    case(funct3)
                        //add-sub
                        (3'b000): begin
                            if (bit30 == 1'b0) begin //bit30 0 for add
                                ALU_FUN = 4'b0000;
                            end
                            else begin //bit30 1 for sub
                                ALU_FUN = 4'b1000;
                            end
                        end
                        //and
                        (3'b111): begin
                            ALU_FUN = 4'b0111;
                        end
                        //or
                        (3'b110): begin
                            ALU_FUN = 4'b0110;
                        end
                        //sll
                        (3'b001): begin
                            ALU_FUN = 4'b0001;
                        end
                        //slt
                        (3'b010): begin
                            ALU_FUN = 4'b0010;
                        end
                        //sltu
                        (3'b011): begin
                            ALU_FUN = 4'b0011;
                        end
                        //sra-srl
                        (3'b101): begin
                            if (bit30 == 1'b0) begin //bit30 0 for srl
                                ALU_FUN = 4'b0101;
                            end
                            else begin //bit30 1 for sra
                                ALU_FUN = 4'b1101;
                            end
                        end
                        //xor
                        (3'b100): begin
                            ALU_FUN = 4'b0100;
                        end
                        default: begin end //shouldn't get here
                    endcase
                end
                ////////////////////////////////
                //Arithmetic w/ Immed
                (IType_OPCODE): begin
                    //All share same srcA, srcB, PC_SEL, and RF_SEL
                    srcA_SEL = 2'b00;
                    srcB_SEL = 3'b001;
//                    PC_SEL = 3'b000;
                    RF_SEL = 2'b11;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                    
                    case(funct3)
                        //addi
                        (3'b000): begin
                            ALU_FUN = 4'b0000;
                        end
                        //andi
                        (3'b111): begin
                            ALU_FUN = 4'b0111;
                        end
                        //ori
                        (3'b110): begin
                            ALU_FUN = 4'b0110;
                        end
                        //slli
                        (3'b001): begin
                            ALU_FUN = 4'b0001;
                        end
                        //slti
                        (3'b010): begin
                            ALU_FUN = 4'b0010;
                        end
                        //sltiu
                        (3'b011): begin
                            ALU_FUN = 4'b0011;
                        end
                        //srai-srli
                        (3'b101): begin
                            if (bit30 == 1'b0) begin //bit30 0 for srli
                                ALU_FUN = 4'b0101;
                            end
                            else begin //bit30 1 for srai
                                ALU_FUN = 4'b1101;
                            end
                        end
                        //xori
                        (3'b100): begin
                            ALU_FUN = 4'b0100;
                        end
                        default: begin end //shouldn't get here
                    endcase
                end
                ////////////////////////////////
                //jalr
                (ITypeJalr_OPCODE): begin
//                    PC_SEL = 3'b001;
                    RF_SEL = 2'b00;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                end
                ////////////////////////////////
                //Load
                //Share all same outputs. Only vars are size and
                //sign which are determined elsewhere.
                //Therefore don't need case statements
                (ITypeLoad_OPCODE): begin
                    ALU_FUN = 4'b0000;
                    srcA_SEL = 2'b00;
                    srcB_SEL = 3'b001;
//                    PC_SEL = 3'b000;
                    RF_SEL = 2'b10;
                    
                    //Pipeline
                    //How is load instruction going to work
                    //if we're reading and writing at the same time?
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                    memRDEN2 = 1'b1;
                end
                ////////////////////////////////
                //Store
                (SType_OPCODE): begin
                    //All share same ALU_FUN, srcA, srcB, and PC_SEL
                    //Only thing that changes is size, determined by ir[13:12] in Mem.
                    //Therefore don't need case statement.
                    ALU_FUN = 4'b0000;
                    srcA_SEL = 2'b00;
                    srcB_SEL = 3'b010;
//                    PC_SEL = 3'b000;
                    
                    //Pipeline
                    //Make sure we don't have to flush before we set WE
                    if (flush == 1'b0) begin
                        memWE = 1'b1;
                    end
                end
                ////////////////////////////////
                //Branch
                (BType_OPCODE): begin
//                    //All branches should default to 000
//                    //(if not branch go to next instruction)
//                    PC_SEL = 3'b000;
                    
//                    case(funct3)
//                        //beq
//                        (3'b000): begin
//                            if (br_eq == 1'b1)
//                                PC_SEL = 3'b010;                        
//                        end
//                        //bge
//                        (3'b101): begin
//                            if (br_lt == 1'b0)
//                                PC_SEL = 3'b010;                        
//                        end
//                        //bgeu
//                        (3'b111): begin
//                            if (br_ltu == 1'b0)
//                                PC_SEL = 3'b010;                        
//                        end
//                        //blt
//                        (3'b100): begin
//                            if (br_lt == 1'b1)
//                                PC_SEL = 3'b010;                        
//                        end
//                        //bltu
//                        (3'b110): begin
//                            if (br_ltu == 1'b1)
//                                PC_SEL = 3'b010;
//                        end
//                        //bne
//                        (3'b001): begin
//                            if (br_eq == 1'b0)
//                                PC_SEL = 3'b010;
//                        end
//                        default: begin end //shouldn't get here
//                    endcase
                end
                ////////////////////////////////
                //lui
                (UType1_OPCODE): begin
                    ALU_FUN = 4'b1001;
                    srcA_SEL = 2'b01;
//                    PC_SEL = 3'b000;
                    RF_SEL = 2'b11;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                end
                ////////////////////////////////
                //auipc
                (UType2_OPCODE): begin
                    ALU_FUN = 4'b0000;
                    srcA_SEL = 2'b01;
                    srcB_SEL = 3'b011;
//                    PC_SEL = 3'b000;
                    RF_SEL = 2'b11;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                end
                ////////////////////////////////
                //jal
                (JType_OPCODE): begin
//                    PC_SEL = 3'b011;
                    RF_SEL = 2'b00;
                    
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                end
                (CSR_OPCODE): begin 
                
                    //Pipeline 
                    if (flush == 1'b0) begin
                        RF_WE = 1'b1;
                    end
                    case(funct3) 
                        //CSRRW
                        3'b001: begin
                            ALU_FUN = 4'b1001;
                            srcA_SEL = 2'b00;
//                            PC_SEL = 3'b000;
                            RF_SEL = 2'b01;
                        end
                        //CSRRC
                        3'b011: begin
                            ALU_FUN = 4'b0111;
                            srcA_SEL = 2'b10;
                            srcB_SEL = 3'b100;
//                            PC_SEL = 3'b000;
                            RF_SEL = 2'b01;
                        end
                        //CSRRS
                        3'b010: begin
                            ALU_FUN = 4'b0110;
                            srcA_SEL = 2'b00;
                            srcB_SEL = 3'b100;
//                            PC_SEL = 3'b000;
                            RF_SEL = 2'b01;
                        end
                        //MRET
                        3'b000: begin                     
//                            PC_SEL = 3'b101;
                        end
                        default: begin end //default funct3 shouldn't get here
                    endcase
                end
                default: begin end //default opcode shouldn't get here
            endcase
        end// end of else statement(when we are not intrpt state)
    end
    
    
endmodule
