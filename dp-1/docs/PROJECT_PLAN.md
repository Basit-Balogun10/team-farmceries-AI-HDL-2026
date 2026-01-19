# AI-HDL DP#1 Project Plan - UART Peripheral Implementation

**Project**: UART Peripheral for TinyQV RISC-V Core  
**Team**: Team Farmceries  
**Deadline**: January 28, 2026  
**Milestone Review**: January 29, 2026

---

## Project Overview

### Objective
Design and implement a synthesizable UART (Universal Asynchronous Receiver/Transmitter) peripheral that interfaces with the TinyQV RISC-V core via a 32-bit register-based interface.

### Success Criteria
1. ✅ Synthesizable RTL (passes Yosys)
2. ✅ Timing closure at 70 MHz (14ns clock period)
3. ✅ Passing testbenches (functional verification)
4. ✅ Complete PPA analysis (OpenLANE)
5. ✅ Full documentation with LLM prompt logs

---

## Technical Requirements

### 1. Interface Requirements

**CPU Interface (Register-Based)**
- 32-bit address bus
- 32-bit data input/output
- Read/write control signals
- Compatible with TinyQV memory map

**UART Signals**
- RX (Receive): `ui_in[7]` - Serial data input
- TX (Transmit): `uo_out[0]` - Serial data output
- Interrupt: `user_interrupt` - RX data ready notification

**Clock & Reset**
- System clock: 70 MHz
- Asynchronous active-low reset

### 2. Functional Requirements

**Transmission (TX)**
- Configurable baud rate (9600, 19200, 38400, 115200 bps)
- 8 data bits
- No parity
- 1 stop bit
- TX FIFO (optional but recommended, depth 4-8)

**Reception (RX)**
- Same baud rates as TX
- Same frame format (8N1)
- RX FIFO (optional but recommended, depth 4-8)
- Interrupt on data ready

**Registers (Memory-Mapped)**
| Address | Register | R/W | Description |
|---------|----------|-----|-------------|
| 0x00 | CTRL | W | Control: baud rate select, enable |
| 0x04 | STATUS | R | Status: TX busy, RX ready, FIFO status |
| 0x08 | TX_DATA | W | Transmit data register |
| 0x0C | RX_DATA | R | Receive data register |

### 3. Performance Requirements

**Timing**
- Clock frequency: 70 MHz (14ns period)
- Setup/hold timing: Must meet at all corners
- Target WNS: 0 ns or better

**Area**
- Die area budget: ~0.02 mm² (similar to example peripheral)
- Cell utilization: 50-70%

**Power**
- Typical power: < 10 µW (estimated)
- Minimize switching activity when idle

---

## Implementation Plan

### Phase 1: Design & Planning (Jan 19) ✅
**Tasks:**
- [x] Study UART fundamentals
- [x] Review interface specifications
- [x] Create block diagrams
- [x] Define register map
- [x] Set up project structure

**Deliverables:**
- UART_FUNDAMENTALS.md
- PROJECT_PLAN.md
- BLOCK_DIAGRAMS.md

---

### Phase 2: Baud Rate Generator (Jan 20)
**Tasks:**
- [ ] Design baud rate clock divider
- [ ] Support multiple baud rates
- [ ] Implement configuration logic
- [ ] Create testbench for baud generator

**LLM Prompts to Use:**
- "Design a configurable baud rate generator for UART at 70MHz system clock"
- "Create testbench for baud rate generator with 9600, 115200 bps"

**Verification:**
- Test at 9600 bps: 70MHz / 9600 = 7291.67 clocks per bit
- Test at 115200 bps: 70MHz / 115200 = 607.64 clocks per bit

**Success Criteria:**
- Accurate baud rate generation (< 2% error)
- Synthesis passes
- Testbench validates timing

---

### Phase 3: UART Transmitter (Jan 21)
**Tasks:**
- [ ] Implement TX state machine (IDLE, START, DATA, STOP)
- [ ] Add TX shift register
- [ ] Integrate baud rate generator
- [ ] Optional: Add TX FIFO (depth 4-8)
- [ ] Create TX testbench

**LLM Prompts to Use:**
- "Implement UART transmitter with 8N1 format and configurable baud rate"
- "Design a simple FIFO buffer for UART TX with depth 8"
- "Create testbench to verify UART transmission of 0x55, 0xAA patterns"

