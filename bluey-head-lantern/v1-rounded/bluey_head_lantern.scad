/*
  Bluey-inspired head lantern. Original modeled geometry; no imported mesh.
  Smooth solid master for slicer-controlled hollowing. Front is -Y.
  The flat underside is already at Z=0. No hanging hardware is included.
  Use a cool, self-contained battery LED only, never a flame or hot bulb.
*/

$fn = 96;
part = "assembled"; // [head,assembled,layout,section]

// Rounded, plush-like head proportions, mm.
head_width = 144;
head_depth = 112;
cheek_radius = 45;
cheek_center_z = 30;
crown_height = 124;
crown_radius = 40;
forehead_width = 132;
forehead_depth = 104;
ear_tip_height = 181;
detail_relief = 0.45;
surface_overlap = 0.2;

// Facial proportions and raised painting guides.
eye_spacing = 56;
eye_size = [44, 24, 60];
eye_y = -48;
eye_z = 85;
pupil_width = 11;
pupil_height = 23;
pupil_look_x = 4;
muzzle_y = -57;
nose_y = -78;

/* [Hidden] */
blue = "#83c5e8";
navy = "#363557";
pale_blue = "#cdeafa";
cream = "#f1d078";
white = "#fffdf0";
ink = "#222336";

assert(cheek_radius > cheek_center_z, "The head must intersect the flat print plane.");
assert(head_width > 2 * cheek_radius && head_depth > 2 * cheek_radius);
assert(crown_radius > 0 && forehead_width > 2 * crown_radius
       && forehead_depth > 2 * crown_radius);
assert(detail_relief >= 0.3 && detail_relief <= 0.8);
assert(surface_overlap > 0 && surface_overlap < 1);
assert(ear_tip_height > crown_height + 35);

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

// Map an X/Z silhouette onto the front-facing part of a curved surface.
module front_mask(depth = 100, back_y = -10) {
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
            translate([side * x, y, 110])
                sphere(r = 6 - inset);
        for (y = [-14, -8])
            translate([side * 60, y, ear_tip_height])
                sphere(r = 3 - inset);
    }
}

module eye_volume(side, inset = 0) {
    ellipsoid([side * eye_spacing / 2, eye_y, eye_z],
              eye_size / 2, inset);
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
    translate([side * 34, -31, 119])
        rotate([0, side * 14, 0])
            scale([18 - inset, 8 - inset, 8 - inset])
                sphere(r = 1);
}

module sculpt_volume(inset = 0) {
    union() {
        head_volume(inset);
        for (side = [-1, 1]) {
            ear_volume(side, inset);
            eye_volume(side, inset);
            brow_volume(side, inset);
        }
        muzzle_volume(inset);
        nose_volume(inset);
    }
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

module head_band(relief = detail_relief) {
    difference() {
        head_volume(-relief);
        head_volume(surface_overlap);
    }
}

module muzzle_band(relief = detail_relief) {
    difference() {
        muzzle_volume(-relief);
        muzzle_volume(surface_overlap);
    }
}

module eye_band(side, relief = detail_relief) {
    difference() {
        eye_volume(side, -relief);
        eye_volume(side, surface_overlap);
    }
}

module ear_band(side, relief = detail_relief) {
    difference() {
        ear_volume(side, -relief);
        ear_volume(side, surface_overlap);
    }
}

module nose_band(relief = detail_relief) {
    difference() {
        nose_volume(-relief);
        nose_volume(surface_overlap);
    }
}

module facial_details() {
    color(navy)
        for (side = [-1, 1]) {
            intersection() {
                head_band();
                front_mask() face_patch_2d(side);
            }
            ear_band(side, 0.12);
        }

    color(cream)
        for (side = [-1, 1])
            intersection() {
                ear_band(side);
                front_mask(back_y = -16) ear_panel_2d(side);
            }

    color(pale_blue) {
        intersection() {
            head_band(0.22);
            front_mask()
                translate([-7, 40]) scale([34, 19]) circle(r = 1);
        }
        for (side = [-1, 1])
            difference() {
                brow_volume(side, -0.15);
                brow_volume(side, surface_overlap);
            }
    }

    color(cream)
        intersection() {
            muzzle_band(0.15);
            front_mask();
        }

    color(white)
        for (side = [-1, 1])
            intersection() {
                eye_band(side, 0.15);
                front_mask();
            }

    color(ink)
        for (side = [-1, 1])
            intersection() {
                eye_band(side, detail_relief + 0.15);
                front_mask()
                    translate([side * eye_spacing / 2 + pupil_look_x, eye_z + 1])
                        scale([pupil_width / 2, pupil_height / 2]) circle(r = 1);
            }

    color(white)
        for (side = [-1, 1])
            intersection() {
                eye_band(side, detail_relief + 0.35);
                front_mask()
                    translate([
                        side * eye_spacing / 2 + pupil_look_x - 1.5,
                        eye_z + 6
                    ])
                        circle(r = 1.4);
            }

    color(navy) nose_band(0.15);
    color("#8f94ad")
        intersection() {
            nose_band(detail_relief + 0.15);
            front_mask()
                translate([1, 70]) scale([8.5, 1.8]) circle(r = 1);
        }

    color("#79603b")
        intersection() {
            muzzle_band(detail_relief + 0.15);
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
        front_mask(depth = 12, back_y = -12)
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
