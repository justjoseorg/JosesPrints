// 3" to Dual 3/4" Schedule 40 PVC Conduit Adapter
//
// A cap-style fitting that slips over the OD of a 3" Schedule 40 PVC
// conduit and provides two 3/4" Schedule 40 sockets on its face, so two
// runs of 3/4" conduit can transition into a single 3" conduit. All three
// bores are joined into one open manifold so wire/cable can pass through
// freely; the fitting carries no independent structural/pressure duty.
//
// Both connections are FEMALE (sockets): the adapter slips over the
// OUTSIDE of the 3" pipe, and the two 3/4" pipes are inserted INTO the
// adapter's 3/4" sockets. Solvent cement does not reliably bond to
// printed plastic, so treat this as a friction-fit / mechanically-glued
// (e.g. PVC cement + epoxy, or silicone sealant) adapter rather than a
// code-rated solvent weld fitting.

/* [Part Selection] */
// Which object to render: adapter (the single printable part), assembled
// (adapter shown with mock pipe stubs inserted, for fit verification),
// or cross_section (assembled view cut in half to inspect the internal
// manifold and wall thickness).
part = "adapter"; // [adapter, assembled, cross_section]

/* [Schedule 40 PVC Conduit Dimensions (reference, do not print-adjust)] */
// Actual outer diameter of 3" Schedule 40 PVC conduit.
pipe3_od = 88.90; // 3.500 in
// Actual outer diameter of 3/4" Schedule 40 PVC conduit.
pipe34_od = 26.67; // 1.050 in

/* [Fit & Wall Parameters] */
// Radial clearance added to each socket ID over the mating pipe OD, per
// side, to allow the printed pipe to slide in. Increase if your printer
// runs tight; keep small enough that the joint can still be glued/sealed.
socket_clearance = 0.35;
// Wall thickness of the printed shell around each socket.
wall = 3.2;
// Total thickness of the face plate between the 3" socket bottom and the
// base of the 3/4" sockets, measured along the pipe axis. This splits into
// a solid top deck (deck_thickness) plus an internal manifold gap below it
// that lets wire route from the 3" bore into either 3/4" bore.
cap_face_thickness = 9.0;
// Solid deck thickness left at the very top of the face plate (the flat
// area around the two bosses), above the internal manifold chamber. Must
// be less than cap_face_thickness. Keeps the top from being wide open.
deck_thickness = wall;
// How far the 3" pipe end inserts into the cap (engagement depth).
engage_depth_3in = 45; // ~1.8 in, comfortably above code minimum for a slip cap
// How far each 3/4" pipe end inserts into its socket (engagement depth).
engage_depth_34in = 22; // ~0.9 in
// Center-to-center spacing between the two 3/4" ports.
port_spacing = 34;
// Small chamfer size on socket entrances to ease starting the pipe.
lead_in_chamfer = 1.6;

/* [Rendering] */
$fn = 96;

// ---- Derived dimensions ----
socket3_id = pipe3_od + 2 * socket_clearance;      // ID of the cap that slips over the 3" pipe
socket3_od = socket3_id + 2 * wall;                // outer diameter of the cap shell
socket34_id = pipe34_od + 2 * socket_clearance;    // ID of each 3/4" socket
socket34_od = socket34_id + 2 * wall;              // outer diameter of each 3/4" boss

// Overall stack height along the pipe axis, from the open (3" pipe entry)
// end to the top of the 3/4" bosses.
cap_top_z = engage_depth_3in;                       // top of 3" socket cavity / bottom of face plate
face_top_z = cap_top_z + cap_face_thickness;        // top face where 3/4" bosses start
boss_top_z = face_top_z + engage_depth_34in;        // top of the 3/4" bosses
total_height = boss_top_z;

// Half-spacing so the two 3/4" ports are centered on the part's axis.
port_offset = port_spacing / 2;

