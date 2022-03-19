include <lib/t20beam.scad>;
include <lib/metric.scad>;
// include <lib/motion_hardware.scad>;
include <lib/stepper.scad>;
use <lib/lib_pulley.scad>;

bearing_h = 7;
bearing_ir = 4;
bearing_or = 11;
module bearing(clr=0) {
    difference() {
        cylinder(r=bearing_or + clr, h=bearing_h, center=true, $fn=fn()*2);
        cylinder(r=bearing_ir, h=bearing_h*2, center=true);
    }
}

// module drive_pulley_40t(bore=9.5, height=6) {
//     gt2_pulley(40, bore, pulley_t_ht=height, pulley_b_ht=0, pulley_b_dia=0, no_of_nuts=0, nut_t08_screw_distance=0);
// }

motor_coupler_length = 25;
motor_coupler_small_id = 5;
motor_coupler_large_id = 8;
motor_coupler_od = 19;
motor_coupler_large_depth = 18;
motor_coupler_grub_ir = 4 / 2;
motor_coupler_grub_c_c = 17;
motor_coupler_grub_theta = 72; // Unclear from measuring, somewhere 70 <= x < 75, I think

module motor_coupler() {
    color("silver") difference() {
        cylinder(r=motor_coupler_od/2, h=motor_coupler_length);
        cylinder(r=motor_coupler_small_id/2, h=motor_coupler_length);
        cylinder(r=motor_coupler_large_id/2, h=motor_coupler_large_depth);
        motor_coupler_holes();
    }
}

module motor_coupler_holes() {
    for (t=[0, motor_coupler_grub_theta]) {
        for (z=[-1, 1]) {
            rotate([0, 0, t])
            translate([0, 0, motor_coupler_length/2 + z * motor_coupler_grub_c_c/2])
            rotate([0, 90, 0])
            cylinder(r=motor_coupler_grub_ir, h=motor_coupler_od);

        }
    }
}

BEAM_L = 200; // 500;
LEG_L = 70;

roller_or = bearing_or + bearing_h/2;

// TODO: mathematically compute 
bearing_rail_offs = bearing_or + 1;

xstage_w = 65;
xstage_h = 100;
xstage_dz = 20;
xstage_plate_w = 85;
gantry_dz = 50;
stage_plate_th = 2;
stage_plate_gap = 25;

corner_plate_th = 2;

spacer_h = (stage_plate_gap - bearing_h) / 2;


x_beam = BEAM_L + t20_w;
y_beam = BEAM_L - stage_plate_gap;

min_x = 50;
max_x = 100;

min_y = 50;
max_y = 100;

echo(spacer_h=spacer_h);

function fn() = $preview ? 16 : 64;

function stage_position() = [min_x + (sin($t * 180) * (max_x - min_x)), min_y + (sin($t * 180) * (max_y - min_y))];

module frame() {
    for (z=[-t20_w/2, -3*t20_w/2]) {
        for (dx=[0, x_beam]) {
            translate([dx, y_beam/2 + t20_w/2, z])
                rotate([90, 0, 0])
                t20(BEAM_L);
        }
        for (dy=[0, y_beam - stage_plate_th - stage_plate_gap/2 + t20_w/2]) {
            translate([BEAM_L/2 + t20_w/2, dy, z])
                rotate([0, 90, 0])
                t20(BEAM_L);
        }
        // for (offs2=[0, BEAM_L + t20_w]) {
        //     translate([offs, offs2, -LEG_L/2]) {
        //         t20(LEG_L);
        //     }
        // }
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
        cylinder(r=4, h=7, center=true, $fn=2*fn());
        cylinder(r=3, h=20, center=true, $fn=fn());
    }
}

// ! bushing68();

module spacer() {

    // difference() {
    //     cylinder(r=5, h=spacer_h, center=true, $fn=6);
    //     cylinder(r=3, h=20, center=true, $fn=fn());
    // }
    m6_nut(core=true, h=spacer_h);
}

// ! spacer();

module roller() {
    difference() {
        union() {
            rotate_extrude($fn=2*fn()) {
                translate([bearing_or, 0, 0])
                    circle(r=bearing_h/2, $fn=fn());
            }
            // cylinder(r=bearing_or, h=bearing_h+2, center=true);
        }
        # bearing();
        # bushing68();
        # for (dz=[-bearing_h/2 - spacer_h/2, bearing_h/2 + spacer_h/2])
            translate([0, 0, dz])
            spacer();
    }
}

// ! roller();

