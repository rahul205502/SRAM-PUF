# SRAM Physical Unclonable Function (PUF) using SystemVerilog

An FPGA implementation of an SRAM-based Physical Unclonable Function (PUF) for lightweight hardware authentication.

The design extracts unique SRAM startup patterns, improves reliability using Majority Voting, generates helper data through XOR operations, and produces challenge-response pairs (CRPs) using an LFSR architecture. Generated responses can be transmitted over UART for external authentication and analysis.

---

## Features

- SRAM Startup Value Extraction
- Majority Voting Noise Reduction
- Helper Data Generation
- LFSR-based Challenge-Response Generation
- UART Transmission
- Modular FSM-based Architecture
- Fully Parameterized Design
- Complete Simulation Testbenches

---

## Project Architecture

```
                   Challenge
                       │
                       ▼
              +----------------+
              |    PUF_TOP      |
              +----------------+
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   SRAM_CTRL     Majority Vote     XOR Helper
        │              │              │
        └──────────────┼──────────────┘
                       ▼
                    LFSR PUF
                       │
                Response (CRP)
                       │
                    UART TX
```

---

## Folder Structure

```
.
├── LFSR.sv
├── SRAM.sv
├── SRAM_CTRL.sv
├── majority_voting.sv
├── XOR_OP.sv
├── UART.sv
├── UART_TOP.sv
├── PUF_TOP.sv
├── PUF_PARAMS.sv
│
├── Testbenches
│   ├── LFSR_TB.sv
│   ├── TB_SRAM.sv
│   ├── TB_MAJOR_VOTE.sv
│   ├── XOR_TB.sv
│   ├── PUF_TOP_TB.sv
│   └── PUF_UART_TOP_TB.sv
│
└── README.md
```

---

## Design Flow

1. Initialize SRAM
2. Read SRAM startup values
3. Perform Majority Voting
4. Generate helper data using XOR
5. Feed helper data to LFSR
6. Apply challenge
7. Generate response
8. Transmit CRPs through UART

---

## Modules

### SRAM

- Simulates SRAM startup values
- Includes temperature and voltage variation model

### SRAM_CTRL

- Controls SRAM read operations
- Coordinates data collection

### Majority_Voting

- Improves reliability
- Removes unstable SRAM bits

### XOR_OP

- Generates helper data
- Combines multiple SRAM responses

### LFSR

- Produces challenge-response pairs
- Lightweight hardware implementation

### UART

- Serial transmission of generated responses

### PUF_TOP

- Top-level controller integrating all modules

---

## Simulation

Testbenches included:

- SRAM
- Majority Voting
- XOR
- LFSR
- PUF Top
- UART Top

These verify functional correctness of the complete authentication pipeline.

---

## Applications

- Device Authentication
- Secure Key Generation
- Anti-Counterfeiting
- IoT Security
- FPGA Security
- Hardware Root of Trust
- Lightweight Cryptography

---

## Future Improvements

- BCH / Reed-Solomon Error Correction
- Fuzzy Extractor
- AES Integration
- SHA-256 Hashing
- BRAM-based CRP Database
- FPGA Hardware Validation
- Vivado Implementation
- Inter/Intra Hamming Distance Analysis

---

## Tools Used

- SystemVerilog
- Xilinx Vivado
- XSIM Simulator

---

## Author

Rahul M

B.Tech Electronics Engineering (VLSI Design and Technology)

College of Engineering, Guindy (Anna University)

---

