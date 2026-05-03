/**
 * @file fan_assembly_eng.scad
 * @brief Master assembly file for the 92mm OpenSCAD fan project.
 * @details Integrates the parameterized rotor and grill components to check clearances and fits.
 */
include <../parameters/fan_parameters.scad>
use <../stator/fan_grill_eng.scad>
use <../rotor/fan_rotor_eng.scad>

/**
 * @brief Main assembly module.
 * @details Nesting structure as required: full_assembly -> complete_rotor -> single_blade.
 */
module full_assembly() {
    // Render Grill (Transparent/Ghosted for visualization)
    color([0.2, 0.2, 0.2, 0.5]) 
    fan_grill_eng(); 

    // Render Rotor
    // Offset rotor so it sits correctly inside the grill recess with 0.5mm vertical clearance
    // The recess floor is at z=0.5. Rotor bottom should be at z=1.0.
    // Rotor center is at z = 1.0 + rotorHeight / 2 = 11.0.
    color("Orange") 
    translate([0, 0, 11.0]) 
    complete_rotor();
}

// Render the full assembly
full_assembly();
