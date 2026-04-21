# DP-2 Regression Results

## Test Matrix

1. RTL lint/synthesis sanity
- Command: ./scripts/run_synthesis.sh --cleanup
- Result: PASS
- Notes: Yosys synthesis completed successfully on updated RTL.

2. Secure UART cocotb tests
- Command: source ../../venv/bin/activate && make -f test_secure_uart.mk
- Result: PASS (5/5)
- Notes: Bypass mode, key configuration, encrypted transmission, loopback configuration, and mode-switch tests all passed.

3. Full synthesis and PPA flow
- Baseline attempt (default floorplan): FAIL
	- Run: RUN_2026.04.21_13.13.12
	- Failure: Global placement utilization > 100% (GPL-0301)
- Tuned run A: PASS
	- Command: ./scripts/run_synthesis_and_ppa.sh <OpenLane> --aes-block-bytes 1 --die-area "0 0 320.00 240.00" --pl-target-density 0.70 --cleanup
	- Run: RUN_2026.04.21_13.14.49
- Tuned run B: PASS
	- Command: ./scripts/run_synthesis_and_ppa.sh <OpenLane> --aes-block-bytes 1 --die-area "0 0 320.00 240.00" --pl-target-density 0.60 --cleanup
	- Run: RUN_2026.04.21_13.25.50

## Notes

- Before/after DP-2 comparison generated at reports/BEFORE_AFTER_PPA.md.
- The optimization point selected in report is density 0.70 versus 0.60 at fixed die area.
