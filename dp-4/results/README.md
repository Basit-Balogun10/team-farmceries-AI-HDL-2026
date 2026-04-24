# DP-4 Results

This folder stores run outputs for DP-4.

Recommended structure:
- `RUN_<timestamp>/`
  - `RUN_ID.txt`
  - `metrics.csv`
  - `SUMMARY.md`
  - `manufacturability.rpt`
  - `openlane_flow.log.txt`
  - `command.txt`

The wrapper script `dp-4/scripts/run_dp4_tapeout.sh` creates this structure automatically from `dp-1/runs/latest`.
