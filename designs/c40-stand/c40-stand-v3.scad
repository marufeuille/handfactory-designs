// Comandante C40 stand v3 - parametric design for distribution
// One piece: two U-slots (grinder body / grounds jar) plus flat handle
// storage along the back - the lid lies flat in a shallow round recess
// with a hex pocket for its centre shaft, the arm lies in a shallow
// channel along the back, and the knob hangs past the far corner.
// Prints flat, no supports.
// Units: mm. Adjust the parameters below to fit your grinder (C40/C60, individual variance).

part = "base"; // ["base", "both"]

/* [Base] */
base_l = 144;          // base length (X) (trimmed: no margin right of the body seat)
base_d = 138;          // base depth (Y) (deepened for the flat handle zone)
base_h = 15;           // base thickness (v2 was 20; thinned in v3)
base_r = 4;            // base corner radius (vertical edges)
sink = 8;              // how deep body/jar sink from the top
seat_y = 40;           // seat centre Y

/* [Bores - measure your grinder and add clearance] */
body_bore = 64;        // body hole diameter (v2: 63 was a tight fit -> +1)
jar_bore = 62;         // grounds jar hole diameter
jar_cx = 38;           // jar bore centre X
body_cx = 106;         // body bore centre X

/* [Handle storage - flat, along the back] */
lid_cx = 42;           // lid recess centre X (left end of the back zone)
lid_cy = 105;          // lid recess centre Y
lid_recess_d = 61;     // recess diameter (the 58 dia. lid plate lies in it)
lid_recess_depth = 3;  // recess depth (the lid plate is ~3 thick)
hex_af = 12;           // hex pocket across-flats for the lid's centre shaft (MEASURE ME)
hex_depth = 10;        // hex pocket depth
arm_chan_w = 12;       // arm channel width (Y)
arm_chan_depth = 2;    // arm channel depth

$fn = 128;
cy = seat_y;

// centred rounded rectangle (plan view), w along X, d along Y
module rrect(w, d, r) {
    offset(r = r) square([w - 2 * r, d - 2 * r], center = true);
}

// U-shaped slot profile (plan view): a circle plus a channel to the front edge,
// so the body / jar slide in from the front and fines sweep straight out
module u_profile(cx, r) {
    union() {
        translate([cx, cy]) circle(r = r);
        translate([cx - r, 0]) square([2 * r, cy]);
    }
}

module u_slot(cx, bore) {
    // seat down to the shelf only; the shelf is a solid U-shaped floor.
    // No through-hole: the slot opens at the front, so fines sweep out.
    translate([0, 0, base_h - sink]) linear_extrude(sink + 1) u_profile(cx, bore / 2);
}

module base_solid() {
    linear_extrude(base_h)
        hull() for (x = [base_r, base_l - base_r], y = [base_r, base_d - base_r])
            translate([x, y]) circle(r = base_r);
}

// stadium profile along X, centred (for the arm channel)
module capsule_x(l, w) {
    hull() for (sx = [-1, 1]) translate([sx * (l - w) / 2, 0]) circle(r = w / 2);
}

// hexagonal pocket profile, centred (across-flats = af)
module hex_profile(af) {
    polygon([for (i = [0 : 5]) let (a = i * 60 + 30) (af / sqrt(3)) * [cos(a), sin(a)]]);
}

module base() {
    difference() {
        base_solid();
        u_slot(jar_cx, jar_bore);
        u_slot(body_cx, body_bore);
        // lid recess (the lid plate lies flat in it)
        translate([lid_cx, lid_cy, base_h - lid_recess_depth]) linear_extrude(lid_recess_depth + 1) circle(r = lid_recess_d / 2);
        // hex pocket at the recess centre (the lid's centre shaft drops in;
        // the hex also stops the handle rotating in the recess)
        translate([lid_cx, lid_cy, base_h - hex_depth]) linear_extrude(hex_depth + 1) hex_profile(hex_af);
        // arm channel along the back, from the recess to the right edge
        translate([(lid_cx + 30 + base_l) / 2, lid_cy, base_h - arm_chan_depth]) linear_extrude(arm_chan_depth + 1) capsule_x(base_l - lid_cx - 30, arm_chan_w);
    }
}

if (part == "base") base();
if (part == "both") base();
