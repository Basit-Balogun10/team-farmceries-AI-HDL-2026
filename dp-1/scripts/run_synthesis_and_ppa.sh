#!/bin/bash
# AI-HDL DP#1 Complete Flow: Synthesis + OpenLANE PPA Analysis
# This script runs Yosys synthesis first, then full OpenLANE PPA analysis
#
# Usage: ./run_synthesis_and_ppa.sh <openlane_path> [--cleanup] [--pdk-root <path>]
#
# Required dependencies:
#   - Docker (for OpenLANE container)
#   - Yosys (for synthesis)
#   - Python 3 with venv
#   - OpenLANE installation

set -e

# Parse arguments
CLEANUP=false
OPENLANE_PATH=""
CUSTOM_PDK_ROOT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --cleanup)
            CLEANUP=true
            shift
            ;;
        --pdk-root)
            CUSTOM_PDK_ROOT="$2"
            shift 2
            ;;
        *)
            if [ -z "$OPENLANE_PATH" ]; then
                OPENLANE_PATH="$1"
            fi
            shift
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  AI-HDL DP#1 Complete Synthesis & PPA     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
WORK_DIR="synthesis-work"
OUTPUT_DIR="outputs"
PERIPHERAL_NAME="uart"
TOP_MODULE="tt_um_tqv_peripheral_harness"
OPENLANE_DESIGN_NAME="dp1_${PERIPHERAL_NAME}"

# Set PDK_ROOT (custom flag > env var > default)
if [ -n "$CUSTOM_PDK_ROOT" ]; then
    PDK_ROOT="$CUSTOM_PDK_ROOT"
elif [ -n "${PDK_ROOT:-}" ]; then
    PDK_ROOT="$PDK_ROOT"
else
    PDK_ROOT="$HOME/.ciel"
fi

# Check if OpenLANE path is provided (REQUIRED)
# (already parsed in the argument loop above)

if [ -z "$OPENLANE_PATH" ]; then
    echo -e "${RED}Error: OpenLANE path is required!${NC}"
    echo ""
    echo "Usage:"
    echo "  ./run_synthesis_and_ppa.sh <openlane_path> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --cleanup           Remove temporary files after completion"
    echo "  --pdk-root <path>   Custom PDK root path (default: \$HOME/.ciel)"
    echo ""
    echo "Examples:"
    echo "  ./run_synthesis_and_ppa.sh ~vlsi/tools/OpenLane --cleanup"
    echo "  ./run_synthesis_and_ppa.sh /path/to/OpenLane --pdk-root /custom/pdk"
    echo ""
    echo "For synthesis only (faster, no PPA), use:"
    echo "  ./run_synthesis.sh"
    echo ""
    exit 1
fi

if [ ! -d "$OPENLANE_PATH" ]; then
    echo -e "${RED}Error: OpenLANE directory not found: $OPENLANE_PATH${NC}"
    echo ""
    echo "Please provide a valid path to OpenLANE installation."
    exit 1
fi

echo -e "${GREEN}OpenLANE path: $OPENLANE_PATH${NC}"
echo -e "${GREEN}PDK root: $PDK_ROOT${NC}"
echo -e "${GREEN}Running full synthesis + PPA analysis${NC}"
echo ""

# Step 1: Clean and create working directories
echo -e "${YELLOW}[1/8] Preparing directories...${NC}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}  ✓ Created $WORK_DIR and $OUTPUT_DIR${NC}"

