// Open Octagonal 1-1/2" to Eight 3/4" PVC Conduit Access Box
//
// A one-piece open-top access box with a female 1-1/2" socket centered
// underneath and one horizontal female 3/4" socket through each side.

/* [Part Selection] */
// box: printable access box
// assembled: box with all nine conduit stubs inserted
// cross_section: assembled view cut in half for fit inspection
part = "box"; // [box, assembled, cross_section]

/* [Conduit Dimensions] */
pipe15_od = 48.26;       // 1.900 in actual OD
pipe15_bore = 40.39;     // approximate Schedule 40 inside diameter
pipe34_od = 26.67;       // 1.050 in actual OD
pipe34_bore = 20.93;     // approximate Schedule 40 inside diameter

/* [Fit and Strength] */
socket_clearance = 0.35; // radial clearance around each conduit
wall = 3.2;
floor_thickness = 4;
engage_depth_15 = 32;
engage_depth_34 = 24;
outlet_stop_thickness = 3.2;
lead_in_chamfer = 1.2;

/* [Octagonal Access Box] */
inner_apothem = 44;      // center to inside face; 88 mm inside across flats
box_height = 55;
outlet_center_height = 27.5;
side_count = 8;

/* [Rendering] */
$fn = 96;

eps = 0.25;
octagon_face_angle = 180 / side_count;
outer_apothem = inner_apothem + wall;
inner_radius = inner_apothem / cos(octagon_face_angle);
outer_radius = outer_apothem / cos(octagon_face_angle);

box_bottom_z = engage_depth_15;
chamber_bottom_z = box_bottom_z + floor_thickness;
box_top_z = box_bottom_z + box_height;
outlet_axis_z = box_bottom_z + outlet_center_height;

socket15_id = pipe15_od + 2 * socket_clearance;
socket15_od = socket15_id + 2 * wall;
socket34_id = pipe34_od + 2 * socket_clearance;
socket34_od = socket34_id + 2 * wall;

outlet_mouth_radius = outer_apothem + engage_depth_34;
outlet_boss_length = engage_depth_34 + eps;
outlet_passage_length = wall + outlet_stop_thickness + 2 * eps;
large_stop_width = (socket15_id - pipe15_bore) / 2;
outlet_stop_width = (socket34_id - pipe34_bore) / 2;
vertical_outlet_margin = (box_height - socket34_od) / 2;

assert(side_count == 8,
    "This access box requires eight sides and eight outlets");
assert(socket_clearance >= 0,
    "socket_clearance cannot be negative");
assert(wall > lead_in_chamfer,
    "wall must exceed lead_in_chamfer");
assert(floor_thickness > 0 && outlet_stop_thickness > 0,
    "Floor and outlet stops must have positive thickness");
assert(pipe15_bore < pipe15_od && pipe34_bore < pipe34_od,
    "Each conduit bore must be smaller than its outside diameter");
assert(large_stop_width >= wall && outlet_stop_width >= wall,
    "Pipe-stop shoulder is too narrow; reduce the corresponding conduit bore");
assert(vertical_outlet_margin >= wall,
    "box_height is too short to retain full walls above and below the outlets");
assert(outlet_center_height == box_height / 2,
    "Keep horizontal outlets centered vertically in the access box");
assert(socket15_od / 2 < inner_apothem,
    "The bottom inlet is too large for the access-box floor");

module radial_cylinder(angle, radial_start, z, length, diameter)
{
    rotate([0, 0, angle])
        translate([radial_start, 0, z])
            rotate([0, 90, 0])
                cylinder(h = length, d = diameter);
}

module radial_frustum(angle, radial_start, z, length, diameter1, diameter2)
{
    rotate([0, 0, angle])
        translate([radial_start, 0, z])
            rotate([0, 90, 0])
                cylinder(h = length, d1 = diameter1, d2 = diameter2);
}

module at_sides()
{
    for (index = [0 : side_count - 1])
        let(angle = octagon_face_angle + index * 360 / side_count)
            rotate([0, 0, angle])
                children();
}

module access_box()
{
    difference()
    {
        union()
        {
            // Bottom female inlet and the octagonal box shell.
            cylinder(h = box_bottom_z + floor_thickness, d = socket15_od);
            translate([0, 0, box_bottom_z])
                cylinder(h = box_height, r = outer_radius, $fn = side_count);

            // One horizontal socket boss normal to each octagon face.
            at_sides()
                radial_cylinder(
                    0,
                    outer_apothem - eps,
                    outlet_axis_z,
                    outlet_boss_length,
                    socket34_od
                );
        }

        // Open access chamber, leaving an octagonal wall and solid floor.
        translate([0, 0, chamber_bottom_z])
            cylinder(
                h = box_height - floor_thickness + eps,
                r = inner_radius,
                $fn = side_count
            );

        // Female 1-1/2" bottom socket, lead-in, and floor passage.
        translate([0, 0, -eps])
            cylinder(h = engage_depth_15 + eps, d = socket15_id);
        translate([0, 0, -eps])
            cylinder(
                h = lead_in_chamfer + eps,
                d1 = socket15_id + 2 * lead_in_chamfer,
                d2 = socket15_id
            );
        translate([0, 0, engage_depth_15 - eps])
            cylinder(
                h = floor_thickness + 2 * eps,
                d = pipe15_bore
            );

        // Female side sockets. Smaller passages through the walls create
        // positive pipe stops before each opening reaches the chamber.
        at_sides()
        {
            radial_cylinder(
                0,
                outer_apothem,
                outlet_axis_z,
                engage_depth_34 + eps,
                socket34_id
            );
            radial_cylinder(
                0,
                inner_apothem - outlet_stop_thickness - eps,
                outlet_axis_z,
                outlet_passage_length,
                pipe34_bore
            );
            radial_frustum(
                0,
                outlet_mouth_radius - lead_in_chamfer,
                outlet_axis_z,
                lead_in_chamfer + eps,
                socket34_id,
                socket34_id + 2 * lead_in_chamfer
            );
        }
    }
}

module mock_pipe(outer_diameter, bore_diameter, length)
{
    difference()
    {
        cylinder(h = length, d = outer_diameter);
        translate([0, 0, -eps])
            cylinder(h = length + 2 * eps, d = bore_diameter);
    }
}

module radial_mock_pipe(angle, radial_start, z, length)
{
    rotate([0, 0, angle])
        translate([radial_start, 0, z])
            rotate([0, 90, 0])
                mock_pipe(pipe34_od, pipe34_bore, length);
}

module assembled()
{
    preview_protrusion = 24;

    color("DarkOrange")
        access_box();

    color("LightSteelBlue", 0.8)
    {
        translate([0, 0, -preview_protrusion])
            mock_pipe(
                pipe15_od,
                pipe15_bore,
                engage_depth_15 + preview_protrusion
            );

        for (index = [0 : side_count - 1])
            radial_mock_pipe(
                octagon_face_angle + index * 360 / side_count,
                outer_apothem,
                outlet_axis_z,
                engage_depth_34 + preview_protrusion
            );
    }
}

if (part == "box")
    access_box();
else if (part == "assembled")
    assembled();
else if (part == "cross_section")
    difference()
    {
        assembled();
        translate([-200, 0, -100])
            cube([400, 250, 300]);
    }
else
    assert(false, str("Unknown part: ", part));
