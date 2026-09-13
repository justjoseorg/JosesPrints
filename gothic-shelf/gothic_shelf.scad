// Nominal design: 152 x 300 mm, 5 mm backplate, 10 mm shelf; output scaled to 95%.
part = "assembled"; // [backplate,shelf,assembled,layout,collision_check,insertion_check]

output_scale = 0.95;
width = 152;
height = 300;
back_thickness = 5;
shelf_width = 140;
shelf_depth = 65; // Projection beyond the front of the decorative backplate.
shelf_thickness = 10;
shelf_bottom = 74;
fit_clearance = 0.3;
rail_wall = 3.5;
rail_length = 116;
rail_depth = 9;
rail_stop = 4;
rail_tongue_height = min(shelf_thickness + 4, 10);
latch_length = 36;
latch_thickness = 1.6;
latch_engagement = 1.2;
mount_hole_diameter = 4.2;
mount_head_diameter = 8.4;
layout_gap = 15;
curve_steps = 24;
$fn = 48;

// Inspection controls: the latch bends toward the shelf front during insertion.
insertion_offset = 0;
latch_deflection = 0;

eps = 0.01;
sx = width / 152;
sz = height / 300;
rail_front = back_thickness + rail_depth;
groove_back = back_thickness + 1.5;
tongue_back = groove_back + 0.5;
board_back = rail_front + fit_clearance;
board_front = back_thickness + shelf_depth;
tongue_left = -rail_length / 2 + rail_stop + fit_clearance;
tongue_right = rail_length / 2 - rail_stop - fit_clearance;
latch_root = rail_length / 2 - 46;
latch_tip = latch_root + latch_length;
latch_back = rail_front + 1;
latch_ramp_start = latch_tip - 5;
latch_shoulder = latch_tip - 0.2;
latch_tip_depth = rail_front - latch_engagement;
latch_lift = shelf_thickness - 1.2;
insertion_flex = latch_engagement + fit_clearance;
slot_front = latch_back + latch_thickness + insertion_flex + 1.4;

assert(output_scale > 0);
assert(width > 0 && height > 0 && back_thickness >= 4);
assert(fit_clearance >= 0.2 && fit_clearance <= 0.5);
assert(rail_depth == 9, "Changing rail_depth requires revising the dovetail section.");
assert(rail_length / 2 >= 55 * sx && rail_length / 2 <= 71 * sx,
       "Rail ends must overlap the side posts.");
assert(shelf_bottom - rail_wall >= 69 * sz &&
       shelf_bottom + rail_tongue_height + rail_wall <= 89 * sz,
       "Keep the receiver within the solid window sill.");
assert(shelf_width <= width && shelf_width / 2 > rail_length / 2 + 5);
assert(shelf_depth > 35 && shelf_thickness >= 5);
assert(latch_length >= 30 && latch_tip + 3 < shelf_width / 2);
assert(latch_tip < rail_length/2-rail_wall,
       "The latch pocket needs a solid shoulder before the rail opening.");
assert(shelf_thickness + fit_clearance + 2 < rail_tongue_height + rail_wall,
       "Keep material above the latch pocket.");
assert(rail_wall >= 3 && rail_stop >= 3);
assert(latch_lift - (rail_tongue_height - (latch_tip_depth-tongue_back))
       >= fit_clearance,
       "The hook must stay clear of the tongue so the spring remains free.");
assert(1.5 * latch_thickness * insertion_flex / pow(latch_length, 2) < 0.01,
       "Excessive estimated latch bending strain.");
assert(mount_hole_diameter > 0 && mount_head_diameter < 11 * min(sx, sz));
assert(latch_deflection >= 0 && latch_deflection <= insertion_flex);

function bezier(c, t) =
    pow(1-t, 3)*c[0] + 3*pow(1-t, 2)*t*c[1] +
    3*(1-t)*t*t*c[2] + t*t*t*c[3];
function curve(c) = [for (i = [0:curve_steps]) bezier(c, i/curve_steps)];
function curves(cs) = [for (c = cs) each curve(c)];
function reflect_points(ps) = [for (i = [len(ps)-1:-1:0]) [-ps[i][0], ps[i][1]]];
function bend(t, amount) = amount * t*t*(3-t)/2;

module stroke(points, diameter) {
    for (i = [0:len(points)-2])
        hull() {
            translate(points[i]) circle(d = diameter);
            translate(points[i+1]) circle(d = diameter);
        }
}

module curved_stroke(cs, diameter = 3.8) {
    stroke(curves(cs), diameter);
}

module both_sides() {
    children();
    mirror([1,0,0]) children();
}

