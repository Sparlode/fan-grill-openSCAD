/**
 * @file fan_grill_eng.scad
 * @brief Parametric fan grill (stator) with hybrid 2D engineering annotations.
 */
include <../parameters/fan_parameters.scad>
use <../utils/dim_utils.scad>

// --- Derived Variables ---
sizeXY = fanSize;
sizeZ = thickness;
sizeZinside = thicknessInside;
innerGrillDiameter = hubDiameter;
grillStep = (shroudDiameter/2-innerGrillDiameter/2-grillNumber*grillThickness)/(grillNumber+1);

module base_frame_solid() {
    if ($preview) {
        hull() radial_4x() translate([sizeXY/2-roundRadius/2, sizeXY/2-roundRadius/2, 0]) 
            cylinder(h=sizeZ, d=roundRadius, center=true);
    } else {
        minkowski() {
            hull() radial_4x() translate([sizeXY/2-roundRadius/2, sizeXY/2-roundRadius/2, 0]) 
                cylinder(h=sizeZ-2, d=roundRadius-2, center=true);
            cylinder(h=2, d=2, center=true);
        }
    }
}

module fan_grill_eng() {
    difference() {
        union() {
            difference() {
                base_frame_solid();
                cylinder(h=sizeZ+0.1, d=shroudDiameter, center=true);
            }
            cylinder(h=sizeZ, d=innerGrillDiameter, center=true);
            radial_8x() cube([grillThickness+0.8, sizeXY-frameWidth, sizeZ], true);
            for(i=[1:grillNumber]) {
                difference(){
                    cylinder(h=sizeZ, d=innerGrillDiameter+grillStep*2*i+i*2*grillThickness, center=true);
                    cylinder(h=sizeZ+0.1, d=innerGrillDiameter+grillStep*2*i+(i-1)*2*grillThickness, center=true);
                }
            }
            radial_4x() translate([holesDistance/2, holesDistance/2, 0]) 
                cylinder(h=sizeZ, d=2.5*holesDiameter, center=true);
        }
        translate([0, 0, sizeZinside/2+0.05])
            cube([sizeXY-frameWidth*2, sizeXY-frameWidth*2, sizeZ-sizeZinside+0.1], true);
        radial_4x() {
            translate([holesDistance/2, holesDistance/2, 0]) {
                cylinder(h=sizeZ+0.1, d=holesDiameter, center=true); 
                translate([0, 0, -0.6]) 
                    if (chamfer == "cone") cylinder(h=sizeZ-1, d1=2*holesDiameter, d2=0, center=true);
                    else cylinder(h=sizeZ-1, d=2*holesDiameter, center=true);
            }
        }
        radial_4x() translate([-latchWidth/2, -sizeXY/2-0.1, sizeZ/2-1.8+0.1]) 
            cube([latchWidth, 1.3, 1.8]);
    }
}

module blueprint_view() {
    // 1. Geometric base
    color([0.5, 0.5, 0.5, 0.5]) projection(cut = true) fan_grill_eng();
    
    // 2. DIMENSIONS (Fixed Constraints)
    // Frame Size
    dimension_line([-sizeXY/2, sizeXY/2, 0], [sizeXY/2, sizeXY/2, 0], str(sizeXY, " mm"), offset=12, horizontal=true);
    // Mounting Pitch
    dimension_line([-holesDistance/2, holesDistance/2, 0], [holesDistance/2, holesDistance/2, 0], str(holesDistance, " mm"), offset=5, horizontal=true);
    // Hub Diameter
    dimension_line([-innerGrillDiameter/2, 0, 0], [innerGrillDiameter/2, 0, 0], str("DIA ", innerGrillDiameter), offset=-25, horizontal=true);
    
    // 3. PERFORMANCE CALLOUTS (Variable DoE Points)
    performance_callout([sizeXY/2 - 5, 0, 0], "P1", "Tip Clearance (Variable)");
    performance_callout([innerGrillDiameter/2 + 5, innerGrillDiameter/4, 0], "P2", "Grill Impedance Pattern");
}

// Global render trigger
if ($preview || $init_done == undef) {
    if (render_mode == "BLUEPRINT") {
        blueprint_view();
    } else {
        fan_grill_eng();
    }
}
