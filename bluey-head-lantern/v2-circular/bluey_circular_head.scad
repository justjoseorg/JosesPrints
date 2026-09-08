/*
  V2: Bluey-inspired cylindrical head with a circular flat base.
  Smooth solid master for slicer-controlled hollowing. Front is -Y.
  Independent of the preserved V1 sculpt. No texture or hanging hardware.
*/

$fn = 96;
part = "assembled"; // [head,assembled,layout,section]

// Rotationally symmetric, LEGO-like head body, mm.
head_radius = 72;
base_radius = 66;
base_bevel_height = 6;
crown_height = 124;
top_edge_radius = 10;
ear_tip_height = 181;
ear_y = -16;
detail_relief = 0.45;

// Features follow the cylindrical face instead of sitting on a flat panel.
eye_spacing = 56;
eye_size = [44, 24, 60];
eye_y = -61;
eye_z = 85;
eye_wrap_angle = 22;
pupil_width = 11;
pupil_height = 23;
pupil_look_x = 4;
muzzle_y = -68;
nose_y = -89;
brow_y = -61;

/* [Hidden] */
blue = "#83c5e8";
navy = "#363557";
pale_blue = "#cdeafa";
cream = "#f1d078";
white = "#fffdf0";
ink = "#222336";

assert(base_radius > 0 && base_radius < head_radius);
assert(base_bevel_height >= head_radius - base_radius,
       "Keep the outward rise from the circular base at 45 degrees or steeper.");
assert(top_edge_radius > 0 && top_edge_radius < head_radius / 2);
assert(crown_height > base_bevel_height + 2 * top_edge_radius);
assert(ear_tip_height > crown_height + 35);
assert(detail_relief >= 0.3 && detail_relief <= 0.8);
assert(eye_wrap_angle >= 0 && eye_wrap_angle <= 35);

module ellipsoid(center, radii, inset = 0) {
    translate(center)
        scale([for (r = radii) r - inset])
            sphere(r = 1);
}

module stroke_2d(points, width) {
    for (i = [0 : len(points) - 2])
        hull() {
            translate(points[i]) circle(d = width);
            translate(points[i + 1]) circle(d = width);
        }
}

module front_mask(depth = 110, back_y = -10) {
    if ($children > 0)
        translate([0, back_y, 0])
            rotate([90, 0, 0])
                linear_extrude(depth)
                    children();
    else
        translate([-100, back_y - depth, 0])
            cube([200, depth, 240]);
}

module head_volume(inset = 0) {
    // Revolving one radial profile makes the whole base circular, not an
    // added round pedestal beneath the V1 rounded-rectangle head.
    rotate_extrude()
        polygon(concat(
            [
                [0, -inset],
                [base_radius - inset, -inset],
                [head_radius - inset, base_bevel_height]
            ],
            [
                for (a = [0 : 3 : 90])
                    [
                        head_radius - top_edge_radius
                            + (top_edge_radius - inset) * cos(a),
                        crown_height - top_edge_radius
                            + (top_edge_radius - inset) * sin(a)
                    ]
            ],
            [[0, crown_height - inset]]
        ));
}

module ear_volume(side, inset = 0) {
    hull() {
        for (x = [29, 64], y = [-21, 10])
            translate([side * x, y + ear_y, 110])
                sphere(r = 6 - inset);
        for (y = [-14, -8])
            translate([side * 60, y + ear_y, ear_tip_height])
                sphere(r = 3 - inset);
    }
}

module eye_volume(side, inset = 0) {
    translate([side * eye_spacing / 2, eye_y, eye_z])
        rotate([0, 0, side * eye_wrap_angle])
            ellipsoid([0, 0, 0], eye_size / 2, inset);
}

module muzzle_volume(inset = 0) {
    hull() {
        ellipsoid([1, muzzle_y, 49], [31, 26, 28], inset);
        ellipsoid([5, muzzle_y + 2, 61], [24, 24, 23], inset);
    }
}

