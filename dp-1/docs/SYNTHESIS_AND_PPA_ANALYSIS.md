# DP-1 Synthesis & PPA Analysis

Automated scripts for running synthesis and PPA (Power, Performance, Area) analysis for AI-HDL Design Phase 1.

## Directory Structure

```
dp-1/
├── cpu/                       # CPU core files (reference)
├── peripheral/                # UART peripheral implementation
│   ├── src/                  # Source files
│   │   ├── peripheral.v      # UART peripheral module
│   │   ├── tt_wrapper.v      # Test wrapper (top module)
│   │   └── test_harness/     # SPI test infrastructure
│   └── test/                 # Python testbenches
├── scripts/                   # Synthesis automation scripts
│   ├── run_synthesis.sh      # Yosys synthesis only
│   └── run_synthesis_and_ppa.sh  # Full synthesis + OpenLANE PPA
└── synthesis-work/            # Temporary directory (auto-created)
```

## Available Scripts

### 1. `scripts/run_synthesis.sh` - Quick Synthesis Verification

**Purpose:** Run Yosys synthesis to verify design correctness

**Usage:**
```bash
cd dp-1
./scripts/run_synthesis.sh
```

**Process:**
1. Creates temporary `synthesis-work/` directory
2. Copies all source files to flat structure (19 files total)
3. Generates `synth.ys` script with proper file ordering
4. Runs Yosys synthesis
5. Displays synthesis statistics
6. Prompts for cleanup of temporary files

**When to use:** During development after modifying peripheral.v to check for syntax/logic errors

---

### 2. `scripts/run_synthesis_and_ppa.sh` - Full PPA Analysis

**Purpose:** Run complete synthesis and OpenLANE physical design flow for PPA metrics

**Usage:**
```bash
cd dp-1
./scripts/run_synthesis_and_ppa.sh /path/to/OpenLane
```

**Example:**
```bash
./scripts/run_synthesis_and_ppa.sh ~/OpenLane
./scripts/run_synthesis_and_ppa.sh ~/tools/OpenLane
```

**Process:**
1. Runs Yosys synthesis (same as script 1)
2. Generates OpenLANE `config.json` with all source files
3. Copies design to `OpenLane/designs/dp1_uart/`
4. Executes full OpenLANE flow in Docker (5-10 minutes)
5. Displays PPA metrics: Area, WNS/TNS, Power
6. Prompts for cleanup of temporary files

**When to use:** Before DP#1 submission to generate baseline PPA reports

**Requirements:** 
- OpenLANE installation path (mandatory argument)
- Docker installed and running
- For synthesis-only verification, use script 1 instead

---

## Recommended Workflow

### Development Iteration

1. **Edit** the peripheral implementation: `peripheral/src/peripheral.v`
2. **Run testbenches** (if available): `cd peripheral/test && make`
3. **Verify synthesis**: `./scripts/run_synthesis.sh`
4. **Fix errors** and repeat until synthesis passes cleanly

### Pre-Submission

1. **Run full PPA analysis**: `./scripts/run_synthesis_and_ppa.sh ~/OpenLane`
2. **Review PPA metrics** displayed in terminal output
3. **Check timing**: Ensure WNS (Worst Negative Slack) is positive
4. **View GDSII layout**: `klayout ~/OpenLane/designs/dp1_uart/runs/*/results/final/gds/*.gds`
5. **Save prompt logs** documenting design decisions
6. **Tag for submission**: `git tag DP1-Submission && git push --tags`

---

## File Organization Strategy

### The Challenge
Synthesis tools (Yosys/OpenLANE) expect a flat directory structure, but development benefits from organized hierarchical structure.

### The Solution
Scripts automatically handle file organization:

```
DEVELOPMENT (organized)          SYNTHESIS (flat, temporary)
dp-1/                            synthesis-work/
├── peripheral/src/              ├── peripheral.v
│   ├── peripheral.v      ─────▶ ├── tt_wrapper.v
│   ├── tt_wrapper.v      ─────▶ ├── synchronizer.sv
│   └── test_harness/     ─────▶ ├── spi_reg.sv
│       └── *.sv                 ├── (all harness files)
└── cpu/src/              ─────▶ ├── alu.v
    └── *.v                      ├── core.v
                                 └── (all CPU files)
                                 
                                 [Synthesis runs here]
                                 [Cleanup after completion]
```

### Key Features
- **Organized source structure** remains unchanged
- **Temporary flat copy** created automatically for synthesis
- **Auto-cleanup** option after synthesis completes
- **Git-ignored** temporary directory (no repository pollution)

---

## Troubleshooting

### Synthesis Failures

**Error: Synthesis failed**
- **Log location**: `synthesis-work/synthesis.log`
- **Common causes**: Missing semicolons, undefined modules, syntax errors
- **Action**: Review ERROR lines in log, fix Verilog syntax

### OpenLANE/PPA Failures

**Error: Timing violations (negative WNS)**
- **Cause**: Design cannot meet target clock frequency
- **Solution**: Increase `CLOCK_PERIOD` in generated config.json
- **Example**: Change from 20.0 to 25.0 (slower clock = easier timing)

**Error: OpenLANE flow failed**
- **Log location**: Check openlane.log in OpenLANE directory
- **Action**: Review error messages, check Docker is running

### Path/File Issues

**Error: Can't find source files**
- **Requirement**: Scripts must be run from `dp-1/` directory
- **Verify**: `peripheral/src/` and `cpu/src/` directories exist
- **Command**: `ls -la cpu/src/ peripheral/src/`

---

## Script Configuration

To customize for different peripherals, edit the configuration variables in both scripts:

```bash
# Location: scripts/run_synthesis.sh and scripts/run_synthesis_and_ppa.sh
# Lines: ~17-19

PERIPHERAL_NAME="uart"                    # Peripheral identifier
TOP_MODULE="tt_um_tqv_peripheral_harness" # Top module name from tt_wrapper.v
```

## Files Included in Synthesis

Based on the AI-HDL DP#1 example, these files are included:

**Test Harness (SystemVerilog):**
- reclocking.sv
- rising_edge_detector.sv
- falling_edge_detector.sv
- spi_reg.sv
- synchronizer.sv

**CPU Core (Verilog):**
- alu.v
- core.v
- counter.v
- cpu.v
- decode.v
- latch_reg.v
- mem_ctrl.v
- qspi_ctrl.v
- qspi_flash.v
- register.v
- time.v
- tinyqv.v

**Your Design:**
- peripheral.v (YOUR UART implementation)
- tt_wrapper.v (test wrapper/top module)

---

## Reset/Clean Environment

To start fresh after errors or testing:

```bash
# Remove temporary synthesis files
rm -rf synthesis-work/

# Remove OpenLANE design files (if PPA was run)
rm -rf ~/OpenLane/designs/dp1_uart/

# Verify clean state
git status

# Run synthesis again
./scripts/run_synthesis.sh
```
