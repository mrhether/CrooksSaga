///create_camp(x,y,size)
var xx = argument0;
var yy = argument1;
var size = argument2

repeat(irandom(size/2)) {
    instance_create(xx + irandom_range(-24*size, +24*size), yy, obj_camp_fire);
}
var side = choose(1,-1)
for (var i = 0; i < size; i++) {
    side *= -1
    with instance_create(xx + side*(8+irandom(64*size)), yy, obj_cabin) {
        image_xscale = -side;
    }
}
