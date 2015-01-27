///create_dialog(name,dialog,list)
{
    var dialog = ds_map_create();
    dialog[? dm_name] = argument0;
    dialog[? dm_dialog] = argument1;
    
    var list = ds_list_create();
    for (var i = 0; i < ds_list_size(argument2); i++) {
        ds_list_add (list, string_split(argument2[| i],"~"));
        ds_list_mark_as_list(list,i);
    }
    ds_list_destroy(argument2);
    ds_map_add_list(dialog,dm_choices,list);
    
    return dialog;
}