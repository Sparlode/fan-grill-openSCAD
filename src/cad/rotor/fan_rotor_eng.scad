/**
 * @file fan_rotor_eng.scad
 * @brief Parametric axial fan rotor using NACA airfoil profiles.
 */
include <../parameters/fan_parameters.scad>
use <../utils/dim_utils.scad>

/**
 * @brief Generates a single aerodynamic blade using linear_extrude.
 * DESIGN DECISION: Uses global parameters for chord and twist to allow DoE overrides.
 */
module single_blade() {
    r_hub = (hubDiameter / 2) - 1.0; 
    r_tip = fanDiameter / 2;
    blade_span = r_tip - r_hub;
    
    // Use GLOBAL parameters (allows DoE override)
    c_hub = chord_hub;
    c_tip = chord_tip;
    t_hub = twist_hub;
    t_tip = twist_tip;
    
    twist_diff = t_tip - t_hub; 
    scale_factor = c_tip / c_hub;

    intersection() {
        cylinder(h=rotorHeight, d=fanDiameter, center=true);
        
        translate([r_hub, 0, 0])
        rotate([t_hub, 0, 0]) 
        rotate([0, 90, 0])        
        rotate([0, 0, 90])        
        linear_extrude(height=blade_span + 2, twist=twist_diff, scale=scale_factor, slices=20)
        scale([c_hub, c_hub])
        translate([-0.5, 0]) 
        polygon(points=generate_naca_polygon());
    }
}

module rotor_hub() {
    difference() {
        union() {
            cylinder(h=rotorHeight, d=hubDiameter, center=true);
            translate([0, 0, rotorHeight/2])
            rotate_extrude()
            intersection() {
                scale([hubDiameter/2, hubDiameter/4])
                circle(r=1);
                square([hubDiameter, hubDiameter]);
            }
        }
        cylinder(h=rotorHeight+10, d=5.0, center=true);
        translate([3.0, 0, 0]) 
        cube([3.0, 2.0, rotorHeight+10], center=true);
    }
}

module complete_rotor() {
    union() {
        rotor_hub();
        for (i = [0 : bladeCount - 1]) {
            rotate([0, 0, i * (360 / bladeCount)]) {
                single_blade();
            }
        }
    }
}

// Global render trigger
if ($preview || $init_done == undef) {
    complete_rotor();
}