**Verification:**
- Send test patterns: 0x00, 0x55, 0xAA, 0xFF
- Verify start bit, data bits, stop bit
- Check bit timing with oscilloscope/waveform

**Success Criteria:**
- Correct serial bit sequence
- Accurate bit timing
- TX busy flag works correctly

---

### Phase 4: UART Receiver (Jan 22)
**Tasks:**
- [ ] Implement RX state machine
- [ ] Add oversampling (16x recommended)
- [ ] Implement start bit detection
- [ ] Add RX shift register
- [ ] Optional: Add RX FIFO (depth 4-8)
- [ ] Create RX testbench

**LLM Prompts to Use:**
- "Design UART receiver with 16x oversampling and start bit detection"
- "Implement majority voting for noise immunity in UART RX"
- "Create testbench that sends serial data and verifies UART reception"

**Verification:**
- Receive test patterns from TX
- Verify data integrity
- Test with noisy input (glitches)
- Check interrupt generation

**Success Criteria:**
- Correctly receives all test patterns
- Handles noise gracefully
- RX ready interrupt triggers properly

---

### Phase 5: Register Interface (Jan 23)
**Tasks:**
- [ ] Implement register read/write logic
- [ ] Add control register (baud rate, enable)
- [ ] Add status register (TX busy, RX ready)
- [ ] Connect TX_DATA, RX_DATA registers
- [ ] Integrate with TinyQV interface

**LLM Prompts to Use:**
- "Create memory-mapped register interface for UART peripheral"
- "Design control/status registers for UART with baud rate configuration"
- "Integrate UART registers with TinyQV 32-bit bus interface"

**Register Definitions:**

**CTRL (0x00) - Control Register**
```
[31:8] Reserved
[7:4]  BAUD_SEL (0=9600, 1=19200, 2=38400, 3=115200)
[3:1]  Reserved
[0]    ENABLE (1=enabled, 0=disabled)
```

**STATUS (0x04) - Status Register**
```
[31:8] Reserved
[7:4]  RX_FIFO_COUNT (if FIFO implemented)
[3]    TX_BUSY
[2]    RX_READY
[1]    RX_OVERRUN
[0]    RX_ERROR
```

**Verification:**
- Write to CTRL, read back
- Check STATUS flags
- Verify TX_DATA write triggers transmission
- Verify RX_DATA read clears RX_READY

**Success Criteria:**
- All registers accessible
- Baud rate changes correctly
- Status flags accurate

---

### Phase 6: Integration & Testing (Jan 24-25)
**Tasks:**
- [ ] Integrate all modules (TX, RX, baud gen, registers)
- [ ] Update top-level peripheral.v
- [ ] Create comprehensive testbench
- [ ] Test loopback mode (TX → RX)
- [ ] Test with TinyQV CPU interface
- [ ] Run cocotb tests

**LLM Prompts to Use:**
- "Integrate UART TX, RX, and registers into top-level module"
- "Create comprehensive cocotb testbench for UART peripheral"
- "Design loopback test that verifies UART TX to RX communication"

**Test Scenarios:**
1. Basic loopback (connect TX to RX)
2. Multiple byte transmission
3. Different baud rates
4. FIFO full/empty conditions (if implemented)
5. Interrupt generation
6. Register read/write

**Success Criteria:**
- All cocotb tests pass
- Loopback test successful
- No timing violations in simulation

---

### Phase 7: Synthesis & PPA (Jan 26)
**Tasks:**
- [ ] Run synthesis: `./scripts/run_synthesis.sh --cleanup`
- [ ] Fix any synthesis errors
- [ ] Run full PPA: `./scripts/run_synthesis_and_ppa.sh ~vlsi/tools/OpenLane --cleanup`
- [ ] Analyze timing reports
- [ ] Optimize if needed (area/timing trade-offs)
- [ ] Document PPA results

**Verification:**
- Synthesis: 0 errors
- WNS (Worst Negative Slack): 0 ns or better
- Area: < 0.03 mm²
- Power: < 10 µW

**Success Criteria:**
- Clean synthesis
- Timing closure
- Reasonable area/power

---

### Phase 8: Documentation (Jan 27)
**Tasks:**
- [ ] Complete DESIGN_REPORT.md
- [ ] Complete PPA_ANALYSIS.md
- [ ] Organize prompt logs
- [ ] Create diagrams/screenshots
- [ ] Update README.md
- [ ] Final review

