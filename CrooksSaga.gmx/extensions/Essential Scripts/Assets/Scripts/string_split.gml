///string_split(string, split)
///Returns a ds_list of strings after splitting the initial string
/* 
 * Example use:
 * var str = "These are some words";
 * word_list = string_split(str, " ");
 * //Returns a list containing ("These", "are", "some", "words")
 */
var str = argument0;
var split = argument1;
var list = ds_list_create();
var number = string_count(split, str);
if (number == 0)
{
    ds_list_add(list, str);
}
else
{
    for (var i = 0; i < number; i++)
    {
        var pos = string_pos(split, str);
        ds_list_add(list, string_copy(str, 1, pos-1));
        str = string_delete(str, 1, pos);
    }
    ds_list_add(list, str);
}
return list;