module reinforced_hole_mask(ir=5, delta_or=5, mask_r=5) {
    intersection() {
        rotate_extrude() {
            translate([ir + mask_r, 0, 0])
                circle(r=mask_r);
        }
        translate([0, 0, -0.01])
            cylinder(r=ir + delta_or, h=bearing_h*2);
    }
}

// ! reinforced_hole_mask();

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
            cylinder(r=bearing_or, h=100, center=true, $fn=2*fn());
    }

    for (dx=[-xstage_w/2, xstage_w/2])
        translate([dx, (stage_plate_gap - t20_w)/4 + stage_plate_th/2, 30]) {
            rotate([90, 0, 0])
                cylinder(r=5/2, h=50, center=true);
    }

    translate([0, -stage_plate_gap/2 - stage_plate_th + bearing_h, xstage_dz])
        rotate([90, 0, 0])
            reinforced_hole_mask(
                ir=bearing_or + stage_plate_th, 
                delta_or=bearing_h, 
                mask_r=bearing_h-stage_plate_th);
    translate([0, -10, -25])
        rotate([90, 0, 0])
        cylinder(r=25, h=20, center=true);
}

module xstage_plate_base() {
    translate([0, 0, -10])
        cube([xstage_plate_w, stage_plate_th, xstage_h], center=true);
    translate([0, bearing_h/2 - stage_plate_th/2, xstage_dz])
        rotate([90, 0, 0])
        cylinder(r=bearing_or + bearing_h, h=bearing_h, center=true, $fn=fn());
}

// ! xstage_plate_base();

module xstage_flush_mask() {
    translate([-25, stage_plate_th/2, 0])
        cube([50, 50, 39]);
}

module xstage_center_mask() {
    translate([0, 0, gantry_dz + t20_w/2])
        cube([4*t20_w, t20_w, 2*t20_w + 0.01], center=true);
}

module xstage_center_motor_mask() {
    translate([0, 0, gantry_dz + t20_w/2])
        cube([100, t20_w, 40], center=true);
}

module xstage_motor_plate() {
   difference() {
        xstage_plate_base();
        translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])
            xstage_plate_base_holes();
        xstage_flush_mask();
    } 
}

// ! xstage_motor_plate();

// module xstage_antimotor_plate() {
//    // difference() {
//    //      xstage_plate_base();
//    //      translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])
//    //          xstage_plate_base_holes();
//    //      // xstage_center_mask();
//    //  } 
//     mirror([0, 1, 0])
//         xstage_motor_plate();
// }

// ! xstage_antimotor_plate();

// module xstage_center_motor_plate() {
//    difference() {
//         xstage_plate_base();
//         translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])
//             xstage_plate_base_holes();
//         xstage_flush_mask();
//         xstage_center_motor_mask();
//     } 
// }

// ! xstage_center_motor_plate();

// module xstage_bearing_mask() {
//     translate([0, 0, gantry_dz + t20_w/2])
//         cube([4*t20_w, t20_w, 55], center=true);
//     translate([30, -30, 15])
//         rotate([0, -50, 0])
//         cube([60, 60, 60]);
//     translate([-30, -30, 15])
//         rotate([0, -40, 0])
//         cube([60, 60, 60]);
// }

module xstage_bearing_plate() {
   difference() {
        xstage_plate_base();
        translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])
            xstage_plate_base_holes();
        // xstage_bearing_mask();
        // # xstage_bearing_mask();
    } 
}

// ! xstage_bearing_plate();

module xstage_motorside() {
    translate([0, -stage_plate_gap/2 - stage_plate_th/2, 0])
        xstage_motor_plate();
    translate([0, stage_plate_gap/2 + stage_plate_th/2, 0])    
        xstage_motor_plate();

    for (z=[bearing_rail_offs, -2*t20_w - bearing_rail_offs]) {
        for (x=[-xstage_w/2, xstage_w/2])
            translate([x, 0, z])
            rotate([90, 0, 0])
            roller();
    }

    % translate([0, -stage_plate_gap/2, xstage_dz])
        rotate([-90, 0, 0]) 
        pulley_20t();
    % translate([0, 3, xstage_dz])
        rotate([-90, 0, 0]) 
        motor_coupler();
    % translate([
            xstage_w/2, 
            -stage_plate_gap/2 - t20_w/2 - stage_plate_th, 
            15])
        t20(150);
    
    % for (z=[-t20_w/2, -t20_w/2 - t20_w])
        translate([0, 0, z])
        rotate([0, 90, 0])
        t20(xstage_plate_w + roller_or);
    % translate([0, -stage_plate_gap/2 - stage_plate_th/2, xstage_dz])
        rotate([90, 0, 0])
            motor(model=Nema17);
}

