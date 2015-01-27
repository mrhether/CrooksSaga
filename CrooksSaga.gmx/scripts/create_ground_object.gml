///create_ground_object(x,y,depth,number)

var secondGround = create_ground(end_height[argument3]);
end_height[argument3] = secondGround[| (ds_list_size(secondGround)-1)];
var oldDepth = depth;
depth = argument2

var backgroundGround = instance_create(argument0, argument1, obj_pground);
backgroundGround.decal = create_ground_auora(secondGround);
backgroundGround.sprite_index = create_ground_sprite(secondGround);
backgroundGround.depth = depth

ds_list_destroy(secondGround);
depth = oldDepth;
return backgroundGround;
