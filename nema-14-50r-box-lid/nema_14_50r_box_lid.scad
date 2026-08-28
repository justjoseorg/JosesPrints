/*
  NEMA 14-50R weatherproof lid for an existing square EMT box

  This is a lid only. It does not replace or include a wall box: it
  bolts directly to the two existing diagonal cover screws (top-left and
  bottom-right on this box) already tapped into a square EMT box that
  is already mounted on the wall with a NEMA 14-50R receptacle inside
  it. A shallow ASA shroud clears the receptacle face, and a top-hinged
  ASA flap, pinned with plain 1.75 mm filament running through printed
  knuckles, swings up so a cord can exit the bottom while a car is
  plugged in and closes down over a TPU seal when the receptacle is
  not in use.

  Defaults below are measured from this specific box: 3.65 in (92.7 mm)
  square internal opening, cover screws spaced 132 mm apart on the
  diagonal (top-left/bottom-right), 3 mm screw shank diameter. MEASURE
  YOUR OWN BOX, SCREW SPACING/POSITION, AND RECEPTACLE BEFORE PRINTING
  if yours differs.

  Printable part values: "lid", "flap", "lid_gasket", "flap_seal".
  Diagnostic/view values: "hinge_clearance_check",
  "seal_compression_check", "layout", "assembled".
*/

$fn = 64;

part = "assembled"; // lid, flap, lid_gasket, flap_seal, hinge_clearance_check, seal_compression_check, layout, assembled
preview_flap_angle = 100;
hinge_test_angle = 90;

// ===================== Existing wall box (MEASURE YOURS) =====================
box_face_width = 92.7;        // 3.65 in measured internal box opening
box_face_height = 92.7;
box_mount_diagonal = 132;    // measured diagonal spacing of the box's own top-left/bottom-right screws
box_mount_offset =
    box_mount_diagonal / (2 * sqrt(2)); // per-axis offset of each screw from the box/lid center
box_mount_screw_clearance = 3.6;  // clearance hole for the box's 3mm-shank cover screws
box_mount_head_diameter = 6.5;    // clearance for a pan/oval screw head
box_mount_counterbore_depth = 3;

// ===================== Receptacle clearance =====================
// Round clearance for the receptacle's face/bezel only; the device
// itself stays mounted to the existing box, not to this lid.
receptacle_clearance_diameter = 55;

// ===================== Lid shroud =====================
lid_margin = 13;                               // lid overlap beyond the box face, each side
lid_width = box_face_width + 2 * lid_margin;   // 118.7
lid_height = box_face_height + 2 * lid_margin; // 118.7
lid_depth = 42;         // forward projection: hinge, closed flap, and room for a plugged-in cord bend
wall_thickness = 3.2;
flange_thickness = 5;   // back plate thickness against the box face
corner_radius = 10;

receptacle_center_x_lid = lid_width / 2;
receptacle_center_z_lid = lid_height / 2;

// ===================== Flap =====================
// The flap matches the lid's outside face so all four edges align when
// closed. Hinge clearance is provided by the axis offset, not by making
// the leaf shorter or wider than the lid.
flap_side_overlap = 0;
flap_bottom_overlap = 0;
flap_top_clearance = 0;
flap_width = lid_width + 2 * flap_side_overlap;
flap_height = lid_height - flap_top_clearance + flap_bottom_overlap;
flap_x = -flap_side_overlap;
flap_thickness = 4;
flap_seal_thickness = 2.4;
flap_seal_ring_width = 8;
flap_seal_compression = 0.4;
flap_closed_gap = flap_seal_thickness - flap_seal_compression;
flap_leaf_y_start = lid_depth + flap_closed_gap;

// ===================== Gaskets =====================
gasket_thickness = 2;
gasket_border = 12;

// ===================== Hinge (sized for raw 1.75 mm filament) =====================
hinge_pin_diameter = 1.75;
hinge_clearance = 0.25;
hinge_bore_diameter = hinge_pin_diameter + hinge_clearance;
hinge_outer_diameter = 10;
hinge_rotation_clearance = 0.6;
hinge_axis_z = lid_height + hinge_outer_diameter / 2 + hinge_rotation_clearance;
hinge_axis_y = lid_depth + 6;
hinge_anchor_height = 10;
hinge_left_start = 10;
hinge_outer_length = 20;
hinge_axial_clearance = 0.4; // one nozzle width at each knuckle joint
hinge_center_start =
    hinge_left_start + hinge_outer_length + hinge_axial_clearance;
hinge_center_length =
    lid_width
    - 2 * (hinge_left_start + hinge_outer_length + hinge_axial_clearance);

