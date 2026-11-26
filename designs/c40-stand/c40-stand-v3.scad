// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with arch slots), "pole" (5x5 arch, print it lying flat), "both" (preview)
// Units: mm. Adjust the parameters below to fit your grinder (C40/C60, individual variance).

part = "both"; // ["base", "pole", "both"]

/* [Base] */
base_l = 144;          // base length (X) (trimmed: no margin right of the body seat)
base_d = 80;           // base depth (Y)
base_h = 15;           // base thickness (v2 was 20; thinned in v3)
base_r = 4;            // base corner radius (vertical edges)
sink = 8;              // how deep body/jar sink from the top

/* [Bores - measure your grinder and add clearance] */
body_bore = 64;        // body hole diameter (v2: 63 was a tight fit -> +1)
jar_bore = 62;         // grounds jar hole diameter
jar_cx = 38;           // jar bore centre X
body_cx = 106;         // body bore centre X

/* [Arch - 5x5 bar, legs at both back corners] */
post_t = 5;            // bar cross-section: 5x5
arch_cy = 66;          // arch plane Y (back row)
leg_half = 62;         // legs at base centre X +/- this (10 and 134)
spring_z = 150;        // where the arc springs from the legs
peak_z = 174;          // arch midline peak height (outer peak = this + 2.5)
leg_top = 150;         // leg height (ends at the springing, inside the arc band)
sock_depth = 12;       // slot socket depth (base_h - 3 floor)

$fn = 128;
cy = base_d / 2;

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

module base() {
    difference() {
        base_solid();
        u_slot(jar_cx, jar_bore);
        u_slot(body_cx, body_bore);
        // arch leg slots (tapered in X: bar size at the floor, widening upward)
        for (sx = [base_l / 2 - leg_half, base_l / 2 + leg_half])
            hull() {
                translate([sx, arch_cy, base_h - sock_depth]) linear_extrude(0.1) rrect(post_t, post_t + 0.6, 1.5);
                translate([sx, arch_cy, base_h + 0.9]) linear_extrude(0.1) rrect(post_t + 1.7, post_t + 0.6, 1.5);
            }
    }
}

// the arch is a planar profile (in the XZ plane) extruded 5 thick in Y:
// two legs with tapered tenons and a shallow arc band on top; the handle
// bar rests front-to-back in the shallow dip at the peak, lid toward the
// back, knob toward the front
module arch_profile() {
    cx0 = base_l / 2;
    arc_cz = (peak_z * peak_z - spring_z * spring_z - leg_half * leg_half) / (2 * (peak_z - spring_z));
    r_mid = peak_z - arc_cz;
    difference() {
        union() {
            for (s = [-1, 1]) {
                // tenon (tapered in X: wedges into the slot)
                polygon([[cx0 + s * leg_half - 2.5, 3.5], [cx0 + s * leg_half + 2.5, 3.5],
                         [cx0 + s * leg_half + 3.05, base_h], [cx0 + s * leg_half - 3.05, base_h]]);
                // leg (5 wide)
                translate([cx0 + s * leg_half, (base_h + leg_top) / 2]) square([post_t, leg_top - base_h], center = true);
            }
            // arc band (5 thick, radially)
            intersection() {
                difference() {
                    translate([cx0, arc_cz]) circle(r = r_mid + 2.5);
                    translate([cx0, arc_cz]) circle(r = r_mid - 2.5);
                }
                translate([cx0, 172]) square([2 * leg_half + post_t, 56], center = true);
            }
        }
        // shallow dip at the peak for the handle bar
        translate([cx0, peak_z + 19.5]) circle(r = 20);
    }
}

module pole() {
    translate([0, arch_cy + post_t / 2, 0])
        rotate([90, 0, 0]) linear_extrude(post_t) arch_profile();
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
