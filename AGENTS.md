# Repository guidance

This repository contains parametric OpenSCAD models and their generated print artifacts.

## Structure

Keep every print self-contained in a kebab-case folder at the repository root:

```text
print-name/
  README.md
  preview.png
  model_name.scad
  printable-part.stl
```

Each folder README must:

- Display `preview.png` near the top using a relative Markdown image.
- Describe the model, included files, dimensions, hardware, and assembly.
- State the correct print orientation and support requirements.
- Document important adjustable parameters.

Update the root `README.md` whenever a print is added, renamed, or removed.

## OpenSCAD sources

- Treat `.scad` files as the source of truth.
- Keep dimensions and fit tolerances as named parameters near the top.
- Preserve a `part` selector so individual pieces and an assembled preview can be rendered.
- Design parts in their intended print orientation where practical.
- Consider FDM layer direction when designing clips, hinges, and snap fits.
- Do not expose additional Raspberry Pi ports unless the model requirements change.

## Generated artifacts

Commit the current STL files and rendered preview for every model. Do not edit generated files manually.

After changing a source file, regenerate every affected STL and its preview with OpenSCAD. Examples:

```powershell
openscad --render -D 'part="body"' -o body.stl car_coin_holder.scad
openscad --render -D 'part="lid"' -o lid.stl car_coin_holder.scad
openscad --render --autocenter --viewall --projection=ortho --imgsize=1200,800 -D 'part="assembled"' -o preview.png car_coin_holder.scad
```

The Raspberry Pi case uses `base`, `lid`, and `assembled` as its part values.

## Validation

Before committing a model change:

1. Render every printable part to STL without OpenSCAD errors or assertions.
2. Render the assembled PNG and inspect it for missing, intersecting, or separated pieces.
3. Confirm each expected artifact is non-empty and stored beside its source.
4. Always check for collisions: in the assembled render (and any relevant moving-part check, e.g. `hinge_clearance_check`), verify no two parts intersect where they should not, and that mating/moving parts (screws, hinges, plugs, gaskets) have real, intentional clearance instead of relying on visual inspection alone.
5. When a design expects two or more printed parts to be structurally attached to each other (e.g. co-printed multi-material pieces, snap-fits, integrated anchors, or hinge barrels sharing a pin), confirm in the assembled render and part geometry that the attachment feature is actually present, correctly sized, and connects the parts as intended before committing.
6. Update dimensions and printing notes in the folder README.
7. Ensure all relative README links and preview images resolve on GitHub.

Keep unrelated model folders unchanged.
