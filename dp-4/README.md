# DP-4: Netlist to Chip Tapeout

This folder is the fresh start for Design Phase 4.

## Goal
Produce a manufacturable submission package:
- Final GDSII
- Clean DRC/LVS/STA sign-off reports
- Final comprehensive project report (DP1 to DP4)
- Git tag: DP4-Submission

## Folder Layout
- `scripts/`: execution helpers
- `results/`: run outputs and copied OpenLANE metrics
- `reports/`: final writeups and summaries
- `signoff/`: DRC/LVS/STA reports and check logs
- `netlist/`: final gate-level netlists
- `gds/`: final GDSII
- `constraints/`: SDC and other constraints

## Quick Start
1. Run the DP-4 wrapper:

```bash
cd dp-4
./scripts/run_dp4_tapeout.sh /ABSOLUTE/PATH/TO/OpenLane
```

2. Review artifacts in `dp-4/results/`.
3. Populate signoff reports in `dp-4/signoff/`.
4. Update final report in `dp-4/reports/FINAL_PROJECT_REPORT.md`.
5. Complete checklist in `dp-4/CHECKLIST.md`.

## Notes
- The wrapper currently uses the proven low-resource settings from the DP-3 hardened run as defaults.
- You can override settings through flags documented in `scripts/run_dp4_tapeout.sh`.
