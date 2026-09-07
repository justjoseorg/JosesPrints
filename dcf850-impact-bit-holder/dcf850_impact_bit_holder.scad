// DCF850 impact bit holder
//
// A screw-mounted holder for 4 spare 1/4" hex impact bits that
// attaches to a Dewalt DCF850 (and most Dewalt 20V Max compact
// impact driver/drill) using the same single M4 screw and threaded
// hole that normally holds the factory belt clip on the side of the
// tool's handle.
//
// The mounting tab is a flat plate with a single clearance hole and a
// counterbore for the screw head, sized to match the stock belt-clip
// screw (M4, ~8 mm long). Because it is a single-point screw mount
// (like the stock belt clip), rotate the part to the desired angle
// before fully tightening the screw -- friction against the tool
// body plus screw tension hold it in place, there is no keyed
// anti-rotation feature.
//
// Render selector: "holder" (the printable part) or "assembled"
// (identical geometry, used for the preview render).
part = "assembled"; // [holder, assembled]

// ---- Bit fit parameters ----
// Standard 1/4" hex bit shank measured across flats (impact bits use
// the same shank size as regular hex-shank bits).
hex_flat_to_flat = 6.35;
// Extra room added to the shank size so bits slide in snugly but
// still hold under friction. Increase slightly if bits are too tight,
// decrease if they fall out.
hex_clearance = 0.4;
hex_hole_size = hex_flat_to_flat + hex_clearance;

// Depth of straight hex socket that grips the bit shank.
socket_depth = 14;
// Extra tapered lead-in at the top of each socket to make it easy to
// find and start inserting a bit.
lead_in_height = 2;
// How much wider the lead-in mouth is than the socket, per side.
lead_in_oversize = 1.2;

// ---- Grid layout ----
// Single row of 4 bits keeps the holder slim against the tool body.
bit_count = 4;
// Solid wall thickness left between adjacent hex holes and around the
// outer edge of the block.
wall_thickness = 3;

// ---- Base plate (bit block) ----
base_thickness = 3.5;
corner_radius = 3;

block_height = base_thickness + socket_depth + lead_in_height;
hex_pitch = hex_hole_size + wall_thickness;

block_width = bit_count * hex_pitch + wall_thickness;
block_depth = hex_pitch;

// ---- Mounting tab ----
// Matches the stock Dewalt belt-clip screw: M4 machine screw, ~8 mm
// long. Sized generously so it can be trimmed/filed to fit the exact
// curve of the handle if needed.
mount_screw_clearance_d = 4.6;
mount_head_d = 8.2;
mount_head_depth = 3;
mount_tab_width = block_depth + 6;
mount_tab_length = 18;
mount_tab_thickness = base_thickness;

mount_rect_fn = 48;

module rounded_rect(width, depth, radius, height) {
    linear_extrude(height = height)
        offset(r = radius, $fn = mount_rect_fn)
            offset(delta = -radius)
                square([width, depth], center = true);
}

module hex_hole(size, depth) {
    // Flat-to-flat sized hexagon: circumscribed circle diameter = size / cos(30)
    hole_d = size / cos(30);
    lead_d = (size + 2 * lead_in_oversize) / cos(30);

    translate([0, 0, block_height - lead_in_height])
        cylinder(h = lead_in_height + 0.01, d1 = hole_d, d2 = lead_d, $fn = 6);

    translate([0, 0, block_height - lead_in_height - depth])
        cylinder(h = depth + lead_in_height + 0.02, d = hole_d, $fn = 6);
}

module bit_block() {
    difference() {
        rounded_rect(block_width, block_depth, corner_radius, block_height);

        x_start = -block_width / 2 + wall_thickness + hex_hole_size / cos(30) / 2;

        for (i = [0 : bit_count - 1])
            translate([x_start + i * hex_pitch, 0, 0])
                hex_hole(hex_hole_size, socket_depth);
    }
}

module mount_tab() {
    difference() {
        translate([0, mount_tab_length / 2, 0])
            rounded_rect(mount_tab_width, mount_tab_length, corner_radius, mount_tab_thickness);

        // Through hole for the M4 screw shaft.
        translate([0, mount_tab_length * 0.62, -0.1])
            cylinder(h = mount_tab_thickness + 0.2, d = mount_screw_clearance_d, $fn = 32);

        // Counterbore on the outward face so the screw head sits flush.
        translate([0, mount_tab_length * 0.62, mount_tab_thickness - mount_head_depth])
            cylinder(h = mount_head_depth + 0.1, d = mount_head_d, $fn = 32);
    }
}

module bit_holder() {
    union() {
        bit_block();
        translate([0, block_depth / 2, 0])
            mount_tab();
    }
}

if (part == "holder" || part == "assembled") {
    bit_holder();
}
