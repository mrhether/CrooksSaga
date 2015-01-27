/// scr_triangle_find_side_similar(x1,y1,y2,x3,y3)
/// solves for x2, a point on the hypotenuse of a right triangle. 
/// also solves for x coord of a point on any line

var x1,y1,x2,y2,x3,y3; 

x1 = argument0; // x of endpoint 1 
y1 = argument1; // y of endpoint 1
//x2               x of point on line - what we're solving for  
y2 = argument2; // y of point on line
x3 = argument3; // x of endpoint 2
y3 = argument4; // y of endpoint 2

if (y1-y3 != 0) {
    x2 = -( ((x1-x3) * ( (y1-y2)/(y1-y3) ) - x1) );
}
else {
    x2 = -( ((x1-x3) * ( (y1-y2)/(0.000001) ) - x1) ); 
}

return x2; 