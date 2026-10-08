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

## Verilog File Structure

