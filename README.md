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
## Cache Architecture

The processor incorporates an instruction cache designed to reduce memory access latency and improve instruction-fetch efficiency. The cache temporarily stores instructions retrieved from main memory, allowing the processor to access frequently used instructions without repeatedly accessing slower memory.

The cache architecture uses address indexing, tag comparisons, and valid bits to determine whether a requested instruction is currently stored.

### Cache Operation

**1. Address Decoding**

- The Program Counter (PC) provides the address of the requested instruction.
- The address is divided into tag, index, and offset fields.
- The index selects a cache location, while the tag identifies the corresponding memory region.

**2. Cache Hit**

- The cache checks the stored valid bits and compares the address tag against the stored tags.
- If a valid matching entry is found, a cache hit occurs.
- The requested instruction is retrieved from the cache and supplied to the processor pipeline.

**3. Cache Miss**

- If no valid matching tag is found, a cache miss occurs.
- The cache controller stalls instruction fetching while the requested instructions are retrieved from memory.
- The fetched instructions are written into the cache, and the corresponding tag and valid bit are updated.
- The processor can then resume instruction fetching.

### Cache Control Unit

The cache controller uses a Finite State Machine (FSM) with two primary states:

- **ST_READ_CACHE:** Checks whether the requested instruction is available in the cache.
- **ST_READ_MEM:** Handles cache misses by stalling instruction fetching and initiating a cache update.

This architecture is intended to reduce unnecessary memory accesses and improve processor throughput by supplying cached instructions to the instruction-fetch stage.

## RTL Schematics

The following schematics were generated using Xilinx Vivado and illustrate the processor architecture.

- [Top-Level Processor Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/schematic.svg)
- [CPU Datapath Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/CPU_Datapath.svg)
- [Cache Controller Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/Cache_Datapath.svg)
