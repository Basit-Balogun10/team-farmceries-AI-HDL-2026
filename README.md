# Team Farmceries - AI Hardware Design League 2026

This repository documents our journey through the [AI-HDL 2026](https://github.com/prismlabarizona/AIHDL-2026/) competition design phases.

## Design Phase 1: Secure UART Peripheral

### Completed: Basic UART (Jan 17-20)

A complete UART (serial communication) peripheral that connects to a tiny RISC-V processor - the chip's "talking module" for sending and receiving data one bit at a time over a wire.

**Implementation**: Minimalist design with essentials - transmitter, receiver, baud rate control, and CPU interface.

**Results:**

-   ✅ 852 logic cells (525 for UART core)
-   ✅ 0.01795 mm² chip area
-   ✅ 0 ns worst negative slack (meets 70MHz timing)
-   ✅ 0.0014 µW average power
-   ✅ 37/37 tests passing

### Completed: Enhanced Secure UART (Jan 21-25)

Building upon the basic UART with hardware-accelerated encryption for secure embedded communication:

**✅ AES-128 Encryption Engine**

-   11-cycle hardware encryption/decryption
-   Dual independent cores for full-duplex operation
-   Transparent to software (CPU sees simple byte TX/RX)
-   Bypass mode for debugging and plaintext communication

**✅ 16-Byte Block Buffering**

-   Automatic accumulation of bytes into 128-bit AES blocks
-   Hardware handles all buffering logic
-   Zero software overhead

**✅ Complete Integration**

-   12 registers (UART control + AES key storage)
-   18/18 tests passing (13 component + 5 system)
-   0.01% performance overhead (AES is 8800× faster than UART)
-   Production-ready encrypted serial communication

**Design Context**: While industry typically uses WiFi/TLS or software encryption, our hardware AES-UART demonstrates transparent encryption in dedicated circuits - excellent for learning FPGA design and understanding hardware acceleration trade-offs. See [detailed industry comparison](dp-1/docs/secure-uart/SECURE_UART_FUNDAMENTALS.md#why-isnt-secure-being-done-this-way).

## The Journey

### Phase 0: Infrastructure Setup (Jan 17-18)

-   Gathered competition docs, webinar notes, technical specs
-   Converted PDFs to markdown for better AI parsing
-   Set up synthesis tools and automation scripts
-   Built comprehensive context for AI collaboration

### Phase 1: Learning & Basic UART (Jan 19-20)

-   Used AI to understand UART protocol and timing
-   Created comprehensive documentation and diagrams
-   Implemented 5 core modules with AI code generation
-   Wrote 37 tests to verify everything works
-   Fixed bugs through multiple debug iterations
-   **Result: All tests passing ✓**

### Phase 2: Synthesis & Verification (Jan 20)

-   Ran synthesis to convert code into actual logic gates
-   Fixed critical bug (multiple drivers on same wire)
-   Achieved target metrics: 0.018mm² area, 0ns timing slack
-   **Result: PPA targets exceeded ✓**

### Phase 3: Documentation (Jan 20-21)

-   Wrote technical reports explaining the design
-   Analyzed performance metrics
-   Saved complete AI conversation logs for transparency
-   **Result: Complete Phase 1 documentation ✓**

### Phase 4: Enhancement Planning & Documentation (Jan 21)

-   Researched FIFOs, flow control, and AES-128
-   Created comprehensive documentation for enhancements
-   **Secure UART concept**: FIFOs + Flow Control + AES encryption
-   Organized documentation: separate uart/ and aes/ subdirectories

### Phase 5: Enhanced Implementation (Jan 21-25) ✅ COMPLETE

-   **Days 1-2**: Researched and documented AES-128 theory
-   **Days 3-4**: Implemented AES core (encryption + decryption) with test suite
-   **Day 5**: Built AES-UART integration controller with streaming logic
-   **Day 6**: System integration and comprehensive testing (18/18 passing)
-   **Day 7**: Complete documentation (8 files, 2000+ lines, diagrams)
-   **Result**: Production-ready encrypted UART with hardware acceleration

### Phase 6: Synthesis & Submission (Jan 25-26) 🔄 IN PROGRESS

-   **Today**: Final synthesis and PPA analysis
-   **Tomorrow**: Submission preparation and repository cleanup

## Current Results

### Phase 1 (Basic UART) - Complete

✅ **852 logic cells** (525 for UART core)  
✅ **0.01795 mm²** chip area (exceeds 0.020mm² target)  
✅ **0 ns** worst negative slack (meets 70MHz timing)  
✅ **0.0014 µW** average power (exceeds 0.005µW target)  
✅ **37/37 tests passing**

### Phase 2 (Secure UART with AES-128) - Complete

✅ **18/18 tests passing** (13 component + 5 system tests)  
✅ **AES-128 encryption** in 11 cycles @ 70MHz (157ns)  
✅ **Full-duplex** simultaneous TX encrypt + RX decrypt  
✅ **0.01% overhead** (AES 8800× faster than UART bottleneck)  
✅ **Transparent operation** (zero software crypto code needed)  
✅ **124,778 total cells** (CPU + Secure UART, 30,331 flip-flops)  
✅ **Synthesis successful** on full tt_wrapper with TinyQV integration

## AI Collaboration

This design was created through conversation with GitHub Copilot (Claude Sonnet 4.5). We didn't just ask AI to "make a UART" - we learned together, iterated on bugs, and verified every step through testing.

**Key insight**: AI is powerful for hardware design when you understand what you're building, test rigorously, and treat it as a collaborator rather than a magic wand.

The complete 417KB conversation log is in [`dp-1/submissions/prompt_logs/`](dp-1/submissions/prompt_logs/) - every question, every bug fix, every iteration.

## Repository Structure

```
dp-1/
├── peripheral/
│   ├── src/uart/              # UART Verilog modules
│   └── test/                  # 37 Cocotb test files
└── submissions/
    ├── DESIGN_REPORT.md       # Technical architecture
    ├── PPA_ANALYSIS.md        # Performance metrics
    ├── README.md              # Quick overview
    ├── prompt_logs/           # Complete AI conversation
    ├── synthesis_reports/     # Tool outputs
    └── testbench_results/     # Test results
```

## What's Next

Future design phases will build upon this foundation as the competition progresses.

---

**Team Farmceries** | AI-HDL 2026 Competition
