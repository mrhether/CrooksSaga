///mouse_in(x1,y1,x2,y2)
{
    var x1 = argument0
    var y1 = argument1
    var x2 = argument2
    var y2 = argument3
    var mx = device_mouse_x_to_gui(0); 
    var my = device_mouse_y_to_gui(0);
    return 
       (mx >= x1 &&
        mx <= x2 &&
        my >= y1 &&
        my <= y2);
    
}