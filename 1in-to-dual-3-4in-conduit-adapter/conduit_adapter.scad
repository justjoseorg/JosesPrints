// 1" to Dual 3/4" Schedule 40 PVC Conduit Adapter
//
// One female inlet and two female outlets, all snug unthreaded slip
// sockets. Positive pipe stops open into a shared tapered wire passage.

/* [Part Selection] */
// adapter: printable fitting
// assembled: fitting with conduit stubs inserted
// cross_section: assembled view cut in half for fit inspection
// fit_clearance_check: empty when the conduits clear the fitting
part = "adapter"; // [adapter, assembled, cross_section, fit_clearance_check]

/* [Conduit Dimensions] */
pipe1_od = 33.40;        // 1.315 in actual OD, rounded to 0.01 mm
pipe1_bore = 26.64;      // approximate Schedule 40 inside diameter
pipe34_od = 26.67;       // 1.050 in actual OD
pipe34_bore = 20.93;     // approximate Schedule 40 inside diameter

/* [Fit and Strength] */
socket_clearance = 0.15; // radial clearance; adds 0.30 mm to socket diameter
wall = 3.2;
deck_thickness = 3.2;
min_stop_width = 2.4;
engage_depth_1 = 28;
engage_depth_34 = 24;
lead_in_chamfer = 1.2;

/* [Outlet Layout] */
port_spacing = 31;
transition_height = 22;

/* [Rendering] */
$fn = 128;
preview_protrusion = 30;

/* [Hidden] */
eps = 0.01;
port_offset = port_spacing / 2;
face_top_z = engage_depth_1 + transition_height;
manifold_top_z = face_top_z - deck_thickness;
adapter_height = face_top_z + engage_depth_34;

socket1_id = pipe1_od + 2 * socket_clearance;
socket1_od = socket1_id + 2 * wall;
socket34_id = pipe34_od + 2 * socket_clearance;
socket34_od = socket34_id + 2 * wall;

inlet_stop_width = (socket1_id - pipe1_bore) / 2;
outlet_stop_width = (socket34_id - pipe34_bore) / 2;
shared_web = port_spacing - socket34_id;
outer_transition_run =
    max(0, port_offset + socket34_od / 2 - socket1_od / 2);
inner_transition_run =
    max(0, port_offset + pipe34_bore / 2 - pipe1_bore / 2);
manifold_height = manifold_top_z - engage_depth_1;

assert(socket_clearance > 0,
    "socket_clearance must leave positive clearance around each conduit");
assert(wall > lead_in_chamfer && lead_in_chamfer > 0,
    "The entry chamfer must be positive and smaller than the socket wall");
assert(deck_thickness > 0 && transition_height > deck_thickness,
    "transition_height must exceed a positive deck_thickness");
assert(engage_depth_1 > lead_in_chamfer &&
       engage_depth_34 > lead_in_chamfer,
    "Both insertion depths must exceed the entry chamfer");
assert(pipe1_bore > 0 && pipe1_bore < pipe1_od &&
       pipe34_bore > 0 && pipe34_bore < pipe34_od,
    "Each conduit bore must be positive and smaller than its outside diameter");
assert(min_stop_width > 0 &&
       inlet_stop_width >= min_stop_width &&
       outlet_stop_width >= min_stop_width,
    "Each pipe-stop shoulder must retain at least min_stop_width");
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
        translate([0, 0, engage_depth_1 - eps])
            cylinder(h = eps, d = socket1_od);
        at_outlets(face_top_z - eps)
            cylinder(h = eps, d = socket34_od);
    }
}

module manifold_cavity()
{
    hull()
    {
        translate([0, 0, engage_depth_1 - eps])
            cylinder(h = eps, d = pipe1_bore);
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
            cylinder(h = engage_depth_1 + eps, d = socket1_od);
            outer_transition();
            at_outlets(face_top_z - eps)
                cylinder(h = engage_depth_34 + eps, d = socket34_od);
        }

        translate([0, 0, -eps])
            cylinder(h = engage_depth_1 + eps, d = socket1_id);
        translate([0, 0, -eps])
            cylinder(
                h = lead_in_chamfer + eps,
                d1 = socket1_id + 2 * lead_in_chamfer,
                d2 = socket1_id
            );

        manifold_cavity();
        at_outlets(manifold_top_z - eps)
            cylinder(h = deck_thickness + 2 * eps, d = pipe34_bore);

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

module mock_conduits(seat_gap = 0)
{
    translate([0, 0, -preview_protrusion - seat_gap])
        mock_pipe(pipe1_od, pipe1_bore, engage_depth_1 + preview_protrusion);

    at_outlets(face_top_z + seat_gap)
        mock_pipe(pipe34_od, pipe34_bore, engage_depth_34 + preview_protrusion);
}

module assembled()
{
    color("DarkOrange")
        adapter();
    color("LightSteelBlue", 0.8)
        mock_conduits();
}

module fit_clearance_check()
{
    intersection()
    {
        adapter();
        // Exclude intentional end-face contact with the pipe stops.
        mock_conduits(seat_gap = eps);
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
        cut_width = max(socket1_od, port_spacing + socket34_od) + 2;
        translate([-cut_width, -cut_width, -preview_protrusion - 1])
            cube([
                2 * cut_width,
                cut_width,
                adapter_height + 2 * preview_protrusion + 2
            ]);
    }
else if (part == "fit_clearance_check")
    fit_clearance_check();
else
    assert(false, str("Unknown part: ", part));
