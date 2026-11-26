// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with post socket), "pole" (centre post with a Y-fork, print it lying flat), "both" (preview)
// Units: mm. Adjust the parameters below to fit your grinder (C40/C60, individual variance).

part = "both"; // ["base", "pole", "both"]

/* [Base] */
base_l = 165;          // base length (X)
base_d = 80;           // base depth (Y)
base_h = 15;           // base thickness (v2 was 20; thinned in v3)
base_r = 4;            // base corner radius (vertical edges)
sink = 8;              // how deep body/jar sink from the top

/* [Bores - measure your grinder and add clearance] */
body_bore = 64;        // body hole diameter (v2: 63 was a tight fit -> +1)
jar_bore = 62;         // grounds jar hole diameter
jar_cx = 38;           // jar bore centre X
body_cx = 106;         // body bore centre X

/* [Post socket - back-centre, between the two seats] */
pole_r = 10;           // pole radius (D-profile: circle r=10, flat cut at +X)
flat_off = 6;          // flat offset from the pole centre (+X side): the flat is
                       // the anti-rotation face and the face the pole lies on
                       // when printed flat
sock_depth = 12;       // socket depth (base_h - 3 floor)
sock_taper = 0.75;     // socket + tenon taper, mm per side over sock_depth (wedge fit)
tenon_root_clear = 0.15; // tenon root clearance per side at the rim
tenon_len = 11.5;      // sock_depth - 0.5: walls wedge before the tip bottoms out
tenon_taper = 0.6;     // gentler than sock_taper: the gap closes with depth,
                       // so the tenon tip seats firm as the pole shoulder lands
sock_cx = 71.5;        // post centre X
sock_cy = 66;          // post centre Y

/* [Post and Y-fork] */
// tenon clearance is handled by the taper (sock_taper / tenon_root_clear)
stem_top = 156;        // where the stem ends and the fork takes over
prong_r = 7;           // fork prong radius
prong_base_dy = 6;     // prong centre offset from the post centre at the root
prong_base_z = 144;    // prong root height (embedded in the stem)
prong_tip_dy = 20;     // prong centre offset at the tip
prong_tip_z = 169;     // prong tip centre height (overall height = this + prong_r = 176)

$fn = 128;
cy = base_d / 2;

// D-shaped profile (plan view), centred on the origin: a circle of radius r
// with the +X side cut flat at x = f
module d_profile(r, f) {
    intersection() {
        circle(r = r);
        translate([-r, -r]) square([r + f, 2 * r]);
    }
}

// tapered D solid between z0 (r0, f0) and z1 (r1, f1), centred at (cx, cy)
module d_frustum(cx, cyy, z0, r0, f0, z1, r1, f1) {
    hull() {
        translate([cx, cyy, z0]) linear_extrude(0.1) d_profile(r0, f0);
        translate([cx, cyy, z1 - 0.1]) linear_extrude(0.1) d_profile(r1, f1);
    }
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
        // pole socket (tapered D: nominal at the floor, widening upward)
        d_frustum(sock_cx, sock_cy, base_h - sock_depth,
                  pole_r, flat_off,
                  base_h + 1,
                  pole_r + sock_taper * (sock_depth + 1) / sock_depth,
                  flat_off + sock_taper * (sock_depth + 1) / sock_depth);
    }
}

module pole() {
    intersection() {
        union() {
            // tenon (tapered D; its flat stays at flat_off, coplanar with the
            // stem flat, so the whole post rests on that face printed flat)
            tenon_root_r = pole_r + sock_taper - tenon_root_clear;
            tenon_tip_r = tenon_root_r - tenon_taper * tenon_len / sock_depth;
            d_frustum(sock_cx, sock_cy, base_h - tenon_len,
                      tenon_tip_r, flat_off,
                      base_h,
                      tenon_root_r, flat_off);
            // main stem (D-profile)
            translate([sock_cx, sock_cy, base_h])
                linear_extrude(stem_top - base_h) d_profile(pole_r, flat_off);
            // Y-fork prongs (capsules splayed in the YZ plane); the handle
            // bar rests in the V, captured between its lid and its knob
            for (s = [-1, 1])
                hull() {
                    translate([sock_cx, sock_cy + s * prong_base_dy, prong_base_z]) sphere(r = prong_r);
                    translate([sock_cx, sock_cy + s * prong_tip_dy, prong_tip_z]) sphere(r = prong_r);
                }
        }
        // keep the +X flat (printing face / anti-rotation flat)
        translate([sock_cx + flat_off - 60, sock_cy - 100, -10]) cube([60, 200, 300]);
    }
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
