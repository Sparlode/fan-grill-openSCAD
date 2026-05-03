/**
 * @file dim_utils.scad
 * @brief Engineering annotation utility for OpenSCAD technical drawings.
 */

module dimension_line(start, end, label, offset=10, side=1, horizontal=true) {
    dir = horizontal ? [1, 0, 0] : [0, 1, 0];
    perp = horizontal ? [0, 1, 0] : [-1, 0, 0];
    
    p1 = start + perp * offset * side;
    p2 = end + perp * offset * side;
    mid = (p1 + p2) / 2;

    color("blue") {
        // Main dimension line
        hull() {
            translate(p1) sphere(r=0.2);
            translate(p2) sphere(r=0.2);
        }
        
        // Extension lines (Leaders)
        hull() { translate(start) sphere(r=0.1); translate(p1) sphere(r=0.1); }
        hull() { translate(end) sphere(r=0.1); translate(p2) sphere(r=0.1); }
        
        // Standard Arrows (Approximated)
        translate(p1) rotate(horizontal ? 0 : 90) scale([2,1,1]) rotate(45) square(1, center=true);
        translate(p2) rotate(horizontal ? 0 : 90) scale([2,1,1]) rotate(-135) square(1, center=true);
        
        // Label
        translate(mid + perp * 2 * side)
        text(label, size=3, halign="center", valign="center");
    }
}

/**
 * @brief Radial layout helpers for 4-way and 8-way symmetry.
 */
module radial_4x() { for(i=[0:3]) rotate([0,0,i*90]) children(); }
module radial_8x() { for(i=[0:7]) rotate([0,0,i*45]) children(); }

/**
 * @brief Performance callout for blueprint views.
 */
module performance_callout(pos, label, desc) {
    color("DarkGreen") {
        translate(pos) {
            circle(r=1.5);
            translate([0,0,0.1]) text(label, size=2, halign="center", valign="center");
            // Leader line to nowhere (just a pointer)
            rotate(45) translate([1.5, 0, 0]) square([5, 0.2]);
        }
    }
}

// --- NACA 4-Digit Approximation ---
function naca_half_thickness(x, t) = 5 * t * (
    0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * pow(x, 2) + 0.2843 * pow(x, 3) - 0.1015 * pow(x, 4)
);

function naca_camber(x, m, p) = 
    (x < p) ? (m / pow(p, 2)) * (2 * p * x - pow(x, 2)) :
              (m / pow(1 - p, 2)) * (1 - 2 * p + 2 * p * x - pow(x, 2));

function naca_camber_gradient(x, m, p) = 
    (x < p) ? (2 * m / pow(p, 2)) * (p - x) :
              (2 * m / pow(1 - p, 2)) * (p - x);

function naca_point(x, m, p, t, is_upper) = let(
    yt = naca_half_thickness(x, t),
    yc = naca_camber(x, m, p),
    dy_dx = naca_camber_gradient(x, m, p),
    theta = atan(dy_dx),
    xu = x - yt * sin(theta),
    yu = yc + yt * cos(theta),
    xl = x + yt * sin(theta),
    yl = yc - yt * cos(theta)
) is_upper ? [xu, yu] : [xl, yl];

function generate_naca_polygon(m=0.06, p=0.5, t=0.12, steps=40) = [
    for (i = [0:steps]) naca_point(i/steps, m, p, t, true), 
    for (i = [steps-1:-1:1]) naca_point(i/steps, m, p, t, false) 
];
