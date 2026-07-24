/*
  Drilling template for the round twist-lock ceiling mount.

  The two outer guides match the mount's 68 mm screw-center spacing.
  The center guide marks the cable-hole location.
*/

$fn = 64;

screw_radius = 34;
screw_hole_diameter = 4.5;
cable_hole_diameter = 5;

template_width = 12;
template_thickness = 2;

difference() {
    hull() {
        for (x = [-screw_radius, screw_radius]) {
            translate([x, 0, 0])
                cylinder(
                    h = template_thickness,
                    d = template_width
                );
        }
    }

    for (x = [-screw_radius, screw_radius]) {
        translate([x, 0, -0.1])
            cylinder(
                h = template_thickness + 0.2,
                d = screw_hole_diameter
            );
    }

    translate([0, 0, -0.1])
        cylinder(
            h = template_thickness + 0.2,
            d = cable_hole_diameter
        );
}
