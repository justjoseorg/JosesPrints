# One-piece Switch 2 dock adapter for the Odin 2 Portal

![One-piece adapter](preview.png)

**ONE printed piece that docks into the Nintendo Switch 2 dock, like a Killswitch-style adapter.** The insertion blade, top stop, over-front cable bridge, TPU-clearance Odin cradle, and both USB-C housing pockets are fused into one solid. There is **no separate stand, removable carrier, screw assembly, or platform underneath the Nintendo dock**.

This replaces the incorrect companion-stand version previously in this folder. Its files remain available only in Git history.

![Placement and cable route](placement.png)

The blue shape is the actual adapter projection. Cyan is an illustrative Odin envelope using official dimensions plus estimated TPU allowance; gray dock walls are illustrative clearance envelopes, **not a complete measured dock model**. Orange shows the extension wire and its accessible slack loop. The cable pockets are part of the print, but the USB connectors and cable are your existing hardware.

## Download and source

- **[adapter.stl](adapter.stl): the only printable part.** Already oriented rear insert face down.
- [odin_portal_dock.scad](odin_portal_dock.scad): editable parametric source of truth.
- [print-orientation.png](print-orientation.png): exported print orientation.
- [verify_model.py](verify_model.py): repeatable generation, connectivity, envelope and collision checks.
- [validation.json](validation.json): actual check results and artifact hashes.
- [reference-measurements.json](reference-measurements.json): datums and hash from the user-supplied `Switch+2+Dock+Adapter+v14.stl`.

## Fit dimensions

The uploaded reference was inspected for mechanical datums; its mesh is not imported or bundled. Its source axes were X=width, Y=insertion height, Z=depth. Measured section at height 15 mm: **200 mm-wide body with a 14.3 mm depth envelope**. Its upper stop begins at **50 mm**, with a **230 mm-wide flange**. The central rounded bore's depth center is **1.8 mm** off the middle plane.

The new, independently constructed insertion blade is **199 × 13.8 mm**, with **50 mm to the stop**, a tapered entry and small bottom support feet at the reference's ±95 mm lateral contact positions. The slight reduction versus the reference envelope is deliberate clearance. This is reference-derived fit geometry, **not a physical fit test or an exact clone**. The uploaded file is nominal v14, not a scan of your manually enlarged printed copy.

AYN's official Odin 2 Portal dimensions are **257 × 98.6 × 17.2 mm**. The cradle has **25.2 mm clear depth**, comprising the 17.2 mm body, an estimated 3 mm TPU allowance per face, and 2 mm extra total fit clearance. The cradle supports the central 160 mm, leaves the end grips unconstrained, and leans back 15°.

Print-oriented model bounds: approximately **230 × 95.1 × 82.7 mm**. Allow additional bed space for supports and brim; do not scale the whole model to fit a smaller bed.

## Adjustable parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `insert_width_clearance` | 1 mm total | Width reduction from reference 200 mm |
| `insert_depth_clearance` | 0.5 mm total | Reduction from reference 14.3 mm envelope |
| `insertion_height` | 50 mm | Blade depth before the top stop |
| `flange_width` | 230 mm | Integral seating stop |
| `tpu_per_face` | 3 mm | Estimated shell thickness allowance, not an AYN published grip dimension |
| `fit_clearance` | 2 mm total | Extra space in the Odin seat |
| `tilt` | 15° | Backward lean |
| `seat_y` | −70 mm | Cradle position in front of the insert; negative Y is forward |
| `seat_height` | 62 mm | Relative to reference insert bottom, not desk height |
| `female_width/depth/height` | 22 × 14 × 30 mm | Oversized dock-side receptacle housing pocket |
| `male_width/depth/height` | 22 × 14 × 29 mm | Oversized Odin-side male plug housing pocket |
| `channel_width` | 10 mm | Open wire trough width |
| `wire_diameter_allowance` | 8 mm | Carved bend allowance |
| `cable_bend_radius` | 20 mm | Turn from insert up and over the dock lip |
| `front_bend_radius` | 12 mm | Front turn down into slack loop |
| `wire_outlet` | 9 mm | Odin-side pocket wire opening |

The pockets deliberately leave room for silicone. Their dimensions are **not claimed measurements of your LEIRUI cable**. Check your cable's actual housing size and bend-radius requirements. Larger bend radii or changed cradle depth must be regenerated and rechecked; several dimensional relationships and structural connections are coupled.

## Hardware and cable installation

Use your working **LEIRUI USB4 male/female extension, ASIN B09L4Q85CH**. You reported both charging and video working with this cable/device/dock combination; that electrical behavior has not been independently tested.

