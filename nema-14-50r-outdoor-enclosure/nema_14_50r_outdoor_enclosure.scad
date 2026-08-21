/*
  Weather-resistant NEMA 14-50R enclosure

  This model provides an ASA body, a removable receptacle faceplate, a
  top-hinged rain flap, and separate TPU seals. It is intended for use
  with a listed receptacle and a listed 3/4-inch wet-location conduit hub.

  Printable part values are "body", "faceplate", "flap",
  "flap_integrated_asa", "flap_integrated_tpu",
  "flap_with_integrated_seal", "faceplate_gasket", "flap_seal",
  "conduit_gasket", and "wall_mount_washer".
*/

$fn = 64;

part = "assembled"; // body, faceplate, flap, flap_integrated_asa, flap_integrated_tpu, flap_with_integrated_seal, faceplate_gasket, flap_seal, conduit_gasket, wall_mount_washer, hinge_clearance_check, layout, assembled
preview_flap_angle = 105;
hinge_test_angle = 90;

// Enclosure dimensions
box_width = 150;
box_height = 190;
box_depth = 100;
wall_thickness = 3.2;
back_thickness = 4.2;
corner_radius = 8;

// Front plate and flexible seals
faceplate_width = 144;
faceplate_height = 176;
faceplate_thickness = 4;
faceplate_x = (box_width - faceplate_width) / 2;
faceplate_z = 3;
faceplate_gasket_thickness = 2;
faceplate_gasket_border = 14;
flap_thickness = 4;
flap_width = 148;
flap_height = 166;
flap_x = (box_width - flap_width) / 2;
flap_z = 3;
flap_inner_offset = 6;
flap_seal_thickness = 2;
integrated_anchor_hole_diameter = 3.2;
integrated_anchor_head_diameter = 5.2;
integrated_anchor_head_depth = 1.2;

// Common NEMA 14-50R dimensions; verify the selected receptacle
receptacle_center_x = box_width / 2;
receptacle_center_z = 95;
receptacle_cutout_diameter = 60;
receptacle_mount_spacing = 83.3;
receptacle_screw_diameter = 4.5;

// Faceplate attachment
faceplate_screw_diameter = 4.5;
insert_pocket_diameter = 5.3;
insert_pocket_depth = 7;
boss_diameter = 13;
faceplate_screw_x = [15, box_width - 15];
faceplate_screw_z = [20, box_height - 20];

// 3/4-inch trade-size conduit hub
conduit_hole_diameter = 28.8;
conduit_boss_diameter = 44;
conduit_boss_height = 4;
conduit_center_y = 45;
conduit_gasket_thickness = 2;

// Internal rear-wall mounting bosses
wall_mount_x = box_width / 2;
wall_mount_z = [45, box_height - 45];
wall_mount_boss_diameter = 22;
wall_mount_boss_depth = 7;
wall_screw_diameter = 6.5;
wall_screw_head_diameter = 13;
wall_screw_head_depth = 5;
wall_mount_washer_diameter = 12.5;
wall_mount_washer_hole_diameter = 6.8;
wall_mount_washer_thickness = 1.5;

// Hinge sized for raw 1.75 mm ASA filament
hinge_pin_diameter = 1.75;
hinge_clearance = 0.25;
hinge_bore_diameter = hinge_pin_diameter + hinge_clearance;
hinge_outer_diameter = 10;
hinge_rotation_clearance = 0.6;
hinge_axis_z =
    faceplate_height
    + hinge_outer_diameter / 2
    + hinge_rotation_clearance;
hinge_axis_y = 10;
hinge_anchor_height = 10;
hinge_left_start = 9;
hinge_outer_length = 30;
hinge_center_start = 45;
hinge_center_length = 58;
magnet_diameter = 8.3;
magnet_depth = 3.1;
magnet_centers_x = [32, box_width - 32];
magnet_center_z = 13;

// Flap seal and raised rain curb
seal_outer_width = 112;
seal_outer_height = 148;
seal_ring_width = 6;
seal_global_bottom = 20;
curb_height = 1.2;
curb_width = 3;

// Front rain visor
visor_depth = 6;
visor_height = 4;

assert(
    receptacle_cutout_diameter < seal_outer_width - 2 * seal_ring_width,
    "The receptacle cutout must fit inside the flap seal."
);
assert(
    conduit_hole_diameter < conduit_boss_diameter - 6,
    "Increase the conduit boss diameter."
);
assert(
    faceplate_gasket_border > faceplate_screw_diameter,
    "Increase the faceplate gasket border."
);

