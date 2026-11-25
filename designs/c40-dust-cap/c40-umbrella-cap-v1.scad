// C40 dust cap — umbrella type (light & fast to print)
// Sits on the body's top rim; a hex socket on the underside engages
// the drive shaft's hex to centre and hold it.
// Shaft hex: 5.5mm across flats (community data from a motorised
// adapter project; not an official spec). Socket modelled at 5.7mm
// = light fit, per the owner's preference (2026-11-26).
// The cup type lives in c40-dust-cap-v1.scad; this is the flat variant.

$fn = 96;

// --- parameters (mm) ---
disk_d       = 66;   // canopy diameter (body is ~60-61)
disk_t       = 3;    // canopy thickness
skirt_h      = 3;    // centring skirt height below the disk
skirt_in_d   = 62.5; // skirt inner diameter (body OD ~61 + clearance)
boss_d       = 12;   // centre boss outer diameter
boss_h       = 7;    // boss protrusion below disk underside
hex_af       = 5.7;  // hex socket across-flats (light fit on 5.5)
socket_depth = 12;   // socket depth measured from boss tip
grip_d       = 22;   // top grip bump diameter
grip_h       = 3;    // top grip bump height

module hex_prism(af, h) {
  // 6-facet cylinder sized so the across-flats distance equals af
  cylinder(h = h, r = af / sqrt(3), $fn = 6);
}

module umbrella_cap() {
  difference() {
    union() {
      // canopy disk
      cylinder(h = disk_t, d = disk_d);
      // centring skirt (ring that hugs the body's top outside)
      translate([0, 0, -skirt_h])
        difference() {
          cylinder(h = skirt_h, d = disk_d);
          translate([0, 0, -0.1]) cylinder(h = skirt_h + 0.2, d = skirt_in_d);
        }
      // centre boss reaching down to the shaft hex
      translate([0, 0, -boss_h]) cylinder(h = boss_h, d = boss_d);
      // top grip bump
      translate([0, 0, disk_t]) cylinder(h = grip_h, d = grip_d);
    }
    // hex socket (blind, opens at the boss tip)
    translate([0, 0, -boss_h - 0.1]) hex_prism(hex_af, socket_depth + 0.1);
  }
}

umbrella_cap();
