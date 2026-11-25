// Comandante C40 stand — two-story tower (v1)
// 1F: body, 2F: grounds jar, roof: crank hook. Floors double as dust lids.
// Front is open: body and jar slide out forward (blind recesses, no through holes).
// Units: mm. Origin: front-left-bottom corner of the footprint. Z up.
// part: "all" | "base" | "middle" | "roof"

part = "all";

// ---- parameters ----
W = 96;              // footprint width  (x)
D = 92;              // footprint depth  (y)

base_t = 12;         // 1F floor thickness
body_bore = 64;      // body recess diameter (C40 body ~61 + clearance)
body_recess_d = 6;   // blind recess depth (shallow: slide-out step)
body_c = [48, 46];   // body centre (x, y)

f2_under = 176;      // underside of 2F floor (body top 166 + slide lift 6 + margin 4)
f2_t = 10;           // 2F floor thickness -> top at 186
jar_bore = 62;       // jar recess diameter (jar ~60 + clearance)
jar_recess_d = 6;
jar_c = [48, 46];

roof_under = 250;    // underside of roof (jar top 245 + margin 5)
roof_t = 10;         // roof thickness -> top at 260
lip_h = 12;          // front lip height above roof (crank rest)
lip_t = 5;           // front lip thickness
notch_w = 16;        // centre notch in the lip for the crank shaft

post = 18;           // back post cross-section (square)
post_inset = 4;      // post inset from footprint edges
socket = 12.6;       // tenon socket (12 peg + 0.3 clearance per side)
socket_d = 10;
peg = 12;            // tenon peg cross-section
peg_l = 10;

$fn = 128;

post_x = [post_inset, W - post_inset - post];
post_y = D - post_inset - post;

module posts(h_z0, h_z1, sockets) {
    for (x = post_x)
        translate([x, post_y, h_z0])
            difference() {
                cube([post, post, h_z1 - h_z0]);
                if (sockets)
                    translate([(post - socket) / 2, (post - socket) / 2, h_z1 - h_z0 - socket_d])
                        cube([socket, socket, socket_d + 1]);
            }
}

module pegs(z_top) {
    for (x = post_x)
        translate([x + (post - peg) / 2, post_y + (post - peg) / 2, z_top - peg_l])
            cube([peg, peg, peg_l]);
}

module base() {
    difference() {
        cube([W, D, base_t]);
        translate([body_c[0], body_c[1], base_t - body_recess_d])
            cylinder(h = body_recess_d + 1, d = body_bore);
    }
    posts(base_t, f2_under, true);
}

module middle() {
    difference() {
        translate([0, 0, f2_under]) cube([W, D, f2_t]);
        translate([jar_c[0], jar_c[1], f2_under + f2_t - jar_recess_d])
            cylinder(h = jar_recess_d + 1, d = jar_bore);
    }
    pegs(f2_under);
    posts(f2_under + f2_t, roof_under, true);
}

module roof() {
    translate([0, 0, roof_under]) cube([W, D, roof_t]);
    pegs(roof_under);
    // front lip with a centre notch for the crank shaft
    lip_z = roof_under + roof_t;
    translate([0, 0, lip_z]) cube([(W - notch_w) / 2, lip_t, lip_h]);
    translate([(W + notch_w) / 2, 0, lip_z]) cube([(W - notch_w) / 2, lip_t, lip_h]);
}

if (part == "all") { base(); middle(); roof(); }
if (part == "base") base();
if (part == "middle") middle();
if (part == "roof") roof();