assert(
    receptacle_clearance_diameter < min(lid_width, lid_height) - 2 * lid_margin,
    "Receptacle clearance must fit inside the box opening."
);
assert(
    box_mount_offset * 2 < min(lid_width, lid_height),
    "Increase lid_margin so both mounting holes stay on the lid."
);
assert(
    flange_thickness < lid_depth,
    "The back plate must be thinner than the overall lid depth."
);
assert(
    hinge_left_start + hinge_outer_length + hinge_axial_clearance
        <= hinge_center_start + flap_x + 0.001,
    "Hinge barrels overlap; adjust hinge_left_start/outer_length/center_start."
);
assert(
    hinge_center_start + flap_x + hinge_center_length + hinge_axial_clearance
        <= lid_width - hinge_left_start - hinge_outer_length + 0.001,
    "Hinge barrels overlap; adjust hinge_left_start/outer_length/center_start."
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

module hinge_anchor(
    start,
    length,
    leaf_y_min,
    leaf_y_max,
    leaf_z_top
) {
    hull() {
        translate([start, hinge_axis_y, hinge_axis_z])
            cylinder_x(length, hinge_outer_diameter);

        translate([start, leaf_y_min, leaf_z_top - hinge_anchor_height])
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
    leaf_y_max,
    leaf_z_top
) {
    difference() {
        hinge_anchor(start, length, leaf_y_min, leaf_y_max, leaf_z_top);

        translate([start - 0.1, hinge_axis_y, hinge_axis_z])
            cylinder_x(length + 0.2, hinge_bore_diameter);
    }
}

module stationary_hinge_barrel(start, length) {
    support_z_min = lid_height - hinge_anchor_height;
    support_z_max = hinge_axis_z + hinge_outer_diameter / 2;
    support_front_y = lid_depth;
    support_slice = 0.4;

    difference() {
        union() {
            translate([start, hinge_axis_y, hinge_axis_z])
                cylinder_x(length, hinge_outer_diameter);

            // The support rises gradually from the back plate but never
            // passes the lid's front rim inside the TPU seal envelope.
            hull() {
                translate([
                    start,
                    flange_thickness - support_slice / 2,
                    support_z_min
                ])
                    cube([
                        length,
                        support_slice,
                        hinge_anchor_height
                    ]);

                translate([
                    start,
                    support_front_y - support_slice,
                    support_z_min
                ])
                    cube([
                        length,
                        support_slice,
                        support_z_max - support_z_min
                    ]);
            }

            // Bridge from the rim to the barrel above the flap. Its
            // underside stays exactly one rotation-clearance gap above
            // the axis-aligned flap and full-perimeter TPU seal.
            translate([
                start,
                lid_depth,
                lid_height + hinge_rotation_clearance
            ])
                cube([
                    length,
                    hinge_axis_y - lid_depth,
                    hinge_outer_diameter
                ]);
        }

        translate([start - 0.1, hinge_axis_y, hinge_axis_z])
            cylinder_x(length + 0.2, hinge_bore_diameter);
    }
}

module lid_hinge_barrels() {
    for (start = [
        hinge_left_start,
        lid_width - hinge_left_start - hinge_outer_length
    ]) {
        stationary_hinge_barrel(
            start,
            hinge_outer_length
        );
    }
}

module flap_hinge_barrel() {
    // flap() shifts the leaf down by flap_bottom_overlap in Z, so the
    // leaf's true top surface sits at (flap_height - flap_bottom_overlap),
    // not at flap_height itself. The anchor cube must embed into that
    // true surface so it stays fully bonded to the leaf material.
    reinforced_hinge_barrel(
        hinge_center_start,
        hinge_center_length,
        flap_leaf_y_start,
        flap_leaf_y_start + flap_thickness,
        flap_height - flap_bottom_overlap
    );
}

module lid_shell() {
    union() {
        // Shallow shroud walls, open front and open back except for the
        // back plate below, rising from the box face to the front rim.
        ring_front_prism(
            lid_width,
            lid_height,
            lid_depth,
            corner_radius,
            wall_thickness
        );

        // Back plate: solid, contacts the box face, carries the two
        // mounting holes and the receptacle clearance opening.
        front_prism(
            lid_width,
            lid_height,
            flange_thickness,
            corner_radius
        );

        lid_hinge_barrels();
    }
}

module lid_cutouts() {
    translate([receptacle_center_x_lid, -0.1, receptacle_center_z_lid])
        cylinder_y(flange_thickness + 0.2, receptacle_clearance_diameter);

    for (signs = [[-1, 1], [1, -1]]) {  // top-left, bottom-right
        x = lid_width / 2 + signs[0] * box_mount_offset;
        z = lid_height / 2 + signs[1] * box_mount_offset;

        translate([x, -0.1, z])
            cylinder_y(
                flange_thickness + 0.2,
                box_mount_screw_clearance
            );

        translate([
            x,
            flange_thickness - box_mount_counterbore_depth,
            z
        ])
            cylinder_y(
                box_mount_counterbore_depth + 0.2,
                box_mount_head_diameter
            );
    }
}

module lid() {
    difference() {
        lid_shell();
        lid_cutouts();
    }
}

module lid_gasket() {
    difference() {
        ring_front_prism(
            lid_width,
            lid_height,
            gasket_thickness,
            corner_radius,
            gasket_border
        );

        translate([receptacle_center_x_lid, -0.1, receptacle_center_z_lid])
            cylinder_y(gasket_thickness + 0.2, receptacle_clearance_diameter);

        for (signs = [[-1, 1], [1, -1]]) {  // top-left, bottom-right
            x = lid_width / 2 + signs[0] * box_mount_offset;
            z = lid_height / 2 + signs[1] * box_mount_offset;

            translate([x, -0.1, z])
                cylinder_y(
                    gasket_thickness + 0.2,
                    box_mount_screw_clearance + 0.8
                );
        }
    }
}

module flap() {
    translate([0, flap_leaf_y_start, -flap_bottom_overlap])
        front_prism(flap_width, flap_height, flap_thickness, 8);
}

module flap_assembly() {
    union() {
        flap();
        flap_hinge_barrel();
    }
}

// A flat ring matching the flap leaf's own footprint, bonded to the
// flap's back face. It is 0.4 mm thicker than the nominal closed gap,
// giving controlled compression against the lid's flat front rim without
// a raised hard curb that could hold the flap open.
module flap_seal() {
    translate([0, flap_leaf_y_start - flap_seal_thickness, -flap_bottom_overlap])
        ring_front_prism(
            flap_width,
            flap_height,
            flap_seal_thickness,
            8,
            flap_seal_ring_width
        );
}

module receptacle_preview() {
    difference() {
        cylinder_y(4, receptacle_clearance_diameter - 4);

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

module lid_for_printing() {
    translate([0, hinge_axis_z + hinge_outer_diameter / 2, 0])
        rotate([90, 0, 0])
            lid();
}

module flap_for_printing() {
    translate([
        0,
        hinge_axis_z + hinge_outer_diameter / 2,
        flap_leaf_y_start + flap_thickness
    ])
        rotate([-90, 0, 0])
            flap_assembly();
}

module lid_gasket_for_printing() {
    translate([0, lid_height, 0])
        rotate([90, 0, 0])
            lid_gasket();
}

module flap_seal_for_printing() {
    translate([0, lid_height, 0])
        rotate([90, 0, 0])
            flap_seal();
}

module positioned_flap_assembly() {
    translate([flap_x, 0, 0])
        flap_assembly();
}

module positioned_flap_seal() {
    translate([flap_x, 0, 0])
        flap_seal();
}

module rotated_flap(angle) {
    hinge_global_y = hinge_axis_y;
    hinge_global_z = hinge_axis_z;

    translate([0, hinge_global_y, hinge_global_z])
        rotate([angle, 0, 0])
            translate([0, -hinge_global_y, -hinge_global_z])
                positioned_flap_assembly();
}

module hinge_clearance_check(angle) {
    intersection() {
        lid();
        rotated_flap(angle);
    }
}

module seal_compression_check() {
    intersection() {
        lid();
        positioned_flap_seal();
    }
}

module assembled() {
    color([0.76, 0.38, 0.08])
        lid();

    color([0.15, 0.15, 0.15])
        translate([0, 0, 0])
            lid_gasket();

    color([0.08, 0.08, 0.08])
        translate([
            receptacle_center_x_lid,
            flange_thickness - 0.2,
            receptacle_center_z_lid
        ])
            receptacle_preview();

    translate([0, hinge_axis_y, hinge_axis_z])
        rotate([preview_flap_angle, 0, 0])
            translate([0, -hinge_axis_y, -hinge_axis_z]) {
                color([0.85, 0.48, 0.12])
                    positioned_flap_assembly();

                color([0.15, 0.15, 0.15])
                    positioned_flap_seal();
            }

    color([0.55, 0.55, 0.58])
        translate([0, hinge_axis_y, hinge_axis_z])
            rotate([preview_flap_angle, 0, 0])
                cylinder_x(lid_width - 2 * hinge_left_start, hinge_pin_diameter);
}

if (part == "lid") {
    lid_for_printing();
} else if (part == "flap") {
    flap_for_printing();
} else if (part == "lid_gasket") {
    lid_gasket_for_printing();
} else if (part == "flap_seal") {
    flap_seal_for_printing();
} else if (part == "hinge_clearance_check") {
    hinge_clearance_check(hinge_test_angle);
} else if (part == "seal_compression_check") {
    seal_compression_check();
} else if (part == "layout") {
    lid_for_printing();

    translate([170, 0, 0])
        flap_for_printing();

    translate([340, 0, 0])
        lid_gasket_for_printing();

    translate([510, 0, 0])
        flap_seal_for_printing();
} else if (part == "assembled") {
    assembled();
}
