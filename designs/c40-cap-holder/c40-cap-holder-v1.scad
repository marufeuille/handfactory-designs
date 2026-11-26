// Comandante C40 cap + crank park (v1)
// One cap, two jobs: it covers the body's top opening against dust
// (same cup as the dust cap v1), and a small hex peg pressed into its
// top takes the detached crank: the hex socket in the end of the
// crank's shaft drops over the peg, the shaft end rests on the cap
// top, and the arm + knob hang alongside the body. No stand footprint
// is spent on the crank at all.
// Units: mm. The cap prints mouth-down, support-free; the peg prints
// standing on one end.
// Sizes marked (MEASURE) are placeholders: inner_d is carried over
// from the dust cap v1 fit test, and the hex sizes come from the
// umbrella cap's body-screw figures (nominal 5.5 across-flats).

part = "cap"; // ["cap", "peg", "both"]

/* [Cap] */
inner_d = 63.5;        // inner diameter (body outer + clearance) (MEASURE)
depth = 22;            // inner depth (how far the cap drops over the body)
wall = 2.4;            // side wall thickness
roof = 6;              // top thickness (holds the peg socket)
socket_af = 5.9;       // peg socket across-flats in the cap top (MEASURE)
socket_depth = 5;      // peg socket depth (blind: dust seal stays intact)

/* [Peg] */
peg_af = 5.5;          // hex peg across-flats (the crank's hex socket) (MEASURE)
peg_h = 7;             // peg height above the cap top
peg_stem = 5;          // peg length inside the socket

$fn = 96;

outer_d = inner_d + wall * 2;
cap_h = depth + roof;

// hexagon profile, centred (across-flats = af)
module hex_profile(af) {
    polygon([for (i = [0 : 5]) let (a = i * 60 + 30) (af / sqrt(3)) * [cos(a), sin(a)]]);
}

module cap() {
    difference() {
        cylinder(h = cap_h, d = outer_d);
        // body cavity
        translate([0, 0, -1]) cylinder(h = depth + 1, d = inner_d);
        // blind hex socket for the peg
        translate([0, 0, cap_h - socket_depth]) linear_extrude(socket_depth + 1) hex_profile(socket_af);
    }
}

module peg() {
    translate([0, 0, -peg_stem]) linear_extrude(peg_stem + peg_h) hex_profile(peg_af);
}

if (part == "cap") cap();
if (part == "peg") peg();
if (part == "both") { cap(); translate([outer_d / 2 + 12, 0, peg_stem]) peg(); }
