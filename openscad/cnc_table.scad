include <lib/t20beam.scad>
include <lib/motors.scad>
include <gantry_plate.scad>
include <lib/helpers.scad>
use <lib/lib_pulley.scad>
include <lib/motion_hardware.scad>

module v2040(l=100) {
    translate([t20_w/2, 0, 0])
        color("black")
        t20(l);
    translate([-t20_w/2, 0, 0])
        color("black")
        t20(l);
}

// ! v2040();

BEAM_L = 1220;
GANTRY_W = 1220;

CUT_L = 1000;
CUT_W = 500;


TABLE_W = 18 * IN_MM; // TODO: measure
TABLE_H = 24 * IN_MM; // TODO: measure
TABLE_LIFT = 150;
LEG_H = TABLE_LIFT - 3/2*t20_w;

module tabletop() {
    translate([-TABLE_W/2 + t20_w/2, 0, t20_w/2])
        rotate([90, 0, 0])
        t20(CUT_L);
    translate([TABLE_W/2 - t20_w/2, 0, t20_w/2])
        rotate([90, 0, 0])
        t20(CUT_L);

    translate([0, -CUT_L/2 - t20_w/2, t20_w/2])
        rotate([0, 90, 0])
        t20(TABLE_W);
    translate([0, CUT_L/2 + t20_w/2, t20_w/2])
        rotate([0, 90, 0])
        t20(TABLE_W);

    translate([0, -CUT_L/2- 3*t20_w/2, TABLE_LIFT - t20_w/2])
        rotate([0, 90, 0])
        v2040(BEAM_L);
    translate([0, CUT_L/2 + 3*t20_w/2, TABLE_LIFT - t20_w/2])
        rotate([0, 90, 0])
        v2040(BEAM_L);

    translate([
            TABLE_W/2 - t20_w/2, 
            -CUT_L/2 - 3*t20_w/2, 
            LEG_H/2])
        t20(LEG_H);  
    translate([
            -TABLE_W/2 + t20_w/2, 
            -CUT_L/2 - 3*t20_w/2, 
            LEG_H/2])
        t20(LEG_H);
    translate([
            TABLE_W/2 - t20_w/2, 
            CUT_L/2 + 3*t20_w/2, 
            LEG_H/2])
        t20(LEG_H);
    translate([
            -TABLE_W/2 + t20_w/2, 
            CUT_L/2 + 3*t20_w/2, 
            LEG_H/2])
        t20(LEG_H);
}

module table() {
    translate([0, 0, -TABLE_H/2])
    draft_cube(
        [TABLE_W, TABLE_W, TABLE_H], 
        center=true, draft_angle=-15, 
        invert=true);
}

// ! table();

// x_pos = 50; //CUT_L / 2;
// y_pos = 50;

cut_limit = CUT_W/2;
// $t = 0.5;
x_pos = cut_limit/2 * cos(360*$t);
y_pos = cut_limit/2 * sin(360*$t);
echo(x_pos=x_pos, y_pos=y_pos);

module frame() {
    translate([-t20_w - GANTRY_W/2, 0, 0])
        rotate([0, 0, 0])
        rotate([90, 0, 0])
        v2040(BEAM_L);
    translate([GANTRY_W/2 + t20_w, 0, 0])
        rotate([0, 0, 0])
        rotate([90, 0, 0])
        v2040(BEAM_L);  
}



module gantry() {
    translate([-GANTRY_W/2, 0, 0])
        rotate([0, -90, 0])
        gantry_assm();
    translate([
            GANTRY_W/2 - nema17_mount_flange_h, 
            0, 
            gplate_w/2 + nema17_mount_c_h + t20_w])
        // rotate([0, 0, 0])
            nema17_mount(reverse=-1, shaft2_l=30);
    translate([GANTRY_W/2, 0, 0])
        rotate([0, 90, 0])
        gantry_assm();
    translate([
            0, -t20_w/2, 
            gplate_w/2 + t20_w/2])
        rotate([90, 0, 0])
        rotate([0, 90, 0])
        v2040(BEAM_L);

    translate([
            x_pos, -3*t20_w/2, 
            gplate_w/2 +t20_w/2])
        rotate([90, 0, 180])
        gantry_assm();
    % translate([0, 0, gplate_w/2 + t20_w + nema17_mount_c_h])
        rotate([0, 90, 0])
        cylinder(h=BEAM_L, r=4, center=true, $fn=20);
    // % translate([0, 0, gplate_w/2 + t20_w + nema17_mount_c_h])
    //     rotate([90, 0, 0])
    //     kp08();
    translate([300, 0, gplate_w/2 + nema17_mount_c_h + t20_w])
        gantry_bearing_holder();
    translate([-300, 0, gplate_w/2 + nema17_mount_c_h + t20_w])
        gantry_bearing_holder();
}

// ! gantry();

module bearing_cap() {
    difference() {
        translate([5, 0, 0])
            cube([4, 42, 42], center=true);
        // nema17_mount(shaft2_l=22);
        nema17_mount_holes();
    }
}

// ! bearing_cap();

module gantry_bearing_holder() {
    % translate([0, t20_w + 5 + 2, -nema17_mount_c_h + 10])
        t20(100);
    difference() {
        union() {
            translate([
                    -t20_w/2, 
                    t20_w/2 + 5, 
                    -nema17_mount_c_h -t20_w*2])
                cube([t20_w, 2, 100]);
            translate([
                    -t20_w/2, t20_w/2, 
                    -nema17_mount_c_h -t20_w*2])
                cube([t20_w, 5, 2*t20_w]);
        }
        translate([0, 0, -nema17_mount_c_h -3*t20_w/2])
            rotate([90, 0, 0])
            cylinder(r=5/2, h=20, center=true);
        translate([0, 0, -nema17_mount_c_h -t20_w/2])
            rotate([90, 0, 0])
            cylinder(r=5/2, h=20, center=true);

        *% translate([
                200/2 - nema17_mount_flange_h, 
                0, 
                0])
            rotate([0, 0, 0])
                nema17_mount(reverse=-1, shaft2_l=30);
        
        rotate([0, 90, 0])
            cylinder(h=200, r=4, center=true, $fn=20);
        rotate([90, 0, 0]) {
            # kp08();
            translate([0, 0, -10])
                kp08_holes(h=20);
        }
        % translate([
                0, -t20_w/2, 
                -gplate_w/2*0 - nema17_mount_c_h -t20_w/2])
            rotate([90, 0, 0])
            rotate([0, 90, 0])
            v2040(200);

        // # translate([0, 0, t20_w + nema17_mount_c_h])
        //     rotate([90, 0, 0])
            
    }
}

// ! gantry_bearing_holder();

module design() {
    % translate([0, 0, -TABLE_LIFT]) {
        table();
        tabletop();
    }
    frame();
    translate([0, y_pos, 0])
        gantry();
}

design();
