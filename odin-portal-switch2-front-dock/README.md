# Two-piece Switch 2 dock insert + adjustable cable winder + Odin cradle

![Two independent parts](preview.png)

**Two printed pieces, connected only by your existing USB-C extension cable:**

1. **Dock insert with a built-in cable winder.** It holds the cable's female USB-C end facing downward to connect to Nintendo's upward-facing plug. Wind surplus cable around the two rounded cores under their keeper lips.
2. **Independent Odin 2 Portal cradle.** It supports the TPU-covered Odin on its own tabletop base and holds the cable's male end in its integral pocket.

**No rigid arm, bridge between the parts, screws, third carrier, or matched Z height.** Put the cradle where you want, within cable reach, and wind/unwind the spare length. Nintendo's overall dock height is used only for an example preview—not to set the cradle's printable geometry.

![Example placement](placement.png)

The illustrated placement is not mandatory. Dock/device envelopes and cable hardware silhouettes are approximate; real fit and electrical engagement remain to be tested.

## Print these two files

| File | Purpose | Exported print dimensions |
| --- | --- | --- |
| **[adapter.stl](adapter.stl)** | Dock insert + integral two-post winder | Approx. **230 × 81 × 42.9 mm** |
| **[cradle.stl](cradle.stl)** | Standalone TPU-friendly Odin cradle, including male connector pocket | Approx. **180 × 56.5 × 83.3 mm** |

- [odin_portal_dock.scad](odin_portal_dock.scad): source of truth; `part="layout"` by default.
- [print-orientation.png](print-orientation.png): both pieces in their individual print orientations.
- [cable-winder.png](cable-winder.png): winding method and actual keeper-lip clearance section.
- [dock-interface.png](dock-interface.png): female-end mounting and mating direction.
- [verify_model.py](verify_model.py): repeatable export and validation.
- [validation.json](validation.json): real check results and artifact hashes.
- [reference-measurements.json](reference-measurements.json): measured datums from your uploaded reference.

## Adjustable cable storage

![Built-in cable winder](cable-winder.png)

Wrap excess wire around **both cores**, making an oval/racetrack loop. Slide the wire under the retaining flanges; the winder is part of the insert, not another print. There is a **14 mm winding gap**, **12 mm-radius cores** and **20 mm-radius keeper lips**. The winder is near the right-side exit to avoid an unnecessary cable detour.

First position the cradle and leave relaxed leads at both connectors. Wind **only the remaining slack**, and unwind if you move the cradle farther away. Do not tension the wire against either USB-C port or force a tighter bend than the cable permits.

One illustrated complete loop of a 6 mm cable stores approximately **179.5 mm** of length. Two sample loops were checked for geometric space, **not to claim your extension has enough spare length for two full wraps**. A partial wrap may be all that is available once both ends are connected.

The small winder platform carries cable only; it does not support or fix the height of the separate cradle.

## Dock-side electrical connection

![USB-C mating direction](dock-interface.png)

```text
Nintendo dock's upward MALE USB-C plug
                 ↑
Extension's downward FEMALE socket, fixed inside Part A
                 → surplus wire on built-in winder
                 → adjustable free cable length
Extension's upward MALE plug, fixed inside Part B
                 → Odin 2 Portal
```

Fit the female receiving face at the supplied reference's datum (`female_socket_face_z=0`, X=0, Y=−1.8 mm), facing down. The insert has a housing shoulder and four silicone-key holes for retention. Set and test actual engagement before curing neutral-cure, electronics-safe silicone; trim cured material flush with insert faces and keep it out of the socket. Once retained, inserting Part A is intended to connect to the dock automatically. This has **not** been physically/electrically verified with a printed part.

Your working LEIRUI extension is **ASIN B09L4Q85CH**. You reported charging and video working with this cable/device/dock combination; that does not verify the printed housing fit. The **22 × 14 × 30 mm female pocket** and **22 × 14 × 29 mm male pocket** deliberately leave silicone-adjustment space; they are not measured LEIRUI housing dimensions.

## Device and insert fit

The user-supplied `Switch+2+Dock+Adapter+v14.stl` provided the 200 mm insertion-body width, 14.3 mm depth envelope, 50 mm stop datum, 230 mm flange, ±95 mm lower contacts and right-side exit at reference height 55 mm. This original parametric insert uses **199 × 13.8 mm** for clearance. The reference mesh is not imported, modified or redistributed.

AYN's official Odin dimensions are **257 × 98.6 × 17.2 mm**. The cradle has **25.2 mm clear depth**, including estimated 3 mm TPU per face and 2 mm total additional clearance. It supports the center 160 mm, leaves the grip ends free, leans back **15°**, and has a seating datum **55 mm above its own base** to make room for the straight male plug and wire bend.

There is **no need to measure the adapter-to-cradle Z distance**. Both printable parts were regenerated with two different dock preview heights and their geometry stayed identical. The cradle supports itself on its own flat base; use your actual cable reach to determine its location.

