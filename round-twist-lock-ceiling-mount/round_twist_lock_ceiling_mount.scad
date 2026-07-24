/* Twist-Lock Ceiling Mount */
$fa = 1;
$fs = 0.5;
// --- Dimensions ---
base_diameter = 80;      // Outer diameter of the ceiling base (mm)
base_height = 20;        // Total height of the main base (mm)

// --- Internal & Mounting ---
hollow_diameter = 56;    // Diameter of the hollow space for wiring (mm)
roof_thickness = 5;      // Thickness of the top face before the neck starts (mm)

// --- Top Cable Cylinder ---
neck_diameter = 14;      // Width of the top cylinder
neck_height = 15;        // Height of the top cylinder
cable_hole_dia = 5;      // Center hole for the cable (mm)

// --- Twist-Lock Mechanism ---
screw_radius = 34;       // Perfect center of the solid perimeter wall
shaft_dia = 4.5;         // Clearance for a 4mm screw shaft
head_dia = 9.5;          // Clearance for the screw head (4mm heads are usually ~8mm)
twist_angle = 20;        // Degrees of rotation to lock
lip_start = 1.5;         // Starting thickness of the grab lip (loose fit)
lip_end = 3.5;           // Ending thickness of the grab lip (tight fit against ceiling)
lock_drop = 0.5;         // Depth of the locking dimple so it "clicks"

$fn = 64; 

// Sub-module to generate the arced ramping slot
module twist_lock_cutout() {
    // 1. Entry Hole (Wide enough for the screw head to enter)
    translate([screw_radius, 0, -0.1])
        cylinder(h = 10, d = head_dia);
        
    // 2. The Arced Track for the screw shaft
    for(a = [0 : 1 : twist_angle - 1]) {
        hull() {
            rotate([0, 0, a]) 
                translate([screw_radius, 0, -0.1]) 
                cylinder(h = 10, d = shaft_dia);
            rotate([0, 0, a + 1]) 
                translate([screw_radius, 0, -0.1]) 
                cylinder(h = 10, d = shaft_dia);
        }
    }
    
    // 3. The Ramping Channel for the screw head
    // As the angle increases, the Z-height of the cut moves up, thickening the lip below it
    for(a = [0 : 1 : twist_angle - 1]) {
        z1 = (a < twist_angle - 3) 
             ? lip_start + (lip_end - lip_start) * (a / (twist_angle - 3)) 
             : lip_end - lock_drop;
             
        z2 = ((a+1) < twist_angle - 3) 
             ? lip_start + (lip_end - lip_start) * ((a+1) / (twist_angle - 3)) 
             : lip_end - lock_drop;
        
        hull() {
            rotate([0, 0, a]) 
                translate([screw_radius, 0, z1]) 
                cylinder(h = 10, d = head_dia);
            rotate([0, 0, a + 1]) 
                translate([screw_radius, 0, z2]) 
                cylinder(h = 10, d = head_dia);
        }
    }
}

module ceiling_mount() {
    difference() {
        // 1. The solid outer shape
        union() {
            cylinder(h = base_height, d = base_diameter);
            translate([0, 0, base_height])
                cylinder(h = neck_height, d = neck_diameter);
        }
        
        // 2. The hollow region
        // We define the hollow area, but we leave the top solid by making 
        // the height less than the total base_height
        translate([0, 0, -0.1])
            cylinder(h = base_height - roof_thickness + 0.1, d = hollow_diameter);
            
        // 3. Cable Hole (remains constant)
        translate([0, 0, -1])
            cylinder(h = base_height + neck_height + 2, d = cable_hole_dia);
            
        // 4. Twist-Lock Cutouts
        for (angle = [0, 180]) {
            rotate([0, 0, angle])
            twist_lock_cutout();
        }
    }
}

ceiling_mount();