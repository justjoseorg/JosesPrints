# DCF850 Impact Bit Holder

![Rendered impact bit holder](preview.png)

A screw-mounted holder for 4 spare 1/4" hex impact bits that attaches directly to a Dewalt DCF850 (and most Dewalt 20V Max compact impact driver/drill models sharing the same body) using the stock belt-clip screw hole on the side of the handle. Remove the factory belt clip, bolt this holder on in its place, and 4 bits ride snugly along the side of the tool.

## Files

| File | Description |
| --- | --- |
| [`dcf850_impact_bit_holder.scad`](dcf850_impact_bit_holder.scad) | Parametric OpenSCAD source |
| [`printable-part.stl`](printable-part.stl) | Bit holder part |
| [`preview.png`](preview.png) | Top-down render showing the mounting hole and hex sockets |

## Interactive 3D preview

GitHub's STL viewer lets you rotate and inspect the part:

- [Open the holder in the 3D viewer](printable-part.stl)

## Hardware

- Reuses the **stock Dewalt belt-clip screw**: an M4 machine screw, roughly 8 mm long, that already threads into the handle where the belt clip mounts. No extra hardware is required.
- The mounting tab has a 4.6 mm clearance hole with an 8.2 mm × 3 mm counterbore so the screw head sits flush/recessed instead of protruding.

## Dimensions

- Bit block: 4 hex sockets in a single row, holding standard 1/4" (6.35 mm) hex-shank impact bits.
- Hex socket size: 6.35 mm + 0.4 mm clearance = 6.75 mm across flats (slightly more clearance than a standard bit holder since impact bit shanks run a hair thicker/rougher).
- Socket depth: 14 mm straight hex grip, plus a 2 mm tapered lead-in.
- Overall footprint: about 42 mm wide × 27.8 mm tall × 19.5 mm thick, including the mounting tab.

## Mounting

1. Remove the factory belt clip screw and clip from the side of the DCF850 handle.
2. Hold the printed part against the same location, screw hole aligned, and thread the stock screw back in through the tab's counterbore.
3. **This is a single-screw mount, just like the stock clip** — there is no keyed anti-rotation feature. Rotate the part to the angle you want (typically hanging bits downward when the tool rests nose-down) before fully tightening the screw.
4. Because tool body curvature varies slightly by unit/revision, test-fit the flat mounting tab against your DCF850 first. If it doesn't sit flush against a curved section of the housing, sand or file the back face of the tab lightly to match.

## Printing

- Print flat with the sockets facing up (this is the default orientation in the STL) — the block base and mounting tab both sit on the build plate.
- No supports are required; the hex sockets print as ordinary vertical holes with a small unsupported taper at the top, and the counterbore bridges a short enough span (8.2 mm) to self-support.
- Print in a tough filament (PETG or nylon) rather than brittle PLA — the mounting tab takes ongoing vibration and cantilever load from the impact driver.

## Tuning the fit

Adjust these parameters in the `.scad` source and re-render if needed:

- `hex_clearance` — extra room added to the 6.35 mm bit shank size. Increase if bits are hard to insert/remove; decrease if they feel loose.
- `socket_depth` — how deep each hex socket is, i.e. how much of the bit shank is gripped.
- `bit_count` — number of bits held in the row.
- `mount_screw_clearance_d` / `mount_head_d` / `mount_head_depth` — adjust if your tool's belt-clip screw is a different size than the stock M4.
- `mount_tab_width` / `mount_tab_length` — resize the mounting tab to better match your tool's handle profile.
