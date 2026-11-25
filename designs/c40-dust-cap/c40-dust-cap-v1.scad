// Comandante C40 body dust cap (v1)
// Storage cap: swaps with the stock lid and covers the body's top opening
// so dust stays out of the grinding chamber while the grinder is stored.
// The grounds jar needs no cap — it is stored upside down.
// Units: mm. Printed open-side down (top disc on the bed), no supports.
// Tune inner_d after measuring the body (nominal ~61, prints suggested 62-63).

inner_d = 63.5;   // inner diameter (body outer + clearance)
depth = 22;       // inner depth (how far the cap drops over the body)
wall = 2.4;       // wall and top thickness
knob_d = 18;      // top knob diameter
knob_h = 8;       // top knob height
tab_w = 18;       // hanging tab width
tab_t = 3;        // hanging tab thickness
tab_h = 16;       // hanging tab height above the top face
tab_hole = 6;     // hanging hole diameter
tab_r = 22;       // tab centre distance from the cap centre

$fn = 128;

outer_d = inner_d + wall * 2;
top_z = depth + wall;

difference() {
    union() {
        cylinder(h = top_z, d = outer_d);
        translate([0, 0, top_z]) cylinder(h = knob_h, d = knob_d);
        // hanging tab: stands on the top face near the rim,
        // hangs on the stand's arm while the grinder is in use
        translate([-tab_w / 2, tab_r - tab_t / 2, top_z - 2])
            cube([tab_w, tab_t, tab_h + 2]);
    }
    translate([0, 0, -1]) cylinder(h = depth + 1, d = inner_d);
    // hanging hole through the tab
    translate([0, tab_r, top_z + tab_h - 6])
        rotate([90, 0, 0]) cylinder(h = tab_t + 2, d = tab_hole, center = true);
}
