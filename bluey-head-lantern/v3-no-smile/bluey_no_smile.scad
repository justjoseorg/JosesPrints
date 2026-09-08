/*
  V3: single-piece rounded V1 Bluey head, no smile.
  Solid master for slicer-controlled hollowing. The hollow crown needs support.
  Front is -Y. No hook and no surface texture.
*/

$fn = 96;
part = "assembled"; // [head,assembled,layout,section]

// Original V1 rounded, plush-like head proportions, mm.
head_width = 144;
head_depth = 112;
cheek_radius = 45;
cheek_center_z = 30;
crown_height = 124;
crown_radius = 40;
forehead_width = 132;
forehead_depth = 104;
ear_tip_height = 181;
ear_y = 0;

// Print-friendly facial volumes and shallow markings.
eye_spacing = 56;
eye_size = [44, 20, 60];
eye_y = -46;
eye_z = 85;
eye_wrap_angle = 0;
pupil_width = 11;
pupil_height = 23;
pupil_look_x = 4;
muzzle_y = -52;
muzzle_depth = 22;
muzzle_root_y = -32;
muzzle_top_root_y = -25;
muzzle_root_bottom = 4;
muzzle_root_top = 100;
brow_y = -31;
brow_root_z = 107;
detail_relief = 0.2;

/* [Hidden] */
blue = "#83c5e8";
navy = "#363557";
pale_blue = "#cdeafa";
cream = "#f1d078";
white = "#fffdf0";
ink = "#222336";

assert(cheek_radius > cheek_center_z);
assert(head_width > 2 * cheek_radius && head_depth > 2 * cheek_radius);
assert(forehead_width > 2 * crown_radius && forehead_depth > 2 * crown_radius);
assert(ear_tip_height > crown_height + 35);
assert(detail_relief > 0 && detail_relief <= 0.2,
       "Keep the raised detail steps at most 0.2 mm.");

module ellipsoid(center, radii, inset = 0) {
    translate(center)
        scale([for (r = radii) r - inset])
            sphere(r = 1);
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
    hull() {
        for (x = [-1, 1], y = [-1, 1])
            translate([
                x * (head_width / 2 - cheek_radius),
                y * (head_depth / 2 - cheek_radius),
                cheek_center_z
            ])
                sphere(r = cheek_radius - inset);
        for (x = [-1, 1], y = [-1, 1])
            translate([
                x * (forehead_width / 2 - crown_radius),
                y * (forehead_depth / 2 - crown_radius),
                crown_height - crown_radius
            ])
                sphere(r = crown_radius - inset);
    }
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
    // Tangent lower/upper blends replace the unsupported spherical chin and
    // the abrupt inward closure above it, while retaining a rounded snout.
    hull() {
        ellipsoid([1, muzzle_y, 49], [31, muzzle_depth, 28], inset);
        ellipsoid([5, muzzle_y + 2, 61], [24, muzzle_depth, 23], inset);
        ellipsoid([1, muzzle_root_y, muzzle_root_bottom], [17, 12, 2], inset);
        ellipsoid([1, muzzle_top_root_y, muzzle_root_top], [17, 12, 2], inset);
    }
}

module nose_volume(inset = 0) {
    // A curved relief avoids a projecting nose's hidden inner-wall bridge.
    intersection() {
        muzzle_volume(inset - detail_relief);
        front_mask()
            offset(r = 3)
                polygon([[-12, 69], [14, 69], [4, 57]]);
    }
}

module brow_volume(side, inset = 0) {
    hull() {
        translate([side * 34, brow_y, 119])
            rotate([0, side * 14, side * eye_wrap_angle])
                scale([18 - inset, 8 - inset, 8 - inset])
                    sphere(r = 1);
        ellipsoid([side * 34, -33, brow_root_z], [14, 3, 1], inset);
    }
}

module sculpt_volume() {
    head_volume();
    for (side = [-1, 1]) {
        ear_volume(side);
        eye_volume(side);
        brow_volume(side);
    }
    muzzle_volume();
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
    color(navy)
        for (side = [-1, 1]) {
            intersection() {
                head_volume(-detail_relief);
                front_mask() face_patch_2d(side);
            }
            ear_volume(side, -0.1);
        }

    color(cream)
        for (side = [-1, 1])
            intersection() {
                ear_volume(side, -detail_relief);
                front_mask(back_y = -16 + ear_y) ear_panel_2d(side);
            }

    color(pale_blue) {
        intersection() {
            head_volume(-0.1);
            front_mask()
                translate([-7, 40]) scale([34, 19]) circle(r = 1);
        }
        for (side = [-1, 1]) brow_volume(side, -0.1);
    }

    color(cream) {
        intersection() { muzzle_volume(-0.1); front_mask(); }
    }
    color(white)
        for (side = [-1, 1])
            intersection() { eye_volume(side, -0.1); front_mask(); }

    color(ink)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -detail_relief - 0.1);
                front_mask()
                    translate([side * eye_spacing / 2 + pupil_look_x, eye_z + 1])
                        scale([pupil_width / 2, pupil_height / 2]) circle(r = 1);
            }
    color(white)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -detail_relief - 0.2);
                front_mask()
                    translate([
                        side * eye_spacing / 2 + pupil_look_x - 1.5,
                        eye_z + 6
                    ])
                        circle(r = 1.4);
            }

    color(navy) nose_volume(-0.1);
    color("#8f94ad")
        intersection() {
            nose_volume(-detail_relief - 0.1);
            front_mask()
                translate([1, 70]) scale([8.5, 1.2]) circle(r = 1);
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