# Step 2: Copy files
echo -e "${YELLOW}[2/8] Copying source files to flat directory...${NC}"
cp peripheral/src/peripheral.v "$WORK_DIR/"
cp peripheral/src/tt_wrapper.v "$WORK_DIR/"
cp peripheral/src/uart/*.v "$WORK_DIR/"
cp peripheral/src/aes/*.v "$WORK_DIR/"
cp peripheral/src/test_harness/*.sv "$WORK_DIR/"
cp cpu/src/*.v "$WORK_DIR/"
echo -e "${GREEN}  ✓ All files copied${NC}"

# Step 3: Generate synthesis script
echo -e "${YELLOW}[3/8] Generating Yosys synthesis script...${NC}"
cat > "$WORK_DIR/synth.ys" << 'SYNTH_SCRIPT'
# Yosys Synthesis Script for AI-HDL DP#1

# Read SystemVerilog test harness files
read_verilog -sv reclocking.sv
read_verilog -sv rising_edge_detector.sv
read_verilog -sv falling_edge_detector.sv
read_verilog -sv spi_reg.sv
read_verilog -sv synchronizer.sv

# Read Verilog core files (bottom-up order is safer)
read_verilog alu.v
read_verilog core.v
read_verilog counter.v
read_verilog cpu.v
read_verilog decode.v
read_verilog latch_reg.v
read_verilog mem_ctrl.v
read_verilog qspi_ctrl.v
read_verilog qspi_flash.v
read_verilog register.v
read_verilog time.v

# Read UART peripheral modules
read_verilog uart_baud_generator.v
read_verilog uart_tx.v
read_verilog uart_rx.v
read_verilog uart_register_interface.v
read_verilog uart_peripheral.v

# Read AES peripheral modules (Phase 2 - in dependency order)
read_verilog -defer aes_sbox.v
read_verilog -defer aes_add_round_key.v
read_verilog -defer aes_shift_rows.v
read_verilog -defer aes_mix_columns.v
read_verilog -defer aes_round.v
read_verilog -defer aes_inv_round.v
read_verilog -defer aes_key_expansion.v
read_verilog -defer aes_core.v
read_verilog -defer aes_uart_streaming.v
read_verilog -defer aes_uart_controller.v
read_verilog -defer secure_uart_peripheral.v

# Read top-level files
read_verilog peripheral.v
read_verilog tinyqv.v
read_verilog tt_wrapper.v

# Synthesize
hierarchy -top tt_um_tqv_peripheral_harness
synth -top tt_um_tqv_peripheral_harness
opt
clean
stat
SYNTH_SCRIPT
echo -e "${GREEN}  ✓ synth.ys created${NC}"

# Step 4: Run Yosys
echo -e "${YELLOW}[4/8] Running Yosys synthesis...${NC}"
cd "$WORK_DIR"
if yosys synth.ys > synthesis.log 2>&1; then
    echo -e "${GREEN}  ✓ Synthesis successful${NC}"
    grep -A 15 "Printing statistics" synthesis.log | head -20
    cp synthesis.log "../$OUTPUT_DIR/synthesis.log"
else
    echo -e "${RED}  ✗ Synthesis failed! Check $OUTPUT_DIR/synthesis.log${NC}"
    cp synthesis.log "../$OUTPUT_DIR/synthesis.log" 2>/dev/null || true
    cd ..
    exit 1
fi
cd ..

# Step 5: Generate OpenLANE config
echo -e "${YELLOW}[5/8] Generating OpenLANE configuration...${NC}"

# Copy and modify the base config from peripheral/src/config.json
# Remove JSON comment entries (keys that are "//") and add our specific fields
python3 << PYTHON_CONFIG
import json

# Load the base config
with open('peripheral/src/config.json', 'r') as f:
    config = json.load(f)

# Remove comment keys
config = {k: v for k, v in config.items() if k != '//'}

# Override/add our specific fields
config['DESIGN_NAME'] = '$TOP_MODULE'

config['VERILOG_FILES'] = [
    'dir::reclocking.sv',
    'dir::synchronizer.sv',
    'dir::rising_edge_detector.sv',
    'dir::falling_edge_detector.sv',
    'dir::spi_reg.sv',
    'dir::alu.v',
    'dir::core.v',
    'dir::decode.v',
    'dir::cpu.v',
    'dir::register.v',
    'dir::latch_reg.v',
    'dir::mem_ctrl.v',
    'dir::qspi_ctrl.v',
    'dir::qspi_flash.v',
    'dir::uart_baud_generator.v',
    'dir::uart_tx.v',
    'dir::uart_rx.v',
    'dir::uart_register_interface.v',
    'dir::uart_peripheral.v',
    'dir::aes_sbox.v',
    'dir::aes_add_round_key.v',
    'dir::aes_shift_rows.v',
    'dir::aes_mix_columns.v',
    'dir::aes_round.v',
    'dir::aes_inv_round.v',
    'dir::aes_key_expansion.v',
    'dir::aes_core.v',
    'dir::aes_uart_streaming.v',
    'dir::aes_uart_controller.v',
    'dir::secure_uart_peripheral.v',
    'dir::peripheral.v',
    'dir::counter.v',
    'dir::time.v',
    'dir::tinyqv.v',
    'dir::tt_wrapper.v'
]
config['DIE_AREA'] = '0 0 161.00 111.52'

# Write to synthesis-work
with open('$WORK_DIR/config.json', 'w') as f:
    json.dump(config, f, indent=2)
PYTHON_CONFIG

echo -e "${GREEN}  ✓ config.json created (using Tiny Tapeout base config)${NC}"

# Step 6: Run OpenLANE PPA analysis
echo -e "${YELLOW}[6/8] Running OpenLANE PPA analysis...${NC}"

# Get absolute paths for mounting and logging
WORK_DIR_ABS="$(cd "$WORK_DIR" && pwd)"
OUTPUT_DIR_ABS="$(mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR" && pwd)"
echo "  Mounting $WORK_DIR_ABS directly into container"
echo "  Starting OpenLANE flow (this may take 5-10 minutes)..."
cd "$OPENLANE_PATH"

# Clean up any old/stopped OpenLANE containers first
echo "  Cleaning up old containers..."
docker stop $(docker ps -aq --filter "ancestor=ghcr.io/the-openroad-project/openlane") 2>/dev/null || true
docker rm $(docker ps -aq --filter "ancestor=ghcr.io/the-openroad-project/openlane") 2>/dev/null || true

# Start fresh container
echo "  Starting new OpenLANE Docker container..."
CONTAINER_ID=$(docker run -d \
    -v "$OPENLANE_PATH:/openlane" \
    -v "$OPENLANE_PATH/designs:/openlane/install" \
    -v "$HOME:$HOME" \
    -v "$PDK_ROOT:$PDK_ROOT" \
    -v "$WORK_DIR_ABS:/openlane/designs/$OPENLANE_DESIGN_NAME" \
    -e PDK_ROOT="$PDK_ROOT" \
    -e PDK="sky130A" \
    --user $(id -u):$(id -g) \
    ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69-amd64 \
    sleep infinity)

if [ -z "$CONTAINER_ID" ]; then
    echo -e "${RED}  ✗ Failed to start Docker container${NC}"
    exit 1
fi

# Run the flow
if docker exec "$CONTAINER_ID" /bin/bash -c "cd /openlane && ./flow.tcl -design $OPENLANE_DESIGN_NAME" 2>&1 | tee openlane.log; then
    echo -e "${GREEN}  ✓ OpenLANE completed successfully${NC}"
    FLOW_SUCCESS=true
else
    echo -e "${RED}  ✗ OpenLANE flow failed${NC}"
    echo "  Last 50 lines of openlane.log:"
    tail -50 openlane.log
    FLOW_SUCCESS=false
fi

# Always clean up container when done
echo "  Cleaning up container..."
docker stop "$CONTAINER_ID" > /dev/null 2>&1
docker rm "$CONTAINER_ID" > /dev/null 2>&1

if [ "$FLOW_SUCCESS" = false ]; then
    cd "$SCRIPT_DIR"
    exit 1
fi
    
    # Find latest run (now in synthesis-work/runs/ due to direct mount)
    LATEST_RUN=$(ls -t "$WORK_DIR_ABS/runs" 2>/dev/null | head -1)
    echo ""
    echo "  Latest run: $LATEST_RUN"
    
    # Display key metrics
    if [ -f "$WORK_DIR_ABS/runs/$LATEST_RUN/reports/metrics.csv" ]; then
        echo ""
        echo -e "${BLUE}=== Key PPA Metrics ===${NC}"
        python3 -c "
import csv
with open('$WORK_DIR_ABS/runs/$LATEST_RUN/reports/metrics.csv', 'r') as f:
    reader = csv.DictReader(f)
    row = next(reader)
    print(f'  Area: {row.get(\"DIEAREA_mm^2\", \"N/A\")} mm²')
    print(f'  WNS:  {row.get(\"wns\", \"N/A\")} ns (Worst Negative Slack)')
    print(f'  TNS:  {row.get(\"tns\", \"N/A\")} ns (Total Negative Slack)')
    # Calculate total power from components
    pi = row.get('power_typical_internal_uW', '-1')
    ps = row.get('power_typical_switching_uW', '-1')
    pl = row.get('power_typical_leakage_uW', '-1')
    if pi not in ['-1', '', 'N/A']:
        total_uw = float(pi) + float(ps) + float(pl)
        print(f'  Power: {total_uw:.6f} µW ({total_uw/1000:.9f} mW)')
    else:
        print(f'  Power: N/A')
" 2>/dev/null || echo "  (Could not parse metrics)"
    fi
    
    # Save logs to outputs
    cp openlane.log "$OUTPUT_DIR_ABS/" 2>/dev/null || true
    
    FLOW_SUCCESS=true
else
    echo -e "${RED}  ✗ OpenLANE failed! Check $OUTPUT_DIR/openlane.log${NC}"
    cp openlane.log "$OUTPUT_DIR_ABS/" 2>/dev/null || true
    # Stop container if we started it
    if [ "$STARTED_CONTAINER" = true ]; then
        docker stop "$CONTAINER_ID" > /dev/null 2>&1
    fi
    FLOW_SUCCESS=false
fi
cd - > /dev/null

# Step 7: Copy results back to working directory
if [ "$FLOW_SUCCESS" = true ]; then
    echo -e "${YELLOW}[7/8] Moving results to runs/ directory...${NC}"
    mkdir -p "runs"
    # Move all runs from synthesis-work to dp-1/runs (keeps history)
    if [ -d "$WORK_DIR/runs" ]; then
        mv "$WORK_DIR/runs/"* "runs/" 2>/dev/null || true
        echo -e "${GREEN}  ✓ Results moved to runs/$LATEST_RUN${NC}"
        echo "  All runs preserved in: runs/"
    fi
fi

# Step 8: Cleanup
echo -e "${YELLOW}[8/8] Cleanup...${NC}"
if [ "$CLEANUP" = true ]; then
    rm -rf "$WORK_DIR"
    echo -e "${GREEN}  ✓ Temporary files removed${NC}"
else
    echo -e "${YELLOW}  Keeping $WORK_DIR for review${NC}"
    echo -e "${YELLOW}  (Use --cleanup flag to auto-remove)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Synthesis & PPA Analysis Complete!    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
if [ "$FLOW_SUCCESS" = true ]; then
    echo "Results saved to:"
    echo "  - Logs: $OUTPUT_DIR/ (synthesis.log, openlane.log)"
    echo "  - Full run: runs/$LATEST_RUN/"
    echo ""
    echo "Next steps:"
    echo "  1. Review PPA metrics above"
    echo "  2. Check detailed reports in: runs/$LATEST_RUN/reports/"
    echo "  3. View GDSII layout:"
    echo "     klayout runs/$LATEST_RUN/results/final/gds/*.gds"
    echo "  4. Review timing reports if WNS is negative"
else
    echo "Logs saved to: $OUTPUT_DIR/"
fi
echo ""