module outline_2d() {
    half = curves([
        [[0,300],[2,298],[1,293],[5,290]],
        [[5,290],[9,287],[12,288],[12,283]],
        [[12,283],[12,278],[9,276],[6,278]],
        [[6,278],[2,276],[6,266],[9,260]],
        [[9,260],[20,237],[40,213],[55,205]],
        [[55,205],[55,216],[55,228],[55,237]],
        [[55,237],[52,240],[50,243],[51,246]],
        [[51,246],[52,251],[59,252],[61,255]],
        [[61,255],[64,258],[62,262],[63,264]],
        [[63,264],[62,267],[65,266],[65,270]],
        [[65,270],[68,269],[66,266],[69,265]],
        [[69,265],[71,264],[68,260],[70,256]],
        [[70,256],[71,253],[76,252],[76,247]],
        [[76,247],[76,243],[74,241],[71,239]],
        [[71,239],[71,180],[71,80],[71,43]],
        [[71,43],[75,40],[73,38],[71,36]],
        [[71,36],[75,33],[71,29],[64,22]],
        [[64,22],[60,26],[54,30],[55,34]],
        [[55,34],[51,43],[49,55],[40,59]],
        [[40,59],[28,67],[15,57],[10,36]],
        [[10,36],[9,32],[7,31],[5,30]],
        [[5,30],[7,27],[5,25],[6,23]],
        [[6,23],[7,20],[4,20],[5,17]],
        [[5,17],[7,15],[5,13],[6,11]],
        [[6,11],[6,8],[2,3],[0,0]]
    ]);
    polygon(concat(half, reflect_points(half)));
}

module window_void_2d() {
    roof = curves([
        [[55,193],[32,202],[10,230],[0,252]],
        [[0,252],[-10,230],[-32,202],[-55,193]]
    ]);
    polygon(concat([[-55,89],[55,89]], roof));
}

module lower_cutouts_2d() {
    both_sides()
        polygon(curves([
            [[9,53],[19,64],[37,70],[51,62]],
            [[51,62],[46,73],[28,74],[18,70]],
            [[18,70],[14,65],[12,59],[9,53]]
        ]));
    polygon(curves([
        [[-12,72],[-8,61],[-3,55],[0,43]],
        [[0,43],[3,55],[8,61],[12,72]],
        [[12,72],[5,72],[-5,72],[-12,72]]
    ]));
}

module tracery_2d() {
    // Five lancets, with four slender, collared mullions.
    boundaries = [-55,-32,-10,10,32,55];
    for (i = [0:4]) {
        a = boundaries[i];
        b = boundaries[i+1];
        peak = (i == 0 || i == 4) ? 179 : 175;
        curved_stroke([
            [[a,146],[a,160],[a+3,peak-7],[(a+b)/2,peak]],
            [[(a+b)/2,peak],[b-3,peak-7],[b,160],[b,146]]
        ], 4.2);
    }
    for (x = [-32,-10,10,32]) {
        translate([x-2.5,88]) square([5,60]);
        translate([x,146])
            polygon([[-2.5,-4],[-4.2,1],[-4.2,3],[4.2,3],[4.2,1],[2.5,-4]]);
        translate([x,140]) scale([1.4,1]) circle(r=2);
    }
    both_sides() {
        curved_stroke([
            [[-55,147],[-55,173],[-40,198],[-21,200]],
            [[-21,200],[-2,202],[10,177],[10,147]]
        ], 4.3);
        curved_stroke([
            [[-55,182],[-42,198],[-19,211],[0,207]]
        ], 3.5);
        curved_stroke([
            [[-32,147],[-32,173],[-17,195],[0,207]]
        ], 4);
        curved_stroke([
            [[-35,207],[-29,216],[-11,222],[0,214]]
        ], 4);
        curved_stroke([
            [[-7,210],[-1,223],[-5,234],[-10,240]]
        ], 3.2);
        curved_stroke([
            [[-30,180],[-25,178],[-25,185],[-28,188]]
        ], 3);
        curved_stroke([
            [[-9,180],[-5,178],[-4,184],[-6,187]]
        ], 3);
        curved_stroke([
            [[-24,211],[-22,207],[-17,209],[-16,212]]
        ], 3);
        curved_stroke([
            [[-14,224],[-12,220],[-6,221],[-4.7,224]]
        ], 3);
        translate([-54,146])
            polygon([[-3,-5],[6,1],[6,3],[-3,3]]);
    }
    stroke([[0,215],[0,228]], 3);
    stroke([[0,228],[-7,238],[0,247],[7,238],[0,228]], 3);
    translate([0,249]) circle(r=5.5);
}

module back_profile_2d() {
    scale([sx,sz])
        union() {
            difference() {
                outline_2d();
                window_void_2d();
                lower_cutouts_2d();
            }
            tracery_2d();
        }
}

// All mechanical geometry uses X = rail travel, Y = depth, Z = height.
module along_x(start, length) {
    translate([start,0,0])
        multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
            linear_extrude(height=length, convexity=10) children();
}

