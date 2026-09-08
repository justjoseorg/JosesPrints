/*
  Removable screw-on rain hat for the already-installed NEMA 14-50R box lid

  This is a retrofit accessory for the lid in ../nema-14-50r-box-lid, which
  is already printed, bolted to the wall box, and must not be removed or
  modified. The design is strictly ADDITIVE: it consumes only surfaces the
  installed lid already has (its outside shroud faces, its front rim and
  its two hinge-barrel supports) and it drills, cuts or reshapes nothing.

  The only thing removed from the existing assembly is the flap: pull the
  1.75 mm filament hinge pin, take off the flap and its TPU seal, and slide
  this hat on in its place. The two stationary hinge barrels stay where
  they are; the hat simply arches over them.

  How it attaches
    * A U-shaped collar (left, right and bottom walls) slips forward-to-back
      over the outside of the lid's 118.7 mm square shroud with a 0.4 mm
      slip fit, so the hat cannot move up, down or sideways.
    * Two clamp jaws reach around the lid's front rim: an outer leg (the
      collar wall) and an inner finger that slides into the shroud opening
      alongside the side walls. One M4 screw per side passes through the
      collar and threads into the finger, pinching the lid's 3.2 mm side
      wall between them. Back the two screws out and the hat lifts straight
      off. Nothing else touches the lid.
    * The jaw bridges land against the lid's front rim, which sets how far
      back the hat sits.

  What it does
    A canopy peaks just in front of the old hinge line and then slopes down
    and forward, overhanging the receptacle by 58 mm past the lid's rim,
    with side wings that close the sides. Rain and drips are thrown clear of
    the open front while a cord stays plugged in; the front and bottom stay
    completely open for the plug and its cord.

  Keeping water out
    * The canopy runs all the way back to the wall, so the lid's top face
      and both of its barrel support ramps are roofed over. Nothing can
      fall into the space between the lid and the canopy from above.
    * The side wings run back to the wall too, closing that space along
      both sides, and a notched rear lip closes it across the back.
    * The hat pushes flush against the wall and finishes in a flat sealing
      flange that rings the lid, so the joint can be caulked or taped.
      The flange's bore is relieved to clear the lid's compressed TPU
      gasket, which is what lets the hat reach the wall at all.
    * The hat is stopped by the wall, not by the lid: the clamp jaws are
      cut with 2 mm of slack in front of the lid's rim, so the hat always
      seats against whatever is behind it.
    * Nothing is sealed shut. Any water that still finds its way in lands
      on the lid's own top wall and drains forward, out under the canopy.

  Printable part values: "hat".
  Diagnostic/view values: "fit_check", "slide_on_check",
  "plug_clearance_check", "layout", "assembled".
*/

use <../nema-14-50r-box-lid/nema_14_50r_box_lid.scad>

$fn = 64;

part = "assembled"; // hat, fit_check, slide_on_check, plug_clearance_check, layout, assembled
slide_check_step = 2;      // sampling of the slide-on sweep, in mm
slide_check_travel = 60;   // enough travel to fully disengage the hat

// ===================== Installed lid interface =====================
// FIXED BY THE PART ALREADY ON THE WALL. These mirror
// ../nema-14-50r-box-lid/nema_14_50r_box_lid.scad and must not be changed
// unless that lid is reprinted. X = width, Y = out from the box face,
// Z = height, exactly as in the lid model.
lid_width = 118.7;
lid_height = 118.7;
lid_depth = 42;              // front rim plane, measured from the box face
lid_corner_radius = 10;
lid_wall = 3.2;              // shroud wall the clamp jaws pinch

// The lid is bolted down over a 2 mm TPU gasket, so the box/wall face it is
// clamped against sits 2 mm behind the lid's own back face (y = 0). That
// plane is how far back this hat can go.
gasket_thickness = 2;
gasket_bulge = 0.8;          // conservative squeeze-out of the compressed TPU
wall_y = -gasket_thickness;