## Parameters

| Parameter | Default | Purpose |
| --- | --- | --- |
| `insert_width/depth_clearance` | 1 / 0.5 mm total | Reduction from reference body envelope |
| `insertion_height` | 50 mm | Insert to stop depth |
| `female_socket_face_z` | 0 mm | Receiving-face datum; alter only for verified actual engagement |
| `female_width/depth/height` | 22 × 14 × 30 mm | Female housing pocket |
| `male_width/depth/height` | 22 × 14 × 29 mm | Cradle's integral male housing pocket |
| `winder_core_radius` | 12 mm | Gentle winding cores |
| `winder_spacing` | 42 mm | Two post centers; keeper lips must not be tangent |
| `winder_flange_radius` | 20 mm | Keeper lips |
| `winder_gap` | 14 mm | Axial winding room |
| `winder_x` | 68 mm | Winder position near side exit |
| `tpu_per_face`, `fit_clearance` | 3 / 2 mm | Assumed TPU allowance and extra seat clearance |
| `tilt` | 15° | Backward lean |
| `seat_above_table` | 55 mm | Height above cradle's own base |
| `preview_cradle_offset_y` | −25 mm | Example position only; no mechanical constraint |

Change named parameters and regenerate; do not scale entire STLs to fit a smaller bed, because that changes connector clearances.

## Installation

1. Remove the old printed adapter and install the extension's female end in Part A, facing downward. Carefully test full engagement without force before fixing it with silicone using a protected alignment jig. Do not let the connector carry the insert's weight.
2. Lay the wire into the open insert channel toward the right-side exit. The plugs do not need threading through a sealed wire-sized tunnel.
3. Fit and retain the male end in Part B's pocket at the cradle angle. Keep contacts/ports free of silicone and let it cure fully.
4. Put the standalone cradle on a stable surface and choose its location. Wind only excess wire around the insert's cores, leaving both connector leads unstressed.
5. Dock Part A into Nintendo's dock and place the TPU-covered Odin into Part B. Test gentle docking cycles, charging/video, connector load, ventilation, slipping and tipping before unattended use.

## Printing

![Two-part print layout](print-orientation.png)

Print both at **100% scale**:
- **Adapter:** rear insert face down, as exported. Supports are needed for winder-platform/keeper overhangs and pocket/channel regions. Inspect supports for accessibility and remove all debris from the socket mount and winding space.
- **Cradle:** broad base down, as exported. Elevated seat/pocket overhangs may need supports. Inspect the triangular openings and cable loading slot in layer preview; do not assume every bridge is support-free.

Suggested starting settings: PETG, 0.2 mm layers, 4–5 walls, 20–30% infill, brim where needed. These settings and mechanical strength are not physically tested. Layout is a visualization; check actual support/brim clearances before arranging both on one build plate.

## Regenerate and checks

```sh
openscad --render -D 'part="adapter"' -o adapter.stl odin_portal_dock.scad
openscad --render -D 'part="cradle"' -o cradle.stl odin_portal_dock.scad
uv run --python 3.11 --with trimesh --with scipy --with networkx --with matplotlib --no-project python verify_model.py
```

Set `OPENSCAD_BIN` if needed. PNG rendering requires DISPLAY/OpenGL, which may be virtual. Source views include `adapter`, `cradle`, `assembled` (example use), and `layout` (independent print orientations), plus the named clearance-check selectors.

Actual validation: **two printable files, each one connected watertight positive-volume solid**; insert envelope verified at four heights; dock plug entry, adapter routing, two sample coil loops, cradle/device, cradle wire/table, and example part placement checked for collisions. Both native prints were regenerated with preview seating-height parameters **115 and 125 mm**, with **0 mm vertex deviation**—no matched-height dependency. The original uploaded STL remains untouched.

**Still unverified:** physical dock/case/connector fit, automatic electrical engagement, actual bend-radius suitability, loaded cradle stability, print settings, support removal and thermal behavior. Schematic hardware drawings are not measured cable housings.

## References

- [Nintendo dock specifications](https://www.nintendo.com/sg/hardware/switch2/specs/index.html): 115 × 201 × 51.2 mm including feet, used for preview only.
- [AYN Odin 2 Portal](https://www.ayntec.com/products/odin2-portal), [official size image](https://www.ayntec.com/cdn/shop/files/odin2-portal_7_a9a0c473-3e93-4c62-885f-e1e904205da8.jpg?v=1737092883).
- [Dock adapter by adimaniac](https://makerworld.com/en/models/1583137-nintendo-switch-2-dock-usb-c-extension-adapter): supplied nominal v14 examined for fit datums only; original mesh not bundled.
- [Odin stand by Martin Mesa](https://www.printables.com/model/1417821-odin-2-portal-stand): visual reference, mesh not included.

Original OpenSCAD construction; not an official Nintendo, AYN or dbrand product.
