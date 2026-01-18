#!/bin/bash
# AI-HDL DP#1 Complete Flow: Synthesis + OpenLANE PPA Analysis
# This script automates the entire process including OpenLANE

set -e

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
PERIPHERAL_NAME="uart"
TOP_MODULE="tt_um_tqv_peripheral_harness"
OPENLANE_DESIGN_NAME="dp1_${PERIPHERAL_NAME}"

# Check if OpenLANE path is provided (REQUIRED)
OPENLANE_PATH="${1:-}"

if [ -z "$OPENLANE_PATH" ]; then
    echo -e "${RED}Error: OpenLANE path is required!${NC}"
    echo ""
    echo "Usage:"
    echo "  ./run_synthesis_and_ppa.sh /path/to/OpenLane"
    echo ""
    echo "Example:"
    echo "  ./run_synthesis_and_ppa.sh ~/OpenLane"
    echo ""
    echo "For synthesis only (without PPA), use:"
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
echo -e "${GREEN}Running full synthesis + PPA analysis${NC}"
echo ""

# Step 1: Clean and create working directory
echo -e "${YELLOW}[1/7] Preparing working directory...${NC}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
echo -e "${GREEN}  ✓ Created $WORK_DIR${NC}"

# Step 2: Copy files
echo -e "${YELLOW}[2/7] Copying source files to flat directory...${NC}"
cp peripheral/src/peripheral.v "$WORK_DIR/"
cp peripheral/src/tt_wrapper.v "$WORK_DIR/"
cp peripheral/src/test_harness/*.sv "$WORK_DIR/"
cp cpu/src/*.v "$WORK_DIR/"
echo -e "${GREEN}  ✓ All files copied${NC}"

# Step 3: Generate synthesis script
echo -e "${YELLOW}[3/7] Generating Yosys synthesis script...${NC}"
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
echo -e "${YELLOW}[4/7] Running Yosys synthesis...${NC}"
cd "$WORK_DIR"
if yosys synth.ys > synthesis.log 2>&1; then
    echo -e "${GREEN}  ✓ Synthesis successful${NC}"
    grep -A 15 "Printing statistics" synthesis.log | head -20
else
    echo -e "${RED}  ✗ Synthesis failed! Check synthesis.log${NC}"
    cd ..
    exit 1
fi
cd ..

# Step 5: Generate OpenLANE config
echo -e "${YELLOW}[5/7] Generating OpenLANE configuration...${NC}"
cat > "$WORK_DIR/config.json" << OPENLANE_CONFIG
{
  "DESIGN_NAME": "$TOP_MODULE",
  "VERILOG_FILES": [
    "dir::reclocking.sv",
    "dir::synchronizer.sv",
    "dir::rising_edge_detector.sv",
    "dir::falling_edge_detector.sv",
    "dir::spi_reg.sv",
    "dir::alu.v",
    "dir::core.v",
    "dir::decode.v",
    "dir::cpu.v",
    "dir::register.v",
    "dir::latch_reg.v",
    "dir::mem_ctrl.v",
    "dir::qspi_ctrl.v",
    "dir::qspi_flash.v",
    "dir::peripheral.v",
    "dir::counter.v",
    "dir::time.v",
    "dir::tinyqv.v",
    "dir::tt_wrapper.v"
  ],
  "CLOCK_PERIOD": 20.0,
  "CLOCK_PORT": "clk",
  "CLOCK_NET": "clk",
  "FP_SIZING": "absolute",
  "DIE_AREA": "0 0 161.00 111.52",
  "PL_TARGET_DENSITY": 0.75
}
OPENLANE_CONFIG
echo -e "${GREEN}  ✓ config.json created${NC}"

# Step 6: Run OpenLANE PPA analysis
echo -e "${YELLOW}[6/7] Running OpenLANE PPA analysis...${NC}"

# Copy to OpenLANE designs directory
OPENLANE_DESIGN_PATH="$OPENLANE_PATH/designs/$OPENLANE_DESIGN_NAME"
echo "  Copying to $OPENLANE_DESIGN_PATH"
rm -rf "$OPENLANE_DESIGN_PATH"
cp -r "$WORK_DIR" "$OPENLANE_DESIGN_PATH"

# Run OpenLANE
echo "  Starting OpenLANE flow (this may take 5-10 minutes)..."
cd "$OPENLANE_PATH"

# Run in Docker
if docker run --rm -v "$(pwd)":/openlane -v "$(pwd)/designs:/openlane/designs" \
    efabless/openlane:latest /bin/bash -c \
    "cd /openlane && ./flow.tcl -design $OPENLANE_DESIGN_NAME" > openlane.log 2>&1; then
    echo -e "${GREEN}  ✓ OpenLANE completed successfully${NC}"
    
    # Find latest run
    LATEST_RUN=$(ls -t "$OPENLANE_DESIGN_PATH/runs" | head -1)
    echo ""
    echo "  Results in: $OPENLANE_DESIGN_PATH/runs/$LATEST_RUN"
    
    # Display key metrics
    if [ -f "$OPENLANE_DESIGN_PATH/runs/$LATEST_RUN/reports/metrics.csv" ]; then
        echo ""
        echo -e "${BLUE}=== Key PPA Metrics ===${NC}"
        python3 -c "
import csv
with open('$OPENLANE_DESIGN_PATH/runs/$LATEST_RUN/reports/metrics.csv', 'r') as f:
    reader = csv.DictReader(f)
    row = next(reader)
    print(f'  Area: {row.get(\"DIEAREA_mm^2\", \"N/A\")} mm²')
    print(f'  WNS:  {row.get(\"wns\", \"N/A\")} ns')
    print(f'  TNS:  {row.get(\"tns\", \"N/A\")} ns')
    print(f'  Power: {row.get(\"Total_Power\", \"N/A\")} mW')
" 2>/dev/null || echo "  (Could not parse metrics)"
    fi
else
    echo -e "${RED}  ✗ OpenLANE failed! Check openlane.log${NC}"
fi
cd - > /dev/null

# Step 7: Cleanup
echo -e "${YELLOW}[7/7] Cleanup...${NC}"
echo ""
read -p "Remove temporary $WORK_DIR directory? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$WORK_DIR"
    echo -e "${GREEN}  ✓ Temporary files removed${NC}"
else
    echo -e "${YELLOW}  Keeping $WORK_DIR for review${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Synthesis & PPA Analysis Complete!    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Review PPA metrics above"
echo "  2. Check detailed reports in: $OPENLANE_DESIGN_PATH/runs/"
echo "  3. View GDSII layout:"
echo "     klayout $OPENLANE_DESIGN_PATH/runs/*/results/final/gds/*.gds"
echo "  4. Review timing reports if WNS is negative"
echo ""
