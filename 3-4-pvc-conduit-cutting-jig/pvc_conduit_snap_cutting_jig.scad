/*
  One-piece snap-on cutting jig for 3/4-inch PVC electrical conduit.
  The end face holds an oscillating multi-tool blade square to the conduit.
*/

$fa = 1;
$fs = 0.35;

// --- Part selection: "jig" or "preview" ---
part = "preview";

// --- Conduit fit ---
conduit_outer_diameter = 26.67; // 3/4-inch PVC Schedule 40
radial_clearance = 0.25;
entry_throat_width = 23.2;      // smaller than the tube for snap retention

// --- Cut guide face ---
cut_face_relief_depth = 1.5;
cut_face_tooth_clearance = 1.2;

// --- Jig body ---
body_length = 36;
body_width = 56;
body_height = 42;
corner_radius = 5;
bore_center_height = 21;

// --- Flexible jaw reliefs ---
jaw_relief_width = 2.5;
jaw_relief_center = 17.5;
jaw_relief_bottom = 17;

// --- Safety tether ---
tether_hole_diameter = 5;
tether_hole_y = -22;
tether_hole_height = 6;

// --- Preview references ---
preview_conduit_length = 92;
preview_blade_width = 35;
preview_blade_thickness = 0.9;

eps = 0.15;
bore_diameter = conduit_outer_diameter + 2 * radial_clearance;

assert(
    entry_throat_width < bore_diameter,
    "entry_throat_width must retain the conduit"
);
assert(
    entry_throat_width > conduit_outer_diameter * 0.8,
    "entry_throat_width is too narrow to snap over the conduit safely"
);
module rounded_body() {
    linear_extrude(height = body_height)
        hull()
            for (x = [-body_length / 2 + corner_radius,
                      body_length / 2 - corner_radius])
                for (y = [-body_width / 2 + corner_radius,
                          body_width / 2 - corner_radius])
                    translate([x, y])
                        circle(r = corner_radius);
}

module conduit_channel() {
    translate([-body_length / 2 - 1, 0, bore_center_height])
        rotate([0, 90, 0])
            cylinder(
                h = body_length + 2,
                d = bore_diameter
            );

    // The straight mouth leaves two shallow, printable retaining lips.
    translate([
        -body_length / 2 - 1,
        -entry_throat_width / 2,
        bore_center_height
    ])
        cube([
            body_length + 2,
            entry_throat_width,
            body_height - bore_center_height + 1
        ]);
}

module cut_face_relief() {
    relief_diameter = bore_diameter + 2 * cut_face_tooth_clearance;
    relief_throat = entry_throat_width + 2 * cut_face_tooth_clearance;

    translate([
        body_length / 2 - cut_face_relief_depth,
        0,
        bore_center_height
    ])
        rotate([0, 90, 0])
            cylinder(
                h = cut_face_relief_depth + 1,
                d = relief_diameter
            );

    translate([
        body_length / 2 - cut_face_relief_depth,
        -relief_throat / 2,
        bore_center_height
    ])
        cube([
            cut_face_relief_depth + 1,
            relief_throat,
            body_height - bore_center_height + 1
        ]);
}

module jaw_reliefs() {
    for (side = [-1, 1])
        translate([
            -body_length / 2 - 1,
            side * jaw_relief_center - jaw_relief_width / 2,
            jaw_relief_bottom
        ])
            cube([
                body_length + 2,
                jaw_relief_width,
                body_height - jaw_relief_bottom + 1
            ]);

}

module tether_hole() {
    translate([
        -body_length / 2 - 1,
        tether_hole_y,
        tether_hole_height
    ])
        rotate([0, 90, 0])
            cylinder(
                h = body_length + 2,
                d = tether_hole_diameter
            );
}

module jig_in_use_orientation() {
    difference() {
        rounded_body();
        conduit_channel();
        cut_face_relief();
        jaw_reliefs();
        tether_hole();
    }
}

module printable_jig() {
    // The tube axis becomes Z so jaw bending loads remain within each layer.
    // The recessed cut-guide face is placed directly on the print bed.
    translate([-body_height / 2, 0, body_length / 2])
        rotate([0, 90, 0])
            jig_in_use_orientation();
}

module preview() {
    color("darkorange")
        jig_in_use_orientation();

    color("gray", 0.7)
        translate([
            -preview_conduit_length / 2,
            0,
            bore_center_height
        ])
            rotate([0, 90, 0])
                cylinder(
                    h = preview_conduit_length,
                    d = conduit_outer_diameter
                );

    color("steelblue", 0.8)
        translate([
            body_length / 2 + 0.2,
            -preview_blade_width / 2,
            3
        ])
            cube([
                preview_blade_thickness,
                preview_blade_width,
                46
            ]);
}

if (part == "jig")
    printable_jig();
else if (part == "preview")
    preview();
else
    assert(false, str("Unknown part: ", part));
