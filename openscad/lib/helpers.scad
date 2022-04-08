draft_angle = 2;

module draft_cube(dims, center=false, draft_angle=draft_angle, invert=false) {
    translate(center ? [0, 0, 0] : dims/2)
        rotate(invert ? [180, 0, 0] : [0, 0, 0])
        _draft_cube(dims, draft_angle=draft_angle);
    
}

module _draft_cube(dims, draft_angle=draft_angle) {
    draft_dims = [
        dims[0] - dims[2] * sin(draft_angle),
        dims[1] - dims[2] * sin(draft_angle),
        dims[2]];
    hull() {
        translate([0,0,-dims[2]/2])
        cube([dims[0], dims[1], .1], center = true);
        translate([0,0,dims[2]/2])
            cube([draft_dims[0], draft_dims[1], .1], center = true);
    }
}

module draft_cylinder(r=1, h=1, center=false, draft_angle=draft_angle, invert=false, fn=1000, face_draft=0) {
    if (!center) {
        translate([0, 0, h/2])
        _draft_cylinder(r=r, h=h, draft_angle=draft_angle, invert=invert, fn=fn, face_draft=face_draft);
    } else {
        _draft_cylinder(r=r, h=h, draft_angle=draft_angle, invert=invert, fn=fn, face_draft=face_draft);
    }
}

module _draft_cylinder(r=1, h=1, draft_angle=draft_angle, invert=false, fn=1000, face_draft=0) {
    draft_r = r - h * sin(draft_angle);
    draft_h = h + 2*abs(r * sin(face_draft));
    // echo(draft_angle=draft_angle, face_draft=face_draft, h=h, draft_h=draft_h, r=r, draft_r=draft_r);
    intersection() {
        rotate([invert ? 180 : 0, 0, 0])
           cylinder(r1=r, r2=draft_r, h=draft_h, center=true, $fn=min(fn, 8*r));
        if (face_draft != 0) 
            rotate([-90, 0, 0])
            draft_cube([3*r, h, 3*r], center=true, draft_angle=face_draft);
    }
}
