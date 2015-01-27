#define create_ground_auora
///create_ground_auora(dslist)
return create_sprite_from_list(argument0, ini_create_ground_auora);

#define ini_create_ground_auora
var xx = argument0;
var yy = argument1;


var yyRand = yy-1 + random_range(0,2);

//d3d_set_fog(true, c_white, 0, 0);
//draw_sprite_ext(spr_ground_grass,-1,xx,yyRand,1,1,0,colorA,1);

//d3d_set_fog(false,0,0,0);
//draw_set_blend_mode(bm_subtract)
draw_set_colour(c_white);
draw_rectangle(xx,yyRand,xx+1,yyRand+1000,false);
draw_set_blend_mode(bm_normal)
