include <lib/t20beam.scad>;
include <lib/motion_hardware.scad>;
include <lib/stepper.scad>;
use <lib/lib_pulley.scad>;

BEAM_L = 500;
LEG_L = 100;

roller_or = bearing_or + bearing_h/2;

// TODO: mathematically compute 
bearing_rail_offs = bearing_or + 2;

xstage_w = 50;
xstage_h = 120;
xstage_dz = 30;
stage_plate_th = 2;
stage_plate_gap = 30;

corner_plate_th = 2;

function fn() = $preview ? 32 : 64;

function stage_position() = [100, 100];

module frame() {
    for (offs=[0, BEAM_L + t20_w]) {
        for (z=[-t20_w/2, -3*t20_w/2]) { 
            translate([offs, BEAM_L/2 + t20_w/2, z])
                rotate([90, 0, 0])
                t20(BEAM_L);
            translate([BEAM_L/2 + t20_w/2, offs, z])
                rotate([0, 90, 0])
                t20(BEAM_L);
        }
        for (offs2=[0, BEAM_L + t20_w]) {
            translate([offs, offs2, -LEG_L/2]) {
                t20(LEG_L);
            }
        }
    }
    translate([-t20_w/2, -t20_w/2, -t20_w*2])
        rotate([0, -90, 0])
        corner_plate();
    translate([-t20_w/2, -t20_w/2, -t20_w*2])
        rotate([90, 0, 0])
        corner_plate();
}

module bushing68() {
    difference() {
        cylinder(r=3.9, h=7, center=true, $fn=128);
        cylinder(r=3, h=20, center=true, $fn=64);
    }
}

// ! bushing68();

module roller() {
    difference() {
        rotate_extrude($fn=fn()*2) {
            translate([bearing_or, 0, 0])
                circle(r=bearing_h/2);
        }
        # bearing();
        # bushing68();
    }
}

module xstage_plate_base_holes() {
    for (z=[bearing_rail_offs, -2*t20_w - bearing_rail_offs]) {
        for (x=[-xstage_w/2, xstage_w/2])
            translate([x, 0, z])
            rotate([90, 0, 0])
            cylinder(r=3, h=50, center=true);
    }
    translate([0, -stage_plate_gap/2 - stage_plate_th/2 - 0.6, xstage_dz]) {
        rotate([90, 0, 0])
            motor(model=Nema17);
        for (x=[-31.04/2, 31.04/2])
            for (z=[-31.04/2, 31.04/2])
            translate([x, 0, z])
            rotate([90, 0, 0])
            cylinder(r=3/2, h=30, center=true);
        rotate([90, 0, 0])
            cylinder(r=6/2, h=30, center=true);
        rotate([90, 0, 0])
            cylinder(r=bearing_or, h=100, center=true, $fn=fn());
    }

}

module xstage_plate_base() {
    cube([xstage_w + roller_or, stage_plate_th, xstage_h], center=true);
    translate([0, bearing_h/2 - stage_plate_th/2, xstage_dz])
        rotate([90, 0, 0])
        cylinder(r=bearing_or + stage_plate_th, h=bearing_h, center=true, $fn=fn());
}

// ! xstage_plate_base();

module xstage_motor_plate() {
   difference() {
        translate([0, -stage_plate_gap/2 - stage_plate_th/2, 0])
            xstage_plate_base();
        xstage_plate_base_holes();
    } 
}

module xstage_brace_plate() {
   difference() {
        union() {
            translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])
                xstage_plate_base();
            translate([0, stage_plate_gap/2 + bearing_h/2, xstage_dz])
                rotate([90, 0, 0])
                cylinder(r=bearing_or + stage_plate_th, h=bearing_h, center=true, $fn=fn());
        }
        xstage_plate_base_holes();
        // translate([0, stage_plate_gap/2 + stage_plate_th/2, xstage_dz])
        //     rotate([90, 0, 0])
        //     cylinder(r=bearing_or, h=30, center=true, $fn=fn());
        // translate([0, stage_plate_gap/2 + bearing_h/2, xstage_dz])
        //     rotate([90, 0, 0])
        //     bearing();
        % translate([0, stage_plate_gap/2 + bearing_h/2, xstage_dz])
            rotate([90, 0, 0])
            bearing();
        // translate([-50, 0, roller_or + 6])
        //     cube([100, 30, 100]);
    } 
}

// ! xstage_brace_plate();

module xstage() {
    xstage_motor_plate();
    xstage_brace_plate();
    for (z=[bearing_rail_offs, -2*t20_w - bearing_rail_offs]) {
        for (x=[-xstage_w/2, xstage_w/2])
            translate([x, 0, z])
            rotate([90, 0, 0])
            roller();
    }

    % for (z=[-t20_w/2, -t20_w/2 - t20_w])
        translate([0, 0, z])
        rotate([0, 90, 0])
        t20(xstage_w + roller_or*2);
}

// ! xstage();

module corner_plate() {
    difference() {
        cube([t20_w * 2, t20_w * 2, corner_plate_th]);
        for (x=[t20_w/2, 3*t20_w/2])
            for (y=[t20_w/2, 3*t20_w/2])
            translate([x, y, 0])
            cylinder(r=5/2, h=10, center=true, $fn=fn());
    }
}

// ! corner_plate();

module design() {
    frame();
    translate([stage_position()[0], 0, 0]) {
        xstage();
        % translate([0, -stage_plate_gap/2 - stage_plate_th/2 - 0.6, xstage_dz])
            rotate([90, 0, 0])
                motor(model=Nema17);
    }
}

design();
