# UART Peripheral Modules

This directory contains the Verilog RTL for the UART peripheral implementation.

## Module Structure

```
uart/
├── uart_baud_generator.v      - Baud rate timing generation
├── uart_tx.v                   - Transmitter (parallel to serial)
├── uart_rx.v                   - Receiver (serial to parallel)
├── uart_register_interface.v  - CPU memory-mapped registers
├── uart_peripheral.v           - Top-level integration
└── lint.sh                     - Verilator linting script
```

## Quick Start

```bash
# Lint all modules
./lint.sh

# Or use the Makefile in parent directory
cd ..
make lint
```

## Implementation Order

According to [PROJECT_PLAN.md](../../../docs/PROJECT_PLAN.md):

1. **Phase 2** (Jan 20): Baud Rate Generator
2. **Phase 3** (Jan 21): UART Transmitter  
3. **Phase 4** (Jan 22): UART Receiver
4. **Phase 5** (Jan 23): Register Interface
5. **Phase 6** (Jan 24): Top-level Integration

## Coding Guidelines

- **Always lint** before committing
- Use **non-blocking assignments** (`<=`) for sequential logic
- Use **blocking assignments** (`=`) for combinational logic
- **Complete all case statements** (add default clause)
- **Assign all outputs** in all branches (avoid latches)
- Follow TinyQV naming conventions (matching cpu/ modules)

## Module Specifications

Each module has detailed specifications in:
- [UART_FUNDAMENTALS.md](../../../docs/UART_FUNDAMENTALS.md)
- [BLOCK_DIAGRAMS.md](../../../docs/BLOCK_DIAGRAMS.md)

## Testing

Tests are located in `../../../dp-1/peripheral/test/`:
- `test_baud_gen.py` - Baud rate generator tests
- `test_uart_tx.py` - Transmitter tests
- `test_uart_rx.py` - Receiver tests
- etc.

See [WORKFLOW.md](../WORKFLOW.md) for the complete development workflow.
