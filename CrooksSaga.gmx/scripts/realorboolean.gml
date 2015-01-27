///realorboolean(value)
if (string_pos("true",argument0)) {
   return true;
} else if (string_pos("false",argument0)) {
   return false;
} else {
  return real(argument0)
}
