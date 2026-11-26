// Comandante C40 stand v3 - parametric design for distribution
// One piece: two U-slots (grinder body / grounds jar) plus handle storage
// along the back strip - the lid drops edge-on into a slot and leans back
// against a low half-round rest; the arm lies along the back and the knob
// rests near the far corner. Prints flat, no supports.
// Units: mm. Adjust the parameters below to fit your grinder (C40/C60, individual variance).

part = "base"; // ["base", "both"]

/* [Base] */
base_l = 144;          // base length (X) (trimmed: no margin right of the body seat)
base_d = 105;          // base depth (Y) (deepened for the back strip)
base_h = 15;           // base thickness (v2 was 20; thinned in v3)
base_r = 4;            // base corner radius (vertical edges)
sink = 8;              // how deep body/jar sink from the top
seat_y = 40;           // seat centre Y

/* [Bores - measure your grinder and add clearance] */
body_bore = 64;        // body hole diameter (v2: 63 was a tight fit -> +1)
jar_bore = 62;         // grounds jar hole diameter
jar_cx = 38;           // jar bore centre X
body_cx = 106;         // body bore centre X

/* [Handle storage - along the back strip] */
lid_cx = 33;           // lid slot centre X (left end of the back strip)
lid_cy = 90;           // lid slot centre Y
lid_slot_l = 58;       // slot length (X): the 58 dia. lid drops in edge-on
lid_slot_w = 14;       // slot width (Y): lid thickness + clearance
lid_slot_floor = 5;    // slot floor height (10 deep)
rest_h = 22;           // lean-rest wall height above the base top
rest_r = 20;           // lean-rest plan radius (half-round bump behind the slot)

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

// lean-rest wall: a half-round bump behind the lid slot (clipped by the
// base outline); the lid leans back against its flat front face
module rest_wall() {
    translate([0, 0, base_h]) linear_extrude(rest_h)
        intersection() {
            translate([base_l / 2, base_d / 2]) rrect(base_l, base_d, base_r);
            translate([lid_cx, lid_cy + lid_slot_w / 2])
                intersection() {
                    circle(r = rest_r);
                    translate([0, rest_r / 2]) square([2 * rest_r, rest_r], center = true);
                }
        }
}

module base() {
    union() {
        difference() {
            base_solid();
            u_slot(jar_cx, jar_bore);
            u_slot(body_cx, body_bore);
            // lid slot along X in the back strip
            translate([lid_cx, lid_cy, lid_slot_floor]) linear_extrude(base_h - lid_slot_floor + 1) rrect(lid_slot_l, lid_slot_w, 7);
        }
        rest_wall();
    }
}

if (part == "base") base();
if (part == "both") base();
