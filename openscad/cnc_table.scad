include <lib/t20beam.scad>

CUT_L = 1000;
CUT_W = 500;


module frame() {
    translate([CUT_L/2, -t20_w/2, -t20_w/2])
        rotate([0, 90, 0])
        t20(CUT_L);
    translate([-t20_w/2, CUT_W/2, -t20_w/2])
        rotate([90, 0, 0])
        t20(CUT_W);
    translate([CUT_L/2, CUT_W + t20_w/2, -t20_w/2])
        rotate([0, 90, 0])
        t20(CUT_L);
    translate([CUT_L + t20_w/2, CUT_W/2, -t20_w/2])
        rotate([90, 0, 0])
        t20(CUT_W);   
}

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

module gantry_plate() {
    translate([-gplate_w/2, -gplate_w/2, -gplate_th/2])
    difference() {
        cube([gplate_w, gplate_w, gplate_th]);
        /*
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

//! gantry_plate();

module gwheel() {
    cylinder(r=gwheel_od/2, h=gwheel_th, center=true);
}

module gantry_assm() {
    % translate([0, -t20_w/2, t20_w/2])
        rotate([0, 90, 0])
        t20(100);
    translate([
        0, -t20_w/2, -gplate_th/2 + -gwheel_clr])
        gantry_plate();
    # translate([0, 0, 0])
        gwheel();
    
}

! gantry_assm();

module gantry() {
    translate([gplate_w/2, 0, 0])
        rotate([90, 0, 0])
        gantry_assm();
}

module design() {
    frame();
    gantry();
}

design();