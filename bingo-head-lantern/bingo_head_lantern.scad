/*
  Bingo-inspired adaptation of the rounded Bluey V3 head.
  One-piece solid master for slicer-controlled hollowing; no mouth line.
  Front is -Y, flat base is Z=0. Hollow printing requires crown supports.
*/

$fn = 192;
part = "assembled"; // [head,assembled,layout,section]

/* [Rounded head] */
head_width = 136;
head_depth = 108;
cheek_radius = 43;
cheek_center_z = 29;
crown_height = 114;
crown_radius = 38;
forehead_width = 126;
forehead_depth = 100;

/* [Ears] */
ear_root_height = 100;
ear_root_inner = 28;
ear_root_outer = 58;
ear_tip_height = 152;
ear_tip_x = 55;
ear_y = 0;

/* [Face] */
eye_spacing = 52;
eye_size = [43, 20, 56];
eye_y = -44;
eye_z = 78;
pupil_width = 11;
pupil_height = 22;
pupil_look_x = 3;
eye_patch_margin = [8, 10];
muzzle_y = -50;
muzzle_depth = 20;
muzzle_root_y = -31;
muzzle_top_root_y = -24;
muzzle_root_bottom = 5;
muzzle_root_top = 90;
brow_y = -31;
brow_z = 109;
brow_root_z = 99;
detail_relief = 0.2;

/* [Colors] */
coat_color = "#F3A64D";
patch_color = "#D97732";
inner_ear_color = "#F8C781";
cream_color = "#FFF0BF";
eye_color = "#FFFEF5";
pupil_color = "#29231E";
nose_color = "#5C3A22";
nose_highlight_color = "#C99562";

/* [Hidden] */
assert(cheek_radius > cheek_center_z && cheek_center_z > 0,
       "The rounded head must intersect the flat print plane.");
assert(head_width > 2 * cheek_radius && head_depth > 2 * cheek_radius);
assert(crown_radius > 0 && forehead_width > 2 * crown_radius
       && forehead_depth > 2 * crown_radius);
assert(crown_height > crown_radius && crown_height < 200);
assert(ear_root_inner > 6 && ear_root_outer > ear_root_inner);
assert(ear_root_outer + 6 < head_width / 2);
assert(ear_root_height < crown_height && ear_root_height > cheek_center_z);
assert(ear_tip_height > crown_height + 20 && ear_tip_height < 230);
assert(ear_tip_x >= ear_root_inner && ear_tip_x <= ear_root_outer);
assert(eye_spacing > eye_size[0] && min(eye_size) > 0);
assert(pupil_width > 0 && pupil_height > 0);
assert(abs(pupil_look_x) + pupil_width / 2 < eye_size[0] / 2);
assert(pupil_height + 2 < eye_size[2]);
assert(min(eye_patch_margin) > 0);
assert(muzzle_depth > 0 && muzzle_root_bottom > 2);
assert(muzzle_root_top > muzzle_root_bottom && muzzle_root_top < crown_height);
assert(brow_root_z < brow_z && brow_z < crown_height);
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
        for (x = [ear_root_inner, ear_root_outer], y = [-20, 10])
            translate([side * x, y + ear_y, ear_root_height])
                sphere(r = 6 - inset);
        for (y = [-14, -8])
            translate([side * ear_tip_x, y + ear_y, ear_tip_height])
                sphere(r = 3 - inset);
    }
}

module eye_volume(side, inset = 0) {
    ellipsoid([side * eye_spacing / 2, eye_y, eye_z], eye_size / 2, inset);
}

module muzzle_volume(inset = 0) {
    // Keep V3's continuous lower and upper blends instead of a separate snout.
    hull() {
        ellipsoid([1, muzzle_y, 46], [28, muzzle_depth, 26], inset);
        ellipsoid([4, muzzle_y + 2, 56], [22, muzzle_depth, 21], inset);
        ellipsoid([1, muzzle_root_y, muzzle_root_bottom], [16, 12, 2], inset);
        ellipsoid([1, muzzle_top_root_y, muzzle_root_top], [16, 12, 2], inset);
    }
}

module nose_volume(inset = 0) {
    intersection() {
        muzzle_volume(inset - detail_relief);
        front_mask()
            offset(r = 3)
                polygon([[-11, 65], [12, 65], [3, 55]]);
    }
}

module brow_volume(side, inset = 0) {
    hull() {
        translate([side * 31, brow_y, brow_z])
            rotate([0, side * 12, 0])
                scale([16 - inset, 8 - inset, 7 - inset])
                    sphere(r = 1);
        ellipsoid([side * 31, -32, brow_root_z], [13, 3, 1], inset);
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
    translate([side * eye_spacing / 2, eye_z + 2])
        scale([eye_size[0] / 2 + eye_patch_margin[0],
               eye_size[2] / 2 + eye_patch_margin[1]])
            circle(r = 1);
}

module ear_panel_2d(side) {
    scale([side, 1])
        offset(r = 2)
            polygon([
                [ear_root_inner + 7, ear_root_height + 10],
                [ear_root_outer - 5, ear_root_height + 10],
                [ear_tip_x - 1, ear_tip_height - 14]
            ]);
}

module facial_details() {
    color(patch_color)
        for (side = [-1, 1]) {
            intersection() {
                head_volume(-detail_relief);
                front_mask() face_patch_2d(side);
            }
            ear_volume(side, -0.1);
        }

    color(inner_ear_color)
        for (side = [-1, 1])
            intersection() {
                ear_volume(side, -detail_relief);
                front_mask(back_y = -16 + ear_y) ear_panel_2d(side);
            }

    color(cream_color) {
        intersection() {
            head_volume(-0.1);
            front_mask()
                translate([0, 38]) scale([30, 18]) circle(r = 1);
        }
        for (side = [-1, 1]) brow_volume(side, -0.1);
        intersection() { muzzle_volume(-0.1); front_mask(); }
    }

    color(eye_color)
        for (side = [-1, 1])
            intersection() { eye_volume(side, -0.1); front_mask(); }

    color(pupil_color)
        for (side = [-1, 1])
            intersection() {
                eye_volume(side, -detail_relief - 0.1);
                front_mask()
                    translate([side * eye_spacing / 2 + pupil_look_x, eye_z + 1])
                        scale([pupil_width / 2, pupil_height / 2]) circle(r = 1);
            }

    color(eye_color)
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

    color(nose_color) nose_volume(-0.1);
    color(nose_highlight_color)
        intersection() {
            nose_volume(-detail_relief - 0.1);
            front_mask()
                translate([0, 65]) scale([7, 1.2]) circle(r = 1);
        }
}

module head() {
    difference() {
        union() {
            color(coat_color) sculpt_volume();
            facial_details();
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
