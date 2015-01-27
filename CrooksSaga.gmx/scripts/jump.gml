///jump(speed)
var moveSpeed = argument0;
if (not place_free(x,y+1)) {
    y--;
    
    motion_add(image_angle+90,moveSpeed);
    //vspeed = -moveSpeed;
}