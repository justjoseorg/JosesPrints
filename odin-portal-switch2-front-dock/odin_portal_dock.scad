// ONE print: dock insert, RIGHT-SIDE cable exit/link, low tabletop Odin cradle.
// Reference measured for datums only; no imported/redistributed mesh.
part="adapter"; // [adapter,assembled,placement,cable_check,dock_clearance_check,device_clearance_check,table_check,cable_device_check,cable_dock_check]
$fn=48;
reference_insert_width=200;
reference_depth_envelope=14.3;
insertion_height=50;
flange_width=230;
flange_height=10;
insert_width_clearance=1;
insert_depth_clearance=.5;
insert_width=reference_insert_width-insert_width_clearance;
insert_depth=reference_depth_envelope-insert_depth_clearance;
entry_chamfer=1;
foot_height=1;
foot_x=95;
foot_y=3.18;
foot_width=2;
foot_depth=5;
// Official dimensions; overall dock height is only a seating-height proxy.
dock_height=115;
dock_width=201;
dock_depth=51.2;
seating_stop_to_table=115;
tabletop_z=insertion_height-seating_stop_to_table;
odin_width=257;
odin_height=98.6;
odin_thickness=17.2;
tpu_per_face=3;
fit_clearance=2;
seat_gap=odin_thickness+2*tpu_per_face+fit_clearance;
tilt=15;
seat_y=-70;
seat_above_table=55;
seat_height=tabletop_z+seat_above_table;
support_width=160;
seat_floor=5;
front_lip=10;
contact_wall=4;
rail_width=18;
rail_offset=58;
rear_contact_height=36;
front_base_width=180;
front_base_front=-88;
front_base_rear=-32;
front_base_thickness=6;
front_base_corner=4;
// Narrow side link stays OUTSIDE the official 201 mm-wide dock envelope.
side_column_x=112;
side_arm_inner_x=104;
side_arm_width=8;
side_arm_depth=16;
side_foot_width=12;
side_foot_front=-48;
side_foot_rear=6;
// Connector housings bedded in electronics-safe neutral-cure silicone.
female_center_y=-1.8;
female_width=22;
female_depth=14;
female_height=30;
male_width=22;
male_depth=14;
male_height=29;
housing_wall=3;
housing_floor=3;
wire_outlet=9;
wire_diameter_allowance=8;
usb_access_width=36;
channel_width=10;
side_exit_height=55; // same reference height as its existing right-side exit
cable_bend_radius=12;
mid=seat_gap/2;
holder_height=male_height+housing_floor;
outlet=[0,seat_y+mid*cos(tilt)-holder_height*sin(tilt),seat_height-mid*sin(tilt)-holder_height*cos(tilt)];
lead_dir=[0,sin(tilt),cos(tilt)];
return_y=outlet[1]-cable_bend_radius*sin(tilt);
return_z=outlet[2]-cable_bend_radius*cos(tilt);
eps=.02;
assert(side_arm_inner_x>dock_width/2);
assert(side_foot_rear<insert_depth/2);
assert(front_base_rear < -dock_depth/2);
assert(usb_access_width>male_width+2*housing_wall);
assert(side_exit_height-cable_bend_radius>female_height);
assert(return_z-wire_diameter_allowance/2>tabletop_z+2);
module box(pos,size){translate(pos)cube(size);}
module seated(){translate([0,seat_y,seat_height])rotate([-tilt,0,0])children();}
module print_pose(){translate([0,0,insert_depth/2])rotate([-90,0,0])children();}
module ball(p,d){translate(p)sphere(d=d,$fn=16);}
module link(a,b,d){hull(){ball(a,d);ball(b,d);}}
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
  box([-28,mid-10,-8],[56,20,5]);
  box([-(male_width+2*housing_wall)/2,mid-(male_depth+2*housing_wall)/2,-holder_height],[male_width+2*housing_wall,male_depth+2*housing_wall,holder_height]);
 }
}
module yz_frame(x,points,width){
 translate([x,0,0])multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])linear_extrude(height=width)polygon(points);
}
module tabletop_support(){
 translate([0,(front_base_front+front_base_rear)/2,tabletop_z])linear_extrude(height=front_base_thickness)
  offset(r=front_base_corner)square([front_base_width-2*front_base_corner,front_base_rear-front_base_front-2*front_base_corner],center=true);
 yf=seat_y-contact_wall*cos(tilt)-seat_floor*sin(tilt);
 zf=seat_height+contact_wall*sin(tilt)-seat_floor*cos(tilt);
 yb=seat_y+(seat_gap+5)*cos(tilt)-seat_floor*sin(tilt);
 zb=seat_height-(seat_gap+5)*sin(tilt)-seat_floor*cos(tilt);
 for(x=[-rail_offset-rail_width/2,rail_offset-rail_width/2])difference(){
  yz_frame(x,[[front_base_front+6,tabletop_z+front_base_thickness-1],[front_base_rear-1,tabletop_z+front_base_thickness-1],[yb+1,zb+1],[yf-1,zf+1]],rail_width);
  yz_frame(x-1,[[front_base_front+17,tabletop_z+front_base_thickness+10],[front_base_rear-16,tabletop_z+front_base_thickness+10],[seat_y+6,seat_height-20]],rail_width+2);
 }
}
module side_link_solid(){
 // Single narrow outer-right arm; NO bridge or columns over/in front of cradle.
 box([side_arm_inner_x,female_center_y-side_arm_depth/2,tabletop_z+front_base_thickness-1],
     [side_arm_width,side_arm_depth,insertion_height+flange_height-(tabletop_z+front_base_thickness-1)]);
 // L-shaped ground link goes AROUND dock corner, never diagonally through it.
 box([side_arm_inner_x,side_foot_front,tabletop_z],[side_foot_width,side_foot_rear-side_foot_front,front_base_thickness]);
 box([front_base_width/2-10,side_foot_front,tabletop_z],[side_arm_inner_x+side_foot_width-(front_base_width/2-10),front_base_rear-side_foot_front,front_base_thickness]);
}
module wire_path(d=6){
 r=cable_bend_radius;
 link([0,female_center_y,27],[0,female_center_y,side_exit_height-r],d);
 // Turn towards +X into original-reference-style right-side exit.
 for(t=[0:10:80])link([r-r*cos(t),female_center_y,side_exit_height-r+r*sin(t)],
                       [r-r*cos(t+10),female_center_y,side_exit_height-r+r*sin(t+10)],d);
 link([r,female_center_y,side_exit_height],[side_column_x-r,female_center_y,side_exit_height],d);
 // Turn down outside Nintendo's right wall.
 for(t=[0:10:80])link([side_column_x-r+r*sin(t),female_center_y,side_exit_height-r+r*cos(t)],
                       [side_column_x-r+r*sin(t+10),female_center_y,side_exit_height-r+r*cos(t+10)],d);
 link([side_column_x,female_center_y,side_exit_height-r],[side_column_x,female_center_y,return_z+r],d);
 // Turn forward, then left across the front sole below the device.
 for(t=[0:10:80])link([side_column_x,female_center_y-r+r*cos(t),return_z+r-r*sin(t)],
                       [side_column_x,female_center_y-r+r*cos(t+10),return_z+r-r*sin(t+10)],d);
 link([side_column_x,female_center_y-r,return_z],[side_column_x,return_y+r,return_z],d);
 for(t=[0:10:80])link([side_column_x-r+r*cos(t),return_y+r-r*sin(t),return_z],
                       [side_column_x-r+r*cos(t+10),return_y+r-r*sin(t+10),return_z],d);
 link([side_column_x-r,return_y,return_z],[r,return_y,return_z],d);
 // Final tilted-plane quarter bend follows the male connector axis exactly.
 for(t=[0:10:80])link(outlet+r*(1-sin(t))*[1,0,0]-r*cos(t)*lead_dir,
                       outlet+r*(1-sin(t+10))*[1,0,0]-r*cos(t+10)*lead_dir,d);
 link(outlet,outlet+4*lead_dir,d);
}
module front_open_exit(){
 r=cable_bend_radius;
 box([-channel_width/2,-insert_depth/2-1,female_height-1],[channel_width,insert_depth/2+1+female_center_y+wire_diameter_allowance/2,side_exit_height-female_height+5]);
 for(t=[0:10:80])hull()for(theta=[t,t+10],y=[female_center_y,-insert_depth/2-2])
  ball([r-r*cos(theta),y,side_exit_height-r+r*sin(theta)],wire_diameter_allowance);
 box([0,-insert_depth/2-2,side_exit_height-wire_diameter_allowance/2],[side_column_x+5,insert_depth/2+2+female_center_y+wire_diameter_allowance/2,wire_diameter_allowance]);
 // Lay-in slots from the low cross-feed into stand windows; no sealed thread-only bore.
 box([r,return_y-5,return_z],[side_column_x-r+5,10,14]);
}
module pockets(){
 box([-female_width/2,female_center_y-female_depth/2,-eps],[female_width,female_depth,female_height+eps]);
 seated(){
  box([-male_width/2,mid-male_depth/2,-male_height],[male_width,male_depth,male_height+eps]);
  translate([0,mid,-holder_height-eps])cylinder(d=wire_outlet,h=housing_floor+2*eps);
  box([-5,mid+male_depth/2-1,-holder_height-eps],[10,housing_wall+2,holder_height+2*eps]);
 }
}
module device_clearance(){seated()box([-odin_width/2,0,0],[odin_width,seat_gap,odin_height+6]);}
module device_envelope(){seated()box([-odin_width/2,1,eps],[odin_width,seat_gap-2,odin_height+6-eps]);}
module adapter_assembled(){
 difference(){
  union(){dock_insert_solid();side_link_solid();cradle_solid();tabletop_support();}
  pockets();wire_path(wire_diameter_allowance);front_open_exit();device_clearance();
 }
}
module illustrative_dock(){
 box([-dock_width/2,-dock_depth/2,tabletop_z],[dock_width,dock_depth/2-8,dock_height]);
 box([-dock_width/2,8,tabletop_z],[dock_width,dock_depth/2-8,dock_height]);
}
if(part=="adapter")print_pose()adapter_assembled();
else if(part=="assembled")adapter_assembled();
else if(part=="placement"){
 color([.3,.48,.6])adapter_assembled();
 %illustrative_dock();%device_envelope();%color([1,.5,.1])wire_path();
}
else if(part=="cable_check")intersection(){adapter_assembled();wire_path();}
else if(part=="dock_clearance_check")intersection(){adapter_assembled();illustrative_dock();}
else if(part=="device_clearance_check")intersection(){adapter_assembled();device_envelope();}
else if(part=="cable_device_check")intersection(){wire_path();device_envelope();}
else if(part=="cable_dock_check")intersection(){wire_path();illustrative_dock();}
else if(part=="table_check")intersection(){
 union(){adapter_assembled();wire_path();}
 box([-200,-150,tabletop_z-20],[400,220,20-eps]);
}
else assert(false,"Unknown part selector");