// ! xstage_motorside();

module xstage_idleside() {
    // translate([0, BEAM_L + t20_w + -stage_plate_gap/2 - stage_plate_th/2, 0])
    translate([
            0, 
            BEAM_L -3*stage_plate_gap/2 - 3*stage_plate_th, 
            0])
        rotate([0, 0, 180])
        xstage_bearing_plate();
    // translate([0, BEAM_L + t20_w + stage_plate_gap/2 + stage_plate_th/2, 0])
    # translate([
            0, 
            BEAM_L -stage_plate_gap/2 - 2*stage_plate_th, 
            0])
        xstage_bearing_plate();
        // xstage_antimotor_plate();
}

// ! xstage_idleside();

module xstage_linkage() {
    % translate([
            xstage_w/2, 
            y_beam + t20_w, 
            15])
        // t20(2 * t20_w);
        // % translate([
        //     xstage_w/2, 
        //     -stage_plate_gap/2 - t20_w/2 - stage_plate_th, 
        //     15])
        t20(150);
    % for (z=[0, t20_w])
        translate([xstage_w/2, BEAM_L/2 + -stage_plate_gap/2 - stage_plate_th, gantry_dz + z])
        rotate([90, 0, 0])
        t20(BEAM_L);
    % translate([0, 20, xstage_dz])
        rotate([-90, 0, 0]) 
        cylinder(r=4, h=BEAM_L);
}

module xstage() {
    xstage_motorside();
    xstage_idleside();
    xstage_linkage();
}

// ! xstage();

module ystage_motor_mask() {
    translate([0, 0, 64])
        cube([70, 10, 50], center=true);

}

module ystage_laser_plate() {
    difference() {
        union() {
            xstage_center_motor_plate();
            translate([0, 0, -30])
                cube([20, stage_plate_th, 50], center=true);
        }
        // # ystage_laser_mask();
        for (z=[5:-15:-90])
            translate([0, 0, z])
            rotate([90, 0, 0])
            cylinder(r=3/2, h=10, center=true);
    }
}

// ! ystage_laser_plate();

module ystage_motor_plate() {
    difference() {
        xstage_motor_plate();
        ystage_motor_mask();
    }
}

module ystage() {
    translate([t20_w + stage_plate_gap/2 + stage_plate_th/2, 0, gantry_dz + 3/2 * t20_w])
        rotate([0, 0, 90])
        ystage_laser_plate();
    translate([t20_w -stage_plate_gap/2 + -stage_plate_th/2, 0, gantry_dz + 3/2 * t20_w])
        rotate([0, 0, -90])
        ystage_motor_plate();
        
    for (z=[bearing_rail_offs, -2*t20_w - bearing_rail_offs]) {
        for (y=[-xstage_w/2, xstage_w/2])
            translate([t20_w, y, z + gantry_dz + 3/2*t20_w])
            rotate([0, 90, 0])
            roller();
    }

    % translate([t20_w -stage_plate_gap/2 - stage_plate_th/2, 0, gantry_dz + xstage_dz + 3/2*t20_w])
        rotate([0, -90, 0])
            motor(model=Nema17);
    translate([t20_w - 11 , 0, gantry_dz + xstage_dz + 3/2*t20_w])
        rotate([0, 90, 0]) 
        pulley_20t();

}

// ! ystage();

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

module pulley_20t() {
    gt2_pulley(20, 5, pulley_t_ht=9, pulley_b_ht=7, pulley_b_dia=16, no_of_nuts=0, nut_shaft_distance=3);
}

module laser_holes() {
    for (dz=[10, 35, 60])
        for (dx=[-xstage_w/2, xstage_w/2])
        translate([dx, 0, dz])
        rotate([90, 0, 0])
        cylinder(r=5/2, h=20, center=true);
    
    for (dz=[10, 50])
        for (dx=[-10, 10])
        translate([dx, 0, dz])
        rotate([90, 0, 0])
        cylinder(r=3/2, h=20, center=true);
    for (dz=[22, 34, 63])
        translate([0, 0, dz])
        rotate([90, 0, 0])
        cylinder(r=3/2, h=20, center=true);
}

module laser_plate() {
    difference() {
        cube([xstage_plate_w, stage_plate_th, 70], center=true);
        # translate([0, 0, -35])
            laser_holes();
    }
}

! laser_plate();

// ! pulley_20t();

module design() {
    frame();
    translate([stage_position()[0], 0, 0]) {
        xstage();
        translate([0, stage_position()[1], 0]) {
            ystage();
        }
        
    }
}

design();
