// ONE printed adapter: docking insert + over-front bridge + Odin cradle.
// Original parametric construction from reference measurements; no mesh import.
part="adapter"; // [adapter,assembled,placement,cable_check,dock_clearance_check,device_clearance_check]
$fn=64;
// Measured reference datums from user-supplied v14 STL (millimeters).
reference_insert_width=200;
reference_depth_envelope=14.3;
insertion_height=50;
flange_width=230;
flange_height=10;
insert_width_clearance=1.0;
insert_depth_clearance=.5;
insert_width=reference_insert_width-insert_width_clearance;
insert_depth=reference_depth_envelope-insert_depth_clearance;
entry_chamfer=1;
foot_height=1;
foot_x=95; // measured lower contact centers in supplied reference
foot_y=3.18;
foot_width=2;
foot_depth=5;
// Official AYN body dimensions; TPU allowance is an estimate.
odin_width=257;
odin_height=98.6;
odin_thickness=17.2;
tpu_per_face=3;
fit_clearance=2;
seat_gap=odin_thickness+2*tpu_per_face+fit_clearance;
tilt=15;
seat_y=-70; // NEGATIVE Y is in front of the Nintendo dock.
seat_height=62; // relative to reference insert bottom, NOT desk height
support_width=160;
seat_floor=5;
front_lip=10;
contact_wall=4;
rail_width=18;
rail_offset=58;
rear_contact_height=40;
// Generous silicone-adjusted female and male housing pockets.
female_center_y=-1.8; // reference central rounded bore center after upright rotation
female_width=22;
female_depth=14;
female_height=30;
male_width=22;
male_depth=14;
male_height=29;
housing_wall=3;
housing_floor=3;
wire_diameter_allowance=8;
wire_outlet=9;
usb_access_width=36;
bridge_front=-51;
bridge_bottom=insertion_height+4;
bridge_height=10;
cable_bend_radius=20;
front_bend_radius=12;
channel_width=10;
channel_floor=2;
cable_z=bridge_bottom+channel_floor+wire_diameter_allowance/2;
mid=seat_gap/2;
holder_height=male_height+housing_floor;
eps=.02;
assert(insert_width<reference_insert_width);
assert(insert_depth<reference_depth_envelope);
assert(insert_depth>female_depth/2+abs(female_center_y));
assert(seat_gap>odin_thickness);
assert(usb_access_width>male_width+2*housing_wall);
assert(bridge_bottom>insertion_height);
assert(bridge_height>=wire_diameter_allowance+channel_floor);
assert(female_height<cable_z-cable_bend_radius);
module box(pos,size){translate(pos)cube(size);}
module seated(){translate([0,seat_y,seat_height])rotate([-tilt,0,0])children();}
module print_pose(){translate([0,0,insert_depth/2])rotate([-90,0,0])children();}
module dock_insert_solid(){
 union(){
  hull(){
   box([-insert_width/2+entry_chamfer,-insert_depth/2+entry_chamfer,0],[insert_width-2*entry_chamfer,insert_depth-2*entry_chamfer,eps]);
   box([-insert_width/2,-insert_depth/2,entry_chamfer],[insert_width,insert_depth,eps]);
  }
  box([-insert_width/2,-insert_depth/2,entry_chamfer],[insert_width,insert_depth,insertion_height-entry_chamfer+eps]);
  box([-flange_width/2,-insert_depth/2,insertion_height],[flange_width,insert_depth,flange_height]);
  for(x=[-foot_x,foot_x])box([x-foot_width/2,foot_y-foot_depth/2,-foot_height],[foot_width,foot_depth,foot_height+eps]);
 }
}
module cradle_solid(){
 seated()union(){
  difference(){
   union(){
    box([-support_width/2,-contact_wall,-seat_floor],[support_width,seat_gap+2*contact_wall,seat_floor]);
    box([-support_width/2,-contact_wall,-seat_floor],[support_width,contact_wall,seat_floor+front_lip]);
    for(x=[-rail_offset,rail_offset])box([x-rail_width/2,seat_gap,-seat_floor],[rail_width,5,rear_contact_height+seat_floor]);
   }
   box([-usb_access_width/2,-contact_wall-2,-seat_floor-1],[usb_access_width,seat_gap+2*contact_wall+4,rear_contact_height+seat_floor+5]);
  }
  // Fused tabs overlap shelf by 2 mm; integral pocket, NO mounting hardware.
  box([-28,mid-10,-8],[56,20,5]);
  box([-(male_width+2*housing_wall)/2,mid-(male_depth+2*housing_wall)/2,-holder_height],[male_width+2*housing_wall,male_depth+2*housing_wall,holder_height]);
 }
}
module bridge_solid(){
 box([-support_width/2,bridge_front,bridge_bottom],[support_width,insert_depth/2-bridge_front,bridge_height]);
 for(x=[-rail_offset,rail_offset])hull(){
  seated()box([x-rail_width/2,seat_gap,-seat_floor],[rail_width,5,14]);
  box([x-rail_width/2,bridge_front+3,bridge_bottom],[rail_width,13,bridge_height]);
 }
}
module cable_cut(){
 // Female housing loads from bottom/front; align socket with dock plug before curing.
 box([-female_width/2,female_center_y-female_depth/2,-eps],[female_width,female_depth,female_height+eps]);
 // Front-open vertical trough permits laying in cable without threading plugs.
 box([-channel_width/2,-insert_depth/2-1,female_height-1],[channel_width,insert_depth/2+1+female_center_y+wire_diameter_allowance/2,cable_z-female_height+4]);
 // Smooth 20 mm-radius emergence above the dock lip.
 for(theta=[0:5:85])hull()for(t=[theta,theta+5])translate([0,female_center_y-cable_bend_radius+cable_bend_radius*cos(t),cable_z-cable_bend_radius+cable_bend_radius*sin(t)])sphere(d=wire_diameter_allowance,$fn=32);
 // Exit notch through bridge floor for the downward slack loop.
 box([-channel_width/2,bridge_front-2,bridge_bottom-10],[channel_width,front_bend_radius+10,bridge_height+11]);
 // Top-open horizontal trough to front cradle.
 box([-channel_width/2,bridge_front-2,bridge_bottom+channel_floor],[channel_width,insert_depth/2-bridge_front+3,bridge_height+5]);
 seated(){
  box([-male_width/2,mid-male_depth/2,-male_height],[male_width,male_depth,male_height+eps]);
  translate([0,mid,-holder_height-eps])cylinder(d=wire_outlet,h=housing_floor+2*eps);
  box([-5,mid+male_depth/2-1,-holder_height-eps],[10,housing_wall+2,holder_height+2*eps]);
 }
}
module device_clearance(){seated()box([-odin_width/2,0,0],[odin_width,seat_gap,odin_height+6]);}
// Exclude the intentional seating-contact plane by 0.02 mm in collision check.
module device_envelope(){seated()box([-odin_width/2,1,eps],[odin_width,seat_gap-2,odin_height+6-eps]);}
module adapter_assembled(){difference(){union(){dock_insert_solid();bridge_solid();cradle_solid();}cable_cut();device_clearance();}}
module cable_reference(){
 translate([0,female_center_y,27])cylinder(d=6,h=cable_z-cable_bend_radius-27);
 for(theta=[0:5:85])hull()for(t=[theta,theta+5])translate([0,female_center_y-cable_bend_radius+cable_bend_radius*cos(t),cable_z-cable_bend_radius+cable_bend_radius*sin(t)])sphere(d=6,$fn=20);
 hull()for(y=[female_center_y-cable_bend_radius,bridge_front+4+front_bend_radius])translate([0,y,cable_z])sphere(d=6,$fn=20);
 for(theta=[0:5:85])hull()for(t=[theta,theta+5])translate([0,bridge_front+4+front_bend_radius-front_bend_radius*sin(t),cable_z-front_bend_radius+front_bend_radius*cos(t)])sphere(d=6,$fn=20);
 // Accessible slack loop below cradle, with a smooth return into male outlet.
 outlet=[0,seat_y+mid*cos(tilt)-holder_height*sin(tilt),seat_height-mid*sin(tilt)-holder_height*cos(tilt)];
 direction=[0,sin(tilt),cos(tilt)];
 approach=outlet-8*direction;
 column_y=bridge_front+4;
 center_y=(column_y+approach[1])/2;
 radius=(column_y-approach[1])/2;
 hull()for(z=[cable_z-front_bend_radius,approach[2]])translate([0,column_y,z])sphere(d=6,$fn=20);
 for(theta=[0:10:170])hull()for(t=[theta,theta+10])translate([0,center_y+radius*cos(t),approach[2]-radius*sin(t)])sphere(d=6,$fn=20);
 hull()for(p=[approach,outlet+4*direction])translate(p)sphere(d=6,$fn=20);
}
module illustrative_dock(){
 // Wall envelopes for clearance checks, NOT a measured whole Nintendo dock.
 box([-100,-25,-55],[200,17,insertion_height+55]);
 box([-100,8,-55],[200,18,insertion_height+55]);
}
if(part=="adapter")print_pose()adapter_assembled();
else if(part=="assembled")adapter_assembled();
else if(part=="placement"){
 color([.3,.48,.6])adapter_assembled();
 %illustrative_dock();
 %device_envelope();
 %color([1,.5,.1])cable_reference();
}
else if(part=="cable_check")intersection(){adapter_assembled();cable_reference();}
else if(part=="dock_clearance_check")intersection(){adapter_assembled();illustrative_dock();}
else if(part=="device_clearance_check")intersection(){adapter_assembled();device_envelope();}
else assert(false,"Unknown part selector");
