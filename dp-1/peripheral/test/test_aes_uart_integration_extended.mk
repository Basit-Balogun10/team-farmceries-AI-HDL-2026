# Extended AES-UART Integration Tests Makefile

SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../src/aes/aes_sbox.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_shift_rows.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_mix_columns.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_add_round_key.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_key_expansion.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_round.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_core.v
VERILOG_SOURCES += $(PWD)/../src/aes/aes_uart_controller.v

TOPLEVEL = aes_uart_controller
MODULE = test_aes_uart_integration_extended

include $(shell cocotb-config --makefiles)/Makefile.sim
