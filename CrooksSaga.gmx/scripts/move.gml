///move(speed)
var moveSpeed = argument0;
var changeY = 0;
while (not place_free(x+moveSpeed,y)) {//(collision_point(x+10,y,obj_ground,true,false)) {
    y-=1
    changeY++;
}
if (moveSpeed > 0) {
    x += max(1, (moveSpeed - changeY));
} else {
    x += min(-1, (moveSpeed + changeY));
}