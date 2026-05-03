# Rotor

**Source**: `src/cad/rotor/fan_rotor_eng.scad`

## Description
Parametric axial fan rotor using NACA airfoil profiles.

## Design Decisions
- **Parameter Injection:** Uses global parameters (`chord_hub`, `chord_tip`, `twist_hub`, `twist_tip`) to allow Design of Experiments (DoE) overrides without mutating core logic.
- **Aerodynamic Profiling:** Blade generation relies on `linear_extrude` with `twist` and `scale` transformations applied to a high-fidelity NACA 4-digit polygon.
- **Math-Driven Geometry:** The NACA profile is generated using list comprehensions in `dim_utils.scad`, allowing for smooth, differentiable surfaces suitable for CFD analysis.
- **Production Clearances:** Employs `intersection()` with a bounding cylinder to ensure blades are precisely trimmed to the `fanDiameter` while maintaining a clean hub interface.