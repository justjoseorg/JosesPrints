// TWO independent printed parts: docking insert + cable winder, and Odin cradle.
// Existing cable connects them; NO rigid side arm or matched-Z-height requirement.
part="layout"; // [adapter,cradle,assembled,layout,dock_usb_entry_check,adapter_dock_check,coil_check,coil_dock_check,cradle_device_check,cradle_wire_check,parts_collision_check]
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
foot_x=95;foot_y=3.18;foot_width=2;foot_depth=5;
// Official dock dimensions used ONLY for illustrative installed preview/check.
dock_height=115;dock_width=201;dock_depth=51.2;
seating_stop_to_table=115;
tabletop_z=insertion_height-seating_stop_to_table;
odin_width=257;odin_height=98.6;odin_thickness=17.2;
tpu_per_face=3;fit_clearance=2;
seat_gap=odin_thickness+2*tpu_per_face+fit_clearance;
tilt=15;seat_y=-70;seat_above_table=55;
seat_height=seat_above_table; // cradle geometry is intrinsically tabletop-Z=0
support_width=160;seat_floor=5;front_lip=10;contact_wall=4;
rail_width=18;rail_offset=58;rear_contact_height=36;
front_base_width=180;front_base_front=-88;front_base_rear=-32;
front_base_thickness=6;front_base_corner=4;
// Female end points DOWN into Nintendo dock; preserve reference datum.
female_center_y=-1.8;female_socket_face_z=0;
female_anchor_diameter=3;female_anchor_x=8;female_anchor_low=8;female_anchor_high=20;
dock_usb_access_width=12.2;dock_usb_access_depth=6.7;
female_width=22;female_depth=14;female_height=30;
male_width=22;male_depth=14;male_height=29;
housing_wall=3;housing_floor=3;wire_outlet=9;
wire_diameter_allowance=8;usb_access_width=36;channel_width=10;
side_exit_height=55;cable_bend_radius=12;
// RECESSED storage in the X/Z plane: no geometry outside dock_insert_solid().
// Single illustrative 6 mm loop; actual cable diameter/bend limit unmeasured.
winder_spacing=42;
winder_x=58;
winder_center_z=30;
winder_core_radius=12;
storage_margin=.5;
storage_back_y=.4;
storage_wire_y=-2.8;
keeper_thickness=1;
keeper_width=6;
coil_test_diameter=6;
central_seat_opening=36;
window_bottom=12;
window_shoulder=24;
window_half_width=10;
window_roof_angle=60; // margin above the slicer's 45-degree support threshold
window_center_y=-58;
// Only illustrative use placement. Cradle may be anywhere cable reaches.
preview_cradle_offset_y=-25;
layout_cradle_y=130;
mid=seat_gap/2;holder_height=male_height+housing_floor;
cradle_center_y=(front_base_front+front_base_rear)/2;
outlet=[0,seat_y+mid*cos(tilt)-holder_height*sin(tilt),seat_height-mid*sin(tilt)-holder_height*cos(tilt)];
lead_dir=[0,sin(tilt),cos(tilt)];
return_y=outlet[1]-cable_bend_radius*sin(tilt);
return_z=outlet[2]-cable_bend_radius*cos(tilt);
eps=.02;
storage_radius=winder_core_radius+coil_test_diameter+storage_margin;
assert(winder_x+winder_spacing/2+storage_radius<insert_width/2);
assert(winder_x-winder_spacing/2-storage_radius>female_width/2+housing_wall);
assert(winder_center_z+storage_radius<insertion_height);
assert(winder_center_z-storage_radius>0);
assert(storage_wire_y-coil_test_diameter/2>-insert_depth/2+keeper_thickness);
assert(storage_wire_y+coil_test_diameter/2<storage_back_y);
assert(window_shoulder+window_half_width*tan(window_roof_angle)<seat_height-seat_floor-8);
assert(return_z-wire_diameter_allowance/2>2);
module box(pos,size){translate(pos)cube(size);}
module seated(){translate([0,seat_y,seat_height])rotate([-tilt,0,0])children();}
module adapter_print_pose(){translate([0,0,insert_depth/2])rotate([-90,0,0])children();}
module cradle_print_pose(){translate([0,-cradle_center_y,0])children();}
module preview_cradle(){translate([0,preview_cradle_offset_y,tabletop_z])children();}
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
module storage_track(r,y_front){
 hull()for(x=[winder_x-winder_spacing/2,winder_x+winder_spacing/2])
  translate([x,y_front,winder_center_z])rotate([-90,0,0])cylinder(r=r,h=storage_back_y-y_front);
}
module storage_cut(){
 // Removing material leaves two internal cores and a flush retaining tab above/below.
 difference(){
  storage_track(storage_radius,-insert_depth/2-1);
  for(x=[winder_x-winder_spacing/2,winder_x+winder_spacing/2])
   translate([x,-insert_depth/2-2,winder_center_z])rotate([-90,0,0])cylinder(r=winder_core_radius,h=insert_depth+4);
  for(z=[winder_center_z-storage_radius,winder_center_z+winder_core_radius])
   box([winder_x-keeper_width/2,-insert_depth/2,z],[keeper_width,keeper_thickness,storage_radius-winder_core_radius]);
 }
 // Top-loading feed slots connect the original right-hand route to the recess.
 for(x=[winder_x-winder_spacing/2,winder_x+winder_spacing/2])
  box([x-channel_width/2,-insert_depth/2-1,winder_center_z+storage_radius-eps],
      [channel_width,storage_back_y+insert_depth/2+1,side_exit_height-winder_center_z-storage_radius+wire_diameter_allowance]);
}
module adapter_wire(d=6){
 r=cable_bend_radius;
 link([0,female_center_y,27],[0,female_center_y,side_exit_height-r],d);
 for(t=[0:10:80])link([r-r*cos(t),female_center_y,side_exit_height-r+r*sin(t)],
                       [r-r*cos(t+10),female_center_y,side_exit_height-r+r*sin(t+10)],d);
 link([r,female_center_y,side_exit_height],[flange_width/2+3,female_center_y,side_exit_height],d);
}
module adapter_front_loading(){
 r=cable_bend_radius;
 box([-channel_width/2,-insert_depth/2-2,female_height-1],
     [channel_width,insert_depth+4,side_exit_height-female_height+5]);
 for(t=[0:10:80])hull()for(theta=[t,t+10],y=[female_center_y,-insert_depth/2-2])
  ball([r-r*cos(theta),y,side_exit_height-r+r*sin(theta)],wire_diameter_allowance);
 box([0,-insert_depth/2-2,side_exit_height-wire_diameter_allowance/2],
     [flange_width/2+4,insert_depth+4,wire_diameter_allowance]);
}
module female_pocket(){
 box([-female_width/2,female_center_y-female_depth/2,female_socket_face_z-eps],[female_width,female_depth,female_height+eps]);
 for(x=[-female_anchor_x,female_anchor_x],z=[female_anchor_low,female_anchor_high])
  translate([x,insert_depth/2,z+female_socket_face_z])rotate([90,0,0])cylinder(d=female_anchor_diameter,h=4,center=true);
}
module adapter_body(){
 difference(){
  dock_insert_solid();
  female_pocket();adapter_wire(wire_diameter_allowance);adapter_front_loading();storage_cut();
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
  // No elevated mounting wings: holder is supported continuously from the base.
  box([-(male_width+2*housing_wall)/2,mid-(male_depth+2*housing_wall)/2,-holder_height],
      [male_width+2*housing_wall,male_depth+2*housing_wall,holder_height]);
 }
}
module yz_frame(x,points,width){
 translate([x,0,0])multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])linear_extrude(height=width)polygon(points);
}
module cradle_base(){
 translate([0,cradle_center_y,0])linear_extrude(height=front_base_thickness)
  offset(r=front_base_corner)square([front_base_width-2*front_base_corner,front_base_rear-front_base_front-2*front_base_corner],center=true);
 yf=seat_y-contact_wall*cos(tilt)-seat_floor*sin(tilt);
 zf=seat_height+contact_wall*sin(tilt)-seat_floor*cos(tilt);
 yb=seat_y+(seat_gap+5)*cos(tilt)-seat_floor*sin(tilt);
 zb=seat_height-(seat_gap+5)*sin(tilt)-seat_floor*cos(tilt);
 for(side=[-1,1])let(x=side<0?-support_width/2:central_seat_opening/2,
                         w=(support_width-central_seat_opening)/2)difference(){
  yz_frame(x,[[front_base_front+6,front_base_thickness-1],[front_base_rear-1,front_base_thickness-1],[yb+1,zb+1],[yf-1,zf+1]],w);
  // Steep pitched roof gives margin above a 45-degree support threshold.
  yz_frame(x-1,[[window_center_y-window_half_width,window_bottom],
                [window_center_y+window_half_width,window_bottom],
                [window_center_y+window_half_width,window_shoulder],
                [window_center_y,window_shoulder+window_half_width*tan(window_roof_angle)],
                [window_center_y-window_half_width,window_shoulder]],w+2);
 }
 // Continuous, steep-walled support under the existing angled connector cup.
 hull(){
  box([-(male_width+2*housing_wall)/2,outlet[1]-11,front_base_thickness-1],
      [male_width+2*housing_wall,22,2]);
  seated()box([-(male_width+2*housing_wall)/2,mid-(male_depth+2*housing_wall)/2,-holder_height],
             [male_width+2*housing_wall,male_depth+2*housing_wall,2]);
 }
}
module front_cable_chute(){
 // Front-open passage with a steep pitched roof under the connector cup.
 y0=front_base_front-1;y1=outlet[1]+1;half=6;shoulder=outlet[2]+4;
 translate([0,y1,0])rotate([90,0,0])linear_extrude(height=y1-y0)
 polygon([[-half,front_base_thickness], [half,front_base_thickness],
          [half,shoulder],[0,shoulder+half*tan(window_roof_angle)],[-half,shoulder]]);
}
module cradle_wire(d=6){
 r=cable_bend_radius;angle=90-tilt;
 start=outlet-[0,r*sin(angle),r*(1-cos(angle))];
 link([0,front_base_front-10,start[2]],start,d);
 for(t=[0:5:angle-5])link(start+[0,r*sin(t),r*(1-cos(t))],
                         start+[0,r*sin(t+5),r*(1-cos(t+5))],d);
 link(outlet,outlet+4*lead_dir,d);
}
module male_pocket(){
 seated(){
  box([-male_width/2,mid-male_depth/2,-male_height],[male_width,male_depth,male_height+eps]);
  translate([0,mid,-holder_height-eps])cylinder(d=wire_outlet,h=housing_floor+2*eps);
  box([-5,mid+male_depth/2-1,-holder_height-eps],[10,housing_wall+2,holder_height+2*eps]);
 }
}
module device_clearance(){seated()box([-odin_width/2,0,0],[odin_width,seat_gap,odin_height+6]);}
module device_envelope(){seated()box([-odin_width/2,1,eps],[odin_width,seat_gap-2,odin_height+6-eps]);}
module cradle_body(){difference(){union(){cradle_solid();cradle_base();}male_pocket();front_cable_chute();cradle_wire(wire_diameter_allowance);device_clearance();}}
module coil_sample(d=coil_test_diameter){
 // ONE sample turn entirely recessed in the original docking-body envelope.
 r=winder_core_radius+d/2+.2;
 for(t=[90:10:260])link([winder_x-winder_spacing/2+r*cos(t),storage_wire_y,winder_center_z+r*sin(t)],
                      [winder_x-winder_spacing/2+r*cos(t+10),storage_wire_y,winder_center_z+r*sin(t+10)],d);
 for(t=[-90:10:80])link([winder_x+winder_spacing/2+r*cos(t),storage_wire_y,winder_center_z+r*sin(t)],
                     [winder_x+winder_spacing/2+r*cos(t+10),storage_wire_y,winder_center_z+r*sin(t+10)],d);
 link([winder_x-winder_spacing/2,storage_wire_y,winder_center_z+r],
      [winder_x+winder_spacing/2,storage_wire_y,winder_center_z+r],d);
 link([winder_x-winder_spacing/2,storage_wire_y,winder_center_z-r],
      [winder_x+winder_spacing/2,storage_wire_y,winder_center_z-r],d);
}
module insert_reference_envelope(){
 box([-flange_width/2,-reference_depth_envelope/2,-foot_height],
     [flange_width,reference_depth_envelope,insertion_height+flange_height+foot_height]);
}
module dock_usb_entry_keepout(){box([-dock_usb_access_width/2,female_center_y-dock_usb_access_depth/2,female_socket_face_z-1],[dock_usb_access_width,dock_usb_access_depth,7]);}
module illustrative_dock(){
 box([-dock_width/2,-dock_depth/2,tabletop_z],[dock_width,dock_depth/2-8,dock_height]);
 box([-dock_width/2,8,tabletop_z],[dock_width,dock_depth/2-8,dock_height]);
}
module installed(){color([.3,.48,.6])adapter_body();color([.9,.48,.18])preview_cradle()cradle_body();}
module print_layout(){
 color([.3,.48,.6])adapter_print_pose()adapter_body();
 color([.9,.48,.18])translate([0,layout_cradle_y,0])cradle_print_pose()cradle_body();
}
if(part=="adapter")adapter_print_pose()adapter_body();
else if(part=="cradle")cradle_print_pose()cradle_body();
else if(part=="assembled")installed();
else if(part=="layout")print_layout();
else if(part=="placement"){installed();%illustrative_dock();%preview_cradle()device_envelope();%color([1,.6,.1])coil_sample();}
else if(part=="dock_usb_entry_check")intersection(){adapter_body();dock_usb_entry_keepout();}
else if(part=="adapter_dock_check")intersection(){adapter_body();illustrative_dock();}
else if(part=="adapter_wire_check")intersection(){adapter_body();adapter_wire();}
else if(part=="coil_check")intersection(){adapter_body();coil_sample();}
else if(part=="coil_inside_body_check")difference(){coil_sample();box([-insert_width/2,-insert_depth/2,0],[insert_width,insert_depth,insertion_height]);}
else if(part=="loaded_envelope_check")difference(){union(){adapter_body();coil_sample();}insert_reference_envelope();}
else if(part=="coil_dock_check")intersection(){illustrative_dock();coil_sample();}
else if(part=="cradle_device_check")intersection(){cradle_body();device_envelope();}
else if(part=="cradle_wire_check")intersection(){cradle_body();cradle_wire();}
else if(part=="cradle_table_check")intersection(){union(){cradle_body();cradle_wire();}box([-200,-150,-20],[400,220,20-eps]);}
else if(part=="parts_collision_check")intersection(){adapter_body();preview_cradle()cradle_body();}
else if(part=="preview_device_check")intersection(){adapter_body();preview_cradle()device_envelope();}
else assert(false,"Unknown part selector");
