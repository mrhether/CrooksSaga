/// scr_draw_resizable(sprite_index, x, y, width, height, pivot_x, pivot_y)
/*
** Script helps to draw resizable interface elements
** from 9 frame images from passed sprite.
** 123  - images from sprite are draws in this order.
** 456  Images 2, 4, 5, 6, 8 in this order are scalable.
** 789  Try to keep it in mind while drawing them.
** width and height in pixels.
** pivot_x and pivot_y from 0 to 1 when
** 0,0 - top left corner and
** 1,1 - bottom right corner.
** Created by Alexander Kondyrev
** (c) 2014 Alexander Kondyrev
** http://www.hiddenrabbit.com/
*/

// Set current sprite
sprite_index = argument0;

// Set variables from arguments
var width = floor(argument3 * image_xscale);
var height = floor(argument4 * image_yscale);
var pivot_x = abs(argument5);
var pivot_y = abs(argument6);

// Set double width and height
var double_width = 2 * sprite_width;
var double_height = 2 * sprite_height;

// Check for minimal width and height
if ( width < double_width) width = double_width;
if ( height < double_height) height = double_height;

// Calculate side width and height
var side_width = (width - double_width) / sprite_width;
var side_height = (height - double_height) / sprite_height;

// Calculate offset for right and bottom sides
var offset_right = width - sprite_width;
var offset_bottom = height - sprite_height;

// Offset calculations
xx = floor(argument1 - pivot_x * width);
yy = floor(argument2 - pivot_y * height);

// 1 draw top left corner
draw_sprite_ext(
    sprite_index, 0,
    xx, yy,
    image_xscale, image_yscale,
    0, image_blend, image_alpha
);

// 2 draw top center side
draw_sprite_ext(
    sprite_index, 1,
    xx + sprite_width, yy,
    image_xscale * side_width, image_yscale,
    0, image_blend, image_alpha
);

// 3 draw top right corner
draw_sprite_ext(
    sprite_index, 2,
    xx + offset_right, yy,
    image_xscale, image_xscale,
    0, image_blend, image_alpha
);

// 4 draw middle left side
draw_sprite_ext(
    sprite_index, 3,
    xx, yy + sprite_height,
    image_xscale, image_yscale * side_height,
    0, image_blend, image_alpha
);

// 5 draw middle center core
draw_sprite_ext(
    sprite_index, 4,
    xx + sprite_width, yy + sprite_height,
    image_xscale * side_width, image_yscale * side_height,
    0, image_blend, image_alpha
);

// 6 draw middle right side
draw_sprite_ext(
    sprite_index, 5,
    xx + offset_right, yy + sprite_height,
    image_xscale, image_yscale * side_height,
    0, image_blend, image_alpha
);

// 7 draw bottom left corner
draw_sprite_ext(
    sprite_index, 6,
    xx, yy + offset_bottom,
    image_xscale, image_yscale,
    0, image_blend, image_alpha
);

// 8 draw bottom center side
draw_sprite_ext(
    sprite_index, 7,
    xx + sprite_width, yy + offset_bottom,
    image_xscale * side_width, image_yscale,
    0, image_blend, image_alpha
);

// 9 draw bottom right corner
draw_sprite_ext(
    sprite_index, 8,
    xx + offset_right, yy + offset_bottom,
    image_xscale, image_yscale,
    0, image_blend, image_alpha
);
