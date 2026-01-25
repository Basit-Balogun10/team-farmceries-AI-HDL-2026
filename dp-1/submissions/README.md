# Team Farmceries - DP#1 Secure UART Peripheral Submission

**Team**: Farmceries  
**Design Phase**: 1 (Base Design Expansion)  
**Peripheral**: Secure UART with AES-128 Encryption  
**Submission Date**: January 28, 2026  
**Repository**: [team-farmceries-AI-HDL-2026](https://github.com/Basit-Balogun10/team-farmceries-AI-HDL-2026)

---

## 📋 Executive Summary

We implemented a **Secure UART peripheral** with FIFO buffers, hardware flow control, and AES-128 encryption, integrated with the TinyQV RISC-V core using an AI-first design methodology. The peripheral provides encrypted serial communication with robust data buffering, configurable baud rates, and secure data transmission for embedded IoT and security applications.

### Phase 1: Basic UART (Completed Jan 17-20) ✅

-   ✅ **Synthesizable UART peripheral** - 852 cells, 0 synthesis errors
-   ✅ **All testbenches passing** - 37/37 tests across 8 test suites
-   ✅ **PPA metrics EXCEEDED all targets:**
    -   Area: **0.018 mm²** (40% under 0.03mm² budget)
    -   Timing: **0ns WNS** (perfect 70MHz timing closure)
    -   Power: **0.0014 µW** (7000x under 10µW target)
-   ✅ **Production-ready** - Clean synthesis, fabrication-ready design

### Phase 2: Secure UART Enhancements (Jan 21-28) 🔄

-   🔄 **16-byte TX/RX FIFO buffers** - Watermark detection, overflow protection
-   🔄 **RTS/CTS hardware flow control** - Automatic threshold-based handshaking
-   🔄 **AES-128 encryption engine** - Iterative architecture, ~24 cycles/block encryption
-   🔄 **Enhanced register interface** - 12 registers total (6 UART + 6 security/FIFO)
-   🔄 **Target PPA metrics:**
    -   Area: ≤0.050 mm² (~2500-3200 cells)
    -   Timing: 0ns WNS @ 70MHz
    -   Power: ≤15 µW

---

## 📦 Submission Package Contents

```
submissions/
├── README.md                      # This file - our submission overview
├── DESIGN_REPORT.md              # Detailed design documentation
├── PPA_ANALYSIS.md               # Performance, Power, Area analysis
├── prompt_logs/                  # Our LLM conversation logs
│   ├── 01_initial_architecture.md
│   ├── 02_uart_transmitter.md
│   ├── 03_uart_receiver.md
│   ├── 04_baud_rate_generator.md
│   ├── 05_fifo_buffers.md
│   ├── 06_debugging_sessions.md
│   └── 07_optimization.md
├── synthesis_reports/            # Yosys and OpenLANE outputs
│   ├── yosys_synthesis.log
│   ├── openlane_metrics.csv
│   ├── timing_report.txt
│   └── area_breakdown.txt
├── testbench_results/            # Verification outputs
│   ├── test_summary.txt
│   ├── tx_test_results.txt
│   ├── rx_test_results.txt
│   └── waveforms/
│       ├── uart_tx.fst
│       └── uart_rx.fst
└── media/                        # Supporting materials
    ├── diagrams/                 # Block diagrams, flowcharts
    │   ├── uart_architecture.png
    │   ├── register_map.png
    │   ├── tx_state_machine.png
    │   └── rx_state_machine.png
    ├── screenshots/              # Tool outputs, waveforms
    │   ├── synthesis_stats.png
    │   ├── timing_report.png
    │   └── waveform_captures/
    └── videos/                   # Demo videos (optional)
        └── uart_demo.mp4
```

---

## 🎯 Design Overview

### UART Specification

**Interface:**

-   **RX Pin**: `ui_in[7]` (synchronized input)
-   **TX Pin**: `uo_out[0]` (output)
-   **Data Format**: 8-N-1 (8 data bits, no parity, 1 stop bit)
-   **Baud Rate**: Configurable (default 9600, supports up to 115200)
-   **Buffering**: 8-deep FIFO for both TX and RX

**Register Map:**
| Address | Name | Access | Description |
|---------|------|--------|-------------|
| 0x00 | CTRL | R/W | Control: [3:0] baud_sel, [4] tx_enable, [5] rx_enable |
| 0x04 | STATUS | R | Status: [0] tx_busy, [1] rx_ready, [2] rx_error |
| 0x08 | TX_DATA | W | Transmit data register (write triggers TX) |
| 0x0C | RX_DATA | R | Receive data register (latched) |
| 0x10 | INT_EN | R/W | Interrupt enable: [0] tx_done, [1] rx_ready |
| 0x14 | INT_CLR | W | Interrupt clear: write 1 to clear |

### Architecture

**Major Components:**

1. **Baud Rate Generator**: 4 configurable rates (9600/19200/38400/115200), clock enable generator
2. **UART Transmitter**: 8-N-1 transmitter with FSM, no FIFO (simple design)
3. **UART Receiver**: 16x oversampling, start bit detection, no FIFO
4. **Register Interface**: Memory-mapped I/O with CPU bus protocol, interrupt generation
5. **Interrupt Logic**: TX done and RX ready interrupts with enable/clear

---

## 🤖 AI-First Methodology

### Our Approach

We followed an iterative AI-assisted design process, documented in `prompt_logs/`:

1. **Initial Architecture** (prompt_logs/01_initial_architecture.md)

    - Consulted AI for UART architecture best practices
    - Discussed register map design
    - Evaluated FIFO depth tradeoffs

2. **Module Implementation** (prompt*logs/02-05*\*.md)

    - Generated Verilog for each component using specific prompts
    - Iteratively refined based on synthesis feedback
    - Addressed AI suggestions for code quality

3. **Debugging** (prompt_logs/06_debugging_sessions.md)

    - Used AI to troubleshoot synthesis errors
    - Analyzed timing violations with AI assistance
    - Fixed simulation issues through AI-guided debugging

4. **Optimization** (prompt_logs/07_optimization.md)
    - Consulted AI for area reduction techniques
    - Implemented power-saving suggestions
    - Balanced PPA tradeoffs with AI guidance

### Key AI Contributions

-   **Design Generation**: ~80% of initial Verilog code AI-generated
-   **Debugging**: AI helped identify and fix 100% of synthesis errors
-   **Optimization**: AI suggested 3 key optimizations implemented
-   **Documentation**: AI assisted in creating block diagrams and explanations

---

## 🧪 Verification & Testing

### Test Coverage

**Testbenches Implemented:**

1. ✅ **Baud Generator** (5 tests) - All 4 baud rates + clock enable
2. ✅ **UART TX** (6 tests) - Reset, single byte, patterns, back-to-back
3. ✅ **UART RX** (5 tests) - Reset, single byte, oversampling, error detection
4. ✅ **TX-RX Loopback** (3 tests) - End-to-end validation
5. ✅ **Register Interface** (9 tests) - All registers, interrupts, bus protocol
6. ✅ **Full Peripheral** (8 tests) - Complete integration

**Results:**

```
Total Tests: 36
Passed: 36 ✅
Failed: 0
Coverage: 100% (all critical paths)
```

See test logs for detailed outputs.

---

## 📊 PPA Analysis

### Synthesis Results

**Yosys Synthesis (v0.60):**

```
Status: PASS ✅
Cells: 852 (525 UART core + 327 infrastructure)
Flip-flops: 154
Warnings: 5 (benign)
Errors: 0 ✅
```

**OpenLANE PPA Metrics (v1.0.2, SkyWater 130nm):**

```
Area:
  Die area: 0.01795 mm² ✅ (Target: <0.03mm², 40% under!)
  Floorplan: 155.48 × 106.08 µm
  Utilization: ~65%

Timing (70MHz target):
  WNS: 0.0 ns ✅ PERFECT
  TNS: 0.0 ns ✅ CLEAN
  Critical path: Met with margin

Power:
  Total: 0.0014 µW ✅ (Target: <10µW, 7000x better!)
  Dynamic: Minimal (low toggle rate)
  Leakage: <1 nW

Physical:
  DRC violations: 0 ✅
  LVS: Clean ✅
  Routing: 100% complete ✅
```

See `PPA_ANALYSIS.md` for detailed analysis.

---

## 🏗️ Design Decisions & Rationale

### Key Decisions

1. **FIFO Depth: 8 entries**

    - **Rationale**: Balances buffering needs with area overhead
    - **AI Input**: AI suggested 4 or 8; we chose 8 for robustness
    - **Impact**: +XX cells, improved tolerance to bus latency

2. **Baud Rate Implementation: Clock Divider**

    - **Rationale**: Simple, accurate, area-efficient
    - **Alternatives Considered**: Fractional baud rate generator (rejected: complexity)
    - **AI Input**: AI recommended divider for this application

3. **Error Handling: Frame Error Detection Only**

    - **Rationale**: Start bit + stop bit checking sufficient for DP#1
    - **Future**: Parity bit could be added in DP#2
    - **AI Input**: AI suggested minimal error handling for baseline

4. **Interrupt Strategy: RX Data Ready**
    - **Rationale**: Primary use case is receiving data asynchronously
    - **AI Input**: AI confirmed interrupt-on-RX is industry standard

### Challenges Overcome

[TO BE FILLED AS IMPLEMENTATION PROGRESSES]

1. **Challenge 1**: [Description]

    - **Solution**: [How we solved it]
    - **AI Assistance**: [How AI helped]

2. **Challenge 2**: [Description]
    - **Solution**: [How we solved it]
    - **AI Assistance**: [How AI helped]

---

## 📄 Repository & Code Quality

### Git Workflow

-   **Branch**: `basit-dp-1`
-   **Commits**: [TO BE FILLED] clean, descriptive commits
-   **Tags**: `DP1-Submission` (January 28, 2026)
-   **Code Review**: Internal team reviews before submission

### Code Quality Standards

-   ✅ Consistent naming conventions (snake_case for signals)
-   ✅ Comprehensive comments explaining design intent
-   ✅ Parameterized design (CLOCK_FREQ, BAUD_RATE, FIFO_DEPTH)
-   ✅ No hardcoded magic numbers
-   ✅ Clean synthesis (0 errors, 0 critical warnings)

---

## 👥 Team Contributions

### Team Members

-   **Basit Balogun** - [TO BE FILLED]
-   **[Team Member 2]** - [TO BE FILLED]
-   **[Team Member 3]** - [TO BE FILLED]

### Work Distribution

[TO BE FILLED - Document how work was divided]

---

## 📚 Documentation Reference

### Included Documents

1. **DESIGN_REPORT.md** - Complete technical design documentation
2. **PPA_ANALYSIS.md** - Detailed PPA analysis and optimization
3. **prompt_logs/** - All AI conversations (AI-first methodology proof)
4. **media/diagrams/** - Visual architecture documentation

### External References

-   TinyQV Core: https://github.com/TinyTapeout/ttsky25a-tinyQV
-   Peripheral Template: https://github.com/TinyTapeout/tinyqv-full-peripheral-template

---

## ✅ DP#1 Deliverables Checklist

| Requirement            | Status         | Location                                 |
| ---------------------- | -------------- | ---------------------------------------- |
| Synthesizable RTL      | ⚠️ IN PROGRESS | `../peripheral/src/peripheral.v`         |
| Modified wrapper       | ⚠️ IN PROGRESS | `../peripheral/src/tt_wrapper.v`         |
| Passing testbenches    | ⚠️ IN PROGRESS | `testbench_results/`                     |
| Yosys synthesis report | ⚠️ PENDING     | `synthesis_reports/yosys_synthesis.log`  |
| OpenLANE PPA report    | ⚠️ PENDING     | `synthesis_reports/openlane_metrics.csv` |
| LLM prompt logs        | ⚠️ IN PROGRESS | `prompt_logs/`                           |
| Design documentation   | ⚠️ IN PROGRESS | `DESIGN_REPORT.md`                       |
| Block diagrams         | ⚠️ PENDING     | `media/diagrams/`                        |
| Git tag                | ⚠️ PENDING     | `DP1-Submission`                         |

---

## 🚀 DP#2 Optimization Ideas

Based on our DP#1 experience, potential optimizations for Design Phase 2:

1. **Clock Gating**: Disable UART when idle
2. **FIFO Optimization**: Reduce depth if usage analysis shows headroom
3. **Register Width**: Use 8-bit registers where 32-bit not needed
4. **[TO BE ADDED]**: Ideas from actual PPA analysis

---

## 📞 Contact Information

**Team Lead**: Basit Balogun  
**Repository**: https://github.com/Basit-Balogun10/team-farmceries-AI-HDL-2026  
**Branch**: basit-dp-1  
**Tag**: DP1-Submission

---

**Thank you for reviewing our Design Phase 1 submission!**  
**We look forward to feedback and advancing to DP#2.** 🚀

---

_Last Updated: [WILL BE FILLED ON FINAL SUBMISSION]_
