///get_depth_color(depth)
var d = argument0

if (d >= 300) {
   return colorB
} else if (d >= 100) {
  return colorC
} else if (d >= 0) {
  return colorD
} else {
  return colorA
}
