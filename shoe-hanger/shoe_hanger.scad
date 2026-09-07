/*
  Modular three-level shoe hanger

  Print:
    - 1 hanger_adapter
    - 3 shoe_level

  The hanger adapter hooks around the bottom bar of a sturdy clothes
  hanger. Every shoe level slides onto the wide bayonet tongue above it,
  drops into a gravity-locked pocket, holds one pair of shoes, and
  provides the same tongue for the next level.

  All parts are already in their support-free print orientation.
*/

$fn = 144;

part = "assembled"; // "hanger_adapter", "shoe_level", or "assembled"

// General
level_thickness = 8;
adapter_thickness = 10;

// Existing clothes hanger
hanger_bar_d = 10;             // Measure the hanger's bottom bar
hanger_bar_clearance = 0.7;
hanger_socket_depth = 19;      // How far the socket reaches around the bar
hanger_socket_wall = 5.5;
hanger_socket_width = 22;      // Contact length along the hanger bar
hanger_socket_snap = 0.4;      // Throat is this much smaller than the bar
hanger_socket_center = hanger_socket_depth - 8;
adapter_connector_y = -52;
adapter_stem_w = 24;

// One repeated shoe level
level_pitch = 170;          // Connector-to-connector spacing
level_spine_w = 24;
crossbar_y = -76;
crossbar_w = 150;
crossbar_h = 11;

shoe_hook_x = 48;           // 96 mm between shoe supports
shoe_hook_w = 9;
shoe_hook_outer_x = 80;
shoe_hook_top_y = 14;
shoe_hook_tip_y = -20;

// Wide side-entry bayonet connector
connector_tongue_w = 42;
connector_tongue_h = 14;
connector_clearance = 0.4;
connector_drop = 9;
connector_block_w = 82;
connector_block_h = 50;
connector_root_w = 66;
connector_root_h = 32;
connector_depth_clearance = 0.5;
connector_cap_w = 56;
connector_cap_h = 24;
connector_cap_ramp = 7;
connector_cap_lip = 2;

assert(level_pitch <= 170,
       "The shoe level may not fit a 220 mm print bed.");
assert(connector_cap_w > connector_tongue_w + 4,
       "The connector cap needs retaining shoulders.");
assert(connector_block_w > connector_cap_w + 12,
       "The receiver needs material around the connector cap.");

module rounded_rect_2d(size, radius) {
    w = size[0];
    h = size[1];
    hull()
        for (x = [-w / 2 + radius, w / 2 - radius])
            for (y = [-h / 2 + radius, h / 2 - radius])
                translate([x, y])
                    circle(r = radius);
}

module stroke_2d(points, width) {
    for (i = [0 : len(points) - 2])
        hull() {
            translate(points[i])
                circle(d = width);
            translate(points[i + 1])
                circle(d = width);
        }
}

module connector_slot_2d() {
    slot_w = connector_tongue_w + 2 * connector_clearance;
    slot_h = connector_tongue_h + 2 * connector_clearance;
    entry_y = -connector_drop;

    union() {
        // Vertical leg: release only after lifting against gravity.
        hull() {
            rounded_rect_2d([slot_w, slot_h], 2);
            translate([0, entry_y])
                rounded_rect_2d([slot_w, slot_h], 2);
        }

        // Horizontal leg: the only insertion/removal path.
        translate([
            -slot_w / 2,
            entry_y - slot_h / 2
        ])
            square([
                connector_block_w / 2 + slot_w / 2 + 0.5,
                slot_h
            ]);
    }
}

module connector_receiver_2d() {
    difference() {
        rounded_rect_2d(
            [connector_block_w, connector_block_h],
            5
        );
        connector_slot_2d();
    }
}

module connector_root_2d() {
    rounded_rect_2d(
        [connector_root_w, connector_root_h],
        5
    );
}

// Printable side-entry socket for a horizontal hanger bar. Local X is
// print height / assembled depth; local Y is the model's vertical axis.
module hanger_socket_profile_2d() {
    cavity_r = hanger_bar_d / 2 + hanger_bar_clearance;
    throat_r = (hanger_bar_d - hanger_socket_snap) / 2;
    outer_half_h = cavity_r + hanger_socket_wall;

    difference() {
        polygon([
            [0, -outer_half_h],
            [hanger_socket_depth - 3, -outer_half_h],
            [hanger_socket_depth, -outer_half_h + 3],
            [hanger_socket_depth, outer_half_h - 3],
            [hanger_socket_depth - 3, outer_half_h],
            [0, outer_half_h]
        ]);

        union() {
            translate([hanger_socket_center, 0])
                circle(r = cavity_r);

            translate([hanger_socket_center, -throat_r])
                square([
                    hanger_socket_depth - hanger_socket_center + 0.2,
                    throat_r * 2
                ]);
        }
    }
}

