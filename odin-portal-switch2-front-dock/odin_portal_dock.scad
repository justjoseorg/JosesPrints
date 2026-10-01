// Original companion cradle for the user's existing modified dock insert.
// Units: mm. Official Odin dimensions are not a measured TPU/connector drawing.
part = "layout"; // [stand,carrier,gauge,assembled,layout,placement,collision_check]
$fn = 64;

// Official AYN Odin 2 Portal dimensions (current specification image).
odin_width = 257;
odin_height = 98.6;
odin_thickness = 17.2;
// TPU allowance is an estimate, NOT an AYN-published grip measurement.
tpu_per_face = 3;
fit_allowance = 2;
seat_gap = odin_thickness + 2*tpu_per_face + fit_allowance;
tilt = 15; // rearward lean from vertical
seat_height = 65;
seat_y = 18;
support_width = 160;
seat_floor = 5;
front_lip_height = 10;
contact_wall = 4;
rear_rail_height = 43;
rail_width = 16;
rail_offset = 58;

base_width = 190;
base_depth = 180;
base_height = 8;
base_corner = 4;
cable_channel_width = 12;
cable_channel_depth = 6;
cable_channel_start = 65;
foot_radius = 5;
foot_recess = 1;

// Oversized male housing cavity for adjustable neutral-cure silicone bedding.
pocket_width = 22;
pocket_depth = 14;
pocket_height = 29;
carrier_wall = 3;
carrier_bottom = 3;
wire_outlet = 9;
loading_slit = 10;
usb_access_width = 36;
carrier_flange_width = 56;
carrier_flange_depth = 20;
carrier_flange_thickness = 3;
mount_pitch = 46;
mount_hole = 3.4;
mount_travel = 10;
head_clearance = 6.4;
head_recess = 2;
mid = seat_gap/2;
carrier_outer_width = pocket_width + 2*carrier_wall;
carrier_outer_depth = pocket_depth + 2*carrier_wall;
carrier_height = pocket_height + carrier_bottom;
eps = 0.02;

assert(seat_gap > odin_thickness);
assert(base_height > cable_channel_depth);
assert(usb_access_width > carrier_outer_width);
assert(carrier_flange_width > mount_pitch + mount_hole);
assert(seat_floor > head_recess);
assert(pocket_depth > wire_outlet);
assert(base_width > support_width);

