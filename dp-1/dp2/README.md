# DP-2 Workspace: Design Evaluation and PPA Optimization

This directory tracks all DP-2 planning, experiments, and reports for the Secure UART design.

## Scope

- Baseline: DP-1 secure run configuration used as the DP-2 starting point.
- Optimization targets:
  - Improve timing headroom (WNS/TNS).
  - Reduce power and switching where possible.
  - Keep area growth bounded and justified.

## Contents

- reports/OPTIMIZATION_PLAN.md
- reports/OPTIMIZATION_REPORT.md
- reports/BEFORE_AFTER_PPA.md
- logs/REGRESSION_RESULTS.md
- results/ (captured experiment metrics)

## Automation

- scripts/run_dp2_experiments.sh: executes baseline and candidate OpenLANE runs, then generates before/after report.
- scripts/dp2_compare_metrics.py: compares two metrics.csv files and renders markdown summary.
