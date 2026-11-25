# SETUP.md — Add a design to a running registry

Use this procedure when a design registry is **already set up**
(see [DEPLOY.md](DEPLOY.md)) and you want to register one more design so
it appears in the viewer.

**This procedure does not touch the infrastructure.** No hosting changes,
no viewer changes. The only change is one folder of STL files and one
entry in `designs.json`, committed and pushed.

## What you need before starting

- The design's STL file(s): one per part you want to switch between in
  the viewer (a single combined file is fine on its own).
- Units in **millimetres**, **Z-up**, parts in their assembled positions
  if they belong together. Binary STL is recommended (smaller); ASCII
  also works.
- The design's key dimensions, if you want annotations: bore diameters,
  outer size, heights — measured or taken from the source model.

## 1. Add the files

Create `designs/<id>/` (a short kebab-case id) and copy the STL file(s)
in. Keep the source next to them when there is one (e.g. the `.scad`
file), under its original name.

## 2. Add the manifest entry

Append one object to `designs` in `designs.json`:

```json
{
  "id": "c40-stand",
  "name": "Human-readable name shown in the viewer",
  "dir": "designs/c40-stand",
  "source": "c40-stand-v3.scad",
  "parts": [
    { "id": "all",  "label": "全体",     "file": "stand-v3-both.stl" },
    { "id": "base", "label": "台座のみ", "file": "stand-v3-base.stl" }
  ],
  "dims": { "all": { "lines": [], "leaders": [] } }
}
```

Fields:

- `id`: unique, kebab-case. `name`: display name. `dir`: the folder.
- `source`: optional; the design source file in the same folder.
- `parts`: at least one. `id` is referenced by `dims`; `label` is the
  button text; `file` is the STL name inside `dir`.
- `dims`: optional annotations per part id (see below). Omit it and the
  design simply shows without dimension lines.

## 3. Dimension annotations (`dims`)

Coordinates are model coordinates in mm, in the same space as the STL.

- `lines`: `[start, end, screenOffset, label]` — a dimension line drawn
  between the two 3D points, shifted by `screenOffset` (`[dx, dy]` in
  screen pixels), with `label` (e.g. `"165"`) at its midpoint.
  Example: `[[0,0,0],[165,0,0],[0,26],"165"]` measures the front bottom
  edge, drawn 26 px below it.
- `leaders`: `[point, dx, dy, label]` — a dot at the 3D `point`, a leader
  line to a label offset by (`dx`, `dy`) screen pixels.
  Example: `[[138,40,15],-46,-30,"Ø64"]` labels a Ø64 bore from a point
  on its rim.

## 4. Commit, push, verify

One commit per design (STL files + manifest entry together), then push.
Open the viewer: the new design appears in the dropdown, its parts
switch, and its dimension labels show. If it does not appear, check that
`designs.json` is still valid JSON and that the pushed manifest is the
one being served (raw/CDN caches can lag a few minutes).
