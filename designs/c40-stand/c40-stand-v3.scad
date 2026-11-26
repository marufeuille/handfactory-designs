// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with pole socket), "pole" (L-shaped, print it lying flat), "both" (preview)
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
shelf_w = 7;           // shelf ledge width (through-hole = bore - 2*shelf_w)
jar_cx = 38;           // jar bore centre X
body_cx = 106;         // body bore centre X

/* [Pole socket - back-right corner] */
sock_w = 14;           // socket size X
sock_d = 18;           // socket size Y
sock_depth = 12;       // socket depth (base_h - 3 floor)
sock_taper = 0.75;     // socket + tenon taper, mm per side over sock_depth (wedge fit)
tenon_root_clear = 0.15; // tenon root clearance per side at the rim
tenon_len = 11.5;      // sock_depth - 0.5: walls wedge before the tip bottoms out
tenon_taper = 0.6;     // gentler than sock_taper: the gap closes with depth,
                       // so the tenon tip seats firm as the pole shoulder lands
sock_cx = 152.5;       // socket centre X
sock_cy = 63;          // socket centre Y

/* [Pole] */
pole_top = 160;        // total height when assembled (same as v2)
// tenon clearance is handled by the taper (sock_taper / tenon_root_clear)
pole_w = 16;           // pole cross-section X (above the tenon)
pole_d = 20;           // pole cross-section Y (above the tenon)
arm_z0 = 148;          // arm underside height
arm_t = 10;            // arm thickness
arm_tip_y = 10;        // arm tip Y (front side)
lip_w = 6;             // hook lip size (along Y)
lip_drop = 10;         // hook lip drop below the arm

$fn = 128;
cy = base_d / 2;

// rectangular frustum, centred at (cx, cy), from z0 (bottom, wb x db) up h to (wt x dt)
module frustum_c(cx, cyy, z0, h, wb, db, wt, dt) {
    hull() {
        translate([cx - wb / 2, cyy - db / 2, z0]) cube([wb, db, 0.1]);
        translate([cx - wt / 2, cyy - dt / 2, z0 + h - 0.1]) cube([wt, dt, 0.1]);
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
    thru = bore - 2 * shelf_w;
    // upper seat (from the shelf up to the top face)
    translate([0, 0, base_h - sink]) linear_extrude(sink + 1) u_profile(cx, bore / 2);
    // narrower through-channel below the shelf (fines fall / sweep through)
    translate([0, 0, -1]) linear_extrude(base_h - sink + 1) u_profile(cx, thru / 2);
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
        // pole socket (tapered: nominal sock_w x sock_d at the floor, widening upward)
        frustum_c(sock_cx, sock_cy, base_h - sock_depth, sock_depth + 1,
                  sock_w, sock_d,
                  sock_w + 2 * sock_taper * (sock_depth + 1) / sock_depth,
                  sock_d + 2 * sock_taper * (sock_depth + 1) / sock_depth);
    }
}

module pole() {
    // tenon (tapered to match the socket; root at the rim, tip short of the floor)
    tenon_root_w = sock_w + 2 * sock_taper - 2 * tenon_root_clear;
    tenon_root_d = sock_d + 2 * sock_taper - 2 * tenon_root_clear;
    tenon_tip_w = tenon_root_w - 2 * tenon_taper * tenon_len / sock_depth;
    tenon_tip_d = tenon_root_d - 2 * tenon_taper * tenon_len / sock_depth;
    frustum_c(sock_cx, sock_cy, base_h - tenon_len, tenon_len,
              tenon_tip_w, tenon_tip_d, tenon_root_w, tenon_root_d);
    // main shaft
    translate([sock_cx - pole_w / 2, sock_cy - pole_d / 2, base_h])
        cube([pole_w, pole_d, pole_top - base_h]);
    // top arm: from the shaft forward (-Y). Full pole_w wide, flush with the
    // shaft faces, so the pole stays a uniform extrusion and prints flat.
    arm_y1 = sock_cy + pole_d / 2;
    translate([sock_cx - pole_w / 2, arm_tip_y, arm_z0])
        cube([pole_w, arm_y1 - arm_tip_y, arm_t]);
    // hook lip at the arm tip
    translate([sock_cx - pole_w / 2, arm_tip_y, arm_z0 - lip_drop])
        cube([pole_w, lip_w, lip_drop]);
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
