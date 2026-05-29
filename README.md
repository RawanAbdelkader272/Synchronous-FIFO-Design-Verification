# Synchronous FIFO Design & Verification 

![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue)
![SVA](https://img.shields.io/badge/Assertions-SVA-green)
![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-orange)

## Overview
This project presents a complete RTL design and verification flow for a configurable **Synchronous First-In-First-Out (FIFO) memory**. Implemented in SystemVerilog, the design features robust control logic, pointer management, and comprehensive status flags. The verification environment leverages **SystemVerilog Assertions (SVA)** for real-time property checking, alongside a structured testbench with a reference-model scoreboard and functional coverage to ensure exhaustive validation across all operational modes and corner cases.

## 📄 Documentation
For a comprehensive breakdown of the design architecture, bug reports, verification plan, assertion properties, and coverage results, refer to the official project documentation:
📑 **[Synchronous FIFO Design & Verification Project.pdf](./Synchronous%20FIFO%20Design%20&%20Verification%20Project.pdf)**

## Design Architecture
The synchronous FIFO operates on a single clock domain and includes:
- **Memory Backend**: Parameterized depth and width (`FIFO_DEPTH`, `FIFO_WIDTH`)
- **Control Logic**: Read/Write enables (`rd_en`, `wr_en`), synchronous active-low reset (`rst_n`)
- **Status Flags**: `full`, `empty`, `almostfull`, `almostempty`, `overflow`, `underflow`, `wr_ack`
- **Pointer & Counter Management**: Independent read/write pointers with automatic wrap-around, and a precise occupancy counter that correctly handles simultaneous read/write operations.

## Verification Methodology
A class based, assertion-driven verification approach was employed:
- **SystemVerilog Assertions (SVA)**: Embedded concurrent and sequential properties monitor reset behavior, pointer movement, flag activation, and counter bounds in real-time.
- **Reference Model Scoreboard**: A queue-based model independently tracks expected data and state, comparing against DUT outputs cycle-by-cycle.
- **Functional Coverage**: Covergroups and cross-coverage track stimulus distribution, flag combinations, and edge-case scenarios (e.g., simultaneous R/W, wrap-around, overflow/underflow).
- **Constrained-Random Stimulus**: Testbench generates randomized `wr_en`/`rd_en` patterns with weighted distributions to stress-test all FIFO states.

## Bugs Identified & Resolved
During verification, six critical design flaws were uncovered and corrected:
| # | Bug Description | Fix Applied |
|---|-----------------|-------------|
| 1 | `wr_ack` & `overflow` not properly reset/controlled | Added reset conditions & gated assertions on FIFO state |
| 2 | `underflow` declared combinational instead of sequential | Moved to clocked `always` block with synchronous reset |
| 3 | Incorrect thresholds for `full` & `almostfull` | Corrected `almostfull` trigger from `DEPTH-2` → `DEPTH-1` |
| 4 | Missing simultaneous R/W handling (`2'b11` case) | Added conditional logic to prevent counter drift on concurrent ops |
| 5 | Incomplete reset (not all internal registers cleared) | Added full reset assignments to all sequential blocks |
| 6 | Missing pointer wrap-around | Implemented modular wrap: `ptr <= (ptr == DEPTH-1) ? 0 : ptr + 1` |

