tolerance = 2;

vibe_d = 26.33 + tolerance;
vibe_h = 24.36;
vibe_h_in = 13.9;
vibe_d_in = 24.1;

chip_h = 52.38;
batt_d = 30.85 + tolerance;

outside_w = 5;
top_h = 20;

usb_d = 9;
usb_t = 0.3;
usb_h = 3.2 + usb_t;
    
motor_board_spacing = 5;
motor_board_d = 2;
hex_d = 4.22;
insert_h = 2.08;
cuttout_d = 5;

usb_top_offset = 4.24;


inlet_h = chip_h + vibe_h + 2 * tolerance + motor_board_spacing;
bh = inlet_h + top_h;
handle_h = 30;
handle_offset = bh + top_h;
handle_mult = 1.2;

thread_r = 1;
top_screw_offset = thread_r * 2.5;

$fa = 1;
$fn = 100;

module usb_c(x)
{    
    linear_extrude(x)
    {
        hull()
        {
            translate([usb_d / 2 -usb_h / 2 + usb_t, 0, 0])
            circle(d = usb_h);
            
            square([usb_d, usb_h], center = true);
            
            translate([-usb_d / 2 + usb_h / 2 - usb_t, 0, 0])
            circle(d = usb_h);
        }
    }
}

// Electronics well
module leccy_blob()
{
    d = max(vibe_d, batt_d);
    h = inlet_h - vibe_h_in;
    
    translate([0, 0, top_h])
    union()
    {
        translate([0, 0, h / 2 + vibe_h_in])
        cylinder(r = d / 2, h = h, center = true);
    
        translate([0, 0, vibe_h_in / 2])
        cylinder(r = vibe_d_in / 2, h = vibe_h_in, center = true);
    }
}

module body()
{
    hull()
    {
        d = max(vibe_d, batt_d) + outside_w;
        
        translate([0, 0, bh / 2 + top_h])
        cylinder(r = d / 2, h = bh, center = true);
        
        translate([0, 0, top_h])
        sphere(r = d / 2);
    }
}

module top_screw()
{
    h = top_h;
    d = max(vibe_d, batt_d) + top_screw_offset;
    
    translate([0, 0, bh])
    union(){
        cylinder(r = d / 2, h = h);
        linear_extrude(height = h, twist = 360 * 3)
        {
            translate([d / 2, 0])
            circle(r = thread_r);
        }
    }
}

module top()
{
    d = max(vibe_d, batt_d) + outside_w;
    
    union()
    {
        translate([0, 0, handle_offset +  handle_h / 2])
        hull()
        {
            sphere(r = handle_mult * d / 2);
            cylinder(r = d / 2, h = handle_h, center = true);
        }
        
        top_screw();
    }        
}

module pcb_holder()
{
    d = max(vibe_d, batt_d);
    
    translate([0, 0, bh - top_h / 2])
    union(){
        pcbh = chip_h + motor_board_spacing;
        
        // Board holder
        intersection()
        {
            // round the board if needed
            translate([0, 0, -pcbh / 2])
            cylinder(r = batt_d, h = pcbh, center = true);
            
            // pcb holder with cutout
            difference()
            {
                
                translate([0, 0, -pcbh / 2])
                cube([batt_d, motor_board_d, pcbh], center = true);
                
                hull()
                {
                    translate([-d / 2 + cuttout_d, 0, -pcbh + cuttout_d])
                    sphere(d = cuttout_d);
                    
                    translate([-d / 2 + cuttout_d, 0, -cuttout_d])
                    sphere(d = cuttout_d);
                }
            }
        }
            
        // Motor Holder
        motor_hh = motor_board_spacing;
        
        translate([0, 0, -pcbh])
        difference()
        {
            translate([0, 0, -motor_hh / 2])
            cylinder(r = vibe_d / 2 - tolerance, h = motor_hh, center = true);
        }
        
        // Ring
        h = motor_board_spacing;
        union()
        {
            difference()
            {
                translate([0, 0, h - insert_h])
                cylinder(r = d / 2, h = insert_h);
                
                translate([0, usb_top_offset, h - insert_h])
                usb_c(insert_h);
                
                // Hex screw point
                color("red")
                translate([0, 0, h - insert_h / 2])
                linear_extrude(insert_h / 2)
                {
                    pts = [
                    for (i = [0 : 1: 5]) 
                        [cos(i * (360 / 6)) * hex_d / 2, sin(i * (360 / 6)) * hex_d / 2]
                    ];
                    
                    echo(pts);
                    polygon(points = pts);
                }
            }
            
            difference()
            {
                cylinder(r = d / 2, h = h);
                cylinder(r = d / 2 - top_screw_offset, h = h);
            }
        }
        
        // Threading
        linear_extrude(height = h, twist = 360 * 3)
        {
            translate([d / 2, 0])
            circle(r = thread_r);
        }
    }
}



difference()
{
    body();
    
    color("blue")
    leccy_blob();
    
    top_screw();
    
    pcb_holder();
}

translate([50, 0, 0])
top();

translate([-50, 0, 0])
pcb_holder();
