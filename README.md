# Team Farmceries - AI Hardware Design League 2026

This repository documents our journey through the [AI-HDL 2026](https://github.com/prismlabarizona/AIHDL-2026/) competition design phases.

## Design Phase 1: UART Peripheral

A complete UART (serial communication) peripheral that connects to a tiny RISC-V processor. Think of it as the chip's "talking module" - it lets the processor send and receive data one bit at a time over a wire.

We implemented a minimalist design with just the essentials - transmitter, receiver, baud rate control, and CPU interface. No extra fluff, just what works.

## The Journey

### Phase 1: Setup (Jan 17-18)
- Gathered competition docs, webinar notes, technical specs
- Set up synthesis tools and automation scripts
- Built context for the AI to understand what we're building

### Phase 2: Learning (Jan 19)
- Used AI to understand UART protocol and timing
- Created diagrams and documentation to visualize the design
- Made sure we understood *why*, not just *what*

### Phase 3: Building (Jan 20)
- Implemented 5 core modules with AI code generation
- Wrote 37 tests to verify everything works
- Fixed bugs through multiple debug iterations
- All tests passing ✓

### Phase 4: Synthesis & Verification (Jan 20)
- Ran synthesis to convert our code into actual logic gates
- Fixed a critical bug (multiple drivers on same wire)
- Achieved target metrics: 0.018mm² area, 0ns timing slack, 0.0014µW power

### Phase 5: Documentation (Jan 20-21)
- Wrote technical reports explaining the design
- Analyzed performance metrics
- Saved complete AI conversation logs for transparency

## Results

✅ **852 logic cells** (525 for UART core)  
✅ **0.01795 mm²** chip area (exceeds 0.020mm² target)  
✅ **0 ns** worst negative slack (meets 70MHz timing)  
✅ **0.0014 µW** average power (exceeds 0.005µW target)  
✅ **37/37 tests passing**

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
