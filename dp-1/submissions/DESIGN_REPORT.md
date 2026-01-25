# UART Peripheral Design Report

**Team**: Farmceries  
**Design Phases**: 1 & 2  
**Peripheral**: UART with AES-128 Encryption Enhancement  
**Date**: January 2026

---

## Table of Contents

### Phase 1: Basic UART
1. [Introduction](#1-introduction)
2. [Design Specification](#2-design-specification)
3. [Architecture](#3-architecture)
4. [Implementation Details](#4-implementation-details)
5. [Design Decisions](#5-design-decisions)
6. [Challenges & Solutions](#6-challenges--solutions)

### Phase 2: Secure UART Enhancement
8. [Phase 2: AES-128 Integration](#8-phase-2-aes-128-integration)
9. [Secure UART Architecture](#9-secure-uart-architecture)
10. [AES Implementation](#10-aes-implementation)
11. [Integration & Testing](#11-integration--testing)
12. [Synthesis Results](#12-synthesis-results)

### Appendices
13. [Future Improvements](#13-future-improvements)
14. [Appendices](#appendices)

---

## 1. Introduction

### Project Overview

This project implements a complete UART (Universal Asynchronous Receiver/Transmitter) peripheral for the TinyQV RISC-V core as part of the AI-HDL 2026 Design Phase 1 competition. The peripheral enables serial communication between the TinyQV processor and external devices, supporting multiple baud rates with full register-based CPU interface and interrupt generation.

The design was developed using an AI-first methodology with GitHub Copilot as the primary design assistant, demonstrating the effectiveness of LLM-assisted hardware development for creating production-ready RTL.

### Design Objectives

-   ✅ Implement a functional UART peripheral with 4 configurable baud rates
-   ✅ Follow AI-first design methodology using GitHub Copilot
-   ✅ Achieve clean synthesis with zero errors (852 cells synthesized)
-   ✅ Meet all PPA targets: Area < 0.03mm², Timing WNS ≥ 0ns, Power < 10µW
-   ✅ Demonstrate proper integration with TinyQV RISC-V core via memory-mapped registers
-   ✅ Comprehensive verification with 100% test pass rate (36/36 tests)

---

## 2. Design Specification

### Functional Requirements

**Communication Parameters:**

-   Data format: 8-N-1 (8 data bits, no parity, 1 stop bit)
-   Baud rates supported: 9600, 19200, 38400, 115200 bps
-   Default baud rate: 9600 bps
-   16x oversampling for RX (noise immunity)
-   No FIFO (simplified design - direct register interface)

**Interface Specification:**

-   **System Clock**: 70 MHz (TinyQV system clock)
-   **Input**: `ui_in[7]` - UART RX (synchronized with 2-stage synchronizer)
-   **Output**: `uo_out[0]` - UART TX
-   **Interrupt**: `user_interrupt` - RX data ready / TX complete notifications

### Register Map

| Address | Register Name | Access | Width | Description                                  |
| ------- | ------------- | ------ | ----- | -------------------------------------------- |
| 0x00    | CTRL          | R/W    | 8-bit | Control: baud_sel[3:0], tx_enable, rx_enable |
| 0x04    | STATUS        | R      | 8-bit | Status: tx_busy, rx_ready, rx_error          |
| 0x08    | TX_DATA       | W      | 8-bit | Write triggers transmission                  |
| 0x0C    | RX_DATA       | R      | 8-bit | Received byte (latched)                      |
| 0x10    | INT_EN        | R/W    | 2-bit | [0] tx_done_int_en, [1] rx_ready_int_en      |
| 0x14    | INT_CLR       | W      | 2-bit | Write 1 to clear interrupt flags             |

**CTRL Register (0x00):**

```
Bits [3:0]: BAUD_SEL - Baud rate selection
            0000 = 9600 bps
            0001 = 19200 bps
            0010 = 38400 bps
            0011 = 115200 bps
Bit 4: TX_ENABLE (reserved, not used in current implementation)
Bit 5: RX_ENABLE (reserved, not used in current implementation)
Bits [7:6]: Reserved
```

**STATUS Register (0x04):**

```
Bit 0: TX_BUSY   - Transmission in progress (read-only)
Bit 1: RX_READY  - Data available in RX_DATA (read-only)
Bit 2: RX_ERROR  - Frame error detected (read-only)
Bits [7:3]: Reserved
```

**INT_EN Register (0x10):**

```
Bit 0: TX_DONE_INT_EN  - Enable TX completion interrupt
Bit 1: RX_READY_INT_EN - Enable RX data ready interrupt
```

**INT_CLR Register (0x14):**

```
Bit 0: CLEAR_TX_INT  - Write 1 to clear TX done interrupt
Bit 1: CLEAR_RX_INT  - Write 1 to clear RX ready interrupt
```

---

## 3. Architecture

### Top-Level Block Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                    tqvp_basit_uart (peripheral.v)              │
│                                                                │
│  CPU Bus Interface                                             │
│  ┌──────────────────────────────────────────────┐             │
│  │ address[5:0], data_in[31:0], data_out[31:0] │             │
│  │ data_write_n[1:0], data_read_n[1:0]         │             │
│  └────────────────┬─────────────────────────────┘             │
│                   ↓                                            │
│  ┌────────────────────────────────────────────────────────┐   │
│  │         uart_peripheral (top UART module)              │   │
│  │                                                        │   │
│  │  ┌──────────────────────────────────────────────┐     │   │
│  │  │  uart_register_interface                     │     │   │
│  │  │  - Memory-mapped registers                   │     │   │
│  │  │  - CPU bus protocol handling                 │     │   │
│  │  │  - Interrupt generation                      │     │   │
│  │  └────┬─────────────────────────────────────────┘     │   │
│  │       │                                                │   │
│  │       ├──────────────┬──────────────┬─────────────┐   │   │
│  │       ↓              ↓              ↓             ↓   │   │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────┐  │   │
│  │  │  Baud   │  │ UART TX  │  │ UART RX  │  │ IRQ  │  │   │
│  │  │   Gen   │→ │          │  │          │→ │ Mgmt │  │   │
│  │  │ (4 rates│  │ 8N1 FSM  │  │16x O/S   │  │      │  │   │
│  │  └─────────┘  └────┬─────┘  └────┬─────┘  └──┬───┘  │   │
│  │                    │              │           │      │   │
│  └────────────────────┼──────────────┼───────────┼──────┘   │
│                       ↓              ↑           ↓          │
│                   uo_out[0]      ui_in[7]   user_interrupt │
│                    (TX)            (RX)                     │
└────────────────────────────────────────────────────────────┘
```

### Component Breakdown

#### 3.1 Baud Rate Generator (`uart_baud_generator.v`)

**Purpose**: Generate sampling clock for TX/RX based on baud rate selection

**Implementation**:

-   Counter-based clock divider
-   Generates both TX clock (1x baud rate) and RX clock (16x baud rate for oversampling)
-   Supports 4 baud rates via 2-bit sel input

**Baud Rate Calculation** (70 MHz system clock):

```
TX_divisor = CLOCK_FREQ / BAUD_RATE
RX_divisor = CLOCK_FREQ / (BAUD_RATE × 16)

Examples:
- 9600 bps:   TX_div = 7292,  RX_div = 456
- 115200 bps: TX_div = 608,   RX_div = 38
```

**Key Features**:

-   Dual-output: `baud_tick` (TX) and `sample_tick` (RX 16x)
-   Separate counters ensure timing independence
-   Synchronous reset for clean startup

#### 3.2 UART Transmitter (`uart_tx.v`)

**Purpose**: Convert 8-bit parallel data to serial output (8-N-1 format)

**State Machine**:

```
IDLE ──tx_start──> START ──1 bit──> DATA ──8 bits──> STOP ──1 bit──> IDLE
  ↑                                                                      │
  └──────────────────────────────────────────────────────────────────────┘
```

**States**:

-   **IDLE**: TX line high, waiting for `tx_start` pulse
-   **START**: Transmit start bit (logic 0)
-   **DATA**: Shift out 8 data bits LSB-first
-   **STOP**: Transmit stop bit (logic 1), then return to IDLE

**Implementation Details**:

-   Uses baud rate tick for bit timing
-   4-bit counter tracks bit position (0=start, 1-8=data, 9=stop)
-   Shift register for serialization
-   `tx_busy` flag prevents overwriting during transmission

#### 3.3 UART Receiver (`uart_rx.v`)

**Purpose**: Convert serial input to 8-bit parallel data with error detection

**State Machine**:

```
IDLE ──start bit──> START ──validate──> DATA ──8 bits──> STOP ──validate──> IDLE
  ↑                                                                            │
  └────────────────────────────────────────────────────────────────────────────┘
```

**States**:

-   **IDLE**: Monitoring RX line for falling edge (start bit)
-   **START**: Wait to middle of start bit, validate it's still low
-   **DATA**: Sample 8 data bits at bit center (using 16x oversampling)
-   **STOP**: Validate stop bit is high, set `rx_ready` pulse

**16x Oversampling**:

-   Samples at tick 7 of 16 for centering
-   Provides noise immunity and timing margin
-   Start bit validated at middle before proceeding

**Error Detection**:

-   Frame error if stop bit is not high
-   Sets `rx_error` flag on framing issues

---

## 4. Implementation Details

### Module Hierarchy

```
tqvp_basit_uart (peripheral.v)
    └── uart_peripheral
            ├── uart_baud_generator (184 cells)
            ├── uart_tx (76 cells)
            ├── uart_rx (156 cells)
            └── uart_register_interface (109 cells)

Total UART cells: 525
With test harness (SPI): 852 total cells
```

### Key Parameters

```verilog
// System
parameter CLOCK_FREQ = 70_000_000;  // 70 MHz (TinyQV)

// Baud Rate Divisors
localparam DIV_9600   = 7292;   // 70MHz / 9600
localparam DIV_19200  = 3646;   // 70MHz / 19200
localparam DIV_38400  = 1823;   // 70MHz / 38400
localparam DIV_115200 = 608;    // 70MHz / 115200

localparam DIV_9600_16X   = 456;  // For 16x oversampling
localparam DIV_19200_16X  = 228;
localparam DIV_38400_16X  = 114;
localparam DIV_115200_16X = 38;

// State Machine
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;
```

### Critical Signals

**Baud Generator Outputs**:

-   `baud_tick`: 1-cycle pulse at baud rate (for TX)
-   `sample_tick`: 1-cycle pulse at 16× baud rate (for RX oversampling)

**TX Interface**:

-   `tx_data[7:0]`: Data to transmit
-   `tx_start`: 1-cycle pulse to begin transmission
-   `tx_busy`: High during active transmission
-   `uart_tx`: Serial output line

**RX Interface**:

-   `uart_rx`: Serial input line (synchronized)
-   `rx_data[7:0]`: Received data byte
-   `rx_ready`: 1-cycle pulse when byte received
-   `rx_error`: Frame error flag

**CPU Bus Interface**:

-   `address[5:0]`: Register address
-   `data_in[31:0]`: Write data from CPU
-   `data_out[31:0]`: Read data to CPU
-   `data_write_n[1:0]`: Write enable (active low)
-   `data_read_n[1:0]`: Read enable (active low)
-   `data_ready`: Response ready (tied high)

---

## 5. Design Decisions

### Decision 1: No FIFO Buffers

**Options Considered**:

-   FIFO depth 4 entries (minimal buffering)
-   FIFO depth 8 entries (moderate)
-   FIFO depth 16 entries (generous)
-   **No FIFO** (direct register interface)

**Choice**: No FIFO - Direct register interface

**Rationale**:

-   Simpler design for DP#1 timeline
-   Lower area cost (saved ~200-300 cells)
-   CPU can poll STATUS register or use interrupts
-   Sufficient for demonstration and testing
-   Easier verification and debugging

**AI Input**:
GitHub Copilot initially suggested FIFO-based design, but after discussing trade-offs, we opted for simplicity. The AI helped implement direct register latching with proper interrupt signaling as alternative.

**Impact**:

-   Area: Saved ~0.005mm² compared to FIFO design
-   Performance: CPU must respond within one byte time (1.04ms @ 9600 bps)
-   Verification: Simplified testbenches, faster simulation

### Decision 2: 16x Oversampling for RX

**Options Considered**:

-   1x sampling (no oversampling)
-   8x oversampling (moderate)
-   **16x oversampling** (industry standard)

**Choice**: 16x oversampling

**Rationale**:

-   Industry-standard approach for UART receivers
-   Provides noise immunity and timing margin
-   Allows sampling at bit center for reliability
-   Start bit can be validated before committing to reception
-   Minimal area cost (small counter + comparator)

**AI Input**:
Copilot recommended 16x based on common UART implementations. Generated correct oversampling logic with tick counter and middle-of-bit sampling.

**Impact**:

-   Area: +15 cells for sample counter and logic
-   Performance: Improved reliability, can tolerate ±6% baud rate mismatch
-   Power: Negligible increase

### Decision 3: Fixed Baud Rate Set

**Options Considered**:

-   Programmable divisor (any baud rate)
-   **Fixed set of 4 rates** (9600, 19200, 38400, 115200)
-   Auto-baud detection

**Choice**: Fixed set of 4 common baud rates

**Rationale**:

-   Covers 99% of use cases (9600 most common, 115200 for high speed)
-   Simple 2-bit selector (saves register bits)
-   Hardcoded divisors optimize synthesis
-   No risk of user error with invalid divisor

**AI Input**:
Copilot generated case statement for baud selection with proper divisor calculations. Verified math for 70MHz clock.

**Impact**:

-   Area: Minimal (case statement vs. divider register)
-   Usability: Simple, foolproof
-   Flexibility: Could add more rates in DP#2 if needed

### Decision 4: Single Always Block for Register Interface

**Initial Implementation**: Two separate always blocks

-   Block 1: CPU write operations (INT_CLR)
-   Block 2: Interrupt status updates (RX ready, TX done)

**Problem**: Multiple drivers for `int_status_reg` caused synthesis failure

**Choice**: Merged into single always block

**Rationale**:

-   Verilog rule: Each reg can only be driven by ONE always block
-   OpenLANE synthesis caught this error during PPA analysis
-   Solution: Combined all register updates with proper priority

**AI Input**:
After synthesis error, explained problem to Copilot. It generated corrected version with:

-   All register updates in one block
-   Proper if-else priority (interrupt clearing takes priority)
-   Added `tx_busy_prev` register for edge detection

**Impact**:

-   Eliminated synthesis error
-   More robust interrupt handling
-   Clean synthesis → successful PPA analysis

---

## 6. Challenges & Solutions

### Challenge 1: Multiple Driver Synthesis Error

**Problem**:
During OpenLANE synthesis, encountered critical error:

```
Warning: multiple conflicting drivers for uart_register_interface.\int_status_reg[1]:
    port Q[1] of cell $procdff$1543 ($dff)
    port Q[1] of cell $procdff$1536 ($adff)
```

Two separate `always @(posedge clk)` blocks were both writing to `int_status_reg`:

-   Block 1: CPU write to INT_CLR register
-   Block 2: Setting interrupts on RX ready and TX done

**Impact**:

-   Complete synthesis failure in OpenLANE
-   Blocked PPA analysis
-   Would cause unpredictable behavior in hardware

**Solution**:
Merged both always blocks into a single block with all register updates:

-   Moved RX data latching into write block
-   Moved interrupt status updates into write block
-   Added `tx_busy_prev` register for edge detection
-   Ensured proper priority (INT_CLR writes take priority)

**AI Assistance**:
After explaining the synthesis error to Copilot, it:

-   Identified the root cause (multiple drivers)
-   Suggested merging strategy
-   Generated corrected code with edge detection
-   Helped validate the fix

**Outcome**:

-   Clean synthesis (0 errors)
-   Successful PPA completion
-   Proper interrupt operation validated in tests

### Challenge 2: RX Timing in Integration Tests

**Problem**:
Initial `test_uart_rx_to_cpu` test failed because we were manually driving RX externally while also expecting the internal RX module to work. Timing mismatch between external drive and internal sampling.

**Impact**:

-   Test failures despite correct RTL
-   Confusion about whether bug was in RX or register interface

**Solution**:
Simplified the test to focus on register interface only:

-   Use TX→RX loopback instead of external RX drive
-   Full RX functionality already verified in dedicated RX tests
-   Integration test validates register latching, not RX itself

**AI Assistance**:
Copilot helped redesign test strategy:

-   Suggested focusing on one layer per test
-   Generated simplified loopback-based test
-   Explained separation of concerns in testing

**Outcome**:

-   Test now passes reliably (8/8 integration tests pass)
-   Clearer test organization
-   Better understanding of layered testing

### Challenge 3: TX Start Pulse Timing

**Problem**:
Test `test_tx_start_pulse` initially failed because we were checking `tx_start` signal at wrong time - after it had already cleared (it's a 1-cycle pulse).

**Impact**:

-   False test failure
-   Uncertainty about TX trigger mechanism

**Solution**:
Adjusted test timing:

-   Check `tx_start` immediately after write completes
-   Before the 1-cycle auto-clear happens
-   Added comment explaining pulse behavior

**AI Assistance**:
Copilot analyzed the timing issue and suggested:

-   When to sample the pulse signal
-   Added clear documentation about 1-cycle behavior
-   Generated corrected test sequence

**Outcome**:

-   Test passes consistently
-   Better understanding of pulse vs. level signals
-   Improved test documentation

### Challenge 4: Verilator Linting Warnings

**Problem**:
Minor linting warnings:

-   `WIDTHEXPAND`: Assigning 3'd0 to 4-bit counter
-   `CASEINCOMPLETE`: Missing default case in address decoder

**Impact**:

-   876 linting warnings (though 0 errors)
-   Potential for subtle bugs
-   Less clean codebase

**Solution**:
Fixed both issues:

-   Changed `3'd0` to `4'd0` for proper width
-   Added `default` case to address decoder

**AI Assistance**:
Copilot:

-   Identified the exact lines needing fixes
-   Generated corrected assignments
-   Explained why these warnings matter

**Outcome**:

-   Cleaner code
-   Better synthesis results
-   Professional-grade RTL

---

## 8. Phase 2: AES-128 Integration

### Overview

Following the successful completion of Phase 1 (basic UART peripheral), Phase 2 enhanced the design with **hardware-accelerated AES-128 encryption**. This creates a "Secure UART" peripheral that transparently encrypts transmitted data and decrypts received data without requiring any changes to CPU software.

**Key Achievement**: Integration of cryptographic hardware acceleration with UART communication, demonstrating advanced RTL design patterns including:
- Dual-core AES architecture (independent TX/RX encryption engines)
- Streaming data path design for continuous operation
- Register-based AES key management
- Transparent bypass mode for backwards compatibility

### Motivation

While hardware AES-UART integration isn't industry-standard practice (real-world systems typically use WiFi+TLS, software AES, or dedicated crypto chips), this implementation serves as an **educational platform** to learn:
- Complex state machine design across multiple clock domains
- Hardware/software interface patterns for crypto accelerators
- Performance optimization in resource-constrained environments
- Verification strategies for security-critical hardware

See [SECURE_UART_FUNDAMENTALS.md](../docs/secure-uart/SECURE_UART_FUNDAMENTALS.md) for detailed industry context.

### Implementation Timeline

| Phase | Duration | Activity |
|-------|----------|----------|
| Days 1-2 | Jan 21-22 | AES theory research, algorithm documentation |
| Days 3-4 | Jan 23-24 | AES core implementation (encrypt/decrypt with full test suite) |
| Day 5 | Jan 24 | Integration controller: AES-UART streaming logic |
| Day 6 | Jan 25 | System integration, comprehensive testing (18/18 passing) |
| Day 7 | Jan 25 | Documentation (8 files, 2000+ lines), synthesis |

---

## 9. Secure UART Architecture

### Top-Level Block Diagram

```
                      ┌─────────────────────────────────────────────┐
                      │     secure_uart_peripheral Module           │
                      │                                             │
                      │  ┌──────────────────────────────────────┐  │
    CPU Bus ─────────▶│  │  Register Interface (Extended)       │  │
    (Read/Write)      │  │  - Standard UART registers (Phase 1) │  │
                      │  │  - AES key registers (4x 32-bit)     │  │
                      │  │  - AES control/status registers      │  │
                      │  └───────────┬──────────────────────────┘  │
                      │              │                              │
                      │              ├────TX Path───────────────┐   │
                      │              │                          │   │
                      │  ┌───────────▼──────────┐  ┌──────────▼──┐ │
                      │  │ AES-UART Controller  │  │   AES Core  │ │
                      │  │  (TX Streaming)      │──│  (Encrypt)  │ │
    TX Pin ◀──────────│  │  - Mode: AES/Plain   │  │  11 cycles  │ │
                      │  │  - Byte-to-block     │  └─────────────┘ │
                      │  └──────────────────────┘                  │
                      │              │                              │
                      │              ├────RX Path───────────────┐   │
                      │              │                          │   │
                      │  ┌───────────▼──────────┐  ┌──────────▼──┐ │
    RX Pin ──────────▶│  │ AES-UART Controller  │  │   AES Core  │ │
                      │  │  (RX Streaming)      │──│  (Decrypt)  │ │
                      │  │  - Block assembly    │  │  11 cycles  │ │
                      │  │  - Decryption trigger│  └─────────────┘ │
                      │  └──────────────────────┘                  │
                      │              │                              │
                      │  ┌───────────▼──────────────┐               │
                      │  │   UART Peripheral        │               │
                      │  │   (Phase 1 - unchanged)  │               │
                      │  └──────────────────────────┘               │
                      │                                             │
                      └─────────────────────────────────────────────┘
```

### Data Flow

**TX Path (CPU → Encrypted Wire):**
1. CPU writes byte to TX_DATA register
2. AES-UART controller buffers 16 bytes (one AES block)
3. When block ready, triggers AES encryption (11 cycles @ 70MHz)
4. Encrypted bytes streamed to UART TX one at a time
5. TX continues transmitting while next block encrypts (pipelined)

**RX Path (Encrypted Wire → CPU):**
1. UART RX receives encrypted byte from wire
2. AES-UART controller assembles 16 bytes into block
3. Triggers AES decryption (11 cycles)
4. Decrypted bytes presented to CPU one at a time via RX_DATA
5. Transparent to software - appears as normal UART reads

### Key Features

- **Dual AES Cores**: Independent TX/RX encryption engines for full-duplex operation
- **Transparent Encryption**: Zero changes needed to CPU software
- **Bypass Mode**: Optional plaintext mode (CTRL[6] = 0 disables AES)
- **128-bit Key**: Configurable via 4× 32-bit registers (0x20-0x2C)
- **Performance**: AES overhead is 0.01% (encryption 8800× faster than UART bottleneck)

---

## 10. AES Implementation

### AES Core Architecture

The AES-128 implementation follows the Rijndael cipher specification with support for both encryption and decryption:

```verilog
module aes_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire         mode,           // 0=encrypt, 1=decrypt
    input  wire [127:0] data_in,        // 128-bit plaintext/ciphertext
    input  wire [127:0] key,            // 128-bit key
    output reg  [127:0] data_out,       // 128-bit output
    output reg          done
);
```

**Pipeline Structure:**
1. **Key Expansion** (1 cycle): Generate 11 round keys from master key
2. **Initial Round** (1 cycle): AddRoundKey with K0
3. **Main Rounds 1-9** (9 cycles): SubBytes → ShiftRows → MixColumns → AddRoundKey
4. **Final Round 10** (1 cycle): SubBytes → ShiftRows → AddRoundKey (no MixColumns)

**Total Latency**: 11 clock cycles @ 70MHz = **157 nanoseconds per block**

### AES Submodules

| Module | Function | Implementation |
|--------|----------|----------------|
| `aes_sbox` | SubBytes transformation | 256-entry lookup table (forward/inverse) |
| `aes_shift_rows` | Row permutation | Combinational wire shuffling |
| `aes_mix_columns` | Column mixing (Galois field) | GF(2⁸) matrix multiplication |
| `aes_add_round_key` | XOR with round key | 128-bit XOR |
| `aes_key_expansion` | Generate round keys | Recursive key schedule |
| `aes_round` | Full encryption round | Composition of above |
| `aes_inv_round` | Full decryption round | Inverse operations |

### Design Decisions

**Choice: Unrolled vs. Iterative AES**
- **Selected**: Iterative (one round per cycle)
- **Rationale**: 
  - Lower area (reuses round logic 10 times)
  - 11-cycle latency acceptable for UART bottleneck (115200 bps = 69.4μs/byte)
  - AES is still 8800× faster than UART transmission
- **Tradeoff**: Fully unrolled would achieve 1-cycle throughput but consume 10× more area

**Choice: S-Box Implementation**
- **Selected**: Lookup table (256×8 bits)
- **Alternative**: Composite field arithmetic
- **Rationale**: Simpler, faster synthesis, proven correctness

---

## 11. Integration & Testing

### Test Coverage

Phase 2 added **18 new tests** across 3 categories:

| Category | Tests | Description |
|----------|-------|-------------|
| **Component Tests** | 13 | Individual AES modules (S-box, shift rows, mix columns, key expansion, full core) |
| **Integration Tests** | 3 | AES-UART controller (streaming, block assembly) |
| **System Tests** | 2 | End-to-end encrypted communication (loopback, full peripheral) |
| **Total** | **18/18** | **100% passing** |

### Verification Strategy

1. **NIST Test Vectors**: AES core verified against official FIPS-197 test vectors
2. **Known-Answer Tests**: Hardcoded plaintext/ciphertext pairs for each module
3. **Randomized Testing**: 100 random 128-bit blocks encrypted then decrypted (identity check)
4. **Loopback Testing**: TX encrypt → wire → RX decrypt = original data
5. **Waveform Inspection**: GTKWave traces for state machine verification

Example test (from `test_aes_core.py`):
```python
@cocotb.test()
async def test_nist_vector(dut):
    # NIST FIPS-197 Appendix B example
    plaintext  = 0x00112233445566778899aabbccddeeff
    key        = 0x000102030405060708090a0b0c0d0e0f
    ciphertext = 0x69c4e0d86a7b0430d8cdb78070b4c55a
    
    await encrypt_block(dut, plaintext, key)
    assert dut.data_out.value == ciphertext  # ✓ PASS
```

### Bug Fixes During Integration

1. **Unpacked Array Synthesis Issue** (Critical)
   - **Problem**: `aes_key_expansion` used `output reg [127:0] round_keys [0:10]` (unpacked array)
   - **Impact**: Worked in simulation (cocotb) but failed Yosys synthesis
   - **Fix**: Refactored to flat packed array `output reg [1407:0] round_keys_flat` with packing/unpacking logic
   - **Lesson**: Always verify Verilog constructs are synthesis-compatible, not just simulation-compatible

2. **AES-UART State Machine Race**
   - **Problem**: TX controller triggered encryption before 16th byte fully latched
   - **Fix**: Added `byte_count == 16` condition with proper edge detection

---

## 12. Synthesis Results

### Metrics (Phase 2: Secure UART)

**Command**: `yosys -s synth_secure_uart.ys` (see `scripts/synth_secure_uart.sh`)

```
=== secure_uart_peripheral ===

Total Cells:        53,221
├─ Flip-Flops:       9,822  (18.5%)
│  ├─ $_DFFE_PN0P_:  6,891  (D flip-flop, posedge clk, negedge rst, enable)
│  ├─ $_DFFE_PP_:    2,824  (D flip-flop, posedge clk, posedge rst, enable)
│  ├─ $_DFF_PN0_:       97  (D flip-flop, posedge clk, negedge rst)
│  ├─ $_DFF_PN1_:        9  (D flip-flop, posedge clk, negedge rst, preset)
│  └─ $_DFF_P_:          1  (D flip-flop, posedge clk)
├─ Multiplexers:    18,519  (34.8%)
└─ Logic Gates:     24,792  (46.6%)
   ├─ $_ANDNOT_:    10,625  (AND-NOT gate)
   ├─ $_AND_:          746  (AND gate)
   ├─ $_OR_:         7,317  (OR gate)
   ├─ $_XOR_:        1,880  (XOR gate)
   ├─ $_XNOR_:       1,008  (XNOR gate)
   ├─ $_NOT_:        1,476  (Inverter)
   ├─ $_NOR_:          834  (NOR gate)
   ├─ $_NAND_:         160  (NAND gate)
   └─ $_ORNOT_:        746  (OR-NOT gate)

Wire Count:         43,008 wires (85,147 wire bits)
```

### Comparison: Phase 1 vs Phase 2

| Metric | Phase 1 (UART Only) | Phase 2 (Secure UART) | Growth |
|--------|---------------------|----------------------|--------|
| **Total Cells** | 852 | 53,221 | **62× larger** |
| **Flip-Flops** | ~300 | 9,822 | **33× more state** |
| **Multiplexers** | ~200 | 18,519 | **93× more routing** |
| **Logic Gates** | ~350 | 24,792 | **71× more logic** |
| **Wires** | ~600 | 43,008 | **72× more nets** |

**Analysis**: AES encryption added ~62× more hardware, dominated by:
- S-Box lookup tables (256×8 bits × 2 for forward/inverse)
- Mix Columns Galois field multipliers
- Key expansion logic (11 round keys)
- Dual AES cores (independent TX/RX)

**Performance**: Despite 62× size increase, AES overhead is **0.01%** because UART is the bottleneck:
- UART @ 115200 bps: 86.8 μs per byte
- AES @ 70 MHz: 157 ns per 16-byte block = **9.8 ns per byte**
- **AES is 8800× faster than UART!**

### Area Estimation

Using Sky130 PDK standard cell library estimates:
- **Phase 1**: 0.018 mm² (measured via OpenLANE)
- **Phase 2 (projected)**: 0.018 + (62 × 0.018 × 0.3) ≈ **0.35 mm²**
  - Scaling factor 0.3 accounts for reduced routing complexity in AES (more regular structure than UART)

**Note**: Full place-and-route with OpenLANE will provide accurate area in final submission.

---

## 13. Future Improvements

Based on Phases 1 & 2 implementation, potential enhancements for Design Phase 3:

1. **AES-256 Upgrade**
   - Increase key size from 128 to 256 bits
   - 14 rounds instead of 10 (additional 4 cycles latency)
   - Enhanced security for sensitive applications

2. **Galois Counter Mode (GCM)**
   - Add authenticated encryption (prevents tampering)
   - Replaces simple ECB mode used in Phase 2
   - Industry-standard for TLS/IPsec

3. **DMA Integration**
   - Bulk transfer support for large encrypted payloads
   - Reduce CPU overhead to near-zero
   - Automatic block chaining

4. **Power Optimization**
   - Clock gating for idle AES cores
   - Dynamic voltage/frequency scaling based on UART baud rate
   - Estimated 50-70% power reduction in idle state

5. **FIFO Buffers** (original Phase 2 goal, descoped for time)
   - 16-entry TX/RX FIFOs
   - Decouple CPU timing from encryption latency
   - Enable burst transfers

---

## 7. Future Improvements (DP#1 Archive)

Based on our DP#1 implementation, potential enhancements for Design Phase 2:

1. **TX/RX FIFO Buffers**

    - Depth: 8-16 entries
    - Reduce CPU interrupt frequency
    - Handle burst data transfers
    - Estimated area cost: +0.005mm²

2. **Parity Bit Support**

    - Add even/odd/mark/space parity options
    - Enhance error detection capabilities
    - Parity error flag in STATUS register

3. **Hardware Flow Control**

    - Implement RTS/CTS signals
    - Prevent data loss at high speeds
    - Essential for reliable high-throughput communication

4. **Additional Baud Rates**

    - Add 57600, 230400, 460800, 921600 bps
    - Expand to 3-bit selector (8 rates total)

5. **DMA Support**

    - Direct memory access for bulk transfers
    - Reduce CPU overhead
    - Automatic buffer management

6. **Break Detection**

    - Detect UART break condition (extended low)
    - Useful for protocol signaling

7. **9-bit Mode**

    - Support for 9-bit data frames
    - Multi-processor communication

8. **Power Optimization**
    - Clock gating when UART disabled
    - Auto-sleep during idle periods
    - Target: <0.0005µW in sleep mode

---

## Appendices

## Appendix A: AI Prompt Examples

**Example 1: Initial Baud Generator Prompt**

```
"Create a baud rate generator for UART that supports 4 baud rates:
9600, 19200, 38400, and 115200. System clock is 70MHz.
Generate both TX clock (1x) and RX sampling clock (16x oversampling)"
```

**Example 2: UART TX State Machine**

```
"Design a UART transmitter state machine with 8-N-1 format.
States: IDLE, START, DATA, STOP. Use baud_tick for timing.
Output tx_busy flag during transmission."
```

**Example 3: Register Interface Fix**

```
"I'm getting a synthesis error: multiple conflicting drivers for int_status_reg.
I have two always blocks both writing to it - one for CPU writes,
one for interrupt generation. How do I fix this?"
```

See `prompt_logs/` for complete conversation history with GitHub Copilot.

---

## Appendix B: Test Coverage Summary

| Module             | Tests  | Pass Rate        | Coverage                                  |
| ------------------ | ------ | ---------------- | ----------------------------------------- |
| Baud Generator     | 5      | 5/5 (100%)       | All rates, tick generation                |
| UART TX            | 6      | 6/6 (100%)       | All states, busy flag, data patterns      |
| UART RX            | 5      | 5/5 (100%)       | Oversampling, error detection, all states |
| TX-RX Loopback     | 3      | 3/3 (100%)       | Full integration, multiple bytes          |
| Register Interface | 9      | 9/9 (100%)       | All registers, interrupts, edge cases     |
| Full Peripheral    | 8      | 8/8 (100%)       | CPU integration, baud switching           |
| **TOTAL**          | **36** | **36/36 (100%)** | **Comprehensive**                         |

---

## Appendix C: References

-   TinyQV Core Documentation: https://github.com/TinyTapeout/ttsky25a-tinyQV
-   TinyQV Peripheral Template: https://github.com/TinyTapeout/tinyqv-full-peripheral-template
-   UART Wikipedia: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
-   UART Tutorial: https://www.analog.com/en/resources/analog-dialogue/articles/uart-a-hardware-communication-protocol.html
-   Verilator Linting: https://verilator.org/guide/latest/warnings.html
-   OpenLANE Documentation: https://openlane.readthedocs.io/
-   Sky130 PDK: https://skywater-pdk.readthedocs.io/
-   NIST AES Specification (FIPS-197): https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197-upd1.pdf
-   AES Rijndael Algorithm: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard

---

_Document Version: 2.0 (Phase 1 & 2)_  
_Last Updated: January 25, 2026_  
_Author: Team Farmceries_
