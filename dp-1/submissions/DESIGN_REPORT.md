# UART Peripheral Design Report

**Team**: Farmceries  
**Design Phase**: 1  
**Peripheral**: UART (Universal Asynchronous Receiver/Transmitter)  
**Date**: January 2026

---

## Table of Contents

1. [Introduction](#introduction)
2. [Design Specification](#design-specification)
3. [Architecture](#architecture)
4. [Implementation Details](#implementation-details)
5. [Design Decisions](#design-decisions)
6. [Challenges & Solutions](#challenges--solutions)
7. [Future Improvements](#future-improvements)

---

## 1. Introduction

### Project Overview

[TO BE FILLED - Brief overview of the UART peripheral project and its role in the TinyQV system]

### Design Objectives

- Implement a functional UART peripheral for serial communication
- Follow AI-first design methodology
- Achieve clean synthesis and meet timing requirements
- Demonstrate proper integration with TinyQV RISC-V core

---

## 2. Design Specification

### Functional Requirements

**Communication Parameters:**
- Data format: 8-N-1 (8 data bits, no parity, 1 stop bit)
- Baud rates supported: 9600, 19200, 38400, 57600, 115200
- Default baud rate: 9600
- FIFO depth: 8 entries (TX and RX)

**Interface Specification:**
- **Input**: `ui_in[7]` - UART RX (synchronized)
- **Output**: `uo_out[0]` - UART TX
- **Interrupt**: `user_interrupt` - RX data ready notification

### Register Map

| Address | Register Name | Access | Width | Description |
|---------|--------------|--------|-------|-------------|
| 0x00    | TX_DATA      | W      | 8-bit | Transmit data register |
| 0x04    | RX_DATA      | R      | 8-bit | Receive data register |
| 0x08    | STATUS       | R      | 8-bit | Status register |
| 0x0C    | CONTROL      | R/W    | 32-bit| Control register |
| 0x10    | INT_CTRL     | R/W    | 8-bit | Interrupt control |

**STATUS Register (0x08):**
```
Bit 0: TX_READY   - Transmit FIFO not full
Bit 1: RX_READY   - Receive FIFO not empty
Bit 2: TX_EMPTY   - Transmit FIFO empty
Bit 3: RX_FULL    - Receive FIFO full
Bit 4: FRAME_ERR  - Frame error detected
Bit 5: RX_OVERRUN - RX FIFO overflow
Bits 6-7: Reserved
```

**CONTROL Register (0x0C):**
```
Bit 0: UART_EN      - UART enable
Bits 1-15: Reserved
Bits 16-31: BAUD_DIV - Baud rate divisor
```

---

## 3. Architecture

### Top-Level Block Diagram

![UART Architecture](media/diagrams/uart_architecture.png)

[TO BE FILLED - Describe the diagram]

### Component Breakdown

#### 3.1 Baud Rate Generator

**Purpose**: Generate sampling clock for TX/RX based on baud rate divisor

**Implementation**:
```verilog
[TO BE FILLED - Code snippet or description]
```

**Key Features**:
- Configurable via BAUD_DIV field
- Formula: `baud_clk = sys_clk / (2 * BAUD_DIV)`
- [TO BE FILLED]

#### 3.2 UART Transmitter

**Purpose**: Convert 8-bit parallel data to serial output

**State Machine**:
![TX State Machine](media/diagrams/tx_state_machine.png)

**States**:
- IDLE: Waiting for data
- START: Send start bit (0)
- DATA: Send 8 data bits (LSB first)
- STOP: Send stop bit (1)

**Implementation**:
[TO BE FILLED - Describe TX implementation]

#### 3.3 UART Receiver

**Purpose**: Convert serial input to 8-bit parallel data

**State Machine**:
![RX State Machine](media/diagrams/rx_state_machine.png)

**States**:
- IDLE: Waiting for start bit
- START: Validate start bit
- DATA: Sample 8 data bits
- STOP: Validate stop bit

**Implementation**:
[TO BE FILLED - Describe RX implementation]

#### 3.4 TX/RX FIFOs

**Purpose**: Buffer transmit and receive data

**Specifications**:
- Depth: 8 entries
- Width: 8 bits
- Type: Synchronous FIFO
- Flags: full, empty, almost_full, almost_empty

**Implementation**:
[TO BE FILLED - FIFO implementation details]

#### 3.5 Register Interface

**Purpose**: Memory-mapped I/O for CPU communication

**Implementation**:
[TO BE FILLED - Register interface logic]

---

## 4. Implementation Details

### Module Hierarchy

```
tqvp_uart (top peripheral module)
├── baud_rate_gen
├── uart_tx
│   └── tx_fifo
├── uart_rx
│   └── rx_fifo
└── reg_interface
```

### Key Parameters

```verilog
parameter CLOCK_FREQ = 50_000_000;  // 50 MHz
parameter DEFAULT_BAUD = 9600;
parameter FIFO_DEPTH = 8;
```

### Critical Signals

[TO BE FILLED - List and describe critical signals]

---

## 5. Design Decisions

### Decision 1: FIFO Depth Selection

**Options Considered**:
- 4 entries (minimal)
- 8 entries (moderate)
- 16 entries (generous)

**Choice**: 8 entries

**Rationale**:
[TO BE FILLED - Explain why 8 was chosen]

**AI Input**:
[TO BE FILLED - What AI suggested and how it influenced decision]

**Impact**:
- Area: [TO BE FILLED]
- Performance: [TO BE FILLED]

### Decision 2: Baud Rate Generation Method

[TO BE FILLED - Similar structure for other decisions]

### Decision 3: Error Handling Strategy

[TO BE FILLED]

---

## 6. Challenges & Solutions

### Challenge 1: [TO BE FILLED]

**Problem**: [Description]

**Impact**: [What issues it caused]

**Solution**: [How we solved it]

**AI Assistance**: [How AI helped find/implement solution]

**Outcome**: [Result after fix]

### Challenge 2: [TO BE FILLED]

[Similar structure for other challenges]

---

## 7. Future Improvements (DP#2 Ideas)

Based on our DP#1 implementation, potential enhancements for Design Phase 2:

1. **Clock Gating**
   - Gate UART clocks when disabled
   - Estimated power savings: [TO BE ANALYZED]

2. **Parity Bit Support**
   - Add even/odd parity option
   - Enhance error detection

3. **Hardware Flow Control**
   - Implement RTS/CTS signals
   - Prevent data loss at high speeds

4. **[TO BE FILLED]**

---

## Appendix A: AI Prompt Examples

**Example 1: Initial Architecture Prompt**
```
[TO BE FILLED - Copy actual prompt used]
```

**Example 2: FIFO Design Prompt**
```
[TO BE FILLED]
```

See `prompt_logs/` for complete conversation history.

---

## Appendix B: References

- TinyQV Core Documentation
- UART Wikipedia: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
- [TO BE FILLED - Add any other references used]

---

*Document Version: 1.0*  
*Last Updated: [TO BE FILLED]*
