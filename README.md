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

### In Progress: Enhanced Secure UART (Jan 21-28)

Building upon the basic UART with production-grade features for real-world secure communication:

**🔄 FIFOs (Jan 21-22)**

-   TX/RX buffers (16 bytes each)
-   Watermark detection for efficient interrupt handling
-   Overflow/underflow protection

**🔄 Hardware Flow Control (Jan 21-22)**

-   RTS/CTS handshaking
-   Prevents data loss during backpressure
-   Automatic pause/resume

**🔄 AES-128 Encryption (Jan 23-25)**

-   Hardware encryption engine
-   Secure serial communication
-   Transparent encrypt-on-send, decrypt-on-receive
-   128-bit key storage

**Why Secure UART?**
This isn't just adding features - it's solving a real problem: **secure serial communication for embedded systems**. Use cases include encrypted firmware updates, secure debug interfaces, and protected sensor data transmission.

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

### Phase 5: Enhanced Implementation (Jan 21-28) 🔄 IN PROGRESS

-   **Days 1-2**: Implementing TX/RX FIFOs and RTS/CTS flow control
-   **Days 3-5**: Building AES-128 encryption engine
-   **Day 6**: Integration and end-to-end testing
-   **Day 7**: Final synthesis, PPA, and documentation
-   **Day 8**: Submission preparation

## Current Results

### Phase 1 (Basic UART) - Complete

✅ **852 logic cells** (525 for UART core)  
✅ **0.01795 mm²** chip area (exceeds 0.020mm² target)  
✅ **0 ns** worst negative slack (meets 70MHz timing)  
✅ **0.0014 µW** average power (exceeds 0.005µW target)  
✅ **37/37 tests passing**

### Phase 2 (Secure UART) - In Progress

🔄 **Target: ~2500-3200 cells** (FIFOs + Flow Control + AES)  
🔄 **Target: ≤0.050 mm²** chip area  
🔄 **Target: 0 ns** WNS @ 70MHz  
🔄 **Target: ≤15 µW** average power  
🔄 **Target: 50+ tests passing**

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
