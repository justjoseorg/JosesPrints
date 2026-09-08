/* Eufy C220 / T8W11 inverted wall bracket. Dimensions in mm. */

/* [Output] */
part = "bracket"; // [bracket, assembled]

/* [Bracket] */
width = 100;
projection = 120;
wall_height = 90;
wall_thickness = 6;
arm_thickness = 8;
reinforcement_run = 32;
reinforcement_rise = 32;

/* [Camera mounting plate] */
camera_hole_spacing = 37;
camera_hole_diameter = 4.5;
camera_mount_offset = 84;
camera_hardware_diameter = 12;

/* [Wall fasteners] */
wall_hole_diameter = 5.5;
wall_hole_spacing = 60;
wall_hole_lower = 52;
wall_hole_upper = 76;
wall_hardware_diameter = 12;

/* [Hidden] */
$fn = 64;
epsilon = 0.02;
minimum_edge = 4;

assert(part == "bracket" || part == "assembled", "Unknown part.");
assert(width > 0 && projection > 0 && wall_height > 0);
assert(wall_thickness >= 4 && arm_thickness >= 6);
assert(reinforcement_run > 0 && reinforcement_rise > 0);
assert(wall_thickness + reinforcement_run < projection);
assert(arm_thickness + reinforcement_rise < wall_height);
assert(camera_hole_diameter > 0 && wall_hole_diameter > 0);
assert(camera_hardware_diameter > camera_hole_diameter);
assert(wall_hardware_diameter > wall_hole_diameter);
assert(camera_hole_spacing > camera_hardware_diameter);
assert(camera_hole_spacing / 2 + camera_hardware_diameter / 2
       + minimum_edge <= width / 2, "Camera hardware exceeds arm width.");
assert(camera_mount_offset - camera_hardware_diameter / 2
       >= wall_thickness + reinforcement_run + minimum_edge,
       "Camera hardware would touch the reinforcement.");
assert(camera_mount_offset + camera_hardware_diameter / 2
       + minimum_edge <= projection, "Camera holes too close to arm tip.");
assert(wall_hole_spacing > wall_hardware_diameter);
assert(wall_hole_spacing / 2 + wall_hardware_diameter / 2
       + minimum_edge <= width / 2, "Wall hardware exceeds backplate width.");
assert(wall_hole_lower - wall_hardware_diameter / 2
       >= arm_thickness + reinforcement_rise + minimum_edge,
       "Wall hardware would touch the reinforcement.");
assert(wall_hole_upper - wall_hole_lower
       >= wall_hardware_diameter + minimum_edge);
assert(wall_hole_upper + wall_hardware_diameter / 2
       + minimum_edge <= wall_height, "Wall holes too close to top edge.");

module blank() {
    // Extrude one continuous L-section: the upper fillet leaves the underside flat.
    translate([-width / 2, 0, 0])
        multmatrix([
            [0, 0, 1, 0],
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 0, 1]
        ])
            linear_extrude(height = width, convexity = 4)
                polygon([
                    [0, 0],
                    [projection, 0],
                    [projection, arm_thickness],
                    [wall_thickness + reinforcement_run, arm_thickness],
                    [wall_thickness, arm_thickness + reinforcement_rise],
                    [wall_thickness, wall_height],
                    [0, wall_height]
                ]);
}

module installed_bracket() {
    difference() {
        blank();
        for (x = [-camera_hole_spacing / 2, camera_hole_spacing / 2])
            translate([x, camera_mount_offset, -epsilon])
                cylinder(d = camera_hole_diameter,
                         h = arm_thickness + 2 * epsilon);

        for (x = [-wall_hole_spacing / 2, wall_hole_spacing / 2])
            for (z = [wall_hole_lower, wall_hole_upper])
                translate([x, -epsilon, z])
                    rotate([-90, 0, 0])
                        cylinder(d = wall_hole_diameter,
                                 h = wall_thickness + 2 * epsilon);
    }
}

if (part == "assembled")
    installed_bracket();
else
    // Print on an end face so each layer contains the complete reinforced L.
    translate([wall_height, 0, width / 2])
        rotate([0, -90, 0])
            installed_bracket();
