// Comandante C40 cap + crank hanger (v1)
// One cap, two jobs: it covers the body's top opening against dust
// (same cup as the dust cap v1), and the detached crank HANGS from
// it: an ear on the cap's rim carries a vertical slot, the crank's
// lid disc (58 dia. x ~3 thick) drops edge-on into the slot, and the
// arm + knob hang down alongside the body - the way the JHAT stand
// and the wavexx / Lastaforest top caps park the crank. No stand
// footprint is spent on the crank at all.
// Units: mm. Prints mouth-down, support-free (the ear's slot is open
// at the top and prints as a bridge-free channel in this orientation:
// rotate so the slot faces up if your slicer prefers).
// inner_d is carried over from the dust cap v1 fit test (MEASURE).

part = "cap"; // ["cap", "both"]

/* [Cap] */
inner_d = 63.5;        // inner diameter (body outer + clearance) (MEASURE)
depth = 22;            // inner depth (how far the cap drops over the body)
wall = 2.4;            // side wall and top thickness

/* [Hanger ear - at the back of the cap] */
ear_w = 34;            // ear width (X, tangential)
ear_out = 12;          // ear reach beyond the cap's outer wall (Y)
ear_top = 0;           // ear top relative to the cap top (0 = flush)
slot_w = 4.5;          // slot width (Y): lid disc ~3 + clearance
slot_depth = 18;       // slot depth from the ear top
slot_cy = 38;          // slot centre distance from the axis (Y)

$fn = 96;

outer_d = inner_d + wall * 2;
outer_r = outer_d / 2;
cap_h = depth + wall;

module cap() {
    difference() {
        union() {
            cylinder(h = cap_h, d = outer_d);
            // ear block at the back, embedded into the cap wall
            translate([0, slot_cy, cap_h + ear_top - (slot_depth + 6) / 2])
                cube([ear_w, outer_r + ear_out - slot_cy + slot_w, slot_depth + 6], center = true);
        }
        // body cavity
        translate([0, 0, -1]) cylinder(h = depth + 1, d = inner_d);
        // hanger slot across the ear (open at the top and both ends)
        translate([0, slot_cy, cap_h + ear_top - slot_depth / 2 + 1])
            cube([ear_w + 2, slot_w, slot_depth + 2], center = true);
    }
}

if (part == "cap") cap();
if (part == "both") cap();
