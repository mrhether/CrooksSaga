#define create_ground_auora
///create_ground_auora(dslist)
return create_sprite_from_list(argument0, ini_create_ground_auora);

#define ini_create_ground_auora
var xx = argument0;
var yy = argument1;


var yyRand = yy-1 + random_range(0,1);
draw_sprite_ext(spr_ground_grass,-1,xx,yyRand,1,1,0,colorA,1);


draw_set_colour(make_colour_rgb(0,123+irandom_range(-20,20),12+irandom_range(-5,5)))
