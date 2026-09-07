// 2" to Four 3/4" Schedule 40 PVC Conduit Adapter
//
// A one-piece manifold with a female 2" socket on the bottom and four
// female 3/4" sockets in a centered 2x2 array on top. Any outlet can be
// used first while removable plugs close the other three. The sockets fit
// standard Schedule 40 PVC electrical conduit and are not threaded.

/* [Part Selection] */
// adapter: printable part
// plug: one removable branch plug (print three copies)
// layout: adapter and three plugs arranged for printing
// assembled: one conduit installed and the other three outlets capped
// expanded: conduit installed in all four outlets
// cross_section: assembled view cut in half to inspect stops and passages
part = "adapter"; // [adapter, plug, layout, assembled, expanded, cross_section]

/* [Conduit Dimensions] */
pipe2_od = 60.325;       // 2.375 in actual OD
pipe2_bore = 52.50;      // approximate Schedule 40 inside diameter
pipe34_od = 26.67;       // 1.050 in actual OD
pipe34_bore = 20.93;     // approximate Schedule 40 inside diameter

/* [Fit and Strength] */
// Clearance is radial, so each socket ID is twice this value over pipe OD.
socket_clearance = 0.35;
wall = 3.2;
deck_thickness = 3.2;
engage_depth_2in = 38;
engage_depth_34in = 22;
lead_in_chamfer = 1.2;

/* [Removable Branch Plugs] */
plug_fit_clearance = 0.20;
plug_insertion_depth = 14;
plug_flange_thickness = 3.2;
plug_flange_overhang = 0.8;

/* [Outlet Layout] */
// Center-to-center spacing in both axes for the four-socket 2x2 array.
port_spacing = 36;
transition_height = 16;

/* [Rendering] */
$fn = 96;

eps = 0.25;
port_offset = port_spacing / 2;
primary_x = -port_offset;
primary_y = port_offset;
future_outlet_count = 3;

socket2_id = pipe2_od + 2 * socket_clearance;
socket2_od = socket2_id + 2 * wall;
socket34_id = pipe34_od + 2 * socket_clearance;
socket34_od = socket34_id + 2 * wall;

transition_bottom_z = engage_depth_2in;
face_top_z = transition_bottom_z + transition_height;
manifold_top_z = face_top_z - deck_thickness;
boss_top_z = face_top_z + engage_depth_34in;

input_stop_width = (socket2_id - pipe2_bore) / 2;
output_stop_width = (socket34_id - pipe34_bore) / 2;
shared_web = port_spacing - socket34_id;
top_corner_radius = sqrt(2) * port_offset + socket34_od / 2;
outer_transition_run = top_corner_radius - socket2_od / 2;
manifold_corner_radius = sqrt(2) * port_offset + pipe34_bore / 2;
inner_transition_run = manifold_corner_radius - pipe2_bore / 2;
manifold_height = manifold_top_z - transition_bottom_z;
plug_shaft_diameter = socket34_id - 2 * plug_fit_clearance;
plug_flange_diameter = socket34_od + 2 * plug_flange_overhang;

assert(pipe2_bore < pipe2_od && pipe34_bore < pipe34_od,
    "Each conduit bore must be smaller than its outside diameter");
assert(socket_clearance >= 0,
    "socket_clearance cannot be negative");
assert(wall > lead_in_chamfer,
    "wall must exceed lead_in_chamfer to retain material at each socket mouth");
assert(shared_web >= wall,
    "port_spacing is too small to leave a full wall between socket bores");
assert(plug_fit_clearance > 0 && plug_shaft_diameter <= socket34_id,
    "plug_fit_clearance must leave a positive sliding fit");
assert(plug_insertion_depth < engage_depth_34in,
    "plug_insertion_depth must stop before the 3/4in socket shoulder");
assert(plug_flange_diameter < port_spacing,
    "Plug flanges collide; increase port_spacing or reduce their overhang");
assert(input_stop_width >= wall,
    "The 2in insertion stop is narrower than wall; reduce pipe2_bore");
assert(output_stop_width >= wall,
    "The 3/4in insertion stops are narrower than wall; reduce pipe34_bore");
assert(deck_thickness > 0 && deck_thickness < transition_height,
    "deck_thickness must be positive and smaller than transition_height");
assert(transition_height >= outer_transition_run,
    "transition_height is too short for a support-free outer shoulder");
assert(manifold_height >= inner_transition_run,
    "transition/deck dimensions make the internal manifold overhang too steep");

module at_outlets(z)
{
    for (x = [-port_offset, port_offset])
        for (y = [-port_offset, port_offset])
            translate([x, y, z])
                children();
}

module at_future_outlets(z)
{
    for (x = [-port_offset, port_offset])
        for (y = [-port_offset, port_offset])
            if (x != primary_x || y != primary_y)
                translate([x, y, z])
                    children();
}

