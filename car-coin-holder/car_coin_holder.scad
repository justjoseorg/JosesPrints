/*
  Two-piece car cup-holder coin container

  Print orientation:
    - Body: open side up
    - Lid: flat top against the print bed

  Set part to "body", "lid", "both", or "assembled".
*/

$fn = 120;

part = "both";

cup_holder_diameter = 70;
fit_clearance = 0.8;
body_height = 70;
bottom_taper = 2.9;

wall = 2.4;
floor_thickness = 2.4;
divider_thickness = 2.0;
divider_count = 3;

lid_clearance = 0.25;
lid_top_thickness = 2.6;
lid_skirt_height = 7;
lid_wall = 1.8;

body_top_d = cup_holder_diameter - 2 * fit_clearance;
body_bottom_d = body_top_d - bottom_taper;
inner_top_d = body_top_d - 2 * wall;
inner_bottom_d = body_bottom_d - 2 * wall;
lid_inner_d = body_top_d + 2 * lid_clearance;
lid_outer_d = lid_inner_d + 2 * lid_wall;

module body_shell() {
    difference() {
        cylinder(h = body_height, d1 = body_bottom_d, d2 = body_top_d);

        translate([0, 0, floor_thickness])
            cylinder(
                h = body_height,
                d1 = inner_bottom_d,
                d2 = inner_top_d
            );
    }
}

module coin_dividers() {
    divider_length = inner_top_d / 2 + wall;

    for (angle = [0 : 360 / divider_count : 359]) {
        rotate([0, 0, angle])
            translate([0, -divider_thickness / 2, floor_thickness])
                cube([
                    divider_length,
                    divider_thickness,
                    body_height - floor_thickness - 1
                ]);
    }
}

module body() {
    union() {
        body_shell();
        coin_dividers();
    }
}

module lid() {
    difference() {
        union() {
            cylinder(h = lid_top_thickness, d = lid_outer_d);

            translate([0, 0, lid_top_thickness])
                difference() {
                    cylinder(h = lid_skirt_height, d = lid_outer_d);
                    cylinder(h = lid_skirt_height + 0.1, d = lid_inner_d);
                }
        }

        // A small opening makes the lid easier to flex and remove.
        translate([
            lid_inner_d / 2 - 0.5,
            -3,
            lid_top_thickness - 0.1
        ])
            cube([
                lid_wall + 2,
                6,
                lid_skirt_height + 0.2
            ]);
    }
}

module assembled() {
    body();

    translate([0, 0, body_height + lid_top_thickness])
        rotate([180, 0, 0])
            lid();
}

if (part == "body") {
    body();
} else if (part == "lid") {
    lid();
} else if (part == "assembled") {
    assembled();
} else {
    body();
    translate([body_top_d / 2 + lid_outer_d / 2 + 10, 0, 0])
        lid();
}
