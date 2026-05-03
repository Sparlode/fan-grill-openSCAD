# Design Logic & Modeling Decisions

This document outlines the architectural decisions and modeling methodologies used in the OpenSCAD codebase to achieve accurate, production-ready geometry suitable for engineering validation and simulation.

## 1. Separation of Concerns
The project structure isolates geometric parameters (`fan_parameters.scad`) from geometric implementation (`fan_rotor_eng.scad`, `fan_grill_eng.scad`) and assembly logic (`fan_assembly_eng.scad`). This modularity ensures the Python generation script can safely inject parameter overrides without mutating source logic.

## 2. Advanced Data Structures
In `dim_utils.scad`, the NACA airfoil generation relies on mathematical list comprehensions to build 2D polygons:
```openscad
function generate_naca_polygon(m=0.06, p=0.5, t=0.12, steps=40) = [
    for (i = [0:steps]) naca_point(i/steps, m, p, t, true), 
    for (i = [steps-1:-1:1]) naca_point(i/steps, m, p, t, false) 
];
```
This demonstrates flow control and array manipulation critical for programmatic shapes.

## 3. Swept Solid Generation
To transform the 2D NACA shadow into a 3D blade, `linear_extrude` is employed with mathematical functions controlling `twist` and `scale`. This enables non-linear 3D behaviors critical for turbomachinery while keeping the script lightweight and fast to render.