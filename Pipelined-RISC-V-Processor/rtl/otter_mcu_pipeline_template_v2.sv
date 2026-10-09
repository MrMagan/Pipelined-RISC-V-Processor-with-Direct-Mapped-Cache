`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Diego Magana
// 
// Create Date: 10/08/2024 03:00:00 PM
// Design Name: 
// Module Name: OTTER_MCU
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

typedef enum logic [6:0] {
    RType_OPCODE = 7'b0110011, //Arithmetic
    IType_OPCODE = 7'b0010011, //Arithmetic w/ Immed
    ITypeJalr_OPCODE = 7'b1100111, //jalr
    ITypeLoad_OPCODE = 7'b0000011, //Load
    SType_OPCODE = 7'b0100011, //Store
    BType_OPCODE = 7'b1100011, //Branch
    UTypeLui_OPCODE = 7'b0110111, //lui
    UTypeAuiPC_OPCODE = 7'b0010111, //auipc
    JTypeJal_OPCODE = 7'b1101111, //jal
    CSR_OPCODE = 7'b1110011 //interrupt instructions(CSR and MRET)matches matches 
 } opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    
    //PC internal Signals
    logic [31:0] pc, pc_plus_four;
    
    //Instruction signal
    logic [31:0] instr;

    //Memory internal signals
    // logic [31:0] dout1; //changing name to be more compatible with new cache
    logic [31:0] dout2;
    logic memBusy1;
    logic memBusy2;
   
    //Decoder internal signals
    logic regWrite;
    logic memWrite;
    logic memRead2;
    logic [3:0] alu_fun;
    logic [1:0] rf_wr_sel;
    
    //Reg File internal signals
    logic [31:0] rs1;
    logic [31:0] rs2;
    
    //Immediate Generator internal signals 
    logic [31:0] u_type_imm;
    logic [31:0] i_type_imm;
    logic [31:0] s_type_imm;
    logic [31:0] j_type_imm;
    logic [31:0] b_type_imm;
    
    //ALU MUX A internal signals
    logic [31:0] alu_mux_a;
    
    //ALU Mux B internal signals
    logic [31:0] alu_mux_b;
    
    //Reg File Mux internal signals 
    logic [31:0] wd;

    //For Data Hazards
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    
    //Old FSM Stuff, not sure where these go yet
    logic reset;
    logic csr_we;
    logic int_taken;
    logic mret_execute;
   
    
    //Control Status Registers internal signals
    logic [31:0] csr_RD, csr_MEPC, csr_MTVEC;
    logic CSR_MIE;
    
    // flush complete must be passed through pipeline because we need to init to 0.
    logic flush_complete;
    
  
} instr_t;

module OTTER_MCU(input CLK,
                input INTR,
                input RESET,
                input [31:0] IOBUS_IN,
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output logic IOBUS_WR 
);     
      
    //Steps to create pipeline from diagram
    //1. Signal needed before --> Make a logic signal if a future module creates a signal needed by a previous module
    //2. Signal needed later --> Pass a logic signal into the pipeline registers if a module produces a signal needed later
    //3. If a module appears multiple times, make those connections to those respective pipeline registers. 
    //      If a module is split up with dashed lines, make sure that I/O connection is in that respective stage.
    //4. If a signal is needed in the same stage, create a logic wire external from the pipeline registers
    
    //Err for New Mem module from canvas
    logic err;
    
    //Target Gen (Branch Address Generator) internal signals
    logic [31:0] jalr_gen;
    logic [31:0] jal_gen;
    logic [31:0] branch_gen;
    
    //Decoder internal signals
    logic [2:0] pcSource; 
    logic [1:0] alu_srcA;
    logic [2:0] alu_srcB; 
    
    logic flush, flushed, stall;
    logic pcWrite; 
//    memRead1; //Don't need anymore
  
//==== Pipeline Registers ===========================================
    instr_t if_PReg, dec_PReg, ex_PReg, mem_PReg, wb_PReg;
                     
//==== Instruction Fetch ===========================================

    logic [31:0] if_de_pc, if_de_pc_plus_four;

    logic [31:0] w0, w1, w2, w3, w4, w5, w6, w7;
    logic [31:0] rd;
    logic cache_hit, cache_miss, cache_update, im_cache_stall;
     
     // Need pc to automatically update on decode stage. (Don't pass through pipeline from IF to Dec)
     // Don't want to pass through pipeline because will take an extra CC.
     
    always_comb begin
        if (stall == 1'b0 && im_cache_stall == 1'b0) begin
            pcWrite = 1'b1;
//            memRead1 = 1'b1; //DO NOT MEM READ ANYMORE FOR CACHE.
        end
        // Stall means to read same pc, technically instruction still gets read twice in pipeline but second
        // time around, data gets modified to proper data.
        else if (stall == 1'b1) begin
            pcWrite = 1'b0;
//            memRead1 = 1'b0;            
        end
        else if (im_cache_stall == 1'b1) begin //Similar to a load stall, but this is specifically for a branch right before a miss.
                                                //Now branch is resolved by allowing the pc to write when we want a different pc than pc+4.
             if (flush) begin
                pcWrite = 1'b1;
            end 
            else begin
                pcWrite = 1'b0;
            end
    
        end
    end  

    always_ff @(posedge CLK) begin
        dec_PReg.flush_complete <= 1'b0; // init flush complete
        // If we have a flush we do not want to stall. im_cache_stall should be a mutually exlusive
        // check because it must take precedence regardless of if we are flushing.
        if (im_cache_stall || ( (stall) && (~flush || ~flushed)) ) begin
            if_de_pc <= if_de_pc; //reading same pc (STALLING)
            if_de_pc_plus_four <= if_de_pc_plus_four; // also want to read same pc + 4
        end
        else begin
            if_de_pc <= if_PReg.pc;
            if_de_pc_plus_four <= if_PReg.pc_plus_four;
        end
    end    
     
       
    ProgramCounter pc(
    .JALR_TL(jalr_gen),
    .BRANCH_TL(branch_gen), 
    .JAL_TL(jal_gen), 
    .MTVEC_TL(if_PReg.csr_MTVEC), 
    .MEPC_TL(if_PReg.csr_MEPC), 
    .PC_SEL_TL(pcSource), 
    .CLK_TL(CLK), 
    .PC_WE_TL(pcWrite),
    .RESET_TL(RESET),
    .PC_OUT_TL(if_PReg.pc),
    .PC_OUT_PLUS_FOUR_TL(if_PReg.pc_plus_four)
    );     
    
    
    CacheFSM cachfsm(
    //Inputs
    .hit(cache_hit), 
    .miss(cache_miss), 
    .CLK(CLK), 
    .RST(RESET), 
    
    //Outputs
    .update(cache_update), 
    .pc_stall(im_cache_stall)
    );

    imem imem(
    //Inputs
    .a(if_PReg.pc), //PC
    
    //Outputs
    .w0(w0),
    .w1(w1),
    .w2(w2),
    .w3(w3),
    .w4(w4),
    .w5(w5),
    .w6(w6),
    .w7(w7)
    );

    Cache cache(
    //Inputs
    .stall(im_cache_stall),
    .load_stall(stall),
    .PC(if_PReg.pc), //PC
    .CLK(CLK),
    .update(cache_update),
    .w0(w0),
    .w1(w1),
    .w2(w2), 
    .w3(w3),
    .w4(w4), 
    .w5(w5),
    .w6(w6), 
    .w7(w7),
    
    //Outputs
    .rd(dec_PReg.instr),
    .hit(cache_hit), 
    .miss(cache_miss)
    );
    
//==== Instruction Decode ===========================================
    
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(dec_PReg.instr[6:0]); //type casts to struct type
    assign dec_PReg.opcode=OPCODE;
    
    //Sets pc to pc from IF
    assign dec_PReg.pc = if_de_pc;
    assign dec_PReg.pc_plus_four = if_de_pc_plus_four;
    
   
    assign dec_PReg.rs1_addr = dec_PReg.instr[19:15];
    assign dec_PReg.rs2_addr = dec_PReg.instr[24:20];
    assign dec_PReg.rd_addr = dec_PReg.instr[11:7];
    
    // Used for data hazards, lets us know if the instr. we're dealing with can have one.
    assign dec_PReg.rs1_used = dec_PReg.rs1_addr != 0 
                                && dec_PReg.opcode != UTypeLui_OPCODE 
                                && dec_PReg.opcode != UTypeAuiPC_OPCODE 
                                && dec_PReg.opcode != JTypeJal_OPCODE;
    assign dec_PReg.rs2_used = dec_PReg.rs2_addr != 0 
                                && dec_PReg.opcode != UTypeLui_OPCODE 
                                && dec_PReg.opcode != UTypeAuiPC_OPCODE 
                                && dec_PReg.opcode != JTypeJal_OPCODE
                                && dec_PReg.opcode != IType_OPCODE
                                && dec_PReg.opcode != ITypeJalr_OPCODE
                                && dec_PReg.opcode != ITypeLoad_OPCODE;
                                
    assign dec_PReg.rd_used = dec_PReg.rd_addr != 0
                                && dec_PReg.opcode != SType_OPCODE
                                && dec_PReg.opcode != BType_OPCODE;
     
    //Moved branch logic (PC SEL) from dcdr to branch cond gen.
    CU_DCDR dcdr( 
    //inputs
    .opcode(dec_PReg.instr[6:0]), 
    .funct3(dec_PReg.instr[14:12]), 
    .bit30(dec_PReg.instr[30]), 
    .int_taken(dec_PReg.int_taken), //Not sure where to put
    .flush(flush), //Added for control hazard 
    
    //outputs
    .ALU_FUN(dec_PReg.alu_fun),
    .srcA_SEL(alu_srcA), 
    .srcB_SEL(alu_srcB), 
    .RF_SEL(dec_PReg.rf_wr_sel),
    
    //Added logic for these in dcdr(used to be from FSM)
    .memRDEN2(dec_PReg.memRead2), 
    .memWE(dec_PReg.memWrite),
    .RF_WE(dec_PReg.regWrite)
  
    );    
    logic [31:0] wb_wd;
    
    RegFile regfile(
    .CLK(CLK),
    //Reg from Dec Stage
    .adr1(dec_PReg.rs1_addr), 
    .adr2(dec_PReg.rs2_addr),
    .rs1(dec_PReg.rs1), 
    .rs2(dec_PReg.rs2),
    
    //Reg from WB Stage 
    .en(wb_PReg.regWrite), 
    .w_adr(wb_PReg.rd_addr),
    .w_data(wb_wd)
    );
    
    ImmediateGenerator immedgen(
    .Instruction(dec_PReg.instr[31:7]), 
    .U_Type(dec_PReg.u_type_imm), 
    .I_Type(dec_PReg.i_type_imm), 
    .S_Type(dec_PReg.s_type_imm), 
    .B_Type(dec_PReg.b_type_imm), 
    .J_Type(dec_PReg.j_type_imm)
    );
    
    // These original muxes now go before forwarding muxes
    ALU_MUX_A muxa(
    .signal_0_MuxA(dec_PReg.rs1), 
    .signal_1_MuxA(dec_PReg.u_type_imm), 
    .signal_2_MuxA(dec_PReg.rs1),
    .srcA_SEL(alu_srcA), 
    .out_MuxA(dec_PReg.alu_mux_a)
    );
                    
    ALU_MUX_B muxb(
    .signal_0_MuxB(dec_PReg.rs2), 
    .signal_1_MuxB(dec_PReg.i_type_imm), 
    .signal_2_MuxB(dec_PReg.s_type_imm), 
    .signal_3_MuxB(dec_PReg.pc), 
    .signal_4_MuxB(dec_PReg.csr_RD), 
    .srcB_SEL(alu_srcB), 
    .out_MuxB(dec_PReg.alu_mux_b)
    );                    
    
    
    always_ff@(posedge CLK) begin
        ex_PReg <= dec_PReg;
        // Set write enable to 0 and set a second signal so that the next instruction 
        // that comes through will do the same. Flushed gets set to 0 afterwards. Flush 
        // comes from branch cond gen and flushed is within this block.
        if (flush) begin
            ex_PReg.regWrite <= 1'b0;
            ex_PReg.memWrite <= 1'b0;
            ex_PReg.instr <= 32'b0;
            
            flushed <= 1'b1;
        end
        else if (flushed) begin 
            ex_PReg.regWrite <= 1'b0;
            ex_PReg.memWrite <= 1'b0;
            ex_PReg.instr <= 32'b0;
            flushed <= 1'b0;
            
            //Set high here to tell instr. after a flushed to not check for data hazards
            ex_PReg.flush_complete <= 1'b1;
        end
        
    end
     
    
	
	
//==== Execute ======================================================
//      From template might need later
//     logic [31:0] ex_mem_rs2;
//     logic ex_mem_aluRes = 0;
//     instr_t ex_mem_inst;
//     logic [31:0] opA_forwarded;
//     logic [31:0] opB_forwarded;    
    
    logic [31:0] out_fwd_mux_a, out_fwd_mux_b_ex, out_fwd_mux_b_mem; 
    logic [1:0] fwd_mux_a_sel, fwd_mux_b_sel;
    logic [31:0] sw_mux_out_ex, sw_mux_out_mem;
    logic [1:0] sw_mux_sel;
    
    // Hazard Unit deals with data hazards, but gets the flush complete signal
    // to tell whether or not to look for them.
    HazardUnit HU(
    .EX_OPCODE(ex_PReg.opcode),
    .WB_RD(wb_PReg.rd_addr), 
    .EX_RS1(ex_PReg.rs1_addr), 
    .EX_RS2(ex_PReg.rs2_addr), 
    .MEM_RD(mem_PReg.rd_addr), 
    .WB_RD_USED(wb_PReg.rd_used), 
    .EX_RS1_USED(ex_PReg.rs1_used), 
    .EX_RS2_USED(ex_PReg.rs2_used), 
    .DEC_RS1_USED(dec_PReg.rs1_used),
    .DEC_RS2_USED(dec_PReg.rs2_used),
    .MEM_RD_USED(mem_PReg.rd_used),
    .FLUSH_COMPLETE(mem_PReg.flush_complete),
    .DEC_RS1(dec_PReg.rs1_addr),
    .DEC_RS2(dec_PReg.rs2_addr),
    .EX_RD(ex_PReg.rd_addr),
    .FWD_A_SEL(fwd_mux_a_sel), 
    .FWD_B_SEL(fwd_mux_b_sel),
    .SW_FWD_SEL(sw_mux_sel),
    .STALL(stall)
    );
    
    logic [31:0] ex_alu_result, mem_alu_result, wb_alu_result;
    
    // Forward muxes will carry the proper data needed when dealing with data hazards.
    Fwd_Mux_A fwd_mux_a(
    .ALU_MUX_A_OUT(ex_PReg.alu_mux_a), 
    .MEM_ALU_OUT(mem_alu_result), 
    .WB_ALU_DOUT2_OUT(wb_wd),
    .FWD_A_SEL(fwd_mux_a_sel),
    .OUT_FWD_MUX_A(out_fwd_mux_a)
    );
    
    Fwd_Mux_B fwd_mux_b(
    .ALU_MUX_B_OUT(ex_PReg.alu_mux_b), 
    .MEM_ALU_OUT(mem_alu_result), 
    .WB_ALU_DOUT2_OUT(wb_wd),
    .FWD_B_SEL(fwd_mux_b_sel),
    .OUT_FWD_MUX_B(out_fwd_mux_b_ex)
    );
    
    // Needed to add this mux for the case where the instr. was a store word and there was a data hazard. 
    // The problem initially was that the alu src2 still needs to get an immediate, but the din 2 needs the 
    // rs2 data but the fwd mux b cannot provide both.
    Sw_Fwd_Mux sw_mux(
    .EX_RS2(ex_PReg.rs2),
    .MEM_ALU_OUT(mem_alu_result),
    .WB_ALU_OUT(wb_alu_result),
    .SW_FWD_SEL(sw_mux_sel),
    .OUT_SW_FWD_MUX(sw_mux_out_ex)
    );
   
    ArithmeticLogicUnit alu(
    .srcA(out_fwd_mux_a), 
    .srcB(out_fwd_mux_b_ex), 
    .alu_fun(ex_PReg.alu_fun),
    .alu_result(ex_alu_result)
    );
    
    //Target Gen
    BranchAddrGenerator brgen(
    .PC(ex_PReg.pc), 
    .J_Type(ex_PReg.j_type_imm), 
    .B_Type(ex_PReg.b_type_imm), 
    .I_Type(ex_PReg.i_type_imm), 
    .RS1(out_fwd_mux_a), 
    .JALR(jalr_gen),
    .BRANCH(branch_gen), 
    .JAL(jal_gen)
    );
    
    // This generates signals needed for control hazards.
    BranchCondGenerator condgen(
    .opcode(ex_PReg.instr[6:0]), //Added for control hazards
    .funct3(ex_PReg.instr[14:12]), //Added for control hazards
    //GET OUTPUT OF FORWARDED MUXES
    .IN1(out_fwd_mux_a), 
    .IN2(out_fwd_mux_b_ex), 
    .PC_SEL(pcSource), //Added to handle control hazards
    .flush(flush)
    );
     
    always_ff@(posedge CLK) begin
        mem_PReg <= ex_PReg;
        mem_alu_result <= ex_alu_result;
        out_fwd_mux_b_mem <= out_fwd_mux_b_ex;
        
        sw_mux_out_mem <= sw_mux_out_ex;
        
    end
    
//==== Memory ======================================================
    
    assign IOBUS_ADDR = mem_alu_result;
    assign IOBUS_OUT = sw_mux_out_mem;     
    logic [31:0] mem_dout2;
    
////  New Mem from canvas
    OTTER_mem_byte mem(
    .MEM_CLK(CLK),
    .IO_IN(IOBUS_IN),
    .IO_WR(IOBUS_WR),
    
    //instruction memory has been replaced with cache!
    //memory 1(instruction memory)
    // .MEM_READ1(memRead1),
    // .MEM_ADDR1(if_PReg.pc), //  New mem wants entire PC
    // .MEM_DOUT1(dec_PReg.instr),
    
    //memory 2(R/W memory)
    .MEM_ADDR2(mem_alu_result),
    .MEM_DIN2(sw_mux_out_mem), //ISSUE WITH THIS RN
    .MEM_SIZE(mem_PReg.instr[13:12]),
    .MEM_SIGN(mem_PReg.instr[14]),
    .MEM_DOUT2(mem_dout2),
    .MEM_WRITE2(mem_PReg.memWrite),
    .MEM_READ2(mem_PReg.memRead2),
    .ERR(err)
    );
    
    
    always_ff@(posedge CLK) begin
        wb_PReg <= mem_PReg;
        
        //Don't pass through structure because it has multiple concurrent drivers
        //(Unkown Data getting passed from previous pipeline might override output.)
        wb_alu_result <= mem_alu_result; 
    end 
 
 
     
//==== Write Back ==================================================
    
    
//    ControlStatusRegisters csr(
//    .RST(RESET), 
//    .csr_MRET_EXEC(wb_PReg.mret_execute), 
//    .INT_TAKEN(wb_PReg.int_taken), 
//    .csr_WE(wb_PReg.csr_we), 
//    .CLK(CLK), 
//    .ADDR(wb_PReg.instr[31:20]), 
//    .PC(wb_PReg.pc), 
//    .WD(wb_alu_result), 
//    .CSR_MIE(wb_PReg.CSR_MIE), 
//    .CSR_MEPC(wb_PReg.csr_MEPC), 
//    .CSR_MTVEC(wb_PReg.csr_MTVEC), 
//    .RD(wb_PReg.csr_RD)
//    );
                         
    RF_MUX rfmux(
    .signal_0_RFMux(wb_PReg.pc_plus_four), 
    .signal_1_RFMux(wb_PReg.csr_RD), 
    .signal_2_RFMux(mem_dout2), 
    .signal_3_RFMux(wb_alu_result),
    .RF_SEL(wb_PReg.rf_wr_sel), 
    .RF_Mux_Out(wb_wd)
    );


 
 

       
            
endmodule
