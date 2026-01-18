# PPA Analysis Report - UART Peripheral

**Team**: Farmceries  
**Design Phase**: 1  
**Analysis Date**: [TO BE FILLED]

---

## Executive Summary

This document presents the Power, Performance, and Area (PPA) analysis of our UART peripheral implementation.

**Key Metrics**:
- **Area**: [TO BE FILLED] μm²
- **Timing**: WNS = [TO BE FILLED] ns (✓/✗ MET/VIOLATED)
- **Power**: [TO BE FILLED] mW

---

## 1. Area Analysis

### 1.1 Synthesis Results

**Tool**: Yosys  
**Technology**: SkyWater 130nm

```
[TO BE FILLED - Paste Yosys statistics output]

Cell Count:
  Total cells: XXX
  Flip-flops: XXX
  Combinational: XXX
  
Cell Breakdown:
  AND gates: XXX
  OR gates: XXX
  MUX: XXX
  [etc.]
```

### 1.2 Physical Design Results

**Tool**: OpenLANE  
**Die Area**: [TO BE FILLED] μm²

```
[TO BE FILLED - Paste OpenLANE area report]

Utilization: XX%
Standard cells: XXX
Macro cells: XXX
```

### 1.3 Area Breakdown by Module

| Module | Cell Count | Percentage | Notes |
|--------|-----------|------------|-------|
| Baud Rate Gen | XXX | XX% | [TO BE FILLED] |
| UART TX | XXX | XX% | Includes TX FIFO |
| UART RX | XXX | XX% | Includes RX FIFO |
| Registers | XXX | XX% | Memory-mapped I/O |
| **Total** | **XXX** | **100%** | |

### 1.4 Area Optimization Opportunities

[TO BE FILLED after analyzing results]

1. **Opportunity 1**: [Description]
   - Current usage: [XX cells]
   - Potential savings: [XX%]
   - Implementation: [How to achieve]

2. **Opportunity 2**: [Similar format]

---

## 2. Performance (Timing) Analysis

### 2.1 Clock Constraints

**Target Frequency**: 50 MHz  
**Clock Period**: 20 ns

### 2.2 Static Timing Analysis Results

**Tool**: OpenLANE (OpenSTA)

```
[TO BE FILLED - Paste timing report]

Setup Analysis:
  WNS (Worst Negative Slack): X.XX ns
  TNS (Total Negative Slack): X.XX ns
  Number of failing endpoints: X
  
Hold Analysis:
  WNS: X.XX ns
  TNS: X.XX ns
  Number of failing endpoints: X
```

**Status**: ✓ TIMING MET / ✗ TIMING VIOLATED

### 2.3 Critical Path Analysis

**Critical Path** (if timing violated):
```
[TO BE FILLED - Describe critical path]

Start: [module/register]
  → [gate 1]
  → [gate 2]
  → ...
End: [module/register]

Total delay: XX.XX ns
Slack: -X.XX ns (VIOLATED) / +X.XX ns (MET)
```

**Critical Path Diagram**:
![Critical Path](media/screenshots/timing_report.png)

### 2.4 Timing Optimization Strategies

[TO BE FILLED if timing is violated]

1. **Strategy 1**: Pipeline insertion
   - Target: [specific path]
   - Expected improvement: [XX ns]

2. **Strategy 2**: Logic restructuring
   - [Description]

---

## 3. Power Analysis

### 3.1 Power Estimation Results

**Tool**: OpenLANE (OpenSTA Power)

```
[TO BE FILLED - Paste power report]

Total Power: XXX mW
  Internal Power: XXX mW (XX%)
  Switching Power: XXX mW (XX%)
  Leakage Power: XXX μW (XX%)
```

### 3.2 Power Breakdown by Module

| Module | Power (mW) | Percentage | Notes |
|--------|-----------|------------|-------|
| Baud Rate Gen | X.XX | XX% | |
| UART TX | X.XX | XX% | |
| UART RX | X.XX | XX% | |
| Registers | X.XX | XX% | |
| Clock tree | X.XX | XX% | |
| **Total** | **X.XX** | **100%** | |

### 3.3 Power Optimization Opportunities

[TO BE FILLED]

1. **Clock Gating**
   - Target modules: [TX/RX when disabled]
   - Estimated savings: [XX%]
   
2. **Operand Isolation**
   - [Description]

3. **Voltage Scaling**
   - [If applicable]

---

## 4. PPA Tradeoffs

### 4.1 Design Decisions Impact

| Decision | Area Impact | Timing Impact | Power Impact |
|----------|-------------|---------------|--------------|
| FIFO depth = 8 | +XX cells | Minimal | +X.X mW |
| Clock divider | +XX cells | +X.X ns | Minimal |
| [TO BE FILLED] | | | |

### 4.2 Optimization Priorities for DP#2

Based on DP#1 baseline metrics:

**Priority 1**: [Area/Timing/Power]
- **Rationale**: [Why this is top priority]
- **Target**: [Specific goal]
- **Approach**: [How to achieve]

**Priority 2**: [Similar format]

**Priority 3**: [Similar format]

---

## 5. Comparison & Benchmarking

### 5.1 Target vs. Achieved

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Frequency | 50 MHz | [XX MHz] | ✓/✗ |
| Die Area | < XXX μm² | [XXX μm²] | ✓/✗ |
| Power | < X mW | [X.X mW] | ✓/✗ |

### 5.2 Similar Designs (if references available)

[TO BE FILLED - Compare with published UART implementations if data available]

---

## 6. Recommendations for DP#2

### 6.1 Performance Optimization

[TO BE FILLED based on actual results]

1. **If timing violated**: [Specific fixes]
2. **If timing met with margin**: [Can we increase frequency?]

### 6.2 Area Optimization

1. **FIFO reduction**: [Analyze if 4-deep sufficient]
2. **Register optimization**: [Use narrower widths where possible]

### 6.3 Power Optimization

1. **Clock gating**: [Implement for idle modules]
2. **Multi-threshold cells**: [Use HVT for non-critical paths]

---

## 7. Conclusion

### Summary

[TO BE FILLED - Brief summary of PPA results and key takeaways]

### Lessons Learned

[TO BE FILLED - What we learned about PPA from this design]

---

## Appendix: Raw Tool Outputs

### A. Yosys Synthesis Log
```
[TO BE FILLED - Attach or reference synthesis_reports/yosys_synthesis.log]
```

### B. OpenLANE Metrics CSV
```
[TO BE FILLED - Key lines from synthesis_reports/openlane_metrics.csv]
```

### C. Timing Reports
```
[TO BE FILLED - Critical excerpts from timing analysis]
```

---

*Document Version: 1.0*  
*Last Updated: [TO BE FILLED]*
