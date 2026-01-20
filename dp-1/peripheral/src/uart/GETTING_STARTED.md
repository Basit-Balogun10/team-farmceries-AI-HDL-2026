# UART Development - Getting Started

## ✅ Setup Complete!

Your development environment is ready with:
- ✓ Verilator 5.020 (linting)
- ✓ Cocotb + Icarus Verilog (testing)
- ✓ Complete documentation (UART_FUNDAMENTALS.md, PROJECT_PLAN.md, diagrams)
- ✓ Workflow automation (Makefile, lint.sh)

## Quick Command Reference

### Linting (Run Before Every Commit!)
```bash
cd dp-1/peripheral/src
make lint
```

### Testing (Once Modules Exist)
```bash
cd dp-1/peripheral/test
make -f test_baud_gen.mk
```

### Development Cycle
```bash
# 1. Edit module
vim uart/uart_baud_generator.v

# 2. Lint
make lint

# 3. Test
cd ../test && make -f test_baud_gen.mk

# 4. Debug, iterate, repeat
```

## What to Build (In Order)

According to [PROJECT_PLAN.md](../../docs/PROJECT_PLAN.md):

### Phase 2 - TODAY (Jan 20): Baud Rate Generator ⏰
```
File: uart/uart_baud_generator.v
Test: test/test_baud_gen.py + test_baud_gen.mk

Inputs:  clk, rst_n, baud_sel[3:0], enable
Outputs: baud_tick (1 cycle pulse)

Function: Divide 70 MHz clock → baud rate pulses
```

### Phase 3 - Tomorrow (Jan 21): UART Transmitter 📤
```
File: uart/uart_tx.v
Test: test/test_uart_tx.py

Inputs:  clk, rst_n, baud_tick, tx_data[7:0], tx_start
Outputs: tx_out (serial), tx_busy

Function: Parallel byte → serial bits (LSB first)
```

### Phase 4 - Jan 22: UART Receiver 📥
```
File: uart/uart_rx.v
Test: test/test_uart_rx.py

Inputs:  clk, rst_n, baud_tick, rx_in (serial)
Outputs: rx_data[7:0], rx_ready, rx_error

Function: Serial bits → parallel byte (with error detection)
```

### Phase 5 - Jan 23: Register Interface 🎛️
```
File: uart/uart_register_interface.v
Test: test/test_registers.py

Inputs:  CPU bus (address, data_in, write_n, read_n)
Outputs: data_out, control signals

Function: Memory-mapped registers for CPU control
```

### Phase 6 - Jan 24: Integration 🔗
```
File: uart/uart_peripheral.v
Test: test/test_uart_full.py

Function: Connect all modules together
```

## Resources at Your Fingertips

📚 **Documentation**:
- [UART_FUNDAMENTALS.md](../../docs/UART_FUNDAMENTALS.md) - Everything about UART protocol
- [PROJECT_PLAN.md](../../docs/PROJECT_PLAN.md) - Day-by-day implementation schedule
- [WORKFLOW.md](WORKFLOW.md) - Development workflow details
- [diagrams/](../../docs/diagrams/) - Visual references (Mermaid, ASCII, timing)

🔧 **Tools**:
- Verilator linting: `make lint`
- Cocotb testing: `make test-all` (when tests exist)
- Waveform viewing: GTKWave (for .vcd files)

## Ready to Start?

Let me know when you're ready to begin Phase 2 (Baud Rate Generator)!

I'll help you:
1. Write the Verilog module
2. Create the cocotb test
3. Lint and debug
4. Verify it works

Then we'll move to Phase 3, 4, 5, and 6 in sequence.

**Let's build this UART! 🚀**
