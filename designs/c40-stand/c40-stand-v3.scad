// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with post slot), "pole" (5x5 bar post with a Y-fork top, print it lying flat), "both" (preview)
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

/* [Post - 5x5 bar, back-centre between the two seats] */
post_t = 5;            // bar cross-section: 5x5 (stem width in X, thickness in Y)
post_cx = 71.5;        // post centre X (also the centre of the trimmed base)
post_cy = 62;          // post centre Y
stem_top = 152;        // where the stem ends and the fork takes over
prong_base_dx = 3;     // prong centre offset from the post centre at the root
prong_base_z = 148;    // prong root height (embedded in the stem)
prong_tip_dx = 21;     // prong centre offset at the tip (the fork opens in X)
prong_tip_z = 171;     // prong tip centre height (overall height = this + 2.5)
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
        // post slot socket (tapered in X: post size at the floor, widening upward)
        hull() {
            translate([post_cx, post_cy, base_h - sock_depth]) linear_extrude(0.1) rrect(post_t, post_t + 0.6, 1.5);
            translate([post_cx, post_cy, base_h + 0.9]) linear_extrude(0.1) rrect(post_t + 1.7, post_t + 0.6, 1.5);
        }
    }
}

// the post is a planar Y profile (in the XZ plane) extruded 5 thick in Y;
// the handle bar rests front-to-back in the fork, its flat arm cradled
// between the prongs, lid toward the back, knob toward the front
module post_profile() {
    union() {
        // tenon (tapered in X: wedges into the slot before bottoming out)
        polygon([[post_cx - 2.5, 3.5], [post_cx + 2.5, 3.5],
                 [post_cx + 3.05, base_h], [post_cx - 3.05, base_h]]);
        // stem (5 wide)
        translate([post_cx, (base_h + stem_top) / 2]) square([post_t, stem_top - base_h], center = true);
        // prongs (5-wide capsules splayed in X)
        for (s = [-1, 1])
            hull() {
                translate([post_cx + s * prong_base_dx, prong_base_z]) circle(r = 2.5);
                translate([post_cx + s * prong_tip_dx, prong_tip_z]) circle(r = 2.5);
            }
    }
}

module pole() {
    translate([0, post_cy + post_t / 2, 0])
        rotate([90, 0, 0]) linear_extrude(post_t) post_profile();
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