// Hinge hardware left behind after the flap is removed. The two stationary
// barrels sit on sloped supports that rise out of the lid's top face, so
// the hat's roof has to clear a ramp, not a flat surface.
hinge_barrel_diameter = 8;
hinge_axis_y = 48.0;
hinge_axis_z = 123.3;
hinge_barrel_top_z = hinge_axis_z + hinge_barrel_diameter / 2;   // 127.3
hinge_barrel_front_y = hinge_axis_y + hinge_barrel_diameter / 2; // 52.0
hinge_barrel_length = 20;
hinge_barrel_starts = [10, lid_width - 10 - hinge_barrel_length];
hinge_ramp_back_y = 4.8;     // where the barrel support leaves the back plate
hinge_ramp_front_y = 41.6;   // where it reaches full barrel height
ramp_slope =
    (hinge_barrel_top_z - lid_height)
    / (hinge_ramp_front_y - hinge_ramp_back_y);

// ===================== Fit =====================
fit_clearance = 0.4;     // collar to lid outside faces, per side
hinge_gap = 1.5;         // roof underside above the lid's hinge hardware
notch_clearance = 1.5;   // rear lip relief around each barrel support ramp

// ===================== Wall interface =====================
// The hat is pushed back until it is flush against the wall, so the whole
// rear face is one plane. Raise wall_setback if the box stands proud of
// the wall and the hat needs to stop short of it.
wall_setback = 0;
hat_back_y = wall_y + wall_setback;

// The last few mm of the bore are opened up so the hat slides over the
// lid's compressed gasket instead of jamming on it.
gasket_relief_depth = 4;
gasket_relief = 1.4;     // extra clearance there, per side

// Flat land around the rear face, for a bead of sealant or a strip of
// closed-cell foam tape. Matches roof_side_overhang so the flange finishes
// flush with the canopy's drip edge.
wall_flange_width = 3;
wall_flange_depth = 2.4;

// ===================== Collar =====================
collar_wall = 3.2;
collar_back_y = hat_back_y;                    // reaches the wall
collar_depth = lid_depth - collar_back_y;      // 44.0
collar_outer_width = lid_width + 2 * (fit_clearance + collar_wall);
collar_outer_height = lid_height + 2 * (fit_clearance + collar_wall);
collar_outer_radius = lid_corner_radius + fit_clearance + collar_wall;
collar_x = -(fit_clearance + collar_wall);
collar_z = -(fit_clearance + collar_wall);
collar_grip_depth = lid_depth - 14;            // precision-fit length
// The sleeve is cut off below the lid's top face: the two barrel support
// ramps rise out of that face, so the canopy covers this span instead.
collar_top_cut_z = lid_height - 0.5;

// ===================== Canopy =====================
roof_thickness = 3.6;
roof_side_overhang = 3;    // drip edge proud of the collar, each side
roof_x = collar_x - roof_side_overhang;
roof_width = collar_outer_width + 2 * roof_side_overhang;
roof_back_y = collar_back_y;
roof_shoulder_y = hinge_barrel_front_y + 2;   // 54, just clear of the barrels
roof_front_y = 100;        // 58 mm of overhang past the lid's front rim
roof_front_under_z = 95;

function lid_ramp_z(y) =
    y <= hinge_ramp_back_y ? lid_height
    : y >= hinge_ramp_front_y ? hinge_barrel_top_z
    : lid_height + (y - hinge_ramp_back_y) * ramp_slope;

// Highest point of anything the installed lid carries at a given depth.
function lid_top_obstruction_z(y) =
    y <= lid_depth ? lid_ramp_z(y)
    : y <= hinge_barrel_front_y ? hinge_barrel_top_z
    : lid_height;

// The hat is installed by sliding it straight back onto the lid, so every
// part of the canopy behind the barrels' front face has to pass over the
// full height of the barrels on the way in, not just clear them where it
// finally sits. That span is therefore held flat, one hinge_gap above the
// barrel tops; only the section in front of them is allowed to fall away.
roof_flat_under_z = hinge_barrel_top_z + hinge_gap;
roof_front_slope =
    (roof_front_under_z - roof_flat_under_z) / (roof_front_y - roof_shoulder_y);

