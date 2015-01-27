///save_dialog(name)
json = json_encode(dialogMap);
var file = file_text_open_write(working_directory + "\" + argument0);
file_text_write_string(file, json);
file_text_close(file);