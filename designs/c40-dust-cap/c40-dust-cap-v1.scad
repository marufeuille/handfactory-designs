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

$fn = 128;

outer_d = inner_d + wall * 2;

difference() {
    union() {
        cylinder(h = depth + wall, d = outer_d);
        translate([0, 0, depth + wall]) cylinder(h = knob_h, d = knob_d);
    }
    translate([0, 0, -1]) cylinder(h = depth + 1, d = inner_d);
}
