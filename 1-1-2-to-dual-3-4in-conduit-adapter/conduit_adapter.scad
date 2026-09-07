// 1-1/2" to Dual 3/4" Schedule 40 PVC Conduit Adapter
//
// A one-piece manifold with a female 1-1/2" socket on the bottom and two
// female 3/4" sockets on top. All conduit ends insert into the fitting
// and stop at the shared internal wire passage.

/* [Part Selection] */
// adapter: printable fitting
// assembled: fitting with conduit stubs inserted
// cross_section: assembled view cut in half for fit inspection
part = "adapter"; // [adapter, assembled, cross_section]

/* [Conduit Dimensions] */
pipe15_od = 48.26;       // 1.900 in actual OD
pipe15_bore = 40.39;     // approximate Schedule 40 inside diameter
pipe34_od = 26.67;       // 1.050 in actual OD
pipe34_bore = 20.93;     // approximate Schedule 40 inside diameter

/* [Fit and Strength] */
socket_clearance = 0.35; // radial clearance around each conduit
wall = 3.2;
deck_thickness = 3.2;
engage_depth_15 = 32;
engage_depth_34 = 24;
lead_in_chamfer = 1.2;

/* [Outlet Layout] */
port_spacing = 31;
transition_height = 16;

/* [Rendering] */
$fn = 128;

eps = 0.25;
port_offset = port_spacing / 2;
face_top_z = engage_depth_15 + transition_height;
manifold_top_z = face_top_z - deck_thickness;
adapter_height = face_top_z + engage_depth_34;

socket15_id = pipe15_od + 2 * socket_clearance;
socket15_od = socket15_id + 2 * wall;
socket34_id = pipe34_od + 2 * socket_clearance;
socket34_od = socket34_id + 2 * wall;

large_stop_width = (socket15_id - pipe15_bore) / 2;
outlet_stop_width = (socket34_id - pipe34_bore) / 2;
shared_web = port_spacing - socket34_id;
outer_transition_run =
    max(0, port_offset + socket34_od / 2 - socket15_od / 2);
inner_transition_run =
    max(0, port_offset + pipe34_bore / 2 - pipe15_bore / 2);
manifold_height = manifold_top_z - engage_depth_15;

assert(transition_height > deck_thickness,
    "transition_height must exceed deck_thickness");
assert(socket_clearance >= 0,
    "socket_clearance cannot be negative");
assert(wall > lead_in_chamfer,
    "wall must exceed lead_in_chamfer");
assert(pipe15_bore < pipe15_od && pipe34_bore < pipe34_od,
    "Each conduit bore must be smaller than its outside diameter");
assert(large_stop_width >= wall && outlet_stop_width >= wall,
    "Pipe-stop shoulder is too narrow; reduce the corresponding conduit bore");
assert(shared_web >= wall,
    "port_spacing is too small to leave a full wall between outlet sockets");
assert(transition_height >= outer_transition_run,
    "Transition is too short for a support-free outer taper");
assert(manifold_height >= inner_transition_run,
    "Transition is too short for a support-free internal manifold");

module at_outlets(z)
{
    for (x = [-port_offset, port_offset])
        translate([x, 0, z])
            children();
}

module outer_transition()
{
    hull()
    {
        translate([0, 0, engage_depth_15 - eps])
            cylinder(h = eps, d = socket15_od);
        at_outlets(face_top_z - eps)
            cylinder(h = eps, d = socket34_od);
    }
}

module manifold_cavity()
{
    hull()
    {
        translate([0, 0, engage_depth_15 - eps])
            cylinder(h = eps, d = pipe15_bore);
        at_outlets(manifold_top_z - eps)
            cylinder(h = eps, d = pipe34_bore);
    }
}

module adapter()
{
    difference()
    {
        union()
        {
            cylinder(h = engage_depth_15 + eps, d = socket15_od);
            outer_transition();
            at_outlets(face_top_z - eps)
                cylinder(h = engage_depth_34 + eps, d = socket34_od);
        }

        // Large female socket and flared entry.
        translate([0, 0, -eps])
            cylinder(h = engage_depth_15 + eps, d = socket15_id);
        translate([0, 0, -eps])
            cylinder(
                h = lead_in_chamfer + eps,
                d1 = socket15_id + 2 * lead_in_chamfer,
                d2 = socket15_id
            );

        // Shared support-free passage between all three pipe stops.
        manifold_cavity();
        at_outlets(manifold_top_z - eps)
            cylinder(h = deck_thickness + 2 * eps, d = pipe34_bore);

        // Two female outlet sockets and flared entries.
        at_outlets(face_top_z)
            cylinder(h = engage_depth_34 + eps, d = socket34_id);
        at_outlets(adapter_height - lead_in_chamfer)
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

module assembled()
{
    preview_protrusion = 30;

    color("DarkOrange")
        adapter();

    color("LightSteelBlue", 0.8)
    {
        translate([0, 0, -preview_protrusion])
            mock_pipe(
                pipe15_od,
                pipe15_bore,
                engage_depth_15 + preview_protrusion
            );

        at_outlets(face_top_z)
            mock_pipe(
                pipe34_od,
                pipe34_bore,
                engage_depth_34 + preview_protrusion
            );
    }
}

if (part == "adapter")
    adapter();
else if (part == "assembled")
    assembled();
else if (part == "cross_section")
    difference()
    {
        assembled();
        translate([-100, -200, -100])
            cube([200, 200, 300]);
    }
else
    assert(false, str("Unknown part: ", part));
