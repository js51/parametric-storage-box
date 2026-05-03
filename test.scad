// Test OpenSCAD code for box with lid and magnet holes in corners

// Set the resolution for circles and cylinders to ensure smooth edges
$fn = 100;  // Set the resolution for circles and cylinders

// Parameters
magnet_width = 4;
magnet_height = 2;
magnet_tolerance = 0.4;  // Tolerance for magnet fit (added to magnet dimensions to ensure it fits in the hole)

magnet_hole_diameter = magnet_width + magnet_tolerance;  // Diameter of hole for magnet
magnet_hole_height = magnet_height + magnet_tolerance;  // Height of hole for magnet

box_outer_width = 175;
box_outer_length = 175;
box_outer_height = 35;
box_floor_thickness = 3;

lid_height = 5;
lid_storage = true;

lid_inset_width = 3;  // Inset for lid to fit inside box
lid_inset_height = 2;  // Height of the lid inset

lid_tolerance = 0.8;  // Tolerance for lid fit (added to lid dimensions to ensure it fits inside the box)
insert_thickness = 2;
insert_tolerance = 0.4;  // Tolerance for insert fit (added to insert dimensions to ensure it fits in the box)

// Computed values
magnet_dist_from_edge = lid_inset_width + magnet_hole_diameter / 2;  // Distance from edge to center of magnet hole
box_wall_thickness = magnet_hole_diameter + lid_inset_width + 0.5;
inner_box_width = box_outer_width - 2 * box_wall_thickness;
inner_box_length = box_outer_length - 2 * box_wall_thickness;
inner_box_height = box_outer_height - box_floor_thickness - lid_inset_height;

echo(str("Inner box dimensions: ", inner_box_width, " x ", inner_box_length, " x ", inner_box_height));

part = "box"; // [box, lid, inserts]

if (part == "box") {
    box();
} else if (part == "lid") {
    lid();
} else if (part == "inserts") {
    inserts(1, 20);
} else {
    echo("Invalid part specified. Please set 'part' to either 'box', 'lid', or 'inserts'.");
}

module box() {
    difference() {
        cube([box_outer_width, box_outer_length, box_outer_height]);  // Main cube

        translate([box_wall_thickness, box_wall_thickness, box_floor_thickness]) {
            cube([box_outer_width - 2 * box_wall_thickness, box_outer_length - 2 * box_wall_thickness, box_outer_height]);  // Inside dimensions of box
        }

        // Inset for lid    
        translate([lid_inset_width / 2, lid_inset_width / 2, box_outer_height - lid_inset_height]) {
            cube([box_outer_width - lid_inset_width, box_outer_length - lid_inset_width, lid_inset_height + 1]);  // Lid inset
        }

        // Holes for cylindrical magnets in each of four corners of main cube
        for (x = [magnet_dist_from_edge, box_outer_width - magnet_dist_from_edge]) {
            for (y = [magnet_dist_from_edge, box_outer_length - magnet_dist_from_edge]) {
                translate([x, y, box_outer_height - lid_inset_height - magnet_hole_height + 1]) {
                    cylinder(h=magnet_hole_height + 1, r=magnet_hole_diameter / 2);
                }
            }
        }
        if (lid_storage) {
            // Make a hole in the bottom of the box for the lid to fit under when not in use
            translate([lid_inset_width / 2, lid_inset_width / 2, - 1]) {
                cube([box_outer_width - lid_inset_width, box_outer_length - lid_inset_width, lid_inset_height + 1]);  // Lid inset
            }
        }
    }
}

module lid() {
    // Start with a cube same dimensions as the box
    difference () {
        union () {
            cube([box_outer_width, box_outer_length, lid_height]);  // Main cube
            translate([(lid_inset_width + lid_tolerance) / 2, (lid_inset_width + lid_tolerance) / 2, lid_height]) {
                color("lightgreen")
                cube([
                    box_outer_width - lid_inset_width - lid_tolerance, 
                    box_outer_length - lid_inset_width - lid_tolerance, 
                    lid_inset_height - lid_tolerance
                ]);  // Inset for fitting inside box
            }
        }
        // Put magnets in the lid (holes for magnets to fit into)
        for (x = [magnet_dist_from_edge, box_outer_width - magnet_dist_from_edge]) {
            for (y = [magnet_dist_from_edge, box_outer_length - magnet_dist_from_edge]) {
                translate([x, y, lid_height + lid_inset_height - magnet_hole_height + 1]) {
                    cylinder(h=magnet_height + 1, r=magnet_hole_diameter / 2);
                }
            }
        }
    }
}


module inserts(inserts_in_length = 3, insert_row_width = 40) {
    insert_length = (inner_box_length / inserts_in_length) - insert_tolerance;  // Length of each insert, accounting for tolerance
    insert_width = insert_row_width - insert_tolerance;  // Width of each insert, accounting for tolerance
    // Pen insert
    for (i = [0 : inserts_in_length - 1]) {
        // Position each insert in the box, starting from the front and moving back, with a gap between each insert
        translate([i * (insert_length + insert_tolerance + 2), 0, 0]) {   
            difference() {
                cube([insert_length, insert_width, inner_box_height]);  // Main cube
                translate([insert_thickness / 2, insert_thickness / 2, insert_thickness]) {
                    cube([insert_length - insert_thickness, insert_width - insert_thickness, inner_box_height - insert_thickness + 1
                    ]);  // Main cube
                }
            }
        }
    }
}