///instance_create_worldO(x,y,obj,objToDodge)
var inst = instance_create(argument0,argument1,argument2);
var objectToContact = argument3
with (inst) { 
    y = 0
    move_contact_obj(270,-1,objectToContact)
    image_angle = get_ground_angle(objectToContact);
    y = minY; // set by get_ground_angle
}
return inst