module hanger_socket() {
    translate([0, 0, adapter_thickness])
        rotate([0, -90, 0])
            linear_extrude(hanger_socket_width, center = true)
                hanger_socket_profile_2d();
}

// The receiver plate is trapped between the root and cap. The tongue
// carries vertical load across a broad face; the cap prevents peeling.
module connector_tongue(x, y, plate_top_z) {
    gap = level_thickness + connector_depth_clearance;
    overlap = 0.25;

    translate([x, y, plate_top_z - overlap])
        linear_extrude(gap + overlap)
            rounded_rect_2d(
                [connector_tongue_w, connector_tongue_h],
                2
            );

    translate([x, y, plate_top_z + gap - overlap])
        linear_extrude(
            height = connector_cap_ramp + overlap,
            scale = [
                connector_cap_w / connector_tongue_w,
                connector_cap_h / connector_tongue_h
            ]
        )
            rounded_rect_2d(
                [connector_tongue_w, connector_tongue_h],
                2
            );

    translate([
        x,
        y,
        plate_top_z + gap + connector_cap_ramp - overlap
    ])
        linear_extrude(connector_cap_lip + overlap)
            rounded_rect_2d(
                [connector_cap_w, connector_cap_h],
                4
            );
}

module hanger_adapter_2d() {
    socket_half_h =
        hanger_bar_d / 2 + hanger_bar_clearance + hanger_socket_wall;
    stem_top = -socket_half_h + 2.2;
    stem_bottom = adapter_connector_y - 6;
    stem_h = stem_top - stem_bottom;

    union() {
        translate([0, 0])
            rounded_rect_2d(
                [hanger_socket_width, socket_half_h * 2],
                3
            );

        translate([0, stem_bottom + stem_h / 2])
            rounded_rect_2d([adapter_stem_w, stem_h], 3);

        translate([0, adapter_connector_y])
            connector_root_2d();
    }
}

module hanger_adapter() {
    union() {
        linear_extrude(adapter_thickness)
            hanger_adapter_2d();

        hanger_socket();
        connector_tongue(
            0,
            adapter_connector_y,
            adapter_thickness
        );
    }
}

module shoe_hook_2d(side) {
    points = [
        [side * shoe_hook_x, crossbar_y],
        [side * shoe_hook_x, -12],
        [side * (shoe_hook_x + 2), 0],
        [side * (shoe_hook_x + 8), 9],
        [side * (shoe_hook_x + 16), shoe_hook_top_y],
        [side * (shoe_hook_outer_x - 8), shoe_hook_top_y - 1],
        [side * (shoe_hook_outer_x - 2), 7],
        [side * shoe_hook_outer_x, -3],
        [side * shoe_hook_outer_x, shoe_hook_tip_y]
    ];

    stroke_2d(points, shoe_hook_w);
}

module shoe_level_2d() {
    spine_top = -connector_block_h / 2 + 12;
    spine_bottom = -level_pitch - 8;
    spine_h = spine_top - spine_bottom;

    union() {
        connector_receiver_2d();

        translate([0, spine_bottom + spine_h / 2])
            rounded_rect_2d([level_spine_w, spine_h], 3);

        translate([0, crossbar_y])
            rounded_rect_2d([crossbar_w, crossbar_h], 4);

        shoe_hook_2d(-1);
        shoe_hook_2d(1);

        // Short diagonal ribs keep the wide pair bar stiff without bulk.
        stroke_2d([
            [-level_spine_w / 2 + 1, crossbar_y - 21],
            [-shoe_hook_x, crossbar_y]
        ], 7);
        stroke_2d([
            [level_spine_w / 2 - 1, crossbar_y - 21],
            [shoe_hook_x, crossbar_y]
        ], 7);

        translate([0, -level_pitch])
            connector_root_2d();
    }
}

module shoe_level() {
    union() {
        linear_extrude(level_thickness)
            shoe_level_2d();

        connector_tongue(
            0,
            -level_pitch,
            level_thickness
        );
    }
}

module assembled() {
    module_y0 = adapter_connector_y;
    module_z0 =
        adapter_thickness + connector_depth_clearance / 2;
    module_step_z =
        level_thickness + connector_depth_clearance / 2;

    cavity_center_z =
        adapter_thickness + hanger_socket_center;

    color("silver")
        translate([-145, 0, cavity_center_z])
            rotate([0, 90, 0])
                cylinder(h = 290, d = hanger_bar_d);

    color("#F28C28")
        hanger_adapter();

    for (i = [0 : 2])
        color(i % 2 == 0 ? "#2F80ED" : "#56CC9D")
            translate([
                0,
                module_y0 - i * level_pitch,
                module_z0 + i * module_step_z
            ])
                shoe_level();
}

if (part == "hanger_adapter") {
    hanger_adapter();
} else if (part == "shoe_level") {
    shoe_level();
} else if (part == "assembled") {
    assembled();
}
