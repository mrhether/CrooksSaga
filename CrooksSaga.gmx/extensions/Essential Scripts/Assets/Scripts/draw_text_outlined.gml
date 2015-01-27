///draw_text_outlined(x, y, string, colour, outline_colour)
var xx = argument0;
var yy = argument1;
var str = argument2;
draw_set_colour(argument4);
draw_text(xx-1, yy, str);
draw_text(xx+1, yy, str);
draw_text(xx, yy-1, str);
draw_text(xx, yy+1, str);
draw_set_colour(argument3);
draw_text(xx, yy, str);
draw_set_colour(c_white);
