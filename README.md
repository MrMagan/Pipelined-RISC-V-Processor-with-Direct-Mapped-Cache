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
## Hazard Detection and Data Forwarding

The processor implements a **Hazard Detection Unit** and **Data Forwarding Logic** to manage data dependencies between instructions executing in different pipeline stages. These mechanisms help maintain correct instruction execution while minimizing unnecessary pipeline stalls.

### Hazard Detection

Data hazards occur when an instruction requires a register value that a previous instruction has not yet written back to the register file.

The `HazardUnit.sv` module monitors source and destination registers across pipeline stages to identify potential dependencies.

- **Register Dependency Detection:** Compares source registers (`rs1`, `rs2`) against destination registers (`rd`) of preceding instructions.
- **Load-Use Hazard Detection:** Identifies when an instruction immediately following a load depends on the loaded data.
- **Pipeline Stalling:** Generates a `STALL` signal when a load-use dependency cannot be resolved through forwarding alone.
- **Flush Handling:** Uses the `FLUSH_COMPLETE` signal to suppress hazard-control actions during the designated flush condition.

### Data Forwarding

Data forwarding, also known as *bypassing*, allows instructions to use results from previous instructions before those results are written back to the register file.

Rather than waiting for the write-back stage, the processor forwards available data directly from later pipeline stages to the execution stage.

The forwarding system supports:

- **MEM-to-EX Forwarding:** Forwards an ALU result from the Memory stage to a dependent instruction in the Execute stage.
- **WB-to-EX Forwarding:** Forwards a result from the Write-Back stage to the Execute stage.
- **Store Data Forwarding:** Provides updated register values to store instructions when the data being stored depends on a preceding instruction.
- **Forwarding Priority:** Prioritizes the Memory-stage result over the Write-Back-stage result when both match the same source register.

### Forwarding Control Signals

The Hazard Detection Unit generates forwarding selection signals (`FWD_A_SEL`, `FWD_B_SEL`) to control the multiplexers supplying operands to the ALU.

| Signal Value | Forwarding Source |
|---|---|
| `00` | Normal ALU operand |
| `01` | Memory (MEM) stage |
| `10` | Write-Back (WB) stage |

The processor also uses `SW_FWD_SEL` to select forwarded data for store instructions.

### Load-Use Hazard Example

Consider the following RISC-V instructions:

```asm
lw  x5, 0(x10)      # Load data into x5
add x6, x5, x7     # Use the loaded value
```

The `add` instruction depends on the result of the preceding `lw` instruction. Because the loaded value is not immediately available, the Hazard Detection Unit asserts `STALL` to delay execution until the dependency can be resolved.

### Data Forwarding Example

```asm
add x5, x6, x7     # x5 = x6 + x7
sub x8, x5, x9     # x8 = x5 - x9
```

The `sub` instruction requires the result of the preceding `add` instruction. Instead of waiting for `x5` to be written back to the register file, the forwarding logic supplies the ALU result directly to the dependent instruction.

This reduces pipeline stalls and improves overall instruction throughput.

### Implementation Files

- `HazardUnit.sv` — Detects register dependencies and generates stall and forwarding control signals.
- `Fwd_Mux_A.sv` — Selects the appropriate forwarded data for ALU operand A.
- `Fwd_Mux_B.sv` — Selects the appropriate forwarded data for ALU operand B.
- `Sw_Fwd_Mux.sv` — Selects forwarded data for store instructions.

Together, these components improve pipeline efficiency by resolving common data dependencies without requiring every instruction to complete the write-back stage before dependent instructions can execute.

## RTL Schematics

The following schematics were generated using Xilinx Vivado and illustrate the processor architecture.

- [Top-Level Processor Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/schematic.svg)
- [CPU Datapath Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/CPU_Datapath.svg)
- [Cache Controller Schematic](https://raw.githubusercontent.com/MrMagan/Pipelined-RISC-V-Processor-with-Direct-Mapped-Cache/main/docs/Cache_Datapath.svg)