**Deliverables Structure:**
```
submissions/
├── README.md                    # Executive summary
├── DESIGN_REPORT.md            # Technical details
├── PPA_ANALYSIS.md             # Metrics analysis
├── prompt_logs/
│   ├── 01_baud_generator.md
│   ├── 02_uart_tx.md
│   ├── 03_uart_rx.md
│   └── 04_integration.md
├── synthesis_reports/
│   ├── synthesis.log
│   └── openlane.log
├── testbench_results/
│   ├── cocotb_results.txt
│   └── waveforms/
└── media/
    ├── block_diagram.png
    └── layout_screenshot.png
```

**Success Criteria:**
- All templates filled
- Prompt logs complete
- Clear, professional documentation

---

### Phase 9: Submission (Jan 28)
**Tasks:**
- [ ] Final testing
- [ ] Create git tag: `DP1-Submission`
- [ ] Push to GitHub
- [ ] Verify submission package
- [ ] Submit via competition portal

**Final Checks:**
- [ ] All code compiles
- [ ] All tests pass
- [ ] Documentation complete
- [ ] PPA metrics documented
- [ ] Git history clean

---

## Risk Management

### Risk 1: Timing Violations
**Probability**: Medium  
**Impact**: High  
**Mitigation**:
- Start with simple design
- Run synthesis early and often
- Use pipelining if needed
- Reduce combinational logic depth

### Risk 2: Testbench Failures
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Test incrementally (module by module)
- Use waveform viewer to debug
- Create simple tests first
- Use known-good patterns

### Risk 3: Time Constraints
**Probability**: Medium  
**Impact**: High  
**Mitigation**:
- Prioritize core functionality (8N1, single baud rate)
- Make FIFO optional
- Focus on one feature at a time
- Skip advanced features if needed

### Risk 4: LLM-Generated Code Issues
**Probability**: High  
**Impact**: Medium  
**Mitigation**:
- Review all generated code carefully
- Test each module independently
- Use multiple prompts for same function
- Iterate with LLM to fix issues

---

## Resource Requirements

### Tools
- ✅ Yosys (synthesis)
- ✅ OpenLANE (PPA)
- ✅ Cocotb (testing)
- ✅ Icarus Verilog (simulation)
- ✅ GTKWave (waveform viewing)
- ✅ KLayout (layout viewing)

### Documentation
- ✅ UART specification (created)
- ✅ TinyQV interface spec (from example)
- ✅ Automation scripts (created)

### Team Skills Needed
- Verilog/SystemVerilog
- Digital design fundamentals
- Testbench creation
- LLM prompt engineering
- Git workflow

---

## Success Metrics

### Technical Metrics
- [ ] Synthesis: 0 errors, < 10 warnings
- [ ] Timing: WNS ≥ 0 ns
- [ ] Area: ≤ 0.03 mm²
- [ ] Power: ≤ 10 µW
- [ ] Tests: 100% pass rate

### Process Metrics
- [ ] Daily commits
- [ ] All prompts logged
- [ ] Weekly progress reviews
- [ ] Documentation updated continuously

### Deliverable Metrics
- [ ] All required files present
- [ ] Documentation complete
- [ ] Code well-commented
- [ ] Clean git history

---

## Daily Schedule

**Jan 19 (Today)**: Planning ✅
**Jan 20**: Baud rate generator + testing
**Jan 21**: TX module + testing
**Jan 22**: RX module + testing
**Jan 23**: Register interface + integration
**Jan 24**: Full integration testing
**Jan 25**: Synthesis optimization
**Jan 26**: PPA analysis
**Jan 27**: Documentation
**Jan 28**: Final submission

---

## Team Communication

**Daily Standup**: Quick sync on progress
- What did I complete?
- What am I working on today?
- Any blockers?

**LLM Interaction Log**: Track all prompts
- Save full conversations
- Note what worked/didn't work
- Include iteration details

**Git Commits**: Clear messages
- Use conventional commits
- Reference issues/tasks
- Keep commits atomic

---

## Next Immediate Steps

1. **Review this plan** - Make sure you understand each phase
2. **Study UART_FUNDAMENTALS.md** - Understand the protocol
3. **Review BLOCK_DIAGRAMS.md** - Understand the architecture
4. **Start Phase 2** - Begin with baud rate generator
5. **Log first LLM prompt** - Save the conversation!

---

**Status**: Planning Complete ✅  
**Next Phase**: Baud Rate Generator (Jan 20)  
**Ready to Start**: Yes! 🚀
