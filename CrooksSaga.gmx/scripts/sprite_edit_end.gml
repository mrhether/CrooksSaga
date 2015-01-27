///sprite_edit_end(surface)
// create sprite from surface
var surface = argument0
surface_reset_target()
var sprite = sprite_create_from_surface(surface,0,0,sprite_width,sprite_height,false,false,0,0)
sprite_collision_mask(sprite, false, 1, 0, 0, 0, 0, 0, 254);
surface_free(surface)
return sprite;