function roof_under_z(y) =
    y <= roof_shoulder_y
        ? roof_flat_under_z
        : roof_flat_under_z + (y - roof_shoulder_y) * roof_front_slope;
function roof_top_z(y) = roof_under_z(y) + roof_thickness;

// ===================== Side wings =====================
wing_rim_z = 40;        // how far down the wings close the sides at the rim
wing_front_y = 94;
wing_front_z = 90;

// ===================== Spine rib =====================
rib_thickness = 3.2;
rib_height = 8;
rib_back_y = 40;

// ===================== Rear lip =====================
// Two of them: one right at the wall, sitting on the sealing flange, and
// one further in as a second baffle. Both are interrupted where the lid's
// barrel support ramps pass through, because that span has to stay clear
// for the canopy to sweep over the barrels during installation.
rear_lip_depth = 3.2;
rear_lip_weld = 0.2;    // embed into the roof so the weld is never zero width
inner_lip_y = 14;
inner_lip_bottom_z = lid_height + fit_clearance;      // 119.1
// The lip at the wall also has to miss the gasket's squeeze-out.
wall_lip_bottom_z = lid_height + fit_clearance + gasket_relief;   // 120.5

// ===================== Clamp jaws =====================
jaw_finger_gap = 0.5;         // finger to the shroud's inside face
jaw_finger_thickness = 7;     // thread depth available for the M4 screw
jaw_finger_x = lid_wall + jaw_finger_gap;
jaw_back_y = 14;              // the finger must stop clear of the back plate
jaw_bottom_z = 19;
jaw_height = 22;
// Slack, not a stop: the wall sets how far back the hat goes, so the jaw
// bridges must not reach the lid's rim first.
jaw_rim_gap = 2.0;
jaw_bridge_depth = 4.5;
jaw_bridge_y = lid_depth + jaw_rim_gap;
screw_clearance_diameter = 4.4;   // M4 free fit through the collar wall
screw_pilot_diameter = 3.4;       // M4 self-tapping into the finger
screw_y = 28;
screw_z = jaw_bottom_z + jaw_height / 2;

// ===================== Plug envelope (reference only) =====================
// A deliberately generous stand-in for a NEMA 14-50 plug body, used by
// plug_clearance_check to prove the canopy leaves the receptacle usable.
plug_envelope_diameter = 75;
plug_envelope_back_y = 5;      // the lid's back plate face
plug_envelope_front_y = 95;

