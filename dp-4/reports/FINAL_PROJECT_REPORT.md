# Final Project Report (DP1 to DP4)

## 1. Executive Summary
This project implemented and hardened a TinyQV-based peripheral subsystem and carried the design from RTL through physical implementation and sign-off.

The DP4 objective was to generate a manufacturable layout package with reproducible OpenLANE runs and complete sign-off evidence.

Outcome: a full DP4 package was produced with final GDS, gate-level netlists, constraints, DRC/LVS reports, STA reports, and measured PPA artifacts.

## 2. Timeline and Milestones
- DP1: baseline synthesis flow and first physical implementation path established.
- DP2: optimization workflow and measured PPA comparison infrastructure added.
- DP3: security hardening integrated and validated with measured hardened metrics.
- DP4: full netlist-to-chip package assembled with sign-off reports and reproducible run capture.

## 3. Architecture and Security Design
The design integrates a TinyQV-oriented peripheral harness centered on secure UART streaming and SPI-facing logic. The DP3 hardening changes were preserved into DP4 implementation.

Security-oriented behaviors include bounded configuration behavior and hardened control paths introduced during DP3. DP4 focused on preserving those semantics through physical implementation without functional regressions in sign-off timing checks.

## 4. Physical Design Flow (DP4)
Flow execution used OpenLANE through the wrapper script at dp-4/scripts/run_dp4_tapeout.sh, which invokes dp-1/scripts/run_synthesis_and_ppa.sh and snapshots outputs into DP4 folders.

Final selected run:
- Run ID: RUN_2026.04.24_00.19.16
- AES block mode: 1 byte
- DIE_AREA: 0 0 320.00 240.00
- PL_TARGET_DENSITY: 0.61

Additional closure sweeps were executed with relaxed floorplan and density settings, then discarded from final package to keep a single canonical final run.

## 5. Sign-off Results
- DRC: clean (COUNT: 0)
- LVS: clean (Total errors = 0)
- STA summary: tns 0.00, wns 0.00, worst setup slack 4.44, worst hold slack 0.31

Observed warning class:
- max fanout violations in the STA checks report

Rationale: these do not appear as setup/hold timing violations in the final STA summary and did not block DRC/LVS-clean completion.

## 6. Final PPA Metrics
From dp-4/results/RUN_2026.04.24_00.19.16/metrics.csv:
- DIEAREA_mm^2: 0.0768
- synth_cell_count: 3594
- wns: -10.13
- tns: -8908.4
- power_typical_total_uW: 0.008380027

Note: OpenLANE metrics.csv timing fields differ from final sign-off STA summary reports. Submission timing conclusions are taken from sign-off STA reports in dp-4/signoff.

## 7. Challenges and Trade-offs
Primary challenge: placement-density sensitivity and convergence constraints under reduced-resource hardened configuration.

Trade-off: preserving the proven low-resource DP3-hardened mode (AES block bytes = 1) prioritized reproducibility against larger-floorplan variants that did not improve sign-off quality.

## 8. Final Tapeout Package
- Final GDS: dp-4/gds/RUN_2026.04.24_00.19.16_tt_um_tqv_peripheral_harness.gds
- Final netlists:
	- dp-4/netlist/RUN_2026.04.24_00.19.16_tt_um_tqv_peripheral_harness.v
	- dp-4/netlist/RUN_2026.04.24_00.19.16_tt_um_tqv_peripheral_harness.nl.v
- Final constraints:
	- dp-4/constraints/RUN_2026.04.24_00.19.16_tt_um_tqv_peripheral_harness.sdc
- Final sign-off reports:
	- dp-4/signoff/RUN_2026.04.24_00.19.16_drc.rpt
	- dp-4/signoff/RUN_2026.04.24_00.19.16_lvs.rpt
	- dp-4/signoff/RUN_2026.04.24_00.19.16_sta_summary.rpt
	- dp-4/signoff/RUN_2026.04.24_00.19.16_sta_checks.rpt

## 9. Lessons Learned
- Use scriptable run capture for every physical iteration; it prevents missing submission artifacts.
- Separate sign-off interpretation from raw metrics.csv fields to avoid timing misreads.
- Keep one canonical final run for submission clarity; archive exploratory runs only when needed.

## 10. Appendix
Reproducible final command:

./scripts/run_dp4_tapeout.sh /home/abdulbasit/electrical-and-electronics-engineering/VLSI/tools/OpenLane --aes-block-bytes 1 --die-area "0 0 320.00 240.00" --pl-target-density 0.61 --cleanup
