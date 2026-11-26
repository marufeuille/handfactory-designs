// Comandante C40 stand v3 - parametric, split/assembly design for distribution
// Parts: "base" (with post slot), "pole" (slim 5 mm blade post with a Y-fork top, print it lying flat), "both" (preview)
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

/* [Blade post - back-centre, between the two seats] */
blade_t = 5;           // blade thickness (X): a slim rounded bar, not a pole
blade_w = 30;          // blade width (Y)
blade_cx = 71.5;       // post centre X (also the centre of the trimmed base)
blade_cy = 62;         // post centre Y
blade_top = 176;       // horn tip height (overall post height)
valley_z = 164;        // fork valley floor: the handle bar rests here
valley_w = 20;         // fork valley width (Y)
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
        // blade slot socket (tapered: blade size at the floor, widening upward)
        hull() {
            translate([blade_cx, blade_cy, base_h - sock_depth]) linear_extrude(0.1) rrect(blade_t, blade_w, 2);
            translate([blade_cx, blade_cy, base_h + 0.9]) linear_extrude(0.1) rrect(blade_t + 1.7, blade_w + 1.7, 2);
        }
    }
}

module pole() {
    // tenon (tapered: wedges into the slot before its tip bottoms out)
    hull() {
        translate([blade_cx, blade_cy, base_h - 11.5]) linear_extrude(0.1) rrect(blade_t, blade_w, 2);
        translate([blade_cx - 0.55, blade_cy, base_h - 0.1]) linear_extrude(0.1) rrect(blade_t + 1.1, blade_w + 1.1, 2);
    }
    // blade: a rounded slab (hull of X-axis cylinders) with a valley cut
    // between the two horns at the top; the handle bar rests in the valley,
    // captured between its lid and its knob
    difference() {
        hull()
            for (sy = [-1, 1], zz = [base_h + 2.5, valley_z - 2.5, blade_top - 2.5])
                translate([blade_cx - blade_t / 2, blade_cy + sy * (blade_w / 2 - 2.5), zz])
                    rotate([0, 90, 0]) cylinder(h = blade_t, r = 2.5);
        // valley cut (flat floor, filleted entries)
        hull() {
            for (sy = [-1, 1])
                translate([blade_cx - blade_t / 2 - 1, blade_cy + sy * (valley_w / 2 - 3), valley_z + 3])
                    rotate([0, 90, 0]) cylinder(h = blade_t + 2, r = 3);
            translate([blade_cx, blade_cy, (valley_z + 3 + blade_top + 10) / 2])
                cube([blade_t + 2, valley_w, blade_top + 10 - valley_z - 3], center = true);
        }
    }
}

if (part == "base") base();
if (part == "pole") pole();
if (part == "both") { base(); pole(); }