// ===================== Sanity checks =====================
// Slide-on clearance: anything on the hat that is level with the barrels at
// any point during installation must stay above them, because the whole
// canopy sweeps over them as the collar is pushed back onto the lid.
assert(
    min([
        for (y = [roof_back_y : 0.5 : hinge_barrel_front_y]) roof_under_z(y)
    ]) >= hinge_barrel_top_z + hinge_gap - 0.001,
    "The canopy must clear the hinge barrels over its whole rear span so the hat can slide on."
);
assert(
    min([
        for (y = [roof_back_y : 0.5 : hinge_barrel_front_y])
            roof_under_z(y) - lid_top_obstruction_z(y)
    ]) >= hinge_gap - 0.001,
    "The canopy underside must stay clear of the lid's hinge barrels and their ramps."
);
assert(
    min([for (start = hinge_barrel_starts) start]) - notch_clearance
        > roof_x,
    "The rear lip's barrel notches must fall inside the lip."
);
assert(
    collar_top_cut_z < lid_height,
    "The collar must end below the lid's top face, where the barrel supports rise."
);
assert(
    wing_rim_z < collar_top_cut_z,
    "The side wings must overlap the collar walls to close the gap up to the canopy."
);
assert(
    jaw_finger_x + jaw_finger_thickness
        < lid_width / 2 - 55 / 2,
    "Clamp fingers must stay outside the receptacle clearance opening."
);
assert(
    jaw_bottom_z + jaw_height < lid_height / 2 - 55 / 2 + 55,
    "Clamp fingers must stay clear of the receptacle bezel."
);
assert(
    roof_shoulder_y > hinge_barrel_front_y,
    "The canopy must start falling away in front of the hinge barrels."
);
assert(
    (roof_front_y - roof_shoulder_y) > (roof_flat_under_z - roof_front_under_z),
    "The canopy's forward slope must stay above 45 degrees in the print orientation."
);
assert(
    (wing_front_y - lid_depth) > (wing_front_z - wing_rim_z),
    "The wing's lower edge must stay above 45 degrees in the print orientation."
);
assert(
    gasket_relief > gasket_bulge,
    "The relieved bore must clear the compressed gasket's squeeze-out."
);
assert(
    gasket_relief_depth > gasket_thickness,
    "The relieved bore must be deeper than the gasket it has to pass over."
);
assert(
    wall_lip_bottom_z > lid_height + gasket_bulge,
    "The lip at the wall must sit above the gasket's squeeze-out."
);
assert(
    hat_back_y + gasket_relief_depth < inner_lip_y,
    "The relieved bore must end before the inner baffle."
);
assert(
    jaw_rim_gap > 1,
    "The jaw bridges must clear the lid's rim so the wall is the depth stop."
);
assert(
    jaw_back_y > gasket_thickness + 5,
    "The clamp fingers must start in front of the lid's back plate."
);
assert(
    collar_grip_depth > 20,
    "The precision-fit section of the collar must be long enough to locate the hat."
);
assert(
    collar_x - wall_flange_width >= roof_x,
    "The sealing flange must not stand proud of the canopy's drip edge."
);
assert(
    wall_flange_width == roof_side_overhang,
    "The sealing flange should finish flush with the canopy's drip edge."
);

// ===================== Primitives =====================
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

module ring_front_prism(
    outer_width,
    outer_height,
    depth,
    radius,
    ring_width
) {
    difference() {
        front_prism(outer_width, outer_height, depth, radius);

        translate([ring_width, -0.1, ring_width])
            front_prism(
                outer_width - 2 * ring_width,
                outer_height - 2 * ring_width,
                depth + 0.2,
                max(radius - ring_width, 1)
            );
    }
}

// A profile drawn in the Y/Z plane, extruded across X.
module yz_extrude(points, x_start, width) {
    translate([x_start, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = width)
                polygon(points);
}

module cylinder_x(length, diameter) {
    rotate([0, 90, 0])
        cylinder(h = length, d = diameter);
}

// ===================== Hat geometry =====================

// Three-sided sleeve. The top is left open because the lid's barrel
// supports rise out of its top face; the canopy covers that span instead.
module collar() {
    difference() {
        translate([collar_x, collar_back_y, collar_z])
            ring_front_prism(
                collar_outer_width,
                collar_outer_height,
                collar_depth,
                collar_outer_radius,
                collar_wall
            );

        translate([roof_x - 10, collar_back_y - 1, collar_top_cut_z])
            cube([roof_width + 20, collar_depth + 2, 40]);
    }
}

// Flat land all the way round the rear face, pressed against the wall.
// It is left open across the top, where the canopy and the lip at the wall
// take over, because the hinge barrels have to sweep through that band.
module wall_flange() {
    difference() {
        translate([
            collar_x - wall_flange_width,
            hat_back_y,
            collar_z - wall_flange_width
        ])
            ring_front_prism(
                collar_outer_width + 2 * wall_flange_width,
                collar_outer_height + 2 * wall_flange_width,
                wall_flange_depth,
                collar_outer_radius + wall_flange_width,
                wall_flange_width + collar_wall + fit_clearance
            );

        translate([roof_x - 10, hat_back_y - 1, collar_top_cut_z])
            cube([roof_width + 20, wall_flange_depth + 2, 40]);
    }
}

// Opens up the last few mm of the bore so the hat rides over the lid's
// compressed TPU gasket instead of jamming on it.
module gasket_relief_cut() {
    offset = fit_clearance + gasket_relief;

