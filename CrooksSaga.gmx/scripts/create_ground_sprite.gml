#define create_ground_sprite
///create_ground_sprite(dslist)
return create_sprite_from_list(argument0, ini_create_ground);

#define ini_create_ground
var xx = argument0;
var yy = argument1;
draw_sprite(spr_ground_grass,-1,xx,yy);
