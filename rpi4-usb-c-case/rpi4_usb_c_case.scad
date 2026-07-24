/*
  Minimal Raspberry Pi 4 Model B enclosure

  External access is limited to the USB-C power connector. Install the
  microSD card before closing the case. A shallow internal rim on the
  lid aligns the seam, while two horizontal snap hooks positively lock
  into the base. Two short split pegs retain the board.

  Set part to "base", "lid", "both", or "assembled".
*/

$fn = 48;

part = "both";
ventilation = true;

wall = 1.6;
floor_thickness = 1.6;
roof_thickness = 1.6;
corner_radius = 3.5;

board_length = 85;
board_width = 56;
board_thickness = 1.4;
board_standoff = 1.8;
usb_stack_height = 15.5;
usb_port_overhang = 4.5;
connector_clearance = 1.0;

left_overhang = 2.5;
right_overhang = 5.5;
front_overhang = 3.0;
back_clearance = 0.8;

base_height = 20.5;
case_height = 23.5;

usb_c_center_x = 11.2;
usb_c_cable_width = 11;
usb_c_cable_height = 6;
usb_c_cable_clearance = 0.75;
usb_c_opening_width =
    usb_c_cable_width + 2 * usb_c_cable_clearance;
usb_c_opening_height =
    usb_c_cable_height + 2 * usb_c_cable_clearance;

board_boss_diameter = 5.5;
board_locating_pin_diameter = 2.45;
board_snap_head_diameter = 3.05;
board_snap_head_height = 0.6;
board_snap_slot = 0.5;

lid_skirt_bottom_z = 19.7;
lid_skirt_wall = 1.2;
lid_fit_clearance = 0.2;
snap_beam_length = 18;
snap_beam_thickness = 1.0;
snap_beam_height = 1.2;
snap_beam_bottom_z = 19.5;
snap_hook_width = 3.0;
snap_hook_depth = 0.5;
snap_hook_height = 0.6;
snap_anchor_overlap = 0.8;
snap_relief = 0.25;

inner_length = left_overhang + board_length + right_overhang;
inner_width = front_overhang + board_width + back_clearance;
cavity_offset = wall;
case_length = inner_length + 2 * cavity_offset;
case_width = inner_width + 2 * cavity_offset;

board_x = cavity_offset + left_overhang;
board_y = cavity_offset + front_overhang;
board_bottom_z = floor_thickness + board_standoff;
board_top_z = board_bottom_z + board_thickness;
roof_bottom_z = case_height - roof_thickness;

assert(
    right_overhang >= usb_port_overhang + connector_clearance,
    "Increase right_overhang to clear the USB connector faces."
);
assert(
    roof_bottom_z
        >= board_bottom_z + usb_stack_height + connector_clearance,
    "Increase case_height to clear the stacked USB ports."
);
assert(
    snap_beam_bottom_z + snap_hook_height
        <= base_height - 0.2,
    "Snap hooks need a retaining ledge above their grooves."
);

mounting_holes = [
    [3.5, 3.5],
    [61.5, 3.5],
    [3.5, 52.5],
    [61.5, 52.5]
];

snap_center_x = case_length / 2;
snap_start_x = snap_center_x - snap_beam_length / 2;
snap_end_x = snap_center_x + snap_beam_length / 2;
snap_hook_x = snap_end_x - snap_hook_width;

module rounded_rectangle(size, radius) {
    translate([radius, radius])
        offset(r = radius)
            square([
                size[0] - 2 * radius,
                size[1] - 2 * radius
            ]);
}

module rounded_prism(size, height, radius) {
    linear_extrude(height = height)
        rounded_rectangle(size, radius);
}

module case_outer(height) {
    rounded_prism(
        [case_length, case_width],
        height,
        corner_radius
    );
}

module usb_c_cutout() {
    connector_center_z = board_bottom_z + 1.6;
    opening_bottom =
        connector_center_z - usb_c_opening_height / 2;

    translate([
        board_x + usb_c_center_x - usb_c_opening_width / 2,
        -0.1,
        opening_bottom
    ])
        cube([
            usb_c_opening_width,
            cavity_offset + front_overhang + 0.2,
            usb_c_opening_height
        ]);
}

module mounting_bosses() {
    for (index = [0 : len(mounting_holes) - 1]) {
        hole = mounting_holes[index];

        translate([
            board_x + hole[0],
            board_y + hole[1],
            floor_thickness
        ])
            cylinder(
                h = board_standoff,
                d = board_boss_diameter
            );

        translate([
            board_x + hole[0],
            board_y + hole[1],
            board_bottom_z
        ])
            if (index == 0 || index == 3) {
                difference() {
                    union() {
                        cylinder(
                            h = board_thickness + 0.1,
                            d = board_locating_pin_diameter
                        );

                        translate([
                            0,
                            0,
                            board_thickness + 0.1
                        ])
                            cylinder(
                                h = board_snap_head_height,
                                d1 = board_snap_head_diameter,
                                d2 = board_locating_pin_diameter
                            );
                    }

                    translate([
                        -board_snap_slot / 2,
                        -board_snap_head_diameter,
                        -0.1
                    ])
                        cube([
                            board_snap_slot,
                            2 * board_snap_head_diameter,
                            board_thickness
                                + board_snap_head_height
                                + 0.3
                        ]);
                }
            } else {
                cylinder(
                    h = board_thickness,
                    d = board_locating_pin_diameter
                );
            }
    }
}