    translate([-offset, hat_back_y - 0.1, -offset])
        front_prism(
            lid_width + 2 * offset,
            lid_height + 2 * offset,
            gasket_relief_depth + 0.1,
            lid_corner_radius + offset
        );
}

function roof_profile() = [
    [roof_back_y, roof_under_z(roof_back_y)],
    [roof_shoulder_y, roof_under_z(roof_shoulder_y)],
    [roof_front_y, roof_under_z(roof_front_y)],
    [roof_front_y, roof_top_z(roof_front_y)],
    [roof_shoulder_y, roof_top_z(roof_shoulder_y)],
    [roof_back_y, roof_top_z(roof_back_y)]
];

module roof() {
    yz_extrude(roof_profile(), roof_x, roof_width);
}

function wing_profile() = [
    [collar_back_y, wing_rim_z],
    [lid_depth, wing_rim_z],
    [wing_front_y, wing_front_z],
    [wing_front_y, roof_top_z(wing_front_y)],
    [roof_shoulder_y, roof_top_z(roof_shoulder_y)],
    [collar_back_y, roof_top_z(collar_back_y)]
];

module wings() {
    for (x = [collar_x, lid_width + fit_clearance])
        yz_extrude(wing_profile(), x, collar_wall);
}

function rib_profile() = [
    [rib_back_y, roof_top_z(rib_back_y)],
    [roof_shoulder_y, roof_top_z(roof_shoulder_y)],
    [roof_front_y, roof_top_z(roof_front_y)],
    [roof_front_y, roof_top_z(roof_front_y) + rib_height],
    [roof_shoulder_y, roof_top_z(roof_shoulder_y) + rib_height]
];

module spine_rib() {
    yz_extrude(
        rib_profile(),
        lid_width / 2 - rib_thickness / 2,
        rib_thickness
    );
}

function rear_lip_profile(back_y, bottom_z) = [
    [back_y, bottom_z],
    [back_y + rear_lip_depth, bottom_z],
    [back_y + rear_lip_depth,
     roof_under_z(back_y + rear_lip_depth) + rear_lip_weld],
    [back_y, roof_under_z(back_y) + rear_lip_weld]
];

// Closes the back of the gap between the lid's top face and the canopy,
// interrupted where the two barrel support ramps pass through.
module rear_lip(back_y, bottom_z) {
    notches = [
        for (start = hinge_barrel_starts)
            [start - notch_clearance,
             start + hinge_barrel_length + notch_clearance]
    ];
    edges = concat(
        [roof_x],
        [for (n = notches) each [n[0], n[1]]],
        [roof_x + roof_width]
    );

    for (i = [0 : 2 : len(edges) - 2]) {
        segment_width = edges[i + 1] - edges[i];
        if (segment_width > 0.1)
            yz_extrude(
                rear_lip_profile(back_y, bottom_z),
                edges[i],
                segment_width
            );
    }
}

// One clamp per side: the collar wall is the outer leg, the finger inside
// the shroud is the inner leg, and the bridge in front of the rim ties them
// together so the whole jaw slides on as one piece. The root block merges
// the bridge into the collar wall so the jaw is a continuous part of the
// hat rather than something hanging off the wing.
module clamp_jaw() {
    union() {
        translate([jaw_finger_x, jaw_back_y, jaw_bottom_z])
            cube([
                jaw_finger_thickness,
                jaw_bridge_y + jaw_bridge_depth - jaw_back_y,
                jaw_height
            ]);

        translate([collar_x, jaw_bridge_y, jaw_bottom_z])
            cube([
                jaw_finger_x + jaw_finger_thickness - collar_x,
                jaw_bridge_depth,
                jaw_height
            ]);

