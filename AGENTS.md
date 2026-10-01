# Repository guidance

This repository contains printable models authored in OpenSCAD or Blender, together with their generated print artifacts. Use whichever tool best suits the model; do not convert an existing model solely to change authoring tools.

## Structure

Keep every print self-contained in a kebab-case folder at the repository root:

```text
print-name/
  README.md
  preview.png
  model_name.scad     # OpenSCAD source, or:
  model_name.blend    # Editable Blender source
  build_model.py     # Include when Blender generation is scripted
  printable-part.stl
```

Each folder README must:

- Display `preview.png` near the top using a relative Markdown image.
- Describe the model, included files, dimensions, hardware, and assembly.
- State the correct print orientation and support requirements.
- Document important adjustable parameters and the authoring tool.
- Include reproducible generation/export commands when practical.

Update the root `README.md` whenever a print is added, renamed, or removed.

## Source models

- Treat the documented `.scad` or `.blend` file as the source of truth. Do not maintain divergent versions in both tools.
- Keep dimensions and fit tolerances as named parameters in OpenSCAD, or clearly documented custom properties/generator settings in Blender.
- For OpenSCAD, preserve a `part` selector for individual printable pieces, `assembled`, and, for multi-part models, `layout`.
- For Blender, use named objects/collections for individual printable pieces, an assembled view, and a print layout. Keep each printable object's export selection unambiguous.
- Set and document real-world units. STL has no unit metadata: export coordinates in millimeters and verify the resulting dimensions in a mesh checker or slicer. For Blender, do not assume scene unit settings alone fix STL scale.
- Design parts in their intended print orientation where practical.
- Consider FDM layer direction when designing clips, hinges, and snap fits.
- Do not expose additional Raspberry Pi ports unless the model requirements change.

## Generated artifacts

Commit the current STL files and rendered preview for every model. Do not edit generated files manually.

After changing a source, regenerate every affected STL and its preview with its authoring tool.

OpenSCAD examples:

```powershell
openscad --render -D 'part="body"' -o body.stl car_coin_holder.scad
openscad --render -D 'part="lid"' -o lid.stl car_coin_holder.scad
openscad --render --autocenter --viewall --projection=ortho --imgsize=1200,800 -D 'part="assembled"' -o preview.png car_coin_holder.scad
```

The Raspberry Pi case uses `base`, `lid`, and `assembled` as its part values.

For Blender, preserve an export/render script when practical and document its actual invocation. Save the editable `.blend`, export the named printable parts to STL with correct millimeter scale, and render `preview.png` from the current scene. Exclude cameras, lights, illustrative device envelopes, and non-printing reference objects from STL exports. Honor a requested GPU when rendering and report the actual device used rather than only a configured setting.

## Validation

Before committing a model change:

1. Generate every printable STL without tool errors or failed assertions. Check that each intended part is a watertight, positive-volume mesh with the expected connected components.
2. Render the assembled PNG and inspect it for missing, intersecting, or separated pieces.
3. Confirm every expected artifact is non-empty, stored beside its source, and dimensionally correct in millimeters.
4. Always check for collisions: in the assembled render and any relevant moving-part check (e.g. `hinge_clearance_check`), verify no two parts intersect where they should not. Check mating/moving parts (screws, hinges, plugs, gaskets) geometrically for real, intentional clearance; do not rely on visual inspection alone. Document numerical tolerances used by mesh checks.
5. When two or more printed parts are structurally attached (e.g. multi-material pieces, snap-fits, anchors, hinges sharing a pin), verify the attachment feature is present, correctly sized, and connects the parts as intended.
6. Update dimensions, assumptions, and printing notes in the folder README. Distinguish CAD checks from physical print/fit tests.
7. Ensure all relative README links and preview images resolve on GitHub.

When a GUI/display is available, open the current source in its authoring application for inspection: OpenSCAD with `part="layout"` or `part="assembled"`, or Blender with its assembled/print-layout view visible. If no interactive display is available, inspect generated previews and clearly state that an interactive GUI review was not possible; do not let a headless environment prevent artifact generation and validation.

Keep unrelated model folders unchanged.