// Sanity check: the two 3/4" bosses (plus their walls) must fit inside the
// 3" cap's outer shell footprint without overlapping it.
assert(port_spacing + socket34_od <= socket3_od,
    "port_spacing/port sizes too large for the 3in cap footprint - reduce port_spacing or wall");
// Sanity check: there must be room for a manifold gap below the solid deck.
assert(cap_face_thickness > deck_thickness,
    "cap_face_thickness must be greater than deck_thickness to leave room for the internal manifold");

module adapter()
{
    eps = 0.5; // generous overlap epsilon so adjoining cavities always fuse cleanly

    difference()
    {
        union()
        {
            // Outer shell of the 3" cap, from the open pipe-entry end up to
            // the top of the face plate.
            cylinder(h = face_top_z, d = socket3_od);

            // Two 3/4" bosses rising from the face plate.
            for (dx = [-port_offset, port_offset])
                translate([dx, 0, face_top_z - eps])
                    cylinder(h = engage_depth_34in + eps, d = socket34_od);
        }

        // 3" pipe socket cavity (open at the bottom), overlapping up into
        // the manifold cavity above it.
        translate([0, 0, -1])
            cylinder(h = engage_depth_3in + eps + 1, d = socket3_id);

        // Manifold chamber inside the face plate: a shared open cavity that
        // both 3/4" sockets tunnel down into, so wire can pass from the 3"
        // pipe into either 3/4" run. Its ceiling stops deck_thickness below
        // the top face, leaving a solid deck there (punctured only by the
        // two 3/4" bores themselves) instead of leaving the top wide open.
        manifold_id = socket3_id - 2 * wall;
        translate([0, 0, cap_top_z - eps])
            cylinder(h = cap_face_thickness - deck_thickness + 2 * eps, d = manifold_id);

        // Two 3/4" pipe socket cavities (open at the top), tunneling down
        // through the solid deck into the manifold chamber below, each with
        // a flared lead-in chamfer right at the opening to ease insertion.
        for (dx = [-port_offset, port_offset])
        {
            translate([dx, 0, face_top_z - deck_thickness - eps])
                cylinder(h = engage_depth_34in + deck_thickness + eps + 1, d = socket34_id);
            translate([dx, 0, boss_top_z - lead_in_chamfer])
                cylinder(h = lead_in_chamfer + eps, d1 = socket34_id, d2 = socket34_id + 2 * lead_in_chamfer);
        }

        // Flared lead-in chamfer at the 3" pipe entry (bottom of the part).
        translate([0, 0, -eps])
            cylinder(h = 2 * lead_in_chamfer + eps, d1 = socket3_id + 2 * 2 * lead_in_chamfer, d2 = socket3_id);
    }
}

module mock_pipe(od, id_bore, length, z0 = 0)
{
    // Simple stand-in pipe stub for fit-check renders only (not printed).
    translate([0, 0, z0])
        difference()
        {
            cylinder(h = length, d = od);
            translate([0, 0, -1])
                cylinder(h = length + 2, d = id_bore);
        }
}

module assembled()
{
    adapter();

    color("LightBlue", 0.85)
    {
        // 3" pipe fully bottomed in its socket (top flush with cap_top_z),
        // protruding well below the cap opening for a clear fit-check view.
        protrude = 50;
        pipe3_len = engage_depth_3in + protrude;
        translate([0, 0, cap_top_z - pipe3_len])
            mock_pipe(pipe3_od, pipe3_od - 2 * 4.6, pipe3_len);

        // Two 3/4" pipes fully bottomed in their sockets (bottom flush with
        // face_top_z), protruding well above the bosses.
        for (dx = [-port_offset, port_offset])
            translate([dx, 0, face_top_z])
                mock_pipe(pipe34_od, pipe34_od - 2 * 2.2, engage_depth_34in + protrude);
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
        translate([-200, 0, -200])
            cube([400, 400, 400]);
    }
