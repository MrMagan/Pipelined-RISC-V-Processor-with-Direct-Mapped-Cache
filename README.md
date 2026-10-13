# Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache

## Project Overview

This project implements a pipelined RISC-V-based processor with an integrated cache memory system using SystemVerilog. The design is based on the OTTER MCU architecture and explores processor pipelining, memory hierarchy, and hardware control logic.

The processor incorporates instruction execution, hazard detection, data forwarding, and cache memory management to demonstrate fundamental concepts in computer architecture and digital hardware design.

The project was developed using Xilinx Vivado for RTL design, simulation, and synthesis.

## Key Features

- Pipelined Processor Architecture: Implements a pipelined datapath with dedicated control and execution modules.

- Cache Memory System: Implements cache storage with tag comparison, valid bits, and hit/miss detection.

- Cache Control FSM: Manages cache access, memory requests, and processor stalls during cache misses.

- Hazard Detection: Includes logic for identifying pipeline hazards.

- Data Forwarding: Uses forwarding multiplexers to manage data dependencies between instructions.

- Memory Integration: Incorporates instruction memory, block RAM, and memory initialization files.

- Simulation and Verification: Includes SystemVerilog testbenches for testing processor and memory functionality.

## Five-Stage Pipeline Architecture

The processor implements a five-stage RISC-V pipeline consisting
of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX),
Memory Access (MEM), and Write Back (WB).

The architecture incorporates hazard detection and data forwarding
to manage instruction dependencies and improve execution efficiency.

![Five-Stage Pipeline Architecture](docs/Processor%20Architecture.png)

#### Stage 1 - Instruction Fetch (IF)
The Program Counter (PC) identifies the next instruction. The processor fetches that instruction from instruction memory, with the cache subsystem helping supply instructions. The PC normally increments by 4 bytes.
#### Stage 2 — Instruction Decode (ID)
The control unit interprets the instruction, reads source operands from the register file, and generates immediate values and control signals.
#### Stage 3 — Execute (EX)
The Arithmetic Logic Unit (ALU) performs operations such as addition, subtraction, and comparisons. Branch calculations and operand forwarding also occur around this stage.
#### Stage 4 — Memory Access (MEM)
Load instructions read data from memory, and store instructions write data. Arithmetic instructions can pass their results through this stage.
#### Stage 5 — Write Back (WB)
The final result is written to its destination register when the instruction requires a register update.
