// Comandante C40 stand — two-story tower (v1, four separate legs)
// 1F: body, 2F: grounds jar, roof: crank hook. Floors double as dust lids.
// Front slide-out: legs are at the corners, footprint widened so the body
// (Ø64) clears the front legs (inner gap 72mm).
// Units: mm. Origin: front-left-bottom corner of the footprint. Z up.
// part: "all" | "base" | "middle" | "roof" | "leg1" | "leg2"

part = "all";

// ---- parameters ----
W = 128;             // footprint width  (x) — wide enough for fingers around the body
D = 104;             // footprint depth  (y)

body_bore = 64;
recess_d = 6;
body_c = [64, 52];
jar_bore = 62;
jar_c = [64, 52];

base_t = 18;         // 1F plate: z 0..18
f2_under = 184;      // 2F plate underside (body top 172 + slide lift 6 + margin 6)
mid_t = 20;          // 2F plate: z 184..204 (sockets 9 + web 2 + sockets 9)
roof_under = 274;    // roof underside (jar top 263 + slide lift 6 + margin 5)
roof_t = 14;         // roof plate: z 274..288
lip_h = 12;          // front lip above roof -> total height 300
lip_t = 5;
notch_w = 16;

leg = 16;            // leg cross-section (square)
inset = 4;           // leg inset from footprint edges
peg = 12;            // tenon peg cross-section
peg_l = 8;           // peg length (socket depth 9, 1mm end clearance)
socket = 12.6;       // socket (peg + 0.3 clearance per side)
socket_d = 9;

$fn = 128;

leg_x = [inset, W - inset - leg];
leg_y = [inset, D - inset - leg];

module socket_cut(z0, h = socket_d) {
    for (x = leg_x) for (y = leg_y)
        translate([x + (leg - socket) / 2, y + (leg - socket) / 2, z0])
            cube([socket, socket, h]);
}

module base() {
    difference() {
        cube([W, D, base_t]);
        translate([body_c[0], body_c[1], base_t - recess_d])
            cylinder(h = recess_d + 1, d = body_bore);
        socket_cut(base_t - socket_d);
    }
}

module middle() {
    difference() {
        translate([0, 0, f2_under]) cube([W, D, mid_t]);
        translate([jar_c[0], jar_c[1], f2_under + mid_t - recess_d])
            cylinder(h = recess_d + 1, d = jar_bore);
        socket_cut(f2_under - 1, socket_d + 1);   // bottom sockets (open downward)
        socket_cut(f2_under + mid_t - socket_d);  // top sockets
    }
}

module roof() {
    difference() {
        translate([0, 0, roof_under]) cube([W, D, roof_t]);
        socket_cut(roof_under - 1, socket_d + 1);
    }
    lip_z = roof_under + roof_t;
    translate([0, 0, lip_z]) cube([(W - notch_w) / 2, lip_t, lip_h]);
    translate([(W + notch_w) / 2, 0, lip_z]) cube([(W - notch_w) / 2, lip_t, lip_h]);
}

// one leg at the front-left corner, in assembled position
module leg1() {
    x = leg_x[0]; y = leg_y[0];
    translate([x + (leg - peg) / 2, y + (leg - peg) / 2, base_t - peg_l])
        cube([peg, peg, peg_l]);
    translate([x, y, base_t]) cube([leg, leg, f2_under - base_t]);
    translate([x + (leg - peg) / 2, y + (leg - peg) / 2, f2_under])
        cube([peg, peg, peg_l]);
}

module leg2() {
    x = leg_x[0]; y = leg_y[0];
    mid_top = f2_under + mid_t;
    translate([x + (leg - peg) / 2, y + (leg - peg) / 2, mid_top - peg_l])
        cube([peg, peg, peg_l]);
    translate([x, y, mid_top]) cube([leg, leg, roof_under - mid_top]);
    translate([x + (leg - peg) / 2, y + (leg - peg) / 2, roof_under])
        cube([peg, peg, peg_l]);
}

module all_legs() {
    for (x = leg_x) for (y = leg_y) {
        translate([x - leg_x[0], y - leg_y[0], 0]) { leg1(); leg2(); }
    }
}

if (part == "all") { base(); middle(); roof(); all_legs(); }
if (part == "base") base();
if (part == "middle") middle();
if (part == "roof") roof();
if (part == "leg1") leg1();
if (part == "leg2") leg2();