module nose_volume(inset = 0) {
    hull() {
        translate([-10, nose_y, 68]) sphere(r = 6 - inset);
        translate([12, nose_y, 68]) sphere(r = 6 - inset);
        translate([4, nose_y - 3, 55]) sphere(r = 5 - inset);
    }
}

module brow_volume(side, inset = 0) {
    translate([side * 34, brow_y, 119])
        rotate([0, side * 14, side * eye_wrap_angle])
            scale([18 - inset, 8 - inset, 8 - inset])
                sphere(r = 1);
}

module sculpt_volume() {
    head_volume();
    for (side = [-1, 1]) {
        ear_volume(side);
        eye_volume(side);
        brow_volume(side);
    }
    muzzle_volume();
    nose_volume();
}

module face_patch_2d(side) {
    scale([side, 1])
        offset(r = 5)
            polygon([
                [14, 114], [27, 124], [59, 122], [73, 110],
                [75, 55], [63, 47], [48, 47], [34, 53],
                [25, 66], [16, 89]
            ]);
}

module ear_panel_2d(side) {
    scale([side, 1])
        offset(r = 2)
            polygon([[37, 121], [59, 121], [59, ear_tip_height - 17]]);
}

module facial_details() {
    // Relief carriers stay filled: their buried volume is inside the solid
    // sculpt, so no thin cosmetic shells or fixed lantern walls are needed.
    color(navy)
        for (side = [-1, 1]) {
            intersection() {
                head_volume(-detail_relief);
                front_mask() face_patch_2d(side);
            }
            ear_volume(side, -0.12);
        }

    color(cream)
        for (side = [-1, 1])
            intersection() {
                ear_volume(side, -detail_relief);
                front_mask(back_y = -16 + ear_y) ear_panel_2d(side);
            }

    color(pale_blue) {
        intersection() {
            head_volume(-0.22);
            front_mask()
                translate([-7, 40]) scale([34, 19]) circle(r = 1);
        }
        for (side = [-1, 1])
            brow_volume(side, -0.15);
    }

    color(cream)
        intersection() {
            muzzle_volume(-0.15);
            front_mask();
        }

    color(white)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -0.15);
                front_mask();
            }

    color(ink)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -detail_relief - 0.15);
                front_mask()
                    translate([side * eye_spacing / 2 + pupil_look_x, eye_z + 1])
                        scale([pupil_width / 2, pupil_height / 2]) circle(r = 1);
            }

    color(white)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -detail_relief - 0.35);
                front_mask()
                    translate([
                        side * eye_spacing / 2 + pupil_look_x - 1.5,
                        eye_z + 6
                    ])
                        circle(r = 1.4);
            }

    color(navy) nose_volume(-0.15);
    color("#8f94ad")
        intersection() {
            nose_volume(-detail_relief - 0.15);
            front_mask()
                translate([1, 70]) scale([8.5, 1.8]) circle(r = 1);
        }

    color("#79603b")
        intersection() {
            muzzle_volume(-detail_relief - 0.15);
            front_mask() {
                stroke_2d([
                    [-21, 46], [-22, 42], [-20.8, 37], [-17.4, 33],
                    [-12, 30.5], [-5, 29.5], [3, 29.7],
                    [11, 31], [17, 34]
                ], 1.15);
                stroke_2d([[-26, 43], [-23, 46], [-19, 47]], 1.15);
            }
        }
}

module forehead_tuft() {
    color(blue)
        front_mask(depth = 12, back_y = -12 + ear_y)
            offset(r = 1)
                polygon([
                    [-14, crown_height - 5], [-5, crown_height + 11],
                    [1, crown_height + 3], [6, crown_height + 7],
                    [14, crown_height - 5]
                ]);
}

module head() {
    difference() {
        union() {
            color(blue) sculpt_volume();
            facial_details();
            forehead_tuft();
        }
        translate([-150, -150, -100]) cube([300, 300, 100]);
    }
}

if (part == "head" || part == "assembled" || part == "layout") head();
else if (part == "section")
    difference() {
        head();
        translate([-160, 0, -1]) cube([320, 160, 240]);
    }
else assert(false, str("Unknown part selector: ", part));
