# AI-HDL Design Phase 1 (DP#1) - Secure UART Peripheral

Team implementation of a **Secure UART peripheral** with FIFOs, flow control, and AES-128 encryption for the AI-HDL 2026 competition Design Phase 1.

## Project Overview

### Phase 1: Basic UART (Completed ✅)

-   **5 core modules**: baud_gen, uart_tx, uart_rx, register_interface, peripheral
-   **37/37 tests passing** across 8 test suites
-   **0.018 mm²** area, **0ns WNS**, **0.0014 µW** power
-   **Production-ready** with clean synthesis

### Phase 2: Secure UART with AES-128 Encryption (Completed ✅)

-   **AES-128 Engine**: Hardware-accelerated encryption/decryption (11 cycles/block)
-   **Transparent Operation**: CPU sees simple byte-level TX/RX interface
-   **Full-Duplex**: Dual independent AES cores for simultaneous TX encrypt + RX decrypt
-   **Bypass Mode**: Optional plaintext mode for debugging/compatibility
-   **18/18 tests passing** (13 component + 5 system tests)
-   **Performance**: 0.01% overhead (AES is 8800× faster than UART!)
-   **Security**: AES-128 with 340 undecillion possible keys

**Design Context**: While industry typically uses WiFi/TLS or software AES for secure communication, our hardware-accelerated AES-UART demonstrates transparent encryption in dedicated circuits - valuable for learning FPGA design patterns and understanding hardware/software integration. See [SECURE_UART_FUNDAMENTALS.md](docs/secure-uart/SECURE_UART_FUNDAMENTALS.md#why-isnt-secure-being-done-this-way) for detailed industry comparison.

## Quick Start

### Prerequisites

**Required Tools:**

-   **Docker** - For running OpenLANE (PPA analysis)
-   **Yosys** - For RTL synthesis
-   **Python 3.8+** - For scripts and cocotb
-   **iverilog** - For simulation (if using cocotb)
-   **GTKWave** - For viewing waveforms (optional)
-   **KLayout** - For viewing GDSII layouts (optional)

**For Full PPA Analysis:**

-   OpenLANE installation (tested with v1.0.2)
-   PDK (default: `~/.ciel/sky130A`)

### Setup

```bash
# 1. Clone and navigate to dp-1
cd dp-1

# 2. Set up Python environment (for cocotb testing)
python3 -m venv venv
source venv/bin/activate
pip install cocotb==1.9.2

# 3. Verify synthesis works
./scripts/run_synthesis.sh

# 4. Run cocotb tests
cd peripheral/test
make

# 5. Run full PPA analysis (requires OpenLANE)
cd ../..
./scripts/run_synthesis_and_ppa.sh ~vlsi/tools/OpenLane --cleanup
```

### Script Usage

```bash
# Quick synthesis only (no PPA, ~10 seconds)
./scripts/run_synthesis.sh [--cleanup]

# Full synthesis + PPA analysis (~3-5 minutes)
./scripts/run_synthesis_and_ppa.sh <openlane_path> [OPTIONS]

# Options:
#   --cleanup           Remove temporary files after completion
#   --pdk-root <path>   Custom PDK location (default: $HOME/.ciel)

# Examples:
./scripts/run_synthesis_and_ppa.sh ~vlsi/tools/OpenLane --cleanup
./scripts/run_synthesis_and_ppa.sh /path/to/OpenLane --pdk-root /custom/pdk
```

### Output Locations

After running scripts, results are organized as follows:

```
dp-1/
├── outputs/                  # Build logs (git-ignored)
│   ├── synthesis.log        # Yosys synthesis log
│   └── openlane.log         # OpenLANE flow log
├── runs/                     # Full PPA results (kept in git)
│   └── RUN_YYYY.MM.DD_HH.MM.SS/
│       ├── reports/         # Timing, power, area reports
│       │   └── metrics.csv  # Summary PPA metrics
│       ├── results/
│       │   └── final/
│       │       └── gds/     # GDSII layout files
│       └── logs/            # Detailed step-by-step logs
└── synthesis-work/           # Temporary files (use --cleanup to remove)
```

### Viewing Results

```bash
# View GDSII layout
klayout runs/RUN_*/results/final/gds/*.gds

# View waveforms (from cocotb tests)
gtkwave peripheral/test/tb.vcd

# Check PPA metrics
cat runs/RUN_*/reports/metrics.csv
```

## Project Structure

```
dp-1/
├── cpu/                      # TinyQV CPU core (reference)
│   ├── src/                 # CPU source files
│   ├── test/                # CPU testbenches
│   └── verify/              # Formal verification
├── peripheral/               # UART peripheral implementation
│   ├── src/
│   │   ├── peripheral.v     # UART peripheral module
│   │   ├── tt_wrapper.v     # Test wrapper (top module)
│   │   └── test_harness/    # SPI test infrastructure
│   └── test/                # UART testbenches
├── scripts/                  # Synthesis automation
│   ├── run_synthesis.sh              # Quick synthesis check
│   └── run_synthesis_and_ppa.sh      # Full PPA analysis
├── docs/                     # Documentation
│   └── SYNTHESIS_AND_PPA_ANALYSIS.md # Synthesis workflow guide
├── submissions/              # DP#1 deliverables
│   ├── README.md            # Submission package overview
│   ├── DESIGN_REPORT.md     # Technical design documentation
│   ├── PPA_ANALYSIS.md      # Power/Performance/Area analysis
│   ├── prompt_logs/         # LLM conversation logs
│   ├── synthesis_reports/   # Yosys and OpenLANE outputs
│   ├── testbench_results/   # Test results and waveforms
│   └── media/               # Diagrams, screenshots, videos
└── synthesis-work/           # Temporary (auto-generated, git-ignored)
```

## Documentation

### UART Peripheral (Phase 1)
-   **[docs/uart/](docs/uart/)** - Complete UART documentation
  - UART_FUNDAMENTALS.md - Beginner-friendly introduction
  - BLOCK_DIAGRAMS.md - Architecture and module interfaces
  - diagrams/ - ASCII art, Mermaid, and timing diagrams

### AES-128 Engine
-   **[docs/aes/](docs/aes/)** - Complete AES documentation
  - AES_FUNDAMENTALS.md - Encryption theory and implementation
  - BLOCK_DIAGRAMS.md - Round functions and data paths
  - diagrams/ - Comprehensive visual documentation

### Secure UART System (Phase 2)
-   **[docs/secure-uart/](docs/secure-uart/)** - Complete system documentation
  - README.md - System overview and integration guide
  - SECURE_UART_FUNDAMENTALS.md - Theory, security analysis, industry comparison
  - BLOCK_DIAGRAMS.md - Complete architecture and signal paths
  - SOFTWARE_GUIDE.md - C driver examples and register API
  - diagrams/ - 500+ lines of ASCII/Mermaid/timing diagrams

### Tools & Submission
-   **[SYNTHESIS_AND_PPA_ANALYSIS.md](docs/SYNTHESIS_AND_PPA_ANALYSIS.md)** - Synthesis workflow guide
-   **[submissions/](submissions/)** - Design reports, PPA analysis, test results

## Development Workflow

1. **Implement** UART functionality in `peripheral/src/peripheral.v`
2. **Test** using testbenches in `peripheral/test/`
3. **Verify** synthesis: `./scripts/run_synthesis.sh`
4. **Iterate** until clean synthesis
5. **Generate PPA metrics**: `./scripts/run_synthesis_and_ppa.sh ~/OpenLane`
6. **Document** in LLM prompt logs

## Key Files to Modify

-   `peripheral/src/peripheral.v` - UART peripheral implementation
-   `peripheral/test/test.py` - UART testbench (optional)
-   Update `tt_wrapper.v` line 41 if changing module name from `tqvp_example`

## Deliverables (DP#1)

-   [ ] Synthesizable UART peripheral RTL
-   [ ] Passing testbenches
-   [ ] Baseline synthesis report (from Yosys)
-   [ ] Baseline PPA report (from OpenLANE)
-   [ ] LLM prompt logs
-   [ ] Design documentation
-   [ ] Git tag: `DP1-Submission`

## Important Notes

### For AI-HDL Competition

-   **Top module**: `tt_um_tqv_peripheral_harness` (from tt_wrapper.v)
-   **Interface**: 32-bit register-based (address, data_in, data_out, data_write_n, data_read_n)
-   **UART pins**: `ui_in[7]` (RX), `uo_out[0]` (TX)
-   **Interrupt**: `user_interrupt` signal for RX ready

### Synthesis Approach

-   Scripts handle flat directory structure automatically
-   All 19 source files included (CPU + peripheral + test harness)
-   Temporary files auto-cleaned after synthesis

## Team Members

-   [Add team member names]

## Timeline

-   **Phase Start**: January 15, 2026
-   **Milestone Review (MR#1)**: January 29, 2026
-   **Submission Deadline**: January 28, 2026

## Resources

-   AI-HDL Website: https://csm.arizona.edu/AIHDL
-   TinyQV Core: https://github.com/TinyTapeout/ttsky25a-tinyQV
-   Peripheral Template: https://github.com/TinyTapeout/tinyqv-full-peripheral-template

---

**For detailed synthesis instructions, see [SYNTHESIS_AND_PPA_ANALYSIS.md](docs/SYNTHESIS_AND_PPA_ANALYSIS.md)**
