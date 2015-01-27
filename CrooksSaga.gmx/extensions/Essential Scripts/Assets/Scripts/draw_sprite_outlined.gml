///draw_sprite_outlined(sprite, subimg, x, y, xscale, yscale, ang, colour, outline_colour)
var spr = argument0;
var img = argument1;
var xx = argument2;
var yy = argument3;
var xs = argument4;
var ys = argument5;
var ang = argument6;
var col = argument7;
var ocol = argument8;
d3d_set_fog(true, ocol, 0, 1);
draw_sprite_ext(spr, img, xx-xs, yy, xs, ys, ang, c_white, 1);
draw_sprite_ext(spr, img, xx+xs, yy, xs, ys, ang, c_white, 1);
draw_sprite_ext(spr, img, xx, yy-ys, xs, ys, ang, c_white, 1);
draw_sprite_ext(spr, img, xx, yy+ys, xs, ys, ang, c_white, 1);
d3d_set_fog(0, 0, 0, 0);
draw_sprite_ext(spr, img, xx, yy, xs, ys, ang, col, 1);