1. Remove the old printed insert from the Nintendo dock. This new one-piece adapter **replaces it**.
2. With power disconnected, load the cable's **female housing into the adapter's lower docking-blade pocket**, so its socket can mate with the dock's upward-facing USB-C plug. Use the front/bottom opening for installation. Adjust its seating height and lateral alignment before fixing it; never force the Nintendo connector.
3. Lay the wire into the front-open vertical groove and the top-open bridge trough. It emerges above the dock lip, crosses forward through the print and drops through the exit notch.
4. Leave a gentle slack loop underneath the Odin cradle. Feed the cable's male housing into the **integrated** cradle pocket; its metal plug points upward at the same 15° tilt as the cradle. Both ends can be loaded through open slots; no plug needs threading through a sealed wire-sized tunnel.
5. Bed the housings with electronics-safe, non-corrosive **neutral-cure silicone**. Keep it out of sockets/contacts and vents. Use a masked alignment jig and allow full cure. Do not cure against unprotected handheld/dock surfaces. Keep excess cable loose and retained away from vents; this adapter does not contain a sealed compartment for all 0.5 m of cable.
6. Lift the complete adapter and dock its blade into the Switch 2 dock until the integral stop seats. The blade/stop, **not the USB plug**, must carry the print's weight.
7. Dock the TPU-covered Odin in the front cradle. Its weight rests on the printed seat/contact pads, **not on its USB-C port**. Do not bend either connector to correct a misalignment.
8. Test gentle insertion/removal, charging/video, ventilation and tip resistance before unattended use. Because the Odin is cantilevered in front, check that the Nintendo dock cannot tip or slide during use. Stop if seating needs force, cable insulation is pinched, the port bears weight, or signal is intermittent.

No mounting screws or other printed components are required. Optional thin felt/silicone contact pads can improve surface protection and take up clearance without changing the one-piece construction.

## Printing

![Back-face-down print orientation](print-orientation.png)

Print `adapter.stl` at **100% scale**, in its exported **rear insert face-down** orientation. Do not print the visual `assembled` orientation unless you deliberately redesign the support strategy.

Suggested starting settings: PETG, 0.2 mm layers, 4–5 walls, 25–35% infill, brim as needed. **Supports are required beneath the raised front cradle, projecting lips and pocket/channel roofs in this orientation.** Inspect your slicer's layer/support preview, keep supports removable, and clean the female socket pocket, male pocket, cable channel and outlet completely. Deburr square edges and add protective pads where needed. Printer settings and mechanical strength are not physically tested.

## Regenerate and verify

Basic exports:

```sh
openscad --render -D 'part="adapter"' -o adapter.stl odin_portal_dock.scad
openscad --render --autocenter --viewall --projection=ortho --imgsize=1400,1000 --colorscheme=Tomorrow -D 'part="assembled"' -o preview.png odin_portal_dock.scad
```

Complete repeatable checks (requires OpenSCAD and a working graphics display, which may be virtual):

```sh
uv run --python 3.11 --with trimesh --with scipy --with networkx --with matplotlib --no-project python verify_model.py
```

Set `OPENSCAD_BIN` if OpenSCAD is not on PATH. PNG rendering needs `DISPLAY`/OpenGL on Linux. The generator does not import the private reference mesh.

Selectors: `adapter` for printing, `assembled`, `placement`, `cable_check`, `dock_clearance_check`, and `device_clearance_check`. This design has only one printed part, so there is no multi-part layout to assemble.

Verified from actual exports: **one connected solid**, watertight, positive-volume STL; insertion envelope checked at four heights; a **6 mm test cable has no positive-volume intersection along the complete modeled route**, including the loose return loop and male pocket entry; no intersection with the explicitly illustrative dock walls or the Odin-plus-TPU envelope. The device check excludes only 0.02 mm at the intentional seat-contact plane to avoid degenerate coplanar faces. Empty OpenSCAD intersection exports return code 1 with `Current top level object is empty.`—the verifier treats that as the expected check result, not a successful physical fit test. The previews were generated and inspected in a headless virtual display; no interactive review on the user's screen occurred.

**Not verified:** actual dock fit, measured TPU fit, housing engagement, printer-specific support removal, electrical behavior, temperatures, and stability. `physical_fit_verified` remains false.

## References

- [AYN Odin 2 Portal](https://www.ayntec.com/products/odin2-portal), [official specification image](https://www.ayntec.com/cdn/shop/files/odin2-portal_7_a9a0c473-3e93-4c62-885f-e1e904205da8.jpg?v=1737092883).
- [Dock extension adapter by adimaniac](https://makerworld.com/en/models/1583137-nintendo-switch-2-dock-usb-c-extension-adapter): the user supplied its nominal v14 STL for measurement. The original is not imported, copied, modified or redistributed here. This is independently constructed geometry using fit datums, not a literal merge.
- [TPU-friendly Odin stand by Martin Mesa](https://www.printables.com/model/1417821-odin-2-portal-stand): visual/layout reference; original mesh not imported or included.

Not an official Nintendo, AYN or dbrand product.
