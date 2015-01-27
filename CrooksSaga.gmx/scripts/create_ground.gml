///create_ground(leftHeightOrNegativeOne)

var maxPoints = 5;
var minHeight = 100;
var maxHeight = sprite_height;
var maxHeightDif = sprite_height/2;
var smoothMod = 15;
var startingHeight = argument0;
if (startingHeight == -1) {
    startingHeight = minHeight + irandom((maxHeight-minHeight)/2);
}

var ground = ds_list_create()
var length = irandom(maxPoints) + 2;

tempPath = path_add()
path_set_kind(tempPath, 1);
path_set_closed(tempPath, false);
path_set_precision(tempPath, 8)

for (var i = 0; i < length; i++) {
    var height = startingHeight;
    if (i > 0) {
        var previousPos = path_get_point_y(tempPath,i-1)
        var difFromMax = maxHeight - previousPos;
        height = min(maxHeight,max(minHeight,previousPos + irandom_range(-maxHeightDif/2,maxHeightDif/2)));
    }
    var distance_x = 1000*i;
    if (i == 0 || i == length-1) {
        path_add_point(tempPath, distance_x-200, height, 1);
        path_add_point(tempPath, distance_x+200, height, 1);
    } else {
        path_add_point(tempPath, distance_x, height, 1);
    }
}

var finalListSize = sprite_width+1;
for (var i = 0; i < finalListSize; i+=1) {
    ds_list_add(ground, path_get_y(tempPath, i / (finalListSize)));
}

path_delete(tempPath);
return ground;
