///draw_text_shadow_ext(x, y, string, colour, shadow_colour, shadow_direction, shadow_distance, shadow_alpha)
var xx = argument0;
var yy = argument1;
var str = argument2;
var dir = argument5;
var len = argument6;

//Draw text shadow
draw_set_colour(argument4);
draw_set_alpha(argument7);
var shadow_x = xx+lengthdir_x(len, dir);
var shadow_y = yy+lengthdir_y(len, dir);
draw_text(shadow_x, shadow_y, str);

//Draw text
draw_set_colour(argument3);
draw_set_alpha(1);
draw_text(xx, yy, str);
draw_set_colour(c_white);