module box(pos,size) { translate(pos) cube(size); }
module posed() { translate([0,seat_y,seat_height]) rotate([-tilt,0,0]) children(); }
module slot(length,diameter,height) {
    hull() for(y=[-(length-diameter)/2,(length-diameter)/2])
        translate([0,y,0]) cylinder(d=diameter,h=height);
}
module yz_beam(x,points,width) {
    translate([x,0,0])
        multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
        linear_extrude(height=width) polygon(points);
}
module local_seat() {
    difference() {
        union() {
            box([-support_width/2,-contact_wall,-seat_floor],
                [support_width,seat_gap+2*contact_wall,seat_floor]);
            box([-support_width/2,-contact_wall,-seat_floor],
                [support_width,contact_wall,seat_floor+front_lip_height]);
            for(x=[-rail_offset,rail_offset])
                box([x-rail_width/2,seat_gap,-seat_floor],
                    [rail_width,5,seat_floor+rear_rail_height]);
        }
        box([-usb_access_width/2,-contact_wall-2,-seat_floor-5],
            [usb_access_width,seat_gap+2*contact_wall+4,rear_rail_height+20]);
        for(x=[-mount_pitch/2,mount_pitch/2]) {
            translate([x,mid,-seat_floor-5])
                slot(mount_travel+mount_hole,mount_hole,seat_floor+10);
            translate([x,mid,-head_recess])
                slot(mount_travel+head_clearance,head_clearance,head_recess+eps);
        }
    }
}
module platform() {
    difference() {
        translate([0,base_depth/2,0]) linear_extrude(height=base_height)
            offset(r=base_corner) square([base_width-2*base_corner,base_depth-2*base_corner],center=true);
        box([-cable_channel_width/2,cable_channel_start,base_height-cable_channel_depth],
            [cable_channel_width,base_depth-cable_channel_start+eps,cable_channel_depth+eps]);
        for(x=[-base_width/2+15,base_width/2-15],y=[12,base_depth-15])
            translate([x,y,-eps]) cylinder(r=foot_radius,h=foot_recess+eps);
    }
}
module stand() {
    yf=seat_y+cos(tilt)*(-contact_wall)+sin(tilt)*(-seat_floor);
    zf=seat_height-sin(tilt)*(-contact_wall)+cos(tilt)*(-seat_floor);
    yb=seat_y+cos(tilt)*(seat_gap+5)+sin(tilt)*(-seat_floor);
    zb=seat_height-sin(tilt)*(seat_gap+5)+cos(tilt)*(-seat_floor);
    union() {
        platform();
        posed() local_seat();
        for(x=[-rail_offset-rail_width/2,rail_offset-rail_width/2])
            difference() {
                yz_beam(x,[[5,5],[80,5],[yb+1,zb+1],[yf-1,zf+1]],rail_width);
                yz_beam(x-1,[[20,15],[63,15],[33,43]],rail_width+2);
            }
    }
}
module carrier_local() {
    difference() {
        union() {
            box([-carrier_outer_width/2,mid-carrier_outer_depth/2,-carrier_height],
                [carrier_outer_width,carrier_outer_depth,carrier_height]);
            box([-carrier_flange_width/2,mid-carrier_flange_depth/2,-seat_floor-carrier_flange_thickness],
                [carrier_flange_width,carrier_flange_depth,carrier_flange_thickness]);
        }
        box([-pocket_width/2,mid-pocket_depth/2,-pocket_height],
            [pocket_width,pocket_depth,pocket_height+eps]);
        translate([0,mid,-carrier_height-eps]) cylinder(d=wire_outlet,h=carrier_bottom+2*eps);
        box([-loading_slit/2,mid+pocket_depth/2-1,-carrier_height-eps],
            [loading_slit,carrier_wall+2,carrier_height+2*eps]);
        for(x=[-mount_pitch/2,mount_pitch/2])
            translate([x,mid,-seat_floor-carrier_flange_thickness-eps])
                cylinder(d=mount_hole,h=carrier_flange_thickness+2*eps);
    }
}
module carrier_print() {
    translate([0,carrier_outer_depth/2-mid,carrier_height]) carrier_local();
}
module gauge() {
    difference() {
        union() {
            box([-40,-contact_wall,0],[80,seat_gap+2*contact_wall,3]);
            box([-40,-contact_wall,0],[80,contact_wall,10]);
            box([-40,seat_gap,0],[80,contact_wall,10]);
        }
        box([-pocket_width/2,mid-pocket_depth/2,-eps],[pocket_width,pocket_depth,11]);
        box([-loading_slit/2,mid+pocket_depth/2-1,-eps],[loading_slit,seat_gap+10,11]);
    }
}
module assembled() {
    color([.22,.32,.42]) stand();
    color([1,.42,.12]) posed() carrier_local();
}
module layout() {
    color([.22,.32,.42]) stand();
    translate([base_width/2+40,0,0]) color([1,.42,.12]) carrier_print();
    translate([base_width/2+60,60,0]) color([.3,.6,.7]) gauge();
}
module placement() {
    assembled();
    // Background boxes are ILLUSTRATIVE; dock dimensions are NOT verified.
    %posed() box([-odin_width/2,1,0],[odin_width,seat_gap-2,odin_height+6]);
    %box([-100,100,base_height],[200,65,110]);
}
if(part=="stand") stand();
else if(part=="carrier") carrier_print();
else if(part=="gauge") gauge();
else if(part=="assembled") assembled();
else if(part=="layout") layout();
else if(part=="placement") placement();
else if(part=="collision_check") intersection() { stand(); posed() carrier_local(); }
else assert(false,"Unknown part selector");
