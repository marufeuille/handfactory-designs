// Comandante C40 spine stand v1 (AeroStack-style: back spine, front-open)
// Proto design. All unmeasured clearances are marked 仮 (provisional).
// part: "all" | "base" | "top"
part = "all";

$fn = 96;

// ---- parameters (mm) ----
body_bore   = 64;   // body seat inner (v3 flat stand value)
body_h      = 160;  // body height (nominal)
cup_bore    = 63;   // catch cup recess (cup nominal Ø60)
cup_h       = 65;   // catch cup height (nominal)

// base plate
plate_w = 106; plate_d = 110; plate_t = 8; plate_r = 6;
// plate spans y in [-66, +44]; body axis at origin

// body seat (owner's revision): body stands at plate level; its bottom
// rim (protrudes 2mm) drops into a shallow groove in the plate, caught
// by an inner island (~2mm) and a low back wall (~10mm)
groove_ro = 32;     // groove outer wall Ø64
groove_ri = 26;     // groove inner Ø52 (island edge = inner catch)
groove_floor = 5;   // 3mm below plate top (plate top z=8)
island_top = 6.8;   // island stands ~1.8mm above groove floor
wall_ro = 40;       // back wall outer Ø80, inner face = groove outer wall
wall_top = 18;      // 10mm above plate top
wall_arc = 130;     // back wall arc (deg, centred on -y)

// spine
spine_w = 20; spine_d = 22;
spine_y0 = -62; spine_y1 = -40;       // front face at y=-40 (tangent to claw back)
spine_top_base = 168;                  // base part spine top
socket_w = 13; socket_d = 15; socket_depth = 28;
tenon_w = 12.4; tenon_d = 14.4;        // 0.3/side clearance

// cup shelf (on top part)
shelf_z0 = 184; shelf_t = 8;           // underside clears body top (174) + axle stub (仮 ~186)
shelf_r  = 40;
shelf_hole = 30;                       // centre hole so the axle stub can poke through (仮)
cup_recess = 2.5;

// top arm (crank hook, provisional — fit unverified)
arm_z0 = 260; arm_t = 10;              // top at 278
arm_w = 64; arm_y1 = 36;               // extends forward from spine
slot_w = 24; slot_back = -6;           // U-notch for crank shaft, lid rests on arm

module rounded_plate() {
  hull() for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * (plate_w/2 - plate_r), -11 + sy * (plate_d/2 - plate_r), 0])
      cylinder(h = plate_t, r = plate_r);
}

module back_wall() {
  // low arc wall at the back only; front and sides stay open
  rotate([0, 0, 270 - wall_arc/2])
    rotate_extrude(angle = wall_arc)
      polygon([[groove_ro, 8], [wall_ro, 8], [wall_ro, wall_top],
               [groove_ro, wall_top]]);
}

module seat_cuts() {
  // annular groove in the plate top
  difference() {
    translate([0, 0, groove_floor]) cylinder(h = 4, r = groove_ro);
    translate([0, 0, groove_floor - 1]) cylinder(h = 6, r = groove_ri);
  }
  // dish the island top down to island_top
  translate([0, 0, island_top]) cylinder(h = 3, r = groove_ri);
}

module spine_block(z0, z1) {
  translate([-spine_w/2, spine_y0, z0])
    cube([spine_w, spine_d, z1 - z0]);
}

module base_part() {
  difference() {
    union() {
      rounded_plate();
      back_wall();
      spine_block(plate_t, spine_top_base);
    }
    seat_cuts();
    // tenon socket at spine top
    translate([-socket_w/2, (spine_y0+spine_y1)/2 - socket_d/2,
               spine_top_base - socket_depth])
      cube([socket_w, socket_d, socket_depth + 1]);
  }
}

module top_part() {
  yc = (spine_y0 + spine_y1) / 2;
  union() {
    // tenon
    translate([-tenon_w/2, yc - tenon_d/2, spine_top_base - socket_depth])
      cube([tenon_w, tenon_d, socket_depth]);
    // spine continuation
    spine_block(spine_top_base, arm_z0 + arm_t);
    // cup shelf: disc + neck to spine, centre hole, cup recess
    difference() {
      union() {
        translate([0, 0, shelf_z0]) cylinder(h = shelf_t, r = shelf_r);
        translate([-16, -52, shelf_z0]) cube([32, 34, shelf_t]); // neck
      }
      translate([0, 0, shelf_z0 - 1]) cylinder(h = shelf_t + 2, d = shelf_hole);
      translate([0, 0, shelf_z0 + shelf_t - cup_recess])
        cylinder(h = cup_recess + 1, d = cup_bore);
    }
    // top arm with U-notch (crank lid rests on top, shaft in slot) — 仮
    difference() {
      translate([-arm_w/2, spine_y0, arm_z0])
        cube([arm_w, arm_y1 - spine_y0, arm_t]);
      translate([-slot_w/2, slot_back, arm_z0 - 1])
        cube([slot_w, arm_y1 - slot_back + 1, arm_t + 2]);
    }
  }
}

// exported in positive octant (min corner at origin), repo convention
translate([plate_w/2, 66, 0]) {
  if (part == "base") base_part();
  else if (part == "top") top_part();
  else { base_part(); top_part(); }
}
