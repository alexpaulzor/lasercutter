
include <lib/t20beam.scad>;
include <lib/motors.scad>;

gplate_th = 3;
gplate_w = 65.5;
gplate_corner_r = 3;
gwheel_clr = 2;
gwheel_od = 25;
gwheel_th = 7;
// x, y, id, slot_w
gplate_holes = [
    [12.90, 5.05, 3, 15.85-9.35],
        [32.75, 5.05, 3, 36-29.5],
        [52.6, 5.05, 3, 56.15-49.65],
    [12.90, 12.75, 7.20, 0],
        [32.75, 12.75, 5, 42.75-22.75],
        [52.6, 12.75, 5.10, 0],
    [12.90, 22.75, 5.1, 0],
        [32.75, 22.75, 5.1, 0],
        [52.6, 22.75, 5.1, 0],
    [12.90, 32.75, 7.20, 0],
        [22.75, 32.75, 5.1, 0],
        [32.75, 32.75, 5.1, 0],
        [42.75, 32.75, 5.1, 0],
        [52.6, 32.75, 5.1, 0],
    [12.90, 42.75, 5.1, 0],
        [32.75, 42.75, 5.1, 0],
        [52.6, 42.75, 5.1, 0],
    [12.90, 52.75, 7.20, 0],
        [32.75, 52.75, 5, 42.75-22.75],
        [52.6, 52.75, 5.1, 0],
    [12.90, 60.45, 3, 15.85-9.35],
        [32.75, 60.45, 3, 36-29.5],
        [52.6, 60.45, 3, 56.15-49.65],
];

// x, y
gplate_wheels = [
    [12.90, 12.75],
    [12.90, 52.75],
    [52.6, 52.75],
    [52.6, 12.75],
];

module gantry_plate(simple=false) {
    translate([-gplate_w/2, -gplate_w/2, -gplate_th/2])
    difference() {
        if (simple)
            cube([gplate_w, gplate_w, gplate_th]);
        else
            // /*
            minkowski() {
                translate([gplate_corner_r, gplate_corner_r, 0])
                cube([
                    gplate_w - 2 * gplate_corner_r, 
                    gplate_w - 2 * gplate_corner_r, 
                    gplate_th]);
                cylinder(r=3, h=0.1, center=true);
            }  // */
        for (holespec=gplate_holes) {
            x = holespec[0];
            y = holespec[1];
            id = holespec[2];
            w = holespec[3];
            translate([x, y, 0]) {
                translate([-w/2, 0, 0])
                    cylinder(r=id/2, h=3*gplate_th, center=true);
                if (w > 0) {
                    translate([w/2, 0, 0])
                        cylinder(r=id/2, h=3*gplate_th, center=true);
                    cube([w, id, 3*gplate_th], center=true);
                }
            }
        }
    }
}

// ! gantry_plate();

module gwheel() {
    cylinder(r=gwheel_od/2, h=gwheel_th, center=true);
    translate([0, 0, -20])
        cylinder(r=5/2, h=30, center=false);
}

module gantry_assm(use_stl=true, simple=false) {
    // *% translate([0, 0, t20_w/2])
    //     rotate([0, 90, 0])
    //     t20(100);
    translate([
        0, 0, -gplate_th/2 + -gwheel_clr])
        if (use_stl)
            import("stl/gantry_plate.gantry_plate.stl");
        else
            gantry_plate(simple=simple);
    % for (xy=gplate_wheels) {
        translate([
                xy[0]-gplate_w/2, 
                xy[1]-gplate_w/2, 
                t20_w/2])
            gwheel();
    }
}

// ! gantry_assm();