module rounded_rectangle_2d(size, radius) {
    translate([radius, radius])
        offset(r = radius)
            square([
                size[0] - 2 * radius,
                size[1] - 2 * radius
            ]);
}

// A rounded rectangle in X/Z extruded in the positive Y direction.
module front_prism(width, height, depth, radius) {
    translate([0, depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                rounded_rectangle_2d([width, height], radius);
}

module cylinder_x(length, diameter) {
    rotate([0, 90, 0])
        cylinder(h = length, d = diameter);
}

module cylinder_y(length, diameter) {
    rotate([-90, 0, 0])
        cylinder(h = length, d = diameter);
}

module ring_front_prism(
    outer_width,
    outer_height,
    depth,
    radius,
    ring_width
) {
    difference() {
        front_prism(
            outer_width,
            outer_height,
            depth,
            radius
        );

        translate([ring_width, -0.1, ring_width])
            front_prism(
                outer_width - 2 * ring_width,
                outer_height - 2 * ring_width,
                depth + 0.2,
                max(radius - ring_width, 1)
            );
    }
}

module body_shell() {
    difference() {
        union() {
            front_prism(
                box_width,
                box_height,
                box_depth,
                corner_radius
            );

            translate([
                receptacle_center_x,
                conduit_center_y,
                box_height - wall_thickness
            ])
                cylinder(
                    h = wall_thickness + conduit_boss_height,
                    d = conduit_boss_diameter
                );

            translate([
                0,
                box_depth - 6,
                box_height - 1
            ])
                cube([
                    box_width,
                    visor_depth,
                    visor_height
                ]);
        }

        translate([
            wall_thickness,
            back_thickness,
            wall_thickness
        ])
            front_prism(
                box_width - 2 * wall_thickness,
                box_height - 2 * wall_thickness,
                box_depth - back_thickness + 0.2,
                corner_radius - wall_thickness
            );
    }
}

module faceplate_bosses() {
    for (x = faceplate_screw_x) {
        for (z = faceplate_screw_z) {
            translate([x, back_thickness, z])
                cylinder_y(
                    box_depth - back_thickness,
                    boss_diameter
                );
        }
    }
}

module wall_mount_bosses() {
    for (z = wall_mount_z) {
        translate([
            wall_mount_x,
            back_thickness - 0.1,
            z
        ])
            cylinder_y(
                wall_mount_boss_depth + 0.1,
                wall_mount_boss_diameter
            );
    }
}

module body_cutouts() {
    translate([
        receptacle_center_x,
        conduit_center_y,
        box_height - wall_thickness - 0.1
    ])
        cylinder(
            h = wall_thickness
                + conduit_boss_height
                + 0.2,
            d = conduit_hole_diameter
        );

    for (x = faceplate_screw_x) {
        for (z = faceplate_screw_z) {
            translate([
                x,
                box_depth - insert_pocket_depth,
                z
            ])
                cylinder_y(
                    insert_pocket_depth + 0.2,
                    insert_pocket_diameter
                );
        }
    }

    for (z = wall_mount_z) {
        translate([wall_mount_x, -0.1, z])
            cylinder_y(
                back_thickness
                    + wall_mount_boss_depth
                    + 0.2,
                wall_screw_diameter
            );

        translate([
            wall_mount_x,
            back_thickness
                + wall_mount_boss_depth
                - wall_screw_head_depth,
            z
        ])
            cylinder_y(
                wall_screw_head_depth + 0.2,
                wall_screw_head_diameter
            );
    }
}

module body() {
    difference() {
        union() {
            body_shell();
            faceplate_bosses();
            wall_mount_bosses();
        }

        body_cutouts();
    }
}

module hinge_anchor(
    start,
    length,
    leaf_y_min,
    leaf_y_max
) {
    hull() {
        translate([
            start,
            hinge_axis_y,
            hinge_axis_z
        ])
            cylinder_x(
                length,
                hinge_outer_diameter
            );

        translate([
            start,
            leaf_y_min,
            faceplate_height - hinge_anchor_height
        ])
            cube([
                length,
                leaf_y_max - leaf_y_min,
                hinge_anchor_height
            ]);
    }
}

module reinforced_hinge_barrel(
    start,
    length,
    leaf_y_min,
    leaf_y_max
) {
    difference() {
        hinge_anchor(
            start,
            length,
            leaf_y_min,
            leaf_y_max
        );

        translate([
            start - 0.1,
            hinge_axis_y,
            hinge_axis_z
        ])
            cylinder_x(
                length + 0.2,
                hinge_bore_diameter
            );
    }
}

module faceplate_hinge_barrels() {
    for (start = [
        hinge_left_start,
        faceplate_width
            - hinge_left_start
            - hinge_outer_length
    ]) {
        reinforced_hinge_barrel(
            start,
            hinge_outer_length,
            0,
            faceplate_thickness
        );
    }
}

module faceplate_curb() {
    translate([
        (faceplate_width - seal_outer_width) / 2,
        faceplate_thickness,
        seal_global_bottom - faceplate_z
    ])
        ring_front_prism(
            seal_outer_width,
            seal_outer_height,
            curb_height,
            8,
            curb_width
        );
}

module faceplate_cutouts() {
    translate([
        receptacle_center_x - faceplate_x,
        -0.1,
        receptacle_center_z - faceplate_z
    ])
        cylinder_y(
            faceplate_thickness + 0.2,
            receptacle_cutout_diameter
        );

    for (z_offset = [
        -receptacle_mount_spacing / 2,
        receptacle_mount_spacing / 2
    ]) {
        translate([
            receptacle_center_x - faceplate_x,
            -0.1,
            receptacle_center_z
                - faceplate_z
                + z_offset
        ])
            cylinder_y(
                faceplate_thickness + 0.2,
                receptacle_screw_diameter
            );
    }

    for (x = faceplate_screw_x) {
        for (z = faceplate_screw_z) {
            translate([
                x - faceplate_x,
                -0.1,
                z - faceplate_z
            ])
                cylinder_y(
                    faceplate_thickness + 0.2,
                    faceplate_screw_diameter
                );
        }
    }

    for (x = magnet_centers_x) {
        translate([
            x - faceplate_x,
            faceplate_thickness - magnet_depth,
            magnet_center_z - faceplate_z
        ])
            cylinder_y(
                magnet_depth + 0.2,
                magnet_diameter
            );
    }
}

module faceplate() {
    difference() {
        union() {
            front_prism(
                faceplate_width,
                faceplate_height,
                faceplate_thickness,
                5
            );
            faceplate_hinge_barrels();
            faceplate_curb();
        }

        faceplate_cutouts();
    }
}

module faceplate_gasket() {
    difference() {
        ring_front_prism(
            faceplate_width,
            faceplate_height,
            faceplate_gasket_thickness,
            5,
            faceplate_gasket_border
        );

        for (x = faceplate_screw_x) {
            for (z = faceplate_screw_z) {
                translate([
                    x - faceplate_x,
                    -0.1,
                    z - faceplate_z
                ])
                    cylinder_y(
                        faceplate_gasket_thickness + 0.2,
                        faceplate_screw_diameter + 0.8
                    );
            }
        }
    }
}

module flap_hinge_barrel() {
    reinforced_hinge_barrel(
        hinge_center_start,
        hinge_center_length,
        flap_inner_offset,
        flap_inner_offset + flap_thickness
    );
}

integrated_anchor_centers = [
    [50, seal_global_bottom - flap_z + seal_ring_width / 2],
    [98, seal_global_bottom - flap_z + seal_ring_width / 2],
    [
        50,
        seal_global_bottom
            - flap_z
            + seal_outer_height
            - seal_ring_width / 2
    ],
    [
        98,
        seal_global_bottom
            - flap_z
            + seal_outer_height
            - seal_ring_width / 2
    ],
    [
        (flap_width - seal_outer_width) / 2
            + seal_ring_width / 2,
        70
    ],
    [
        (flap_width + seal_outer_width) / 2
            - seal_ring_width / 2,
        70
    ],
    [
        (flap_width - seal_outer_width) / 2
            + seal_ring_width / 2,
        112
    ],
    [
        (flap_width + seal_outer_width) / 2
            - seal_ring_width / 2,
        112
    ]
];

module integrated_anchor_cutouts() {
    for (center = integrated_anchor_centers) {
        translate([
            center[0],
            flap_inner_offset - 0.1,
            center[1]
        ])
            cylinder_y(
                flap_thickness + 0.2,
                integrated_anchor_hole_diameter
            );

        translate([
            center[0],
            flap_inner_offset
                + flap_thickness
                - integrated_anchor_head_depth,
            center[1]
        ])
            cylinder_y(
                integrated_anchor_head_depth + 0.2,
                integrated_anchor_head_diameter
            );
    }
}

module flap_cutouts(integrated_seal = false) {
    for (x = magnet_centers_x) {
        translate([
            x - flap_x,
            flap_inner_offset - 0.1,
            magnet_center_z - flap_z
        ])
            cylinder_y(
                magnet_depth + 0.2,
                magnet_diameter
            );
    }

    if (integrated_seal) {
        integrated_anchor_cutouts();
    }
}

module flap(integrated_seal = false) {
    difference() {
        union() {
            translate([0, flap_inner_offset, 0])
                front_prism(
                    flap_width,
                    flap_height,
                    flap_thickness,
                    7
                );

            translate([
                (flap_width - 34) / 2,
                flap_inner_offset,
                -3
            ])
                front_prism(
                    34,
                    10,
                    flap_thickness,
                    4
                );

            flap_hinge_barrel();
        }

        flap_cutouts(integrated_seal);
    }
}

module flap_seal() {
    translate([
        (flap_width - seal_outer_width) / 2,
        0,
        seal_global_bottom - flap_z
    ])
        ring_front_prism(
            seal_outer_width,
            seal_outer_height,
            flap_seal_thickness,
            8,
            seal_ring_width
        );
}

module integrated_flap_seal() {
    union() {
        translate([
            (flap_width - seal_outer_width) / 2,
            flap_inner_offset - flap_seal_thickness,
            seal_global_bottom - flap_z
        ])
            ring_front_prism(
                seal_outer_width,
                seal_outer_height,
                flap_seal_thickness,
                8,
                seal_ring_width
            );

        for (center = integrated_anchor_centers) {
            translate([
                center[0],
                flap_inner_offset - 0.05,
                center[1]
            ])
                cylinder_y(
                    flap_thickness + 0.1,
                    integrated_anchor_hole_diameter - 0.2
                );

            translate([
                center[0],
                flap_inner_offset
                    + flap_thickness
                    - integrated_anchor_head_depth,
                center[1]
            ])
                cylinder_y(
                    integrated_anchor_head_depth,
                    integrated_anchor_head_diameter - 0.2
                );
        }
    }
}

module conduit_gasket() {
    difference() {
        cylinder(
            h = conduit_gasket_thickness,
            d = conduit_boss_diameter
        );

        translate([0, 0, -0.1])
            cylinder(
                h = conduit_gasket_thickness + 0.2,
                d = conduit_hole_diameter + 0.6
            );
    }
}

module wall_mount_washer() {
    difference() {
        cylinder(
            h = wall_mount_washer_thickness,
            d = wall_mount_washer_diameter
        );

        translate([0, 0, -0.1])
            cylinder(
                h = wall_mount_washer_thickness + 0.2,
                d = wall_mount_washer_hole_diameter
            );
    }
}

module receptacle_preview() {
    difference() {
        cylinder_y(4, receptacle_cutout_diameter - 2);

        for (x = [-14, 14]) {
            translate([x, -0.1, 4])
                rotate([0, x < 0 ? -25 : 25, 0])
                    cube([5, 4.2, 19], center = true);
        }

        translate([0, -0.1, 16])
            cube([6, 4.2, 17], center = true);

        translate([0, -0.1, -17])
            cylinder_y(4.2, 8);
    }
}

module body_for_printing() {
    translate([
        0,
        box_height + visor_height,
        0
    ])
        rotate([90, 0, 0])
            body();
}

module faceplate_for_printing() {
    translate([
        0,
        hinge_axis_z + hinge_outer_diameter / 2,
        0
    ])
        rotate([90, 0, 0])
            faceplate();
}

module flap_for_printing(integrated_seal = false) {
    translate([
        0,
        hinge_axis_z + hinge_outer_diameter / 2,
        flap_inner_offset + flap_thickness
    ])
        rotate([-90, 0, 0])
            flap(integrated_seal);
}

module integrated_flap_seal_for_printing() {
    translate([
        0,
        hinge_axis_z + hinge_outer_diameter / 2,
        flap_inner_offset + flap_thickness
    ])
        rotate([-90, 0, 0])
            integrated_flap_seal();
}

module flap_with_integrated_seal_for_printing() {
    flap_for_printing(true);
    integrated_flap_seal_for_printing();
}

module gasket_for_printing() {
    translate([0, faceplate_height, 0])
        rotate([90, 0, 0])
            faceplate_gasket();
}

module flap_seal_for_printing() {
    translate([0, flap_height, 0])
        rotate([90, 0, 0])
            flap_seal();
}

module flap_assembly() {
    color([0.85, 0.48, 0.12])
        translate([
            flap_x,
            box_depth + faceplate_gasket_thickness,
            flap_z
        ])
            flap();

    color([0.15, 0.15, 0.15])
        translate([
            flap_x,
            box_depth
                + faceplate_gasket_thickness
                + flap_inner_offset
                - flap_seal_thickness,
            flap_z
        ])
            flap_seal();
}

module positioned_faceplate() {
    translate([
        faceplate_x,
        box_depth + faceplate_gasket_thickness,
        faceplate_z
    ])
        faceplate();
}

module positioned_flap() {
    translate([
        flap_x,
        box_depth + faceplate_gasket_thickness,
        flap_z
    ])
        flap();
}

module rotated_flap(angle) {
    hinge_global_y =
        box_depth
        + faceplate_gasket_thickness
        + hinge_axis_y;
    hinge_global_z = faceplate_z + hinge_axis_z;

    translate([0, hinge_global_y, hinge_global_z])
        rotate([angle, 0, 0])
            translate([0, -hinge_global_y, -hinge_global_z])
                positioned_flap();
}

module hinge_clearance_check(angle) {
    intersection() {
        union() {
            body();
            positioned_faceplate();
        }

        rotated_flap(angle);
    }
}

module assembled() {
    color([0.76, 0.38, 0.08])
        body();

    color([0.15, 0.15, 0.15])
        translate([
            faceplate_x,
            box_depth,
            faceplate_z
        ])
            faceplate_gasket();

    color([0.88, 0.46, 0.10])
        translate([
            faceplate_x,
            box_depth + faceplate_gasket_thickness,
            faceplate_z
        ])
            faceplate();

    color([0.08, 0.08, 0.08])
        translate([
            receptacle_center_x,
            box_depth
                + faceplate_gasket_thickness
                + faceplate_thickness
                - 0.2,
            receptacle_center_z
        ])
            receptacle_preview();

    hinge_global_y =
        box_depth
        + faceplate_gasket_thickness
        + hinge_axis_y;
    hinge_global_z = faceplate_z + hinge_axis_z;

    translate([0, hinge_global_y, hinge_global_z])
        rotate([preview_flap_angle, 0, 0])
            translate([0, -hinge_global_y, -hinge_global_z])
                flap_assembly();

    color([0.55, 0.55, 0.58])
        translate([
            faceplate_x + hinge_left_start,
            hinge_global_y,
            hinge_global_z
        ])
            cylinder_x(
                faceplate_width - 2 * hinge_left_start,
                hinge_pin_diameter
            );

    color([0.12, 0.12, 0.12])
        translate([
            receptacle_center_x,
            conduit_center_y,
            box_height + conduit_boss_height
        ])
            conduit_gasket();
}

if (part == "body") {
    body_for_printing();
} else if (part == "faceplate") {
    faceplate_for_printing();
} else if (part == "flap") {
    flap_for_printing();
} else if (part == "flap_integrated_asa") {
    flap_for_printing(true);
} else if (part == "flap_integrated_tpu") {
    integrated_flap_seal_for_printing();
} else if (part == "flap_with_integrated_seal") {
    flap_with_integrated_seal_for_printing();
} else if (part == "faceplate_gasket") {
    gasket_for_printing();
} else if (part == "flap_seal") {
    flap_seal_for_printing();
} else if (part == "conduit_gasket") {
    conduit_gasket();
} else if (part == "wall_mount_washer") {
    wall_mount_washer();
} else if (part == "hinge_clearance_check") {
    hinge_clearance_check(hinge_test_angle);
} else if (part == "layout") {
    body_for_printing();
    translate([170, 0, 0])
        faceplate_for_printing();
    translate([330, 0, 0])
        flap_for_printing();
    translate([490, 0, 0])
        flap_for_printing(true);
    translate([650, 0, 0])
        integrated_flap_seal_for_printing();
    translate([810, 0, 0])
        gasket_for_printing();
    translate([970, 0, 0])
        flap_seal_for_printing();
    translate([1120, 40, 0])
        conduit_gasket();
    translate([1180, 40, 0])
        wall_mount_washer();
} else {
    rotate([0, 0, 180])
        assembled();
}
