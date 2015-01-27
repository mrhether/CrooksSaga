///create_sprite_from_list(dslist, function(xx,yy))
var ground = argument0;
var arrayLength = ds_list_size(ground);
var surface = sprite_edit_begin()

for (var i = 0; i < arrayLength; i++) {    
   var xx = sprite_width / (arrayLength-1) * i
   var yy = sprite_height - ground[| i];
   
   script_execute(argument1,xx,yy);
   
  // draw_set_colour(make_colour_rgb(0,123+irandom_range(-20,20),12+irandom_range(-5,5)))
  // if (irandom(2) == 0) draw_line(xx,yy+10,xx,yy+10-random(10));
   //draw_sprite(spr_ground_grass,-1,xx,yy+random_range(-1,1));
}

return sprite_edit_end(surface);