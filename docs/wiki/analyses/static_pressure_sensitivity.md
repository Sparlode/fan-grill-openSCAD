# Static Pressure Sensitivity Analysis

**Source**: `src/doe/doe_analysis.json`
**Study**: 92mm Industrial Fan - Static Pressure Sensitivity Analysis
**Type**: One-Factor-at-a-Time (OFAT) + Critical Edge Cases

## Objectives
- **Primary**: Identify geometry with >0.5 inH2O peak static pressure.
- **Secondary**: Verify >90 CFM free delivery flow.
- **Constraint**: Acoustic potential check (resonance with 8-spoke stator).

## Critical Sensitivities
1. **radialClearance**: Hypothesis that reducing clearance from 1.0mm to 0.5mm will increase pressure at high impedance.
2. **bladeCount**: 9 blades vs 7 blades (smoothness vs drag).
3. **twist_hub**: Increased pitch (>45deg) needed against dense PSU grill.

## Key Test Cases
- **CASE_001_BASELINE**: Baseline match.
- **CASE_002_HIGH_PRESSURE**: Tight tip clearance (0.5mm).
- **CASE_003_LOW_DRAG**: 7-blade for low noise.
- **CASE_004_INDUSTRIAL_STRENGTH**: Max camber and pitch (11 blades).