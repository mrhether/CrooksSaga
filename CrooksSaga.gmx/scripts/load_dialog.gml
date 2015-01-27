#define load_dialog
///load_dialog(filename)
{
    show_debug_message(working_directory)
    var fullPath = argument0;
    if (file_exists(fullPath)) {
       var file = file_text_open_read(fullPath);
       if (string_count("json", argument0) > 0) {
          return load_dialog_json(file)
        } else {
          return load_dialog_flat(file);
        }
    }
}




#define load_dialog_flat
{
    var file = argument0
    var dMap = ds_map_create();
    while (!file_text_eof(file)) 
    {
        var index = file_text_read_string(file);
        file_text_readln(file);
        
        var name = file_text_read_string(file);
        file_text_readln(file);
        
        var dialog = file_text_read_string(file);
        file_text_readln(file);
        
        var list = ds_list_create();
        var listItem = file_text_read_string(file);
        file_text_readln(file);
        
        while (true) {
            show_debug_message(listItem);
            ds_list_add(list,listItem);
            
            if (file_text_eoln(file)) break;
            listItem = file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_readln(file)
        
        show_debug_message(index + " " + name);
        ds_map_add_map(dMap, string(index), create_dialog(name,dialog,list));
           
    }
    file_text_close(file);
    return dMap;
}

#define load_dialog_json
var file = argument0
var jdata = "";
while (!file_text_eof(file)) 
{
    jdata += file_text_read_string(file);
    file_text_readln(file);
}
file_text_close(file);
return json_decode(jdata);