module base_snap_grooves() {
    groove_width = snap_hook_width + 0.5;
    groove_depth = snap_hook_depth + 0.15;
    groove_height = snap_hook_height + 0.3;

    translate([
        snap_hook_x - 0.25,
        cavity_offset - groove_depth,
        snap_beam_bottom_z - 0.1
    ])
        cube([
            groove_width,
            groove_depth + 0.1,
            groove_height
        ]);

    translate([
        snap_hook_x - 0.25,
        case_width - cavity_offset - 0.1,
        snap_beam_bottom_z - 0.1
    ])
        cube([
            groove_width,
            groove_depth + 0.1,
            groove_height
        ]);
}

module base() {
    difference() {
        union() {
            difference() {
                case_outer(base_height);

                translate([
                    cavity_offset,
                    cavity_offset,
                    floor_thickness
                ])
                    rounded_prism(
                        [inner_length, inner_width],
                        base_height,
                        corner_radius - wall
                    );
            }

            mounting_bosses();
        }

        usb_c_cutout();
        base_snap_grooves();
    }
}

module rounded_slot(length, width, height) {
    hull() {
        translate([-length / 2 + width / 2, 0, 0])
            cylinder(h = height, d = width);
        translate([length / 2 - width / 2, 0, 0])
            cylinder(h = height, d = width);
    }
}

module roof_vents() {
    slot_length = 34;
    slot_width = 1.8;
    slot_spacing = 4.2;

    for (index = [-3 : 3]) {
        translate([
            board_x + 38,
            board_y + 28 + index * slot_spacing,
            roof_bottom_z - 0.1
        ])
            rounded_slot(
                slot_length,
                slot_width,
                roof_thickness + 0.2
            );
    }
}

module lid_skirt() {
    skirt_offset = cavity_offset + lid_fit_clearance;
    skirt_length = case_length - 2 * skirt_offset;
    skirt_width = case_width - 2 * skirt_offset;
    skirt_height = roof_bottom_z - lid_skirt_bottom_z;

    difference() {
        translate([
            skirt_offset,
            skirt_offset,
            lid_skirt_bottom_z
        ])
            difference() {
                rounded_prism(
                    [skirt_length, skirt_width],
                    skirt_height,
                    corner_radius - skirt_offset
                );

            translate([
                lid_skirt_wall,
                lid_skirt_wall,
                -0.1
            ])
                rounded_prism(
                    [
                        skirt_length - 2 * lid_skirt_wall,
                        skirt_width - 2 * lid_skirt_wall
                    ],
                    skirt_height + 0.2,
                    corner_radius
                        - skirt_offset
                        - lid_skirt_wall
                );
            }

        snap_beam_reliefs();
    }
}

module snap_beam_reliefs() {
    front_y = cavity_offset + lid_fit_clearance;
    back_y = case_width - front_y - lid_skirt_wall;
    relief_height = snap_beam_height + 2 * snap_relief;

    translate([
        snap_start_x,
        front_y - snap_relief,
        snap_beam_bottom_z - snap_relief
    ])
        cube([
            snap_beam_length + snap_relief,
            lid_skirt_wall + 2 * snap_relief,
            relief_height
        ]);

    translate([
        snap_start_x,
        back_y - snap_relief,
        snap_beam_bottom_z - snap_relief
    ])
        cube([
            snap_beam_length + snap_relief,
            lid_skirt_wall + 2 * snap_relief,
            relief_height
        ]);
}

module front_snap_beam() {
    front_y = cavity_offset + lid_fit_clearance;

    translate([
        snap_start_x - snap_anchor_overlap,
        front_y,
        snap_beam_bottom_z
    ])
        cube([
            snap_beam_length + snap_anchor_overlap,
            snap_beam_thickness,
            snap_beam_height
        ]);

    hull() {
        translate([
            snap_hook_x,
            front_y - 0.1,
            snap_beam_bottom_z
        ])
            cube([snap_hook_width, 0.1, 0.1]);

        translate([
            snap_hook_x,
            front_y - snap_hook_depth,
            snap_beam_bottom_z + snap_hook_height - 0.1
        ])
            cube([
                snap_hook_width,
                snap_hook_depth,
                0.1
            ]);
    }
}

module back_snap_beam() {
    mirror([0, 1, 0])
        translate([0, -case_width, 0])
            front_snap_beam();
}

module lid_snap_beams() {
    front_snap_beam();
    back_snap_beam();
}

module lid_assembled() {
    difference() {
        union() {
            difference() {
                translate([0, 0, base_height])
                    case_outer(case_height - base_height);

                translate([
                    cavity_offset,
                    cavity_offset,
                    base_height - 0.1
                ])
                    rounded_prism(
                        [inner_length, inner_width],
                        roof_bottom_z - base_height + 0.1,
                        corner_radius - wall
                    );
            }

            lid_skirt();
            lid_snap_beams();
        }

        usb_c_cutout();

        if (ventilation) {
            roof_vents();
        }
    }
}

module lid_for_printing() {
    translate([0, case_width, case_height])
        rotate([180, 0, 0])
            lid_assembled();
}

if (part == "base") {
    base();
} else if (part == "lid") {
    lid_for_printing();
} else if (part == "assembled") {
    base();
    lid_assembled();
} else {
    base();
    translate([case_length + 10, 0, 0])
        lid_for_printing();
}
