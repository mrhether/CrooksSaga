///load_dialog_flat(filename)

var file = file_text_open_read(working_directory + "\" + argument0);
var jdata = "";
while (!file_text_eof(file)) 
{
    jdata += file_text_read_string(file);
    file_text_readln(file);
}
file_text_close(file);