module receiver() {
    difference() {
        translate([-rail_length/2,0,shelf_bottom-rail_wall])
            cube([rail_length,rail_front,rail_tongue_height+2*rail_wall]);
        // A one-sided 45-degree dovetail prints without a bridged channel roof.
        along_x(-rail_length/2+rail_stop, rail_length-rail_stop+eps)
            polygon([
                [groove_back,shelf_bottom-fit_clearance],
                [rail_front+eps,shelf_bottom-fit_clearance],
                [rail_front+eps,shelf_bottom+rail_tongue_height
                    -(rail_front+eps-tongue_back)+fit_clearance],
                [groove_back,shelf_bottom+rail_tongue_height
                    +(tongue_back-groove_back)+fit_clearance]
            ]);
        translate([latch_ramp_start-fit_clearance,
                   latch_tip_depth-fit_clearance,
                   shelf_bottom+latch_lift
                       -(latch_back-latch_tip_depth)-fit_clearance])
            cube([latch_shoulder-latch_ramp_start+2*fit_clearance,
                  rail_front-latch_tip_depth+2*fit_clearance,
                  shelf_thickness-latch_lift
                      +(latch_back-latch_tip_depth)+2*fit_clearance]);
    }
}

module mounting_holes() {
    for (h = [34,249])
        translate([0,back_thickness+eps,h*sz])
            rotate([90,0,0]) {
                cylinder(h=back_thickness+2*eps, d=mount_hole_diameter);
                cylinder(h=(mount_head_diameter-mount_hole_diameter)/2,
                         d1=mount_head_diameter, d2=mount_hole_diameter);
            }
}

module backplate_native() {
    difference() {
        union() {
            translate([0,back_thickness,0])
                rotate([90,0,0])
                    linear_extrude(height=back_thickness, convexity=10)
                        back_profile_2d();
            receiver();
        }
        mounting_holes();
    }
}

module shelf_plan_2d() {
    r = 4;
    hull()
        for (x = [-shelf_width/2+r,shelf_width/2-r])
            for (y = [board_back+r,board_front-r])
                translate([x,y]) circle(r=r);
}

module tongue() {
    along_x(tongue_left, tongue_right-tongue_left)
        polygon([
            [tongue_back,shelf_bottom],
            [board_back+1,shelf_bottom],
            [board_back+1,shelf_bottom+rail_tongue_height
                -(board_back+1-tongue_back)],
            [tongue_back,shelf_bottom+rail_tongue_height]
        ]);
}

module latch(flex = 0) {
    lower = [for (i = [0:curve_steps])
        let(t=i/curve_steps) [latch_root+t*latch_length,
                             latch_back+bend(t,flex)]];
    upper = [for (i = [curve_steps:-1:0])
        let(t=i/curve_steps) [latch_root+t*latch_length,
                             latch_back+latch_thickness+bend(t,flex)]];
    translate([0,0,shelf_bottom]) {
        linear_extrude(height=shelf_thickness)
            polygon(concat(lower,upper));
        // The hook's lower face rises at 45 degrees instead of printing in air.
        translate([0,flex,0])
            intersection() {
                linear_extrude(height=shelf_thickness)
                    polygon([
                        [latch_ramp_start,latch_back+0.5],
                        [latch_ramp_start,latch_back],
                        [latch_tip-2,latch_tip_depth],
                        [latch_shoulder,latch_tip_depth],
                        [latch_shoulder,latch_back+0.5]
                    ]);
                along_x(latch_ramp_start-1,latch_length)
                    polygon([
                        [latch_tip_depth,latch_lift],
                        [latch_back+0.5,latch_lift
                            -(latch_back+0.5-latch_tip_depth)],
                        [latch_back+0.5,shelf_thickness],
                        [latch_tip_depth,shelf_thickness]
                    ]);
            }
    }
}

module shelf_native(flex = 0) {
    union() {
        difference() {
            union() {
                translate([0,0,shelf_bottom])
                    linear_extrude(height=shelf_thickness) shelf_plan_2d();
                tongue();
            }
            // A through-slot leaves the spring entirely in the XY layer plane.
            translate([latch_root+1,rail_front-0.1,shelf_bottom-eps])
                cube([latch_length+2,slot_front-(rail_front-0.1),
                      shelf_thickness+2*eps]);
        }
        translate([latch_root-2,board_back,shelf_bottom])
            cube([3,latch_back+latch_thickness-board_back,shelf_thickness]);
        latch(flex);
    }
}

module backplate_print() {
    multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
        backplate_native();
}

module shelf_print() {
    translate([0,-tongue_back,-shelf_bottom]) shelf_native();
}

module collision(offset = 0, flex = 0) {
    intersection() {
        backplate_native();
        translate([offset,0,0]) shelf_native(flex);
    }
}

scale([output_scale,output_scale,output_scale])
    if (part == "backplate")
        backplate_print();
    else if (part == "shelf")
        shelf_print();
    else if (part == "assembled") {
        mirror([0,1,0]) {
            color("#32303b") backplate_native();
            color("#49434f")
                translate([insertion_offset,0,0]) shelf_native(latch_deflection);
        }
    } else if (part == "layout") {
        color("#32303b") backplate_print();
        color("#49434f")
            translate([(width+shelf_width)/2+layout_gap,0,0]) shelf_print();
    } else if (part == "collision_check")
        collision(insertion_offset,latch_deflection);
    else if (part == "insertion_check") {
        // The hook intentionally cams outward; the rigid dovetail never interferes.
        collision(0,0);
        collision(-fit_clearance,0);
        for (travel = [0:2:rail_length])
            collision(travel,insertion_flex);
    } else
        assert(false,str("Unknown part: ",part));
