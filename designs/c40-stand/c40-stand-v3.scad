// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with pole socket), "pole" (L-shaped, print it lying flat), "both" (preview)
// Units: mm. Adjust the parameters below to fit your grinder (C40/C60, individual variance).

part = "both"; // ["base", "pole", "both"]

/* [Base] */
base_l = 165;          // base length (X)
base_d = 80;           // base depth (Y)
base_h = 15;           // base thickness (v2 was 20; thinned in v3)
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
sock_cx = 152.5;       // socket centre X
sock_cy = 63;          // socket centre Y

/* [Pole] */
pole_top = 160;        // total height when assembled (same as v2)
tenon_clear = 0.3;     // tenon clearance per side
pole_w = 16;           // pole cross-section X (above the tenon)
pole_d = 20;           // pole cross-section Y (above the tenon)
arm_z0 = 148;          // arm underside height
arm_t = 10;            // arm thickness
arm_tip_y = 10;        // arm tip Y (front side)
lip_w = 6;             // hook lip size (along Y)
lip_drop = 10;         // hook lip drop below the arm

/* [Icons on the front face] */
icons = true;          // engraved marks so the two bores are distinguishable
icon_depth = 1.2;

$fn = 128;
cy = base_d / 2;

module stepped_hole(cx, bore) {
    thru = bore - 2 * shelf_w;
    // upper bore (from top down to the shelf)
    translate([cx, cy, base_h - sink]) cylinder(d = bore, h = sink + 1);
    // through hole below the shelf (fines fall through)
    translate([cx, cy, -1]) cylinder(d = thru, h = base_h - sink + 1);
}

module front_icons() {
    // jar side: a ring (the jar seen from above)
    translate([jar_cx, 0, base_h / 2])
        rotate([90, 0, 0])
        difference() {
            cylinder(d = 12, h = icon_depth + 1, center = true);
            cylinder(d = 7.6, h = icon_depth + 3, center = true);
        }
    // body side: an asterisk (the burr seen from above)
    translate([body_cx, 0, base_h / 2])
        for (a = [0, 60, 120])
            rotate([0, a, 0])
            cube([12, icon_depth + 1, 2.2], center = true);
}

module base() {
    difference() {
        cube([base_l, base_d, base_h]);
        stepped_hole(jar_cx, jar_bore);
        stepped_hole(body_cx, body_bore);
        // pole socket
        translate([sock_cx - sock_w / 2, sock_cy - sock_d / 2, base_h - sock_depth])
            cube([sock_w, sock_d, sock_depth + 1]);
        if (icons) front_icons();
    }
}

module pole() {
    tenon_w = sock_w - 2 * tenon_clear;
    tenon_d = sock_d - 2 * tenon_clear;
    // tenon (inserts into the socket)
    translate([sock_cx - tenon_w / 2, sock_cy - tenon_d / 2, base_h - sock_depth])
        cube([tenon_w, tenon_d, sock_depth]);
    // main shaft
    translate([sock_cx - pole_w / 2, sock_cy - pole_d / 2, base_h])
        cube([pole_w, pole_d, pole_top - base_h]);
    // top arm: from the shaft forward (-Y)
    arm_y1 = sock_cy + pole_d / 2;
    translate([sock_cx - pole_w / 2 + 2, arm_tip_y, arm_z0])
        cube([pole_w - 4, arm_y1 - arm_tip_y, arm_t]);
    // hook lip at the arm tip
    translate([sock_cx - pole_w / 2 + 2, arm_tip_y, arm_z0 - lip_drop])
        cube([pole_w - 4, lip_w, lip_drop]);
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
