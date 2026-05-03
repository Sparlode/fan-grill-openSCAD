/**
 * @file fan_parameters.scad
 * @brief Centralized parameters for the OpenSCAD Fan Assembly project with engineering-grade defaults.
 */

// --- Global Resolution ---
$fn = ($fn == undef) ? ($preview ? 30 : 100) : $fn;

/* [ Rotor Parameters ] */
radialClearance = (radialClearance == undef) ? 0.5 : radialClearance;
fanSize = (fanSize == undef) ? 92 : fanSize;
frameWidth = (frameWidth == undef) ? 2.8 : frameWidth;
hubDiameter = (hubDiameter == undef) ? 35.0 : hubDiameter;
bladeCount = (bladeCount == undef) ? 9 : bladeCount;
rotorHeight = (rotorHeight == undef) ? 20.0 : rotorHeight;
design_mode = (design_mode == undef) ? "High Static Pressure" : design_mode;

// Aerodynamic Parameters (Moved from rotor implementation to parameters)
twist_hub = (twist_hub == undef) ? 45.0 : twist_hub;
twist_tip = (twist_tip == undef) ? 20.0 : twist_tip;
chord_hub = (chord_hub == undef) ? 25.0 : chord_hub;
chord_tip = (chord_tip == undef) ? 15.0 : chord_tip;

/* [ Derived Variables ] */
shroudDiameter = fanSize - (2 * frameWidth);
fanDiameter = shroudDiameter - (2 * radialClearance);

/* [ Grill/Stator Parameters ] */
holesDistance = (holesDistance == undef) ? 82.5 : holesDistance;
holesDiameter = (holesDiameter == undef) ? 4.5 : holesDiameter;
chamfer = (chamfer == undef) ? "cone" : chamfer;
thickness = (thickness == undef) ? 4.5 : thickness;
thicknessInside = (thicknessInside == undef) ? 2.7 : thicknessInside;
roundRadius = (roundRadius == undef) ? 4.0 : roundRadius;
latchWidth = (latchWidth == undef) ? 13.6 : latchWidth;
grillNumber = (grillNumber == undef) ? 4 : grillNumber;
grillThickness = (grillThickness == undef) ? 1.2 : grillThickness;

/* [ Validation & Guardrails ] */
assert(fanDiameter < shroudDiameter, "ERROR: Fan rotor is larger than the shroud.");
assert(hubDiameter < fanDiameter * 0.8, "ERROR: Hub is too large for efficient airflow.");
assert(bladeCount > 0, "ERROR: Blade count must be positive.");