gplate_holes2 = [
    [12.90, 5.05, 3, 15.85-9.35],
        [32.75, 5.05, 3, 36-29.5],
        [52.6, 5.05, 3, 56.15-49.65],
        [72.6, 5.05, 3, 56.15-49.65],
        [92.6-5, 5.05, 3, 0],
        [102.6, 5.05, 3, 56.15-49.65],
        [122.6, 5.05, 3, 56.15-49.65],
    [12.90, 12.75, 7.20, 0],
        [32.75, 12.75, 5, 42.75-22.75],
        [52.6, 12.75, 5.10, 0],
        [62.6, 12.75, 5.10, 0],
        [72.6, 12.75, 5.10, 0],
        [82.6, 12.75, 5.10, 0],
        [102.6, 12.75, 5.10, 0],
        [122.6, 12.75, 5.10, 0],
    [12.90, 22.75, 5.1, 0],
        [32.75, 22.75, 5.1, 0],
        [52.6, 22.75, 5.1, 0],
    [12.90, 32.75, 7.20, 0],
        [22.75, 32.75, 5.1, 0],
        [32.75, 32.75, 5.1, 0],
        [42.75, 32.75, 5.1, 0],
        [52.6, 32.75, 5.1, 0],
        // [82.6, 32.75, 5.1, 0],
        [102.6, 32.75, 5.1, 0],
        // [112.6, 32.75, 5.1, 0],
        [122.6, 32.75, 5.1, 0],
    [12.90, 42.75, 5.1, 0],
        [32.75, 42.75, 5.1, 0],
        [52.6, 42.75, 5.1, 0],
    [12.90, 52.75, 7.20, 0],
        [32.75, 52.75, 5, 42.75-22.75],
        [52.6, 52.75, 5.1, 0],
        [62.6, 52.75, 5.1, 0],
        [72.6, 52.75, 5.1, 0],
        [82.6, 52.75, 5.1, 0],
        [102.6, 52.75, 5.1, 0],
        [122.6, 52.75, 5.1, 0],
    [12.90, 60.45, 3, 15.85-9.35],
        [32.75, 60.45, 3, 36-29.5],
        [52.6, 60.45, 3, 56.15-49.65],
        [72.6, 60.45, 3, 56.15-49.65],
        [92.6-5, 60.45, 3, 0],
        [102.6, 60.45, 3, 56.15-49.65],
        [122.6, 60.45, 3, 56.15-49.65],
];

// x, y
gplate_wheels2 = [
    [12.90-10, 12.75],
    [12.90-10, 52.75],
    [52.6+10, 52.75],
    [52.6+10, 12.75],
];

gplate_l = gplate_w + 70;

module gantry_plate2(simple=false) {
    translate([-gplate_w/2-10, -gplate_w/2, -gplate_th/2])
    difference() {
        if (simple)
            cube([gplate_l, gplate_w, gplate_th]);
        else
            // /*
            minkowski() {
                translate([gplate_corner_r, gplate_corner_r, 0])
                cube([
                    gplate_l - 2 * gplate_corner_r, 
                    gplate_w - 2 * gplate_corner_r, 
                    gplate_th]);
                cylinder(r=3, h=0.1, center=true);
            }  // */
        for (holespec=gplate_holes2) {
            x = holespec[0];
            y = holespec[1];
            id = holespec[2];
            w = holespec[3];
            translate([x, y, 0]) {
                translate([-w/2, 0, 0])
                    cylinder(r=id/2, h=3*gplate_th, center=true);
                if (w > 0) {
                    translate([w/2, 0, 0])
                        cylinder(r=id/2, h=3*gplate_th, center=true);
                    cube([w, id, 3*gplate_th], center=true);
                }
            }
        }
        # translate([gplate_w/2+40, gplate_w/2, gplate_th/2])
            rotate([0, -90, 0])
            nema17_mount_holes();
    }
}

// ! gantry_plate2();

module gantry_plate2_export() {
    projection()
        gantry_plate2();
}

// ! gantry_plate2_export();

module gantry_assm2(use_stl=false, simple=false, extras=false) {
    // *% translate([0, 0, t20_w/2])
    //     rotate([0, 90, 0])
    //     t20(100);
    translate([
        0, 0, -gplate_th/2 + -gwheel_clr])
        if (use_stl)
            import("stl/gantry_plate.gantry_plate2.stl");
        else
            gantry_plate2(simple=simple);
    % for (xy=gplate_wheels2) {
        translate([
                xy[0]-gplate_w/2, 
                xy[1]-gplate_w/2, 
                t20_w/2])
            gwheel();
    }
    if (extras) {
        % translate([0, 0, t20_w/2])
            rotate([90, 0, 0])
            v2040(100);
        % translate([gplate_l - gplate_w, 0, 23])
            rotate([0, 0, 0])
            v2040(50);
    }
}

// ! gantry_assm2(simple=true, extras=true);