module at_primary_outlet(z)
{
    translate([primary_x, primary_y, z])
        children();
}

module outlet_cylinders(z, height, diameter)
{
    at_outlets(z)
        cylinder(h = height, d = diameter);
}

module outer_transition()
{
    hull()
    {
        translate([0, 0, transition_bottom_z - eps])
            cylinder(h = 2 * eps, d = socket2_od);

        outlet_cylinders(face_top_z - eps, eps, socket34_od);
    }
}

module manifold_cavity()
{
    hull()
    {
        translate([0, 0, transition_bottom_z - eps])
            cylinder(h = 2 * eps, d = pipe2_bore);

        outlet_cylinders(manifold_top_z - eps, eps, pipe34_bore);
    }
}

module adapter()
{
    difference()
    {
        union()
        {
            cylinder(h = transition_bottom_z + eps, d = socket2_od);
            outer_transition();
            outlet_cylinders(
                face_top_z - eps,
                engage_depth_34in + eps,
                socket34_od
            );
        }

        // Female 2" socket. Its reduced bore at the top forms a pipe stop.
        translate([0, 0, -eps])
            cylinder(h = engage_depth_2in + eps, d = socket2_id);

        translate([0, 0, -eps])
            cylinder(
                h = lead_in_chamfer + eps,
                d1 = socket2_id + 2 * lead_in_chamfer,
                d2 = socket2_id
            );

        manifold_cavity();

        // Four wire passages connect the manifold to the socket bottoms.
        outlet_cylinders(
            manifold_top_z - eps,
            deck_thickness + 2 * eps,
            pipe34_bore
        );

        // Female 3/4" sockets. The smaller passages leave positive stops.
        outlet_cylinders(
            face_top_z,
            engage_depth_34in + eps,
            socket34_id
        );

        at_outlets(boss_top_z - lead_in_chamfer)
            cylinder(
                h = lead_in_chamfer + eps,
                d1 = socket34_id,
                d2 = socket34_id + 2 * lead_in_chamfer
            );
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

module outlet_plug()
{
    tip_chamfer = min(lead_in_chamfer, plug_insertion_depth / 3);

    union()
    {
        cylinder(
            h = plug_flange_thickness,
            d = plug_flange_diameter
        );

        translate([0, 0, plug_flange_thickness - eps])
            cylinder(
                h = plug_insertion_depth - tip_chamfer + eps,
                d = plug_shaft_diameter
            );

        translate([
            0,
            0,
            plug_flange_thickness + plug_insertion_depth - tip_chamfer
        ])
            cylinder(
                h = tip_chamfer,
                d1 = plug_shaft_diameter,
                d2 = plug_shaft_diameter - 2 * tip_chamfer
            );
    }
}

module installed_future_plugs()
{
    at_future_outlets(boss_top_z + plug_flange_thickness)
        rotate([180, 0, 0])
            outlet_plug();
}

module assembled()
{
    color("DarkOrange")
        adapter();

    preview_protrusion = 35;

    color("LightSteelBlue", 0.8)
    {
        input_pipe_length = engage_depth_2in + preview_protrusion;
        translate([0, 0, transition_bottom_z - input_pipe_length])
            mock_pipe(pipe2_od, pipe2_bore, input_pipe_length);

        at_primary_outlet(face_top_z)
            mock_pipe(
                pipe34_od,
                pipe34_bore,
                engage_depth_34in + preview_protrusion
            );
    }

    color("SlateGray")
        installed_future_plugs();
}

module expanded()
{
    color("DarkOrange")
        adapter();

    preview_protrusion = 35;

    color("LightSteelBlue", 0.8)
    {
        input_pipe_length = engage_depth_2in + preview_protrusion;
        translate([0, 0, transition_bottom_z - input_pipe_length])
            mock_pipe(pipe2_od, pipe2_bore, input_pipe_length);

        at_outlets(face_top_z)
            mock_pipe(
                pipe34_od,
                pipe34_bore,
                engage_depth_34in + preview_protrusion
            );
    }
}

module layout()
{
    adapter();

    layout_x =
        top_corner_radius + plug_flange_diameter / 2 + 6;
    layout_pitch = plug_flange_diameter + 4;

    for (index = [0 : future_outlet_count - 1])
        translate([
            layout_x,
            (index - (future_outlet_count - 1) / 2) * layout_pitch,
            0
        ])
            outlet_plug();
}

if (part == "adapter")
    adapter();
else if (part == "plug")
    outlet_plug();
else if (part == "layout")
    layout();
else if (part == "assembled")
    assembled();
else if (part == "expanded")
    expanded();
else if (part == "cross_section")
    difference()
    {
        assembled();
        translate([-150, -300, -150])
            cube([300, 300, 300]);
    }
else
    assert(false, str("Unknown part: ", part));
