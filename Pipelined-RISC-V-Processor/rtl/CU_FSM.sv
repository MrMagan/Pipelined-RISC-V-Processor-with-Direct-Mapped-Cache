`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Diego Magana
// 
// Create Date: 03/17/2024 04:53:35 PM
// Design Name: 
// Module Name: CU_FSM
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


module CU_FSM(
    input CLK,
    input RST_fsm, INTR_Trigger,
    input [6:0] opcode,
    input [2:0] funct3,
    output logic PC_WE_fsm, RF_WE_fsm, memWE2_fsm, memRDEN1, memRDEN2,
            reset_fsm, csr_WE_fsm, int_taken_fsm, mret_exec_fsm
    );
    
    typedef enum {ST_INIT, ST_FETCH, ST_EXEC, ST_WB, ST_INTRPT} state_type;
    
    state_type NS, PS;
    
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
    
    //State Register
    always_ff @(posedge CLK) begin
        if(RST_fsm == 1'b1)
            PS <= ST_INIT;
        else
            PS <= NS;
    end
    
    always_comb begin
        //initialize all outputs to 0 to prevent latch
        PC_WE_fsm = 1'b0;
        RF_WE_fsm = 1'b0;
        memWE2_fsm = 1'b0;
        memRDEN1 = 1'b0;
        memRDEN2 = 1'b0;
        reset_fsm = 1'b0;
        csr_WE_fsm = 1'b0;
        int_taken_fsm = 1'b0;
        mret_exec_fsm = 1'b0;
        
        case(PS)
            ST_INIT: begin
                reset_fsm = 1'b1;
                NS = ST_FETCH;
            end
            //fetch next instruction
            ST_FETCH: begin
                memRDEN1 = 1'b1;
                NS = ST_EXEC;
            end
            //instruction execution
            ST_EXEC: begin
                if (opcode == ITypeLoad_OPCODE) begin //go to WB if load instruction
                    NS = ST_WB;
                    memRDEN2 = 1'b1;    //read from mem then WB 
                end
                else if ((opcode != ITypeLoad_OPCODE) && (INTR_Trigger == 1'b1)) begin
                    NS = ST_INTRPT;
                end
                else begin
                    NS = ST_FETCH;
                end
                case(opcode)    //always run EXEC only thing that will change is next state
                    //Arithmetic
                    RType_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1;
                    end
                    //Arithmetic w/ Immed
                    IType_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1;
                    end
                    //jalr
                    ITypeJalr_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1;
                    end
                    //Store
                    SType_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        memWE2_fsm = 1'b1;
                    end
                    //Branch
                    BType_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                    end
                    //lui
                    UType1_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1; 
                    end
                    //auipc
                    UType2_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1; 
                    end
                    //Jal
                    JType_OPCODE: begin
                        PC_WE_fsm = 1'b1;
                        RF_WE_fsm = 1'b1;
                    end
                    //CSR
                    CSR_OPCODE: begin
                        case (funct3)
                        //CSRRW
                        3'b001: begin
                            PC_WE_fsm = 1'b1;
                            RF_WE_fsm = 1'b1;
                            csr_WE_fsm = 1'b1;
                        end
                        //CSRRC
                        3'b011: begin
                            PC_WE_fsm = 1'b1;
                            RF_WE_fsm = 1'b1;
                            csr_WE_fsm = 1'b1;
                        end
                        //CSRRS
                        3'b010: begin
                            PC_WE_fsm = 1'b1;
                            RF_WE_fsm = 1'b1;
                            csr_WE_fsm = 1'b1;
                        end
                        //MRET
                        3'b000: begin
                            PC_WE_fsm = 1'b1;                      
                            mret_exec_fsm = 1'b1;
                        end
                        default: begin end //default funct3 shouldn't get here
                        endcase
                    end
                    default: begin end//default opcode shouldn't get here
                endcase
            end //EXEC end
            //Write Back for load instructions specifically(need extra clk cycle)
            ST_WB: begin
                if (INTR_Trigger) begin
                    NS = ST_INTRPT;
                end
                else begin
                    NS = ST_FETCH;
                end
                PC_WE_fsm = 1'b1;
                RF_WE_fsm = 1'b1;
            end
            ST_INTRPT: begin
                 int_taken_fsm = 1'b1;
                 PC_WE_fsm = 1'b1;
                 NS = ST_FETCH;
            end
            default: begin //default state
                NS = ST_INIT;
            end
        endcase 
    end
endmodule
