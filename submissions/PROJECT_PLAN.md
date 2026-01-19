# AI-HDL DP#1 Project Plan - UART Peripheral Implementation

**Team**: Farmceries  
**Phase**: Design Phase 1 (DP#1)  
**Deadline**: January 28, 2026  
**Review**: January 29, 2026

---

## Project Overview

### Objective
Implement a **UART peripheral** for the TinyQV RISC-V CPU core to enable serial communication with external devices.

### Deliverables
1. ✅ Synthesizable UART RTL (Verilog)
2. ✅ Passing testbenches (cocotb)
3. ✅ Baseline synthesis report (Yosys)
4. ✅ Baseline PPA report (OpenLANE)
5. ✅ LLM prompt logs (all AI interactions)
6. ✅ Design documentation
7. ✅ Git tag: `DP1-Submission`

### Success Criteria
- **Functional**: UART can TX and RX at standard baud rates
- **Synthesis**: Clean synthesis with no errors
- **Timing**: Meets 70MHz (14ns) clock period
- **Area**: Fits within TinyTapeout die area constraints
- **Quality**: Well-documented with prompt logs

---

## Technical Specifications

### Target Platform
- **Framework**: Tiny Tapeout (TT)
- **CPU**: TinyQV RISC-V core (RV32I)
- **Clock**: 70 MHz
- **Die Area**: 161.00 × 111.52 µm
- **PDK**: SkyWater 130nm

### UART Requirements

#### Functional Requirements
| Feature | Specification |
|---------|---------------|
| **Baud Rates** | 9600, 19200, 38400, 57600, 115200 bps (configurable) |
| **Data Format** | 8N1 (8 data, no parity, 1 stop) - standard |
| **Direction** | Full-duplex (TX and RX simultaneously) |
| **FIFOs** | 16-byte TX FIFO, 16-byte RX FIFO (minimum) |
| **Interrupts** | RX ready, TX empty, error conditions |
| **Error Detection** | Framing errors, overrun detection |

#### Interface Requirements
- **CPU Interface**: 32-bit register-based (TinyQV peripheral bus)
- **External Interface**: 2 pins (TX, RX)
- **Interrupt**: Single interrupt line to CPU

---

## System Architecture

### High-Level Block Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TinyQV RISC-V CPU                        │
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │         Peripheral Register Interface            │     │
│  │  (address, data_in, data_out, write_n, read_n)   │     │
│  └──────────────────┬───────────────────────────────┘     │
│                     │                                       │
└─────────────────────┼───────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                    UART PERIPHERAL                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Register Interface Logic                  │   │
│  │  (Decode address, handle read/write)                │   │
│  └──────┬──────────────────────────────────────┬───────┘   │
│         │                                      │           │
│    ┌────▼─────┐  ┌─────────┐  ┌─────────┐   ┌▼──────┐    │
│    │ Baud Rate│  │ Control │  │ Status  │   │  Data │    │
│    │ Register │  │ Register│  │ Register│   │  Reg  │    │
│    │  (BRR)   │  │  (CR)   │  │  (SR)   │   │  (DR) │    │
│    └────┬─────┘  └────┬────┘  └────┬────┘   └┬──────┘    │
│         │             │            │          │           │
│    ┌────▼─────────────▼────────────▼──────────▼─────┐     │
│    │          UART Control Logic                     │     │
│    │  (Coordinate TX, RX, interrupts, status)        │     │
│    └────┬─────────────────────────────────────┬──────┘     │
│         │                                     │            │
│    ┌────▼──────┐                         ┌───▼──────┐     │
│    │ TX PATH   │                         │ RX PATH  │     │
│    │           │                         │          │     │
│    │ ┌───────┐ │                         │ ┌──────┐ │     │
│    │ │TX FIFO│ │                         │ │RX    │ │     │
│    │ │16 byte│ │                         │ │FIFO  │ │     │
│    │ └───┬───┘ │                         │ │16    │ │     │
│    │     │     │                         │ │byte  │ │     │
│    │ ┌───▼───┐ │                         │ └──▲───┘ │     │
│    │ │TX Shift│                          │    │     │     │
│    │ │Register│                          │ ┌──┴────┐│     │
│    │ └───┬───┘ │                         │ │RX     ││     │
│    │     │     │                         │ │Shift  ││     │
│    │ ┌───▼───┐ │                         │ │Reg    ││     │
│    │ │Baud   │ │                         │ └──▲────┘│     │
│    │ │Rate   │ │                         │    │     │     │
│    │ │Gen    │ │                         │ ┌──┴────┐│     │
│    │ │(TX)   │ │                         │ │16x    ││     │
│    │ └───┬───┘ │                         │ │Sample ││     │
│    │     │     │                         │ │       ││     │
│    └─────┼─────┘                         └──┼──────┘     │
│          │                                  │            │
│       ┌──▼──┐                            ┌──▼──┐         │
│       │ TX  │                            │ RX  │         │
└───────┴─────┴────────────────────────────┴─────┴─────────┘
           │                                  │
           │ ui_out[0]              ui_in[7]  │
           └──────────────┬──────────────────┘
                          │
                     ┌────▼─────┐
                     │ External │
                     │  Device  │
                     └──────────┘
```

### Register Map

| Address | Register | Access | Description |
|---------|----------|--------|-------------|
| 0x00    | DR       | R/W    | Data Register (TX write / RX read) |
| 0x04    | SR       | R      | Status Register |
| 0x08    | CR       | R/W    | Control Register |
| 0x0C    | BRR      | R/W    | Baud Rate Divisor Register |

#### Data Register (DR) - 0x00
| Bits | Name | Access | Description |
|------|------|--------|-------------|
| 7:0  | DATA | R/W    | TX: Write byte to send<br>RX: Read received byte |
| 31:8 | -    | -      | Reserved |

#### Status Register (SR) - 0x04
| Bit | Name     | Access | Description |
|-----|----------|--------|-------------|
| 0   | RXNE     | R      | RX Not Empty (1 = data available) |
| 1   | TXE      | R      | TX Empty (1 = can write data) |
| 2   | RXOVR    | R/W1C  | RX Overrun Error |
| 3   | FRAME_ERR| R/W1C  | Framing Error |
| 4   | TX_FULL  | R      | TX FIFO Full |
| 5   | RX_FULL  | R      | RX FIFO Full |
| 31:6| -        | -      | Reserved |

#### Control Register (CR) - 0x08
| Bit | Name    | Access | Description |
|-----|---------|--------|-------------|
| 0   | TXEN    | R/W    | TX Enable (1 = enable transmitter) |
| 1   | RXEN    | R/W    | RX Enable (1 = enable receiver) |
| 2   | RXNEIE  | R/W    | RX Interrupt Enable |
| 3   | TXEIE   | R/W    | TX Interrupt Enable |
| 4   | ERRIE   | R/W    | Error Interrupt Enable |
| 31:5| -       | -      | Reserved |

#### Baud Rate Register (BRR) - 0x0C
| Bits  | Name | Access | Description |
|-------|------|--------|-------------|
| 15:0  | DIV  | R/W    | Baud rate divisor<br>Baud = CLK / (16 × DIV) |
| 31:16 | -    | -      | Reserved |

**Example**: For 9600 baud @ 70MHz:
```
DIV = 70,000,000 / (16 × 9600) = 456.6 ≈ 457 (0x1C9)
```

---

## Implementation Plan

### Phase 1: Core TX Module (Days 1-2)

**Deliverables**:
- [ ] Baud rate generator module
- [ ] TX shift register and state machine
- [ ] Basic TX FIFO (16 bytes)
- [ ] TX testbench

**LLM Prompts to Use**:
1. "Generate Verilog for a baud rate generator with configurable divisor"
2. "Implement UART TX module with shift register and state machine for 8N1 format"
3. "Create a simple FIFO buffer in Verilog with configurable depth"

### Phase 2: Core RX Module (Days 3-4)

**Deliverables**:
- [ ] RX oversampling logic (16×)
- [ ] RX shift register and state machine
- [ ] Start bit detection
- [ ] RX FIFO (16 bytes)
- [ ] Frame error detection
- [ ] RX testbench

**LLM Prompts to Use**:
1. "Generate UART RX module with 16x oversampling for start bit detection"
2. "Implement RX shift register with framing error detection"
3. "Create RX state machine for 8N1 UART frame reception"

### Phase 3: Register Interface (Day 5)

**Deliverables**:
- [ ] Register decoder
- [ ] DR, SR, CR, BRR implementation
- [ ] Read/write logic
- [ ] Integration with TX/RX modules

**LLM Prompts to Use**:
1. "Implement register interface for UART with address decode and read/write logic"
2. "Create status register that reflects FIFO states and error flags"

### Phase 4: Integration & Testing (Days 6-7)

**Deliverables**:
- [ ] Top-level UART peripheral module
- [ ] Integration with peripheral.v
- [ ] Comprehensive cocotb testbench
- [ ] Loopback test (TX → RX)
- [ ] Multiple baud rate tests

**LLM Prompts to Use**:
1. "Create cocotb testbench for UART with TX/RX loopback test"
2. "Generate test vectors for multiple baud rates"

### Phase 5: Synthesis & PPA (Day 8)

**Deliverables**:
- [ ] Clean Yosys synthesis
- [ ] OpenLANE PPA analysis
- [ ] Timing verification
- [ ] Area/power analysis

**Commands**:
```bash
./scripts/run_synthesis.sh --cleanup
./scripts/run_synthesis_and_ppa.sh ~vlsi/tools/OpenLane --cleanup
klayout runs/RUN_*/results/final/gds/*.gds
```

### Phase 6: Documentation (Day 9)

**Deliverables**:
- [ ] Complete DESIGN_REPORT.md
- [ ] Complete PPA_ANALYSIS.md
- [ ] Organize prompt logs
- [ ] Add block diagrams
- [ ] Add waveform screenshots

### Phase 7: Submission (Day 10)

**Deliverables**:
- [ ] Git tag DP1-Submission
- [ ] Final push to repository
- [ ] Submission package review

---

## Testing Strategy

### Unit Tests
1. **Baud Rate Generator**
   - Verify correct period at multiple baud rates
   - Test divisor calculations

2. **TX Module**
   - Single byte transmission
   - Multiple byte transmission
   - FIFO full/empty conditions
   - Frame format verification (8N1)

3. **RX Module**
   - Single byte reception
   - Start bit detection
   - Frame error detection
   - Overrun detection
   - FIFO operation

### Integration Tests
1. **Loopback Test**
   - Connect TX → RX
   - Verify data integrity
   - Test at multiple baud rates

2. **CPU Interface Test**
   - Register read/write
   - Status flags
   - Interrupt generation

3. **Performance Test**
   - Sustained throughput
   - FIFO stress test
   - Back-to-back frames

---

## Risk Management

| Risk | Impact | Mitigation |
|------|--------|------------|
| Timing closure failure | High | Start simple, optimize if needed |
| RX synchronization issues | Medium | Use 16× oversampling, test thoroughly |
| FIFO implementation errors | Medium | Use well-tested FIFO template |
| Integration issues | Medium | Test modules independently first |
| Insufficient testing time | High | Prioritize core functionality first |

---

## Timeline

```
Day 1-2  : TX Module (baud gen, shift reg, FIFO)
Day 3-4  : RX Module (oversampling, detection, FIFO)
Day 5    : Register Interface
Day 6-7  : Integration & Testing
Day 8    : Synthesis & PPA
Day 9    : Documentation
Day 10   : Final Review & Submission
```

**Milestone**: January 28 - All deliverables complete  
**Review**: January 29 - Present results

---

## Resources & References

### Documentation
- ✅ [UART_FUNDAMENTALS.md](UART_FUNDAMENTALS.md) - Complete UART guide
- ✅ [SYNTHESIS_AND_PPA_ANALYSIS.md](SYNTHESIS_AND_PPA_ANALYSIS.md) - Workflow guide
- ✅ [README.md](../README.md) - Project overview

### Tools
- **Synthesis**: `./scripts/run_synthesis.sh`
- **PPA**: `./scripts/run_synthesis_and_ppa.sh`
- **Testing**: cocotb (`peripheral/test/`)
- **Waveforms**: GTKWave
- **Layout**: KLayout

### Reference Implementations
- Study `peripheral/src/peripheral.v` (example structure)
- TinyQV register interface in `cpu/src/tinyqv.v`

---

## Prompt Logging Requirements

**CRITICAL**: All LLM interactions MUST be logged!

### What to Log
- ✅ Initial design prompts
- ✅ Module generation requests
- ✅ Debugging conversations
- ✅ Optimization discussions
- ✅ Testing strategy development

### How to Log
1. Save conversations as markdown files
2. Name: `YYYY-MM-DD_topic.md`
3. Store in: `submissions/prompt_logs/`

### Example Log Structure
```markdown
# UART TX Module Generation - 2026-01-19

## Prompt 1: Initial Request
User: Generate Verilog for UART TX module...

## Response 1:
[LLM generated code]

## Prompt 2: Refinement
User: Add FIFO integration...
...
```

---

## Success Metrics

At completion, we should have:

✅ **Functional UART** that can TX/RX at standard baud rates  
✅ **Clean synthesis** with 0 errors  
✅ **Timing met** at 70MHz  
✅ **Area efficient** design  
✅ **100% test coverage** of core functionality  
✅ **Complete documentation** with diagrams and analysis  
✅ **All prompts logged** for submission  

---

**Status**: Planning Complete - Ready for Implementation  
**Next**: Create detailed block diagrams → Begin TX module implementation
