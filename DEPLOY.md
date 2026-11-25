# DEPLOY.md — Set up your own design registry and viewer

This guide is written for an **AI agent** setting up a personal registry of
3D-printing designs with a browser viewer, on the owner's GitHub account.
Each step states what to do and what result to expect. Ask the owner before
anything that is not covered here.

**Scope:** this document covers the one-time setup (repository + static
hosting). Adding a design to an already-running registry is a separate,
smaller procedure: see [SETUP.md](SETUP.md).

There is **no backend and no authentication**. The registry is a Git
repository; the viewer is one static HTML file that reads `designs.json`
and STL files over HTTP. Anyone who can read the repository can view the
designs, so use a public repository only for designs you may share, or a
private one together with a hosting setup that can read it.

## 0. Prerequisites

- A GitHub account (the free tier is enough), or any static web host.
- `git`, and a way to produce STL files (OpenSCAD, a CAD app, a slicer).

## 1. Create the repository

Create a repository (public if the designs may be shared) and place these
files, copied from this repository:

```
designs.json          the manifest (the single source of truth)
designs/<id>/*.stl    one folder per design
viewer/index.html     the standalone viewer
README.md
```

Commit and push. Verify the manifest is reachable over HTTP, e.g.
`https://raw.githubusercontent.com/<owner>/<repo>/main/designs.json`
returns the JSON with HTTP 200.

## 2. Serve the viewer

The viewer fetches `../designs.json` and the STL files by relative path,
so the repository root must be served as static files. Options:

- **GitHub Pages**: repository Settings → Pages → deploy from branch
  `main`, folder `/ (root)`. The viewer is then at
  `https://<owner>.github.io/<repo>/viewer/`.
- **Any static host / local server**: serve the repository root, e.g.
  `python3 -m http.server` inside the clone, and open `/viewer/`.

Note: opening `viewer/index.html` as a `file://` URL does not work,
because browsers block the manifest/STL fetches. Always go through HTTP.

Verify: the design dropdown lists the designs from `designs.json`,
selecting one renders the model, the part buttons switch parts, and the
dimension annotations follow the model when it is rotated.

## 3. (Optional) A hosted viewer in Muse

If the owner uses Muse, a Space (web artifact) can host the same viewer.
The Space viewer is **local-first**: the designs (manifest + STL files)
are bundled into the Space and displayed from the bundle, because
fetching the repository at open time proved unreliable (CDN and WebView
caches serve stale copies). A background sync checks the repository and
picks up differences, but the display never depends on it.

Operational rule: whenever a design is added or changed in this
repository, the Space's bundle must be re-synced (rebuilt) in the same
operation, so the bundled snapshot does not drift from the repository.
The repository stays the source of truth either way.

## 4. Ongoing operation

- Adding designs: see [SETUP.md](SETUP.md). No viewer changes are needed.
- The manifest is the contract: keep `designs.json` valid JSON, one entry
  per design, and commit STL + manifest changes together.
