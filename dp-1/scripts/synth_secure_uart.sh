#!/bin/bash
# Synthesis script for secure_uart_peripheral module
# Synthesizes just the Secure UART peripheral (not full chip wrapper)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Secure UART Peripheral - Synthesis      ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

WORK_DIR="synthesis-work-secure-uart"
OUTPUT_DIR="synthesis_outputs"

# Clean previous run
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Removing previous synthesis directory...${NC}"
    rm -rf "$WORK_DIR"
fi
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[1/4] Copying source files...${NC}"

# Copy all Verilog files to flat directory
cp ../peripheral/src/uart/*.v "$WORK_DIR/"
cp ../peripheral/src/aes/*.v "$WORK_DIR/"
# secure_uart_peripheral.v is already in aes/ directory, so it's copied above

echo "  ✓ Copied UART, AES modules, and secure_uart_peripheral"

echo -e "${GREEN}[2/4] Generating Yosys synthesis script...${NC}"

cat > "$WORK_DIR/synth_secure_uart.ys" << 'EOF'
# Yosys synthesis script for secure_uart_peripheral

# Read all UART modules
read_verilog uart_baud_generator.v
read_verilog uart_tx.v
read_verilog uart_rx.v
read_verilog uart_register_interface.v
read_verilog uart_peripheral.v

# Read all AES modules (in dependency order)
read_verilog aes_sbox.v
read_verilog aes_add_round_key.v
read_verilog aes_shift_rows.v
read_verilog aes_mix_columns.v
read_verilog aes_round.v
read_verilog aes_inv_round.v
read_verilog aes_key_expansion.v
read_verilog aes_core.v
read_verilog aes_uart_streaming.v
read_verilog aes_uart_controller.v

# Read top-level secure UART peripheral
read_verilog secure_uart_peripheral.v

# Synthesize with autoflatten to handle unpacked arrays
hierarchy -top secure_uart_peripheral -auto-top
synth -top secure_uart_peripheral -auto-top -flatten

# Optimize and report
opt
clean
stat

# Write netlist
write_verilog synth_netlist.v
EOF

echo "  ✓ Created synthesis script"

echo -e "${GREEN}[3/4] Running Yosys synthesis...${NC}"
echo ""

cd "$WORK_DIR"

if yosys synth_secure_uart.ys > synthesis.log 2>&1; then
    echo -e "${GREEN}  ✓ Synthesis completed successfully!${NC}"
    echo ""
    echo "═══ Synthesis Statistics ═══"
    grep -A 30 "Printing statistics" synthesis.log | head -40
    echo ""
else
    echo -e "${RED}  ✗ Synthesis failed!${NC}"
    echo "Check $WORK_DIR/synthesis.log for details"
    tail -50 synthesis.log
    cd ..
    exit 1
fi

cd ..

echo -e "${GREEN}[4/4] Copying outputs...${NC}"

cp "$WORK_DIR/synthesis.log" "$OUTPUT_DIR/secure_uart_synthesis.log"
cp "$WORK_DIR/synth_netlist.v" "$OUTPUT_DIR/secure_uart_netlist.v"

echo "  ✓ Outputs saved to $OUTPUT_DIR/"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}Synthesis Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo "Results:"
echo "  - Synthesis log: $OUTPUT_DIR/secure_uart_synthesis.log"
echo "  - Gate netlist:  $OUTPUT_DIR/secure_uart_netlist.v"
echo ""
echo "Key metrics:"
grep "Number of cells:" "$WORK_DIR/synthesis.log" | head -1
grep "secure_uart_peripheral" "$WORK_DIR/synthesis.log" | grep "Number of wires" | head -1
echo ""
