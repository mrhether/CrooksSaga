///get_ground_angle(to_obj)
/// sets minY

var left = x - sprite_width/2;
var right = x + sprite_width/2;

var leftY = y;
var rightY = y;

while (leftY < room_height and not collision_point(left,leftY,argument0,true,false)) {
    leftY++;
}

while (rightY < room_height and not collision_point(right,rightY,argument0,true,false)) {
    rightY++;
}

minY = (rightY + leftY )/2 + 3
return point_direction(left,leftY,right,rightY)