        translate([collar_x, jaw_back_y, jaw_bottom_z])
            cube([
                collar_wall,
                jaw_bridge_y + jaw_bridge_depth - jaw_back_y,
                jaw_height
            ]);
    }
}

module clamp_screw_cut() {
    translate([collar_x - 1, screw_y, screw_z])
        cylinder_x(
            jaw_finger_x - collar_x + 1,
            screw_clearance_diameter
        );

    translate([jaw_finger_x - 0.1, screw_y, screw_z])
        cylinder_x(
            jaw_finger_thickness + 0.2,
            screw_pilot_diameter
        );
}

module both_sides() {
    children();

    translate([lid_width, 0, 0])
        mirror([1, 0, 0])
            children();
}

module hat() {
    difference() {
        union() {
            collar();
            wall_flange();
            roof();
            wings();
            spine_rib();
            rear_lip(hat_back_y, wall_lip_bottom_z);
            rear_lip(inner_lip_y, inner_lip_bottom_z);

            both_sides()
                clamp_jaw();
        }

        gasket_relief_cut();

        both_sides()
            clamp_screw_cut();
    }
}

// The lid plus everything else that is already bolted to the wall. The
// compressed gasket is modelled as a solid prism grown by gasket_bulge,
// which is deliberately more than the real squeeze-out.
module installed_obstructions() {
    lid();

    translate([-gasket_bulge, wall_y, -gasket_bulge])
        front_prism(
            lid_width + 2 * gasket_bulge,
            lid_height + 2 * gasket_bulge,
            gasket_thickness,
            lid_corner_radius + gasket_bulge
        );
}

// ===================== Views =====================
// Must render as an empty object: nothing on the hat may occupy the same
// space as the lid that is already bolted to the wall.
module fit_check() {
    intersection() {
        hat();
        installed_obstructions();
    }
}

// Must also render empty: the hat is pushed straight back onto the lid, so
// the whole insertion travel has to be free of the lid and its barrels.
module slide_on_check() {
    for (offset = [0 : slide_check_step : slide_check_travel])
        intersection() {
            translate([0, offset, 0])
                hat();
            installed_obstructions();
        }
}

module plug_envelope() {
    translate([lid_width / 2, plug_envelope_back_y, lid_height / 2])
        rotate([-90, 0, 0])
            cylinder(
                h = plug_envelope_front_y - plug_envelope_back_y,
                d = plug_envelope_diameter
            );
}

// Must also render empty: a plugged-in cord has to live under the canopy.
module plug_clearance_check() {
    intersection() {
        hat();
        plug_envelope();
    }
}

module hat_for_printing() {
    translate([0, roof_top_z(roof_shoulder_y) + rib_height, -roof_back_y])
        rotate([90, 0, 0])
            hat();
}

module assembled() {
    wall_margin = 22;

    color([0.72, 0.72, 0.70])
        translate([-wall_margin, wall_y - 6, -wall_margin])
            cube([
                lid_width + 2 * wall_margin,
                6,
                lid_height + 2 * wall_margin
            ]);

    color([0.15, 0.15, 0.15])
        translate([-gasket_bulge, wall_y, -gasket_bulge])
            front_prism(
                lid_width + 2 * gasket_bulge,
                lid_height + 2 * gasket_bulge,
                gasket_thickness,
                lid_corner_radius + gasket_bulge
            );

    color([0.76, 0.38, 0.08])
        lid();

    color([0.08, 0.08, 0.08])
        translate([lid_width / 2, 4.8, lid_height / 2])
            receptacle_preview();

    color([0.20, 0.35, 0.55])
        hat();
}

if (part == "hat") {
    hat_for_printing();
} else if (part == "fit_check") {
    fit_check();
} else if (part == "slide_on_check") {
    slide_on_check();
} else if (part == "plug_clearance_check") {
    plug_clearance_check();
} else if (part == "layout") {
    hat_for_printing();
} else if (part == "assembled") {
    assembled();
}
