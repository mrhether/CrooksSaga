///draw_text_shadow(x, y, string, colour, shadow_colour, shadow_alpha)
var xx = argument0;
var yy = argument1;
var str = argument2;

//Draw shadow
draw_set_colour(argument4);
draw_set_alpha(argument5);
draw_text(xx, yy+1, str);

//Draw Text
draw_set_colour(argument3);
draw_set_alpha(1);
draw_text(xx, yy, str);
draw_set_colour(c_white);
