#define gms_action_get_argument
//(n)
XServer_verify();
if(XServer_action_get_argument_isreal(argument0))
{
    return gms_action_get_argument_real(argument0);
}else{
    return gms_action_get_argument_string(argument0);
}
#define gms_chat
//(text[, color[, to]])
XServer_verify();

if(!is_string(argument0) || !is_real(argument1))
{
    XServer_error("server_chat: Expected the first argument to be a string, and the second one to be a real");
    exit;
}

var _can_send;
if(argument0 != "")
{
    if(global.__chat_verify_script != -1 && script_exists(global.__chat_verify_script))
    {
        _can_send = script_execute(global.__chat_verify_script, argument0);
        if(!is_real(_can_send))
        {
            XServer_error("The script set by gms_script_set_chat_verify returns a string instead of true or false.");
            exit;
        }
    }else{
        _can_send = 1;
    }
    
    if(_can_send)
    {
        XServer_chat_send_message(argument0, argument1);
        
        ds_list_add(global.__chattime, current_time);
        ds_list_add(global.__chattext, string(argument0));
        ds_list_add(global.__chatcol , argument1);
        ds_list_add(global.__chatsender, gms_self_playerid());
        ds_list_add(global.__chatsendername, gms_self_name());
    }
}
#define gms_chat_bind_pos
XServer_verify();
//server_chat_bind_pos(x1, y1, x2, y2)
if(!is_real(argument0) || !is_real(argument1) || !is_real(argument2) ||  !is_real(argument3))
{
    XServer_error("server_chat_bind_pos: Expected all arguments to be reals, but found one or more strings.");
    exit;
}

global.__chat_bind = 0;
global.__chat_x1   = min(argument0, argument2);
global.__chat_y1   = min(argument1, argument3);
global.__chat_x2   = max(argument0, argument2);
global.__chat_y2   = max(argument1, argument3);
#define gms_chat_bind_room
XServer_verify();
if(!is_real(argument0) || !is_real(argument1))
{
    XServer_error("server_chat_bind_room: Expected all arguments to be reals, but found one or more strings.");exit
}

global.__chat_bind   = 1;
global.__chat_pos    = argument0;
global.__chat_height = argument1;
#define gms_chat_bind_view
///server_chat_bind_view(view_id, up/down (0/1), height);
XServer_verify();
if(!is_real(argument0) || !is_real(argument1) || !is_real(argument2))
{
    XServer_error("server_chat_bind_view: Expected all arguments to be reals, but found one or more strings.");
    exit
}

if(argument0 > 7)
{
    XServer_error("server_chat_bind_view: There are only 8 views (0-7), but got view " + string(argument0) + " as argument.");
    exit
}

global.__chat_bind   = argument0 + 2;
global.__chat_pos    = argument1;
global.__chat_height = argument2;
#define gms_chat_colors
XServer_verify();
//server_chat_colors(textcol, bgcol, bgalpha);

if(!is_real(argument0) || !is_real(argument1) || !is_real(argument2))
{
    XServer_error("server_chat_colors: Expected all arguments to be reals, but found one or more strings.");exit
}

global.__chat_textcol = argument0;
global.__chat_bgcol   = argument1;
global.__chat_bgalpha = argument2;
#define gms_chat_draw
XServer_verify();
if(global.__chat)
{
    //Update position
    if(global.__chat_bind == 1)
    {
        global.__chat_x1 = 0;
        global.__chat_x2 = room_width;
        if(global.__chat_pos == 0)
        {
            global.__chat_y1 = 0;
            global.__chat_y2 = global.__chat_height;
        }else{
            global.__chat_y1 = room_height - global.__chat_height;
            global.__chat_y2 = room_height;
        }
    }else if(global.__chat_bind >= 2 && global.__chat_bind <= 9)
    {
        global.__chat_x1 = view_xview[global.__chat_bind - 2];
        global.__chat_x2 = view_xview[global.__chat_bind - 2] + view_wview[global.__chat_bind - 2];
        if(global.__chat_pos == 0)
        {
            global.__chat_y1 = view_yview[global.__chat_bind - 2];
            global.__chat_y2 = view_yview[global.__chat_bind - 2] + global.__chat_height;
        }else{
            global.__chat_y1 = view_yview[global.__chat_bind - 2] + view_hview[global.__chat_bind - 2] - global.__chat_height;
            global.__chat_y2 = view_yview[global.__chat_bind - 2] + view_hview[global.__chat_bind - 2];
        }
    }else if(global.__chat_bind != 0)
    {
        XServer_error("Unknown way to draw chat set. Maybe the view index was outside the range [0, 7]?");
        exit;
    }
    
    draw_set_color(global.__chat_bgcol);
    draw_set_alpha(global.__chat_bgalpha);
    draw_set_font(global.__chat_font);
    
    if(keyboard_check_pressed(global.__chat_submitkey) && global.__chat_typing)
    {
        if(keyboard_string != "")
        {
            gms_chat(keyboard_string, global.__chat_textcol);
            global.__chat_directclose = 1;
            global.__chat_highl = 1;
        }
        keyboard_string = "";
        global.__chat_typing = false;
    }else
    if(keyboard_check_pressed(global.__chat_togglekey))
    {
        keyboard_string = "";
        global.__chat_typing = !global.__chat_typing;
        global.__chat_directclose = 0;
    }else
    if(keyboard_check_pressed(global.__chat_teamkey) && global.__chat_typing)
    {
        gms_chat_team_only_set(!gms_chat_team_only_get());
    }
    
    if(global.__chat_typing)
    {
        //Increase global.__chat_openani, with an amount of 2 / room_speed 
        global.__chat_openani = min(1, global.__chat_openani + 5 / room_speed);
    }else{
        //Increase global.__chat_openani, with an amount of 2 / room_speed 
        global.__chat_openani = max(0, global.__chat_openani - 5 / room_speed);
    }
    //Increase global.__chat_highl, with an amount of 3 / room_speed 
    global.__chat_highl = max(0, global.__chat_highl - 3 / room_speed);
    
    var _y, _i, _t, __scl;
    _y = global.__chat_y2;
    
    if(global.__chat_small)
    {
    
    }else{
        draw_rectangle(global.__chat_x1, global.__chat_y1, global.__chat_x2, global.__chat_y2, 0);
        draw_rectangle(global.__chat_x1, global.__chat_y1, global.__chat_x2, global.__chat_y2, 1);
        draw_set_alpha(1);
        draw_set_color(global.__chat_textcol);
        draw_set_halign(fa_left);
        if(global.__chat_openani > 0 && !global.__chat_directclose)
        {
            _y -= string_height_ext(gms_self_name() + " " + string_repeat(global.__language_team, gms_chat_team_only_get()) + ": " + keyboard_string, -1, global.__chat_x2 - global.__chat_x1 - 10) * global.__chat_openani;
            
            if(script_exists(global.__chat_colorscript) && global.__chat_colorscript != -1)
            {
                //x, y, username, userid, message, width, yscale, color
                script_execute(global.__chat_colorscript, global.__chat_x1 + 5, _y, gms_self_name(), gms_self_playerid(), keyboard_string + string_repeat("|", (current_time mod 1200) < 600), global.__chat_x2 - global.__chat_x1 - 10, global.__chat_openani, global.__chat_textcol)
            }else{
                draw_text_ext_transformed(global.__chat_x1 + 5, _y, gms_self_name() + ": " + keyboard_string + string_repeat("|", (current_time mod 1200) < 600), -1, global.__chat_x2 - global.__chat_x1 - 10, 1, global.__chat_openani, 0);
            }
            draw_set_alpha(global.__chat_bgalpha / (global.__chat_openani + 1));
            draw_set_color(global.__chat_bgcol)//draw_set_color(c_white);
            draw_rectangle(global.__chat_x1, global.__chat_y2, global.__chat_x2, _y, 0);
        }else if(global.__chat_openani == 0){
            global.__chat_directclose = 0;
        }
        draw_set_alpha(1 / (1 + global.__chat_openani));
        for(_i = gms_chat_num() - 1; _i >= 0 && _y > global.__chat_y1; _i -= 1)
        {
            draw_set_color(gms_chat_get_color(_i))
            _t = string_replace_all(gms_chat_get_text(_i), "#", "\#");
            _y -= string_height_ext(_t, -1, global.__chat_x2 - global.__chat_x1);
            
            if(_y >= global.__chat_y1 + 5)
            {
                __scl = 1;
            }else{
                __scl = 1 - (global.__chat_y1 - _y) / string_height_ext(_t, -1, global.__chat_x2 - global.__chat_x1);
                _y += string_height_ext(_t + "xXgYg", -1, global.__chat_x2 - global.__chat_x1) * (1 - __scl)
            }
            
            if(script_exists(global.__chat_colorscript) && global.__chat_colorscript != -1)
            {
                //x, y, username, userid, message, width, yscale, color
                script_execute(global.__chat_colorscript, global.__chat_x1 + 5, max(_y, global.__chat_y1), gms_chat_get_sendername(_i), gms_chat_get_sender(_i), _t, global.__chat_x2 - global.__chat_x1, __scl, gms_chat_get_color(_i))
            }else{
                var _snder;
                if(gms_chat_get_sendername(_i) != "")
                {
                    _snder = gms_chat_get_sendername(_i) + ": ";
                }else{
                    _snder = "";
                }
                
                draw_text_ext_transformed(global.__chat_x1 + 5, max(_y, global.__chat_y1), _snder + _t, -1, global.__chat_x2 - global.__chat_x1, 1, __scl, 0);
            }
            
            if(_i == gms_chat_num() - 1 && global.__chat_highl > 0)
            {
                draw_set_alpha(global.__chat_bgalpha / 2 * (global.__chat_highl ));
                draw_set_color(c_white);
                draw_rectangle(global.__chat_x1, global.__chat_y2, global.__chat_x2, _y, 0);
                draw_set_alpha(global.__chat_bgalpha / (1 + global.__chat_openani));
            }
        }
    }
}
#define gms_chat_get_color
XServer_verify();
return ds_list_find_value(global.__chatcol, argument0);
#define gms_chat_get_sender
XServer_verify();
return ds_list_find_value(global.__chatsender, argument0);
#define gms_chat_get_sendername
XServer_verify();
return ds_list_find_value(global.__chatsendername, argument0);
#define gms_chat_get_text
XServer_verify();
return ds_list_find_value(global.__chattext, argument0);
#define gms_chat_get_time
XServer_verify();
return ds_list_find_value(global.__chattime, argument0);
#define gms_chat_istyping
return global.__chat_typing;
#define gms_chat_keys
XServer_verify();
//server_chat_keys(Toggle chat, send message, team-only button);
global.__chat_togglekey = argument0;
global.__chat_submitkey = argument1;
global.__chat_teamkey   = argument2;
#define gms_chat_local
XServer_verify();

if(!is_string(argument0) || !is_real(argument1))
{
    XServer_error("server_chat_local: One or more arguments are not of the right type (string, real)")exit
}

if(argument0 != "")
{
    ds_list_add(global.__chattime, current_time);
    ds_list_add(global.__chattext, string(argument0));
    ds_list_add(global.__chatcol , argument1);
    ds_list_add(global.__chatsender, -77);
    ds_list_add(global.__chatsendername, "");
    global.__chat_highl = 1;
}
#define gms_chat_num
XServer_verify();
return ds_list_size(global.__chattext);
#define gms_chat_set_font
global.__chat_font = argument0;
#define gms_chat_team_only_get
XServer_verify();
return global.__chat_teamonly;
#define gms_chat_team_only_set
XServer_verify();
global.__chat_teamonly = !(!real(string(argument0)));
XServer_chat_set_mode(global.__chat_teamonly);
#define gms_chat_toggle
XServer_verify();
global.__chat = !(!real(string(argument0)));
#define gms_draw
//()
if(global.__chat_bubbles)
{
    if(global.__obj_other_player >= 0)
    {
        with(global.__obj_other_player)
        {
            var _w, _alp;
            if(current_time - last_chat_time < 500)
            {
                _alp = (current_time - last_chat_time) / 500;
            }else if(current_time - last_chat_time < 8000)
            {
                _alp = 1;
            }else if(current_time - last_chat_time < 9000)
            {
                _alp = 1 - ((current_time - last_chat_time) - 8000) / 1000;
            }else{
                _alp = 0;
            }
            if(_alp != 0)
            {
                draw_set_alpha(_alp);
                _w = max(0.01, min(string_width(last_chat_message), room_width / 4));
                _w = string_width_ext(last_chat_message, -1, _w);
                _h = string_height_ext(last_chat_message, -1, _w);
                draw_set_color(c_white);
                draw_roundrect(x - _w / 2 - 10, y - _h - sprite_height - 16, x + _w / 2 + 10, y - sprite_height - 6, 0);
                draw_set_color(global.__chat_textcol);
                draw_text_ext(floor(x - _w / 2 - 5), floor(y - _h - sprite_height - 8), last_chat_message, -1, _w);
            }
        }
    }
}

global.__saved_font = global.__last_font;
XWindow_totaldraw();

draw_set_font(global.__saved_font);
draw_set_alpha(1);
draw_set_color(c_black);
#define gms_logout
if(global.__obj_other_player > 0 && instance_exists(global.__obj_other_player))
{
    with(global.__obj_other_player)
    {
        instance_destroy();
    }
}
XServer_logout();
#define gms_friend_send_request
if(!is_real(argument1) || !is_string(argument0))
{
    XServer_error("server_friend_send_request: Expected a string as the first arument and a real as the second argument. Keep in mind a callback script should be provided as a resource, not as a script. There shouldn't be quotes around the script name.")
}

global.__friendrequest_callb = argument1;

XServer_friend_send_request(argument0);
#define gms_global_get
//(variable)
XServer_verify();
if(gms_global_isreal(argument0))
{
    return gms_global_get_real(argument0);
}else{
    return gms_global_get_string(argument0);
}
#define gms_global_set
//(variable, value)
XServer_verify();
if(is_real(argument1))
{
    gms_global_set_real(argument0, argument1);
}else{
    gms_global_set_string(argument0, argument1);
}
#define gms_ini_game_delete
XServer_verify();
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

if(!XServer_require_connection()) return 0;
XServer_ini_game_delete(argument0+">"+argument1);
#define gms_ini_game_exists
return XServer_ini_game_exists(string(argument0)+">"+string(argument1))
#define gms_ini_game_read
XServer_verify();
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

if(!XServer_require_connection()) return 0;
var __n;
__n = argument0+">"+argument1;
if(XServer_ini_game_isreal(__n))
{
    return XServer_ini_game_read_real(__n);
}else{
    return XServer_ini_game_read_string(__n);
}
#define gms_ini_game_write
XServer_verify();
if(!XServer_require_connection()) return 0;
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

var __n;
__n = argument0+">"+argument1;
if(is_real(argument2))
{
    return XServer_ini_game_write_real(__n, argument2);
}else{
    return XServer_ini_game_write_string(__n, argument2);
}
#define gms_ini_player_delete
XServer_verify();
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

XServer_ini_player_delete(argument0+">"+argument1);
#define gms_ini_player_exists
return XServer_ini_player_exists(string(argument0)+">"+string(argument1))
#define gms_ini_player_read
XServer_verify();
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

var __n;
__n = argument0+">"+argument1;
if(XServer_ini_player_isreal(__n))
{
    return XServer_ini_player_read_real(__n);
}else{
    return XServer_ini_player_read_string(__n);
}
#define gms_ini_player_write
XServer_verify();
if(!is_string(argument0) || !is_string(argument1))
{
    XServer_error("GameINI: section & key should be string, but found one or more reals.");
    exit;
}

var __n;
__n = argument0+">"+argument1;
if(is_real(argument2))
{
    return XServer_ini_player_write_real(__n, argument2);
}else{
    return XServer_ini_player_write_string(__n, argument2);
}
#define gms_instance_get
if(gms_instance_isreal(argument0, argument1))
{
    return gms_instance_get_real(argument0, argument1);
}else{
    return gms_instance_get_string(argument0, argument1);
}
#define gms_instance_set
//server_instance_variable_set(id, name, value)
if(is_real(argument2))
{
    gms_instance_set_real(argument0, argument1, argument2);
}else{
    gms_instance_set_string(argument0, argument1, argument2);
}
#define gms_login_error_tostring
XServer_verify();
switch(argument0)
{
    case 0:
        //Actually, this code is used when everything is OK too!
        //But when you can't login, and get this error, the server isn't responding.
        return "Server is not responding to login request. Please try again.";
    case 1:
        return "A password is required when logging in to an account!";
    case 2:
        return "You can't login with a password when the account doesn't exists. Please register first!";
    case 3:
        return "Wrong password!";
    case 4:
        return "Player limit is reached!";
    case 5:
        return "You can't login twice with the same name!";
    case 6:
        return "You're already logged in! (Please contact the developer)";
    case 7:
        return "You have been banned from this game! (contact admin/developer for more info)";
    case 8:
        return "You've been banned from GameMaker Server (For more info, see gamemakerserver.com)";
    case 11:
        return "Username contains invalid characters";
    case 12:
        return "The username has already been used in the highscores";
    case 13:
        return "Could not connect to server";
    default:
        return "Unknown errorcode "+string(argument0);
}
#define gms_login_execute
if(!is_real(argument0))
{
    XServer_error("server_login_execute: Expected the first argument to be a real, but found a string. Please note there should be no quotes around the scripts' name.");
    exit;
}

global.__hide_login = room_speed * 2;
global.__login_finish_script = argument0;
return XServer_login_execute();
#define gms_message_reporting
if(!is_real(argument0))
{
    XServer_error("server_message_reporting: Expected the first argument to be a real, but found a string");
    exit;
}

global.__message_reporting = argument0;
#define gms_optimize_variables
///server_optimize_variables(sync_sprite, sync_imageindex)
if(!is_real(argument0) || !is_real(argument1))
{
    XServer_error("server_optimize_variables: Expected all arguments to be reals, but found one or more strings.");
    exit;
}

global.__sync_sprite = argument0;
global.__sync_imageindex = argument1;
#define gms_other_get
//(player_id, variable)
XServer_verify();
if(gms_other_isreal(argument0, argument1))
{
    return gms_other_get_real(argument0, argument1);
}else{
    return gms_other_get_string(argument0, argument1);
}
#define gms_register_error_tostring
XServer_verify();
switch(argument0)
{
    case 1:
        return "Registration succesful";
    case 2:
        return "The passwords aren't the same";
    case 3:
        return "E-Mail is not valid";
    case 4:
        return "Username has already been taken";
    case 5:
        return "E-Mail has already been taken";
    case 6:
        return "Username needs to be at least 4 characters";
    case 7:
        return "Password needs to be at least 6 characters";
    case 8:
        return "Username contains invalid characters";
    case 9:
        return "You cannot register more than 5 accounts on the same IP-address";
    default:
        return "Unknown errorcode "+string(argument0);
}
#define gms_request_resource
//server_request_resource(type, ind, url, ext)
XServer_request_file(argument2, temp_directory + "\" + string(irandom(999999)) + "." + string(argument3), argument0, argument1);
show_debug_message("Resource requested");
#define gms_script_set_chat_receive
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_chat_recv = argument0;
#define gms_script_set_chat_verify
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
XServer_verify();
global.__chat_verify_script = argument0;
#define gms_script_set_kick
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_kick = argument0;
#define gms_script_set_connection_lost
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_noconnection = argument0;
#define gms_script_set_drawchat
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__chat_colorscript = argument0;
#define gms_script_set_login
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_login  = argument0;
#define gms_script_set_logout
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_logout = argument0;
#define gms_script_set_p2p
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_p2p = argument0;
#define gms_script_set_session_change
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_session = argument0;
#define gms_script_set_vs_end
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_vs_end = argument0;
#define gms_script_set_vs_begin
if(!is_real(argument0)) { XServer_error("When calling a gms_script_* funcion, a real value is required. Please note that the script name should not be between quotes"); exit; }
if(!script_exists(argument0)) { XServer_error("server_script_*: The script provided does not exist. Please make sure you haven't got a resource with the same name as the script"); exit; }
global.__script_vs_begin = argument0;
#define gms_self_set
//(variable, value)
XServer_verify();
if(is_real(argument1))
{
    return XServer_variable_player_set_real(argument0, argument1);
}else{
    return XServer_variable_player_set_string(argument0, argument1);
}
#define gms_settings
//server_settings(simple_mode, version, player, other_player_obj);
if(!gms_info_isconnected())
    gms_connect();

show_debug_message("Connected.");

global.__simple_mode      = !(!real(string(argument0)));
global.__version_num      = real(string(argument1));
gms_setversion(global.__version_num);

if(argument2 < 0 || argument3 < 0)
{
    global.__obj_player       = -100000;
    global.__obj_other_player = -100000;
}else{
    global.__obj_player       = argument2;
    global.__obj_other_player = argument3;
    object_set_persistent(global.__obj_other_player, 1);
}
global.__set              = 1;

if(!instance_exists(global.__obj))
{
    instance_create(0, 0, global.__obj);
}
#define gms_show_achievements
if(global.__xhs_window == -1)
{
    gms_show_replace(wt_achievements, '<constants></constants>

<styles>
	overlay:
	{
		width: max;
		height: max;
		background: $000000;
		background-alpha: 0.0;

		show:
		{
			background-alpha: 0.5;
			tween-speed: 0.02;
		}

		hide:
		{
			background-alpha: 0.0;
			tween-speed: 0.02;
		}
	}

	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: 1;
		width: 640;
		height: 380;
		center: true;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		close-button:
		{
			height: 52;
			font: @f_title;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: 20;
			width: 20;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: 40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: 20;
				arrow-size: 10;
			}
		}

		title-container:
		{
			do-expect: true;
			width: max;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			height: 52;
			width: max;
			text: @txt_achievements;
		}
	}

	achievement-container:
	{
		margin: 10;
		width: max;
		height: max;
	}

	achievement-item:
	{
		width: max;
		title:
		{
			font: @f_text;
			width: min;
			margin-left: 16;

			reached:
			{
				color: @c_grey_text;
			}

			notreached:
			{
				color: $000000;
			}
		}

		reached:
		{
			font: @f_text;
			width: min;
			horizontal-float: true;
			margin-right: 16;

			reached:
			{
				color: @c_grey_text;
			}

			notreached:
			{
				color: $000000;
			}
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}
</styles>

<layout>
	<canvas 
		style[overlay] 
		onopen[overlay.show] 
		onclose[overlay.hide]>
		<canvas 
			style[window, gradientcolor] 
			onopen[window.show] 
			onclose[window.hide]>

			<multielement style[window.title-container, buttoncolor]>
				<label style[window.title_bar] name[achievement-title] />
				<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[achievements.close] />
			</multielement>

			<scrollbox style[achievement-container] name[achievement-container]>
			</scrollbox>
		</canvas>
	</canvas>
</layout>');
}

var _as_container;
_as_container = XWindow_find(global.__xas_window, "achievement-container");

if(_as_container == -1)
{
    show_error("The achievement screen needs an 'achievement-container' element to function properly", false);
}else{
    var _m, _i;
    
    XWindow_destroy_children(_as_container, true);
    
    for(_i = 0; _i < gms_achievement_count(); _i += 1)
    {
        var _reached_str;
        if(gms_achievement_isreached(gms_achievement_find(_i)))
        {
            _reached_str = XWindow_parse_value("@txt_reached", global.__constant_map);
            XWindow_add(_as_container, XWindow_parse_layout("<multielement style[achievement-item]>" + 
                "<label style[achievement-item.title, achievement-item.title.reached]>" + string(gms_achievement_description(gms_achievement_find(_i))) + "</label>" + 
                "<label style[achievement-item.reached, achievement-item.reached.reached]>" + string(_reached_str) + "</label>" + 
                "</multielement>", global.__xas_styles));
        }else{
            _reached_str = XWindow_parse_value("@txt_not_reached", global.__constant_map);
                XWindow_add(_as_container, XWindow_parse_layout("<multielement style[achievement-item]>" + 
                "<label style[achievement-item.title, achievement-item.title.notreached]>" + string(gms_achievement_description(gms_achievement_find(_i))) + "</label>" + 
                "<label style[achievement-item.reached, achievement-item.reached.notreached]>" + string(_reached_str) + "</label>" + 
                "</multielement>", global.__xas_styles));
        }
    }
    
    global.__winel[_as_container, 100] = true;
    XWindow_invalidate_cache(_as_container)
    XWindow_show(global.__xas_window);
}
#define gms_show_friends
if(global.__xfs_window == -1)
{
    gms_show_replace(wt_friends, '<constants></constants>

<styles>
	overlay:
	{
		width: max;
		height: max;
		background: $000000;
		background-alpha: 0.0;

		show:
		{
			background-alpha: 0.5;
			tween-speed: 0.02;
		}

		hide:
		{
			background-alpha: 0.0;
			tween-speed: 0.02;
		}
	}

	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: 1;
		width: 640;
		height: 380;
		center: true;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		close-button:
		{
			height: 52;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: 20;
			width: 20;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: 40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: 20;
				arrow-size: 10;
			}
		}

		title-container:
		{
			do-expect: true;
			width: max;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			text: @txt_friends;
			height: 52;
			width: max;
		}
	}

	friends-container:
	{
		margin: 10;
		width: max;
		height: max;
	}

	friends-item:
	{
		width: max;
		name:
		{
			color: 0;
			font: @f_text;
			width: min;
			margin-left: 16;

			online:
			{
				color: @c_good_color;
			}

			offline:
			{
				color: @c_grey_text;
			}
		}

		online:
		{
			color: 0;
			font: @f_text;
			width: min;
			horizontal-float: true;
			margin-right: 16;

			online:
			{
				color: @c_good_color;
			}

			offline:
			{
				color: @c_grey_text;
			}
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}
</styles>

<layout>
	<canvas 
		style[overlay] 
		onopen[overlay.show] 
		onclose[overlay.hide]>
		<canvas 
			style[window, gradientcolor] 
			onopen[window.show] 
			onclose[window.hide]>

			<multielement style[window.title-container, buttoncolor]>
				<label style[window.title_bar] name[friends-title]></label>
				<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[friends.close] />
			</multielement>

			<scrollbox style[friends-container] name[friends-container]>
			</scrollbox>
		</canvas>
	</canvas>
</layout>');
}

var _fs_container;
_fs_container = XWindow_find(global.__xfs_window, "friends-container");

if(_fs_container == -1)
{
    show_error("The friends screen needs an 'friends-container' element to function properly", false);
}else{
    var _m, _i;
    
    XWindow_destroy_children(_fs_container, true);
    
    for(_i = 0; _i < gms_friend_count(); _i += 1)
    {
        var _reached_str;
        if(gms_friend_isonline(gms_friend_get(_i)))
        {
            _reached_str = XWindow_parse_value("@txt_online", global.__constant_map);
            XWindow_add(_fs_container, XWindow_parse_layout("<multielement style[friends-item]>" + 
                "<label style[friends-item.name, friends-item.name.online]>" + string(gms_friend_name(gms_friend_get(_i))) + "</label>" + 
                "<label style[friends-item.online, friends-item.online.online]>" + string(_reached_str) + "</label>" + 
                "</multielement>", global.__xfs_styles));
        }else{
            _reached_str = XWindow_parse_value("@txt_offline", global.__constant_map);
                XWindow_add(_fs_container, XWindow_parse_layout("<multielement style[friends-item]>" + 
                "<label style[friends-item.name, friends-item.name.offline]>" + string(gms_friend_name(gms_friend_get(_i))) + "</label>" + 
                "<label style[friends-item.online, friends-item.online.offline]>" + string(_reached_str) + "</label>" + 
                "</multielement>", global.__xfs_styles));
        }
    }
    
    global.__winel[_fs_container, 100] = true;
    XWindow_invalidate_cache(_fs_container)
    XWindow_show(global.__xfs_window);
}
#define gms_show_highscore
if(global.__xhs_window == -1)
{
    gms_show_replace(wt_highscores, '<constants></constants>

<styles>
	overlay:
	{
		width: max;
		height: max;
		background: $000000;
		background-alpha: 0.0;

		show:
		{
			background-alpha: 0.5;
			tween-speed: 0.02;
		}

		hide:
		{
			background-alpha: 0.0;
			tween-speed: 0.02;
		}
	}

	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: 1;
		width: 640;
		height: 380;
		center: true;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		close-button:
		{
			height: 52;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: 20;
			width: 20;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: 40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: 20;
				arrow-size: 10;
			}
		}

		title-container:
		{
			do-expect: true;
			width: max;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			height: 52;
			width: max;
		}
	}

	highscore-container:
	{
		margin: 10;
		width: max;
		height: max;
	}

	highscore-item:
	{
		width: max;
		name:
		{
			color: 0;
			font: @f_text;
			width: min;
			margin-left: 16;
		}

		score:
		{
			color: 0;
			font: @f_text;
			width: min;
			horizontal-float: true;
			margin-right: 16;
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}
</styles>

<layout>
	<canvas 
		style[overlay] 
		onopen[overlay.show] 
		onclose[overlay.hide]>
		<canvas 
			style[window, gradientcolor] 
			onopen[window.show] 
			onclose[window.hide]>

			<multielement style[window.title-container, buttoncolor]>
				<label style[window.title_bar] name[highscore-title]>
					Title
				</label>
				<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[highscore.close] />
			</multielement>

			<scrollbox style[highscore-container] name[highscore-container]>
			</scrollbox>
		</canvas>
	</canvas>
</layout>');
}

if(!gms_highscore_list_exists(argument0))
{
    show_error("gms_show_highscore: Highscore list does not exist", false);
}else{
    var _hs_container, _hs_title;
    _hs_container = XWindow_find(global.__xhs_window, "highscore-container");
    _hs_title = XWindow_find(global.__xhs_window, "highscore-title");
    
    if(_hs_container == -1 || _hs_title == -1)
    {
        show_error("The highscore screen needs a 'highscore-container' and a 'highscore-title' element to function properly", false);
    }else{
        var _m, _i;
        
        XWindow_destroy_children(_hs_container, true);
        
        for(_i = 0; _i < gms_highscore_count(argument0); _i += 1)
        {
            XWindow_add(_hs_container, XWindow_parse_layout("<multielement style[highscore-item]>" + 
                "<label style[highscore-item.name]>" + string(gms_highscore_name(argument0, _i)) + "</label>" + 
                "<label style[highscore-item.score]>" + string(gms_highscore_score(argument0, _i)) + "</label>" + 
                "</multielement>", global.__xhs_styles));
        }
        
        global.__winel[_hs_container, 100] = true;
        XWindow_invalidate_cache(_hs_container)
        global.__winel[_hs_title, 62] = gms_highscore_list_title(argument0);
        
        XWindow_show(global.__xhs_window);
    }
}
#define gms_show_login
if(global.__xls_window == -1)
{
    gms_show_replace(wt_login, '<constants>
</constants>

<styles>
overlay:
{
width: max;
height: max;
background: $000000;
background-alpha: 0.0;

show:
{
background-alpha: 0.5;
tween-speed: 0.02;
}

hide:
{
background-alpha: 0.0;
tween-speed: 0.02;
}
}

window:
{
border-size: 1;
border-color: @c_border;
drop-shadow: 6;
alpha: 0.0;
y-offset: 1;
preferred-width: 640;
min-width: 200;
preferred-height: 280;
min-height: 280;
center: true;

width: preferred;
height: preferred;

show:
{
y-offset: 0;
alpha: 1.0;
tween-affects-position: true;
}

hide:
{
y-offset: 1;
alpha: 0.0;
tween-affects-position: true;
}

left:
{
x-offset: -1;
alpha: 0.0;
tween-affects-position: true;
}

center:
{
x-offset: 0;
alpha: 1.0;
tween-affects-position: true;
}

error:
{
x-offset: 0.01;
tween-speed: 0.02;
tween-type: 3;
}

sizeup:
{
preferred-height: 360;
min-height: 360;
tween-affects-position: true;
}

sizedown:
{
preferred-height: 280;
min-height: 280;
tween-affects-position: true;
}

close-button:
{
height: 52;
color: @c_text;
alpha: 0.5;
margin-right: 5;
arrow-size: 10;
arrow-length: 20;
width: 20;
height: 52;

hover:
{
alpha: 1;
arrow-length: 40;
arrow-size: 20;
}

unhover:
{
alpha: 0.5;
arrow-length: 20;
arrow-size: 10;
}
}

title-container:
{
do-expect: true;
width: max;
}

title_bar:
{
color: @c_text;
font: @f_title;
text: @txt_login;
height: 52;
width: max;
}
}

textbox:
{
border-size: 1;
border-color: @c_border;
tip-color: @c_grey_text;
height: 37;
margin: 15;
font: @f_text;
color: @c_text;
width: max;

username:
{
tip-text: @txt_username;
margin-left: 0;

multielement:
{
width: max;
}

guest:
{
margin-right: 0;
text: @txt_guest;
width: 0;
height: 37;
padding-horizontal: 75;
elastic: true;

show:
{
width: min;
tween-speed: 0.05;
tween-affects-position: true;
}

hide:
{
width: 0;
tween-speed: 0.08;
tween-affects-position: true;
}
}
}

password:
{
tip-text: @txt_password;
password: true;
elastic: true;
height: 0.0;
alpha: 0.0;

show:
{
height: 37;
alpha: 1.0;
}

hide:
{
height: 0;
alpha: 0.0;
}
}
}

button:
{
border-size: 1;
border-color: @c_border;
color: @c_text;
font: @f_text;
width: max;
height: 48;
margin: 15;

login:
{
text: @txt_login;
}

register:
{
text: @txt_register;
}

cancel:
{
text: @txt_cancel;
}

hover:
{
background-1: @c_buttonhover1;
background-2: @c_buttonhover1;
background-3: @c_buttonhover2;
background-4: @c_buttonhover2;
}

unhover:
{
background-1: @c_button1;
background-2: @c_button1;
background-3: @c_button2;
background-4: @c_button2;
}
}

textbox-container:
{
margin: 10;
width: max;
height: min;
}

buttoncolor:
{
background-1: @c_button1;
background-2: @c_button1;
background-3: @c_button2;
background-4: @c_button2;
}

gradientcolor:
{
background-1: @c_background1;
background-2: @c_background1;
background-3: @c_background2;
background-4: @c_background2;

hover:
{
background-1: @c_background2;
background-2: @c_background2;
background-3: @c_background1;
background-4: @c_background1;
}

unhover:
{
background-1: @c_background1;
background-2: @c_background1;
background-3: @c_background2;
background-4: @c_background2;
}
}

buttonstrip:
{
multielement:
{
width: max;
height:min;
}

height: min;
width: max;
vertical-float: bottom;
}

tos:
{
text: @txt_tos;
color: $000000;
text-wrapping: true;
font: @f_small;
height: 52;
width: max;
margin-left: 10;
margin-right: 10;
}

error:
{
color: @c_fault_color;
font: @f_small;
text: "";
margin-left: 20;
margin-right: 20;
}
</styles>

<layout>
<canvas 
style[overlay] 
onopen[overlay.show] 
onclose[overlay.hide]
extrawindow[overlay.hide]
unextrawindow[overlay.show]>
<canvas 
style[window, gradientcolor] 
onopen[window.show] 
onclose[window.hide] 
extrawindow[window.left] 
unextrawindow[window.center] 
onerror[window.error]
onunspecial[window.sizeup]
onspecial[window.sizedown]>

<multielement style[window.title-container, buttoncolor]>
<label style[window.title_bar] name[login-title] />
<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[login.close] />
</multielement>

<container style[textbox-container] name[container]>
<multielement style[textbox.username.multielement] name[loginbox]>
<label 
style[buttoncolor, button, textbox.username.guest] 
onopen[textbox.username.guest.show] 
onspecial[textbox.username.guest.show] 
onunspecial[textbox.username.guest.hide]
name[login.username.guest]
/>
<textbox 
style[textbox, textbox.username, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
name[login.username]
/>
</multielement>
<textbox 
style[textbox, textbox.password, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
onspecial[textbox.password.hide]
onunspecial[textbox.password.show]
name[login.password]
/>
</container>

<canvas style[buttonstrip]>
<label style[error] name[login.error] />
<multielement style[buttonstrip.multielement]>
<button style[button, button.login, buttoncolor] hover[button.hover] unhover[button.unhover] name[login.login]/>
<button style[button, button.register, buttoncolor] hover[button.hover] unhover[button.unhover] name[login.register]/>
<button style[button, button.cancel, buttoncolor] hover[button.hover] unhover[button.unhover] name[login.close]/>
</multielement>
<label style[tos] name[login.tos] />
</canvas>
</canvas>
</canvas>
</layout>');
}

XWindow_show(global.__xls_window);
XWindow_tb_select_all(XWindow_find(global.__xls_window, "login.username"));

global.__xls_from_object = id;
#define gms_show_message
//text

if(global.__xms_window == -1)
{
    gms_show_replace(wt_message, '<constants></constants>

<styles>
	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: -0.5;
		x-offset: 0.1;
		preferred-width: 360;
		min-width: 280;
		height: 60;
		width: min;
		horizontal-float: 1;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: -0.5;
			alpha: 0.0;
			tween-affects-position: true;
		}

		title-container:
		{
			do-expect: true;
			width: min;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			text-wrapping: false;
			height: 52;
			width: min;
			padding-horizontal: 10;
		}

		close-button:
		{
			height: 52;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: -20;
			width: 30;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: -40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: -20;
				arrow-size: 10;
			}
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}

	message:
	{
		font: @f_title;
		margin: 10;
	}
</styles>

<layout>
	<canvas 
		style[window, gradientcolor] 
		onopen[window.show] 
		onclose[window.hide]>

		<multielement style[window.title-container] name[message-box]>
			<label style[window.title_bar] name[message-title]>Size43 logged in</label>
			<arrow name[message.close] style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] />
		</multielement>
	</canvas>
</layout>');
}

if(ds_queue_size(global.__xmessage_queue) == 0 && global.__xms_waittime <= 0)
{
    var _textfield;
    _textfield = XWindow_find(global.__xms_window, "message-title");
    if(_textfield == -1)
    {
        show_error("Message screen needs a 'message-title'-element to function properly", 1);
    }else{
        global.__winel[_textfield, 62] = argument0;
        global.__winel[_textfield, 100] = true;
        global.__xms_waittime = room_speed * 5;
        XWindow_show(global.__xms_window);
    }
}else{
    ds_queue_enqueue(global.__xmessage_queue, argument0);
}
#define gms_show_register
if(global.__xrs_window == -1)
{
    gms_show_replace(wt_register, '<constants></constants>
<styles>
overlay:
{
width: max;
height: max;
background: $000000;
background-alpha: 0.0;

show:
{
background-alpha: 0.5;
tween-speed: 0.02;
}

hide:
{
background-alpha: 0.0;
tween-speed: 0.02;
}
}

window:
{
border-size: 1;
border-color: @c_border;
drop-shadow: 6;
alpha: 0.0;
y-offset: 1;
width: preferred;
preferred-width: 640;
preferred-height: 380;
min-height: 320;
center: true;

show:
{
y-offset: 0;
alpha: 1.0;
tween-affects-position: true;
}

hide:
{
y-offset: 1;
alpha: 0.0;
tween-affects-position: true;
}

left:
{
x-offset: -1;
tween-affects-position: true;
}

center:
{
x-offset: 0;
tween-affects-position: true;
}

error:
{
x-offset: 0.01;
tween-speed: 0.02;
tween-type: 3;
}

close-button:
{
height: 52;
font: @f_title;
color: @c_text;
alpha: 0.5;
margin-right: 5;
arrow-size: 10;
arrow-length: 20;
width: 20;
height: 52;

hover:
{
alpha: 1;
arrow-length: 40;
arrow-size: 20;
}

unhover:
{
alpha: 0.5;
arrow-length: 20;
arrow-size: 10;
}
}

title-container:
{
do-expect: true;
width: max;
}

title_bar:
{
color: @c_text;
font: @f_title;
text: @txt_register;
height: 52;
width: max;
}
}

textbox:
{
border-size: 1;
border-color: @c_border;
tip-color: @c_grey_text;
height: 37;
margin: 15;
margin-bottom: 0;
font: @f_text;
color: @c_text;
width: max;

username:
{
tip-text: @txt_username;
}

password:
{
tip-text: @txt_password;
password: true;
}

password-again:
{
tip-text: @txt_repeat_password;
password: true;
}

email:
{
tip-text: @txt_email;
}
}

button:
{
border-size: 1;
border-color: @c_border;
color: @c_text;
font: @f_text;
width: max;
height: 48;
margin: 15;

register:
{
text: @txt_register;
}

cancel:
{
text: @txt_cancel;
}

hover:
{
background-1: @c_buttonhover1;
background-2: @c_buttonhover1;
background-3: @c_buttonhover2;
background-4: @c_buttonhover2;
}

unhover:
{
background-1: @c_button1;
background-2: @c_button1;
background-3: @c_button2;
background-4: @c_button2;
}
}

textbox-container:
{
margin: 10;
width: max;
height: min;
}

buttoncolor:
{
background-1: @c_button1;
background-2: @c_button1;
background-3: @c_button2;
background-4: @c_button2;
}

gradientcolor:
{
background-1: @c_background1;
background-2: @c_background1;
background-3: @c_background2;
background-4: @c_background2;

hover:
{
background-1: @c_background2;
background-2: @c_background2;
background-3: @c_background1;
background-4: @c_background1;
}

unhover:
{
background-1: @c_background1;
background-2: @c_background1;
background-3: @c_background2;
background-4: @c_background2;
}
}

buttonstrip:
{
multielement:
{
width: max;
height:min;
}

height: min;
width: max;
vertical-float: bottom;
}

error:
{
color: @c_fault_color;
font: @f_small;
text: "";
margin-left: 20;
margin-right: 20;
}
</styles>

<layout>
<canvas 
style[overlay] 
onopen[overlay.show] 
onclose[overlay.hide]
extrawindow[overlay.hide]
unextrawindow[overlay.show]>
<canvas 
style[window, gradientcolor] 
onopen[window.show] 
onclose[window.hide] 
extrawindow[window.left] 
unextrawindow[window.center] 
onerror[window.error]>

<multielement style[window.title-container, buttoncolor]>
<label style[window.title_bar] name[highscore-title] />
<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[register.close] />
</multielement>

<container style[textbox-container] name[container]>
<textbox 
style[textbox, textbox.username, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
name[register.username]
/>
<textbox 
style[textbox, textbox.password, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
name[register.password]
/>
<textbox 
style[textbox, textbox.password-again, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
name[register.password-again]
/>
<textbox 
style[textbox, textbox.email, gradientcolor]
hover[gradientcolor.hover]
unhover[gradientcolor.unhover]
name[register.mail]
/>
</container>

<canvas style[buttonstrip]>
<label style[error] name[register.error] />
<multielement style[buttonstrip.multielement]>
<button style[button, button.register, buttoncolor] hover[button.hover] unhover[button.unhover] name[register.register]/>
<button style[button, button.cancel, buttoncolor] hover[button.hover] unhover[button.unhover] name[register.close]/>
</multielement>
</canvas>
</canvas>
</canvas>
</layout>');
}

XWindow_show(global.__xrs_window);
XWindow_tb_select_all(XWindow_find(global.__xrs_window, "register.username"));
#define gms_show_set_allowguest
global.__ls_allow_guest   = !!argument0;
#define gms_show_statistics
if(global.__xss_window == -1)
{
    gms_show_replace(wt_statistics, '<constants></constants>

<styles>
	overlay:
	{
		width: max;
		height: max;
		background: $000000;
		background-alpha: 0.0;

		show:
		{
			background-alpha: 0.5;
			tween-speed: 0.02;
		}

		hide:
		{
			background-alpha: 0.0;
			tween-speed: 0.02;
		}
	}

	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: 1;
		width: 640;
		height: 380;
		center: true;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		close-button:
		{
			height: 52;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: 20;
			width: 20;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: 40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: 20;
				arrow-size: 10;
			}
		}

		title-container:
		{
			do-expect: true;
			width: max;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			text: @txt_statistics;
			height: 52;
			width: max;
		}
	}

	statistics-container:
	{
		margin: 10;
		width: max;
		height: max;
	}

	statistics-item:
	{
		width: max;
		title:
		{
			color: 0;
			font: @f_text;
			width: min;
			margin-left: 16;
		}

		value:
		{
			color: 0;
			font: @f_text;
			width: min;
			horizontal-float: true;
			margin-right: 16;
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}
</styles>

<layout>
	<canvas 
		style[overlay] 
		onopen[overlay.show] 
		onclose[overlay.hide]>
		<canvas 
			style[window, gradientcolor] 
			onopen[window.show] 
			onclose[window.hide]>

			<multielement style[window.title-container, buttoncolor]>
				<label style[window.title_bar] name[statistics-title]></label>
				<arrow style[window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] name[statistics.close] />
			</multielement>

			<scrollbox style[statistics-container] name[statistics-container]>
			</scrollbox>
		</canvas>
	</canvas>
</layout>');
}

var _ss_container;
_ss_container = XWindow_find(global.__xss_window, "statistics-container");

if(_ss_container == -1)
{
    show_error("The statistics screen needs an 'statistics-container' element to function properly", false);
}else{
    var _m, _i;
    
    XWindow_destroy_children(_ss_container, true);
    
    for(_i = 0; _i < gms_statistic_count(); _i += 1)
    {
        XWindow_add(_ss_container, XWindow_parse_layout("<multielement style[statistics-item]>" + 
            "<label style[statistics-item.title]>" + string(gms_statistic_description(gms_statistic_find(_i))) + "</label>" + 
            "<label style[statistics-item.value]>" + string(gms_statistic_get(gms_statistic_find(_i))) + "</label>" + 
            "</multielement>", global.__xss_styles));
    }
    
    global.__winel[_ss_container, 100] = true;
    XWindow_invalidate_cache(_ss_container)
    XWindow_show(global.__xss_window);
}
#define gms_show_update
if(gms_update_check())
{
    if(global.__xus_window == -1)
    {
        gms_show_replace(wt_update, '<constants></constants>

<styles>
	overlay:
	{
		width: max;
		height: max;
		background: $000000;
		background-alpha: 0.0;

		show:
		{
			background-alpha: 0.5;
			tween-speed: 0.02;
		}

		hide:
		{
			background-alpha: 0.0;
			tween-speed: 0.02;
		}
	}

	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		y-offset: 1;
		preferred-width: 480;
		min-width: 320;
		height: 140;
		width: preferred;
		center: true;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		title-container:
		{
			do-expect: true;
			width: max;
		}

		title_bar:
		{
			color: @c_text;
			font: @f_title;
			text: @txt_updating_game;
			height: 52;
			width: max;
		}
	}

	buttoncolor:
	{
		background-1: @c_button1;
		background-2: @c_button1;
		background-3: @c_button2;
		background-4: @c_button2;
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}

	progress-bar-box:
	{
		width: max;
		border-size: 1;
		border-color: @c_text;
		height: 52;
		margin: 20;
	}

	progress-bar:
	{
		width: 0;
		height: max;
		elastic: false;
	}
</styles>

<layout>
	<canvas 
		style[overlay] 
		onopen[overlay.show] 
		onclose[overlay.hide]>
		<canvas 
			style[window, gradientcolor] 
			onopen[window.show] 
			onclose[window.hide]>

			<multielement style[window.title-container, buttoncolor]>
				<label style[window.title_bar] name[friends-title]></label>
			</multielement>

			<button style[progress-bar-box] name[progress-bar-box]>
				<label style[buttoncolor, progress-bar] name[progress-bar]/>
			</button>
		</canvas>
	</canvas>
</layout>');
    }
    

    gms_update_start();
    XWindow_show(global.__xus_window);
}
#define gms_show_keyboard
if(global.__xkb_window == -1)
{
    gms_show_replace(wt_keyboard, '<constants></constants>

<styles>
	window:
	{
		border-size: 1;
		border-color: @c_border;
		drop-shadow: 6;
		alpha: 0.0;
		background-alpha: 0.9;
		y-offset: 1;
		width: max;
		overlapping: true;
		height: 169;

		show:
		{
			y-offset: 0;
			alpha: 1.0;
			tween-speed: 0.04;
			tween-affects-position: true;
		}

		hide:
		{
			y-offset: 1;
			alpha: 0.0;
			tween-affects-position: true;
		}

		close-button:
		{
			height: 52;
			color: @c_text;
			alpha: 0.5;
			margin-right: 5;
			arrow-size: 10;
			arrow-length: 20;
			width: max;
			height: 52;

			hover:
			{
				alpha: 1;
				arrow-length: 40;
				arrow-size: 20;
			}

			unhover:
			{
				alpha: 0.5;
				arrow-length: 20;
				arrow-size: 10;
			}
		}
	}

	keyrow:
	{
		width: max;
	}

	keyboard:
	{
		key:
		{
			width: max;
			height: 52;
			font: @f_title;
			color: @c_text;
			margin: 2;

			background-1: @c_button1;
			background-2: @c_button1;
			background-3: @c_button2;
			background-4: @c_button2;

			hover:
			{
				background-1: @c_buttonhover1;
				background-2: @c_buttonhover1;
				background-3: @c_buttonhover2;
				background-4: @c_buttonhover2;
			}

			unhover:
			{
				background-1: @c_button1;
				background-2: @c_button1;
				background-3: @c_button2;
				background-4: @c_button2;
			}
		}

		x-offset: 0;
		shiftleft:
		{
			x-offset: -1;
			alpha: 0;
			tween-speed: 0.06;
			tween-affects-position: true;
		}

		shift0:
		{
			x-offset: 0;
			alpha: 1;
			tween-speed: 0.06;
			tween-affects-position: true;
		}

		shiftright:
		{
			x-offset: 1;
			alpha: 0;
			tween-speed: 0.06;
			tween-affects-position: true;
		}

		normalkeys:
		{
			width: max;
			height: max;
			x-offset: 0;
			tween-affects-position: true;
		}

		numkeys:
		{
			width: max;
			height: max;
			x-offset: 1;
			alpha: 0;
			tween-affects-position: true;
		}

		extrakeys:
		{
			width: max;
			height: max;
			x-offset: 1;
			alpha: 0;
			tween-affects-position: true;
		}
	}

	gradientcolor:
	{
		background-1: @c_background1;
		background-2: @c_background1;
		background-3: @c_background2;
		background-4: @c_background2;

		hover:
		{
			background-1: @c_background2;
			background-2: @c_background2;
			background-3: @c_background1;
			background-4: @c_background1;
		}

		unhover:
		{
			background-1: @c_background1;
			background-2: @c_background1;
			background-3: @c_background2;
			background-4: @c_background2;
		}
	}
</styles>

<layout>
	<canvas 
		style[window, gradientcolor] 
		onopen[window.show] 
		onclose[window.hide]>

		<container name[normal-keys] style[keyboard.normalkeys] extrawindow[keyboard.shiftleft] unextrawindow[keyboard.shift0]>
			<multielement style[keyrow]>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>Q</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>W</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>E</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>R</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>T</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>Y</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>U</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>I</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>O</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>P</button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.numkey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>0..9</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>A</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>S</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>D</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>F</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>G</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>H</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>J</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>K</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>L</button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.shiftkey] style[keyboard.key] onspecial[keyboard.key.hover] onunspecial[keyboard.key]>Shift</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>Z</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>X</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>C</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>V</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>B</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>N</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>M</button>
				<button name[keyboard.backspacekey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\<-</button>
				<arrow name[keyboard.closekey] style[keyboard.key, window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] />
			</multielement>
		</container>
			
		<container name[num-keys] style[keyboard.numkeys] extrawindow[keyboard.shift0] unextrawindow[keyboard.shiftright] onspecial[keyboard.shiftleft] onunspecial[keyboard.shift0]>
			<multielement style[keyrow]>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>0</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>1</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>2</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>3</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>4</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>5</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>6</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>7</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>8</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>9</button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.normalkey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>a..z</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>-</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\/</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>:</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>;</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>(</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>)</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>$</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>&</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>@</button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.extrakey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\#+=</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>.</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\,</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>?</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>!</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>' + "'" + '</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>"</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>_</button>
				<button name[keyboard.backspacekey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\<-</button>
				<arrow name[keyboard.closekey] style[keyboard.key, window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] />
			</multielement>
		</container>
			
		<container name[extra-keys] style[keyboard.extrakeys] onspecial[keyboard.shift0] onunspecial[keyboard.shiftright]>
			<multielement style[keyrow]>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\[</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\]</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>{</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>}</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>#</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>%</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>^</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>*</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>+</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>=</button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.numkey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>0..9</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\\</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>|</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>~</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\<</button>
				<button name[keyboard.key] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\></button>
			</multielement>

			<multielement style[keyrow]>
				<button name[keyboard.backspacekey] style[keyboard.key] hover[keyboard.key.hover] unhover[keyboard.key]>\<-</button>
				<arrow name[keyboard.closekey] style[keyboard.key, window.close-button] hover[window.close-button.hover] unhover[window.close-button.unhover] />
			</multielement>
		</container>
	</canvas>
</layout>');
}

XWindow_show(global.__xkb_window);
#define gms_show_replace
show_debug_message("Replacing window " + string(argument0));

switch(argument0)
{
    case wt_login: 
        global.__xls_window = XWindow_load(argument1);
        global.__xls_styles = __style_info;
        break;
    case wt_highscores:
        global.__xhs_window = XWindow_load(argument1);
        global.__xhs_styles = __style_info;
        break;
    case wt_achievements:
        global.__xas_window = XWindow_load(argument1);
        global.__xas_styles = __style_info;
        break;
    case wt_statistics:
        global.__xss_window = XWindow_load(argument1);
        global.__xss_styles = __style_info;
        break;
    case wt_friends:
        global.__xfs_window = XWindow_load(argument1);
        global.__xfs_styles = __style_info;
        break;
    case wt_update:
        global.__xus_window = XWindow_load(argument1);
        global.__xus_styles = __style_info;
        break;
    case wt_keyboard:
        global.__xkb_window = XWindow_load(argument1);
        global.__xkb_styles = __style_info;
        break;
    case wt_message:
        global.__xms_window = XWindow_load(argument1);
        global.__xms_styles = __style_info;
        break;
    case wt_register:
        global.__xrs_window = XWindow_load(argument1);
        global.__xrs_styles = __style_info;
        break;
    default: show_error("Unknown window to replace: " + string(argument0) + "; Must be a wt_* constant.", true);
}
#define gms_show_set_position
global.__xw_x1 = argument0;
global.__xw_y1 = argument1;
global.__xw_x2 = argument2;
global.__xw_y2 = argument3;
#define gms_show_set_constant
ds_map_replace(global.__constant_map, "@" + string(argument0), argument1);
#define gms_show_isopen
switch(argument0)
{
    case wt_login: return global.__xls_open;
    case wt_highscores: return global.__xhs_open;
    case wt_achievements: return global.__xas_open;
    case wt_statistics: return global.__xss_open;
    case wt_friends: return global.__xfs_open;
    case wt_update: return global.__xus_open;
    case wt_keyboard: return global.__xkb_open;
    case wt_message: return global.__xms_open;
    case wt_register: return global.__xrs_open;
    default: show_error("Unknown window: " + string(argument0) + "; Must be a wt_* constant.", true);
}
#define gms_show_set_fonts
global.__f_title = argument0;
global.__f_text = argument1;
global.__f_small = argument2;
#define gms_step
//()
if(!global.__set) return 0;
global.__step += 1;
__m = current_time;
//DLL actions
//show_debug_message("Begin step");
if(global.__simple_mode)
{
    XServer_variable_player_set_real("room", room);
    if(global.__obj_player >= 0)
    {
        with(global.__obj_player)
        {
            XServer_variable_player_set_real("x", x);
            XServer_variable_player_set_real("y", y);
            //if(global.__enable_spc)
            //{
            //    XServer_variable_player_set_real("direction", point_direction(xprevious, yprevious, x, y));
            //    XServer_variable_player_set_real("speed", point_distance(x, y, xprevious, yprevious));
            //}else{
                XServer_variable_player_set_real("direction", direction);
                XServer_variable_player_set_real("speed", speed);
            //}
            
            if(global.__sync_sprite) 
            {
                if(global.__sync_imageindex) 
                    XServer_variable_player_set_real("image_index", image_index);
                XServer_variable_player_set_real("sprite_index", sprite_index);
                XServer_variable_player_set_real("image_speed", image_speed);
                XServer_variable_player_set_real("image_xscale", image_xscale);
                XServer_variable_player_set_real("image_yscale", image_yscale);
                XServer_variable_player_set_real("image_alpha", image_alpha);
                XServer_variable_player_set_real("image_angle", image_angle);
                XServer_variable_player_set_real("image_blend", image_blend);
            }
            XServer_variable_player_set_real("visible", visible);
            XServer_variable_player_set_real("depth", depth);
            XServer_variable_player_set_real("solid", solid);
            XServer_variable_player_set_real("friction", friction);
            
            XServer_variable_player_set_real("gravity", gravity);
            XServer_variable_player_set_real("gravity_direction", gravity_direction);
            XServer_variable_player_set_real("health", health);
            XServer_variable_player_set_real("lives", lives);
        }
    }
}
__ret = XServer_step();
//show_debug_message("Beginning GML step");
global.__dll_time = __ret;
if(global.__hide_login > 0) { global.__hide_login -= 1; }

if(keyboard_check_direct(vk_tab))
{
    global.__tablast += 1;
}else{
    global.__tablast = 0;
}
global.__tabpressed = global.__tablast == 1;

//Handle actions
var __max__count;
__max__count = 0;
if(!global.__in_action)
{
    global.__in_action = 0;
    do{
        __max__count += 1;
        //if(gms_action_get_id() != 0) show_message(string(gms_action_get_id()) + " from: "+string(gms_action_get_sender()));
        switch(gms_action_get_id())
        {
            case 1://Player login
                if(global.__obj_other_player >= 0)
                {
                    i = instance_create(0, 0, global.__obj_other_player);
                    i.player_id = gms_action_get_sender();
                    i.last_chat_message = "";
                    i.last_chat_time = 0;
                    i.last_chat_color = 0;
                    i.name = gms_action_get_argument_string(0);
                    if(global.__script_login != -1 && script_exists(global.__script_login))
                    {
                        script_execute(global.__script_login, i);
                    }
                }else{
                    if(global.__script_login != -1 && script_exists(global.__script_login))
                    {
                        script_execute(global.__script_login, gms_action_get_sender());
                    }
                }
                if(global.__message_reporting & mt_player_login && !global.__hide_login)
                {
                    gms_show_message(gms_action_get_argument_string(0) + " logged in");
                }
                //gms_chat_local(string(i.name) + " just logged in!", c_green);
                break;
            case 2://Player logout
                if(global.__obj_other_player >= 0)
                {
                    with(global.__obj_other_player)
                    {
                        if(player_id == gms_action_get_sender())
                        {
                            //gms_chat_local(name+" logged out!", c_red);
                            if(global.__message_reporting & mt_player_logout && !global.__hide_login)
                            {
                                gms_show_message(name + " logged out");
                            }
                            if(global.__script_logout != -1 && script_exists(global.__script_logout))
                            {
                                script_execute(global.__script_logout, id);
                            }
                            instance_destroy();
                        }
                    }
                }
                break;
            case 3://Chat
                ds_list_add(global.__chattime, current_time);
                __name = "";
                if(gms_action_get_sender() == 65535)
                {
                    __name = "SERVER";
                }else
                if(gms_action_get_sender() == 65534)
                {
                    __name = "";
                }else
                {
                    __name = string(gms_other_get_string(gms_action_get_sender(), "name"));
                }
                ds_list_add(global.__chattext, gms_action_get_argument_string(1));
                ds_list_add(global.__chatcol , gms_action_get_argument_real(0));
                ds_list_add(global.__chatsender, gms_action_get_sender());
                ds_list_add(global.__chatsendername, __name);
                if(global.__simple_mode)
                {
                    if(global.__obj_other_player >= 0)
                    {
                        with(global.__obj_other_player)
                        {
                            if(player_id == gms_action_get_sender())
                            {
                                last_chat_message = gms_action_get_argument_string(1);
                                last_chat_color   = gms_action_get_argument_real(0);
                                last_chat_time    = current_time;
                            }
                        }
                    }
                }
                global.__chat_highl = 1;
                if(global.__script_chat_recv != -1 && script_exists(global.__script_chat_recv))
                {
                    script_execute(global.__script_chat_recv, gms_action_get_sender(), gms_action_get_argument_string(1), gms_action_get_argument_real(0));
                }
                break;
            case 5://Error call
                XServer_error(gms_action_get_argument_string(0));
                break;
            case 6:
                //Resource request
                switch(gms_action_get_sender())
                {
                    case 0://Sounds
                        for(__i = 0; __i < 1000; __i += 1)
                        {
                            if(sound_exists(__i))
                            {
                                XServer_set_resource(0, __i, sound_get_name(__i));
                            }
                        }
                        break;
                    case 1://Objects
                        for(__i = 0; __i < 1000; __i += 1)
                        {
                            if(object_exists(__i))
                            {
                                XServer_set_resource(1, __i, object_get_name(__i));
                            }
                        }
                        break;
                    case 2://Rooms
                        for(__i = 0; __i < 1000; __i += 1)
                        {
                            if(room_exists(__i))
                            {
                                XServer_set_resource(2, __i, room_get_name(__i));
                            }
                        }
                        break;
                    case 3://Scripts
                        for(__i = 0; __i < 1000; __i += 1)
                        {
                            if(script_exists(__i))
                            {
                                XServer_set_resource(3, __i, script_get_name(__i));
                            }
                        }
                        break;
                    case 4://Sprites
                        for(__i = 0; __i < 1000; __i += 1)
                        {
                            if(sprite_exists(__i))
                            {
                                //show_message("Setting sprite"+sprite_get_name(__i))
                                XServer_set_resource_spritename(sprite_get_name(__i));
                                XServer_set_resource_sprite(__i, sprite_get_width(__i), sprite_get_height(__i), sprite_get_xoffset(__i), sprite_get_yoffset(__i), sprite_get_bbox_top(__i), sprite_get_bbox_left(__i), sprite_get_bbox_right(__i), sprite_get_bbox_bottom(__i));
                            }
                        }
                        break;
                }
                break;
            case 7://Sound_play call
                if(sound_exists(gms_action_get_sender()))
                {
                    sound_play(gms_action_get_sender());
                }
                break;
            case 8://Sound_loop call
                if(sound_exists(gms_action_get_sender()))
                {
                    sound_loop(gms_action_get_sender());
                }
                break;
            case 9://Sound_stop call
                if(sound_exists(gms_action_get_sender()))
                {
                    sound_stop(gms_action_get_sender());
                }
                break;
            case 10://P2p message
                var __arg, __n;
                if(global.__script_p2p == -1 || !script_exists(global.__script_p2p))
                {
                    XServer_error("Received a P2P message, but no script is set to handle P2P messages. gms_script_set_p2p(script) should be called before any P2P messages are received.");
                }
                
                __n = gms_action_get_argument_real(1);
                __arg = ds_list_create();
                for(__i = 0; __i < __n; __i += 1)
                {
                    ds_list_add(__arg, gms_action_get_argument(__i + 2));
                }
                if(global.__script_p2p != -1 && script_exists(global.__script_p2p))
                {
                    script_execute(global.__script_p2p, gms_action_get_argument_real(0), gms_action_get_sender(), __arg);
                    ds_list_destroy(__arg);
                }
                break;
            case 11://Server instance syncOnce destroy
                var __i;
                __i = gms_action_get_argument_real(1)
                if(__i != 0)
                {
                    if(instance_exists(__i))
                    {
                        with(__i) { instance_destroy(); }
                    }
                }
                break;
            //case 12://Instance sync extended / Full SyncID sender
            //    ds_map_add(global.__instanceMap, gms_action_get_argument_real(1), gms_action_get_argument_real(0));
            //    ds_map_add(global.__instanceMapI, gms_action_get_argument_real(0), gms_action_get_argument_real(1));
            //    break;
            case 4://OneTime instance sync;
                if(debug_mode) show_debug_message("Received instance to sync: is_onetime");
                if(object_exists(gms_action_get_argument_real(1)))
                {
                    global.__can_sync = 0;
                    __i = instance_create(gms_action_get_argument_real(2), gms_action_get_argument_real(3), gms_action_get_argument_real(1));
                    __i.direction = gms_action_get_argument_real(4);
                    __i.speed = gms_action_get_argument_real(5);
                    __i.variable_map = ds_map_create();
                    for(__j = 0; __j < gms_action_get_argument_real(6); __j += 1)
                    {
                        ds_map_add(__i.variable_map, gms_action_get_argument_name(__j + 7), gms_action_get_argument(__j + 7));
                        with(__i)
                        {
                            XServer_variable_local_set(gms_action_get_argument_name(other.__j + 7), gms_action_get_argument(other.__j + 7));
                        }
                    }
                    
                    //__i.x = gms_action_get_argument_real(2);
                    //__i.y = gms_action_get_argument_real(3);
                    __i.owner = gms_action_get_sender();
                    global.__can_sync = 1;
                    with(__i){ event_user(12) }
                }
                break;
            case 14://Full instance sync
                if(debug_mode) show_debug_message("Received instance to sync: is_full " + string(gms_action_get_argument_real(1)) + " / " + object_get_name(gms_action_get_argument_real(1)));
                if(object_exists(gms_action_get_argument_real(1)))
                {
                    //show_message("IS");
                    global.__can_sync = 0;
                    __i = instance_create(gms_action_get_argument_real(2), gms_action_get_argument_real(3), gms_action_get_argument_real(1));
                    if(instance_exists(__i))
                    {
                        __i.direction = gms_action_get_argument_real(4);
                        __i.speed = gms_action_get_argument_real(5);
                        __i.syncID = gms_action_get_argument_real(0);
                        __i.owner = gms_action_get_sender();
                        __i.variable_map = ds_map_create();
                        for(__j = 0; __j < gms_action_get_argument_real(6); __j += 1)
                        {
                            ds_map_add(__i.variable_map, gms_action_get_argument_name(__j + 7), gms_action_get_argument(__j + 7));
                            with(__i)
                            {
                                XServer_variable_local_set(gms_action_get_argument_name(other.__j + 7), gms_action_get_argument(other.__j + 7));
                            }
                        }
                        
                        //ds_map_add(global.__instanceMap, gms_action_get_argument_real(0), __i);
                        //ds_map_add(global.__instanceMapI, __i, gms_action_get_argument_real(0)); 
                        //ds_list_add(global.__instanceList, __i);
                        XServer_linksync(__i, __i.syncID);
                        with(__i){ event_user(12) }
                    }else{
                        gms_instance_sync_destroy(gms_action_get_argument_real(0));
                    }
                    global.__can_sync = 1;
                }
                break;
            case 13://Instance sync extended
                if(debug_mode) show_debug_message("Received instance to sync: is_extended");
                if(object_exists(gms_action_get_argument_real(1)))
                {
                    global.__can_sync = 0;
                    __i = instance_create(gms_action_get_argument_real(2), gms_action_get_argument_real(3), gms_action_get_argument_real(1));
                    if(instance_exists(__i))
                    {
                        __i.direction = gms_action_get_argument_real(4);
                        __i.speed = gms_action_get_argument_real(5);
                        __i.syncID = gms_action_get_argument_real(0);
                        __i.owner = gms_action_get_sender();
                        
                        __i.variable_map = ds_map_create();
                        for(__j = 0; __j < gms_action_get_argument_real(6); __j += 1)
                        {
                            ds_map_add(__i.variable_map, gms_action_get_argument_name(__j + 7), gms_action_get_argument(__j + 7));
                            with(__i)
                            {
                                XServer_variable_local_set(gms_action_get_argument_name(other.__j + 7), gms_action_get_argument(other.__j + 7));
                            }
                        }
                        
                        //ds_map_add(global.__instanceMap, gms_action_get_argument_real(0), __i);
                        //ds_map_add(global.__instanceMapI, __i, gms_action_get_argument_real(0)); 
                        //ds_list_add(global.__instanceList, __i);
                        XServer_linksync(__i, __i.syncID);
                        with(__i){ event_user(12) }
                    }else{
                        gms_instance_sync_destroy(gms_action_get_argument_real(0));
                    }
                    global.__can_sync = 1;
                }
                break;
            case 15:
                if(global.__message_reporting & mt_friend_login && !global.__hide_login)
                {
                    gms_show_message(gms_friend_name(gms_action_get_sender()) + " is now online");
                }
                break;
            case 16:
                if(global.__message_reporting & mt_friend_logout && !global.__hide_login)
                {
                    gms_show_message(gms_friend_name(gms_action_get_sender()) + " is now offline");
                }
                break;
            case 17:
                if(global.__message_reporting & mt_achievement_get)
                {
                    gms_show_message(global.__as_get + " " + gms_action_get_argument_string(0))
                }
                break;
            case 18:
                if(global.__obj_player >= 0)
                {
                    with(global.__obj_player)
                    {
                        XServer_variable_local_set(gms_action_get_argument_name(0), gms_action_get_argument(0));
                    }
                }
                break;
            case 19:
                if(global.__script_noconnection != -1 && script_exists(global.__script_noconnection))
                {
                    script_execute(global.__script_noconnection, "Disconnect");
                }
                break;
            case 20:
                if(global.__script_kick != -1 && script_exists(global.__script_kick))
                {
                    script_execute(global.__script_kick, gms_action_get_argument_string(0));
                }
                break;
            case 21:
                if(room_exists(gms_action_get_argument_real(0)))
                    room_goto(gms_action_get_argument_real(0));
                break;
            case 22:
                show_debug_message("Server command: room_goto_next()");
                room_goto_next();
                break;
            case 23:
                show_debug_message("Server command: room_goto_previous()");
                room_goto_previous();
                break;
            case 24:
                show_debug_message("Server command: room_restart()");
                room_restart();
                break;
            case 25:
                if(sound_exists(gms_action_get_argument_real(0)))
                {
                    sound_stop(gms_action_get_argument_real(0));
                }
                break;
            case 26:
                sound_stop_all();
                break;
                //*/
            case 27:
                show_debug_message("Resource locked & loaded");
                var ind;
                ind = gms_action_get_argument_real(1);
                show_debug_message("Index: "+string(ind));
                //show_message(gms_action_get_argument_string(2))
                switch(gms_action_get_argument_real(0))
                {
                    case rs_sprite:
                        show_debug_message("Sprite...");
                        sprite_replace(ind, gms_action_get_argument_string(2), 0, 0, 0, sprite_get_xoffset(ind), sprite_get_yoffset(ind));
                        break;
                    case rs_sound:
                        show_debug_message("Sound...");
                        show_debug_message(string(XServer_sound_replace(ind, gms_action_get_argument_string(2), XServer_sound_get_kind(ind), XServer_sound_get_preload(ind))))
                        break;
                    case rs_background:
                        show_debug_message("Background...");
                        background_replace(ind, gms_action_get_argument_string(2), 0, 0);
                        break;
                }
                show_debug_message("Resource loaded.");
                file_delete(gms_action_get_argument_string(2));
                break;
            case 28:
                if(global.__script_session != -1 && script_exists(global.__script_session))
                {
                    script_execute(global.__script_session, gms_action_get_sender());
                }
                break;
            case 29:
                if(global.__script_session != -1 && script_exists(global.__script_vs_end))
                {
                    script_execute(global.__script_vs_end);
                }
                break;
            case 30:
                if(global.__script_session != -1 && script_exists(global.__script_vs_start))
                {
                    script_execute(global.__script_vs_start);
                }
                break;
            case 31://'Silent' Player login
                if(global.__obj_other_player >= 0)
                {
                    i = instance_create(0, 0, global.__obj_other_player);
                    i.player_id = gms_action_get_sender();
                    i.last_chat_message = "";
                    i.last_chat_time = 0;
                    i.last_chat_color = 0;
                    i.name = gms_action_get_argument_string(0);
                    if(global.__script_login != -1 && script_exists(global.__script_login))
                    {
                        script_execute(global.__script_login, i);
                    }
                }else{
                    if(global.__script_login != -1 && script_exists(global.__script_login))
                    {
                        script_execute(global.__script_login, gms_action_get_sender());
                    }
                }
                //gms_chat_local(string(i.name) + " just logged in!", c_green);
                break;
            case 32://'Silent' Player logout
                if(global.__obj_other_player >= 0)
                {
                    with(global.__obj_other_player)
                    {
                        if(player_id == gms_action_get_sender())
                        {
                            //gms_chat_local(name+" logged out!", c_red);
                            if(global.__script_logout != -1 && script_exists(global.__script_logout))
                            {
                                script_execute(global.__script_logout, id);
                            }
                            instance_destroy();
                        }
                    }
                }
                break;
            case 34:
                if(global.__login_finish_script == -5)
                {
                    XHandler_login_callback(gms_login_errorcode());
                }else if(global.__login_finish_script != -1 && script_exists(global.__login_finish_script))
                {
                    script_execute(global.__login_finish_script, gms_login_errorcode());
                }
                break;
            case 35:
                if(global.__register_finish_script == -5)
                {
                    XHandler_register_callback(gms_login_errorcode());
                }else if(global.__register_finish_script != -1 && script_exists(global.__register_finish_script))
                {
                    script_execute(global.__register_finish_script, gms_register_errorcode());
                }
                break;
            case 36:
                if(global.__friendrequest_callb != -1)
                {
                    script_execute(global.__friendrequest_callb, gms_action_get_argument_real(0));
                }
                break;
            case 0:
                break;
            default:
                XServer_error("Unknown action ID: " + string(gms_action_get_id()));
                break;
        }
    }until(gms_action_goto_next() == 0 && __max__count != 10000);//*/
    global.__in_action = 0;
}

if(__max__count == 10000)
{
    XServer_error("Aplication hung on retrieving DLL action-info.");
}

//Handle automatic variable syncing
if(global.__simple_mode)
{
    for(__i = 0; __i < XServer_instanceN(); __i += 1)
    {
        var __id, __n;
        __id = XServer_instanceID(__i);
        if(__id != 0 && __id != -1)
        {
            if(!instance_exists(__id))
            {
                gms_instance_sync_destroy(__id);
            }
            else
            {
                if(XServer_instance_isfull(__i))
                {
                    //Sync all variables
                    var __n__n, __v__v;
                    if(gms_instance_is_owner(__id))
                    {
                        /*for(__j = 0; __j < XServer_instance_varN(__i); __j += 1)
                        {
                            __n__n = XServer_instance_get_varname(__i, __j);
                            with(__id)
                            {
                                __v__v = XServer_variable_local_get(__n__n);
                            }
                            if(is_real(__v__v))
                            {
                                gms_instance_set_real(__id, __n__n, __v__v);
                            }else{
                                gms_instance_set_string(__id, __n__n, __v__v);
                            }
                        }*/
                        XServer_instance4d(__id.syncID, __id.x, __id.y, __id.speed, __id.direction);
                    }else{
                        /*for(__j = 0; __j < XServer_instance_varN(__i); __j += 1)
                        {
                            __n__n = XServer_instance_get_varname(__i, __j);
                            var __v;
                            if(gms_instance_isreal(__id, __n__n))
                            {
                                __v__v = gms_instance_get_real(__id, __n__n);
                            }else{
                                __v__v = gms_instance_get_string(__id, __n__n);
                            }
                            with(__id)
                            {
                                XServer_variable_local_set(__n__n, __v__v);
                            }
                        }*/
                        __id.x          = gms_instance_get_real(__id, "x");
                        __id.y          = gms_instance_get_real(__id, "y");
                        __id.speed      = gms_instance_get_real(__id, "speed");
                        __id.direction  = gms_instance_get_real(__id, "direction");
                    }
                }
            }
        }
    }
    
    
    if(global.__obj_other_player >= -1)
    {
        with(global.__obj_other_player)
        {
            room_id     = gms_other_get_real(player_id, "room");
            if(room_id != room)
            {
                x = -1000;
                y = -1000;
                visible = 0;
                //instance_deactivate_object(self);
            }else{
                x           = gms_other_get_real(player_id, "x");
                y           = gms_other_get_real(player_id, "y");
                direction   = gms_other_get_real(player_id, "direction");
                speed       = gms_other_get_real(player_id, "speed");
                //if(gms_other_has_changed(player_id))
                //{
            
                if(global.__sync_sprite) 
                {
                    if(XServer_other_index_changed(player_id) && global.__sync_imageindex) 
                        image_index = gms_other_get_real(player_id, "image_index");
                    
                    sprite_index = gms_other_get_real(player_id, "sprite_index");
                    image_speed = gms_other_get_real(player_id, "image_speed");
                    image_xscale= gms_other_get_real(player_id, "image_xscale");
                    image_yscale= gms_other_get_real(player_id, "image_yscale");
                    if(image_xscale == 0)
                        image_xscale = 0.0001;
                    if(image_yscale == 0)
                        image_yscale = 0.0001;
                    image_alpha = gms_other_get_real(player_id, "image_alpha");
                    image_angle = gms_other_get_real(player_id, "image_angle");
                    image_blend = gms_other_get_real(player_id, "image_blend");
                }
                visible     = gms_other_get_real(player_id, "visible");
                depth       = gms_other_get_real(player_id, "depth");
                solid       = gms_other_get_real(player_id, "solid");
                friction    = gms_other_get_real(player_id, "friction");
                name        = gms_other_get_string(player_id, "name");
            }
        }
    }
}

XWindow_totalstep();

__t = current_time-__m;
global.__steptime += __t;
global.__laststeptime = __t;
//show_debug_message("End step");
//Handle chat
return __ret;
#define gms_debug_hide_errors
global.__show_errors = false;
#define gms_team_auto_join
XServer_verify();
var __tw,__tl,__tc, __i;
__tl=-1;
__tc=-1;
for(__i=1; __i<=global.__maxteam; __i+=1)
{
    __tw[__i] = gms_team_score_get(__i) / (gms_team_player_count(__i) + 1) + gms_team_player_count(__i) * 100;
    if(__tw[__i] < __tl || __tl == -1)// || (__tw[__i] <= __tl + 100 && irandom(global.__maxteam) <= __i))
    {
        __tl = __tw[__i];
        __tc = __i;
    }
}
if(__tc != -1)
{
    gms_team_join(__tc);
}else{
    gms_team_join(round(random_range(1,global.__maxteam)));
}
#define gms_team_find_player
return gms_other_get(argument0, "team");
#define gms_team_get_current
XServer_verify();
return global.__team;
#define gms_team_join
XServer_verify();
global.__team = min(global.__maxteam, max(0, argument0));
XServer_variable_player_set_real("team", global.__team);
#define gms_team_player_is_friend
XServer_verify();
return gms_team_get_current() == gms_other_get_real(argument0, "team")
#define gms_team_score_add
XServer_verify();

if(!is_real(argument0) || !is_real(argument1))
{
    XServer_error("server_team_score_add: Got one or more string arguments, but expected two reals.");
    exit;
}

return gms_team_score_set(argument0, gms_team_score_get(argument0) + argument1);
#define gms_team_set_max
XServer_verify();
global.__maxteam = max(1, argument0);
#define gms_update_apply
if(global.__update_canapply)
{
    global.__update_canapply = 0;
    
    XServer_update_finish();
    game_end();
}
#define gms_update_has_updated
return parameter_string(1) == "-update";
#define gms_register
if(!is_real(argument4))
{
    XServer_error("server_register: Got a string as register script, but it should be a real.")exit
}

global.__register_finish_script = argument4;
XServer_register_execute(argument0, argument1, argument2, argument3);
#define gms_instance_created_by_sync
return !global.__can_sync;
#define XServer_error
if(global.__show_errors)
{
    show_error(argument0, false);
}
#define XServer_require_connection
XServer_verify();
if(!gms_info_isconnected())
{
    if(global.__show_errors)
    {
        show_error("GameMaker Server - Update "+string(gms_version())+": The script called requires the game to be connected to the server. Please verify you haven't been kicked by the server, and you aren't executing any scripts that should not be executed!", 1);
    }
    return 0;
}else{
    return 1;
}
#define XServer_require_login
XServer_verify();
if(!gms_info_isloggedin())
{
    if(global.__show_errors)
    {
        show_error("GameMaker Server - Update "+string(gms_version())+": The script called requires you to be logged in. Please verify you haven't been kicked by the server, and you aren't executing any scripts that should not be executed!", 1);
    }
    return 0;
}else{
    return 1;
}
#define XServer_validate_mail
return string_pos("@", argument0) > 0 && string_pos(".", string_copy(argument0, string_pos("@", argument0), string_length(argument0))) > 0;
#define XServer_validate_name
var __i, __c;
for(__i = 1; __i <= string_length(argument0); __i += 1)
{
    __c = ord(string_char_at(argument0, __i));
    if!((__c >= ord('a') && __c <= ord('z'))||(__c >= ord('A') && __c <= ord('Z')) || (__c >= ord('0') && __c <= ord('9')) || (__c == ord('_')))
    {
        return false;
    }
}
return true;
#define XServer_verify
if(!global.__set)
{
    show_error("server_settings wasn't called before calling an other script!", 0);
}
#define XServer_init_gml
XWindow_init();

//Algemeen
global.__step               = 0;
global.__set                = 0;
global.__steptime           = 0;
global.__laststeptime       = 0;
global.__message_reporting  = 255;
global.__hide_login         = 0;
global.__enable_spc         = 1;
global.__sync_imageindex    = 0;
global.__sync_sprite        = 1;
global.__triggerobject      = -1;
global.__last_font          = -1;
global.__last_halign        = 0;
global.__saved_font         = 0;
global.__tablast            = 0;
global.__tabpressed         = 0;

global.__in_action          = 0;

global.__friendrequest_callb= -1;

//Updates
global.__update_canapply    = 1;

//OTInstancesync
global.__instanceList       = ds_list_create();
global.__instanceTrackList  = ds_list_create();
global.__instanceMap        = ds_map_create();
global.__instanceMapI       = ds_map_create();

//Instance sync
global.__instanceVarC       = 0;

global.__script_login       = -1;
global.__script_logout      = -1;
global.__script_p2p         = -1;
global.__script_chat_recv   = -1;
global.__script_noconnection= -1;
global.__script_kick        = -1;
global.__script_session     = -1;
global.__script_vs_begin    = -1;
global.__script_vs_end      = -1;

//Chat
global.__chat_verify_script = -1;
global.__chattext           = ds_list_create();
global.__chattime           = ds_list_create();
global.__chatcol            = ds_list_create();
global.__chatsender         = ds_list_create();
global.__chatsendername     = ds_list_create();
global.__chat_colorscript   = -1;
global.__chat_highl         = 0;
global.__chat_bubbles       = 0;
global.__can_sync           = 1;

//Errors
global.__show_errors        = true;
global.__wait_for_reconnect = 0;

//Teams
global.__team               = 0;
global.__maxteam            = 2;

globalvar __ret;
__ret = 0;

global.__chat_directclose = 0;

global.__chat_teamonly = 0;

//Chat drawing
global.__chat        = 0;
global.__chat_small  = 0;
global.__chat_typing = 0;
global.__chat_font   = -1;

    //Position
global.__chat_bind   = 2;
global.__chat_pos    = 1;
global.__chat_height = 200;

    //Keys
global.__chat_togglekey = vk_enter;
global.__chat_submitkey = vk_enter;
global.__chat_teamkey   = vk_control;
    
    //Colors
global.__chat_textcol = c_black;
global.__chat_bgcol   = c_ltgray;
global.__chat_bgalpha = 0.6;

    //Effects
global.__chat_openani = 0;

//Language Options
global.__language_team = "[TEAM]";

//General settings
global.__simple_mode      = 1;
global.__version_num      = 0;
global.__obj_player       = -100000;
global.__obj_other_player = -100000;

global.__login_finish_script = -1;
global.__obj              = -1;
global.__ls_allow_guest   = false;
gms_show_set_position(0, 0, 0, 0);
#define XHandler
//argument0: item
//argument1: action
/*
 mouse-hover
 mouse-press
 mouse-hold
 tween
 submit
 keypress
 */
 
var __name;
__name = global.__winel[argument0, 15];

 
if(global.__winel[argument0, 73]) 
{
    exit;
}

if(argument1 == "!tween")
{
    if(global.__winel[argument0, 52] == 46)
    {
        switch(argument0)
        {
            case global.__xls_window:
                global.__xls_open = 0;
                global.__xrs_from_ls = false;
                if(instance_exists(global.__xls_from_object))
                {
                    with(global.__xls_from_object)
                    {
                        if(gms_info_isloggedin())
                        {
                            event_user(15);
                        }else{
                            event_user(14);
                        }
                    }
                }
                break;
            case global.__xrs_window:
                global.__xrs_open = 0;
                break;
            case global.__xhs_window:
                global.__xhs_open = 0;
                break;
            case global.__xss_window:
                global.__xss_open = 0;
                break;
            case global.__xas_window:
                global.__xas_open = 0;
                break;
            case global.__xfs_window:
                global.__xfs_open = 0;
                break;
            case global.__xms_window:
                if(ds_queue_size(global.__xmessage_queue) > 0)
                {
                    var _textfield;
                    _textfield = XWindow_find(global.__xms_window, "message-title");
                    if(_textfield == -1)
                    {
                        show_error("Message screen needs a 'message-title'-element to function properly", 1);
                    }else{
                        global.__winel[_textfield, 62] = ds_queue_dequeue(global.__xmessage_queue);
                        XWindow_show(global.__xms_window);
                        global.__xms_waittime = room_speed * 5;
                    }
                }else{
                    global.__xms_open = 0;
                }
                break;
            case global.__xus_window:
                global.__xus_open = 0;
                break;
            case global.__xkb_window:
                global.__xkb_open = 0;
                break;
        }
    }
}else if(argument1 == "mouse-hover")
{
    XWindow_perform(argument0, 43, false);
}else if(argument1 == "!mouse-hover")
{
    XWindow_perform(argument0, 44, false);
}else if(argument1 == "mouse-press")
{
    
    switch(__name)
    {
        //Login screen
        case "login.login":
            XHandler_login();
            return true;
        case "login.register":
            XWindow_perform(global.__xls_window, 49, 1);
            gms_show_register();
            global.__xrs_from_ls = true;
            global.__focus_item = -1;
            return true;
        case "login.close":
            XWindow_close(global.__xls_window);
            return true;
        case "highscore.close":
            XWindow_close(global.__xhs_window);
            return true;
        case "achievements.close":
            XWindow_close(global.__xas_window);
            return true;
        case "friends.close":
            XWindow_close(global.__xfs_window);
            return true;
        case "statistics.close":
            XWindow_close(global.__xss_window);
            return true;
        case "message.close":
            XWindow_close(global.__xms_window);
            return true;
        case "register.close":
            XWindow_close(global.__xrs_window);
            if(global.__xrs_from_ls)
            {
                global.__xrs_from_ls = false;
                XWindow_perform(global.__xls_window, 50, 1);
            }
            return true;
        case "register.register":
            XHandler_register();
            break;
        case "keyboard.key":
            if(global.__xkb_shift)
            {
                keyboard_string += string_upper(global.__winel[argument0, 62]);
                global.__xkb_shift = 0;
                XWindow_perform(XWindow_find(global.__xkb_window, "keyboard.shiftkey"), 48, false);
            }else{
                keyboard_string += string_lower(global.__winel[argument0, 62]);
            }
            return true;
        case "keyboard.shiftkey":
            global.__xkb_shift = !global.__xkb_shift;
            
            if(global.__xkb_shift)
            {
                XWindow_perform(argument0, 47, false);
            }else{
                XWindow_perform(argument0, 48, false);
            }
            break;
        case "keyboard.backspacekey":
            global.__tb_simulate_back = 1;
            return true;
        case "keyboard.closekey":
            XWindow_close(global.__xkb_window);
            global.__focus_item = -1;
            break;
        case "keyboard.numkey":
            XWindow_perform(global.__xkb_window, 49, true);
            XWindow_perform(global.__xkb_window, 48, true);
            return true;
        case "keyboard.normalkey":
            XWindow_perform(global.__xkb_window, 50, true);
            return true;
        case "keyboard.extrakey":
            XWindow_perform(global.__xkb_window, 47, true);
            return true;
    }
}else if(argument1 == "submit")
{
    //Login: submit via enter
    switch(__name)
    {
        case "login.username":
        case "login.password":
            XHandler_login();
            break;
        case "register.mail":
        case "register.password":
        case "register.password-again":
        case "register.username":
            XHandler_register();
            break;
    }
}else if(argument1 == "keypress")
{
    if(__name == "login.username")
    {
        var __un;
        __un = global.__winel[argument0, 62];
        global.__xls_username_get = __un;
    }
}

return false;
#define XHandler_login
//XHandler_login();
if(!global.__xls_isloggingin)
{
    global.__xls_isloggingin = true;
    
    var _username, _password, _fUsername, _fPassword, _hasAccount;
    _fUsername = XWindow_find(global.__xls_window, "login.username");
    _fPassword = XWindow_find(global.__xls_window, "login.password");
    
    var __xfErr;
    __xfErr = XWindow_find(global.__xls_window, "login.error");
    if(__xfErr != -1) global.__winel[__xfErr, 62] = "";
    
    if(_fUsername != -1 && _fPassword != -1)
    {
        _username = global.__winel[_fUsername, 62];
        _password = global.__winel[_fPassword, 62];
        _hasAccount = gms_login_player_has_account(_username);
        
        gms_login_set_username(_username);
        if(_hasAccount)
        {
            gms_login_set_password(_password);
        }
        
        gms_login_execute(-5);
    }else{
    }
}else{
}
#define XHandler_register
//XHandler_register();
if(!global.__xrs_isregistering)
{
    global.__xrs_isregistering = true;
    
    var _username, _password1, _password2, _mail, _fUsername, _fPassword1, _fPassword2, _fMail;
    _fUsername = XWindow_find(global.__xrs_window, "register.username");
    _fPassword1 = XWindow_find(global.__xrs_window, "register.password");
    _fPassword2 = XWindow_find(global.__xrs_window, "register.password-again");
    _fMail = XWindow_find(global.__xrs_window, "register.mail");
    
    if(_fUsername != -1 && _fPassword1 != -1 && _fPassword2 != -1 && _fMail != -1)
    {
        _username = global.__winel[_fUsername, 62];
        _password1 = global.__winel[_fPassword1, 62];
        _password2 = global.__winel[_fPassword2, 62];
        _mail = global.__winel[_fMail, 62];
        
        global.__xrs_username = _username;
        global.__xrs_password = _password1;
        
        
        
        gms_register(_username, _password1, _password2, _mail, -5);
    }else{
    }
}
#define XHandler_login_callback
var __xr;
__xr = argument0;
global.__xls_isloggingin = false;

if(__xr == 0)
{
    XWindow_close(global.__xls_window);
    if(instance_exists(global.__xls_loginobject))
    {
        with(global.__xls_loginobject)
        {
            event_perform(ev_other, ev_user15);
        }
    }
}else{
    var __xfErr;
    __xfErr = XWindow_find(global.__xls_window, "login.error");
    if(__xfErr != -1)
    {
        global.__winel[__xfErr, 62] = gms_login_error_tostring(__xr);
        global.__winel[__xfErr, 100] = true;
    }else{
        show_error("Could not find login.error element", false);
    }
    
    if(__xr == 1 || __xr == 3)
    {
        XWindow_tb_select_all(XWindow_find(global.__xls_window, "login.password"));
    }else{
        XWindow_tb_select_all(XWindow_find(global.__xls_window, "login.username"));
    }
    
    XWindow_perform(global.__xls_window, 51, 1);
}
#define XHandler_register_callback
var __xr;
__xr = argument0;
global.__xrs_isregistering = false;

if(__xr == 1)
{
    if(instance_exists(global.__xls_loginobject))
    {
        with(global.__xls_loginobject)
        {
            event_perform(ev_other, ev_user14);
        }
    }
    
    XWindow_close(global.__xrs_window);
    if(global.__xrs_from_ls)
    {
        XWindow_perform(global.__xls_window, 50, 1);
        
        var _fUsername, _fPassword;
        _fUsername = XWindow_find(global.__xls_window, "login.username");
        _fPassword = XWindow_find(global.__xls_window, "login.password");
        if(_fUsername != -1) global.__winel[_fUsername, 62] = global.__xrs_username;
        if(_fPassword != -1) global.__winel[_fPassword, 62] = global.__xrs_password;
        
        global.__xrs_username = "";
        global.__xrs_password = "";
        
        XHandler_login();
        
        keyboard_string = "";
        global.__xregister_screen = 0;
        global.__xlogin_screen = true;
    }else{
        XWindow_close(global.__xrs_window)
        gms_show_message(ds_map_find_value(global.__xconstant_map, "@txt_registration_complete"))
    }
}else{
    var __xfErr;
    __xfErr = XWindow_find(global.__xrs_window, "register.error");
    if(__xfErr != -1) global.__winel[__xfErr, 62] = gms_register_error_tostring(__xr);
    
    switch(__xr)
    {
        case 4:
        case 6:
            //Select user
            XWindow_tb_select_all(XWindow_find(global.__xrs_window, "register.username"));
        case 7:
            //Select pass1
            XWindow_tb_select_all(XWindow_find(global.__xrs_window, "register.password"));
            break;
        case 2:
            //Select pass2
            XWindow_tb_select_all(XWindow_find(global.__xrs_window, "register.password-again"));
            break;
        case 5:
        case 3:
            //Select mail
            XWindow_tb_select_all(XWindow_find(global.__xrs_window, "register.mail"));
            break;
    }
    
    XWindow_perform(global.__xls_window, 51, 1);
}
#define XWindow_tween
//XWindow_tween(element, speed, transform_type, bool positionchange);
//return argument0;
var m1, m2, m3;

m1 = argument0;

m2 = global.__winel[m1, 37];
m3 = global.__winel[m1, 38];

if(m2 != -1) 
{
    XWindow_destroy(m2);
}

if(m3 != -1)
{
    XWindow_destroy(m3);
}

m2 = XWindow_create(-1);
m3 = XWindow_create(-1);

XWindow_copy(m2, m1);
XWindow_copy(m3, m1);

global.__winel[m2, 0] = global.__winel[m1, 0];
global.__winel[m3, 0] = global.__winel[m1, 0];

global.__winel[m1, 37] = m2;
global.__winel[m1, 38] = m3;
global.__winel[m1, 39] = 0;
global.__winel[m1, 40] = argument2 * global.__tween_factor;
global.__winel[m1, 41] = argument1;
global.__winel[m1, 36] = true;
global.__winel[m3, 100] = true;

global.__windows_made += 1;

if(argument3)
{
    global.__tween_ongoing = max(global.__tween_ongoing, ceil(1 / (argument2 * global.__tween_factor)) + 5);
}

return m3;
#define XWindow_perform
//XWindow_perform(element, event, recurse)

var __map;
__map = global.__winel[argument0, argument1];
if(__map != -1)
{
    
    if(global.__winel[argument0, 52] != argument1)
    {
        if(__map >= 0)
        {
            var _tw, __ts, __tt, __pos;
            __tt = ds_map_find_value(__map, XWindow_hashname("tween-type"));
            if(__tt <= 0) __tt = tt_ease;
            
            if(__tt != tt_shake || !global.__winel[argument0, 36])
            {
                __ts = ds_map_find_value(__map, 42);
                if(__ts <= 0) __ts = 0.05;
                
                _tw = XWindow_tween(argument0, __tt, __ts, ds_map_find_value(__map, XWindow_hashname("tween-affects-position")));
                
                var __key;
                __key = ds_map_find_first(__map);
                
                while(__key != 0)
                {
                    global.__winel[_tw, __key] = ds_map_find_value(__map, __key);
                    
                    __key = ds_map_find_next(__map, __key);
                }
                
                if(__tt != tt_shake)
                {
                    global.__winel[_tw, 52] = argument1;
                    global.__winel[argument0, 52] = argument1;
                }
            }
        }
    }
}

if(argument2)
{
    var m, i;
    m = global.__winel[argument0, 0];
    for(i = 0; i < ds_list_size(m); i += 1)
    {
        XWindow_perform(ds_list_find_value(m, i), argument1, 1);
    }
}
#define XWindow_hashname
return ds_map_find_value(global.__hashmap, argument0);
#define XWindow_totaldraw
if(global.__xls_open) XWindow_draw(global.__xls_window, 1);
if(global.__xrs_open) XWindow_draw(global.__xrs_window, 1);
if(global.__xhs_open) XWindow_draw(global.__xhs_window, 1);
if(global.__xas_open) XWindow_draw(global.__xas_window, 1);
if(global.__xss_open) XWindow_draw(global.__xss_window, 1);
if(global.__xfs_open) XWindow_draw(global.__xfs_window, 1);
if(global.__xus_open) XWindow_draw(global.__xus_window, 1);
if(global.__xms_open) XWindow_draw(global.__xms_window, 1);

if(global.__xkb_open)
{
    XWindow_draw(global.__xkb_window, 1);
}
#define XWindow_totalstep
global.__enter_pressed     = 0;
global.__click_caught      = 0;
global.__timer             += 1;
global.__tween_factor      = room_speed / 60;

if(global.__timer mod room_speed == 0)
{
    if(global.__xus_open)
    {
        var _update_bar, _update_box;
        _update_box = XWindow_find(global.__xus_window, 'progress-bar-box');
        if(_update_box != -1)
        {
            _update_bar = XWindow_find(_update_box, 'progress-bar');
            if(_update_bar != -1 && !global.__winel[_update_bar, 36])
            {
                var _m, _goto_w;
                _m = XWindow_tween(_update_bar, tt_ease, 0.02, true);
                _goto_w = global.__winel[_update_box, 16] * gms_update_progress();
                global.__winel[_m, 13] = _goto_w;
                
                if(gms_update_progress() >= 1 && global.__winel[_update_bar, 13] >= _goto_w - 5)
                {
                    gms_update_apply();
                }
            }
        }
    }
}

if(global.__tween_ongoing > 0) global.__tween_ongoing     -= 1;

var _x1, _y1, _x2, _y2;
if(global.__xw_x1 != global.__xw_x2 && global.__xw_y1 != global.__xw_y2)
{
    _x1 = global.__xw_x1;
    _y1 = global.__xw_y1;
    _x2 = global.__xw_x2;
    _y2 = global.__xw_y2;
}else{
    _x1 = 0;
    _y1 = 0;
    _x2 = room_width;
    _y2 = room_height;
}

if(global.__xkb_open)
{
    if(global.__winel[global.__xkb_window, 2] > 20)
    {
        _y2 = min(room_height, global.__winel[global.__xkb_window, 2]);
    }
}

global.__zoom_focus_pos *= .95;

if(global.__zoom_focus_pos != global.__prev_zoom_focus_pos)
{
    global.__tween_ongoing  = 1;
    global.__prev_zoom_focus_pos = global.__zoom_focus_pos;
}

if(global.__xkb_open)
{
    XWindow_step(global.__xkb_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xkb_window, _x1, room_height - global.__winel[global.__xkb_window, 14], _x2, room_height);
}
if(global.__xms_open)
{
    XWindow_step(global.__xms_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xms_window, _x1, _y1, _x2, _y2);
    
    if(global.__xms_waittime > 0)
    {
        global.__xms_waittime -= 1;
        if(global.__xms_waittime == 0)
        {
            XWindow_close(global.__xms_window);
        }
    }
}
if(global.__click_caught) global.__click_caught = 2;

_y1 -= global.__zoom_focus_pos * 2;

if(global.__xls_username_get != "")
{
    var _result, _f1, _f2;
    _result = gms_login_player_has_account(global.__xls_username_get);
    
    if(_result != -1)
    {
        _f1 = XWindow_find(global.__xls_window, "login.username.guest");
        _f2 = XWindow_find(global.__xls_window, "login.password");
        if(_f1 != -1 && _f2 != -1)
        {
            if(!global.__winel[_f1, 36] && !global.__winel[_f2, 36])
            {
                if(_result == true)
                {
                    XWindow_perform(global.__xls_window, 48, true);
                }else if(_result == false){
                    XWindow_perform(global.__xls_window, 47, true);
                }
            }
        }
        
        global.__xls_username_get = "";
        global.__xls_isloggingin = false;
    }
}

if(global.__xls_open)
{
    XWindow_step(global.__xls_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xls_window, _x1, _y1, _x2, _y2);
}

if(global.__xrs_open)
{
    XWindow_step(global.__xrs_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xrs_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xhs_open)
{
    XWindow_step(global.__xhs_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xhs_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xfs_open)
{
    XWindow_step(global.__xfs_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xfs_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xss_open)
{
    XWindow_step(global.__xss_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xss_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xus_open)
{
    XWindow_step(global.__xus_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xus_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xas_open)
{
    XWindow_step(global.__xas_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xas_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;

if(global.__xhs_open)
{
    XWindow_step(global.__xhs_window, 1, mouse_x, mouse_y);
    if(global.__tween_ongoing) XWindow_position(global.__xhs_window, _x1, _y1, _x2, _y2);
}
if(global.__click_caught) global.__click_caught = 2;
#define XWindow_step
//
var m, i, _currel, __element_queue, __element_queue_arg0, __queue_size, __queue_pointer, __cache, __sth_sth_tween;

__cache = XWindow_get(argument0, "child-cache");
if(__cache == -1)
{
    __cache = XWindow_build_cache(argument0)
}

__queue_pointer = 1;
while(__queue_pointer < global.__wincache[__cache, 0])
{
    _currel = global.__wincache[__cache, __queue_pointer]
    
    var alp;
    alp = global.__winel[_currel, 31];
    
    if(global.__winel[_currel, 36])
    {
        var m2, m3, _proc, _new_proc;
        m2 = global.__winel[_currel, 37]
        m3 = global.__winel[_currel, 38];
        
        _proc = global.__winel[_currel, 39];
        switch(global.__winel[_currel, 41])
        {
            case tt_sin:
                _new_proc = sin(_proc * pi / 2);
                break;
            case tt_ease:
                _new_proc = global.__bezier[_proc * 3000];
                break;
            case tt_shake:
                _new_proc = sin(_proc * pi * 10) * (1 - _proc) * 5;
                break;
            default:
                show_error("Unknown tween type " + string(global.__winel[_currel, 41]), true);
                break;
        }
        
        
        global.__winel[_currel, 71] = global.__winel[m2, 71] * (1 - _new_proc) + global.__winel[m3, 71] * _new_proc;
        global.__winel[_currel, 70] = global.__winel[m2, 70] * (1 - _new_proc) + global.__winel[m3, 70] * _new_proc;
    
        if(global.__tween_ongoing >= 0)
        {
            global.__winel[_currel, 10] = global.__winel[m2, 10] * (1 - _new_proc) + global.__winel[m3, 10] * _new_proc;
            global.__winel[_currel, 9] = global.__winel[m2, 9] * (1 - _new_proc) + global.__winel[m3, 9] * _new_proc;
            
            global.__winel[_currel, 58] = global.__winel[m2, 58] * (1 - _new_proc) + global.__winel[m3, 58] * _new_proc;
            global.__winel[_currel, 56] = global.__winel[m2, 56] * (1 - _new_proc) + global.__winel[m3, 56] * _new_proc;
            
            global.__winel[_currel, 105] = global.__winel[m2, 105] * (1 - _new_proc) + global.__winel[m3, 105] * _new_proc;
            global.__winel[_currel, 106] = global.__winel[m2, 106] * (1 - _new_proc) + global.__winel[m3, 106] * _new_proc;
            global.__winel[_currel, 102] = global.__winel[m2, 102] * (1 - _new_proc) + global.__winel[m3, 102] * _new_proc;
            global.__winel[_currel, 104] = global.__winel[m2, 104] * (1 - _new_proc) + global.__winel[m3, 104] * _new_proc;
        }
        
        global.__winel[_currel, 31] = global.__winel[m2, 31] * (1 - _new_proc) + global.__winel[m3, 31] * _new_proc;
        global.__winel[_currel, 24] = global.__winel[m2, 24] * (1 - _new_proc) + global.__winel[m3, 24] * _new_proc;
        global.__winel[_currel, 25] = global.__winel[m2, 25] * (1 - _new_proc) + global.__winel[m3, 25] * _new_proc;
        
        global.__winel[_currel, 27] = global.__winel[m2, 27] * (1 - _new_proc) + global.__winel[m3, 27] * _new_proc;
        global.__winel[_currel, 28] = global.__winel[m2, 28] * (1 - _new_proc) + global.__winel[m3, 28] * _new_proc;
        global.__winel[_currel, 30] = global.__winel[m2, 30] * (1 - _new_proc) + global.__winel[m3, 30] * _new_proc;
        
        global.__winel[_currel, 20] = merge_color(global.__winel[m2, 20], global.__winel[m3, 20], _new_proc);
        global.__winel[_currel, 21] = merge_color(global.__winel[m2, 21], global.__winel[m3, 21], _new_proc);
        global.__winel[_currel, 22] = merge_color(global.__winel[m2, 22], global.__winel[m3, 22], _new_proc);
        global.__winel[_currel, 23] = merge_color(global.__winel[m2, 23], global.__winel[m3, 23], _new_proc);
        global.__winel[_currel, 33] = merge_color(global.__winel[m2, 33], global.__winel[m3, 33], _new_proc);
        //global.__winel[_currel, 26] = merge_color(global.__winel[m2, 26], global.__winel[m3, 26], p);
        //global.__winel[_currel, 29] = merge_color(global.__winel[m2, 29], global.__winel[m3, 29], p);
        
        global.__winel[_currel, 39] = _proc + global.__winel[_currel, 40]
        
        if(global.__winel[_currel, 39] >= 1)
        {        
            var __text;
            __text = global.__winel[_currel, 62];
            global.__tween_ongoing = max(global.__tween_ongoing, 3);
            
            if(global.__winel[_currel, 41] == tt_shake)
            {
                XWindow_copy(_currel, m2);
            }else{
                XWindow_copy(_currel, m3);
            }
            global.__winel[_currel, 62] = __text;
            
            XWindow_destroy(m2);
            XWindow_destroy(m3);
            
            global.__winel[_currel, 37] = -1;
            global.__winel[_currel, 38] = -1;
            global.__winel[_currel, 36] = 0;
            global.__winel[_currel, 39] = 0
            XHandler(_currel, "!tween");
        }
    }
    
    var x1, y1, x2, y2, i;
    x1 = global.__winel[_currel, 1];
    if(x1 >= room_width) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    y1 = global.__winel[_currel, 2];
    if(y1 >= room_height) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    x2 = global.__winel[_currel, 3];
    if(x2 <= 0) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    y2 = global.__winel[_currel, 4];
    if(y2 <= 0) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    if(x2 <= x1) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    if(y2 <= y1) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    m = global.__winel[_currel, 0];
    
    var __mp, __mh, __mr, __mhold;
    __mp = 0;
    __mh = 0;
    __mr = 0;
    __mhold = 0;
    
    if(global.__tween_ongoing <= 0)
    {
        if(argument2 >= x1 && argument2 <= x2 && argument3 >= y1 && argument3 <= y2)
        {
            __mh = 1;
            if(!global.__winel[_currel, 59])
            {
                XHandler(_currel, "mouse-hover");
                global.__winel[_currel, 59] = true
            }
            
            if(global.__click_caught != 2)
            {
                if(mouse_check_button_pressed(mb_left))
                {
                    if(XHandler(_currel, "mouse-press"))
                    {
                        global.__click_caught = 1;
                    }
                    __mp = 1;
                }else if(mouse_check_button(mb_left))
                {
                    __mhold = 1;
                }else if(mouse_check_button_released(mb_left))
                {
                    XHandler(_currel, "!mouse-press");
                    __mr = 1;
                }
            }
        }else if(global.__winel[_currel, 59])
        {
            XHandler(_currel, "!mouse-hover");
            global.__winel[_currel, 59] = false
        }
    }
    
    switch(global.__winel[_currel, 34])
    {
        case el_textbox:
            if(global.__focus_item == _currel)
            {
                if(global.__xkb_open) 
                {
                    if(y1 < 0) global.__zoom_focus_pos += (y1 - 40) * .1;
                }
                
                var _text, _select1, _select2, _len_limit, _rp_backspace, _rp_left, _rp_right, _rp_delete, 
                    _rb_backspace_count, _rp_left_count, _rp_right_count, _rp_delete_count, _rp_speed;
                
                var _font;
                _font = global.__winel[_currel, 63];
                if(_font == -2) draw_set_font(global.__f_title) else
                if(_font == -3) draw_set_font(global.__f_text) else
                if(_font == -4) draw_set_font(global.__f_small) else
                draw_set_font(_font)
                
                _text = global.__winel[_currel, 62];
                _select1 = global.__winel[_currel, 74];
                _select2 = global.__winel[_currel, 75];
                if(_select1 > string_length(_text) + 1) _select1 = string_length(_text) + 1;
                if(_select2 > string_length(_text) + 1) _select2 = string_length(_text) + 1;
                if(keyboard_string != "")
                {
                    if(!global.__winel[_currel, 77] && !global.__winel[_currel, 78])
                    {
                        keyboard_string = string_replace_all(keyboard_string, " ", "");
                    }
                    if(!global.__winel[_currel, 78])
                    {
                        keyboard_string = string_replace_all(keyboard_string, "#", "");
                    }
                    if(keyboard_string != "")
                    {
                        if(abs(_select1 - _select2) > 0)
                        {
                            _text = string_delete(_text, _select1, _select2 - _select1);
                        }
                        if(global.__winel[_currel, 78])
                        {
                            _text = string_insert(keyboard_string, _text, _select1);
                        }else{
                            _text = string_replace_all(string_insert(keyboard_string, _text, _select1),  " ", "");
                        }
                        _select1 += string_length(keyboard_string);
                        _select2 = _select1;
                        keyboard_string = "";
                        _len_limit = global.__winel[_currel, 79];
                        if(string_length(_text) > _len_limit)
                        {
                            _text = string_copy(_text, 1, _len_limit);
                            _select1 = min(_select1, _len_limit+1);
                            _select2 = _select1;
                        }
                        global.__winel[_currel, 100] = 1;
                    }
                }
                
                if(keyboard_check(vk_backspace) || global.__tb_simulate_back)
                {
                    global.__tb_simulate_back = 0;
                    _rp_backspace = global.__winel[_currel, 82];
                    _rp_backspace_count = global.__winel[_currel, 88];
                            
                    _rp_speed = global.__winel[_currel, 84];
                    _rp_speed2 = global.__winel[_currel, 85];
                    if(_rp_backspace == 0)
                    {
                        
                        _text = string_delete(_text, min(_select1, _select2) - (_select1 == _select2), max(_select1, _select2) - min(_select1, _select2) + 1);
                        _select1 -= (_select1 == _select2);
                    }else
                    if(_rp_backspace > _rp_speed)
                    {
                        _rp_backspace_count += 1;
                        if(_rp_backspace_count >= _rp_speed2)
                        {
                            _rp_backspace_count = 0;
                            _text = string_delete(_text, _select1 - 1, _select2 - _select1 + 1);
                            _select1 -= 1;
                        }
                    }
                    _rp_backspace += 1;
                    _select1 = max(1, _select1);
                    _select2 = _select1;
                    global.__winel[_currel, 100] = 1;
                    global.__winel[_currel, 82] = _rp_backspace;
                }else{
                    global.__winel[_currel, 82] = 0;
                }
                
                if(keyboard_check(vk_delete))
                {
                    _rp_delete = global.__winel[_currel, 83];
                    _rp_delete_count = global.__winel[_currel, 89];
                            
                    _rp_speed = global.__winel[_currel, 84];
                    _rp_speed2 = global.__winel[_currel, 85];
                    if(_rp_delete == 0)
                    {
                        _text = string_delete(_text, _select1, _select2 - _select1 + 1);
                        _select1 -= 1;
                    }else
                    if(_rp_delete > _rp_speed)
                    {
                        _rp_delete_count += 1;
                        if(_rp_delete_count >= _rp_speed2)
                        {
                            _rp_delete_count = 0;
                            _text = string_delete(_text, _select1, _select2 - _select1 + 1);
                            _select1 -= 1;
                        }
                    }
                    _rp_delete += 1;
                    _select1 = max(1, _select1);
                    _select2 = _select1;
                    global.__winel[_currel, 100] = 1;
                    global.__winel[_currel, 83] = _rp_delete;
                }else{
                    global.__winel[_currel, 83] = 0;
                }
                
                if(keyboard_check(vk_left))
                {
                    _rp_left = global.__winel[_currel, 80];
                    _rp_left_count = global.__winel[_currel, 86];
                            
                    _rp_speed = global.__winel[_currel, 84];
                    _rp_speed2 = global.__winel[_currel, 85];
                    if(_rp_left == 0)
                    {
                        _select1 -= 1;
                    }else if(_rp_left > _rp_speed)
                    {
                        _rp_left_count += 1;
                        if(_rp_left_count >= _rp_speed2)
                        {
                            _rp_left_count = 0;
                            _select1 -= 1;
                        }
                    }
                    _select1 = max(1, _select1);
                    if(!keyboard_check(vk_shift)) _select2 = _select1;
                    _rp_left += 1;
                    global.__winel[_currel, 80] = _rp_left;
                }else{
                    global.__winel[_currel, 80] = 0;
                }
                
                if(keyboard_check(vk_right))
                {
                    _rp_right = global.__winel[_currel, 81];
                    _rp_right_count = global.__winel[_currel, 87];
                            
                    _rp_speed = global.__winel[_currel, 84];
                    _rp_speed2 = global.__winel[_currel, 85];
                    if(_rp_right == 0)
                    {
                        _select2 += 1;
                    }else if(_rp_right > _rp_speed)
                    {
                        _rp_right_count += 1;
                        if(_rp_right_count >= _rp_speed2)
                        {
                            _rp_right_count = 0;
                            _select2 += 1;
                        }
                    }
                    _select2 = min(string_length(_text)+1, _select2);
                    if(!keyboard_check(vk_shift)) _select1 = _select2;
                    _rp_right += 1;
                    global.__winel[_currel, 81] = _rp_right;
                }else{
                    global.__winel[_currel, 81] = 0;
                }
                
                if((keyboard_check_pressed(vk_enter) && !global.__enter_pressed) || (keyboard_check_direct(vk_tab) && !global.__tab_pressed))
                {
                    global.__enter_pressed     = 1;
                    var _next_tab;
                    _next_tab = _currel;
                    repeat(100)
                    {
                        _next_tab = global.__winel[_next_tab, 93];
                        if(_next_tab == -1) break;
                        if(global.__winel[_next_tab, 31] > 0) break;
                    }
                    
                    if(_next_tab == -1)
                    {
                        XHandler(_currel, "submit");
                    }else{
                        global.__focus_item = _next_tab;
                    }
                }
                
                if(keyboard_check_direct(vk_tab))
                {
                    if(!global.__tab_pressed)
                    {
                        var _next_tab;
                        _next_tab = global.__winel[_currel, 92];
                        if(_next_tab != -1)
                        {
                            global.__focus_item = _next_tab;
                        }
                    }
                    global.__tab_pressed = true;
                }else{
                    global.__tab_pressed = false;
                }
                
                if(mouse_check_button_pressed(mb_left))
                {
                    if(__mh)
                    {
                        var _d, _t, _p1, _p2, _aimwidth, _guess;
                        if(global.__winel[_currel, 78])
                        {
                            _t = string_repeat("*", string_length(_text))
                        }else{
                            _t = _text;
                        }
                        
                        _p1 = 0;
                        _p2 = string_length(_t) + 1;
                        _aimwidth = argument2 - ((x1 + x2) / 2 - string_width(_t) / 2);
                        repeat(32)
                        {
                            _guess = round((_p1 + _p2) / 2);
                            _d = string_width(string_copy(_t + " ", 1, _guess));
                            
                            if(abs(_d - _aimwidth) <= 5 || _p1 == _p2)
                            {
                                break;
                            }else if(_d < _aimwidth)
                            {
                                _p1 = _guess;
                            }else if(_d > _aimwidth)
                            {
                                _p2 = _guess;
                            }
                        }
                        
                        _select1 = max(1, _guess + 1);
                        _select2 = max(1, _guess + 1);
                    }
                }else if(mouse_check_button(mb_left))
                {
                    if(__mh)
                    {
                        var _d, _t, _p1, _p2, _aimwidth, _guess;
                        if(global.__winel[_currel, 78])
                        {
                            _t = string_repeat("*", string_length(_text))
                        }else{
                            _t = _text;
                        }
                        
                        _p1 = 0;
                        _p2 = string_length(_t) + 1;
                        _aimwidth = argument2 - ((x1 + x2) / 2 - string_width(_t) / 2);
                        repeat(32)
                        {
                            _guess = round((_p1 + _p2) / 2);
                            _d = string_width(string_copy(_t + " ", 1, _guess));
                            
                            if(abs(_d - _aimwidth) <= 5 || _p1 == _p2)
                            {
                                break;
                            }else if(_d < _aimwidth)
                            {
                                _p1 = _guess;
                            }else if(_d > _aimwidth)
                            {
                                _p2 = _guess;
                            }
                        }
                        
                        _select2 = max(1, _guess + 1);
                    }
                }
                
                if(mouse_check_button_released(mb_left) || keyboard_check_released(vk_shift))
                {
                    if(_select2 < _select1)
                    {
                        var ss;
                        
                        ss = _select1;
                        _select1 = _select2;
                        _select2 = ss;
                    }
                        
                }
                
                global.__winel[_currel, 74] = _select1;
                global.__winel[_currel, 75] = _select2;
                
                if(_text != global.__winel[_currel, 62])
                {
                    global.__winel[_currel, 62] = _text;
                    XHandler(_currel, "keypress");
                }
            }else{
                if(__mp && __mh)
                {
                    XWindow_focus(_currel)
                }
            }
            break;
        case el_scrollbox:
            var _surf, _ih, _scroll, _dscroll, _cscroll, __hh;
            _surf = global.__winel[_currel, 94];
            _ih = global.__winel[_currel, 12];
            
            if(surface_get_width(_surf) != abs(x2 - x1) || surface_get_height(_surf) != _ih)
            {
                surface_free(_surf);
                _surf = -1;
            }
            
            if(!surface_exists(_surf) && _ih > 0)
            {
                _surf = surface_create(abs(x2 - x1), _ih);
                global.__winel[_currel, 94] = _surf;
                global.__winel[_currel, 100] = 1;
            }
            
            if(surface_exists(_surf))
            {
                __hh = abs(y2 - y1);
                _scroll = 0;
                
                //if(_ih > __hh)
                {
                    _scroll = global.__winel[_currel, 95];
                    _momentum = global.__winel[_currel, 96];
                    _dscroll = global.__winel[_currel, 97];
                    _cscroll = global.__winel[_currel, 98];
                    if(surface_get_width(_surf) != abs(x2 - x1))
                    
                    var _scrollb_h;
                    //hh 308
                    //ih 400
                    //scrollbh 308
                    _scrollb_h = min(__hh, max(16, __hh / max(1, _ih) * __hh));
                    global.__winel[_currel, 101] = _scrollb_h
                    
                    var __nostep;
                    __step = false;
                    if(_dscroll)
                    {
                        _scroll = _scroll * .5 + ((argument3 - y1 - _scrollb_h * .5) / (__hh - _scrollb_h) * (_ih - __hh)) * .5;
                        if(!mouse_check_button(mb_any))
                        {
                            global.__winel[_currel, 97] = false
                        }
                    }else if(_cscroll)
                    {
                        var _move;
                        _move = argument3 - global.__winel[_currel, 99];
                        _scroll -= _move;
                        global.__winel[_currel, 96] = _move;
                        
                        global.__winel[_currel, 99] = argument3;
                        
                    }else if(abs(_momentum) > 0.01)
                    {
                        _scroll -= _momentum;
                        _momentum *= 0.9;
                        if(_scroll < 0 || _scroll > _ih - __hh)
                        {
                            _momentum = 0;
                        }
                        global.__winel[_currel, 96] = _momentum;
                    }else{
                        __step = true;
                    }
                    
                    if(mouse_wheel_up())
                    {
                        global.__winel[_currel, 96] = 8;
                    }else if(mouse_wheel_down())
                    {
                        global.__winel[_currel, 96] = -8;
                    }
                    
                    if(argument2 >= x2 - 10 && __mh)
                    {
                        if(mouse_check_button_pressed(mb_any))
                        {
                            global.__winel[_currel, 97] = true
                        }
                    }
                    
                    _scroll = max(0, min(_scroll, _ih - __hh));
                    global.__winel[_currel, 95] = _scroll;
                
                    if(__mp)
                    {
                        global.__winel[_currel, 99] = argument3;
                    }else if(__mhold)
                    {
                        if(abs(argument3 - global.__winel[_currel, 99]) > 4)
                        {
                            global.__winel[_currel, 98] = 1;
                        }
                    }else
                    {
                        global.__winel[_currel, 98] = 0;
                    }
                }
                
                if((x2 - x1) * (__hh) > 0)
                {
                    surface_set_target(_surf);
                    
                    if(alp > 0.01)
                    {
                        draw_set_blend_mode(bm_subtract);
                        draw_rectangle(0, 0, surface_get_width(_surf), surface_get_height(_surf), 0);
                        draw_set_blend_mode(bm_normal);
                        
                        draw_set_alpha(global.__winel[_currel, 24] * alp)
                        draw_rectangle_color(0, 0, surface_get_width(_surf), surface_get_height(_surf), 
                        global.__winel[_currel, 20],
                        global.__winel[_currel, 21],
                        global.__winel[_currel, 22],
                        global.__winel[_currel, 23], 0);
        
                        if(global.__winel[_currel, 25] > 0)
                        {
                            draw_set_color(global.__winel[_currel, 26]);
                            for(i = 0; i < global.__winel[_currel, 25]; i += 1)
                            {
                                draw_rectangle(i, i, surface_get_width(_surf) - i, _ih - i, 1);
                            }
                        }
                    }
                    
                    for(i = 0; i < ds_list_size(m); i += 1)
                    {
                        var __it;
                        __it = ds_list_find_value(m, i);
                        
                        if(global.__winel[__it, 4] < _scroll || global.__winel[__it, 2] > __hh + _scroll) continue;
                        
                        if(__step) XWindow_step(__it, alp, argument2, argument3);
                        XWindow_draw(__it, 1);
                    }
                    surface_reset_target();
                }
            }
            break;
        case el_loading:
            global.__winel[_currel, 60] = global.__winel[_currel, 60] + 5;
            break;
    }
    
    __queue_pointer += 1;
}
#define XWindow_draw
//
var _currel, _queuecount, __element_queue, __element_queue_arg0, __queue_size, __queue_pointer;

__cache = XWindow_get(argument0, "child-cache");
if(__cache == -1)
{
    __cache = XWindow_build_cache(argument0)
}

__queue_pointer = 1;
__alpha[0] = argument1;

while(__queue_pointer < global.__wincache[__cache, 0])
{
    var x1, y1, x2, y2, i, alp, m, _rs;
    _currel = global.__wincache[__cache, __queue_pointer];
    alp = 1;//__alpha[global.__windcache[__cache, __queue_pointer]];
    
    //if(alp <= 0) continue;
    
    //draw_set_alpha(1);
    //draw_line_color(x1, y1, room_width / 2, room_height / 2, 0, 0);
    
    x1 = round(global.__winel[_currel, 1]);
    if(x1 >= room_width) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    y1 = round(global.__winel[_currel, 2]);
    if(y1 >= room_height) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    x2 = round(global.__winel[_currel, 3]);
    if(x2 <= 0) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    y2 = round(global.__winel[_currel, 4]);
    if(y2 <= 0) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    
    if(x2 <= x1) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    if(y2 <= y1) { __queue_pointer = global.__winskip[__cache, __queue_pointer]; continue }
    //show_message("Depth " + string(global.__windcache[__cache, __queue_pointer]) + " / alpha: " + string(alp));
    
    _rs = global.__winel[_currel, 34];
    
    if(_rs != el_container)
    {
        alp *= global.__winel[_currel, 31];
        
        if(alp > 0)
        {
            var d;
            d = global.__winel[_currel, 27];
            if(d)
            {
                var __spread;
                __spread = global.__winel[_currel, 30]
                draw_set_color(global.__winel[_currel, 29]);
                draw_set_alpha(global.__winel[_currel, 28] * alp);
                for(i = 0; i < __spread; i += 2)
                {
                    draw_roundrect(x1 + d - i, y1 + d - i, x2 + d + i, y2 + d + i, 0);
                }
            }
        
            var alp2, _bs;
            alp2 = alp * global.__winel[_currel, 24];
            _bs = global.__winel[_currel, 25];
            if(alp2 > 0.01)
            {
                draw_set_alpha(alp2)
                draw_rectangle_color(x1 - _bs, y1 - _bs, x2 + _bs, y2 + _bs, 
                global.__winel[_currel, 20],
                global.__winel[_currel, 21],
                global.__winel[_currel, 22],
                global.__winel[_currel, 23], 0);
            }
            
            if(_bs > 0)
            {
                draw_set_color(global.__winel[_currel, 26]);
                for(i = 1; i <= _bs; i += 1)
                {
                    draw_rectangle(x1 - i, y1 - i, x2 + i, y2 + i, 1);
                }
            }
        }
    }
    
    /*var _col;
    _col = 0;
    if(_rs == el_multielement)
    {
        _col = 255;
    }
    
    draw_rectangle_color(x1, y1, x2, y2, _col, _col, _col, _col, 1);
    //draw_rectangle_color(x1, y1, x1 + global.__winel[_currel, 102], y2 + global.__winel[_currel, 105], 0, 0, 0, 0, 1);
    //draw_rectangle_color(x1, y1, x1 + global.__winel[_currel, 104], y2 + global.__winel[_currel, 106], 0, 0, 0, 0, 1);
    //draw_set_font(-1);
    //draw_text_color(x1 - 32, y1 - 32, string(x1) + "," + string(y1) + ":", 0, 0, 0, 0, 1);/*/
    
    draw_set_alpha(alp);
    draw_set_color(global.__winel[_currel, 33]);
    switch(_rs)
    {
        case el_label:
        case el_button:
            var _font;
            _font = global.__winel[_currel, 63];
            if(_font == -2) draw_set_font(global.__f_title) else
            if(_font == -3) draw_set_font(global.__f_text) else
            if(_font == -4) draw_set_font(global.__f_small) else
            draw_set_font(_font);
            
            draw_set_alpha(alp);
            draw_set_halign(fa_middle);
            draw_set_valign(fa_middle);
            var _t, _scale;
            _t = global.__winel[_currel, 62];
            
            if(global.__winel[_currel, 61])
            {
                _scale = min((y2 - y1) / max(1, string_height_ext(_t, -1, x2 - x1)), 1);
                if(!global.__winel[_currel, 36] && _scale >= 0.95)
                {
                    draw_text_ext(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _t, -1, x2 - x1);
                }else{
                    draw_text_ext_transformed(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _t, -1, x2 - x1, _scale, _scale, 0);
                }
            }else{
                _scale = min((y2 - y1) / max(1, string_height(_t)), max(1, (x2 - x1) / max(1, string_width(_t))), 1);
                if(_scale >= 0.98)
                {
                    draw_text(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _t);
                }else{
                    draw_text_transformed(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _t, _scale, _scale, 0);
                }
            }
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            break;
        case el_arrow:
            draw_set_alpha(alp);
            var _alength, _asize;
            _alength = global.__winel[_currel, 71];
            draw_arrow((x1 + x2) / 2, (y1 + y2) / 2 - _alength / 2, (x1 + x2) / 2, (y1 + y2) / 2 + _alength / 2, global.__winel[_currel, 70]);
            break;
        case el_textbox:
            var _font;
            _font = global.__winel[_currel, 63];
            if(_font == -2) draw_set_font(global.__f_title) else
            if(_font == -3) draw_set_font(global.__f_text) else
            if(_font == -4) draw_set_font(global.__f_small) else
            draw_set_font(_font)
            
            var _text, _istip;
            _text = global.__winel[_currel, 62];
            
            if(_text == "")
            {
                _text = global.__winel[_currel, 90];
                draw_set_color(global.__winel[_currel, 91]);
                _istip = true;
            }else{
                _istip = false;
                if(global.__winel[_currel, 78])
                {
                    _text = string_repeat("*", string_length(_text));
                }
            }
            
            if(global.__focus_item == _currel)
            {
                var _select1, _select2, _len_limit, _rp_backspace, _rp_left, _rp_right, _rp_delete, 
                    _rb_backspace_count, _rp_left_count, _rp_right_count, _rp_delete_count, _rp_speed;
                
                _select1 = global.__winel[_currel, 74];
                _select2 = global.__winel[_currel, 75];
                
                draw_set_halign(fa_middle);
                draw_set_valign(fa_middle);
                
                var _w, _h, _scale;
                _w = max(1, string_width(_text))
                _h = max(1, string_height(_text));
                _scale = min((y2 - y1) / _h, (x2 - x1) / _w, 1);
                
                if(!global.__winel[_currel, 36] &&_scale >= 0.95) _scale = 1;
                draw_text_transformed(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _text, min(_scale, (x2 - x1 - 8) / max(1, string_width(_text))), _scale, 0);
                
                draw_set_color(global.__winel[_currel, 76])
                var _ww1, _w1, _w2, _wt;
                if(_istip)
                {
                    _ww1 = (x1 + x2) / 2;
                    _ww2 = (x1 + x2) / 2;
                }else{
                    _wt = string_width(_text);
                    _ww1 = (x1 + x2) / 2 - _wt / 2 + string_width(string_copy(_text, 1, _select1 - 1));
                    _ww2 = (x1 + x2) / 2 - _wt / 2 + string_width(string_copy(_text, 1, _select2 - 1));
                }
                
                if(_select1 != _select2)
                {
                    draw_set_alpha(0.3 * alp);
                    draw_rectangle(_ww1, y1 + 2, _ww2, y2 - 2, 0)
                }else if(current_time mod 900 < 400)
                {
                    draw_set_alpha(alp);
                    draw_set_color(c_black);
                    draw_line(_ww1, y1 + 2, _ww1, y2 - 2);
                }
            }else{
                draw_set_halign(fa_middle);
                draw_set_valign(fa_middle);
                
                var _scale;
                _scale = min((y2 - y1) / max(1, string_height(_text)), (x2 - x1) / max(1, string_width(_text)), 1);
                
                if(_scale >= 0.98)
                {
                    draw_text(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _text);
                }else{
                    draw_text_transformed(floor((x1 + x2) / 2), floor((y1 + y2) / 2), _text, _scale, _scale, 0);
                }
            }
            break;
        case el_scrollbox:
            var _surf, _scroll, _scrollb_y1, _scrollb_y2, _scrollb_h;
            _surf = global.__winel[_currel, 94];
            if(surface_exists(_surf))
            {
                _ch = global.__winel[_currel, 12];
                _fh = abs(y2 - y1)
                _scroll = global.__winel[_currel, 95];
                _scrollb_h = global.__winel[_currel, 101]
                
                draw_surface_part(_surf, 0, _scroll, x2 - x1, y2 - y1, x1, y1);
            
                draw_set_color(c_black);
                draw_set_alpha((0.1 + 0.1 * global.__winel[_currel, 97]) * alp);
                draw_rectangle(x2 - 10, y1, x2, y2, 0);
                
                if(_ch > _fh)
                {
                    _scrollb_y1 = max(0, (_fh - _scrollb_h) * (_scroll / (_ch - _fh)));
                    _scrollb_y2 = _scrollb_y1 + _scrollb_h;
                    
                    draw_rectangle(x2 - 10, y1 + _scrollb_y1, x2, y1 + _scrollb_y2, 0);
                }
            }
            break;
        case el_loading:
            var _xm, _ym, _ani, i;
            _xm = (x2 + x1) / 2;
            _ym = (y2 + y1) / 2;
            _ani = global.__winel[_currel, 60];
            _scale = min(x2 - x1, y2 - y1) / 48;
            
            for(i = 0; i < 5; i += 1)
            {
                draw_circle(_xm + lengthdir_x(16, _ani - i * 36) * _scale, _ym + lengthdir_y(16, _ani - i * 36) * _scale, (6 - i) * _scale, 0);
            }
            break;
    }
    
    __alpha[global.__windcache[__cache, __queue_pointer] + 1] = alp;
    __queue_pointer += 1;
}
#define XWindow_position
//XWindow_position(argument0, x1, y1, x2, y2);
var _m, _i, _currel, __element_stack1, __element_stack2, __stackp1, __stackp2, __cache, __pointer;

__element_stack1[0] = argument0;
__element_stack2[0] = argument0;
__stackp1 = 0;
__stackp2 = 0;

//Pass 1: Prepare processing queue so that all children are processed before their parents
while(__stackp1 >= 0)
{
    _currel = __element_stack1[__stackp1];
    __element_stack2[__stackp2] = _currel;
    __stackp1 -= 1;
    __stackp2 += 1;
    
    _m = global.__winel[_currel, 0];
    for(_i = 0; _i < ds_list_size(_m); _i += 1)
    {
        __stackp1 += 1;
        var _el;
        _el = ds_list_find_value(_m, _i);
        if(global.__winel[_el, 36])
        {
            //__stackp1 += 1;
            __element_stack1[__stackp1] = global.__winel[_el, 38];
        }else{
            __element_stack1[__stackp1] = _el;
        }
    }
}

//Pass 2: Set min/max width & min/max height of every element. 
//        Parents can use their children's size to determine their own width
while(__stackp2 > 0)
{
    __stackp2 -= 1;
    _currel = __element_stack2[__stackp2];
    
    var _rs;
    _rs = global.__winel[_currel, 34];
    
    if(_rs == el_button || _rs == el_label || _rs == el_textbox)
    {
        if(global.__winel[_currel, 100])
        {
            global.__winel[_currel, 100] = 0;
            var _font;
            _font = global.__winel[_currel, 63];
            if(_font == -2) _font = global.__f_title;
            if(_font == -3) _font = global.__f_text;
            if(_font == -4) _font = global.__f_small;
            draw_set_font(max(-1, _font));
            
            if(global.__winel[_currel, 61])
            {
                global.__winel[_currel, 11] = string_width_ext(global.__winel[_currel, 62], -1, 1) + global.__winel[_currel, 64];
                global.__winel[_currel, 12] = string_height(global.__winel[_currel, 62]) + global.__winel[_currel, 65];
            }else{
                global.__winel[_currel, 11] = string_width(global.__winel[_currel, 62]) + global.__winel[_currel, 64];
                global.__winel[_currel, 12] = string_height(global.__winel[_currel, 62]) + global.__winel[_currel, 65];
            }
        }
    }
    
    var _hor_margin, _ver_margin;
    _hor_margin = global.__winel[_currel, 5] + global.__winel[_currel, 6];
    _ver_margin = global.__winel[_currel, 7] + global.__winel[_currel, 8];
    
    var _sw, _sh;
    _sw = global.__winel[_currel, 13];
    _sh = global.__winel[_currel, 14];
    switch(_rs)
    {
        //Elements without children (at least, they shouldn't have any)
        case el_button:
        case el_label:
        case el_scrollbox:
        case el_textbox:
        case el_arrow:
            switch(round(_sw))
            {
                case sz_min:
                    global.__winel[_currel, 102] = global.__winel[_currel, 11] + _hor_margin;
                    global.__winel[_currel, 104] = global.__winel[_currel, 11] + _hor_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 102] = global.__winel[_currel, 11] + _hor_margin;
                    global.__winel[_currel, 104] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 102] = global.__winel[_currel, 57] + _hor_margin;
                    global.__winel[_currel, 104] = global.__winel[_currel, 55] + _hor_margin;
                    break;
                default:
                    global.__winel[_currel, 102] = _sw + _hor_margin;
                    global.__winel[_currel, 104] = _sw + _hor_margin;
                    break;
            }
            
            switch(round(_sh))
            {
                case sz_min:
                    global.__winel[_currel, 105] = global.__winel[_currel, 12] + _ver_margin;
                    global.__winel[_currel, 106] = global.__winel[_currel, 12] + _ver_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 105] = global.__winel[_currel, 12] + _ver_margin;
                    global.__winel[_currel, 106] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 105] = global.__winel[_currel, 58] + _ver_margin;
                    global.__winel[_currel, 106] = global.__winel[_currel, 56] + _ver_margin;
                    break;
                default:
                    global.__winel[_currel, 105] = _sh + _ver_margin;
                    global.__winel[_currel, 106] = _sh + _ver_margin;
                    break;
            }
            break;
        
        //Horizontal containers
        case el_multielement:
            var _sxmin, _sxmax, _symin, _symax, _el;
            _sxmin = 0;
            _symin = 0;
            _sxmax = 0;
            _symax = 0;
            _m = global.__winel[_currel, 0];
            for(_i = 0; _i < ds_list_size(_m); _i += 1)
            {
                _el = ds_list_find_value(_m, _i);
                _symin = max(global.__winel[_el, 105], _symin);
                _symax = max(global.__winel[_el, 106], _symax);
                _sxmin += global.__winel[_el, 102]
                _sxmax += global.__winel[_el, 104]
            }
            
            /*global.__winel[_currel, 102] = _sxmin + _hor_margin;
            global.__winel[_currel, 104] = _sxmax + _hor_margin;
            global.__winel[_currel, 105] = _symin + _ver_margin;
            global.__winel[_currel, 106] = _symax + _ver_margin;*/
            switch(round(_sw))
            {
                case sz_min:
                    global.__winel[_currel, 102] = _sxmin + _hor_margin;
                    global.__winel[_currel, 104] = _sxmin + _hor_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 102] = _sxmin + _hor_margin;
                    global.__winel[_currel, 104] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 102] = global.__winel[_currel, 57] + _hor_margin;
                    global.__winel[_currel, 104] = global.__winel[_currel, 55] + _hor_margin;
                    break;
                default:
                    global.__winel[_currel, 102] = _sw + _hor_margin;
                    global.__winel[_currel, 104] = _sw + _hor_margin;
                    break;
            }
            
            switch(round(_sh))
            {
                case sz_min:
                    global.__winel[_currel, 105] = _symin + _ver_margin;
                    global.__winel[_currel, 106] = _symin + _ver_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 105] = _symin + _ver_margin;
                    global.__winel[_currel, 106] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 105] = global.__winel[_currel, 58] + _ver_margin;
                    global.__winel[_currel, 106] = global.__winel[_currel, 56] + _ver_margin;
                    break;
                default:
                    global.__winel[_currel, 105] = _sh + _ver_margin;
                    global.__winel[_currel, 106] = _sh + _ver_margin;
                    break;
            }
            
            global.__winel[_currel, 11] = _sxmax + _hor_margin
            global.__winel[_currel, 12] = _symax + _ver_margin
            break;
            
        //Vertical containers
        case el_container:
        case el_canvas:
            var _sxmin, _sxmax, _symin, _symax, _el;
            _sxmin = 0;
            _symin = 0;
            _sxmax = 0;
            _symax = 0;
            _m = global.__winel[_currel, 0];
            
            if(global.__winel[_currel, 32])
            {
                for(_i = 0; _i < ds_list_size(_m); _i += 1)
                {
                    _el = ds_list_find_value(_m, _i);
                    _sxmin = max(global.__winel[_el, 102], _sxmin);
                    _sxmax = max(global.__winel[_el, 104], _sxmax);
                    _symin = max(global.__winel[_el, 105], _symin);
                    _symax = max(global.__winel[_el, 106], _symax);
                }
            }else{
                for(_i = 0; _i < ds_list_size(_m); _i += 1)
                {
                    _el = ds_list_find_value(_m, _i);
                    _sxmin = max(global.__winel[_el, 102], _sxmin);
                    _sxmax = max(global.__winel[_el, 104], _sxmax);
                    _symin += global.__winel[_el, 105]
                    _symax += global.__winel[_el, 106]
                }
            }
            
            /*global.__winel[_currel, 102] = ;
            global.__winel[_currel, 104] = _sxmax + _hor_margin;
            global.__winel[_currel, 105] = _symin + _ver_margin;
            global.__winel[_currel, 106] = _symax + _ver_margin;*/
            
            switch(round(_sw))
            {
                case sz_min:
                    global.__winel[_currel, 102] = _sxmin + _hor_margin;
                    global.__winel[_currel, 104] = _sxmin + _hor_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 102] = _sxmin + _hor_margin;
                    global.__winel[_currel, 104] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 102] = global.__winel[_currel, 57] + _hor_margin;
                    global.__winel[_currel, 104] = global.__winel[_currel, 55] + _hor_margin;
                    break;
                default:
                    global.__winel[_currel, 102] = _sw + _hor_margin;
                    global.__winel[_currel, 104] = _sw + _hor_margin;
                    break;
            }
            
            switch(round(_sh))
            {
                case sz_min:
                    global.__winel[_currel, 105] = _symin + _ver_margin;
                    global.__winel[_currel, 106] = _symin + _ver_margin;
                    break;
                case sz_max:
                    global.__winel[_currel, 105] = _symin + _ver_margin;
                    global.__winel[_currel, 106] = 65535;
                    break;
                case sz_preferred:
                    global.__winel[_currel, 105] = global.__winel[_currel, 58] + _ver_margin;
                    global.__winel[_currel, 106] = global.__winel[_currel, 56] + _ver_margin;
                    break;
                default:
                    global.__winel[_currel, 105] = _sh + _ver_margin;
                    global.__winel[_currel, 106] = _sh + _ver_margin;
                    break;
            }
            
            global.__winel[_currel, 11] = _sxmax + _hor_margin
            global.__winel[_currel, 12] = _symax + _ver_margin
            break;
    }
}

//Pass 3: Set positions in the order parent -> child, once again rebuilding the parse tree
//        This pass will also take margins in account. Values are grabbed from the parameters themselves
//        So that no arguments need to be used.
//Parameters to take into account:
//overlapping, horizontal-float, vertical-float, x-offset, y-offset, center

//Process outer element that has no parent
{
    x1 = argument1
    y1 = argument2
    x2 = argument3
    y2 = argument4
    
    _m = argument0
    //Calculate percentage of extra height that can be used
    _max_percentage = (global.__winel[_m, 106] - global.__winel[_m, 105]);
    if(_max_percentage != 0) _max_percentage = (y2 - y1 - (global.__winel[_m, 105])) / _max_percentage
    
    _el = _m;
    
    var _sw, _sh, _xoff, _yoff;
    _xoff = global.__winel[_el, 9] * room_width;
    _yoff = global.__winel[_el, 10] * room_height;
    
    _sw = min(global.__winel[_el, 104], max(global.__winel[_el, 102], (x2 - x1)));
    _sh = min(global.__winel[_el, 106], global.__winel[_el, 106] * _max_percentage + global.__winel[_el, 105] * (1 - _max_percentage))
    
    if(global.__winel[_el, 72])
    {
        var _mx, _my;
        _mx = (x1 + x2) / 2;
        _my = (y1 + y2) / 2;
        
        global.__winel[_el, 2] = _my + _yoff + global.__winel[_el, 7] - _sh / 2;
        global.__winel[_el, 4] = _my + _yoff - global.__winel[_el, 8] + _sh / 2;
        global.__winel[_el, 1] = _mx + _xoff + global.__winel[_el, 5] - _sw / 2;
        global.__winel[_el, 3] = _mx + _xoff - global.__winel[_el, 6] + _sw / 2;
    }else{
        if(global.__winel[_el, 19])
        {
            global.__winel[_el, 1] = x2 - _xoff + global.__winel[_el, 5] - _sw;
            global.__winel[_el, 3] = x2 - _xoff - global.__winel[_el, 6];
        }else{
            global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
            global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + _sw;
        }
        
        if(global.__winel[_el, 18])
        {
            global.__winel[_el, 2] = y2 - _yoff + global.__winel[_el, 7] - _sh;
            global.__winel[_el, 4] = y2 - _yoff - global.__winel[_el, 8];
        }else{
            global.__winel[_el, 2] = y1 + _yoff + global.__winel[_el, 7];
            global.__winel[_el, 4] = y1 + _yoff - global.__winel[_el, 8] + _sh;
            y1 += _sh
        }
    }
}

__cache = XWindow_get(argument0, "child-cache");
if(__cache == -1)
{
    __cache = XWindow_build_cache(argument0)
}

var __queue_pointer;
__queue_pointer = 1;

while(__queue_pointer < global.__wincache[__cache, 0])
{
    _currel = global.__wincache[__cache, __queue_pointer];
    
    var _rs, _el, x1, y1, x2, y2, _max_percentage, _extra_load;
    _rs = global.__winel[_currel, 34];
    switch(_rs)
    {
        //Horizontal containers
        //Parameters to take into account:
        //x-offset, y-offset
        case el_multielement:
            //Calculate percentage of extra width that can be used
            var _el, x1, y1, x2, y2;
            x1 = global.__winel[_currel, 1];
            y1 = global.__winel[_currel, 2];
            x2 = global.__winel[_currel, 3];
            y2 = global.__winel[_currel, 4];
            
            _max_percentage = (global.__winel[_currel, 11] - global.__winel[_currel, 102]);
            if(_max_percentage != 0) _max_percentage = (x2 - x1 - (global.__winel[_currel, 102] - global.__winel[_currel, 5] - global.__winel[_currel, 6])) / _max_percentage
            
            var _loop_depth;
            _loop_depth = global.__windcache[__cache, __queue_pointer] + 1;
            for(_i = __queue_pointer + 1; _i < global.__winskip[__cache, __queue_pointer]; _i += 1)
            {
                if(global.__windcache[__cache, _i] != _loop_depth) { _i = global.__winskip[__cache, _i] - 1; continue }
                _el = global.__wincache[__cache, _i];
                
                var _sw, _sh, _xoff, _yoff;
                _xoff = global.__winel[_el, 9] * room_width;
                _yoff = global.__winel[_el, 10] * room_height;
                
                _sw = min(global.__winel[_el, 104], global.__winel[_el, 104] * _max_percentage + global.__winel[_el, 102] * (1 - _max_percentage))
                _sh = min(global.__winel[_el, 106], max(global.__winel[_el, 105], (y2 - y1)))
                //if(_sw > 300) show_message("Shoops! + " + string(x2 - x1));
                
                if(global.__winel[_el, 19])
                {
                    global.__winel[_el, 1] = x2 - _xoff + global.__winel[_el, 5] - _sw;
                    global.__winel[_el, 3] = x2 - _xoff - global.__winel[_el, 6];
                }else{
                    global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
                    global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + _sw;
                }
                //global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
                //global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + _sw;
            
                global.__winel[_el, 2] = y1 + _yoff + global.__winel[_el, 7];
                global.__winel[_el, 4] = y1 + _yoff - global.__winel[_el, 8] + _sh;
                x1 += _sw;
            }
            break;
        
        //Vertical containers
        //[X]overlapping, [X]horizontal-float, [X]vertical-float, [X]x-offset, [X]y-offset, [X]center
        case el_container:
        case el_canvas:
            x1 = global.__winel[_currel, 1];
            y1 = global.__winel[_currel, 2];
            x2 = global.__winel[_currel, 3];
            y2 = global.__winel[_currel, 4];
            
            if(global.__winel[_currel, 32])
            {
                var _loop_depth;
                _loop_depth = global.__windcache[__cache, __queue_pointer] + 1;
                for(_i =  __queue_pointer + 1; _i < global.__winskip[__cache, __queue_pointer]; _i += 1)
                {
                    if(global.__windcache[__cache, _i] != _loop_depth) { _i = global.__winskip[__cache, _i] - 1; continue }
                    _el = global.__wincache[__cache, _i];
                    
                    var _xoff, _yoff;
                    _xoff = global.__winel[_el, 9] * room_width;
                    _yoff = global.__winel[_el, 10] * room_height;
                    
                    global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
                    global.__winel[_el, 2] = y1 + _yoff + global.__winel[_el, 7];
                    global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + min(global.__winel[_el, 104], max(global.__winel[_el, 102], (x2 - x1)));
                    global.__winel[_el, 4] = y1 + _yoff - global.__winel[_el, 8] + min(global.__winel[_el, 106], max(global.__winel[_el, 105], (y2 - y1)));
                }
            }else{
                //Calculate percentage of extra height that can be used
                _max_percentage = (global.__winel[_currel, 12] - global.__winel[_currel, 105]);
                if(_max_percentage != 0) _max_percentage = (y2 - y1 - (global.__winel[_currel, 105] - global.__winel[_currel, 7] - global.__winel[_currel, 8])) / _max_percentage
                var _loop_depth;
                _loop_depth = global.__windcache[__cache, __queue_pointer] + 1;
                for(_i =  __queue_pointer + 1; _i < global.__winskip[__cache, __queue_pointer]; _i += 1)
                {
                    if(global.__windcache[__cache, _i] != _loop_depth) { _i = global.__winskip[__cache, _i] - 1; continue }
                    _el = global.__wincache[__cache, _i];
                    
                    var _sw, _sh, _xoff, _yoff;
                    _xoff = global.__winel[_el, 9] * room_width;
                    _yoff = global.__winel[_el, 10] * room_height;
                    
                    _sw = min(global.__winel[_el, 104], max(global.__winel[_el, 102], (x2 - x1)));
                    _sh = min(global.__winel[_el, 106], global.__winel[_el, 106] * _max_percentage + global.__winel[_el, 105] * (1 - _max_percentage))
                    //
                    
                    if(global.__winel[_el, 72])
                    {
                        var _mx, _my;
                        _mx = (x1 + x2) / 2;
                        _my = (y1 + y2) / 2;
                        
                        global.__winel[_el, 2] = _my + _yoff + global.__winel[_el, 7] - _sh / 2;
                        global.__winel[_el, 4] = _my + _yoff - global.__winel[_el, 8] + _sh / 2;
                        global.__winel[_el, 1] = _mx + _xoff + global.__winel[_el, 5] - _sw / 2;
                        global.__winel[_el, 3] = _mx + _xoff - global.__winel[_el, 6] + _sw / 2;
                    }else{
                        if(global.__winel[_el, 19])
                        {
                            global.__winel[_el, 1] = x2 - _xoff + global.__winel[_el, 5] - _sw;
                            global.__winel[_el, 3] = x2 - _xoff - global.__winel[_el, 6];
                        }else{
                            global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
                            global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + _sw;
                        }
                        
                        if(global.__winel[_el, 18])
                        {
                            global.__winel[_el, 2] = y2 - _yoff + global.__winel[_el, 7] - _sh;
                            global.__winel[_el, 4] = y2 - _yoff - global.__winel[_el, 8];
                        }else{
                            global.__winel[_el, 2] = y1 + _yoff + global.__winel[_el, 7];
                            global.__winel[_el, 4] = y1 + _yoff - global.__winel[_el, 8] + _sh;
                            y1 += _sh
                        }
                    }
                }
            }
            break;
        
        //Map items in scrollbox to a surface with size (x2 - x1) x (65535);
        //Set content-h, hwich is used when drawing & stepping
        case el_scrollbox:
            var _sh, x1, y1, x2, y2;
            x1 = 0;
            y1 = 0;
            x2 = global.__winel[_currel, 3] - global.__winel[_currel, 1]
            y2 = 65535
            _tsh = 0;
            
            var _loop_depth;
            _loop_depth = global.__windcache[__cache, __queue_pointer] + 1;
            for(_i =  __queue_pointer + 1; _i < global.__winskip[__cache, __queue_pointer]; _i += 1)
            {
                if(global.__windcache[__cache, _i] != _loop_depth) { _i = global.__winskip[__cache, _i] - 1; continue }
                _el = global.__wincache[__cache, _i];
                
                var _sw, _sh, _xoff, _yoff;
                _xoff = global.__winel[_el, 9] * room_width;
                _yoff = global.__winel[_el, 10] * room_height;
                
                _sw = min(global.__winel[_el, 104], max(global.__winel[_el, 102], (x2 - x1)));
                _sh = min(global.__winel[_el, 106], global.__winel[_el, 106] * _max_percentage + global.__winel[_el, 105] * (1 - _max_percentage))
                //
                
                if(global.__winel[_el, 72])
                {
                    var _mx, _my;
                    _mx = (x1 + x2) / 2;
                    _my = (y1 + y2) / 2;
                    
                    global.__winel[_el, 2] = _my + _yoff + global.__winel[_el, 7] - _sh / 2;
                    global.__winel[_el, 4] = _my + _yoff - global.__winel[_el, 8] + _sh / 2;
                    global.__winel[_el, 1] = _mx + _xoff + global.__winel[_el, 5] - _sw / 2;
                    global.__winel[_el, 3] = _mx + _xoff - global.__winel[_el, 6] + _sw / 2;
                }else{
                    if(global.__winel[_el, 19])
                    {
                        global.__winel[_el, 1] = x2 - _xoff + global.__winel[_el, 5] - _sw;
                        global.__winel[_el, 3] = x2 - _xoff - global.__winel[_el, 6];
                    }else{
                        global.__winel[_el, 1] = x1 + _xoff + global.__winel[_el, 5];
                        global.__winel[_el, 3] = x1 + _xoff - global.__winel[_el, 6] + _sw;
                    }
                    
                    if(global.__winel[_el, 18])
                    {
                        global.__winel[_el, 2] = y2 - _yoff + global.__winel[_el, 7] - _sh;
                        global.__winel[_el, 4] = y2 - _yoff - global.__winel[_el, 8];
                    }else{
                        global.__winel[_el, 2] = y1 + _yoff + global.__winel[_el, 7];
                        global.__winel[_el, 4] = y1 + _yoff - global.__winel[_el, 8] + _sh;
                        y1 += _sh
                    }
                }
                
                _tsh += _sh;
            }
            
            global.__winel[_currel, 12] = _tsh;
            break;
    }
    
    __queue_pointer += 1;
}
#define XWindow_build_cache
var _curcache, m, i, _currel, __queue_pointer;
_curcache = global.__wincache_counter
XWindow_set(argument0, "child-cache", _curcache);
global.__wincache_counter += 1;
global.__wincache[_curcache, 0] = 1;

XWindow_build_cache_recursive(_curcache, argument0, 0);
global.__winskip[_curcache, 1] = global.__wincache[_curcache, 0];

return _curcache;
#define XWindow_build_cache_recursive
//XWindow_build_cache_recursive(0: cache_id, 1: current, 2: depth)

global.__wincache  [argument0, global.__wincache[argument0, 0]] = argument1
global.__windcache [argument0, global.__wincache[argument0, 0]] = argument2;
global.__wincache  [argument0, 0] += 1;

if(global.__winel[argument1, 34] != el_scrollbox)
{
    var m, i, __basepos;
    m = global.__winel[argument1, 0];
    for(i = 0; i < ds_list_size(m); i += 1)
    {
        __basepos = global.__wincache[argument0, 0];
        XWindow_build_cache_recursive(argument0, ds_list_find_value(m, i), argument2 + 1);
        global.__winskip[argument0, __basepos] = global.__wincache[argument0, 0];
    }
}
#define XWindow_invalidate_cache
XWindow_set(argument0, "child-cache", -1);
#define XWindow_parse_value
var txt, _first;
txt = argument0;
_first = string_char_at(txt, 1);
if(_first == "$")
{
    //Hexadecimal
    var hex, dec, pow, pos;
    hex = string_lower(string_copy(argument0, 2, string_length(argument0) - 1))
    dec = 0
    pow = 0
    for (i = string_length(hex); i >= 1; i -= 1) 
    { 
        pos[i] = string_char_at(hex,i) 
        if (pos[i] == "a") {pos[i] = "10"} 
        if (pos[i] == "b") {pos[i] = "11"} 
        if (pos[i] == "c") {pos[i] = "12"} 
        if (pos[i] == "d") {pos[i] = "13"} 
        if (pos[i] == "e") {pos[i] = "14"} 
        if (pos[i] == "f") {pos[i] = "15"} 
        dec += real(pos[i]) * (power(16, pow))
        pow += 1
    }
    return dec;
}else if(_first == "'" || _first == '"')
{
    //string
    return string_copy(txt, 2, string_length(txt) - 2);
}else if(_first == "@")
{
    //string
    if(argument1 == -1)
    {
        show_error("Cannot use constants here: " + txt, true);
    }else{
        if(ds_map_exists(argument1, txt))
        {
            return ds_map_find_value(argument1, txt);
        }else{
            show_error("Constant does not exist: " + txt, true);
        }
    }
}else if(txt == "true")
{
    return true;
}else if(txt == "false")
{
    return false;
}else if(txt == "max")
{
    return sz_max;
}else if(txt == "min")
{
    return sz_min;
}else if(txt == "preferred")
{
    return sz_preferred;
}else if(txt == "top")
{
    return 0;
}else if(txt == "bottom")
{
    return 1;
}else
{
    //real
    return real(txt);
}/*else{
    show_error("GMWML: Unknown type of value " + txt, true);
}*/
#define XWindow_parse_valuelist
//XWindow_parse_valuelist(string_data);
var i, txt, len, map;
txt = argument0;
len = string_length(txt);
map = ds_map_create();

var c_name, c_value, location;
location = cloc_name;
c_name = "";
c_value = "";
for(i = 1; i <= len; i += 1)
{
    var char;
    char = string_char_at(txt, i);
    if(char == chr(10) || char == chr(13) || char == chr(9))
    {
        continue;
    }
    switch(char)
    {
        case ":":
            if(location == cloc_name)
            {
                location = cloc_value;
            }else{
                show_error("GMWML: Unexpected token ':' near " + string_copy(txt, i, 100), true)
            }
            break;
        case " ":
            if(location == cloc_instring)
            {
                c_value += char;
            }
            break;
        case ";":
            if(location == cloc_instring)
            {
                c_value += char;
            }else{
                //finish constant
                ds_map_add(map, c_name, XWindow_parse_value(c_value, argument1));
                c_name = "";
                c_value = "";
                location = cloc_name;
            }
            break;
        case '"':
        case "'":
            if(location == cloc_value)
            {
                c_value += char;
                location = cloc_instring;
            }else if(location == cloc_instring)
            {
                c_value += char;
                location = cloc_value;
            }else{
                show_error("GMWML: Unexpected token '" + char + "' near " + string_copy(txt, i, 100), true)
            }
            break;
        default:
            switch(location)
            {
                case cloc_name:
                    c_name += char;
                    break;
                case cloc_value:
                    c_value += char;
                    break;
                case cloc_instring:
                    c_value += char;
                    break;
            }
    }
}
return map;
#define XWindow_parse_layout
//XWindow_parse_layout(string-data, styles);
var i, txt, len;
txt = argument0;
len = string_length(txt);

var t_name, t_paramname, t_paramvalue, t_text;
var location, tagdepth, end_flag;
tagdepth = 0;
location = tloc_master;


//0: Opening tag
//1: Normal end (</tag>)
//2: Special end (<tag />)
end_flag = 0;

t_name = "";
t_paramname = "";
t_paramvalue = "";
t_text = "";

var l_stack, _fos, _jo, _jc, _txt_first, _txt_prev;
var _line_num;
_line_num = 0;

l_stack = ds_stack_create();
_fos = -1;
//ds_stack_push(l_stack, XWindow_create(el_container, 0, 0, 0, 0, "max"));

//Just Opened; Indicates whether the tag was just opened
_jo = 0;

//Indicates whether the tag is Just Closed (eg <.../>)
_jc = 0;

_txt_first = -1;
_txt_prev = -1;

var w;
w = XWindow_create(el_container);
for(i = 1; i <= len; i += 1)
{
    var char;
    char = string_char_at(txt, i);
    
    if(char == chr(9))
    {
        continue;
    }else if(char == chr(10) || char == chr(13))
    {
        _line_num += 1;
        continue;
    }
    switch(char)
    {
        case "<":
            location = tloc_tagname;
            _jo = 1;
            _jc = 0;
            break;
        case ">":
            if(_jo && location == tloc_tagname)
            {
                switch(t_name)
                {
                    case "label":
                    case "button":
                        w = XWindow_create(el_label);
                        break;
                    case "canvas":
                        w = XWindow_create(el_canvas);
                        break;
                    case "container":
                        w = XWindow_create(el_container);
                        break;
                    case "textbox":
                        w = XWindow_create(el_textbox);
                        if(_txt_first == -1)
                        {
                            _txt_first = w;
                        }
                        
                        if(_txt_prev != -1)
                        {
                            global.__winel[_txt_prev, 92] = w;
                            global.__winel[_txt_prev, 93] = w;
                        }
                        _txt_prev = w;
                        break;
                    case "multielement":
                        w = XWindow_create(el_multielement);
                        break;
                    case "scrollbox":
                        w = XWindow_create(el_scrollbox);
                        break;
                    case "arrow":
                        w = XWindow_create(el_arrow);
                        break;
                    default:
                        show_error("Unknown tag name: '" + t_name + "' at line " + string(_line_num) + ": " + string_copy(txt, i - 3, 150) + " (" + string(location) + ")", true);
                        break;
                }
                
                location = tloc_paramname;
                t_paramname = "";
                t_paramvalue = "";
                global.__winel[w, 53] = t_name;
            }
            
            if(_jc)
            {
                end_flag = 2;
            }
            
            switch(location)
            {
                case tloc_paramname:
                    if(t_paramname != "")
                    {
                        show_error("GMWLS: Unfinished tagname " + t_name + " at position " + string(i) + " near parameter name " + t_paramname, true);
                    }else{
                        do_finish = true;
                    }
                    break;
                case tloc_paramval:
                    //finish last parameter
                    show_error("GMWLS: Unfinished parameter " + t_name + " at position " + string(i) + " near parameter name " + t_paramname, true);
                    break;
                case tloc_tagname:
                    do_finish = true;
                    break;
            }
            
            if(end_flag == 1)
            {
                tagdepth -= 1;
                var _name, _element;
                _element = ds_stack_pop(l_stack);
                _name = global.__winel[_element, 53];
                
                if(_name != t_name)
                {
                    show_error("GMWLS: Wrong closing tag for '" + _name + "': " + t_name + "' at line " + string(_line_num) + ": " + string_copy(txt, i - 3, 150) + " (" + string(location) + ")", true);
                }
                
                if(string_replace(t_text, " ", "") != "")
                {
                    global.__winel[_element, 62] = t_text;
                }
            }else if(end_flag == 0){
                tagdepth += 1;
                if(ds_stack_size(l_stack) > 0)
                {
                    XWindow_add(ds_stack_top(l_stack), w);
                }else{
                    _fos = w;
                }
                
                ds_stack_push(l_stack, w);
            }else if(end_flag == 2)
            {
                XWindow_add(ds_stack_top(l_stack), w);
            }
            
            t_text = "";
            t_name = "";
            location = tloc_tagcontent;
            
            end_flag = 0;
            break;
        case "\":
            var _next;
            _next = string_char_at(txt, i + 1);
            if(_next == "<" || _next == ">" || _next == "/" || _next == "\" || _next == "[" || _next == "]" || _next == ",")
            {
                switch(location)
                {
                    case tloc_tagname:
                        t_name += _next;
                        break;
                    case tloc_paramname:
                        t_paramname += _next;
                        break;
                    case tloc_paramval:
                        t_paramvalue += _next;
                        break;
                    case tloc_tagcontent:
                        t_text += _next;
                        break;
                }
                i += 1;
            }else{
                switch(location)
                {
                    case tloc_tagname:
                        t_name += char;
                        break;
                    case tloc_paramname:
                        t_paramname += char;
                        break;
                    case tloc_paramval:
                        t_paramvalue += char;
                        break;
                    case tloc_tagcontent:
                        t_text += char;
                        break;
                }
            }
            break;
        case " ":
            _jo = 0;
            switch(location)
            {
                case tloc_tagname:
                    switch(t_name)
                    {
                        case "label":
                        case "button":
                            w = XWindow_create(el_label);
                            break;
                        case "canvas":
                            w = XWindow_create(el_canvas);
                            break;
                        case "container":
                            w = XWindow_create(el_container);
                            break;
                        case "textbox":
                            w = XWindow_create(el_textbox);
                            if(_txt_first == -1)
                            {
                                _txt_first = w;
                            }
                            
                            if(_txt_prev != -1)
                            {
                                global.__winel[_txt_prev, 92] = w;
                                global.__winel[_txt_prev, 93] = w;
                            }
                            _txt_prev = w;
                            break;
                        case "multielement":
                            w = XWindow_create(el_multielement);
                            break;
                        case "scrollbox":
                            w = XWindow_create(el_scrollbox);
                            break;
                        case "arrow":
                            w = XWindow_create(el_arrow);
                            break;
                        default:
                            show_error("Unknown tag name: '" + t_name + "' at line " + string(_line_num) + ": " + string_copy(txt, i - 3, 100) + " (" + string(location) + ")", true);
                            break;
                    }
                    
                    location = tloc_paramname;
                    t_paramname = "";
                    t_paramvalue = "";
                    global.__winel[w, 53] = t_name;
                    break;
                case tloc_tagcontent:
                    t_text += char;
                    break;
            }
            break;
        case "/":
            if(_jo)
            {
                end_flag = 1;
            }else
            {
                _jc = 1;
            }
            break;
        case "[":
            if(location == tloc_paramname)
            {
                location = tloc_paramval;
            }else{
                show_error("Unexpected token '['", true);
            }
            break;
        case ",":
        case "]":
            if(location == tloc_paramval)
            {
                if(t_paramname == "style")
                {
                    var __key, __map;
                    __map = XWindow_find_style(argument1, t_paramvalue)
                    __key = ds_map_find_first(__map);
                    while(__key != 0)
                    {
                        global.__winel[w, __key] = ds_map_find_value(__map, __key);
                        __key = ds_map_find_next(__map, __key);
                    }
                    
                    t_paramvalue = "";
                }else if(t_paramname == "name")
                {
                    global.__winel[w, 15] = t_paramvalue
                }else{
                    var _copyto;
                    _copyto = XWindow_find_style(argument1, t_paramvalue)
                    
                    switch(t_paramname)
                    {
                        case "hover":
                            global.__winel[w, 43] = _copyto
                            break;
                        case "unhover":
                            global.__winel[w, 44] = _copyto
                            break;
                        case "onopen":
                            global.__winel[w, 45] = _copyto
                            break;
                        case "onclose":
                            global.__winel[w, 46] = _copyto
                            break;
                        case "onspecial":
                            global.__winel[w, 47] = _copyto
                            break;
                        case "onunspecial":
                            global.__winel[w, 48] = _copyto
                            break;
                        case "extrawindow":
                            global.__winel[w, 49] = _copyto
                            break;
                        case "unextrawindow":
                            global.__winel[w, 50] = _copyto
                            break;
                        case "onerror":
                            global.__winel[w, 51] = _copyto
                            break;
                        default:
                            show_error("Unknown parameter name '" + t_paramname + "'", true);
                            break;
                    }
                }
            }else{
                show_error("Unexpected token ','", true);
            }
            
            if(char == "]")
            {
                location = tloc_paramname;
                t_paramname = "";
                t_paramvalue = "";
            }
            break;
        default:
            switch(location)
            {
                case tloc_tagname:
                    t_name += char;
                    break;
                case tloc_paramname:
                    t_paramname += char;
                    break;
                case tloc_paramval:
                    t_paramvalue += char;
                    break;
                case tloc_tagcontent:
                    t_text += char;
                    break;
            }
            break;
    }
}

if(_txt_prev != -1 && _txt_first != -1)
{
    global.__winel[_txt_prev, 92] = _txt_first;
    global.__winel[_txt_prev, 93] = -1;
}

if(ds_stack_size(l_stack) == 0)
{
    ds_stack_destroy(l_stack);
    return _fos;
}
var val;
val = ds_stack_pop(l_stack);
ds_stack_destroy(l_stack);
return val;
#define XWindow_load
var i, txt, len;
txt = argument0;
//len = string_length(txt);

var c_pos1, c_pos2;
c_pos1 = string_pos("<constants>", txt) + 11;
c_pos2 = string_pos("</constants>", txt);
p_pos1 = string_pos("<styles>", txt) + 8;
p_pos2 = string_pos("</styles>", txt);
l_pos1 = string_pos("<layout>", txt) + 8;
l_pos2 = string_pos("</layout>", txt);

var str_constants, str_preset, str_layout;
str_constants   = string_copy(txt, c_pos1, c_pos2 - c_pos1);
str_styles      = string_copy(txt, p_pos1, p_pos2 - p_pos1);
str_layout      = string_copy(txt, l_pos1, l_pos2 - l_pos1);

var data_c, data_p;
data_c = XWindow_parse_valuelist(str_constants, global.__constant_map);

var __key, __map;
__map = global.__constant_map;
__key = ds_map_find_first(__map);
while(is_string(__key))
{
    ds_map_add(data_c, __key, ds_map_find_value(__map, __key));
    __key = ds_map_find_next(__map, __key);
}

data_p = ds_map_create();
XWindow_parse_styles(str_styles, data_p, data_c);
ds_map_destroy(data_c);

globalvar __style_info;
__style_info = data_p;

var _ret;
_ret = XWindow_parse_layout(str_layout, data_p);


if(global.__f_load && global.__f_title == -1)
{
    global.__f_title = font_add("Arial Black", 24, 1, 0, 32, 127);
    draw_set_font(global.__f_title);
    if(string_height("GameMaker Server") <= 0)
    {
        global.__f_title = -1;
        global.__f_load = false;
    }
}

if(global.__f_load && global.__f_text == -1)
{
    global.__f_text = font_add("Verdana", 16, 0, 0, 32, 127);
    draw_set_font(global.__f_text);
    if(string_height("GameMaker Server") <= 0)
    {
        global.__f_text = -1;
        global.__f_load = false;
    }
}

if(global.__f_load && global.__f_small == -1)
{
    global.__f_small = font_add("Verdana", 10, 1, 0, 32, 127);
    draw_set_font(global.__f_small);
    if(string_height("GameMaker Server") <= 0)
    {
        global.__f_small = -1;
        global.__f_load = false;
    }
}

XWindow_position(_ret, 0, 0, room_width, room_height);
return _ret;
#define XWindow_find_style
if(ds_map_exists(argument0, argument1))
{
    return ds_map_find_value(argument0, argument1);
}else{
    show_error("Undefined style name '" + argument1 + "'", true);
}
#define XWindow_parse_styles
//XWindow_parse_presets(text, basemap, constants);
/*
Everything is parsed into a flat map:

name1
{
    name2
    {
        
    }
    
    parameter: Value;
}

Results in:

Map: <basemap>
{
    "name1" => XWindow
    {
        "parameter" => Value
    }
    
    "name1.name2" => XWindow
    {
    
    }
}
*/

var _pos, _strlen, _curname, _constants, _basename, _current_map, _map_stack, _str;
_str = string_replace_all(string_replace_all(string_replace_all(string_replace_all(argument0, " ", ""), chr(13), ""), chr(10), ""), chr(9), "");
_strlen = string_length(_str);
_constants = argument2;
_pos = 1;
_basename = "";
_map_stack = ds_stack_create();
_name_stack = ds_stack_create();
_current_map = -1;

while(true)
{
    var _endpos, _substr, _endpos2;
    _substr = string_copy(_str, _pos, _strlen - _pos);
    _endpos = string_pos(":", _substr);
    
    _curname = string_copy(_substr, 1, _endpos - 1);
    
    if(string_char_at(_str, _pos + _endpos) == "{")
    {
        _pos += _endpos + 1;
        
        ds_stack_push(_map_stack, _current_map);
        ds_stack_push(_name_stack, _basename);
        if(_basename == "")
        {
            _basename += _curname;
        }else{
            _basename += "." + _curname;
        }
        
        _current_map = ds_map_create();
        ds_map_add(argument1, _basename, _current_map);
    }else{
        _endpos2 = string_pos(";", _substr);
        _curval = string_copy(_substr, _endpos + 1, _endpos2 - _endpos - 1);
        
        if(_current_map == -1)
        {
            show_error("Error while parsing styles: property out of bounds: " + string(argument0), false);
        }
        
        if(_curname == "background" || _curname == "background-1" || _curname == "background-2" || _curname == "background-3" || _curname == "background-4")
        {
            if(!ds_map_exists(_current_map, "background-alpha"))
            {
                ds_map_add(_current_map, 24, 1.0);
            }
        }
        
        if(_curname == "background")
        {
            var _val;
            _val = XWindow_parse_value(_curval, _constants);
            ds_map_add(_current_map, 20, _val);
            ds_map_add(_current_map, 21, _val);
            ds_map_add(_current_map, 22, _val);
            ds_map_add(_current_map, 23, _val);
        }else if(_curname == "margin")
        {
            var _val;
            _val = XWindow_parse_value(_curval, _constants);
            ds_map_add(_current_map, 5, _val);
            ds_map_add(_current_map, 6, _val);
            ds_map_add(_current_map, 7, _val);
            ds_map_add(_current_map, 8, _val);
        }else{
            var _hn;
            _hn = ds_map_find_value(global.__hashmap, _curname);
            if(_hn == 0)
            {
                show_error("Unknown parameter: " + string(_curname), true);
            }else{
                if(ds_map_exists(_current_map, _hn))
                {
                    ds_map_replace(_current_map, _hn, XWindow_parse_value(_curval, _constants));
                }else{
                    ds_map_add(_current_map, _hn, XWindow_parse_value(_curval, _constants));
                }
            }
        }
        
        _pos += _endpos2;
    }
    
    while(string_char_at(_str, _pos) == "}")
    {
        if(ds_stack_size(_name_stack) > 0 && ds_stack_size(_map_stack) > 0)
        {
            _current_map = ds_stack_pop(_map_stack);
            _basename = ds_stack_pop(_name_stack);
            _pos += 1;
        }else{
            show_error("Error while parsing styles: too many } at pos " + string(_pos) + " in code " + _str, false)
        }
    }
    
    if(_pos > _strlen) break;
}

ds_stack_destroy(_map_stack);
ds_stack_destroy(_name_stack);
#define XWindow_add
//show_message("add to " + string(global.__winel[argument0, 53]) + " element " + string(global.__winel[argument1, 53]))

ds_list_add(global.__winel[argument0, 0], argument1);

//show_message("new size: " + string(ds_list_size(global.__winel[argument0, 0])));
#define XWindow_destroy_children
var _m, _i;
_m = global.__winel[argument0, 0];

for(_i = 0; _i < ds_list_size(_m); _i += 1)
{
    XWindow_destroy_children(ds_list_find_value(_m, _i), false);
}

if(argument1)
{
    ds_list_clear(_m);
}else{
    ds_list_destroy(_m);
    if(global.__winel[argument0, 37] != -1) XWindow_destroy(global.__winel[argument0, 37]);
    if(global.__winel[argument0, 38] != -1) XWindow_destroy(global.__winel[argument0, 38]);
    if(global.__winel[argument0, 43] != -1) XWindow_destroy(global.__winel[argument0, 43]);
    if(global.__winel[argument0, 44] != -1) XWindow_destroy(global.__winel[argument0, 44]);
    if(global.__winel[argument0, 45] != -1) XWindow_destroy(global.__winel[argument0, 45]);
    if(global.__winel[argument0, 46] != -1) XWindow_destroy(global.__winel[argument0, 46]);
    if(global.__winel[argument0, 47] != -1) XWindow_destroy(global.__winel[argument0, 47]);
    if(global.__winel[argument0, 48] != -1) XWindow_destroy(global.__winel[argument0, 48]);
    if(global.__winel[argument0, 49] != -1) XWindow_destroy(global.__winel[argument0, 49]);
    if(global.__winel[argument0, 50] != -1) XWindow_destroy(global.__winel[argument0, 50]);
    if(global.__winel[argument0, 51] != -1) XWindow_destroy(global.__winel[argument0, 51]);
    
    XWindow_destroy(argument0);
}
#define XWindow_focus
global.__focus_item = argument0;
if(global.__kb_when_tb)
{
    gms_show_keyboard();
}
#define XWindow_tb_select_all
if(argument0 != -1)
{
    var __txt;
    XWindow_focus(argument0);
    __txt  = global.__winel[argument0, 62];
    global.__winel[argument0, 74] = 1;
    global.__winel[argument0, 75] = string_length(__txt) + 1;
}
#define XWindow_find
//XWindow_find(element, name)
if(global.__winel[argument0, 15] == argument1)
{
    return argument0;
}else{
    var m, i;
    m = global.__winel[argument0, 0];
    for(i = 0; i < ds_list_size(m); i += 1)
    {
        var result;
        result = XWindow_find(ds_list_find_value(m, i), argument1);
        if(result != -1)
        {
            return result;
        }
    }
}

return -1;
#define XWindow_close
XWindow_perform(argument0, 46, 1);
#define XWindow_show
if(argument0 == -1)
{
    show_error("Trying to show not-loaded window: " + string(argument0), false);
}

if(argument0 == global.__xls_window)
{
    global.__xls_open = true;
}else if(argument0 == global.__xrs_window)
{
    global.__xrs_open = true;
}else if(argument0 == global.__xhs_window)
{
    global.__xhs_open = true;
}else if(argument0 == global.__xas_window)
{
    global.__xas_open = true;
}else if(argument0 == global.__xss_window)
{
    global.__xss_open = true;
}else if(argument0 == global.__xfs_window)
{
    global.__xfs_open = true;
}else if(argument0 == global.__xus_window)
{
    global.__xus_open = true;
}else if(argument0 == global.__xkb_window)
{
    global.__xkb_open = true;
}else if(argument0 == global.__xms_window)
{
    global.__xms_open = true;
}else{
    show_error("Unknown window to show: " + string(argument0), false);
}

XWindow_perform(argument0, 45, true);
#define XWindow_get
if(ds_map_exists(global.__hashmap, argument1))
{
    return global.__winel[argument0, ds_map_find_value(global.__hashmap, argument1)];
}else{
    show_error("Trying to access element " + argument1, true)
}
#define XWindow_set
if(ds_map_exists(global.__hashmap, argument1))
{
    global.__winel[argument0, ds_map_find_value(global.__hashmap, argument1)] = argument2;
}else{
    show_error("Trying to access element " + argument1, true)
}
#define XWindow_init
global.__focus_item = -1;
global.__timer = 0;
global.__f_load = true;

global.__xmessage_queue = ds_queue_create();

global.__constant_map      = ds_map_create();
ds_map_add(global.__constant_map, "@c_fault_color", c_red);
ds_map_add(global.__constant_map, "@c_good_color", c_green);
ds_map_add(global.__constant_map, "@c_hover_color", $999999);
ds_map_add(global.__constant_map, "@c_textbox_color", $FFFFFF);
ds_map_add(global.__constant_map, "@c_button1", $50B7FB);
ds_map_add(global.__constant_map, "@c_button2", $48A5E2);
ds_map_add(global.__constant_map, "@c_buttonhover1", $90D1FC);
ds_map_add(global.__constant_map, "@c_buttonhover2", $82BCE3);
ds_map_add(global.__constant_map, "@c_buttondisable", $DDDDDD);
ds_map_add(global.__constant_map, "@c_border", $166DA6);
ds_map_add(global.__constant_map, "@c_background1", $FDFDFD);
ds_map_add(global.__constant_map, "@c_background2", $E4E4E4);
ds_map_add(global.__constant_map, "@c_selection", $95BDD7);
ds_map_add(global.__constant_map, "@c_text", $1B4764);
ds_map_add(global.__constant_map, "@c_grey_text", $CCCCCC);
ds_map_add(global.__constant_map, "@c_scrollbar", $888888);

global.__f_title = -1;
global.__f_text  = -1;
global.__f_small = -1;
ds_map_add(global.__constant_map, "@f_title", -2);
ds_map_add(global.__constant_map, "@f_text", -3);
ds_map_add(global.__constant_map, "@f_small", -4);

ds_map_add(global.__constant_map, "@txt_registration", "Registration");
ds_map_add(global.__constant_map, "@txt_username", "Username");
ds_map_add(global.__constant_map, "@txt_guest", "Guest_");
ds_map_add(global.__constant_map, "@txt_password", "Password");
ds_map_add(global.__constant_map, "@txt_repeat_password", "repeat password");
ds_map_add(global.__constant_map, "@txt_email", "E-mail");
ds_map_add(global.__constant_map, "@txt_register", "Register");
ds_map_add(global.__constant_map, "@txt_cancel", "Cancel");
ds_map_add(global.__constant_map, "@txt_registration_complete", "Registration Complete");
ds_map_add(global.__constant_map, "@txt_you_can_now_login", "You can now login with your username and password!");
ds_map_add(global.__constant_map, "@txt_login", "Login");
ds_map_add(global.__constant_map, "@txt_tos", "By using GameMaker Server you agree to the terms of use. See gamemakerserver.com for more info.");
ds_map_add(global.__constant_map, "@txt_achievements", "Achievements");
ds_map_add(global.__constant_map, "@txt_reached", "reached");
ds_map_add(global.__constant_map, "@txt_not_reached", "not reached");
ds_map_add(global.__constant_map, "@txt_statistics", "Statistics");
ds_map_add(global.__constant_map, "@txt_updating_game", "Updating game...");
ds_map_add(global.__constant_map, "@txt_friends", "Friends");
ds_map_add(global.__constant_map, "@txt_online", "online");
ds_map_add(global.__constant_map, "@txt_offline", "offline");
ds_map_add(global.__constant_map, "@txt_achievement_get", "Achievement get");

global.__tab_pressed       = 0;
global.__enter_pressed     = 0;
global.__kb_when_tb        = 0;

global.__tween_factor      = 1;//Normal: 1
global.__tween_ongoing     = 0;

global.__el_list           = ds_list_create();
global.__click_caught      = 0;

global.__wincache_counter  = 0;
global.__poscache_counter  = 0;

//Login
global.__xls_window = -1;
global.__xls_styles = -1;
global.__xls_open = 0;
global.__xls_register_link = true;
global.__xls_isloggingin = false;
global.__xls_username_get = "";
global.__xls_loginobject = -10;

global.__prev_zoom_focus_pos = 0;
global.__element_queue = ds_queue_create();
global.__element_queue_arg0 = ds_queue_create();

//Registration
global.__xrs_window = -1;
global.__xrs_styles = -1;
global.__xrs_open = 0;
global.__xrs_from_ls = 0;
global.__xrs_isregistering = false;
global.__xrs_username = "";

//Highscores
global.__xhs_window = -1;
global.__xhs_styles = -1;
global.__xhs_open = 0;

//Achievements
global.__xas_window = -1;
global.__xas_styles = -1;
global.__xas_open = 0;

//Statistics
global.__xss_window = -1;
global.__xss_styles = -1;
global.__xss_open = 0;

//Friends
global.__xfs_window = -1;
global.__xfs_styles = -1;
global.__xfs_open = 0;

//Update
global.__xus_window = -1;
global.__xus_styles = -1;
global.__xus_open = 0;

//Messages
global.__xms_window = -1;
global.__xms_styles = -1;
global.__xms_open = 0;
global.__xms_waittime = 0;

//Keyboard
global.__xkb_window = -1;
global.__xkb_styles = -1;
global.__xkb_open = 0;
global.__xkb_shift = 0;

global.__zoom_focus_pos = 0;

global.__windows_made = 0;

global.__winstack = ds_stack_create();
global.__wincounter = 0;

//#DEBUG
global.__hashmap = ds_map_create();
ds_map_add(global.__hashmap, "children", 0);
ds_map_add(global.__hashmap, "x1", 1);
ds_map_add(global.__hashmap, "y1", 2);
ds_map_add(global.__hashmap, "x2", 3);
ds_map_add(global.__hashmap, "y2", 4);
ds_map_add(global.__hashmap, "margin-left", 5);
ds_map_add(global.__hashmap, "margin-right", 6);
ds_map_add(global.__hashmap, "margin-top", 7);
ds_map_add(global.__hashmap, "margin-bottom", 8);
ds_map_add(global.__hashmap, "x-offset", 9);
ds_map_add(global.__hashmap, "y-offset", 10);
ds_map_add(global.__hashmap, "content-w", 11);
ds_map_add(global.__hashmap, "content-h", 12);
ds_map_add(global.__hashmap, "width", 13);
ds_map_add(global.__hashmap, "height", 14);
ds_map_add(global.__hashmap, "name", 15);
ds_map_add(global.__hashmap, "effective-w", 16);
ds_map_add(global.__hashmap, "effective-h", 17);
ds_map_add(global.__hashmap, "vertical-float", 18);
ds_map_add(global.__hashmap, "horizontal-float", 19);
ds_map_add(global.__hashmap, "background-1", 20);
ds_map_add(global.__hashmap, "background-2", 21);
ds_map_add(global.__hashmap, "background-3", 22);
ds_map_add(global.__hashmap, "background-4", 23);
ds_map_add(global.__hashmap, "background-alpha", 24);
ds_map_add(global.__hashmap, "border-size", 25);
ds_map_add(global.__hashmap, "border-color", 26);
ds_map_add(global.__hashmap, "drop-shadow", 27);
ds_map_add(global.__hashmap, "drop-shadow-intensity", 28);
ds_map_add(global.__hashmap, "drop-shadow-color", 29);
ds_map_add(global.__hashmap, "drop-shadow-spread", 30);
ds_map_add(global.__hashmap, "alpha", 31);
ds_map_add(global.__hashmap, "overlapping", 32);
ds_map_add(global.__hashmap, "color", 33);
ds_map_add(global.__hashmap, "element-type", 34);
ds_map_add(global.__hashmap, "tween-affects-position", 35);
ds_map_add(global.__hashmap, "tween", 36);
ds_map_add(global.__hashmap, "tween_from", 37);
ds_map_add(global.__hashmap, "tween_to", 38);
ds_map_add(global.__hashmap, "tween_proc", 39);
ds_map_add(global.__hashmap, "tween_speed", 40);
ds_map_add(global.__hashmap, "tween_transform", 41);
ds_map_add(global.__hashmap, "tween-speed", 42);
ds_map_add(global.__hashmap, "on-hover", 43);
ds_map_add(global.__hashmap, "on-unhover", 44);
ds_map_add(global.__hashmap, "on-open", 45);
ds_map_add(global.__hashmap, "on-close", 46);
ds_map_add(global.__hashmap, "on-special", 47);
ds_map_add(global.__hashmap, "on-unspecial", 48);
ds_map_add(global.__hashmap, "on-extrawindow", 49);
ds_map_add(global.__hashmap, "on-unextrawindow", 50);
ds_map_add(global.__hashmap, "on-error", 51);
ds_map_add(global.__hashmap, "last-perform", 52);
ds_map_add(global.__hashmap, "tag-name", 53);
ds_map_add(global.__hashmap, "elastic", 54);
ds_map_add(global.__hashmap, "preferred-width", 55);
ds_map_add(global.__hashmap, "preferred-height", 56);
ds_map_add(global.__hashmap, "min-width", 57);
ds_map_add(global.__hashmap, "min-height", 58);
ds_map_add(global.__hashmap, "mouse-hover", 59);
ds_map_add(global.__hashmap, "animation", 60);
ds_map_add(global.__hashmap, "text-wrapping", 61);
ds_map_add(global.__hashmap, "text", 62);
ds_map_add(global.__hashmap, "font", 63);
ds_map_add(global.__hashmap, "padding-horizontal", 64);
ds_map_add(global.__hashmap, "padding-vertical", 65);
ds_map_add(global.__hashmap, "show-close", 66);
ds_map_add(global.__hashmap, "show-close-height", 67);
ds_map_add(global.__hashmap, "show-close-color", 68);
ds_map_add(global.__hashmap, "do-expect", 69);
ds_map_add(global.__hashmap, "arrow-size", 70);
ds_map_add(global.__hashmap, "arrow-length", 71);
ds_map_add(global.__hashmap, "center", 72);
ds_map_add(global.__hashmap, "disable-events", 73);
ds_map_add(global.__hashmap, "select1", 74);
ds_map_add(global.__hashmap, "select2", 75);
ds_map_add(global.__hashmap, "select-color", 76);
ds_map_add(global.__hashmap, "allow-spaces", 77);
ds_map_add(global.__hashmap, "password", 78);
ds_map_add(global.__hashmap, "length-limit", 79);
ds_map_add(global.__hashmap, "rp-left", 80);
ds_map_add(global.__hashmap, "rp-right", 81);
ds_map_add(global.__hashmap, "rp-backspace", 82);
ds_map_add(global.__hashmap, "rp-delete", 83);
ds_map_add(global.__hashmap, "rp-speed", 84);
ds_map_add(global.__hashmap, "rp-speed2", 85);
ds_map_add(global.__hashmap, "rp-left-count", 86);
ds_map_add(global.__hashmap, "rp-right-count", 87);
ds_map_add(global.__hashmap, "rp-backspace-count", 88);
ds_map_add(global.__hashmap, "rp-delete-count", 89);
ds_map_add(global.__hashmap, "tip-text", 90);
ds_map_add(global.__hashmap, "tip-color", 91);
ds_map_add(global.__hashmap, "next-tab", 92);
ds_map_add(global.__hashmap, "next-enter", 93);
ds_map_add(global.__hashmap, "surface", 94);
ds_map_add(global.__hashmap, "scroll", 95);
ds_map_add(global.__hashmap, "momentum", 96);
ds_map_add(global.__hashmap, "drag-scroll", 97);
ds_map_add(global.__hashmap, "drag-canvas", 98);
ds_map_add(global.__hashmap, "drag-y", 99);
ds_map_add(global.__hashmap, "content-changed", 100);
ds_map_add(global.__hashmap, "scrollbar-height", 101);
ds_map_add(global.__hashmap, "tween-type", 102);
ds_map_add(global.__hashmap, "render-min-width", 103);
ds_map_add(global.__hashmap, "render-max-width", 104);
ds_map_add(global.__hashmap, "render-min-height", 105);
ds_map_add(global.__hashmap, "render-max-height", 106);
ds_map_add(global.__hashmap, "child-cache", 107);
//#ENDDEBUG

global.__tb_simulate_back = 0;

global.__bezier[0]=0.000133854256581698;global.__bezier[1]=0.000268778134751798;global.__bezier[2]=0.000404803935155348;global.__bezier[3]=0.000541872249415355;global.__bezier[4]=0.000680015159773646;global.__bezier[5]=0.00081923431926979;global.__bezier[6]=0.000959562871351372;global.__bezier[7]=0.00110093969111638;global.__bezier[8]=0.00124339770356983;global.__bezier[9]=0.00138693855134495;global.__bezier[10]=0.00153156387444525;global.__bezier[11]=0.00167727531023487;global.__bezier[12]=0.00182407449342708;global.__bezier[13]=0.00197196305607331;global.__bezier[14]=0.00212097582598129;global.__bezier[15]=0.00227104824608733;global.__bezier[16]=0.00242221492570236;global.__bezier[17]=0.00257447748611902;global.__bezier[18]=0.00272783754591391;global.__bezier[19]=0.00288229672093605;global.__bezier[20]=0.00303785662429483;global.__bezier[21]=0.00319451886634951;global.__bezier[22]=0.00335231995743254;global.__bezier[23]=0.00351119190983959;global.__bezier[24]=0.00367117101538608;global.__bezier[25]=0.00383225887331931;global.__bezier[26]=0.00399449283447881;global.__bezier[27]=0.00415780319653854;global.__bezier[28]=0.00432222709182376;global.__bezier[29]=0.00448780250119552;global.__bezier[30]=0.00465445843672227;
global.__bezier[31]=0.00482226947921899;global.__bezier[32]=0.00499116378385224;global.__bezier[33]=0.00516121677673789;global.__bezier[34]=0.00533239321292477;global.__bezier[35]=0.0055046946630138;global.__bezier[36]=0.00567808481274902;global.__bezier[37]=0.00585264077813858;global.__bezier[38]=0.00602832645170111;global.__bezier[39]=0.0062051433922923;global.__bezier[40]=0.00638313188802262;global.__bezier[41]=0.0065622162398599;global.__bezier[42]=0.00674243651742754;global.__bezier[43]=0.00692379426765472;global.__bezier[44]=0.0071063306164923;global.__bezier[45]=0.00728996815313258;global.__bezier[46]=0.00747478779183676;global.__bezier[47]=0.00766075148528885;global.__bezier[48]=0.007847860765147;global.__bezier[49]=0.00803611716000075;global.__bezier[50]=0.00822552219535964;global.__bezier[51]=0.00841607739364191;global.__bezier[52]=0.00860778427416306;global.__bezier[53]=0.0088006443531245;global.__bezier[54]=0.00899470084800758;global.__bezier[55]=0.00918987207196559;global.__bezier[56]=0.00938624315258894;global.__bezier[57]=0.00958377388897864;global.__bezier[58]=0.00978246578146767;global.__bezier[59]=0.00998232032720408;global.__bezier[60]=0.0101833390201395;
global.__bezier[61]=0.0103855665390374;global.__bezier[62]=0.0105889182071548;global.__bezier[63]=0.0107934820965516;global.__bezier[64]=0.0109991726768331;global.__bezier[65]=0.0112060788605568;global.__bezier[66]=0.0114141585105508;global.__bezier[67]=0.011623413097927;global.__bezier[68]=0.0118338887602397;global.__bezier[69]=0.0120454978340393;global.__bezier[70]=0.0122583313314194;global.__bezier[71]=0.0124723007362472;global.__bezier[72]=0.0126874978998021;global.__bezier[73]=0.0129038791804241;global.__bezier[74]=0.0131214460257917;global.__bezier[75]=0.0133402460295772;global.__bezier[76]=0.0135601885451413;global.__bezier[77]=0.0137813675198563;global.__bezier[78]=0.0140037382383053;global.__bezier[79]=0.0142273021310159;global.__bezier[80]=0.0144520606250812;global.__bezier[81]=0.0146780151441481;global.__bezier[82]=0.0149052147351857;global.__bezier[83]=0.0151335657721884;global.__bezier[84]=0.0153631651327202;global.__bezier[85]=0.0155939665995708;global.__bezier[86]=0.0158259715788035;global.__bezier[87]=0.016059230153563;global.__bezier[88]=0.0162936465722487;global.__bezier[89]=0.0165293198020419;global.__bezier[90]=0.0167662025540762;
global.__bezier[91]=0.0170042962165168;global.__bezier[92]=0.0172436021739492;global.__bezier[93]=0.0174841218073668;global.__bezier[94]=0.0177259066478799;global.__bezier[95]=0.0179689083359737;global.__bezier[96]=0.0182131282416011;global.__bezier[97]=0.0184585677310731;global.__bezier[98]=0.0187052281670478;global.__bezier[99]=0.0189531621128143;global.__bezier[100]=0.0192022687250025;global.__bezier[101]=0.019452651973647;global.__bezier[102]=0.0197042620021718;global.__bezier[103]=0.0199571521982716;global.__bezier[104]=0.0202112200245217;global.__bezier[105]=0.0204665711144179;global.__bezier[106]=0.020723154756847;global.__bezier[107]=0.0209809722806195;global.__bezier[108]=0.0212400250107689;global.__bezier[109]=0.0215003142685398;global.__bezier[110]=0.0217618948815956;global.__bezier[111]=0.022024715071816;global.__bezier[112]=0.0222887761487824;global.__bezier[113]=0.0225540794182369;global.__bezier[114]=0.0228206805289067;global.__bezier[115]=0.0230884722940997;global.__bezier[116]=0.0233575649104827;global.__bezier[117]=0.0236279053212503;global.__bezier[118]=0.0238994948125313;global.__bezier[119]=0.0241723900575811;global.__bezier[120]=0.0244464817612125;
global.__bezier[121]=0.0247218821883428;global.__bezier[122]=0.0249985372180898;global.__bezier[123]=0.0252764481166463;global.__bezier[124]=0.0255556725796936;global.__bezier[125]=0.0258360992067679;global.__bezier[126]=0.0261178423271397;global.__bezier[127]=0.0264008467573045;global.__bezier[128]=0.0266851137431953;global.__bezier[129]=0.0269707020007354;global.__bezier[130]=0.0272574980275618;global.__bezier[131]=0.0275456182132389;global.__bezier[132]=0.0278350063131739;global.__bezier[133]=0.0281256635527137;global.__bezier[134]=0.0284175911531014;global.__bezier[135]=0.0287108490515838;global.__bezier[136]=0.0290053801558253;global.__bezier[137]=0.0293011856744147;global.__bezier[138]=0.0295982668117856;global.__bezier[139]=0.0298966247682046;global.__bezier[140]=0.0301963204960731;global.__bezier[141]=0.0304972358816127;global.__bezier[142]=0.0307994918319526;global.__bezier[143]=0.0311030297739714;global.__bezier[144]=0.0314078508866307;global.__bezier[145]=0.0317140171350023;global.__bezier[146]=0.0320214083153639;global.__bezier[147]=0.0323301473809873;global.__bezier[148]=0.0326401747031408;global.__bezier[149]=0.0329514914391512;global.__bezier[150]=0.0332641605642348;
global.__bezier[151]=0.0335780597887699;global.__bezier[152]=0.033893314107432;global.__bezier[153]=0.0342098628377441;global.__bezier[154]=0.0345277071150666;global.__bezier[155]=0.0348468480703877;global.__bezier[156]=0.0351672868303109;global.__bezier[157]=0.0354890877799203;global.__bezier[158]=0.035812125716659;global.__bezier[159]=0.0361365284848913;global.__bezier[160]=0.0364622339303646;global.__bezier[161]=0.0367892431572548;global.__bezier[162]=0.0371176215543154;global.__bezier[163]=0.0374472418436205;global.__bezier[164]=0.0377782338987411;global.__bezier[165]=0.0381104696130262;global.__bezier[166]=0.0384440796703384;global.__bezier[167]=0.0387790004487638;global.__bezier[168]=0.0391152330206494;global.__bezier[169]=0.0394528441751894;global.__bezier[170]=0.0397917037370032;global.__bezier[171]=0.0401319444115455;global.__bezier[172]=0.040473435197435;global.__bezier[173]=0.0408163096073136;global.__bezier[174]=0.0411605025559797;global.__bezier[175]=0.0415060150833045;global.__bezier[176]=0.0418529153730948;global.__bezier[177]=0.0422010703621957;global.__bezier[178]=0.042550548021543;global.__bezier[179]=0.0429014171309162;global.__bezier[180]=0.0432535433928071;
global.__bezier[181]=0.043607063539033;global.__bezier[182]=0.0439619108177814;global.__bezier[183]=0.0443180862310632;global.__bezier[184]=0.0446755907761416;global.__bezier[185]=0.0450344254455203;global.__bezier[186]=0.04539459122693;global.__bezier[187]=0.04575615848346;global.__bezier[188]=0.0461189896351213;global.__bezier[189]=0.0464831548331187;global.__bezier[190]=0.0468487250322298;global.__bezier[191]=0.047215561425377;global.__bezier[192]=0.047583805145484;global.__bezier[193]=0.0479533871598699;global.__bezier[194]=0.0483242376245019;global.__bezier[195]=0.0486964988673667;global.__bezier[196]=0.0490701012360769;global.__bezier[197]=0.0494450456646309;global.__bezier[198]=0.049821333082098;global.__bezier[199]=0.0501989644126059;global.__bezier[200]=0.0505779405753273;global.__bezier[201]=0.0509582624844676;global.__bezier[202]=0.0513398586496879;global.__bezier[203]=0.0517228745740793;global.__bezier[204]=0.0521072389577038;global.__bezier[205]=0.0524930256947319;global.__bezier[206]=0.0528800898742745;global.__bezier[207]=0.0532684317808651;global.__bezier[208]=0.0536581988930982;global.__bezier[209]=0.0540493188851442;global.__bezier[210]=0.0544417926259186;
global.__bezier[211]=0.0548356209792399;global.__bezier[212]=0.0552308048038165;global.__bezier[213]=0.0556273449532338;global.__bezier[214]=0.0560252422759408;global.__bezier[215]=0.0564244976152377;global.__bezier[216]=0.0568250366183685;global.__bezier[217]=0.0572270103017424;global.__bezier[218]=0.0576302689133273;global.__bezier[219]=0.0580349642524337;global.__bezier[220]=0.0584409457638975;global.__bezier[221]=0.0588482898476797;global.__bezier[222]=0.0592570736897488;global.__bezier[223]=0.0596671455323366;global.__bezier[224]=0.0600785823533102;global.__bezier[225]=0.0604913849442032;global.__bezier[226]=0.0609054769237383;global.__bezier[227]=0.0613210132110442;global.__bezier[228]=0.0617379176112229;global.__bezier[229]=0.0621561131369798;global.__bezier[230]=0.0625756779180854;global.__bezier[231]=0.0629966127145858;global.__bezier[232]=0.0634189182811604;global.__bezier[233]=0.0638425953671085;global.__bezier[234]=0.0642675659784721;global.__bezier[235]=0.0646939881338735;global.__bezier[236]=0.0651217048954043;global.__bezier[237]=0.065550795729039;global.__bezier[238]=0.0659812613574449;global.__bezier[239]=0.0664130227836715;global.__bezier[240]=0.0668462399529888;
global.__bezier[241]=0.0672807539488902;global.__bezier[242]=0.0677166451867706;global.__bezier[243]=0.0681538338701166;global.__bezier[244]=0.0685924814794908;global.__bezier[245]=0.069032427521317;global.__bezier[246]=0.0694737531674416;global.__bezier[247]=0.0699163778242828;global.__bezier[248]=0.070360464502133;global.__bezier[249]=0.0708058511355399;global.__bezier[250]=0.0712525378025462;global.__bezier[251]=0.071700688657148;global.__bezier[252]=0.0721501404585999;global.__bezier[253]=0.0726009756956849;global.__bezier[254]=0.073053112386245;global.__bezier[255]=0.073506633393897;global.__bezier[256]=0.0739615393435746;global.__bezier[257]=0.0744177476605722;global.__bezier[258]=0.0748753417690595;global.__bezier[259]=0.0753343222773852;global.__bezier[260]=0.0757946060198053;global.__bezier[261]=0.07625627697933;global.__bezier[262]=0.0767193357476154;global.__bezier[263]=0.0771836985694057;global.__bezier[264]=0.0776493654531416;global.__bezier[265]=0.0781164211246156;global.__bezier[266]=0.0785848661534066;global.__bezier[267]=0.0790546160010968;global.__bezier[268]=0.0795257559481927;global.__bezier[269]=0.079998201065757;global.__bezier[270]=0.0804720370032994;
global.__bezier[271]=0.0809471784420888;global.__bezier[272]=0.0814237113998272;global.__bezier[273]=0.0819015501687198;global.__bezier[274]=0.0823807811338452;global.__bezier[275]=0.0828613181990802;global.__bezier[276]=0.0833432481160592;global.__bezier[277]=0.0838264844010703;global.__bezier[278]=0.0843111141714784;global.__bezier[279]=0.0847970505567273;global.__bezier[280]=0.0852842934847948;global.__bezier[281]=0.0857729306203658;global.__bezier[282]=0.0862628745143567;global.__bezier[283]=0.0867541250797134;global.__bezier[284]=0.0872467705265124;global.__bezier[285]=0.0877407228289004;global.__bezier[286]=0.0882360705592736;global.__bezier[287]=0.0887327253080301;global.__bezier[288]=0.0892306869626639;global.__bezier[289]=0.0897300446377459;global.__bezier[290]=0.0902306199325314;global.__bezier[291]=0.0907325913687185;global.__bezier[292]=0.0912359593691202;global.__bezier[293]=0.091740544406169;global.__bezier[294]=0.0922465260964945;global.__bezier[295]=0.0927538145047339;global.__bezier[296]=0.0932624094779886;global.__bezier[297]=0.0937724015672658;global.__bezier[298]=0.0942837002682599;global.__bezier[299]=0.0947963054126131;global.__bezier[300]=0.0953102168270224;
global.__bezier[301]=0.0958254343332325;global.__bezier[302]=0.0963419577480273;global.__bezier[303]=0.0968597868832228;global.__bezier[304]=0.0973790135352971;global.__bezier[305]=0.0978995458806142;global.__bezier[306]=0.098421291361763;global.__bezier[307]=0.0989444342954629;global.__bezier[308]=0.0994688822961523;global.__bezier[309]=0.0999946351449803;global.__bezier[310]=0.100521692618071;global.__bezier[311]=0.101050054486516;global.__bezier[312]=0.101579720516367;global.__bezier[313]=0.102110690468627;global.__bezier[314]=0.102642964099242;global.__bezier[315]=0.103176541159097;global.__bezier[316]=0.103711421394002;global.__bezier[317]=0.104247604544691;global.__bezier[318]=0.104784995829033;global.__bezier[319]=0.105323783834299;global.__bezier[320]=0.105863873947227;global.__bezier[321]=0.106405170834638;global.__bezier[322]=0.106947768909064;global.__bezier[323]=0.107491667881313;global.__bezier[324]=0.108036867457059;global.__bezier[325]=0.108583367336835;global.__bezier[326]=0.109131167216028;global.__bezier[327]=0.109680170666464;global.__bezier[328]=0.110230473138351;global.__bezier[329]=0.110782074312309;global.__bezier[330]=0.11133497386378;
global.__bezier[331]=0.111889074639632;global.__bezier[332]=0.112444472777055;global.__bezier[333]=0.113001167936639;global.__bezier[334]=0.113559159773771;global.__bezier[335]=0.114118350414261;global.__bezier[336]=0.114678836678169;global.__bezier[337]=0.115240520332644;global.__bezier[338]=0.115803498538003;global.__bezier[339]=0.116367770924958;global.__bezier[340]=0.11693323872417;global.__bezier[341]=0.117499999603981;global.__bezier[342]=0.118067954438914;global.__bezier[343]=0.118637201234923;global.__bezier[344]=0.119207640511422;global.__bezier[345]=0.11977937061091;global.__bezier[346]=0.120352391129433;global.__bezier[347]=0.120926602055262;global.__bezier[348]=0.121502002459385;global.__bezier[349]=0.122078691354178;global.__bezier[350]=0.122656568199896;global.__bezier[351]=0.123235732342214;global.__bezier[352]=0.123816082890423;global.__bezier[353]=0.124397618895184;global.__bezier[354]=0.124980440200469;global.__bezier[355]=0.125564445391515;global.__bezier[356]=0.126149633506905;global.__bezier[357]=0.126736104886404;global.__bezier[358]=0.127323757593613;global.__bezier[359]=0.127912590654992;global.__bezier[360]=0.128502603093235;
global.__bezier[361]=0.129093895905521;global.__bezier[362]=0.129686366463998;global.__bezier[363]=0.13028001377919;global.__bezier[364]=0.130874836857839;global.__bezier[365]=0.131470834702905;global.__bezier[366]=0.132068109127156;global.__bezier[367]=0.13266655664481;global.__bezier[368]=0.133266073100824;global.__bezier[369]=0.133866863608004;global.__bezier[370]=0.134468824169648;global.__bezier[371]=0.135071953765072;global.__bezier[372]=0.135676251369783;global.__bezier[373]=0.136281715955473;global.__bezier[374]=0.13688834649002;global.__bezier[375]=0.137496141937478;global.__bezier[376]=0.138105101258081;global.__bezier[377]=0.138715223408232;global.__bezier[378]=0.139326507340504;global.__bezier[379]=0.139938847051642;global.__bezier[380]=0.140552451228075;global.__bezier[381]=0.141167108745029;global.__bezier[382]=0.141782923492589;global.__bezier[383]=0.142399894404999;global.__bezier[384]=0.143018020412652;global.__bezier[385]=0.143637300442086;global.__bezier[386]=0.14425762733313;global.__bezier[387]=0.144879212009928;global.__bezier[388]=0.145501734658722;global.__bezier[389]=0.146125512921077;global.__bezier[390]=0.146750332739451;
global.__bezier[391]=0.147376299422204;global.__bezier[392]=0.14800341187057;global.__bezier[393]=0.148631561782962;global.__bezier[394]=0.14926085493532;global.__bezier[395]=0.149891182703056;global.__bezier[396]=0.150522651172586;global.__bezier[397]=0.151155151397557;global.__bezier[398]=0.151788789773613;global.__bezier[399]=0.152423565177438;global.__bezier[400]=0.153059368181865;global.__bezier[401]=0.153696197187608;global.__bezier[402]=0.154334159205027;global.__bezier[403]=0.154973144329867;global.__bezier[404]=0.155613259877948;global.__bezier[405]=0.156254395628209;global.__bezier[406]=0.156896549969227;global.__bezier[407]=0.157539830673107;global.__bezier[408]=0.158184127046405;global.__bezier[409]=0.158829547163506;global.__bezier[410]=0.159475870171199;global.__bezier[411]=0.16012331398523;global.__bezier[412]=0.160771767287055;global.__bezier[413]=0.161421338752707;global.__bezier[414]=0.162071806296913;global.__bezier[415]=0.162723389046574;global.__bezier[416]=0.163375975063167;global.__bezier[417]=0.164029562709831;global.__bezier[418]=0.164684150347656;global.__bezier[419]=0.165339736335679;global.__bezier[420]=0.165996430391036;
global.__bezier[421]=0.166654008297957;global.__bezier[422]=0.167312579619536;global.__bezier[423]=0.167972254514589;global.__bezier[424]=0.168632807864502;global.__bezier[425]=0.169294349675036;global.__bezier[426]=0.169956878290837;global.__bezier[427]=0.170620504454979;global.__bezier[428]=0.171285001854312;global.__bezier[429]=0.171950481080168;global.__bezier[430]=0.172616827627597;global.__bezier[431]=0.173284265367361;global.__bezier[432]=0.173952566803419;global.__bezier[433]=0.17462184310834;global.__bezier[434]=0.175292092611269;global.__bezier[435]=0.175963313639287;global.__bezier[436]=0.176635504517409;global.__bezier[437]=0.177308549710302;global.__bezier[438]=0.177982447107081;global.__bezier[439]=0.178657422888318;global.__bezier[440]=0.179333247224502;global.__bezier[441]=0.180010032434474;global.__bezier[442]=0.180687662258398;global.__bezier[443]=0.181366249298793;global.__bezier[444]=0.182045677008622;global.__bezier[445]=0.182726058272698;global.__bezier[446]=0.183407391399331;global.__bezier[447]=0.184089559412738;global.__bezier[448]=0.184772560195605;global.__bezier[449]=0.185456507193213;global.__bezier[450]=0.186141283005182;
global.__bezier[451]=0.186827001354936;global.__bezier[452]=0.187513544560422;global.__bezier[453]=0.188200910502177;global.__bezier[454]=0.188889213318758;global.__bezier[455]=0.189578334908732;global.__bezier[456]=0.190268273151565;global.__bezier[457]=0.190959025926722;global.__bezier[458]=0.191650707921697;global.__bezier[459]=0.192343200481154;global.__bezier[460]=0.193036501483487;global.__bezier[461]=0.193730726023936;global.__bezier[462]=0.194425637682742;global.__bezier[463]=0.195121468906857;global.__bezier[464]=0.195817982734272;global.__bezier[465]=0.196515412152754;global.__bezier[466]=0.197213637552003;global.__bezier[467]=0.197912656809337;global.__bezier[468]=0.198612467802071;global.__bezier[469]=0.199313068407524;global.__bezier[470]=0.200014456503013;global.__bezier[471]=0.200716629965854;global.__bezier[472]=0.201419467984949;global.__bezier[473]=0.202123205682813;global.__bezier[474]=0.20282772238034;global.__bezier[475]=0.203532896872625;global.__bezier[476]=0.204238845858111;global.__bezier[477]=0.204945567215189;global.__bezier[478]=0.20565305882225;global.__bezier[479]=0.206361318557687;global.__bezier[480]=0.207070224568586;
global.__bezier[481]=0.207779894207172;global.__bezier[482]=0.20849032535291;global.__bezier[483]=0.209201515885265;global.__bezier[484]=0.209913343439669;global.__bezier[485]=0.210625925885056;global.__bezier[486]=0.211339140603768;global.__bezier[487]=0.21205310572145;global.__bezier[488]=0.212767819119717;global.__bezier[489]=0.21348315780347;global.__bezier[490]=0.21419924028013;global.__bezier[491]=0.21491594330517;global.__bezier[492]=0.215633385639058;global.__bezier[493]=0.216351443789309;global.__bezier[494]=0.217070115267776;global.__bezier[495]=0.217789519212277;global.__bezier[496]=0.218509653508715;global.__bezier[497]=0.219230272303273;global.__bezier[498]=0.219951738723906;global.__bezier[499]=0.220673684681679;global.__bezier[500]=0.221396351805427;global.__bezier[501]=0.222119615626709;global.__bezier[502]=0.222843473671614;global.__bezier[503]=0.223568046067588;global.__bezier[504]=0.224293207986457;global.__bezier[505]=0.225018956959782;global.__bezier[506]=0.225745290521322;global.__bezier[507]=0.226472206207037;global.__bezier[508]=0.22719982475177;global.__bezier[509]=0.227927897420876;global.__bezier[510]=0.228656668267917;
global.__bezier[511]=0.229386011639826;global.__bezier[512]=0.230115801414433;global.__bezier[513]=0.230846282358819;global.__bezier[514]=0.231577328472468;global.__bezier[515]=0.23230893730777;global.__bezier[516]=0.23304110641931;global.__bezier[517]=0.233773709115197;global.__bezier[518]=0.234506991336705;global.__bezier[519]=0.235240826511714;global.__bezier[520]=0.235975087610992;global.__bezier[521]=0.236709896564867;global.__bezier[522]=0.237445375762117;global.__bezier[523]=0.238181273246997;global.__bezier[524]=0.238917586253329;global.__bezier[525]=0.239654562335762;global.__bezier[526]=0.240391948868599;global.__bezier[527]=0.241129868478527;global.__bezier[528]=0.241868318748588;global.__bezier[529]=0.2426071716601;global.__bezier[530]=0.243346550183386;global.__bezier[531]=0.244086451909135;global.__bezier[532]=0.244826874430212;global.__bezier[533]=0.24556768929808;global.__bezier[534]=0.246308893783024;global.__bezier[535]=0.247050611420882;global.__bezier[536]=0.247792839815435;global.__bezier[537]=0.248535450095468;global.__bezier[538]=0.249278566131328;global.__bezier[539]=0.250022058842722;global.__bezier[540]=0.250766052321479;
global.__bezier[541]=0.251510417279736;global.__bezier[542]=0.252255278029281;global.__bezier[543]=0.253000505076187;global.__bezier[544]=0.253746095729321;global.__bezier[545]=0.254492174628116;global.__bezier[546]=0.255238611972951;global.__bezier[547]=0.255985405084799;global.__bezier[548]=0.256732678927291;global.__bezier[549]=0.257480303398515;global.__bezier[550]=0.258228275831526;global.__bezier[551]=0.258976721510713;global.__bezier[552]=0.259725381986197;global.__bezier[553]=0.260474510599473;global.__bezier[554]=0.261223976753114;global.__bezier[555]=0.261973906154204;global.__bezier[556]=0.262724039555266;global.__bezier[557]=0.263474631125203;global.__bezier[558]=0.264225421222847;global.__bezier[559]=0.264976664426794;global.__bezier[560]=0.265728229557676;global.__bezier[561]=0.266480113994531;global.__bezier[562]=0.26723231512077;global.__bezier[563]=0.267984830324164;global.__bezier[564]=0.26873765699685;global.__bezier[565]=0.269490792535324;global.__bezier[566]=0.270244234340434;global.__bezier[567]=0.270997979817383;global.__bezier[568]=0.271752026375719;global.__bezier[569]=0.272506241702139;global.__bezier[570]=0.273260882573973;
global.__bezier[571]=0.274015686864867;global.__bezier[572]=0.274770911741993;global.__bezier[573]=0.275526294707997;global.__bezier[574]=0.276281963116977;global.__bezier[575]=0.277037914409946;global.__bezier[576]=0.277794015645942;global.__bezier[577]=0.278550524954548;global.__bezier[578]=0.279307178925248;global.__bezier[579]=0.280063974740653;global.__bezier[580]=0.280821171099085;global.__bezier[581]=0.281578504051641;global.__bezier[582]=0.282336101734799;global.__bezier[583]=0.283093961626253;global.__bezier[584]=0.283851950091168;global.__bezier[585]=0.284610195553381;global.__bezier[586]=0.285368564208891;global.__bezier[587]=0.286127184671564;global.__bezier[588]=0.286885922969734;global.__bezier[589]=0.287645039466841;global.__bezier[590]=0.288404136990587;global.__bezier[591]=0.289163476003284;global.__bezier[592]=0.289923054025512;global.__bezier[593]=0.290682736672369;global.__bezier[594]=0.291442653210197;global.__bezier[595]=0.292202669091623;global.__bezier[596]=0.292962781598886;global.__bezier[597]=0.293723120273036;global.__bezier[598]=0.294483682663397;global.__bezier[599]=0.295244333902104;global.__bezier[600]=0.296005071294993;
global.__bezier[601]=0.296765892154355;global.__bezier[602]=0.297526926471087;global.__bezier[603]=0.298288039063866;global.__bezier[604]=0.299049360100637;global.__bezier[605]=0.299810621325426;global.__bezier[606]=0.300572085837837;global.__bezier[607]=0.301333751231617;global.__bezier[608]=0.302095348777456;global.__bezier[609]=0.302857142082236;global.__bezier[610]=0.303618995429972;global.__bezier[611]=0.304380906193693;global.__bezier[612]=0.305142871752803;global.__bezier[613]=0.30590502305595;global.__bezier[614]=0.306667224089857;global.__bezier[615]=0.307429472251883;global.__bezier[616]=0.30819176494573;global.__bezier[617]=0.308954099581437;global.__bezier[618]=0.309716473575372;global.__bezier[619]=0.310478884350225;global.__bezier[620]=0.311241463441279;global.__bezier[621]=0.312003940147419;global.__bezier[622]=0.312766445940019;global.__bezier[623]=0.313529112600592;global.__bezier[624]=0.314291668991113;global.__bezier[625]=0.315054381313583;global.__bezier[626]=0.315816978142346;global.__bezier[627]=0.316579725990629;global.__bezier[628]=0.317342353148058;global.__bezier[629]=0.318105126436118;global.__bezier[630]=0.318867773862615;
global.__bezier[631]=0.319630427630645;global.__bezier[632]=0.32039308524436;global.__bezier[633]=0.321155744214119;global.__bezier[634]=0.32191840205649;global.__bezier[635]=0.322681056294233;global.__bezier[636]=0.323443569175718;global.__bezier[637]=0.32420620872694;global.__bezier[638]=0.324968701858483;global.__bezier[639]=0.325731181399476;global.__bezier[640]=0.326493644904623;global.__bezier[641]=0.327256089934776;global.__bezier[642]=0.328018378360061;global.__bezier[643]=0.328780643314231;global.__bezier[644]=0.329542882377606;global.__bezier[645]=0.33030509313662;global.__bezier[646]=0.331067137216665;global.__bezier[647]=0.331829284083997;global.__bezier[648]=0.332591123242952;global.__bezier[649]=0.333353060406872;global.__bezier[650]=0.334114820928199;global.__bezier[651]=0.334876538532151;global.__bezier[652]=0.335638210849864;global.__bezier[653]=0.336399699092188;global.__bezier[654]=0.337161137200337;global.__bezier[655]=0.337922386270312;global.__bezier[656]=0.338683580385844;global.__bezier[657]=0.339444717210339;global.__bezier[658]=0.340205657669596;global.__bezier[659]=0.340966536057842;global.__bezier[660]=0.341727213189485;
global.__bezier[661]=0.342487823497614;global.__bezier[662]=0.343248364677676;global.__bezier[663]=0.344008697379041;global.__bezier[664]=0.34476881912718;global.__bezier[665]=0.345528864628547;global.__bezier[666]=0.346288831604472;global.__bezier[667]=0.347048580489774;global.__bezier[668]=0.347808108839947;global.__bezier[669]=0.348567551629013;global.__bezier[670]=0.349326906604031;global.__bezier[671]=0.350086033990718;global.__bezier[672]=0.35084493137441;global.__bezier[673]=0.351603733990936;global.__bezier[674]=0.352362301913261;global.__bezier[675]=0.353120770505964;global.__bezier[676]=0.353878999741511;global.__bezier[677]=0.354636987242812;global.__bezier[678]=0.355394868565413;global.__bezier[679]=0.356152503534068;global.__bezier[680]=0.356910027829508;global.__bezier[681]=0.357667301179339;global.__bezier[682]=0.358424321243752;global.__bezier[683]=0.359181223889115;global.__bezier[684]=0.359937730448291;global.__bezier[685]=0.360694253359992;global.__bezier[686]=0.361450375558565;global.__bezier[687]=0.362206371405302;global.__bezier[688]=0.362962100299787;global.__bezier[689]=0.363717698470111;global.__bezier[690]=0.364473025224674;
global.__bezier[691]=0.365228078290659;global.__bezier[692]=0.365982855402975;global.__bezier[693]=0.366737354304242;global.__bezier[694]=0.367491711515018;global.__bezier[695]=0.368245786122985;global.__bezier[696]=0.368999575892806;global.__bezier[697]=0.369753217515934;global.__bezier[698]=0.370506569951124;global.__bezier[699]=0.371259491968249;global.__bezier[700]=0.372012398411699;global.__bezier[701]=0.372764870033136;global.__bezier[702]=0.373517043658708;global.__bezier[703]=0.374269056313327;global.__bezier[704]=0.375020766707602;global.__bezier[705]=0.375772172672677;global.__bezier[706]=0.376523272047242;global.__bezier[707]=0.37727406267752;global.__bezier[708]=0.378024681856692;global.__bezier[709]=0.378774848612453;global.__bezier[710]=0.379524839737085;global.__bezier[711]=0.380274513666396;global.__bezier[712]=0.381023868283098;global.__bezier[713]=0.38177290147736;global.__bezier[714]=0.382521611146796;global.__bezier[715]=0.38326999519645;global.__bezier[716]=0.384018051538783;global.__bezier[717]=0.384765917929239;global.__bezier[718]=0.385513312666313;global.__bezier[719]=0.386260513397546;global.__bezier[720]=0.387007378228397;
global.__bezier[721]=0.38775376510403;global.__bezier[722]=0.388499951945518;global.__bezier[723]=0.389245796754128;global.__bezier[724]=0.389991297500234;global.__bezier[725]=0.390736452161516;global.__bezier[726]=0.391481258722939;global.__bezier[727]=0.39222571517675;global.__bezier[728]=0.392969819522455;global.__bezier[729]=0.393713429443638;global.__bezier[730]=0.39445682356208;global.__bezier[731]=0.395199859614707;global.__bezier[732]=0.395942676067886;global.__bezier[733]=0.396684990119003;global.__bezier[734]=0.397426799698;global.__bezier[735]=0.39816838384361;global.__bezier[736]=0.398909600137422;global.__bezier[737]=0.399650446643732;global.__bezier[738]=0.400390921433971;global.__bezier[739]=0.401131022586689;global.__bezier[740]=0.401870748187546;global.__bezier[741]=0.402610096329296;global.__bezier[742]=0.403349065111777;global.__bezier[743]=0.404087511807211;global.__bezier[744]=0.404825716164716;global.__bezier[745]=0.40556339460233;global.__bezier[746]=0.406300827020099;global.__bezier[747]=0.407037729714479;global.__bezier[748]=0.407774382733944;global.__bezier[749]=0.408510502255754;global.__bezier[750]=0.409246227406558;
global.__bezier[751]=0.409981697450118;global.__bezier[752]=0.410716628389363;global.__bezier[753]=0.411451159469863;global.__bezier[754]=0.412185147682049;global.__bezier[755]=0.412918873575269;global.__bezier[756]=0.413652194184946;global.__bezier[757]=0.414384966430472;global.__bezier[758]=0.415117471066233;global.__bezier[759]=0.415849423709937;global.__bezier[760]=0.416581105249615;global.__bezier[761]=0.417312231197913;global.__bezier[762]=0.418042941141097;global.__bezier[763]=0.418773233326537;global.__bezier[764]=0.419502964518711;global.__bezier[765]=0.420232415930035;global.__bezier[766]=0.420961444366751;global.__bezier[767]=0.421689906530783;global.__bezier[768]=0.422417942221841;global.__bezier[769]=0.423145549728757;global.__bezier[770]=0.423872727347083;global.__bezier[771]=0.424599473379076;global.__bezier[772]=0.425325786133687;global.__bezier[773]=0.426051522196131;global.__bezier[774]=0.426776963324242;global.__bezier[775]=0.427501824361417;global.__bezier[776]=0.42822624537453;global.__bezier[777]=0.428950224706667;global.__bezier[778]=0.42967376070753;global.__bezier[779]=0.430396709855508;global.__bezier[780]=0.431119354245741;
global.__bezier[781]=0.431841408468855;global.__bezier[782]=0.43256301277965;global.__bezier[783]=0.433284165561563;global.__bezier[784]=0.434004865204572;global.__bezier[785]=0.434724968089992;global.__bezier[786]=0.435444756629311;global.__bezier[787]=0.436163945180344;global.__bezier[788]=0.436882674175114;global.__bezier[789]=0.437600942036935;global.__bezier[790]=0.438318605073723;global.__bezier[791]=0.439035945944919;global.__bezier[792]=0.439752678829514;global.__bezier[793]=0.440468944299282;global.__bezier[794]=0.441184740810542;global.__bezier[795]=0.441900066826012;global.__bezier[796]=0.442614920814796;global.__bezier[797]=0.443329158992776;global.__bezier[798]=0.44404292206422;global.__bezier[799]=0.444756208518122;global.__bezier[800]=0.445469016849816;global.__bezier[801]=0.446181345560953;global.__bezier[802]=0.446893050809716;global.__bezier[803]=0.447604415792688;global.__bezier[804]=0.448315154314167;global.__bezier[805]=0.449025264850895;global.__bezier[806]=0.449735030721624;global.__bezier[807]=0.450444308082513;global.__bezier[808]=0.451152953030791;global.__bezier[809]=0.451861106536901;global.__bezier[810]=0.452568767160416;
global.__bezier[811]=0.453275933467105;global.__bezier[812]=0.453982461518889;global.__bezier[813]=0.454688492374778;global.__bezier[814]=0.455394167158733;global.__bezier[815]=0.456099056845262;global.__bezier[816]=0.456803587648398;global.__bezier[817]=0.457507615632698;global.__bezier[818]=0.45821099681421;global.__bezier[819]=0.458913872376095;global.__bezier[820]=0.459616240940866;global.__bezier[821]=0.460318101137103;global.__bezier[822]=0.461019308955469;global.__bezier[823]=0.461720148312619;global.__bezier[824]=0.462420332555857;global.__bezier[825]=0.463120002982655;global.__bezier[826]=0.463819015562184;global.__bezier[827]=0.464517654329651;global.__bezier[828]=0.465215632565425;global.__bezier[829]=0.465913091638044;global.__bezier[830]=0.466610030231666;global.__bezier[831]=0.467306447036395;global.__bezier[832]=0.468002340748265;global.__bezier[833]=0.468697567307534;global.__bezier[834]=0.469392268165377;global.__bezier[835]=0.470086442036294;global.__bezier[836]=0.47078008764067;global.__bezier[837]=0.471473203704758;global.__bezier[838]=0.472165646155504;global.__bezier[839]=0.472857556520124;global.__bezier[840]=0.473548933543143;
global.__bezier[841]=0.474239775974908;global.__bezier[842]=0.47493008257157;global.__bezier[843]=0.475619709252616;global.__bezier[844]=0.476308940463975;global.__bezier[845]=0.476997489287984;global.__bezier[846]=0.477685497347096;global.__bezier[847]=0.478372963427049;global.__bezier[848]=0.479059743445635;global.__bezier[849]=0.479746121941884;global.__bezier[850]=0.480431811966304;global.__bezier[851]=0.481116955201894;global.__bezier[852]=0.481801550463657;global.__bezier[853]=0.482485596572272;global.__bezier[854]=0.483168949450872;global.__bezier[855]=0.483851893733767;global.__bezier[856]=0.484534142448555;global.__bezier[857]=0.485215837342401;global.__bezier[858]=0.485896977264877;global.__bezier[859]=0.486577418149858;global.__bezier[860]=0.48725744469778;global.__bezier[861]=0.487936769929944;global.__bezier[862]=0.488615678569583;global.__bezier[863]=0.489293883638388;global.__bezier[864]=0.489971526946942;global.__bezier[865]=0.490648607384466;global.__bezier[866]=0.491324980908874;global.__bezier[867]=0.492000932292758;global.__bezier[868]=0.492676174567374;global.__bezier[869]=0.493350849581444;global.__bezier[870]=0.494024956252341;
global.__bezier[871]=0.494698493502892;global.__bezier[872]=0.495371460261368;global.__bezier[873]=0.496043855461476;global.__bezier[874]=0.496715535101535;global.__bezier[875]=0.497386784008219;global.__bezier[876]=0.498057315250816;global.__bezier[877]=0.498727270726128;global.__bezier[878]=0.499396649395524;global.__bezier[879]=0.500065450225736;global.__bezier[880]=0.500733672188844;global.__bezier[881]=0.50140117132978;global.__bezier[882]=0.502068232498347;global.__bezier[883]=0.502734568820146;global.__bezier[884]=0.503400465147297;global.__bezier[885]=0.504065634625181;global.__bezier[886]=0.504730219186514;global.__bezier[887]=0.505394217841164;global.__bezier[888]=0.506057629604257;global.__bezier[889]=0.506720453496163;global.__bezier[890]=0.50738254563655;global.__bezier[891]=0.508044190872155;global.__bezier[892]=0.508705102431607;global.__bezier[893]=0.509365565155916;global.__bezier[894]=0.510025292301094;global.__bezier[895]=0.51068442581704;global.__bezier[896]=0.511343107639682;global.__bezier[897]=0.512001051069229;global.__bezier[898]=0.512658398057007;global.__bezier[899]=0.51331514767585;global.__bezier[900]=0.513971156147714;
global.__bezier[901]=0.514626708273811;global.__bezier[902]=0.515281660280354;global.__bezier[903]=0.515936011260584;global.__bezier[904]=0.516589617482699;global.__bezier[905]=0.517242763717304;global.__bezier[906]=0.517895163419996;global.__bezier[907]=0.518547101343514;global.__bezier[908]=0.519198290982304;global.__bezier[909]=0.519849017069542;global.__bezier[910]=0.520498993140128;global.__bezier[911]=0.521148361129116;global.__bezier[912]=0.521797262944067;global.__bezier[913]=0.522445412183545;global.__bezier[914]=0.523092950773467;global.__bezier[915]=0.523739877867828;global.__bezier[916]=0.524386192625559;global.__bezier[917]=0.525031894210521;global.__bezier[918]=0.525677124505145;global.__bezier[919]=0.526321597245963;global.__bezier[920]=0.52696545433484;global.__bezier[921]=0.527608694955232;global.__bezier[922]=0.528251318295465;global.__bezier[923]=0.528893323548729;global.__bezier[924]=0.52953470991306;global.__bezier[925]=0.530175476591333;global.__bezier[926]=0.530815622791252;global.__bezier[927]=0.531455290343371;global.__bezier[928]=0.532094193217339;global.__bezier[929]=0.532732473264722;global.__bezier[930]=0.533370129712422;
global.__bezier[931]=0.534007161792114;global.__bezier[932]=0.534643568740236;global.__bezier[933]=0.535279492343479;global.__bezier[934]=0.535914646744002;global.__bezier[935]=0.536549173750533;global.__bezier[936]=0.537183215125094;global.__bezier[937]=0.537816485100967;global.__bezier[938]=0.538449267942506;global.__bezier[939]=0.539081277946062;global.__bezier[940]=0.539712799331261;global.__bezier[941]=0.540343688896553;global.__bezier[942]=0.540973803501015;global.__bezier[943]=0.541603427294275;global.__bezier[944]=0.542232417130412;global.__bezier[945]=0.542860772306216;global.__bezier[946]=0.543488492123092;global.__bezier[947]=0.544115575887041;global.__bezier[948]=0.544742022908657;global.__bezier[949]=0.545367974821804;global.__bezier[950]=0.545993146293087;global.__bezier[951]=0.546617678981065;global.__bezier[952]=0.547241714485466;global.__bezier[953]=0.54786510983619;global.__bezier[954]=0.5484878643706;global.__bezier[955]=0.549109835209143;global.__bezier[956]=0.54973130615792;global.__bezier[957]=0.550352276517284;global.__bezier[958]=0.550972461250261;global.__bezier[959]=0.551592001921284;global.__bezier[960]=0.55221104003009;
global.__bezier[961]=0.552829432774535;global.__bezier[962]=0.553447037427503;global.__bezier[963]=0.554064137583753;global.__bezier[964]=0.554680590507114;global.__bezier[965]=0.555296537628512;global.__bezier[966]=0.555911694229691;global.__bezier[967]=0.556526343776395;global.__bezier[968]=0.557140201633605;global.__bezier[969]=0.557753551200657;global.__bezier[970]=0.558366249877288;global.__bezier[971]=0.558978439005857;global.__bezier[972]=0.55958983412135;global.__bezier[973]=0.560200718485481;global.__bezier[974]=0.560810807720512;global.__bezier[975]=0.561420385017477;global.__bezier[976]=0.562029449748627;global.__bezier[977]=0.562637717669117;global.__bezier[978]=0.563245471860814;global.__bezier[979]=0.563852428169462;global.__bezier[980]=0.564458869602741;global.__bezier[981]=0.565064795551208;global.__bezier[982]=0.565669921998441;global.__bezier[983]=0.566274531837738;global.__bezier[984]=0.566878482808437;global.__bezier[985]=0.56748177438054;global.__bezier[986]=0.568084406028248;global.__bezier[987]=0.568686518825811;global.__bezier[988]=0.569287829041742;global.__bezier[989]=0.569888619331823;global.__bezier[990]=0.570488889118935;
global.__bezier[991]=0.571088354818144;global.__bezier[992]=0.571687298961646;global.__bezier[993]=0.572285579523456;global.__bezier[994]=0.57288333744605;global.__bezier[995]=0.573480289344499;global.__bezier[996]=0.574076717581695;global.__bezier[997]=0.574672480239915;global.__bezier[998]=0.57526771818264;global.__bezier[999]=0.575862289546951;global.__bezier[1000]=0.576456193862875;global.__bezier[1001]=0.577049430664493;global.__bezier[1002]=0.577642140733589;global.__bezier[1003]=0.578234182319144;global.__bezier[1004]=0.578825554966869;global.__bezier[1005]=0.579416399395401;global.__bezier[1006]=0.580006573939098;global.__bezier[1007]=0.580596078155219;global.__bezier[1008]=0.581184911605003;global.__bezier[1009]=0.58177321492074;global.__bezier[1010]=0.582360846552847;global.__bezier[1011]=0.582947947089221;global.__bezier[1012]=0.583534375038957;global.__bezier[1013]=0.584120129982164;global.__bezier[1014]=0.58470535243916;global.__bezier[1015]=0.585289901008387;global.__bezier[1016]=0.585873775281251;global.__bezier[1017]=0.586457115709049;global.__bezier[1018]=0.587039780980859;global.__bezier[1019]=0.587621770699313;global.__bezier[1020]=0.588203225245239;
global.__bezier[1021]=0.588784003399642;global.__bezier[1022]=0.589364245495431;global.__bezier[1023]=0.589943810375454;global.__bezier[1024]=0.59052269766072;global.__bezier[1025]=0.591101047611301;global.__bezier[1026]=0.59167871916409;global.__bezier[1027]=0.592255852529672;global.__bezier[1028]=0.592832306708191;global.__bezier[1029]=0.593408081338816;global.__bezier[1030]=0.593983316556954;global.__bezier[1031]=0.594557871458886;global.__bezier[1032]=0.595131886128981;global.__bezier[1033]=0.595705219728157;global.__bezier[1034]=0.596277871913526;global.__bezier[1035]=0.596849982691979;global.__bezier[1036]=0.597421551638943;global.__bezier[1037]=0.597992438046248;global.__bezier[1038]=0.598562641585038;global.__bezier[1039]=0.599132302156477;global.__bezier[1040]=0.599701279152213;global.__bezier[1041]=0.600269712419645;global.__bezier[1042]=0.600837461417502;global.__bezier[1043]=0.601404665938817;global.__bezier[1044]=0.601971185509932;global.__bezier[1045]=0.602537019826436;global.__bezier[1046]=0.603102448610285;global.__bezier[1047]=0.603667051436447;global.__bezier[1048]=0.604231108002162;global.__bezier[1049]=0.604794617922471;global.__bezier[1050]=0.605357440929724;
global.__bezier[1051]=0.605919716593606;global.__bezier[1052]=0.606481304716186;global.__bezier[1053]=0.607042344809853;global.__bezier[1054]=0.607602696746913;global.__bezier[1055]=0.608162499981878;global.__bezier[1056]=0.608721614457808;global.__bezier[1057]=0.609280179570768;global.__bezier[1058]=0.609838055335081;global.__bezier[1059]=0.610395381087792;global.__bezier[1060]=0.610952016915;global.__bezier[1061]=0.611508102094164;global.__bezier[1062]=0.612063636278343;global.__bezier[1063]=0.612618479662045;global.__bezier[1064]=0.613172771432092;global.__bezier[1065]=0.613726371856031;global.__bezier[1066]=0.614279420059691;global.__bezier[1067]=0.614831776384154;global.__bezier[1068]=0.615383579893703;global.__bezier[1069]=0.615934830261303;global.__bezier[1070]=0.616485387939074;global.__bezier[1071]=0.617035391897743;global.__bezier[1072]=0.617584702664202;global.__bezier[1073]=0.618133459146252;global.__bezier[1074]=0.618681661030826;global.__bezier[1075]=0.619229168957695;global.__bezier[1076]=0.619776121739058;global.__bezier[1077]=0.620322380090677;global.__bezier[1078]=0.62086822170448;global.__bezier[1079]=0.62141322944917;global.__bezier[1080]=0.621957819860096;
global.__bezier[1081]=0.622501714862055;global.__bezier[1082]=0.623044914271194;global.__bezier[1083]=0.623587695437383;global.__bezier[1084]=0.62412978050846;global.__bezier[1085]=0.624671169309772;global.__bezier[1086]=0.625212138982782;global.__bezier[1087]=0.625752411900569;global.__bezier[1088]=0.626291987897612;global.__bezier[1089]=0.626831143904674;global.__bezier[1090]=0.627369602522247;global.__bezier[1091]=0.627907363593878;global.__bezier[1092]=0.628444703837352;global.__bezier[1093]=0.628981346082735;global.__bezier[1094]=0.629517428543451;global.__bezier[1095]=0.63005281263942;global.__bezier[1096]=0.630587636515049;global.__bezier[1097]=0.631121899918991;global.__bezier[1098]=0.631655602602381;global.__bezier[1099]=0.632188606146603;global.__bezier[1100]=0.632721186690279;global.__bezier[1101]=0.63325292958992;global.__bezier[1102]=0.633784249009286;global.__bezier[1103]=0.634314868558917;global.__bezier[1104]=0.634844926101359;global.__bezier[1105]=0.635374421405681;global.__bezier[1106]=0.635903354243383;global.__bezier[1107]=0.636431586524215;global.__bezier[1108]=0.636959255966788;global.__bezier[1109]=0.637486362350233;global.__bezier[1110]=0.638012767709355;
global.__bezier[1111]=0.638538747360969;global.__bezier[1112]=0.639064025637562;global.__bezier[1113]=0.639588740074974;global.__bezier[1114]=0.640112752876168;global.__bezier[1115]=0.640636339051919;global.__bezier[1116]=0.641159223261496;global.__bezier[1117]=0.641681542892402;global.__bezier[1118]=0.642203297745982;global.__bezier[1119]=0.642724487625942;global.__bezier[1120]=0.643244974990561;global.__bezier[1121]=0.643765034384353;global.__bezier[1122]=0.644284390963251;global.__bezier[1123]=0.644803181888488;global.__bezier[1124]=0.645321406975842;global.__bezier[1125]=0.645838928899351;global.__bezier[1126]=0.646356021808676;global.__bezier[1127]=0.64687241127972;global.__bezier[1128]=0.64738823428196;global.__bezier[1129]=0.647903627622215;global.__bezier[1130]=0.64841818019317;global.__bezier[1131]=0.648932302764465;global.__bezier[1132]=0.649445858191592;global.__bezier[1133]=0.649958709499051;global.__bezier[1134]=0.65047113019275;global.__bezier[1135]=0.650982846531522;global.__bezier[1136]=0.651493995171803;global.__bezier[1137]=0.652004575959904;global.__bezier[1138]=0.652514588744395;global.__bezier[1139]=0.653024033376101;global.__bezier[1140]=0.653532773191615;
global.__bezier[1141]=0.654041081121923;global.__bezier[1142]=0.654548684034525;global.__bezier[1143]=0.655055854694088;global.__bezier[1144]=0.655562320143794;global.__bezier[1145]=0.656068216679181;global.__bezier[1146]=0.656573680425738;global.__bezier[1147]=0.657078438691711;global.__bezier[1148]=0.657582627650229;global.__bezier[1149]=0.658086247174694;global.__bezier[1150]=0.658589297140703;global.__bezier[1151]=0.659091777426045;global.__bezier[1152]=0.659593551913524;global.__bezier[1153]=0.660094892523592;global.__bezier[1154]=0.660595663099563;global.__bezier[1155]=0.661095727662923;global.__bezier[1156]=0.661595357876641;global.__bezier[1157]=0.662094417722373;global.__bezier[1158]=0.662592771361158;global.__bezier[1159]=0.663090690196599;global.__bezier[1160]=0.663587902706835;global.__bezier[1161]=0.664084680121525;global.__bezier[1162]=0.664580886654835;global.__bezier[1163]=0.665076386702302;global.__bezier[1164]=0.665571451231119;global.__bezier[1165]=0.666065809178166;global.__bezier[1166]=0.666559731334643;global.__bezier[1167]=0.667052946822278;global.__bezier[1168]=0.667545726255468;global.__bezier[1169]=0.66803779894156;global.__bezier[1170]=0.668529435317341;
global.__bezier[1171]=0.669020500021481;global.__bezier[1172]=0.669510857877528;global.__bezier[1173]=0.670000779054345;global.__bezier[1174]=0.67049012833379;global.__bezier[1175]=0.670978905644734;global.__bezier[1176]=0.671467110918114;global.__bezier[1177]=0.671954609218486;global.__bezier[1178]=0.672441670264209;global.__bezier[1179]=0.67292815907762;global.__bezier[1180]=0.673414210326773;global.__bezier[1181]=0.673899554448352;global.__bezier[1182]=0.674384326161096;global.__bezier[1183]=0.674868525410263;global.__bezier[1184]=0.675352286684663;global.__bezier[1185]=0.675835340803478;global.__bezier[1186]=0.676317956753812;global.__bezier[1187]=0.676799999947197;global.__bezier[1188]=0.677281335986053;global.__bezier[1189]=0.67776223358019;global.__bezier[1190]=0.678242558288667;global.__bezier[1191]=0.678722310072543;global.__bezier[1192]=0.679201488894864;global.__bezier[1193]=0.679680228835137;global.__bezier[1194]=0.680158261583508;global.__bezier[1195]=0.680635855289821;global.__bezier[1196]=0.681112875810277;global.__bezier[1197]=0.681589189195229;global.__bezier[1198]=0.682065063312142;global.__bezier[1199]=0.682540497992761;global.__bezier[1200]=0.683015225515824;
global.__bezier[1201]=0.683489379735807;global.__bezier[1202]=0.683963094315155;global.__bezier[1203]=0.684436235460721;global.__bezier[1204]=0.684908803158506;global.__bezier[1205]=0.68538079739644;global.__bezier[1206]=0.685852218164372;global.__bezier[1207]=0.686323065454071;global.__bezier[1208]=0.686793472645632;global.__bezier[1209]=0.687263306249743;global.__bezier[1210]=0.687732566263639;global.__bezier[1211]=0.688201252686455;global.__bezier[1212]=0.688669365519221;global.__bezier[1213]=0.68913703790417;global.__bezier[1214]=0.68960413660744;global.__bezier[1215]=0.690070661635462;global.__bezier[1216]=0.690536612996547;global.__bezier[1217]=0.691001990700875;global.__bezier[1218]=0.691466927650556;global.__bezier[1219]=0.691931290869234;global.__bezier[1220]=0.692395080372428;global.__bezier[1221]=0.692858296177513;global.__bezier[1222]=0.69332107099284;global.__bezier[1223]=0.693783139410786;global.__bezier[1224]=0.694244766781905;global.__bezier[1225]=0.694705952979117;global.__bezier[1226]=0.695166432902968;global.__bezier[1227]=0.695626471605851;global.__bezier[1228]=0.696085936579956;global.__bezier[1229]=0.696544827856841;global.__bezier[1230]=0.697003277753127;
global.__bezier[1231]=0.697461153918536;global.__bezier[1232]=0.697918456389813;global.__bezier[1233]=0.698375185205504;global.__bezier[1234]=0.698831472484289;global.__bezier[1235]=0.699287186087109;global.__bezier[1236]=0.69974232605765;global.__bezier[1237]=0.700197024365175;global.__bezier[1238]=0.700651017157679;global.__bezier[1239]=0.701104568279939;global.__bezier[1240]=0.701557677627254;global.__bezier[1241]=0.702010213379591;global.__bezier[1242]=0.702462175590809;global.__bezier[1243]=0.702913564316522;global.__bezier[1244]=0.703364511174491;global.__bezier[1245]=0.703814884558983;global.__bezier[1246]=0.704264684530632;global.__bezier[1247]=0.704714042555273;global.__bezier[1248]=0.705162827188627;global.__bezier[1249]=0.705611038496308;global.__bezier[1250]=0.706058807791489;global.__bezier[1251]=0.706506003792013;global.__bezier[1252]=0.706952626568444;global.__bezier[1253]=0.707398807280554;global.__bezier[1254]=0.70784441480898;global.__bezier[1255]=0.708289580210747;global.__bezier[1256]=0.708734041546848;global.__bezier[1257]=0.709178191681334;global.__bezier[1258]=0.709621637909156;global.__bezier[1259]=0.710064642009578;global.__bezier[1260]=0.710507073190799;
global.__bezier[1261]=0.710949062199918;global.__bezier[1262]=0.711390478354822;global.__bezier[1263]=0.711831452298586;global.__bezier[1264]=0.712271853459082;global.__bezier[1265]=0.712711681927757;global.__bezier[1266]=0.713151068191172;global.__bezier[1267]=0.713589881842823;global.__bezier[1268]=0.714028122978914;global.__bezier[1269]=0.714465921928803;global.__bezier[1270]=0.714903148452232;global.__bezier[1271]=0.715339932773299;global.__bezier[1272]=0.715776144762858;global.__bezier[1273]=0.716211914539429;global.__bezier[1274]=0.716647112085266;global.__bezier[1275]=0.717081737507407;global.__bezier[1276]=0.717515920765551;global.__bezier[1277]=0.717949661806058;global.__bezier[1278]=0.71838270109313;global.__bezier[1279]=0.718815427964874;global.__bezier[1280]=0.719247453310972;global.__bezier[1281]=0.719679036566504;global.__bezier[1282]=0.720110177684381;global.__bezier[1283]=0.720540747151652;global.__bezier[1284]=0.720970874500883;global.__bezier[1285]=0.721400430332031;global.__bezier[1286]=0.721829414768743;global.__bezier[1287]=0.722257957182285;global.__bezier[1288]=0.722686057533199;global.__bezier[1289]=0.72311345751293;global.__bezier[1290]=0.723540544656399;
global.__bezier[1291]=0.723967060713262;global.__bezier[1292]=0.724393005815985;global.__bezier[1293]=0.724818509011058;global.__bezier[1294]=0.725243570266548;global.__bezier[1295]=0.725667931950225;global.__bezier[1296]=0.726091980602527;global.__bezier[1297]=0.726515458649811;global.__bezier[1298]=0.726938366233236;global.__bezier[1299]=0.727360832071915;global.__bezier[1300]=0.727782856141341;global.__bezier[1301]=0.728204309954277;global.__bezier[1302]=0.72862519365761;global.__bezier[1303]=0.729045635750775;global.__bezier[1304]=0.729465636214161;global.__bezier[1305]=0.729885066791337;global.__bezier[1306]=0.730304055816146;global.__bezier[1307]=0.730722475147945;global.__bezier[1308]=0.731140453009899;global.__bezier[1309]=0.731557989388344;global.__bezier[1310]=0.731974828362673;global.__bezier[1311]=0.732391353954443;global.__bezier[1312]=0.732807310302547;global.__bezier[1313]=0.733222825352144;global.__bezier[1314]=0.733637771369737;global.__bezier[1315]=0.734052276188842;global.__bezier[1316]=0.734466212192878;global.__bezier[1317]=0.734879707103446;global.__bezier[1318]=0.735292760917511;global.__bezier[1319]=0.735705246194233;global.__bezier[1320]=0.736117163105411;
global.__bezier[1321]=0.736528766471721;global.__bezier[1322]=0.736939801589721;global.__bezier[1323]=0.737350268635204;global.__bezier[1324]=0.73776029493586;global.__bezier[1325]=0.738169880496747;global.__bezier[1326]=0.738578898289342;global.__bezier[1327]=0.738987475471473;global.__bezier[1328]=0.739395612051567;global.__bezier[1329]=0.739803181178666;global.__bezier[1330]=0.740210309840133;global.__bezier[1331]=0.740616998047746;global.__bezier[1332]=0.74102311912865;global.__bezier[1333]=0.741428673271846;global.__bezier[1334]=0.741833913805506;global.__bezier[1335]=0.742238587549713;global.__bezier[1336]=0.742642694697334;global.__bezier[1337]=0.743046488229049;global.__bezier[1338]=0.743449715319404;global.__bezier[1339]=0.743852376165108;global.__bezier[1340]=0.744254723398218;global.__bezier[1341]=0.744656504548825;global.__bezier[1342]=0.74505771981745;global.__bezier[1343]=0.745458621486414;global.__bezier[1344]=0.745858957442419;global.__bezier[1345]=0.74625872788977;global.__bezier[1346]=0.74665818475995;global.__bezier[1347]=0.747057076297325;global.__bezier[1348]=0.74745540270996;global.__bezier[1349]=0.747853415577405;global.__bezier[1350]=0.748250863502738;
global.__bezier[1351]=0.748647872263959;global.__bezier[1352]=0.749044316388986;global.__bezier[1353]=0.749440321539261;global.__bezier[1354]=0.749835887751568;global.__bezier[1355]=0.750231015063683;global.__bezier[1356]=0.75062557824633;global.__bezier[1357]=0.751019702726933;global.__bezier[1358]=0.75141338854642;global.__bezier[1359]=0.751806510658243;global.__bezier[1360]=0.752199194313722;global.__bezier[1361]=0.752591439556913;global.__bezier[1362]=0.752983246432854;global.__bezier[1363]=0.753374490139345;global.__bezier[1364]=0.753765420480009;global.__bezier[1365]=0.754155663138965;global.__bezier[1366]=0.754545592529339;global.__bezier[1367]=0.754934959306146;global.__bezier[1368]=0.75532388824835;global.__bezier[1369]=0.755712379408132;global.__bezier[1370]=0.756100432838635;global.__bezier[1371]=0.756487924228959;global.__bezier[1372]=0.756874978120476;global.__bezier[1373]=0.757261594569376;global.__bezier[1374]=0.757647773632797;global.__bezier[1375]=0.75803339124677;global.__bezier[1376]=0.758418695775341;global.__bezier[1377]=0.758803439095357;global.__bezier[1378]=0.759187621450701;global.__bezier[1379]=0.759571490843024;global.__bezier[1380]=0.759954799517888;
global.__bezier[1381]=0.760337795234685;global.__bezier[1382]=0.760720230485217;global.__bezier[1383]=0.761102105519045;global.__bezier[1384]=0.761483667731494;global.__bezier[1385]=0.761864669984679;global.__bezier[1386]=0.76224523598108;global.__bezier[1387]=0.762625365790543;global.__bezier[1388]=0.763005059483839;global.__bezier[1389]=0.763384317132655;global.__bezier[1390]=0.7637630156063;global.__bezier[1391]=0.764141278304962;global.__bezier[1392]=0.764519105303252;global.__bezier[1393]=0.764896496676688;global.__bezier[1394]=0.765273452501704;global.__bezier[1395]=0.76564984996123;global.__bezier[1396]=0.76602593498428;global.__bezier[1397]=0.766401461923227;global.__bezier[1398]=0.7667765537527;global.__bezier[1399]=0.767151210553817;global.__bezier[1400]=0.767525432408597;global.__bezier[1401]=0.767899096877942;global.__bezier[1402]=0.768272449151943;global.__bezier[1403]=0.76864524433362;global.__bezier[1404]=0.769017605030741;global.__bezier[1405]=0.769389531329949;global.__bezier[1406]=0.769761023318773;global.__bezier[1407]=0.770132081085629;global.__bezier[1408]=0.770502704719813;global.__bezier[1409]=0.770872772288868;global.__bezier[1410]=0.771242527991784;
global.__bezier[1411]=0.771611727937968;global.__bezier[1412]=0.771980494243023;global.__bezier[1413]=0.772348827000787;global.__bezier[1414]=0.772716726305972;global.__bezier[1415]=0.773084192254158;global.__bezier[1416]=0.773451224941791;global.__bezier[1417]=0.773817702946115;global.__bezier[1418]=0.774183869468496;global.__bezier[1419]=0.774549481630967;global.__bezier[1420]=0.774914782384449;global.__bezier[1421]=0.77527952910506;global.__bezier[1422]=0.775643843288499;global.__bezier[1423]=0.77600772503738;global.__bezier[1424]=0.776371174455174;global.__bezier[1425]=0.776734191646196;global.__bezier[1426]=0.777096776715615;global.__bezier[1427]=0.777458929769442;global.__bezier[1428]=0.777820650914535;global.__bezier[1429]=0.77818181949822;global.__bezier[1430]=0.778542677213411;global.__bezier[1431]=0.778902982712444;global.__bezier[1432]=0.779262977435443;global.__bezier[1433]=0.779622420291075;global.__bezier[1434]=0.77998155246628;global.__bezier[1435]=0.780340133126433;global.__bezier[1436]=0.780698282890843;global.__bezier[1437]=0.781056001874024;global.__bezier[1438]=0.78141341037745;global.__bezier[1439]=0.781770268080992;global.__bezier[1440]=0.782126695351755;
global.__bezier[1441]=0.782482692307547;global.__bezier[1442]=0.782838259066996;global.__bezier[1443]=0.783193395749543;global.__bezier[1444]=0.783548102475445;global.__bezier[1445]=0.783902379365773;global.__bezier[1446]=0.784256226542408;global.__bezier[1447]=0.784609644128039;global.__bezier[1448]=0.784962632246165;global.__bezier[1449]=0.785315071541883;global.__bezier[1450]=0.78566720116325;global.__bezier[1451]=0.786018901692474;global.__bezier[1452]=0.786370173256266;global.__bezier[1453]=0.78672101598213;global.__bezier[1454]=0.787071429998372;global.__bezier[1455]=0.787421415434089;global.__bezier[1456]=0.787770972419172;global.__bezier[1457]=0.788120101084305;global.__bezier[1458]=0.788468801560958;global.__bezier[1459]=0.788816955149547;global.__bezier[1460]=0.789164799711783;global.__bezier[1461]=0.789512216484716;global.__bezier[1462]=0.789859205602956;global.__bezier[1463]=0.790205767201894;global.__bezier[1464]=0.790552019924223;global.__bezier[1465]=0.790897726828653;global.__bezier[1466]=0.791243006624577;global.__bezier[1467]=0.791587859450492;global.__bezier[1468]=0.791932285445662;global.__bezier[1469]=0.792276284750124;global.__bezier[1470]=0.792619975619403;
global.__bezier[1471]=0.792963121900185;global.__bezier[1472]=0.793305841914926;global.__bezier[1473]=0.793648253724975;global.__bezier[1474]=0.793990121572122;global.__bezier[1475]=0.794331681371819;global.__bezier[1476]=0.794672815351068;global.__bezier[1477]=0.795013406000194;global.__bezier[1478]=0.795353688843076;global.__bezier[1479]=0.795693546305838;global.__bezier[1480]=0.796032978536747;global.__bezier[1481]=0.796371985684818;global.__bezier[1482]=0.796710567899815;global.__bezier[1483]=0.797048725332246;global.__bezier[1484]=0.797386458133363;global.__bezier[1485]=0.797723766455161;global.__bezier[1486]=0.798060767512908;global.__bezier[1487]=0.798397227268909;global.__bezier[1488]=0.798733379936243;global.__bezier[1489]=0.79906899174313;global.__bezier[1490]=0.799404296639523;global.__bezier[1491]=0.799739177851441;global.__bezier[1492]=0.800073635535913;global.__bezier[1493]=0.800407669850694;global.__bezier[1494]=0.800741280954264;global.__bezier[1495]=0.80107458547192;global.__bezier[1496]=0.801407350564955;global.__bezier[1497]=0.801739809259637;global.__bezier[1498]=0.802071728984595;global.__bezier[1499]=0.802403342501499;global.__bezier[1500]=0.80273453363994;
global.__bezier[1501]=0.803065302563333;global.__bezier[1502]=0.803395649435803;global.__bezier[1503]=0.80372557442219;global.__bezier[1504]=0.804055193554483;global.__bezier[1505]=0.804384275199247;global.__bezier[1506]=0.804713051189426;global.__bezier[1507]=0.805041405826142;global.__bezier[1508]=0.805369339277662;global.__bezier[1509]=0.805696851712953;global.__bezier[1510]=0.806023943301688;global.__bezier[1511]=0.806350614214232;global.__bezier[1512]=0.806676979952454;global.__bezier[1513]=0.807002925223068;global.__bezier[1514]=0.807328335001925;global.__bezier[1515]=0.807653439922271;global.__bezier[1516]=0.807978239956239;global.__bezier[1517]=0.808302505086853;global.__bezier[1518]=0.808626350618525;global.__bezier[1519]=0.808949891587186;global.__bezier[1520]=0.809273013174422;global.__bezier[1521]=0.809595715557297;global.__bezier[1522]=0.809917998913555;global.__bezier[1523]=0.81023997801197;global.__bezier[1524]=0.810561423783424;global.__bezier[1525]=0.810882565520782;global.__bezier[1526]=0.811203288814052;global.__bezier[1527]=0.811523593844261;global.__bezier[1528]=0.811843480793111;global.__bezier[1529]=0.812163064027566;global.__bezier[1530]=0.812482229410573;
global.__bezier[1531]=0.812800977125742;global.__bezier[1532]=0.813119307357349;global.__bezier[1533]=0.813437220290333;global.__bezier[1534]=0.813754829955753;global.__bezier[1535]=0.814071908781041;global.__bezier[1536]=0.814388684576032;global.__bezier[1537]=0.814705043682753;global.__bezier[1538]=0.815021099862865;global.__bezier[1539]=0.815336626090065;global.__bezier[1540]=0.815651849632696;global.__bezier[1541]=0.815966657107248;global.__bezier[1542]=0.81628104870438;global.__bezier[1543]=0.816595137848201;global.__bezier[1544]=0.816908811361374;global.__bezier[1545]=0.817222069436409;global.__bezier[1546]=0.81753491226646;global.__bezier[1547]=0.817847340045323;global.__bezier[1548]=0.818159465858644;global.__bezier[1549]=0.818471176873463;global.__bezier[1550]=0.818782473285405;global.__bezier[1551]=0.819093355290734;global.__bezier[1552]=0.819403935703666;global.__bezier[1553]=0.819714101967311;global.__bezier[1554]=0.820023854279744;global.__bezier[1555]=0.820333192839672;global.__bezier[1556]=0.820642230189317;global.__bezier[1557]=0.820950854048385;global.__bezier[1558]=0.821259064617378;global.__bezier[1559]=0.821566974234122;global.__bezier[1560]=0.821874358758192;
global.__bezier[1561]=0.822181442596502;global.__bezier[1562]=0.822488225745481;global.__bezier[1563]=0.822794484479334;global.__bezier[1564]=0.823100442793687;global.__bezier[1565]=0.823405988962998;global.__bezier[1566]=0.823711123192557;global.__bezier[1567]=0.824015957273706;global.__bezier[1568]=0.824320379689426;global.__bezier[1569]=0.824624390646762;global.__bezier[1570]=0.824928101731529;global.__bezier[1571]=0.825231290326522;global.__bezier[1572]=0.825534179327722;global.__bezier[1573]=0.825836768736964;global.__bezier[1574]=0.826138947455136;global.__bezier[1575]=0.826440715692753;global.__bezier[1576]=0.826742073660931;global.__bezier[1577]=0.82704302157138;global.__bezier[1578]=0.827343670460459;global.__bezier[1579]=0.827643909578232;global.__bezier[1580]=0.827943849823313;global.__bezier[1581]=0.828243380585593;global.__bezier[1582]=0.828542502079602;global.__bezier[1583]=0.828841214520459;global.__bezier[1584]=0.829139628530989;global.__bezier[1585]=0.829437633781197;global.__bezier[1586]=0.82973534075577;global.__bezier[1587]=0.830032529066693;global.__bezier[1588]=0.830329529526508;global.__bezier[1589]=0.830626011759055;global.__bezier[1590]=0.830922196170659;
global.__bezier[1591]=0.831217972852364;global.__bezier[1592]=0.831513342024313;global.__bezier[1593]=0.831808413686842;global.__bezier[1594]=0.832103078141902;global.__bezier[1595]=0.832397335611289;global.__bezier[1596]=0.832691295887278;global.__bezier[1597]=0.832984849482992;global.__bezier[1598]=0.833278106051805;global.__bezier[1599]=0.833570956247744;global.__bezier[1600]=0.83386340029531;global.__bezier[1601]=0.834155438419567;global.__bezier[1602]=0.83444717999581;global.__bezier[1603]=0.834738625039808;global.__bezier[1604]=0.835029555549074;global.__bezier[1605]=0.835320189839631;global.__bezier[1606]=0.835610419059707;global.__bezier[1607]=0.835900352236237;global.__bezier[1608]=0.836189880658859;global.__bezier[1609]=0.836479113214926;global.__bezier[1610]=0.836767941335615;global.__bezier[1611]=0.8370563652513;global.__bezier[1612]=0.837344385192899;global.__bezier[1613]=0.837632109768337;global.__bezier[1614]=0.837919538998251;global.__bezier[1615]=0.83820645643271;global.__bezier[1616]=0.838493187011115;global.__bezier[1617]=0.838779406260569;global.__bezier[1618]=0.839065330674433;global.__bezier[1619]=0.839350852322301;global.__bezier[1620]=0.839636079321832;
global.__bezier[1621]=0.839920903884757;global.__bezier[1622]=0.840205433988381;global.__bezier[1623]=0.840489561986694;global.__bezier[1624]=0.840773288116803;global.__bezier[1625]=0.841056720145292;global.__bezier[1626]=0.84133975063979;global.__bezier[1627]=0.841622379838934;global.__bezier[1628]=0.841904715298347;global.__bezier[1629]=0.842186757045072;global.__bezier[1630]=0.842468290757262;global.__bezier[1631]=0.842749531095745;global.__bezier[1632]=0.843030478088848;global.__bezier[1633]=0.843311024803537;global.__bezier[1634]=0.843591278372634;global.__bezier[1635]=0.843871025186389;global.__bezier[1636]=0.844150585946802;global.__bezier[1637]=0.844429640438629;global.__bezier[1638]=0.844708508938269;global.__bezier[1639]=0.844986871658032;global.__bezier[1640]=0.845264941984432;global.__bezier[1641]=0.845542719949481;global.__bezier[1642]=0.845820099264069;global.__bezier[1643]=0.846097080174743;global.__bezier[1644]=0.846373769107475;global.__bezier[1645]=0.846650059988292;global.__bezier[1646]=0.846926059101448;global.__bezier[1647]=0.847201660516494;global.__bezier[1648]=0.84747697037585;global.__bezier[1649]=0.847751882892701;global.__bezier[1650]=0.848026398316969;
global.__bezier[1651]=0.848300622578161;global.__bezier[1652]=0.848574450105126;global.__bezier[1653]=0.848847986685281;global.__bezier[1654]=0.849121232355821;global.__bezier[1655]=0.849393976368529;global.__bezier[1656]=0.849666535154809;global.__bezier[1657]=0.849938592789243;global.__bezier[1658]=0.850210465274419;global.__bezier[1659]=0.850481837115604;global.__bezier[1660]=0.850753023886241;global.__bezier[1661]=0.8510237105226;global.__bezier[1662]=0.851294107277612;global.__bezier[1663]=0.851564214192008;global.__bezier[1664]=0.851833926559409;global.__bezier[1665]=0.85210334931236;global.__bezier[1666]=0.852372377888965;global.__bezier[1667]=0.852641012547079;global.__bezier[1668]=0.852909358004974;global.__bezier[1669]=0.853177414305664;global.__bezier[1670]=0.853445077176489;global.__bezier[1671]=0.85371234687712;global.__bezier[1672]=0.853979327839724;global.__bezier[1673]=0.854246020108821;global.__bezier[1674]=0.854512319701376;global.__bezier[1675]=0.854778226878861;global.__bezier[1676]=0.855043845786921;global.__bezier[1677]=0.855309176471575;global.__bezier[1678]=0.855574115239791;global.__bezier[1679]=0.855838662354825;global.__bezier[1680]=0.856102921675396;
global.__bezier[1681]=0.856366893249011;global.__bezier[1682]=0.856630473673015;global.__bezier[1683]=0.856893766590631;global.__bezier[1684]=0.857156668744547;global.__bezier[1685]=0.85741918040066;global.__bezier[1686]=0.857681404986546;global.__bezier[1687]=0.857943342551919;global.__bezier[1688]=0.858204890130389;global.__bezier[1689]=0.858466150933597;global.__bezier[1690]=0.858727022140765;global.__bezier[1691]=0.858987606819472;global.__bezier[1692]=0.859247905021199;global.__bezier[1693]=0.859507711489685;global.__bezier[1694]=0.859767334456817;global.__bezier[1695]=0.860026568739639;global.__bezier[1696]=0.860285414608784;global.__bezier[1697]=0.86054397469906;global.__bezier[1698]=0.860802249064107;global.__bezier[1699]=0.861060135539469;global.__bezier[1700]=0.86131773654321;global.__bezier[1701]=0.861574950056984;global.__bezier[1702]=0.861831878354257;global.__bezier[1703]=0.862088419562877;global.__bezier[1704]=0.862344675811624;global.__bezier[1705]=0.86260054537462;global.__bezier[1706]=0.86285613023587;global.__bezier[1707]=0.863111430452161;global.__bezier[1708]=0.863366344517157;global.__bezier[1709]=0.863620974197483;global.__bezier[1710]=0.86387521813331;
global.__bezier[1711]=0.86412917794624;global.__bezier[1712]=0.864382752423029;global.__bezier[1713]=0.864636043040175;global.__bezier[1714]=0.864889049856859;global.__bezier[1715]=0.865141671879841;global.__bezier[1716]=0.865393909388056;global.__bezier[1717]=0.86564596447414;global.__bezier[1718]=0.865897534478767;global.__bezier[1719]=0.866148922182688;global.__bezier[1720]=0.866399926053147;global.__bezier[1721]=0.866650546371085;global.__bezier[1722]=0.866900984499826;global.__bezier[1723]=0.867150938878687;global.__bezier[1724]=0.867400711193102;global.__bezier[1725]=0.867650100643628;global.__bezier[1726]=0.867899107513191;global.__bezier[1727]=0.868147832259915;global.__bezier[1728]=0.868396274947679;global.__bezier[1729]=0.868644335612522;global.__bezier[1730]=0.86889211449376;global.__bezier[1731]=0.869139611656237;global.__bezier[1732]=0.869386727357069;global.__bezier[1733]=0.869633561616555;global.__bezier[1734]=0.86988001483932;global.__bezier[1735]=0.870126186899564;global.__bezier[1736]=0.870372077863756;global.__bezier[1737]=0.870617588357904;global.__bezier[1738]=0.870862818036864;global.__bezier[1739]=0.871107667674354;global.__bezier[1740]=0.871352236778915;
global.__bezier[1741]=0.871596525418628;global.__bezier[1742]=0.871840434588888;global.__bezier[1743]=0.872084063578577;global.__bezier[1744]=0.872327313530993;global.__bezier[1745]=0.872570283588497;global.__bezier[1746]=0.872812973820764;global.__bezier[1747]=0.873055384297746;global.__bezier[1748]=0.873297416458737;global.__bezier[1749]=0.8735390705955;global.__bezier[1750]=0.873780543967139;global.__bezier[1751]=0.874021541194506;global.__bezier[1752]=0.874262357799534;global.__bezier[1753]=0.874502797108507;global.__bezier[1754]=0.874742957603285;global.__bezier[1755]=0.87498283935632;global.__bezier[1756]=0.875222344399883;global.__bezier[1757]=0.875461473028696;global.__bezier[1758]=0.875700421323221;global.__bezier[1759]=0.87593899349791;global.__bezier[1760]=0.876177287593346;global.__bezier[1761]=0.876415206013041;global.__bezier[1762]=0.876652846650334;global.__bezier[1763]=0.876890209580139;global.__bezier[1764]=0.877127197428926;global.__bezier[1765]=0.877363907869004;global.__bezier[1766]=0.877600340976186;global.__bezier[1767]=0.877836399600074;global.__bezier[1768]=0.878072181191763;global.__bezier[1769]=0.878307685827963;global.__bezier[1770]=0.878542816581574;
global.__bezier[1771]=0.878777670682296;global.__bezier[1772]=0.879012151351998;global.__bezier[1773]=0.879246452454243;global.__bezier[1774]=0.87948038042996;global.__bezier[1775]=0.879713935580326;global.__bezier[1776]=0.879947311324467;global.__bezier[1777]=0.88018031454963;global.__bezier[1778]=0.880412945558038;global.__bezier[1779]=0.880645397324043;global.__bezier[1780]=0.880877477181536;global.__bezier[1781]=0.88110918543378;global.__bezier[1782]=0.881340714610017;global.__bezier[1783]=0.881571872491104;global.__bezier[1784]=0.881802755345326;global.__bezier[1785]=0.882033267364525;global.__bezier[1786]=0.8822635046688;global.__bezier[1787]=0.882493467340136;global.__bezier[1788]=0.882723155460775;global.__bezier[1789]=0.882952473521608;global.__bezier[1790]=0.883181517346094;global.__bezier[1791]=0.883410287017336;global.__bezier[1792]=0.883638687250714;global.__bezier[1793]=0.883866813647016;global.__bezier[1794]=0.8840946662902;global.__bezier[1795]=0.884322150120284;global.__bezier[1796]=0.884549360515223;global.__bezier[1797]=0.884776297559827;global.__bezier[1798]=0.885002961339159;global.__bezier[1799]=0.885229257092982;global.__bezier[1800]=0.885455279901866;
global.__bezier[1801]=0.885681029851717;global.__bezier[1802]=0.885906412407301;global.__bezier[1803]=0.886131522425964;global.__bezier[1804]=0.886356359994453;global.__bezier[1805]=0.886580925199768;global.__bezier[1806]=0.886805123806895;global.__bezier[1807]=0.887029050375283;global.__bezier[1808]=0.887252704992763;global.__bezier[1809]=0.887475993649677;global.__bezier[1810]=0.887699010681871;global.__bezier[1811]=0.887921756178006;global.__bezier[1812]=0.888144230226989;global.__bezier[1813]=0.888366339119845;global.__bezier[1814]=0.888588270617219;global.__bezier[1815]=0.88880974363927;global.__bezier[1816]=0.889031039445546;global.__bezier[1817]=0.889251970904837;global.__bezier[1818]=0.889472631755913;global.__bezier[1819]=0.889693022089565;global.__bezier[1820]=0.889913141996833;global.__bezier[1821]=0.890132898370921;global.__bezier[1822]=0.890352384651626;global.__bezier[1823]=0.890571600930795;global.__bezier[1824]=0.890790454327722;global.__bezier[1825]=0.891009130955492;global.__bezier[1826]=0.891227445036254;global.__bezier[1827]=0.89144539688834;global.__bezier[1828]=0.891663172174804;global.__bezier[1829]=0.891880585569512;global.__bezier[1830]=0.892097729913517;
global.__bezier[1831]=0.892314605300751;global.__bezier[1832]=0.892531211825388;global.__bezier[1833]=0.892747457285815;global.__bezier[1834]=0.892963434223292;global.__bezier[1835]=0.893179142732783;global.__bezier[1836]=0.893394490839324;global.__bezier[1837]=0.893609662854031;global.__bezier[1838]=0.893824474807615;global.__bezier[1839]=0.894039018866225;global.__bezier[1840]=0.894253295126085;global.__bezier[1841]=0.894467211990291;global.__bezier[1842]=0.89468086139973;global.__bezier[1843]=0.894894243451406;global.__bezier[1844]=0.895107358242554;global.__bezier[1845]=0.895320205870648;global.__bezier[1846]=0.89553269511721;global.__bezier[1847]=0.895744917547355;global.__bezier[1848]=0.895956873259327;global.__bezier[1849]=0.896168562351601;global.__bezier[1850]=0.896379893908722;global.__bezier[1851]=0.896590959194902;global.__bezier[1852]=0.896801758309382;global.__bezier[1853]=0.897012291351633;global.__bezier[1854]=0.897222558421359;global.__bezier[1855]=0.897432468982203;global.__bezier[1856]=0.897642113921883;global.__bezier[1857]=0.897851493340861;global.__bezier[1858]=0.898060607339825;global.__bezier[1859]=0.898269456019696;global.__bezier[1860]=0.898477949223589;
global.__bezier[1861]=0.898686177462328;global.__bezier[1862]=0.898894140837581;global.__bezier[1863]=0.899101839451246;global.__bezier[1864]=0.899309273405445;global.__bezier[1865]=0.899516352923132;global.__bezier[1866]=0.899723168137844;global.__bezier[1867]=0.899929719152446;global.__bezier[1868]=0.900136006070031;global.__bezier[1869]=0.900342028993914;global.__bezier[1870]=0.900547698527241;global.__bezier[1871]=0.900753104425879;global.__bezier[1872]=0.900958246793881;global.__bezier[1873]=0.901163125735522;global.__bezier[1874]=0.9013677413553;global.__bezier[1875]=0.901572004636894;global.__bezier[1876]=0.901776094003271;global.__bezier[1877]=0.901979831393458;global.__bezier[1878]=0.902183306033945;global.__bezier[1879]=0.902386518030401;global.__bezier[1880]=0.902589378747404;global.__bezier[1881]=0.902792065849691;global.__bezier[1882]=0.902994402036986;global.__bezier[1883]=0.903196476157205;global.__bezier[1884]=0.903398288317178;global.__bezier[1885]=0.903599838623949;global.__bezier[1886]=0.903801038899612;global.__bezier[1887]=0.904002065898084;global.__bezier[1888]=0.90420274323282;global.__bezier[1889]=0.904403159296965;global.__bezier[1890]=0.904603314198712;
global.__bezier[1891]=0.904803208046469;global.__bezier[1892]=0.905002840948859;global.__bezier[1893]=0.905202125262367;global.__bezier[1894]=0.905401149000755;global.__bezier[1895]=0.905599999873366;global.__bezier[1896]=0.905798415189691;global.__bezier[1897]=0.905996657859534;global.__bezier[1898]=0.906194640392846;global.__bezier[1899]=0.906392362899808;global.__bezier[1900]=0.906589738271937;global.__bezier[1901]=0.906786853991264;global.__bezier[1902]=0.906983710168661;global.__bezier[1903]=0.907180306915215;global.__bezier[1904]=0.907376644342222;global.__bezier[1905]=0.907572722561187;global.__bezier[1906]=0.907768454922736;global.__bezier[1907]=0.90796401513735;global.__bezier[1908]=0.908159229871345;global.__bezier[1909]=0.908354185998218;global.__bezier[1910]=0.908548883630577;global.__bezier[1911]=0.90874332288124;global.__bezier[1912]=0.908937503863234;global.__bezier[1913]=0.909131340463395;global.__bezier[1914]=0.909325005324414;global.__bezier[1915]=0.909518326183604;global.__bezier[1916]=0.909711389381267;global.__bezier[1917]=0.909904195031517;global.__bezier[1918]=0.910096743248673;global.__bezier[1919]=0.910289034147259;global.__bezier[1920]=0.910480982150926;
global.__bezier[1921]=0.910672758833309;global.__bezier[1922]=0.910864193003931;global.__bezier[1923]=0.911055455930731;global.__bezier[1924]=0.911246376729812;global.__bezier[1925]=0.911437041054983;global.__bezier[1926]=0.911627449022248;global.__bezier[1927]=0.91181760074781;global.__bezier[1928]=0.912007496348078;global.__bezier[1929]=0.912197050937792;global.__bezier[1930]=0.912386434714157;global.__bezier[1931]=0.912575477867103;global.__bezier[1932]=0.91276426551576;global.__bezier[1933]=0.912952797777586;global.__bezier[1934]=0.9131411593888;global.__bezier[1935]=0.913329181153446;global.__bezier[1936]=0.913516863419693;global.__bezier[1937]=0.9137043753128;global.__bezier[1938]=0.913891632409372;global.__bezier[1939]=0.914078550593148;global.__bezier[1940]=0.91426529852959;global.__bezier[1941]=0.914451707944699;global.__bezier[1942]=0.914637863192681;global.__bezier[1943]=0.914823848320823;global.__bezier[1944]=0.915009495516406;global.__bezier[1945]=0.915194888903903;global.__bezier[1946]=0.915379944906067;global.__bezier[1947]=0.915564831114671;global.__bezier[1948]=0.915749463876018;global.__bezier[1949]=0.915933843310769;global.__bezier[1950]=0.916117886149928;
global.__bezier[1951]=0.91630175937116;global.__bezier[1952]=0.916485296392912;global.__bezier[1953]=0.916668580726516;global.__bezier[1954]=0.916851612493643;global.__bezier[1955]=0.917034391816155;global.__bezier[1956]=0.917216918816109;global.__bezier[1957]=0.91739919361575;global.__bezier[1958]=0.917581216337517;global.__bezier[1959]=0.917762987104039;global.__bezier[1960]=0.917944506038134;global.__bezier[1961]=0.91812569071943;global.__bezier[1962]=0.918306706434926;global.__bezier[1963]=0.918487388298278;global.__bezier[1964]=0.918667901288783;global.__bezier[1965]=0.91884808082861;global.__bezier[1966]=0.919028009431083;global.__bezier[1967]=0.919207769301474;global.__bezier[1968]=0.919387196324891;global.__bezier[1969]=0.919566372784051;global.__bezier[1970]=0.919745298803701;global.__bezier[1971]=0.919923974508771;global.__bezier[1972]=0.92010240002438;global.__bezier[1973]=0.92028057547583;global.__bezier[1974]=0.920458419447394;global.__bezier[1975]=0.920636095224358;global.__bezier[1976]=0.920813521314198;global.__bezier[1977]=0.920990616533277;global.__bezier[1978]=0.921167543704401;global.__bezier[1979]=0.921344140411826;global.__bezier[1980]=0.921520569169929;
global.__bezier[1981]=0.921696667872181;global.__bezier[1982]=0.921872517800848;global.__bezier[1983]=0.922048199929444;global.__bezier[1984]=0.92222355261541;global.__bezier[1985]=0.922398656909868;global.__bezier[1986]=0.922573512940541;global.__bezier[1987]=0.922748120835338;global.__bezier[1988]=0.922922480722343;global.__bezier[1989]=0.923096592729824;global.__bezier[1990]=0.923270456986228;global.__bezier[1991]=0.923444073620182;global.__bezier[1992]=0.923617442760491;global.__bezier[1993]=0.923790564536138;global.__bezier[1994]=0.923963439076289;global.__bezier[1995]=0.924136066510282;global.__bezier[1996]=0.924308367126596;global.__bezier[1997]=0.924480500814425;global.__bezier[1998]=0.9246523877852;global.__bezier[1999]=0.924823948560165;global.__bezier[2000]=0.924995342564607;global.__bezier[2001]=0.925166410788751;global.__bezier[2002]=0.925337312348519;global.__bezier[2003]=0.925507967843271;global.__bezier[2004]=0.92567829818241;global.__bezier[2005]=0.925848382873539;global.__bezier[2006]=0.926018301114554;global.__bezier[2007]=0.926187894826286;global.__bezier[2008]=0.926357322196017;global.__bezier[2009]=0.926526425454953;global.__bezier[2010]=0.926695283724158;
global.__bezier[2011]=0.926863975814771;global.__bezier[2012]=0.927032344423685;global.__bezier[2013]=0.927200468439915;global.__bezier[2014]=0.927368426442418;global.__bezier[2015]=0.927536061593964;global.__bezier[2016]=0.927703452551415;global.__bezier[2017]=0.927870599447983;global.__bezier[2018]=0.928037580552915;global.__bezier[2019]=0.928204239650408;global.__bezier[2020]=0.928370655087655;global.__bezier[2021]=0.928536826998546;global.__bezier[2022]=0.928702833342451;global.__bezier[2023]=0.928868518525316;global.__bezier[2024]=0.929033960584495;global.__bezier[2025]=0.929199159654551;global.__bezier[2026]=0.929364115870215;global.__bezier[2027]=0.929528829366385;global.__bezier[2028]=0.929693377637331;global.__bezier[2029]=0.929857606022167;global.__bezier[2030]=0.930021592093197;global.__bezier[2031]=0.930185335985989;global.__bezier[2032]=0.930348837836271;global.__bezier[2033]=0.930512097779942;global.__bezier[2034]=0.930675192845815;global.__bezier[2035]=0.930837969306845;global.__bezier[2036]=0.931000504269935;global.__bezier[2037]=0.93116279787164;global.__bezier[2038]=0.931324926830269;global.__bezier[2039]=0.931486738041723;global.__bezier[2040]=0.931648308302432;
global.__bezier[2041]=0.931809637749605;global.__bezier[2042]=0.931970802790902;global.__bezier[2043]=0.932131650945445;global.__bezier[2044]=0.932292258699047;global.__bezier[2045]=0.932452626189564;global.__bezier[2046]=0.932612829513865;global.__bezier[2047]=0.932772716814563;global.__bezier[2048]=0.93293236426671;global.__bezier[2049]=0.933091847733977;global.__bezier[2050]=0.933251015826788;global.__bezier[2051]=0.933410020056357;global.__bezier[2052]=0.933568709345086;global.__bezier[2053]=0.933727234892813;global.__bezier[2054]=0.933885445933985;global.__bezier[2055]=0.934043493357002;global.__bezier[2056]=0.934201226708413;global.__bezier[2057]=0.934358796565116;global.__bezier[2058]=0.934516052785826;global.__bezier[2059]=0.934673145635876;global.__bezier[2060]=0.934830000153859;global.__bezier[2061]=0.934986616480153;global.__bezier[2062]=0.935142920043683;global.__bezier[2063]=0.935299060486394;global.__bezier[2064]=0.935454963159497;global.__bezier[2065]=0.935610628203993;global.__bezier[2066]=0.93576605576104;global.__bezier[2067]=0.93592124597195;global.__bezier[2068]=0.93607619897819;global.__bezier[2069]=0.93623091492138;global.__bezier[2070]=0.936385393943296;
global.__bezier[2071]=0.936539636185866;global.__bezier[2072]=0.93669364179117;global.__bezier[2073]=0.936847410901444;global.__bezier[2074]=0.937000943659074;global.__bezier[2075]=0.937154313903233;global.__bezier[2076]=0.937307374305224;global.__bezier[2077]=0.937460198782639;global.__bezier[2078]=0.937612860940679;global.__bezier[2079]=0.937765213919934;global.__bezier[2080]=0.937917404709922;global.__bezier[2081]=0.938069286764174;global.__bezier[2082]=0.938221006759846;global.__bezier[2083]=0.938372491534784;global.__bezier[2084]=0.938523668239749;global.__bezier[2085]=0.938674683083218;global.__bezier[2086]=0.938825463138039;global.__bezier[2087]=0.938976008548537;global.__bezier[2088]=0.939126319459186;global.__bezier[2089]=0.939276396014607;global.__bezier[2090]=0.939426238359569;global.__bezier[2091]=0.939575846638988;global.__bezier[2092]=0.939725220997929;global.__bezier[2093]=0.939874433870567;global.__bezier[2094]=0.940023340746061;global.__bezier[2095]=0.94017201413714;global.__bezier[2096]=0.940320526243569;global.__bezier[2097]=0.940468805000424;global.__bezier[2098]=0.940616778656164;global.__bezier[2099]=0.940764591230123;global.__bezier[2100]=0.940912170892723;
global.__bezier[2101]=0.941059446127824;global.__bezier[2102]=0.941206560485272;global.__bezier[2103]=0.941353442370876;global.__bezier[2104]=0.941500091931424;global.__bezier[2105]=0.941646509313853;global.__bezier[2106]=0.941792765935961;global.__bezier[2107]=0.941938719325152;global.__bezier[2108]=0.942084440977878;global.__bezier[2109]=0.942230002077205;global.__bezier[2110]=0.942375260621269;global.__bezier[2111]=0.942520358750556;global.__bezier[2112]=0.94266515477709;global.__bezier[2113]=0.942809790528014;global.__bezier[2114]=0.94295419527277;global.__bezier[2115]=0.943098369159695;global.__bezier[2116]=0.943242312337266;global.__bezier[2117]=0.943386024954102;global.__bezier[2118]=0.943529507158959;global.__bezier[2119]=0.943672829351933;global.__bezier[2120]=0.943815851101197;global.__bezier[2121]=0.943958642885583;global.__bezier[2122]=0.944101274870166;global.__bezier[2123]=0.944243677031648;global.__bezier[2124]=0.944385779660867;global.__bezier[2125]=0.94452772270353;global.__bezier[2126]=0.944669436372237;global.__bezier[2127]=0.944810920816974;global.__bezier[2128]=0.944952176187867;global.__bezier[2129]=0.945093202635178;global.__bezier[2130]=0.945234069696872;
global.__bezier[2131]=0.945374638669804;global.__bezier[2132]=0.945515048401197;global.__bezier[2133]=0.945655160502409;global.__bezier[2134]=0.945795113506688;global.__bezier[2135]=0.945934838334647;global.__bezier[2136]=0.946074335137484;global.__bezier[2137]=0.946213604066532;global.__bezier[2138]=0.946352645273255;global.__bezier[2139]=0.946491458909253;global.__bezier[2140]=0.946630045126257;global.__bezier[2141]=0.946768472599222;global.__bezier[2142]=0.946906604355359;global.__bezier[2143]=0.94704457751432;global.__bezier[2144]=0.947182323705272;global.__bezier[2145]=0.947319774872084;global.__bezier[2146]=0.947457067662966;global.__bezier[2147]=0.947594201994593;global.__bezier[2148]=0.947731041838685;global.__bezier[2149]=0.947867655478012;global.__bezier[2150]=0.948004110880778;global.__bezier[2151]=0.948140272491156;global.__bezier[2152]=0.948276276014065;global.__bezier[2153]=0.948412053787762;global.__bezier[2154]=0.948547605965802;global.__bezier[2155]=0.948682932701868;global.__bezier[2156]=0.948818034149769;global.__bezier[2157]=0.948952910463446;global.__bezier[2158]=0.949087561796966;global.__bezier[2159]=0.949222055411248;global.__bezier[2160]=0.949356324196404;
global.__bezier[2161]=0.949490301357684;global.__bezier[2162]=0.949624121026817;global.__bezier[2163]=0.949757716330543;global.__bezier[2164]=0.949891087423687;global.__bezier[2165]=0.950024301095323;global.__bezier[2166]=0.950157224153515;global.__bezier[2167]=0.950289989942895;global.__bezier[2168]=0.950422465586944;global.__bezier[2169]=0.950554784115374;global.__bezier[2170]=0.950686879207224;global.__bezier[2171]=0.950818751018194;global.__bezier[2172]=0.950950399704109;global.__bezier[2173]=0.951081891424558;global.__bezier[2174]=0.951213094249512;global.__bezier[2175]=0.951344140263589;global.__bezier[2176]=0.951474963619466;global.__bezier[2177]=0.951605498785338;global.__bezier[2178]=0.951735877373114;global.__bezier[2179]=0.951866099302897;global.__bezier[2180]=0.95199603359159;global.__bezier[2181]=0.952125746005505;global.__bezier[2182]=0.952255301995585;global.__bezier[2183]=0.952384636267342;global.__bezier[2184]=0.952513748978068;global.__bezier[2185]=0.952642640285175;global.__bezier[2186]=0.952771310346196;global.__bezier[2187]=0.952899759318785;global.__bezier[2188]=0.953028052181151;global.__bezier[2189]=0.953156059371411;global.__bezier[2190]=0.953283910609506;
global.__bezier[2191]=0.953411541233133;global.__bezier[2192]=0.953538951400542;global.__bezier[2193]=0.953666141270102;global.__bezier[2194]=0.953793175347079;global.__bezier[2195]=0.953919925017581;global.__bezier[2196]=0.954046519054907;global.__bezier[2197]=0.954172893271121;global.__bezier[2198]=0.954299047825182;global.__bezier[2199]=0.954424982876169;global.__bezier[2200]=0.954550698583273;global.__bezier[2201]=0.954676258899722;global.__bezier[2202]=0.954801536318131;global.__bezier[2203]=0.954926658506861;global.__bezier[2204]=0.955051561831653;global.__bezier[2205]=0.955176246452285;global.__bezier[2206]=0.955300712528648;global.__bezier[2207]=0.955425023540569;global.__bezier[2208]=0.955549116170284;global.__bezier[2209]=0.955672927416311;global.__bezier[2210]=0.95579658384149;global.__bezier[2211]=0.955920022365519;global.__bezier[2212]=0.95604330607355;global.__bezier[2213]=0.956166309198085;global.__bezier[2214]=0.956289157669992;global.__bezier[2215]=0.956411726038265;global.__bezier[2216]=0.956534139917737;global.__bezier[2217]=0.956656336703116;global.__bezier[2218]=0.956778379005779;global.__bezier[2219]=0.956900142007789;global.__bezier[2220]=0.957021750691748;
global.__bezier[2221]=0.95714314276914;global.__bezier[2222]=0.957264318401678;global.__bezier[2223]=0.957385277751184;global.__bezier[2224]=0.957506020979592;global.__bezier[2225]=0.957626610145272;global.__bezier[2226]=0.957746921538618;global.__bezier[2227]=0.957867079035408;global.__bezier[2228]=0.957987020901691;global.__bezier[2229]=0.958106808879716;global.__bezier[2230]=0.958226319893425;global.__bezier[2231]=0.958345677185869;global.__bezier[2232]=0.958464757997838;global.__bezier[2233]=0.958583685255978;global.__bezier[2234]=0.958702458885814;global.__bezier[2235]=0.958820956603459;global.__bezier[2236]=0.958939239835268;global.__bezier[2237]=0.959057369691005;global.__bezier[2238]=0.959175285229376;global.__bezier[2239]=0.959292986613964;global.__bezier[2240]=0.959410474008458;global.__bezier[2241]=0.959527808206234;global.__bezier[2242]=0.95964486803284;global.__bezier[2243]=0.959761774832225;global.__bezier[2244]=0.959878468138926;global.__bezier[2245]=0.959995008429857;global.__bezier[2246]=0.960111275164756;global.__bezier[2247]=0.960227389054183;global.__bezier[2248]=0.960343229875035;global.__bezier[2249]=0.960458978016857;global.__bezier[2250]=0.960574453419516;
global.__bezier[2251]=0.960689716322837;global.__bezier[2252]=0.960804826649735;global.__bezier[2253]=0.960919724648816;global.__bezier[2254]=0.961034410485262;global.__bezier[2255]=0.961148884324357;global.__bezier[2256]=0.961263146331488;global.__bezier[2257]=0.961377256033708;global.__bezier[2258]=0.961491154076485;global.__bezier[2259]=0.961604840625523;global.__bezier[2260]=0.961718315846627;global.__bezier[2261]=0.961831579905704;global.__bezier[2262]=0.961944691933825;global.__bezier[2263]=0.962057592973432;global.__bezier[2264]=0.962170283190746;global.__bezier[2265]=0.962282762752086;global.__bezier[2266]=0.962395090471636;global.__bezier[2267]=0.962507149141087;global.__bezier[2268]=0.962619056143244;global.__bezier[2269]=0.962730752997078;global.__bezier[2270]=0.962842239869419;global.__bezier[2271]=0.962953575178267;global.__bezier[2272]=0.963064700680888;global.__bezier[2273]=0.963175616544422;global.__bezier[2274]=0.963286322936107;global.__bezier[2275]=0.963396820023279;global.__bezier[2276]=0.96350716582761;global.__bezier[2277]=0.963617302503661;global.__bezier[2278]=0.963727230219076;global.__bezier[2279]=0.963836949141591;global.__bezier[2280]=0.963946459439044;
global.__bezier[2281]=0.964055818736681;global.__bezier[2282]=0.964164969586449;global.__bezier[2283]=0.964273912156486;global.__bezier[2284]=0.964382646615027;global.__bezier[2285]=0.96449123027009;global.__bezier[2286]=0.964599605991602;global.__bezier[2287]=0.964707773948097;global.__bezier[2288]=0.964815734308206;global.__bezier[2289]=0.96492354406263;global.__bezier[2290]=0.965031089656829;global.__bezier[2291]=0.965138484824233;global.__bezier[2292]=0.965245672911887;global.__bezier[2293]=0.965352710593131;global.__bezier[2294]=0.965459484949302;global.__bezier[2295]=0.965566109078694;global.__bezier[2296]=0.965672526646493;global.__bezier[2297]=0.965778794008595;global.__bezier[2298]=0.965884798882372;global.__bezier[2299]=0.965990653730816;global.__bezier[2300]=0.966096302537336;global.__bezier[2301]=0.966201745471821;global.__bezier[2302]=0.966307038493266;global.__bezier[2303]=0.966412070114258;global.__bezier[2304]=0.966516952003499;global.__bezier[2305]=0.966621628542248;global.__bezier[2306]=0.966726155371918;global.__bezier[2307]=0.966830421641382;global.__bezier[2308]=0.966934538383781;global.__bezier[2309]=0.967038505531232;global.__bezier[2310]=0.967142212709938;
global.__bezier[2311]=0.967245770476237;global.__bezier[2312]=0.967349068774594;global.__bezier[2313]=0.967452217843466;global.__bezier[2314]=0.967555217615403;global.__bezier[2315]=0.967657958512264;global.__bezier[2316]=0.967760550295636;global.__bezier[2317]=0.967862938302001;global.__bezier[2318]=0.967965177219596;global.__bezier[2319]=0.96806715810697;global.__bezier[2320]=0.96816899008973;global.__bezier[2321]=0.968270618822894;global.__bezier[2322]=0.968372044478319;global.__bezier[2323]=0.968473321346925;global.__bezier[2324]=0.968574395322653;global.__bezier[2325]=0.968675266577636;global.__bezier[2326]=0.968775935284097;global.__bezier[2327]=0.968876455415017;global.__bezier[2328]=0.968976773182975;global.__bezier[2329]=0.969076888760469;global.__bezier[2330]=0.969176802320084;global.__bezier[2331]=0.9692765675168;global.__bezier[2332]=0.969376077479183;global.__bezier[2333]=0.969475439265107;global.__bezier[2334]=0.969574652808725;global.__bezier[2335]=0.969673611716434;global.__bezier[2336]=0.969772422568784;global.__bezier[2337]=0.969871032295465;global.__bezier[2338]=0.969969493994848;global.__bezier[2339]=0.970067701910581;global.__bezier[2340]=0.970165761986646;
global.__bezier[2341]=0.970263674157725;global.__bezier[2342]=0.970361333145495;global.__bezier[2343]=0.970458844416412;global.__bezier[2344]=0.970556155458133;global.__bezier[2345]=0.970653266444583;global.__bezier[2346]=0.970750177549762;global.__bezier[2347]=0.970846941156113;global.__bezier[2348]=0.970943505070182;global.__bezier[2349]=0.971039869466238;global.__bezier[2350]=0.971136086488013;global.__bezier[2351]=0.971232104181258;global.__bezier[2352]=0.971327922720507;global.__bezier[2353]=0.971423542280377;global.__bezier[2354]=0.971519014686263;global.__bezier[2355]=0.97161428830292;global.__bezier[2356]=0.971709363305224;global.__bezier[2357]=0.971804239868133;global.__bezier[2358]=0.971898969498669;global.__bezier[2359]=0.971993500880624;global.__bezier[2360]=0.972087834189213;global.__bezier[2361]=0.972182020692634;global.__bezier[2362]=0.972276009313989;global.__bezier[2363]=0.972369800228755;global.__bezier[2364]=0.972463393612488;global.__bezier[2365]=0.972556840414899;global.__bezier[2366]=0.972650089878229;global.__bezier[2367]=0.972743142178293;global.__bezier[2368]=0.972835997490977;global.__bezier[2369]=0.972928706447476;global.__bezier[2370]=0.973021218609199;
global.__bezier[2371]=0.97311358444804;global.__bezier[2372]=0.973205703469017;global.__bezier[2373]=0.973297676360192;global.__bezier[2374]=0.973389453002214;global.__bezier[2375]=0.973481083548368;global.__bezier[2376]=0.973572468141868;global.__bezier[2377]=0.973663706833223;global.__bezier[2378]=0.973754799559922;global.__bezier[2379]=0.973845646943885;global.__bezier[2380]=0.973936348557387;global.__bezier[2381]=0.974026854839825;global.__bezier[2382]=0.974117215386804;global.__bezier[2383]=0.974207380797382;global.__bezier[2384]=0.974297351248784;global.__bezier[2385]=0.974387126918306;global.__bezier[2386]=0.974476757082786;global.__bezier[2387]=0.974566143640991;global.__bezier[2388]=0.974655433829532;global.__bezier[2389]=0.974744480766956;global.__bezier[2390]=0.974833382431005;global.__bezier[2391]=0.974922090059547;global.__bezier[2392]=0.975010603830442;global.__bezier[2393]=0.975098972462622;global.__bezier[2394]=0.975187147433537;global.__bezier[2395]=0.975275128921287;global.__bezier[2396]=0.975362965405644;global.__bezier[2397]=0.975450608603677;global.__bezier[2398]=0.97553805869373;global.__bezier[2399]=0.975625315854217;global.__bezier[2400]=0.975712428245994;
global.__bezier[2401]=0.975799347905661;global.__bezier[2402]=0.975886075011869;global.__bezier[2403]=0.975972657486265;global.__bezier[2404]=0.976059047605111;global.__bezier[2405]=0.976145245547297;global.__bezier[2406]=0.97623129899522;global.__bezier[2407]=0.976317160464841;global.__bezier[2408]=0.976402830135289;global.__bezier[2409]=0.976488308185758;global.__bezier[2410]=0.976573641979622;global.__bezier[2411]=0.97665878435247;global.__bezier[2412]=0.976743782508132;global.__bezier[2413]=0.97682854249749;global.__bezier[2414]=0.97691315846907;global.__bezier[2415]=0.976997630362987;global.__bezier[2416]=0.977081864709437;global.__bezier[2417]=0.977165955178076;global.__bezier[2418]=0.977249901709217;global.__bezier[2419]=0.977333611312436;global.__bezier[2420]=0.977417177178448;global.__bezier[2421]=0.977500552942104;global.__bezier[2422]=0.977583785009409;global.__bezier[2423]=0.977666781029152;global.__bezier[2424]=0.977749679619487;global.__bezier[2425]=0.977832342523034;global.__bezier[2426]=0.977914861972524;global.__bezier[2427]=0.977997192082473;global.__bezier[2428]=0.978079333033527;global.__bezier[2429]=0.978161330673063;global.__bezier[2430]=0.978243139355453;
global.__bezier[2431]=0.978324759261565;global.__bezier[2432]=0.978406235999329;global.__bezier[2433]=0.978487524162994;global.__bezier[2434]=0.978568623933655;global.__bezier[2435]=0.978649580679761;global.__bezier[2436]=0.978730349235471;global.__bezier[2437]=0.978810929782099;global.__bezier[2438]=0.978891367448592;global.__bezier[2439]=0.978971617309036;global.__bezier[2440]=0.979051679544971;global.__bezier[2441]=0.979131554337994;global.__bezier[2442]=0.9792112864977;global.__bezier[2443]=0.979290831418099;global.__bezier[2444]=0.979370233749087;global.__bezier[2445]=0.979449449044647;global.__bezier[2446]=0.979528477486753;global.__bezier[2447]=0.97960731925744;global.__bezier[2448]=0.979686018687191;global.__bezier[2449]=0.979764531649965;global.__bezier[2450]=0.97984290231652;global.__bezier[2451]=0.979921086720814;global.__bezier[2452]=0.979999085045254;global.__bezier[2453]=0.980076897472307;global.__bezier[2454]=0.980154567853253;global.__bezier[2455]=0.980232052542084;global.__bezier[2456]=0.980309395230325;global.__bezier[2457]=0.980386552431995;global.__bezier[2458]=0.980463524329929;global.__bezier[2459]=0.980540311107017;global.__bezier[2460]=0.980616956135251;
global.__bezier[2461]=0.980693416248735;global.__bezier[2462]=0.980769734659678;global.__bezier[2463]=0.980845868362234;global.__bezier[2464]=0.980921817539658;global.__bezier[2465]=0.980997582375259;global.__bezier[2466]=0.981073205761665;global.__bezier[2467]=0.981148645013157;global.__bezier[2468]=0.981223942862558;global.__bezier[2469]=0.981299056784219;global.__bezier[2470]=0.98137398696181;global.__bezier[2471]=0.981448733579055;global.__bezier[2472]=0.981523339049149;global.__bezier[2473]=0.981597803316007;global.__bezier[2474]=0.981672042184805;global.__bezier[2475]=0.981746140058345;global.__bezier[2476]=0.981820054971307;global.__bezier[2477]=0.981893828937288;global.__bezier[2478]=0.981967420151065;global.__bezier[2479]=0.98204082879692;global.__bezier[2480]=0.982114096648664;global.__bezier[2481]=0.982187182141256;global.__bezier[2482]=0.982260085459178;global.__bezier[2483]=0.982332848136442;global.__bezier[2484]=0.982405428848201;global.__bezier[2485]=0.982477827779137;global.__bezier[2486]=0.98255008622345;global.__bezier[2487]=0.982622163096495;global.__bezier[2488]=0.982694058583153;global.__bezier[2489]=0.982765813737803;global.__bezier[2490]=0.98283738771601;
global.__bezier[2491]=0.982908821412251;global.__bezier[2492]=0.982980074142251;global.__bezier[2493]=0.983051146091233;global.__bezier[2494]=0.983122037444469;global.__bezier[2495]=0.983192788776622;global.__bezier[2496]=0.983263359723745;global.__bezier[2497]=0.98333379070059;global.__bezier[2498]=0.983404041503376;global.__bezier[2499]=0.983474112317716;global.__bezier[2500]=0.98354404331846;global.__bezier[2501]=0.983613794542109;global.__bezier[2502]=0.983683366174468;global.__bezier[2503]=0.983752798150481;global.__bezier[2504]=0.983822050746936;global.__bezier[2505]=0.983891163738823;global.__bezier[2506]=0.983960097563134;global.__bezier[2507]=0.984028852406004;global.__bezier[2508]=0.984097428453618;global.__bezier[2509]=0.98416586516105;global.__bezier[2510]=0.984234162474473;global.__bezier[2511]=0.984302242122711;global.__bezier[2512]=0.984370182589675;global.__bezier[2513]=0.984437983821723;global.__bezier[2514]=0.984505568028168;global.__bezier[2515]=0.984573013212804;global.__bezier[2516]=0.984640319322173;global.__bezier[2517]=0.984707447674473;global.__bezier[2518]=0.984774398456539;global.__bezier[2519]=0.984841210323511;global.__bezier[2520]=0.98490784483397;
global.__bezier[2521]=0.984974302174936;global.__bezier[2522]=0.98504058253347;global.__bezier[2523]=0.985106762392723;global.__bezier[2524]=0.985172727255709;global.__bezier[2525]=0.985238553525601;global.__bezier[2526]=0.985304203241741;global.__bezier[2527]=0.98536967659151;global.__bezier[2528]=0.985435011510006;global.__bezier[2529]=0.985500207944509;global.__bezier[2530]=0.985565190667408;global.__bezier[2531]=0.985630035121369;global.__bezier[2532]=0.985694741253855;global.__bezier[2533]=0.985759234317905;global.__bezier[2534]=0.985823626543052;global.__bezier[2535]=0.985887806075467;global.__bezier[2536]=0.985951847557308;global.__bezier[2537]=0.986015713909424;global.__bezier[2538]=0.986079442266693;global.__bezier[2539]=0.986142995710247;global.__bezier[2540]=0.98620637442827;global.__bezier[2541]=0.986269615315551;global.__bezier[2542]=0.986332681693665;global.__bezier[2543]=0.98639561029733;global.__bezier[2544]=0.98645836460843;global.__bezier[2545]=0.986520944815454;global.__bezier[2546]=0.986583387412994;global.__bezier[2547]=0.986645656123409;global.__bezier[2548]=0.986707751135361;global.__bezier[2549]=0.986769708703324;global.__bezier[2550]=0.986831492790123;
global.__bezier[2551]=0.986893139490146;global.__bezier[2552]=0.98695461292654;global.__bezier[2553]=0.987015913288265;global.__bezier[2554]=0.98707707642956;global.__bezier[2555]=0.987138066714064;global.__bezier[2556]=0.98719891983591;global.__bezier[2557]=0.987259600319077;global.__bezier[2558]=0.987320108352822;global.__bezier[2559]=0.987380479391099;global.__bezier[2560]=0.987440678198407;global.__bezier[2561]=0.98750070496417;global.__bezier[2562]=0.987560594902175;global.__bezier[2563]=0.987620313017428;global.__bezier[2564]=0.987679894363598;global.__bezier[2565]=0.987739304106037;global.__bezier[2566]=0.987798542434461;global.__bezier[2567]=0.987857644162347;global.__bezier[2568]=0.987916574695575;global.__bezier[2569]=0.987975368687489;global.__bezier[2570]=0.988033991704332;global.__bezier[2571]=0.988092443936106;global.__bezier[2572]=0.98815075979594;global.__bezier[2573]=0.988208905090624;global.__bezier[2574]=0.988266914073138;global.__bezier[2575]=0.988324752710645;global.__bezier[2576]=0.988382421193435;global.__bezier[2577]=0.988439953534251;global.__bezier[2578]=0.988497315940824;global.__bezier[2579]=0.988554542265736;global.__bezier[2580]=0.988611598877102;
global.__bezier[2581]=0.988668485965491;global.__bezier[2582]=0.988725237143233;global.__bezier[2583]=0.988781819019023;global.__bezier[2584]=0.988838265045018;global.__bezier[2585]=0.98889450880902;global.__bezier[2586]=0.988950650045737;global.__bezier[2587]=0.989006622423197;global.__bezier[2588]=0.98906242613237;global.__bezier[2589]=0.989118061364256;global.__bezier[2590]=0.989173561090495;global.__bezier[2591]=0.989228925261764;global.__bezier[2592]=0.98928408858826;global.__bezier[2593]=0.989339149122023;global.__bezier[2594]=0.989394009193531;global.__bezier[2595]=0.989448733994209;global.__bezier[2596]=0.989503323474998;global.__bezier[2597]=0.989557713147869;global.__bezier[2598]=0.989611999862863;global.__bezier[2599]=0.989666087152998;global.__bezier[2600]=0.989720039408447;global.__bezier[2601]=0.989773856580411;global.__bezier[2602]=0.989827506801402;global.__bezier[2603]=0.989880990263199;global.__bezier[2604]=0.989934307157614;global.__bezier[2605]=0.989987520833069;global.__bezier[2606]=0.99004053650623;global.__bezier[2607]=0.990093417445439;global.__bezier[2608]=0.990146132264477;global.__bezier[2609]=0.990198712413059;global.__bezier[2610]=0.990251126665385;
global.__bezier[2611]=0.990303406310944;global.__bezier[2612]=0.990355520284373;global.__bezier[2613]=0.990407468777978;global.__bezier[2614]=0.990459282840905;global.__bezier[2615]=0.990510931648441;global.__bezier[2616]=0.990562446089506;global.__bezier[2617]=0.990613795499824;global.__bezier[2618]=0.990664980071958;global.__bezier[2619]=0.990716030454483;global.__bezier[2620]=0.990766916223772;global.__bezier[2621]=0.990817667868172;global.__bezier[2622]=0.990868255124493;global.__bezier[2623]=0.990918708320833;global.__bezier[2624]=0.990968997354458;global.__bezier[2625]=0.991019122418298;global.__bezier[2626]=0.991069113600081;global.__bezier[2627]=0.991118941037743;global.__bezier[2628]=0.991168634658767;global.__bezier[2629]=0.991218164761539;global.__bezier[2630]=0.991267531539239;global.__bezier[2631]=0.991316764678984;global.__bezier[2632]=0.991365864133523;global.__bezier[2633]=0.991414771188634;global.__bezier[2634]=0.991463574038249;global.__bezier[2635]=0.991512184875267;global.__bezier[2636]=0.991560662319663;global.__bezier[2637]=0.991609006324441;global.__bezier[2638]=0.991657187910035;global.__bezier[2639]=0.99170520727009;global.__bezier[2640]=0.991753093370539;
global.__bezier[2641]=0.991800817472517;global.__bezier[2642]=0.991848379769806;global.__bezier[2643]=0.991895808987958;global.__bezier[2644]=0.991943105080317;global.__bezier[2645]=0.991990239628923;global.__bezier[2646]=0.992037212827773;global.__bezier[2647]=0.99208405308187;global.__bezier[2648]=0.992130732213967;global.__bezier[2649]=0.99217727846879;global.__bezier[2650]=0.992223663829569;global.__bezier[2651]=0.992269888490538;global.__bezier[2652]=0.992315980456009;global.__bezier[2653]=0.99236191194991;global.__bezier[2654]=0.992407710816286;global.__bezier[2655]=0.992453349439527;global.__bezier[2656]=0.9924988555034;global.__bezier[2657]=0.99254420155277;global.__bezier[2658]=0.992589387782212;global.__bezier[2659]=0.99263444163507;global.__bezier[2660]=0.992679363065442;global.__bezier[2661]=0.992724124939144;global.__bezier[2662]=0.992768727450957;global.__bezier[2663]=0.992813170795685;global.__bezier[2664]=0.992857508863711;global.__bezier[2665]=0.992901661066113;global.__bezier[2666]=0.992945681213158;global.__bezier[2667]=0.992989569259276;global.__bezier[2668]=0.99303327210499;global.__bezier[2669]=0.993076869526345;global.__bezier[2670]=0.993120308504134;
global.__bezier[2671]=0.993163589233568;global.__bezier[2672]=0.993206711909884;global.__bezier[2673]=0.993249702854385;global.__bezier[2674]=0.993292562021832;global.__bezier[2675]=0.9933352634014;global.__bezier[2676]=0.993377807188525;global.__bezier[2677]=0.993420219383916;global.__bezier[2678]=0.993462499942502;global.__bezier[2679]=0.993504597529625;global.__bezier[2680]=0.993546563710743;global.__bezier[2681]=0.993588398440945;global.__bezier[2682]=0.993630076271105;global.__bezier[2683]=0.993671622721023;global.__bezier[2684]=0.993713012502076;global.__bezier[2685]=0.993754245810117;global.__bezier[2686]=0.993795347924479;global.__bezier[2687]=0.993836293797271;global.__bezier[2688]=0.993877108547528;global.__bezier[2689]=0.99391776728784;global.__bezier[2690]=0.993958294976937;global.__bezier[2691]=0.9939986668879;global.__bezier[2692]=0.994038883216896;global.__bezier[2693]=0.994078968682201;global.__bezier[2694]=0.994118923239477;global.__bezier[2695]=0.994158722482774;global.__bezier[2696]=0.994198366608452;global.__bezier[2697]=0.994237880014156;global.__bezier[2698]=0.994277238534679;global.__bezier[2699]=0.994316466407359;global.__bezier[2700]=0.994355539627479;
global.__bezier[2701]=0.99439448227206;global.__bezier[2702]=0.994433270496881;global.__bezier[2703]=0.994471904498606;global.__bezier[2704]=0.994510408113791;global.__bezier[2705]=0.994548781298587;global.__bezier[2706]=0.994587000529748;global.__bezier[2707]=0.994625066004125;global.__bezier[2708]=0.994663001237635;global.__bezier[2709]=0.994700782947776;global.__bezier[2710]=0.994738434490154;global.__bezier[2711]=0.994775932742758;global.__bezier[2712]=0.994813300900874;global.__bezier[2713]=0.994850516002987;global.__bezier[2714]=0.994887578246243;global.__bezier[2715]=0.994924510585461;global.__bezier[2716]=0.994961312977275;global.__bezier[2717]=0.99499796278114;global.__bezier[2718]=0.995034460194386;global.__bezier[2719]=0.995070827851193;global.__bezier[2720]=0.995107043351752;global.__bezier[2721]=0.995143129169936;global.__bezier[2722]=0.995179063066421;global.__bezier[2723]=0.995214867354763;global.__bezier[2724]=0.995250519956126;global.__bezier[2725]=0.995286043023747;global.__bezier[2726]=0.995321414639285;global.__bezier[2727]=0.995356635000446;global.__bezier[2728]=0.995391747734995;global.__bezier[2729]=0.995426687655125;global.__bezier[2730]=0.995461498308462;
global.__bezier[2731]=0.995496158177889;global.__bezier[2732]=0.995530688855533;global.__bezier[2733]=0.995565090298748;global.__bezier[2734]=0.995599319997358;global.__bezier[2735]=0.995633441850792;global.__bezier[2736]=0.995667413429144;global.__bezier[2737]=0.995701234930565;global.__bezier[2738]=0.995734906553214;global.__bezier[2739]=0.995768470160892;global.__bezier[2740]=0.995801863212894;global.__bezier[2741]=0.995835127492887;global.__bezier[2742]=0.99586826295862;global.__bezier[2743]=0.995901249055883;global.__bezier[2744]=0.995934085983097;global.__bezier[2745]=0.995966794290324;global.__bezier[2746]=0.995999373935473;global.__bezier[2747]=0.996031804685293;global.__bezier[2748]=0.996064086738377;global.__bezier[2749]=0.996096240324148;global.__bezier[2750]=0.996128265400671;global.__bezier[2751]=0.996160122185289;global.__bezier[2752]=0.996191870487921;global.__bezier[2753]=0.996223450896184;global.__bezier[2754]=0.996254922738902;global.__bezier[2755]=0.996286227084953;global.__bezier[2756]=0.996317422782058;global.__bezier[2757]=0.996348451380369;global.__bezier[2758]=0.996379371246487;global.__bezier[2759]=0.996410124411852;global.__bezier[2760]=0.996440749613335;
global.__bezier[2761]=0.99647124680947;global.__bezier[2762]=0.9965015969706;global.__bezier[2763]=0.996531819203936;global.__bezier[2764]=0.996561894640312;global.__bezier[2765]=0.996591823478998;global.__bezier[2766]=0.996621624586735;global.__bezier[2767]=0.996651297922287;global.__bezier[2768]=0.996680806430384;global.__bezier[2769]=0.996710205831594;global.__bezier[2770]=0.996739459150898;global.__bezier[2771]=0.99676856658781;global.__bezier[2772]=0.996797546528153;global.__bezier[2773]=0.996826380824849;global.__bezier[2774]=0.996855087703426;global.__bezier[2775]=0.99688366712296;global.__bezier[2776]=0.996912083311582;global.__bezier[2777]=0.996940390065544;global.__bezier[2778]=0.996968551693232;global.__bezier[2779]=0.996996568394484;global.__bezier[2780]=0.99702445791388;global.__bezier[2781]=0.997052202746217;global.__bezier[2782]=0.99707982047577;global.__bezier[2783]=0.997107293757799;global.__bezier[2784]=0.997134622792301;global.__bezier[2785]=0.997161842066914;global.__bezier[2786]=0.997188900109796;global.__bezier[2787]=0.997215848311866;global.__bezier[2788]=0.997242635682511;global.__bezier[2789]=0.997269296308551;global.__bezier[2790]=0.997295830149677;
global.__bezier[2791]=0.997322220502943;global.__bezier[2792]=0.997348484151141;global.__bezier[2793]=0.997374604551787;global.__bezier[2794]=0.997400581905268;global.__bezier[2795]=0.997426432753934;global.__bezier[2796]=0.997452157057708;global.__bezier[2797]=0.99747773859498;global.__bezier[2798]=0.997503193667664;global.__bezier[2799]=0.997528506214612;global.__bezier[2800]=0.997553676436438;global.__bezier[2801]=0.997578720394615;global.__bezier[2802]=0.99760363804929;global.__bezier[2803]=0.997628413660191;global.__bezier[2804]=0.99765304742808;global.__bezier[2805]=0.997677555093861;global.__bezier[2806]=0.997701936617834;global.__bezier[2807]=0.997726176580593;global.__bezier[2808]=0.99775027518305;global.__bezier[2809]=0.997774247845541;global.__bezier[2810]=0.99779809452852;global.__bezier[2811]=0.997821800133441;global.__bezier[2812]=0.997845364861365;global.__bezier[2813]=0.997868803812066;global.__bezier[2814]=0.997892116946146;global.__bezier[2815]=0.997915289485919;global.__bezier[2816]=0.997938321632588;global.__bezier[2817]=0.997961228165372;global.__bezier[2818]=0.997984009045024;global.__bezier[2819]=0.998006649814704;global.__bezier[2820]=0.99802915067576;
global.__bezier[2821]=0.998051526086862;global.__bezier[2822]=0.998073776008913;global.__bezier[2823]=0.998095886305909;global.__bezier[2824]=0.998117857179344;global.__bezier[2825]=0.998139702767343;global.__bezier[2826]=0.998161423030962;global.__bezier[2827]=0.998183004155023;global.__bezier[2828]=0.998204446341158;global.__bezier[2829]=0.998225763406965;global.__bezier[2830]=0.998246955313648;global.__bezier[2831]=0.998268008566842;global.__bezier[2832]=0.998288936743746;global.__bezier[2833]=0.998309726510423;global.__bezier[2834]=0.998330378068714;global.__bezier[2835]=0.998350904755418;global.__bezier[2836]=0.998371306531961;global.__bezier[2837]=0.998391570385199;global.__bezier[2838]=0.998411696517107;global.__bezier[2839]=0.998431697943989;global.__bezier[2840]=0.998451574627419;global.__bezier[2841]=0.998471313875025;global.__bezier[2842]=0.998490928462737;global.__bezier[2843]=0.998510405858588;global.__bezier[2844]=0.99852974626476;global.__bezier[2845]=0.998548974550149;global.__bezier[2846]=0.99856805367654;global.__bezier[2847]=0.998587008432726;global.__bezier[2848]=0.998605838780574;global.__bezier[2849]=0.998624532669257;global.__bezier[2850]=0.998643102233734;
global.__bezier[2851]=0.998661535583562;global.__bezier[2852]=0.998679844693454;global.__bezier[2853]=0.99869801783335;global.__bezier[2854]=0.998716066817723;global.__bezier[2855]=0.998733980076888;global.__bezier[2856]=0.998751769265085;global.__bezier[2857]=0.998769422972996;global.__bezier[2858]=0.998786952694636;global.__bezier[2859]=0.998804347181049;global.__bezier[2860]=0.998821617766024;global.__bezier[2861]=0.998838753360966;global.__bezier[2862]=0.998855765139447;global.__bezier[2863]=0.998872653063851;global.__bezier[2864]=0.998889395475648;global.__bezier[2865]=0.998906025009188;global.__bezier[2866]=0.998922520086131;global.__bezier[2867]=0.998938880909445;global.__bezier[2868]=0.99895511817204;global.__bezier[2869]=0.998971231836516;global.__bezier[2870]=0.998987211535879;global.__bezier[2871]=0.999003057473219;global.__bezier[2872]=0.999018780021019;global.__bezier[2873]=0.999034379142025;global.__bezier[2874]=0.999049844789925;global.__bezier[2875]=0.999065177167933;global.__bezier[2876]=0.999080386328132;global.__bezier[2877]=0.999095472233412;global.__bezier[2878]=0.999110425158115;global.__bezier[2879]=0.999125254914032;global.__bezier[2880]=0.999139951935842;
global.__bezier[2881]=0.999154525875135;global.__bezier[2882]=0.999168967326921;global.__bezier[2883]=0.999183285782594;global.__bezier[2884]=0.999197471997489;global.__bezier[2885]=0.999211535302812;global.__bezier[2886]=0.999225466614212;global.__bezier[2887]=0.999239275102717;global.__bezier[2888]=0.999252960731577;global.__bezier[2889]=0.99926651465693;global.__bezier[2890]=0.999279937082478;global.__bezier[2891]=0.999293236858865;global.__bezier[2892]=0.999306405382682;global.__bezier[2893]=0.999319451344418;global.__bezier[2894]=0.99933237470754;global.__bezier[2895]=0.999345167109086;global.__bezier[2896]=0.99935783699928;global.__bezier[2897]=0.999370376175479;global.__bezier[2898]=0.999382784841617;global.__bezier[2899]=0.999395079213671;global.__bezier[2900]=0.999407235237322;global.__bezier[2901]=0.999419276894253;global.__bezier[2902]=0.999431180610895;global.__bezier[2903]=0.999442969888325;global.__bezier[2904]=0.999454621633693;global.__bezier[2905]=0.999466158867499;global.__bezier[2906]=0.999477566422821;global.__bezier[2907]=0.999488844503893;global.__bezier[2908]=0.999500000599981;global.__bezier[2909]=0.999511034675054;global.__bezier[2910]=0.999521939568312;
global.__bezier[2911]=0.999532715484099;global.__bezier[2912]=0.99954336959139;global.__bezier[2913]=0.999553901854294;global.__bezier[2914]=0.999564305432535;global.__bezier[2915]=0.999574587254887;global.__bezier[2916]=0.999584740641346;global.__bezier[2917]=0.999594772360546;global.__bezier[2918]=0.99960467589274;global.__bezier[2919]=0.999614457846435;global.__bezier[2920]=0.999624111862131;global.__bezier[2921]=0.999633644388215;global.__bezier[2922]=0.99964305538908;global.__bezier[2923]=0.999652338745606;global.__bezier[2924]=0.999661494662527;global.__bezier[2925]=0.999670529267978;global.__bezier[2926]=0.999679442526492;global.__bezier[2927]=0.999688228639423;global.__bezier[2928]=0.999696887811611;global.__bezier[2929]=0.999705431454039;global.__bezier[2930]=0.999713842722216;global.__bezier[2931]=0.999722138389976;global.__bezier[2932]=0.999730307456191;global.__bezier[2933]=0.999738350125872;global.__bezier[2934]=0.999746271806669;global.__bezier[2935]=0.999754067340845;global.__bezier[2936]=0.99976174197597;global.__bezier[2937]=0.999769295676924;global.__bezier[2938]=0.999776723526289;global.__bezier[2939]=0.999784025729227;global.__bezier[2940]=0.999791211935331;
global.__bezier[2941]=0.999798267943029;global.__bezier[2942]=0.999805203321882;global.__bezier[2943]=0.999812018036981;global.__bezier[2944]=0.999818712053415;global.__bezier[2945]=0.999825276692634;global.__bezier[2946]=0.999831725125562;global.__bezier[2947]=0.999838048753753;global.__bezier[2948]=0.999844247782637;global.__bezier[2949]=0.999850326419263;global.__bezier[2950]=0.999856284628931;global.__bezier[2951]=0.999862118535487;global.__bezier[2952]=0.999867832105885;global.__bezier[2953]=0.999873421624163;global.__bezier[2954]=0.999878890897211;global.__bezier[2955]=0.999884236369239;global.__bezier[2956]=0.999889461687086;global.__bezier[2957]=0.999894563455123;global.__bezier[2958]=0.999899545160151;global.__bezier[2959]=0.999904406767746;global.__bezier[2960]=0.999909145122524;global.__bezier[2961]=0.999913760430265;global.__bezier[2962]=0.999918258818594;global.__bezier[2963]=0.999922631370507;global.__bezier[2964]=0.999926886934431;global.__bezier[2965]=0.999931017073709;global.__bezier[2966]=0.999935030156561;global.__bezier[2967]=0.999938920787318;global.__bezier[2968]=0.999942689171965;global.__bezier[2969]=0.999946337917106;global.__bezier[2970]=0.999949866988658;
global.__bezier[2971]=0.999953274112044;global.__bezier[2972]=0.999956559493341;global.__bezier[2973]=0.999959727499601;global.__bezier[2974]=0.999962771855458;global.__bezier[2975]=0.999965698768388;global.__bezier[2976]=0.999968504283645;global.__bezier[2977]=0.999971188607463;global.__bezier[2978]=0.999973753626394;global.__bezier[2979]=0.999976199306628;global.__bezier[2980]=0.999978524094135;global.__bezier[2981]=0.999980728195233;global.__bezier[2982]=0.999982814536712;global.__bezier[2983]=0.999984779004233;global.__bezier[2984]=0.999986625644788;global.__bezier[2985]=0.999988351944376;global.__bezier[2986]=0.999989958109468;global.__bezier[2987]=0.999991445306657;global.__bezier[2988]=0.999992813502405;global.__bezier[2989]=0.999994061863127;global.__bezier[2990]=0.999995190595376;global.__bezier[2991]=0.999996201185878;global.__bezier[2992]=0.999997091681013;global.__bezier[2993]=0.999997863967596;global.__bezier[2994]=0.999998516972157;global.__bezier[2995]=0.999999050901399;global.__bezier[2996]=0.999999466202061;global.__bezier[2997]=0.999999762840876;global.__bezier[2998]=0.999999940704586;global.__bezier[2999]=1;
#define XWindow_destroy
ds_stack_push(global.__winstack, argument0);
#define XWindow_copy
//XWindow_copy(to, from)
var _i;
for(_i = 1; _i <= 106; _i += 1)
{
    if(_i == XWindow_hashname("animate")) continue;
    if(_i >= 74 && _i <= 93) continue;
    if(_i == 59) continue;
    //if(_i == XWindow_hashname("animate")) continue;
    //if(_i == XWindow_hashname("animate")) continue;
    //if(_i == XWindow_hashname("animate")) continue;
    global.__winel[argument0, _i] = global.__winel[argument1, _i];
}
#define XWindow_create
var _el;
if(ds_stack_size(global.__winstack) > 0)
{
    _el = ds_stack_pop(global.__winstack);
}else{
    _el = global.__wincounter;
    global.__wincounter += 1;
}

if(argument0 != -1)
{
    global.__winel[_el, 0] = ds_list_create();//Element name: "children"
}else{
    global.__winel[_el, 0] = -1;//Element name: "children"
}

global.__winel[_el, 106] = 65535;//Element name: "render-max-height"
global.__winel[_el, 1] = 0;//Element name: "x1"
global.__winel[_el, 2] = 0;//Element name: "y1"
global.__winel[_el, 3] = 0;//Element name: "x2"
global.__winel[_el, 4] = 0;//Element name: "y2"
global.__winel[_el, 5] = 0;//Element name: "margin-left"
global.__winel[_el, 6] = 0;//Element name: "margin-right"
global.__winel[_el, 7] = 0;//Element name: "margin-top"
global.__winel[_el, 8] = 0;//Element name: "margin-bottom"
global.__winel[_el, 9] = 0;//Element name: "x-offset"
global.__winel[_el, 10] = 0;//Element name: "y-offset"
global.__winel[_el, 11] = 0;//Element name: "content-w"
global.__winel[_el, 12] = 0;//Element name: "content-h"
global.__winel[_el, 13] = sz_min;//Element name: "width"
global.__winel[_el, 14] = sz_min;//Element name: "height"
global.__winel[_el, 15] = "";//Element name: "name"
global.__winel[_el, 16] = 0;//Element name: "effective-w"
global.__winel[_el, 17] = 0;//Element name: "effective-h"
global.__winel[_el, 18] = 0;//Element name: "vertical-float"
global.__winel[_el, 19] = 0;//Element name: "horizontal-float"
global.__winel[_el, 20] = c_white;//Element name: "background-1"
global.__winel[_el, 21] = c_white;//Element name: "background-2"
global.__winel[_el, 22] = c_white;//Element name: "background-3"
global.__winel[_el, 23] = c_white;//Element name: "background-4"
global.__winel[_el, 24] = -1;//Element name: "background-alpha"
global.__winel[_el, 25] = 0;//Element name: "border-size"
global.__winel[_el, 26] = c_black;//Element name: "border-color"
global.__winel[_el, 27] = 0;//Element name: "drop-shadow"
global.__winel[_el, 28] = 0.03;//Element name: "drop-shadow-intensity"
global.__winel[_el, 29] = c_black;//Element name: "drop-shadow-color"
global.__winel[_el, 30] = 9;//Element name: "drop-shadow-spread"
global.__winel[_el, 31] = 1;//Element name: "alpha"
global.__winel[_el, 32] = 0;//Element name: "overlapping"
global.__winel[_el, 33] = c_black;//Element name: "color"
global.__winel[_el, 34] = argument0;//Element name: "element-type"
global.__winel[_el, 35] = false;//Element name: "tween-affects-position"
global.__winel[_el, 36] = false;//Element name: "tween"
global.__winel[_el, 37] = -1;//Element name: "tween_from"
global.__winel[_el, 38] = -1;//Element name: "tween_to"
global.__winel[_el, 39] = 0;//Element name: "tween_proc"
global.__winel[_el, 40] = 0;//Element name: "tween_speed"
global.__winel[_el, 41] = 0;//Element name: "tween_transform"
global.__winel[_el, 42] = 0.033;//Element name: "tween-speed"
global.__winel[_el, 43] = -1;//Element name: "on-hover"
global.__winel[_el, 44] = -1;//Element name: "on-unhover"
global.__winel[_el, 45] = -1;//Element name: "on-open"
global.__winel[_el, 46] = -1;//Element name: "on-close"
global.__winel[_el, 47] = -1;//Element name: "on-special"
global.__winel[_el, 48] = -1;//Element name: "on-unspecial"
global.__winel[_el, 49] = -1;//Element name: "on-extrawindow"
global.__winel[_el, 50] = -1;//Element name: "on-unextrawindow"
global.__winel[_el, 51] = -1;//Element name: "on-error"
global.__winel[_el, 52] = -1;//Element name: "last-perform"
global.__winel[_el, 53] = "";//Element name: "tag-name"
global.__winel[_el, 54] = false;//Element name: "elastic"
global.__winel[_el, 55] = 100;//Element name: "preferred-width"
global.__winel[_el, 56] = 100;//Element name: "preferred-height"
global.__winel[_el, 57] = 10;//Element name: "min-width"
global.__winel[_el, 58] = 10;//Element name: "min-height"
global.__winel[_el, 59] = 0;//Element name: "mouse-hover"
global.__winel[_el, 60] = 0;//Element name: "animation"
global.__winel[_el, 61] = 0;//Element name: "text-wrapping"
global.__winel[_el, 62] = "";//Element name: "text"
global.__winel[_el, 63] = -1;//Element name: "font"
global.__winel[_el, 64] = 0;//Element name: "padding-horizontal"
global.__winel[_el, 65] = 0;//Element name: "padding-vertical"
global.__winel[_el, 66] = 0;//Element name: "show-close"
global.__winel[_el, 67] = .5;//Element name: "show-close-height"
global.__winel[_el, 68] = c_black;//Element name: "show-close-color"
global.__winel[_el, 69] = 0;//Element name: "do-expect"
global.__winel[_el, 70] = 10;//Element name: "arrow-size"
global.__winel[_el, 71] = 10;//Element name: "arrow-length"
global.__winel[_el, 72] = false;//Element name: "center"
global.__winel[_el, 73] = 0;//Element name: "disable-events"
global.__winel[_el, 74] = 1;//Element name: "select1"
global.__winel[_el, 75] = 1;//Element name: "select2"
global.__winel[_el, 76] = c_blue;//Element name: "select-color"
global.__winel[_el, 77] = false;//Element name: "allow-spaces"
global.__winel[_el, 78] = false;//Element name: "password"
global.__winel[_el, 79] = 64;//Element name: "length-limit"
global.__winel[_el, 80] = false;//Element name: "rp-left"
global.__winel[_el, 81] = false;//Element name: "rp-right"
global.__winel[_el, 82] = false;//Element name: "rp-backspace"
global.__winel[_el, 83] = false;//Element name: "rp-delete"
global.__winel[_el, 84] = 20;//Element name: "rp-speed"
global.__winel[_el, 85] = 3;//Element name: "rp-speed2"
global.__winel[_el, 86] = 0;//Element name: "rp-left-count"
global.__winel[_el, 87] = 0;//Element name: "rp-right-count"
global.__winel[_el, 88] = 0;//Element name: "rp-backspace-count"
global.__winel[_el, 89] = 0;//Element name: "rp-delete-count"
global.__winel[_el, 90] = "";//Element name: "tip-text"
global.__winel[_el, 91] = c_ltgray;//Element name: "tip-color"
global.__winel[_el, 92] = -1;//Element name: "next-tab"
global.__winel[_el, 93] = -1;//Element name: "next-enter"
global.__winel[_el, 94] = -1;//Element name: "surface"
global.__winel[_el, 95] = 0;//Element name: "scroll"
global.__winel[_el, 96] = 0;//Element name: "momentum"
global.__winel[_el, 97] = false;//Element name: "drag-scroll"
global.__winel[_el, 98] = false;//Element name: "drag-canvas"
global.__winel[_el, 99] = 0;//Element name: "drag-y"
global.__winel[_el, 100] = 1;//Element name: "content-changed"
global.__winel[_el, 101] = 1;//Element name: "scrollbar-height"
global.__winel[_el, 102] = 1;//Element name: "tween-type"
global.__winel[_el, 103] = 0;//Element name: "render-min-width"
global.__winel[_el, 104] = 65536;//Element name: "render-max-width"
global.__winel[_el, 105] = 0;//Element name: "render-min-height"
global.__winel[_el, 107] = -1;//Element name: "child-cache" -1 => Does not exist

global.__windows_made += 1;

return _el;
#define XServer_variable_local_get
switch(argument0){case 'timeline_index':return timeline_index;case 'timeline_position':return timeline_position;case 'timeline_speed':return timeline_speed;case 'room':return room;case 'room_first':return room_first;case 'room_last':return room_last;case 'room_width':return room_width;case 'room_height':return room_height;case 'room_caption':return room_caption;case 'room_persistent':return room_persistent;case 'score':return score;case 'lives':return lives;case 'health':return health;case 'show_score':return show_score;case 'show_lives':return show_lives;case 'show_health':return show_health;case 'caption_score':return caption_score;case 'caption_lives':return caption_lives;case 'caption_health':return caption_health;case 'event_type':return event_type;case 'event_number':return event_number;case 'event_object':return event_object;case 'event_action':return event_action;case 'error_occurred':return error_occurred;case 'error_last':return error_last;case 'keyboard_key':return keyboard_key;case 'keyboard_lastkey':return keyboard_lastkey;case 'keyboard_lastchar':return keyboard_lastchar;case 'keyboard_string':return keyboard_string;case 'mouse_x':return mouse_x;case 'mouse_y':return mouse_y;case 'mouse_button':return mouse_button;case 'mouse_lastbutton':return mouse_lastbutton;case 'cursor_sprite':return cursor_sprite;case 'visible':return visible;case 'sprite_index':return sprite_index;case 'sprite_width':return sprite_width;case 'sprite_height':return sprite_height;case 'sprite_xoffset':return sprite_xoffset;case 'sprite_yoffset':return sprite_yoffset;case 'image_number':return image_number;case 'image_index':return image_index;case 'image_speed':return image_speed;case 'depth':return depth;case 'image_xscale':return image_xscale;case 'image_yscale':return image_yscale;case 'image_angle':return image_angle;case 'image_alpha':return image_alpha;case 'image_blend':return image_blend;case 'bbox_left':return bbox_left;case 'bbox_right':return bbox_right;case 'bbox_top':return bbox_top;case 'bbox_bottom':return bbox_bottom;case 'background_color':return background_color;case 'background_showcolor':return background_showcolor;case 'background_visible':return background_visible;case 'background_foreground':return background_foreground;case 'background_index':return background_index;case 'background_x':return background_x;case 'background_y':return background_y;case 'background_width':return background_width;case 'background_height':return background_height;case 'background_htiled':return background_htiled;case 'background_vtiled':return background_vtiled;case 'background_xscale':return background_xscale;case 'background_yscale':return background_yscale;case 'background_hspeed':return background_hspeed;case 'background_vspeed':return background_vspeed;case 'background_blend':return background_blend;case 'background_alpha':return background_alpha;case 'view_enabled':return view_enabled;case 'view_current':return view_current;case 'view_visible':return view_visible;case 'view_xview':return view_xview;case 'view_yview':return view_yview;case 'view_wview':return view_wview;case 'view_hview':return view_hview;case 'view_xport':return view_xport;case 'view_yport':return view_yport;case 'view_wport':return view_wport;case 'view_hport':return view_hport;case 'view_angle':return view_angle;case 'view_hborder':return view_hborder;case 'view_vborder':return view_vborder;case 'view_hspeed':return view_hspeed;case 'view_vspeed':return view_vspeed;case 'view_object':return view_object;case 'working_directory':return working_directory;case 'temp_directory':return temp_directory;case 'program_directory':return program_directory;case 'game_id':return game_id;case 'secure_mode':return secure_mode;case 'x':return x;case 'y':return y;case 'async_load':return async_load;}
#define XServer_variable_local_set
switch(argument0){case 'timeline_index':timeline_index = argument1;break;case 'timeline_position':timeline_position = argument1;break;case 'timeline_speed':timeline_speed = argument1;break;case 'visible':visible = argument1;break;case 'sprite_index':sprite_index = argument1;break;case 'image_index':image_index = argument1;break;case 'image_speed':image_speed = argument1;break;case 'depth':depth = argument1;break;case 'image_xscale':image_xscale = argument1;break;case 'image_yscale':image_yscale = argument1;break;case 'image_angle':image_angle = argument1;break;case 'image_alpha':image_alpha = argument1;break;case 'image_blend':image_blend = argument1;break;case 'x':x = argument1;break;case 'y':y = argument1;break;}
#define XServer_sleep

#define XServer_sound_replace
argument0 = argument1;
argument2 = argument3;
return 1;
#define XServer_execute_shell

#define XServer_sound_get_kind

#define XServer_screen_capture
global.__screen_capture = -10000;
#define XServer_sound_get_preload
return argument0 == -10;
#define gms_sha512
var _;for(var i=750;i>351;i--){_[i]=$0000}_[0]=$428a;_[1]=$2f98;_[2]=$d728;_[3]=$ae22;_[4]=$7137;_[5]=$4491;_[6]=$23ef;_[7]=$65cd;_[8]=$b5c0;_[9]=$fbcf;_[10]=$ec4d;_[11]=$3b2f;_[12]=$e9b5;_[13]=$dba5;_[14]=$8189;_[15]=$dbbc;_[16]=$3956;_[17]=$c25b;_[18]=$f348;_[19]=$b538;_[20]=$59f1;_[21]=$11f1;_[22]=$b605;_[23]=$d019;_[24]=$923f;_[25]=$82a4;_[26]=$af19;_[27]=$4f9b;_[28]=$ab1c;_[29]=$5ed5;_[30]=$da6d;_[31]=$8118;_[32]=$d807;_[33]=$aa98;_[34]=$a303;_[35]=$0242;_[36]=$1283;_[37]=$5b01;_[38]=$4570;_[39]=$6fbe;_[40]=$2431;_[41]=$85be;_[42]=$4ee4;_[43]=$b28c;_[44]=$550c;_[45]=$7dc3;_[46]=$d5ff;_[47]=$b4e2;_[48]=$72be;_[49]=$5d74;_[50]=$f27b;_[51]=$896f;_[52]=$80de;_[53]=$b1fe;_[54]=$3b16;_[55]=$96b1;_[56]=$9bdc;_[57]=$06a7;_[58]=$25c7;_[59]=$1235;_[60]=$c19b;_[61]=$f174;_[62]=$cf69;_[63]=$2694;_[64]=$e49b;_[65]=$69c1;_[66]=$9ef1;_[67]=$4ad2;_[68]=$efbe;_[69]=$4786;_[70]=$384f;_[71]=$25e3;_[72]=$0fc1;_[73]=$9dc6;_[74]=$8b8c;_[75]=$d5b5;_[76]=$240c;_[77]=$a1cc;_[78]=$77ac;_[79]=$9c65;_[80]=$2de9;_[81]=$2c6f;_[82]=$592b;_[83]=$0275;_[84]=$4a74;_[85]=$84aa;_[86]=$6ea6;_[87]=$e483;_[88]=$5cb0;_[89]=$a9dc;_[90]=$bd41;_[91]=$fbd4;_[92]=$76f9;_[93]=$88da;_[94]=$8311;_[95]=$53b5;_[96]=$983e;_[97]=$5152;_[98]=$ee66;_[99]=$dfab;_[100]=$a831;_[101]=$c66d;_[102]=$2db4;_[103]=$3210;_[104]=$b003;_[105]=$27c8;_[106]=$98fb;_[107]=$213f;_[108]=$bf59;_[109]=$7fc7;_[110]=$beef;_[111]=$0ee4;_[112]=$c6e0;_[113]=$0bf3;_[114]=$3da8;_[115]=$8fc2;_[116]=$d5a7;_[117]=$9147;_[118]=$930a;_[119]=$a725;_[120]=$06ca;_[121]=$6351;_[122]=$e003;_[123]=$826f;_[124]=$1429;_[125]=$2967;_[126]=$0a0e;_[127]=$6e70;_[128]=$27b7;_[129]=$0a85;_[130]=$46d2;_[131]=$2ffc;_[132]=$2e1b;_[133]=$2138;_[134]=$5c26;_[135]=$c926;_[136]=$4d2c;_[137]=$6dfc;_[138]=$5ac4;_[139]=$2aed;_[140]=$5338;_[141]=$0d13;_[142]=$9d95;_[143]=$b3df;_[144]=$650a;_[145]=$7354;_[146]=$8baf;_[147]=$63de;_[148]=$766a;_[149]=$0abb;_[150]=$3c77;_[151]=$b2a8;_[152]=$81c2;_[153]=$c92e;_[154]=$47ed;_[155]=$aee6;_[156]=$9272;_[157]=$2c85;_[158]=$1482;_[159]=$353b;_[160]=$a2bf;_[161]=$e8a1;_[162]=$4cf1;_[163]=$0364;_[164]=$a81a;_[165]=$664b;_[166]=$bc42;_[167]=$3001;_[168]=$c24b;_[169]=$8b70;_[170]=$d0f8;_[171]=$9791;_[172]=$c76c;_[173]=$51a3;_[174]=$0654;_[175]=$be30;_[176]=$d192;_[177]=$e819;_[178]=$d6ef;_[179]=$5218;_[180]=$d699;_[181]=$0624;_[182]=$5565;_[183]=$a910;_[184]=$f40e;_[185]=$3585;_[186]=$5771;_[187]=$202a;_[188]=$106a;_[189]=$a070;_[190]=$32bb;_[191]=$d1b8;_[192]=$19a4;_[193]=$c116;_[194]=$b8d2;_[195]=$d0c8;_[196]=$1e37;_[197]=$6c08;_[198]=$5141;_[199]=$ab53;_[200]=$2748;_[201]=$774c;_[202]=$df8e;_[203]=$eb99;_[204]=$34b0;_[205]=$bcb5;_[206]=$e19b;_[207]=$48a8;_[208]=$391c;_[209]=$0cb3;_[210]=$c5c9;_[211]=$5a63;_[212]=$4ed8;_[213]=$aa4a;_[214]=$e341;_[215]=$8acb;_[216]=$5b9c;_[217]=$ca4f;_[218]=$7763;_[219]=$e373;_[220]=$682e;_[221]=$6ff3;_[222]=$d6b2;_[223]=$b8a3;_[224]=$748f;_[225]=$82ee;_[226]=$5def;_[227]=$b2fc;_[228]=$78a5;_[229]=$636f;_[230]=$4317;_[231]=$2f60;_[232]=$84c8;_[233]=$7814;_[234]=$a1f0;_[235]=$ab72;_[236]=$8cc7;_[237]=$0208;_[238]=$1a64;_[239]=$39ec;_[240]=$90be;_[241]=$fffa;_[242]=$2363;_[243]=$1e28;_[244]=$a450;_[245]=$6ceb;_[246]=$de82;_[247]=$bde9;_[248]=$bef9;_[249]=$a3f7;_[250]=$b2c6;_[251]=$7915;_[252]=$c671;_[253]=$78f2;_[254]=$e372;_[255]=$532b;_[256]=$ca27;_[257]=$3ece;_[258]=$ea26;_[259]=$619c;_[260]=$d186;_[261]=$b8c7;_[262]=$21c0;_[263]=$c207;_[264]=$eada;_[265]=$7dd6;_[266]=$cde0;_[267]=$eb1e;_[268]=$f57d;_[269]=$4f7f;_[270]=$ee6e;_[271]=$d178;_[272]=$06f0;_[273]=$67aa;_[274]=$7217;_[275]=$6fba;_[276]=$0a63;_[277]=$7dc5;_[278]=$a2c8;_[279]=$98a6;_[280]=$113f;_[281]=$9804;_[282]=$bef9;_[283]=$0dae;_[284]=$1b71;_[285]=$0b35;_[286]=$131c;_[287]=$471b;_[288]=$28db;_[289]=$77f5;_[290]=$2304;_[291]=$7d84;_[292]=$32ca;_[293]=$ab7b;_[294]=$40c7;_[295]=$2493;_[296]=$3c9e;_[297]=$be0a;_[298]=$15c9;_[299]=$bebc;_[300]=$431d;_[301]=$67c4;_[302]=$9c10;_[303]=$0d4c;_[304]=$4cc5;_[305]=$d4be;_[306]=$cb3e;_[307]=$42b6;_[308]=$597f;_[309]=$299c;_[310]=$fc65;_[311]=$7e2a;_[312]=$5fcb;_[313]=$6fab;_[314]=$3ad6;_[315]=$faec;_[316]=$6c44;_[317]=$198c;_[318]=$4a47;_[319]=$5817;_[320]=$6a09;_[321]=$e667;_[322]=$f3bc;_[323]=$c908;_[324]=$bb67;_[325]=$ae85;_[326]=$84ca;_[327]=$a73b;_[328]=$3c6e;_[329]=$f372;_[330]=$fe94;_[331]=$f82b;_[332]=$a54f;_[333]=$f53a;_[334]=$5f1d;_[335]=$36f1;_[336]=$510e;_[337]=$527f;_[338]=$ade6;_[339]=$82d1;_[340]=$9b05;_[341]=$688c;_[342]=$2b3e;_[343]=$6c1f;_[344]=$1f83;_[345]=$d9ab;_[346]=$fb41;_[347]=$bd6b;_[348]=$5be0;_[349]=$cd19;_[350]=$137e;_[351]=$2179;var bitlength=string_length(argument0)*8,binb,add1,add2,add3,add4,binb;for(var i=0;i<string_length(argument0);i++){if(i%2==0){binb[i/2]=(ord(string_char_at(argument0,i+1))&$ff)<<8}else{binb[i/2]|=ord(string_char_at(argument0,i+1))&$ff}}if(i%2==0){binb[i/2]=$80<<8}else{binb[i/2]|=$80}var binb_length=((((bitlength+128)>>10)+1)<<6);binb[binb_length-1]=bitlength&$ffff;binb[binb_length-2]=(bitlength>>16)&$ffff;for(var i=0;i<(binb_length/2);i+=32){_[360]=_[320];_[361]=_[321];_[362]=_[322];_[363]=_[323];_[364]=_[324];_[364+1]=_[325];_[364+2]=_[326];_[364+3]=_[327];_[368]=_[328];_[368+1]=_[329];_[368+2]=_[330];_[368+3]=_[331];_[372]=_[332];_[372+1]=_[333];_[372+2]=_[334];_[372+3]=_[335];_[376]=_[336];_[376+1]=_[337];_[376+2]=_[338];_[376+3]=_[339];_[380]=_[340];_[380+1]=_[341];_[380+2]=_[342];_[380+3]=_[343];_[384]=_[344];_[384+1]=_[345];_[384+2]=_[346];_[384+3]=_[347];_[388]=_[348];_[388+1]=_[349];_[388+2]=_[350];_[388+3]=_[351];for(var j=0;j<16;j++){_[(420+(j)*4)]=binb[(i+2*j)*2];_[(420+(j)*4)+1]=binb[(i+2*j)*2+1];_[(420+(j)*4)+2]=binb[(i+2*j+1)*2];_[(420+(j)*4)+3]=binb[(i+2*j+1)*2+1]}for(var j=16;j<80;j++){add2=(420+(j-2)*4)add1=_[add2+3];_[411]=_[add2+2]_[410]=_[add2+1]_[409]=_[add2+0]_[408]=add1 add1=_[411];_[411]=(_[411]>>3)|((_[410]<<13)&$ffff)_[410]=(_[410]>>3)|((_[409]<<13)&$ffff)_[409]=(_[409]>>3)|((_[408]<<13)&$ffff)_[408]=(_[408]>>3)|((add1<<13)&$ffff)add2=(420+(j-2)*4);add1=_[add2+0];_[412]=_[add2+1]_[413]=_[add2+2]_[414]=_[add2+3]_[415]=add1 add1=_[415];_[415]=(_[415]>>13)|((_[414]<<3)&$ffff)_[414]=(_[414]>>13)|((_[413]<<3)&$ffff)_[413]=(_[413]>>13)|((_[412]<<3)&$ffff)_[412]=(_[412]>>13)|((add1<<3)&$ffff)_[419]=(_[add2+3]>>6)|((_[add2+2]<<10)&$ffff)_[418]=(_[add2+2]>>6)|((_[add2+1]<<10)&$ffff)_[417]=(_[add2+1]>>6)|((_[add2+0]<<10)&$ffff)_[416]=(_[add2+0]>>6)_[396]=_[408]^_[412]^_[416];_[397]=_[409]^_[413]^_[417];_[398]=_[410]^_[414]^_[418];_[399]=_[411]^_[415]^_[419];add2=(420+(j-15)*4);add1=_[add2+3];_[411]=(_[add2+3]>>1)|((_[add2+2]<<15)&$ffff)_[410]=(_[add2+2]>>1)|((_[add2+1]<<15)&$ffff)_[409]=(_[add2+1]>>1)|((_[add2+0]<<15)&$ffff)_[408]=(_[add2+0]>>1)|((add1<<15)&$ffff)add1=_[add2+3];_[415]=(_[add2+3]>>8)|((_[add2+2]<<8)&$ffff)_[414]=(_[add2+2]>>8)|((_[add2+1]<<8)&$ffff)_[413]=(_[add2+1]>>8)|((_[add2+0]<<8)&$ffff)_[412]=(_[add2+0]>>8)|((add1<<8)&$ffff)_[419]=(_[add2+3]>>7)|((_[add2+2]<<9)&$ffff)_[418]=(_[add2+2]>>7)|((_[add2+1]<<9)&$ffff)_[417]=(_[add2+1]>>7)|((_[add2+0]<<9)&$ffff)_[416]=(_[add2+0]>>7)_[392]=_[408]^_[412]^_[416];_[393]=_[409]^_[413]^_[417];_[394]=_[410]^_[414]^_[418];_[395]=_[411]^_[415]^_[419];add1=_[399]+_[(420+(j-7)*4)+3]+_[395]+_[(420+(j-16)*4)+3];add2=_[398]+_[(420+(j-7)*4)+2]+_[394]+_[(420+(j-16)*4)+2]+(add1>>16);add3=_[397]+_[(420+(j-7)*4)+1]+_[393]+_[(420+(j-16)*4)+1]+(add2>>16);add4=_[396]+_[(420+(j-7)*4)]+_[392]+_[(420+(j-16)*4)]+(add3>>16);_[(420+(j)*4)+3]=add1&$00ffff;_[(420+(j)*4)+2]=add2&$00ffff;_[(420+(j)*4)+1]=add3&$00ffff;_[(420+(j)*4)]=add4&$00ffff}for(var j=0;j<80;j++){_[403]=(_[376+3]&_[380+3])^(~_[376+3]&_[384+3]);_[402]=(_[376+2]&_[380+2])^(~_[376+2]&_[384+2]);_[401]=(_[376+1]&_[380+1])^(~_[376+1]&_[384+1]);_[400]=(_[376]&_[380])^(~_[376]&_[384]);add1=_[379];_[411]=(_[379]>>14)|((_[378]<<2)&$ffff)_[410]=(_[378]>>14)|((_[377]<<2)&$ffff)_[409]=(_[377]>>14)|((_[376]<<2)&$ffff)_[408]=(_[376]>>14)|((add1<<2)&$ffff)add1=_[379];_[415]=_[378]_[414]=_[377]_[413]=_[376]_[412]=add1 add1=_[415];_[415]=(_[415]>>2)|((_[414]<<14)&$ffff)_[414]=(_[414]>>2)|((_[413]<<14)&$ffff)_[413]=(_[413]>>2)|((_[412]<<14)&$ffff)_[412]=(_[412]>>2)|((add1<<14)&$ffff)add1=_[377];add2=_[378];_[417]=_[379]_[418]=_[376]_[419]=add1;_[416]=add2;add1=_[419];_[419]=(_[419]>>9)|((_[418]<<7)&$ffff)_[418]=(_[418]>>9)|((_[417]<<7)&$ffff)_[417]=(_[417]>>9)|((_[416]<<7)&$ffff)_[416]=(_[416]>>9)|((add1<<7)&$ffff)_[396]=_[408]^_[412]^_[416];_[397]=_[409]^_[413]^_[417];_[398]=_[410]^_[414]^_[418];_[399]=_[411]^_[415]^_[419];add1=_[363];_[411]=(_[363]>>12)|((_[362]<<4)&$ffff)_[410]=(_[362]>>12)|((_[361]<<4)&$ffff)_[409]=(_[361]>>12)|((_[360]<<4)&$ffff)_[408]=(_[360]>>12)|((add1<<4)&$ffff)add1=_[411];_[411]=_[410]_[410]=_[409]_[409]=_[408]_[408]=add1 add1=_[361];add2=_[362];_[413]=_[363]_[414]=_[360]_[415]=add1 _[412]=add2 add1=_[415];_[415]=(_[415]>>2)|((_[414]<<14)&$ffff)_[414]=(_[414]>>2)|((_[413]<<14)&$ffff)_[413]=(_[413]>>2)|((_[412]<<14)&$ffff)_[412]=(_[412]>>2)|((add1<<14)&$ffff)add1=_[361];add2=_[362];_[417]=_[363]_[418]=_[360]_[419]=add1 _[416]=add2 add1=_[419];_[419]=(_[419]>>7)|((_[418]<<9)&$ffff)_[418]=(_[418]>>7)|((_[417]<<9)&$ffff)_[417]=(_[417]>>7)|((_[416]<<9)&$ffff)_[416]=(_[416]>>7)|((add1<<9)&$ffff)_[392]=_[408]^_[412]^_[416];_[393]=_[409]^_[413]^_[417];_[394]=_[410]^_[414]^_[418];_[395]=_[411]^_[415]^_[419];_[407]=(_[363]&_[364+3])^(_[363]&_[368+3])^(_[364+3]&_[368+3]);_[406]=(_[362]&_[364+2])^(_[362]&_[368+2])^(_[364+2]&_[368+2]);_[405]=(_[361]&_[364+1])^(_[361]&_[368+1])^(_[364+1]&_[368+1]);_[404]=(_[360]&_[364])^(_[360]&_[368])^(_[364]&_[368]);add1=_[391]+_[399]+_[403]+_[j*4+3]+_[(420+(j)*4)+3];add2=_[390]+_[398]+_[402]+_[j*4+2]+_[(420+(j)*4)+2]+(add1>>16);add3=_[389]+_[397]+_[401]+_[j*4+1]+_[(420+(j)*4)+1]+(add2>>16);add4=_[388]+_[396]+_[400]+_[j*4]+_[(420+(j)*4)]+(add3>>16);_[355]=add1&$00ffff;_[354]=add2&$00ffff;_[353]=add3&$00ffff;_[352]=add4&$00ffff;add1=_[395]+_[407];add2=_[394]+_[406]+(add1>>16);add3=_[393]+_[405]+(add2>>16);add4=_[392]+_[404]+(add3>>16);_[359]=add1&$00ffff;_[358]=add2&$00ffff;_[357]=add3&$00ffff;_[356]=add4&$00ffff;_[388]=_[384];_[388+1]=_[384+1];_[388+2]=_[384+2];_[388+3]=_[384+3];_[384]=_[380];_[384+1]=_[380+1];_[384+2]=_[380+2];_[384+3]=_[380+3];_[380]=_[376];_[380+1]=_[376+1];_[380+2]=_[376+2];_[380+3]=_[376+3];add1=_[375]+_[355];add2=_[374]+_[354]+(add1>>16);add3=_[373]+_[353]+(add2>>16);add4=_[372]+_[352]+(add3>>16);_[379]=add1&$00ffff;_[378]=add2&$00ffff;_[377]=add3&$00ffff;_[376]=add4&$00ffff;_[372]=_[368];_[372+1]=_[368+1];_[372+2]=_[368+2];_[372+3]=_[368+3];_[368]=_[364];_[368+1]=_[364+1];_[368+2]=_[364+2];_[368+3]=_[364+3];_[364]=_[360];_[364+1]=_[361];_[364+2]=_[362];_[364+3]=_[363];add1=_[355]+_[359];add2=_[354]+_[358]+(add1>>16);add3=_[353]+_[357]+(add2>>16);add4=_[352]+_[356]+(add3>>16);_[363]=add1&$00ffff;_[362]=add2&$00ffff;_[361]=add3&$00ffff;_[360]=add4&$00ffff}add1=_[323]+_[363];add2=_[322]+_[362]+(add1>>16);add3=_[321]+_[361]+(add2>>16);add4=_[320]+_[360]+(add3>>16);_[323]=add1&$00ffff;_[322]=add2&$00ffff;_[321]=add3&$00ffff;_[320]=add4&$00ffff;add1=_[327]+_[364+3];add2=_[326]+_[364+2]+(add1>>16);add3=_[325]+_[364+1]+(add2>>16);add4=_[324]+_[364]+(add3>>16);_[327]=add1&$00ffff;_[326]=add2&$00ffff;_[325]=add3&$00ffff;_[324]=add4&$00ffff;add1=_[331]+_[368+3];add2=_[330]+_[368+2]+(add1>>16);add3=_[329]+_[368+1]+(add2>>16);add4=_[328]+_[368]+(add3>>16);_[331]=add1&$00ffff;_[330]=add2&$00ffff;_[329]=add3&$00ffff;_[328]=add4&$00ffff;add1=_[335]+_[372+3];add2=_[334]+_[372+2]+(add1>>16);add3=_[333]+_[372+1]+(add2>>16);add4=_[332]+_[372]+(add3>>16);_[335]=add1&$00ffff;_[334]=add2&$00ffff;_[333]=add3&$00ffff;_[332]=add4&$00ffff;add1=_[339]+_[376+3];add2=_[338]+_[376+2]+(add1>>16);add3=_[337]+_[376+1]+(add2>>16);add4=_[336]+_[376]+(add3>>16);_[339]=add1&$00ffff;_[338]=add2&$00ffff;_[337]=add3&$00ffff;_[336]=add4&$00ffff;add1=_[343]+_[380+3];add2=_[342]+_[380+2]+(add1>>16);add3=_[341]+_[380+1]+(add2>>16);add4=_[340]+_[380]+(add3>>16);_[343]=add1&$00ffff;_[342]=add2&$00ffff;_[341]=add3&$00ffff;_[340]=add4&$00ffff;add1=_[347]+_[384+3];add2=_[346]+_[384+2]+(add1>>16);add3=_[345]+_[384+1]+(add2>>16);add4=_[344]+_[384]+(add3>>16);_[347]=add1&$00ffff;_[346]=add2&$00ffff;_[345]=add3&$00ffff;_[344]=add4&$00ffff;add1=_[351]+_[388+3];add2=_[350]+_[388+2]+(add1>>16);add3=_[349]+_[388+1]+(add2>>16);add4=_[348]+_[388]+(add3>>16);_[351]=add1&$00ffff;_[350]=add2&$00ffff;_[349]=add3&$00ffff;_[348]=add4&$00ffff}var hex="0123456789abcdef";var output="";for(var i=0;i<8;i++){for(var j=0;j<4;j++){var b=_[(320+i*4)+j];output+=string_char_at(hex,((b>>12)&$f)+1)+string_char_at(hex,((b>>8)&$f)+1)+string_char_at(hex,((b>>4)&$f)+1)+string_char_at(hex,(b&$f)+1)}}return output;
#define gms_instance_sync_var_add
if(!is_string(argument[0]))
{
    XServer_error("gms_instance_sync_var_add: Expected argument 1 to be a string. Please note variable names should be written with quotes.");
    exit
}
if(global.__instanceVarC > 13)
{
    XServer_error("You cannot sync more than 13 variables!");
    exit;
}else{
    var __prec;
    if(argument_count == 3)
    {
        __prec = argument[2];
    }else{
        __prec = 0.01;
    }
    
    if(is_real(argument[1]))
    {
        XServer_instance_sync_set_variable_real(global.__instanceVarC, string(argument[0]), argument[1], __prec);
    }else{
        XServer_instance_sync_set_variable_string(global.__instanceVarC, string(argument[0]), argument[1], __prec);
    }
}
global.__instanceVarC += 1;
#define gms_instance_sync
//(id[, flags])
XServer_verify();
if(!is_real(argument[0]))
{
    XServer_error("gms_instance_sync: Got a string as instance (argument 0), but it should be a real.")
    exit
}
if(!is_real(argument[1]))
{
    XServer_error("gms_instance_sync: Expected the second argument to be a real, but got a string.")
    exit
}
if(instance_exists(argument[0]) && global.__can_sync)
{
    for(__i = 2; __i < argument_count; __i += 1)
    {
        with(argument[0])
        {
            other.__var_value = XServer_variable_local_get(other.argument[other.__i]);
        }
        gms_instance_sync_var_add(argument[__i], __var_value, 0.01);
    }
    if(argument[1] & 4 && argument[1] & 2 && argument[1] & 1)
    {
        //Full instance sync
        sID = XServer_instance_sync_full(argument[1] & 8, argument[0], argument[0].object_index, argument[0].x, argument[0].y, argument[0].direction, argument[0].speed, room);
        //Add to tracking list
        ds_list_add(global.__instanceTrackList, argument[0]);
    }else if(argument[1] & 2 && argument[1] & 1)
    {
        //Extended OneTime instance sync
        sID = XServer_instance_sync_ext(argument[1] & 8, argument[0], argument[0].object_index, argument[0].x, argument[0].y, argument[0].direction, argument[0].speed, room);
    }else
    if(argument[1] & 1)
    {
        //OneTime instance sync
        XServer_instance_sync_once(argument[1] & 8, argument[0], argument[0].object_index, argument[0].x, argument[0].y, argument[0].direction, argument[0].speed);
        sID = -1;
    }else{
        XServer_error("gms_instance_sync: Invalid second argument. The argument should be is_onetime, is_extended, or is_full");
        exit;
    }
    if(argument[1] & 2)
    {
        //Add to instance list (Destroy list)
        ds_list_add(global.__instanceList, argument[0]);
    }
    argument[0].owner = gms_self_playerid();
    if(sID != -1)
    {
        argument[0].syncID = sID;
    }
}
global.__instanceVarC = 0
#define gms_login_player_has_account
XServer_verify();
return XServer_login_player_has_account(argument[0]);
#define gms_p2p_send
XServer_verify();
for(i = 2; i < argument_count; i += 1)
{
    if(is_real(argument[i]))
    {
        XServer_p2p_set_real(i-2, argument[i]);
    }else{
        XServer_p2p_set_string(i-2, argument[i]);
    }
}
XServer_p2p_send(argument[0], argument[1]);
#define gms_init
//()
XServer_init_gml();
XServer_init();

global.__obj = argument0;

if(!object_get_persistent(argument0))
{
    show_error("gms_init(): The GameMaker Server-object should be persistent.", true);
}
#define XServer_send
var pos = buffer_tell(_b) + 1;
    //show_debug_message("Bytes to send: " + string(pos) + " @ position " + string(buffer_tell(global.__send_buffer)))

if(pos >= 128)
{
        //show_debug_message("2B: " + string((pos << 1) | 1) + " | " + string(pos >> 7))
    buffer_write(global.__send_buffer, buffer_u8, (pos << 1) | 1);
    buffer_write(global.__send_buffer, buffer_u8, pos >> 7);
}else{
        //show_debug_message("1B: " + string((pos << 1)) + " | " + string(pos >> 7))
    buffer_write(global.__send_buffer, buffer_u8, pos << 1);
}

buffer_write(global.__send_buffer, buffer_u8, argument0);
buffer_copy(_b, 0, pos - 1, global.__send_buffer, buffer_tell(global.__send_buffer));
    //show_debug_message("Seeking " + string(pos + (pos >= 128) + 1) + " bytes")
buffer_seek(global.__send_buffer, buffer_seek_relative, pos - 1);


    //show_debug_message("Bytes sent: " + string(pos) + " @ position " + string(buffer_tell(global.__send_buffer)))
#define gms_connect
if(!global.__socket_connecting && !gms_info_isconnected())
{
    var ip = network_resolve("gamemakerserver.com");
    if(ip == "") ip = network_resolve("http://gamemakerserver.com");
    if(ip == "") ip = network_resolve("www.gamemakerserver.com");
    if(ip == "") ip = network_resolve("http://www.gamemakerserver.com");
    
    if(ip == "")
    {
        global.__socket_connecting = false;
        global.__socket_connected = false;
    }else{
        if(network_connect_raw(global.__socket, ip, 25500) < 0)
        {
            global.__socket_connecting = false;
            global.__socket_connected = false;
            show_debug_message("Socket failed to connect to server!");
            exit;
        }
        global.__socket_connecting = true;
        show_debug_message("Sending connection request")
        
        XServer_preparesend();
                
        buffer_write(_b, buffer_f64, global.__gms_version);
        
        buffer_write(_b, buffer_u8, 1);
        
        buffer_write(_b, buffer_f64, game_id);
        buffer_write(_b, buffer_f64, 1038746284749);
        buffer_write(_b, buffer_f64, 9847837487487);
        buffer_write(_b, buffer_f64, 3183648256511);
        buffer_write(_b, buffer_f64, 6178346799275);
        
        XServer_sendspecial(mid_hello);
    }
}
#define XServer_network_init
return network_create_socket(network_socket_tcp)
#define XServer_network_update

#define XServer_connectdebug
if(global.__debugging) show_debug_message("Connecting.")
if(!global.__socket_connecting && !gms_info_isconnected())
{
    if(global.__debugging)show_debug_message("Connecting..")
    if(network_connect_raw(global.__socket, "127.0.0.1", 25500) < 0)
    {
        global.__socket_connecting = false;
        global.__socket_connected = false;
        show_debug_message("Socket failed to connect to debug server!");
        exit;
    }
    global.__socket_connecting = true;
    if(global.__debugging) show_debug_message("Sending connection request")
    
    show_debug_message("Sending connection request")
    
    XServer_preparesend();
            
    buffer_write(_b, buffer_f64, global.__gms_version);
    
    buffer_write(_b, buffer_u8, 1);
    
    buffer_write(_b, buffer_f64, game_id);
    buffer_write(_b, buffer_f64, 1038746284749);
    buffer_write(_b, buffer_f64, 9847837487487);
    buffer_write(_b, buffer_f64, 3183648256511);
    buffer_write(_b, buffer_f64, 6178346799275);
    
    XServer_sendspecial(mid_hello);
}
#define XServer_flush
if(buffer_tell(global.__send_buffer) > 0)
{
    /*if(debug_mode)
    {
        show_debug_message("Sending " + string(buffer_tell(global.__send_buffer)) + "bytes");
    }*/
    if(network_send_raw(global.__socket, global.__send_buffer, buffer_tell(global.__send_buffer)) < 0)
    {
        global.__socket_connected = false;
        XServer_disconnected();
    }
    buffer_seek(global.__send_buffer, buffer_seek_start, 0);
}
#define XServer_sendspecial
var pos = buffer_tell(_b);

buffer_write(global.__send_buffer, buffer_u16, pos + 1);
buffer_write(global.__send_buffer, buffer_u8, argument0);

buffer_copy(_b, 0, pos, global.__send_buffer, buffer_tell(global.__send_buffer));
buffer_seek(global.__send_buffer, buffer_seek_relative, pos);
#define gms_achievement_count
return ds_map_size(global.__achievement)
#define gms_achievement_description
if(ds_map_exists(global.__achievement, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__achievement, argument0), "text");
}else{
    return "";
}
#define gms_achievement_find
return ds_list_find_value(global.__achievement_idmap, argument0);
#define gms_achievement_isreached
if(ds_map_exists(global.__achievement, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__achievement, argument0), "value");
}else{
    return 0;
}
#define gms_achievement_reach
XServer_preparesend();

if(ds_map_exists(global.__achievement, argument0))
{
    buffer_write(_b, buffer_u32, ds_map_find_value(ds_map_find_value(global.__achievement, argument0), "id"));
    ds_map_replace(ds_map_find_value(global.__achievement, argument0), "value", true);
}

XServer_send(mid_achievement);
#define gms_action_get_argument_name
return ds_map_find_value(ds_queue_head(global.__actions), argument0 + 16);
#define gms_action_get_argument_real
return ds_map_find_value(ds_queue_head(global.__actions), argument0);
#define gms_action_get_argument_string
return string(ds_map_find_value(ds_queue_head(global.__actions), argument0));
#define gms_action_get_id
return ds_map_find_value(ds_queue_head(global.__actions), "type");
#define gms_action_get_sender
return ds_map_find_value(ds_queue_head(global.__actions), "from");
#define gms_action_goto_next
ds_queue_dequeue(global.__actions);
return ds_queue_size(global.__actions);
#define gms_admin_ban
XServer_preparesend();

XGms_cache_player_write(_b, argument0)
XServer_writestring(_b, argument1);
buffer_write(_b, buffer_s32, argument2);

XServer_send(mid_ban);
#define gms_admin_kick
XServer_preparesend();

XGms_cache_player_write(_b, argument0)
XServer_writestring(_b, argument1);

XServer_send(mid_kick);
#define gms_friend_count
return ds_map_size(global.__friend);
#define gms_friend_get
return ds_list_find_value(global.__friend_idmap, argument0);
#define gms_friend_isonline
if(ds_map_exists(global.__friend, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__friend, argument0), "online");
}else{
    return 0;
}
#define gms_friend_name
if(ds_map_exists(global.__friend, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__friend, argument0), "name");
}else{
    return "";
}
#define XServer_friend_send_request
XServer_preparesend();

//Message-Contents
XServer_writestring(_b, argument0);

//Verzend de data
XServer_send(mid_friendrequest);
#define gms_global_exists
return ds_map_exists(global.__global, argument0);
#define gms_global_get_real
var val = ds_map_find_value(global.__global, argument0);
if(is_real(val))
{
    return val;
}else{
    return 0;
}
#define gms_global_get_string
var val = ds_map_find_value(global.__global, argument0);
if(is_string(val))
{
    return val;
}else{
    return "";
}
#define gms_global_isreal
return is_real(ds_map_find_value(global.__global, argument0));
#define gms_highscore_add
if(gms_highscore_list_exists(argument0))
{
    XServer_preparesend();
    
    buffer_write(_b, buffer_s32, argument0);
    buffer_write(_b, buffer_f64, argument1);
    buffer_write(_b, buffer_u8, 0);
    
    XServer_send(mid_highscore);
}else{
    show_error("Highscore list does not exist.", false);
}
#define gms_highscore_replace
if(gms_highscore_list_exists(argument0))
{
    XServer_preparesend();
    
    buffer_write(_b, buffer_s32, argument0);
    buffer_write(_b, buffer_f64, argument1);
    buffer_write(_b, buffer_u8, 1);
    
    XServer_send(mid_highscore);
}else{
    show_error("Highscore list does not exist.", false);
}
#define gms_highscore_add_guest
if(gms_highscore_list_exists(argument0))
{
    XServer_preparesend();
    
    buffer_write(_b, buffer_s32, argument0);
    XServer_writestring(_b, argument1);
    buffer_write(_b, buffer_f64, argument2);
    
    XServer_send(mid_guest_highscore);
}else{
    show_error("Highscore list does not exist.", false);
}
#define gms_highscore_count
if(gms_highscore_list_exists(argument0))
{
    return ds_list_size(ds_map_find_value(ds_map_find_value(global.__highscore, argument0), "names"));
}else{
    return 0;
}
#define gms_highscore_find_pos
if(gms_highscore_list_exists(argument0))
{
    return ds_list_find_index(ds_map_find_value(ds_map_find_value(global.__highscore, argument0), "names"), argument1);
}else{
    return 0;
}
#define gms_highscore_list_count
return ds_map_size(global.__highscore);
#define gms_highscore_list_exists
return ds_map_exists(global.__highscore, argument0);
#define gms_highscore_list_id
return ds_list_find_value(global.__highscore_ids, argument0);
#define gms_highscore_list_title
if(gms_highscore_list_exists(argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__highscore, argument0), "list_title");
}else{
    return "";
}
#define gms_highscore_name
if(gms_highscore_list_exists(argument0))
{
    return ds_list_find_value(ds_map_find_value(ds_map_find_value(global.__highscore, argument0), "names"), argument1);
}else{
    return "";
}
#define gms_highscore_score
if(gms_highscore_list_exists(argument0))
{
    return ds_list_find_value(ds_map_find_value(ds_map_find_value(global.__highscore, argument0), "scores"), argument1);
}else{
    return "";
}
#define gms_highscore_self_score
if(gms_highscore_list_exists(argument0))
{
    var _map = ds_map_find_value(global.__highscore, argument0),
        _names = ds_map_find_value(_map, "names"),
        _scores = ds_map_find_value(_map, "scores");
    for(var i = 0; i < ds_list_size(_names); i++)
    {
        if(string_lower(ds_list_find_value(_names, i)) == gms_self_name())
        {
            return ds_list_find_value(_scores, i);
        }
    }
}

return 0;
#define gms_info_isconnected
return global.__socket_connected;
#define gms_info_isloggedin
return global.__loggedin && global.__socket_connected;
#define gms_info_isresponding
return global.__connection_accepted;
#define gms_info_login_count
return global.__num_logins;
#define gms_info_ping
return global.__socket_ping;
#define gms_ini_game_size
var __i = ds_map_find_first(global.__ini_game),
    __s = ds_map_size(global.__ini_game),
    __t = 0;
repeat(__s - 1)
{
    if(is_real(__i))
    {
        __t += 8;
    }else{
        __t += string_length(__i);
    }
    
    __i = ds_map_find_next(global.__ini_game, __i);
}

return __t;
#define gms_ini_game_size_limit
return global.__ini_game_limit;
#define gms_ini_player_size
var __i = ds_map_find_first(global.__ini_player),
    __s = ds_map_size(global.__ini_player),
    __t = 0;
repeat(__s - 1)
{
    if(is_real(__i))
    {
        __t += 8;
    }else{
        __t += string_length(__i);
    }
    
    __i = ds_map_find_next(global.__ini_player, __i);
}

return __t;
#define gms_ini_player_size_limit
return global.__ini_player_limit;
#define gms_instance_get_owner
var _m = XServer_instance_find(argument0);
if(_m != -1)
{
    return ds_map_find_value(_m, "owner");
}else{
    return 0;
}
#define gms_instance_get_real
var _m = XServer_instance_find(argument0);
if(_m != -1)
{
    if(ds_map_exists(_m, "*" + argument1))
    {
        var _val = ds_map_find_value(_m, "*" + argument1);
        if(is_real(_val))
        {
            return _val;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}else{
    return 0;
}
#define gms_instance_get_string
var _m = XServer_instance_find(argument0);
if(_m != -1)
{
    if(ds_map_exists(_m, "*" + argument1))
    {
        var _val = ds_map_find_value(_m, "*" + argument1);
        if(is_string(_val))
        {
            return _val;
        }else{
            return "";
        }
    }else{
        return "";
    }
}else{
    return "";
}
#define gms_instance_handover
var __s = XServer_instance_find(argument0);

XServer_preparesend();

buffer_write(_b, buffer_u16, ds_map_find_value(__s, "syncID") - 1000000);

XServer_send(mid_instance_takeover);
#define gms_instance_handover_all
for(var _i = 0; _i < XServer_instanceN(); _i++)
{
    gms_instance_handover(XServer_instanceID(_i));
}
#define gms_instance_isreal
var _m = XServer_instance_find(argument0);
if(_m != -1)
{
    //Does not check for variablke existance: if a ds_map key does not exist, the function will return a real.
    var _val = ds_map_find_value(_m, "*" + argument1);
    if(is_real(_val))
    {
        return true;
    }else{
        return false;
    }
}else{
    return true;
}
#define gms_instance_is_owner
var _m = XServer_instance_find(argument0);
if(_m != -1)
{
    return ds_map_find_value(_m, "owner") == gms_self_playerid();
}else{
    return true;
}
#define gms_instance_set_real
var __i = XServer_instance_find(argument0);
if(__i != -1)
{
    if(argument1 == "x")
    {
        if(ds_map_find_value(__i, "x") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "x", argument2);
        }
    }else if(argument1 == "y")
    {
        if(ds_map_find_value(__i, "y") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "y", argument2);
        }
    }else if(argument1 == "speed")
    {
        if(ds_map_find_value(__i, "speed") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "speed", argument2);
        }
    }else if(argument1 == "direction")
    {
        if(ds_map_find_value(__i, "direction") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "direction", argument2);
        }
    }else{
        var _m1 = ds_map_find_value(__i, "variable_names"),
            _m3 = ds_map_find_value(__i, "variable_changed");
        if(ds_map_exists(__i, "*" + argument1))
        {
            if(ds_map_find_value(__i, "*" + argument1) != argument2) ds_list_add(_m3, argument1);
            ds_map_replace(__i, "*" + argument1, argument2);
        }else{
            ds_list_add(_m1, argument1);
            ds_list_add(_m3, argument1);
            ds_map_add(__i, ">" + argument1, global.__default_prec);
            ds_map_add(__i, "*" + argument1, argument2);
        }
    }
    
    return true;
}else{
    show_debug_message("gms_instance_set_*: Unknown instance " + string(argument0));
    return false;
}
#define gms_instance_set_string
var __i = XServer_instance_find(argument0);
if(__i != -1)
{
    if(argument1 == "x")
    {
        if(ds_map_find_value(__i, "x") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "x", argument2);
        }
    }else if(argument1 == "y")
    {
        if(ds_map_find_value(__i, "y") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "y", argument2);
        }
    }else if(argument1 == "speed")
    {
        if(ds_map_find_value(__i, "speed") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "speed", argument2);
        }
    }else if(argument1 == "direction")
    {
        if(ds_map_find_value(__i, "direction") != argument2)
        {
            ds_map_replace(__i, "has_moved", true);
            ds_map_replace(__i, "direction", argument2);
        }
    }else{
        var _m1 = ds_map_find_value(__i, "variable_names"),
            _m3 = ds_map_find_value(__i, "variable_changed");
        if(ds_map_exists(__i, "*" + argument1))
        {
            if(ds_map_find_value(__i, "*" + argument1) != argument2) ds_list_add(_m3, argument1);
            ds_map_replace(__i, "*" + argument1, argument2);
        }else{
            ds_list_add(_m1, argument1);
            ds_list_add(_m3, argument1);
            ds_map_add(__i, ">" + argument1, global.__default_prec);
            ds_map_add(__i, "*" + argument1, argument2);
            ds_list_add(__i, argument1);
        }
    }
    
    return true;
}else{
    show_debug_message("gms_instance_set_*: Unknown instance " + string(argument0));
    return false;
}
#define gms_instance_sync_destroy
if(argument0 < 1000000)
{
    argument0 = ds_map_find_value(global.__instance_map, argument0);
}
if(ds_map_exists(global.__instance, argument0))
{
    XServer_instance_destroy(argument0);
    
    XServer_preparesend();
    buffer_write(_b, buffer_u16, argument0 - 1000000);
    XServer_send(mid_instance_destroy);
}else{
    return false;
}
#define gms_login_errorcode
if(gms_info_isconnected())
{
    return global.__login_error;
}else{
    return 24;
}
#define gms_login_set_password
global.__login_password = argument0;
#define gms_login_set_username
global.__login_username = argument0;
#define XServer_logout
XServer_preparesend();
XServer_send(mid_logout);
XServer_flush();

XServer_clear_map_map(global.__achievement);
ds_list_clear(global.__achievement_idmap);

XServer_clear_map_map(global.__stat);
ds_list_clear(global.__stat_idmap);

XServer_clear_map_map(global.__friend);
ds_list_clear(global.__friend_idmap);

XServer_clear_map_map(global.__highscore);
ds_list_clear(global.__highscore_ids);

global.__loggedin = 0;

ds_map_clear(global.__ini_player);

ds_map_clear(global.__global);
ds_map_clear(global.__global_prec);
ds_list_clear(global.__global_changed);

ds_map_clear(global.__self);
ds_map_clear(global.__self_prec);
ds_list_clear(global.__self_changed);

XServer_clear_map_map(global.__player);
XServer_clear_instances(global.__instance);
ds_list_clear(global.__player_idmap);

for(var i = 0; i < 10; i++)
{
    global.__team_score[i] = 0;
}

global.__p2p_argument_count     = 0;
for(var i = 0; i < 16; i++) global.__p2p_argument[i] = 0;

global.__sync_pos = 0;
global.__sync_pos_max = 0;
global.__sync_pos_start = 0;

ds_list_clear(global.__session);
#define gms_master_player
return global.__master_player;
#define gms_optimize_set_sendspeed
switch(argument0)
{
    case 0://Fullfps
        global.__timer_threshold = 1000000 / 30;
        break;
    case 1://Half
        global.__timer_threshold = 1000000 / 15;
        break;
    case 2://Twenty
        global.__timer_threshold = 1000000 / 20;
        break;
    case 3://Supersave
        global.__timer_threshold = 1000000 / 5;
        break;
    case 4://Second
        global.__timer_threshold = 1000000;
        break;
}
#define gms_optimize_set_spc
global.__spc = argument0;
#define gms_other_admin_rights
if(ds_map_exists(global.__player, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__player, argument0), "admininfo");
}else{
    return 0;
}
#define gms_other_count
return ds_list_size(global.__player_idmap);
#define gms_other_exists
if(ds_map_exists(global.__player, argument0))
{
    var _m = ds_map_find_value(global.__player, argument0);
    if(ds_map_exists(_m, "*" + argument1))
    {
        return true;
    }else{
        return false;
    }
}else{
    return false;
}
#define gms_other_find
return ds_list_find_value(global.__player_idmap, argument0);
#define gms_other_find_by_name
for(var i = 0; i < gms_other_count(); i++)
{
    if(string_lower(gms_other_get_string(gms_other_find(i), "name")) == string_lower(argument0))
    {
        return gms_other_find(i);
    }
}

return -1;
#define gms_other_get_real
if(ds_map_exists(global.__player, argument0))
{
    var _m = ds_map_find_value(global.__player, argument0);
    if(ds_map_exists(_m, "*" + argument1))
    {
        var _val = ds_map_find_value(_m, "*" + argument1);
        if(is_real(_val))
        {
            return _val;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}else{
    return 0;
}
#define gms_other_get_string
if(ds_map_exists(global.__player, argument0))
{
    var _m = ds_map_find_value(global.__player, argument0);
    if(ds_map_exists(_m, "*" + argument1))
    {
        var _val = ds_map_find_value(_m, "*" + argument1);
        if(is_string(_val))
        {
            return _val;
        }else{
            return "";
        }
    }else{
        return "";
    }
}else{
    return "";
}
#define gms_other_has_changed
if(ds_map_exists(global.__player, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__player, argument0), "has_changed");
}else{
    return 0;
}
#define gms_other_isreal
if(ds_map_exists(global.__player, argument0))
{
    //Does not check for variablke existance: if a ds_map key does not exist, the function will return a real.
    var _val = ds_map_find_value(ds_map_find_value(global.__player, argument0), "*" + argument1);
    if(is_real(_val))
    {
        return true;
    }else{
        return false;
    }
}else{
    return true;
}
#define XServer_register_execute
XServer_preparesend();

XServer_writestring(_b, argument0);
XServer_writestring(_b, argument1);
XServer_writestring(_b, argument2);
XServer_writestring(_b, argument3);

XServer_send(mid_registration);
#define gms_register_errorcode
return global.__register_status;
#define gms_self_admin_rights
return global.__self_admininfo;
#define gms_self_isguest
return global.__player_isguest;
#define gms_self_ismaster
return global.__player_id == global.__master_player;
#define gms_self_name
return global.__name;
#define gms_self_playerid
return global.__player_id;
#define gms_self_set_precision
ds_map_replace(global.__self_prec, argument0, argument1)
#define gms_session_count
return ds_list_size(global.__session);
#define gms_session_create
XServer_preparesend();

buffer_write(_b, buffer_u16, argument0);

XServer_send(mid_session_create);
#define gms_session_current_id
return global.__session_id;
#define gms_session_id
if(argument0 < 0 || argument0 >= ds_list_size(global.__session)) return 0;
return ds_map_find_value(ds_list_find_value(global.__session, argument0), "id");
#define gms_session_join
XServer_preparesend();

buffer_write(_b, buffer_u16, argument0);

XServer_send(mid_session_join);
#define gms_session_player_count
if(argument0 < 0 || argument0 >= ds_list_size(global.__session)) return 0;
return ds_map_find_value(ds_list_find_value(global.__session, argument0), "players");
#define gms_session_type
if(argument0 < 0 || argument0 >= ds_list_size(global.__session)) return 0;
return ds_map_find_value(ds_list_find_value(global.__session, argument0), "type");
#define gms_setversion
argument0 = argument0;
#define gms_statistic_count
return ds_map_size(global.__stat);
#define gms_statistic_description
if(ds_map_exists(global.__stat, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__stat, argument0), "text");
}else{
    return "";
}
#define gms_statistic_find
return ds_list_find_value(global.__stat_idmap, argument0);
#define gms_statistic_get
if(ds_map_exists(global.__stat, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__stat, argument0), "value");
}else{
    return 0;
}
#define gms_statistic_set
XServer_preparesend();

if(ds_map_exists(global.__stat, argument0) && is_real(argument1))
{
    ds_map_replace(ds_map_find_value(global.__stat, argument0), "value", argument1);
    buffer_write(_b, buffer_u32, ds_map_find_value(ds_map_find_value(global.__stat, argument0), "id"));
    buffer_write(_b, buffer_f64, argument1);
}

XServer_send(mid_statistic);
#define gms_status
return global.__statuscode;
#define gms_team_player_count
var _count = 0;
for(var i = 0; i < gms_other_count(); i++)
{
    if(gms_other_get_real(gms_other_find(i), "team") == argument0)
    {
        _count++;
    }
}

return _count;
#define gms_team_player_get
var _count = 0;
for(var i = 0; i < gms_other_count(); i++)
{
    if(gms_other_get_real(gms_other_find(i), "team") == argument0)
    {
        if(_count == argument1)
        {
            return gms_other_find(i);
        }
        _count++;
    }
}

return _count;
#define gms_team_score_get
return global.__team_score[argument0];
#define gms_team_score_set
XServer_preparesend();

buffer_write(_b, buffer_u8, argument0);
buffer_write(_b, buffer_f32, argument1);

XServer_send(mid_team);
#define gms_time
return get_timer() / 1000000 - global.__subtract_time;
#define gms_uninit

#define gms_update_check
if(global.__received_update) return global.__update_avaiable;
return -1;
//show_error("gms_update_check is not supported in the Networking API version of GameMaker Server :(", true);
#define gms_update_isfinished
show_error("gms_update_isfinished is not supported in the Networking API version of GameMaker Server :(", true);
#define gms_update_progress
show_error("gms_update_progress is not supported in the Networking API version of GameMaker Server :(", true);
#define gms_update_start
show_error("gms_update_start is not supported in the Networking API version of GameMaker Server :(", true);
#define gms_version
return global.__gms_version;
#define gms_vs_end
XServer_preparesend();

XServer_send(mid_vs_end);
#define gms_vs_ready
return global.__vs_ready;
#define gms_vs_time
return global.__vs_time;
#define XServer_action_get_argument_isreal
return is_real(ds_map_find_value(ds_queue_head(global.__actions), argument0));
#define XServer_chat_send_message
XServer_preparesend();

//Message-Contents
buffer_write(_b, buffer_u32, argument1);
XServer_writestring(_b, argument0);

//Verzend de data
XServer_send(mid_chat);
#define XServer_chat_set_mode
XServer_preparesend();

buffer_write(_b, buffer_u8, argument0);

XServer_send(mid_chatmode);
#define XServer_init
//This script initializes studio-specific features
//GM:Studio does not support this variable, so we'll add it manually.
global.__gms_version            = 1.7;

global.__achievement            = ds_map_create();
global.__achievement_idmap      = ds_list_create();
global.__achievement_idmap2     = ds_map_create();
global.__stat                   = ds_map_create();
global.__stat_idmap             = ds_list_create();

global.__actions                = ds_queue_create();
global.__friend_idmap           = ds_list_create();
global.__friend                 = ds_map_create();

global.__highscore              = ds_map_create();
global.__highscore_ids          = ds_list_create();

global.__ini_game               = ds_map_create();
global.__ini_player             = ds_map_create();
global.__ini_game_limit         = 0;
global.__ini_player_limit       = 0;

global.__vs_ready               = false;
global.__vs_time                = 0;

//Logins
global.__num_logins             = 0;

global.__debugging              = debug_mode;

//Logging in
global.__login_username         = "";
global.__login_password         = "";
global.__login_status           = 0;
global.__login_error            = 0;
global.__login_save_code        = "";
global.__login_accounts         = ds_map_create();

global.__register_status        = -2;

global.__loggedin               = false;

//Sockets
global.__socket                 = XServer_network_init();
global.__socket_connecting      = false;
global.__socket_connected       = false;
global.__socket_script_queue    = ds_queue_create();
global.__socket_ping            = 0;

global.__last_send              = 0;
global.__timer_threshold        = 1000000 / room_speed;

global.__sprite_resource        = 0;

globalvar _b, _rb, rr;
_b                              = buffer_create(512, buffer_grow, 1);
_rb                             = buffer_create(512, buffer_grow, 1);
_rr                             = buffer_create(512, buffer_grow, 1);
_sb                             = buffer_create(512, buffer_grow, 1);

global.__send_buffer            = buffer_create(16384, buffer_grow, 1);


//Server time
global.__subtract_time          = 0;


//Variable syncing
global.__global                 = ds_map_create();
global.__global_prec            = ds_map_create();
global.__global_changed         = ds_list_create();

global.__self                   = ds_map_create();
global.__self_prec              = ds_map_create();
global.__self_changed           = ds_list_create();
global.__self_admininfo         = 0;

global.__self_x                 = 0;
global.__self_y                 = 0;
global.__self_speed             = 0;
global.__self_direction         = 0;
global.__self_prev_x            = 0;
global.__self_prev_y            = 0;
global.__self_prev_speed        = 0;
global.__self_prev_direction    = 0;
global.__max_skip               = 3;
global.__current_skip           = 0;

global.__self_position_changed  = 1;

//Players
global.__player                 = ds_map_create();
global.__player_idmap           = ds_list_create();
global.__master_player          = 0;

global.__name                   = "";
global.__player_id              = 0;

global.__default_prec           = 0.01;

global.__last_send              = get_timer();

//Team score
for(var i = 0; i < 10; i++)
{
    global.__team_score[i] = 0;
}

//P2P messages
global.__p2p_argument_count     = 0;
for(var i = 0; i < 16; i++) global.__p2p_argument[i] = 0;


//Instance syncing
global.__sync_pos = 0;
global.__sync_pos_max = 0;
global.__sync_pos_start = 0;

global.__instance               = ds_map_create();
global.__instance_map           = ds_map_create();
global.__instance_idmap         = ds_list_create();

for(var __i = 0; i < 14; i++)
{
    global.__instance_var[i]  = "null";
    global.__instance_val[i]  = 0.0;
    global.__instance_prec[i] = 0.01;
}

global.__instance_varcount = 0;

//Sessions
global.__session            = ds_list_create();
global.__session_id         = 0;

global.__statuscode         = 1;

global.__connection_accepted = false;
global.__spc                = 9;

global.__last_4d = 0;
global.__step_timer         = 0;

global.__update_avaiable    = false;
global.__received_update    = false;

global.__loc_isonum         = 0;
global.__loc_countrycode    = "";
global.__loc_countryname    = "";
global.__loc_languages      = "";

//Caches
global.__player_send_cache  = ds_map_create();
global.__player_isend_cache  = ds_map_create();
global.__variable_send_llist = ds_list_create();
for(var j = 0; j < 256; j++)
{
    global.__player_receive_cache[j] = 0;
}

for(var i = 0; i < 6; i++)
{
    global.__variable_send_cache[i] = ds_map_create();
    global.__variable_isend_cache[i] = ds_map_create();
    global.__variable_send_llist[i] = ds_list_create();
    global.__variable_send_queue[i] = ds_map_create();
    
    for(var j = 2; j < 256; j++)
    {
        global.__variable_receive_cache_name[i, j] = "";
        global.__variable_receive_cache_type[i, j] = 0;
        ds_list_add(global.__variable_send_llist[i], j);
    }
    
    global.__variable_receive_cache_type[i, 0] = 1;
    global.__variable_receive_cache_type[i, 1] = 0;
}
#define XServer_ini_game_delete
ds_map_delete(global.__ini_game, argument0);
XServer_preparesend();

XServer_writestring(_b, argument0);

XServer_send(mid_gameini_delete)
#define XServer_ini_game_exists
return ds_map_exists(global.__ini_game, argument0);
#define XServer_ini_game_isreal
return is_real(ds_map_find_value(global.__ini_game, argument0));
#define XServer_ini_game_read_real
var val = ds_map_find_value(global.__ini_game, argument0);
if(is_real(val))
{
    return val;
}else{
    return 0;
}
#define XServer_ini_game_read_string
var val = ds_map_find_value(global.__ini_game, argument0);
if(is_string(val))
{
    return val;
}else{
    return "";
}
#define XServer_ini_game_write_real
if(XServer_ini_game_exists(argument0))
{
    ds_map_replace(global.__ini_game, argument0, argument1)
}else{
    ds_map_add(global.__ini_game, argument0, argument1)
}

XServer_preparesend();

XServer_writevariable(_b, 3, argument0, argument1, 0.01);

XServer_send(mid_gameini_string)
#define XServer_ini_game_write_string
if(XServer_ini_game_exists(argument0))
{
    ds_map_replace(global.__ini_game, argument0, argument1)
}else{
    ds_map_add(global.__ini_game, argument0, argument1)
}

XServer_preparesend();

XServer_writevariable(_b, 3, argument0, argument1, 0.01);

XServer_send(mid_gameini_string)
#define XServer_ini_player_delete
ds_map_delete(global.__ini_player, argument0);
XServer_preparesend();

XServer_writestring(_b, argument0);

XServer_send(mid_playerini_delete)
#define XServer_ini_player_exists
return ds_map_exists(global.__ini_player, argument0);
#define XServer_ini_player_isreal
return is_real(ds_map_find_value(global.__ini_player, argument0));
#define XServer_ini_player_read_real
var val = ds_map_find_value(global.__ini_player, argument0);
if(is_real(val))
{
    return val;
}else{
    return 0;
}
#define XServer_ini_player_read_string
var val = ds_map_find_value(global.__ini_player, argument0);
if(is_string(val))
{
    return val;
}else{
    return "";
}
#define XServer_ini_player_write_real
if(XServer_ini_player_exists(argument0))
{
    ds_map_replace(global.__ini_player, argument0, argument1)
}else{
    ds_map_add(global.__ini_player, argument0, argument1)
}

XServer_preparesend();

XServer_writevariable(_b, 3, argument0, argument1, 0.01);

XServer_send(mid_playerini_string)
#define XServer_ini_player_write_string
if(XServer_ini_player_exists(argument0))
{
    ds_map_replace(global.__ini_player, argument0, argument1)
}else{
    ds_map_add(global.__ini_player, argument0, argument1)
}

XServer_preparesend();

XServer_writevariable(_b, 3, argument0, argument1, 0.01);

XServer_send(mid_playerini_string)
#define XServer_instance4d
//syncID, x, y, speed, direction
//gms_instance_set_real(argument0, "x", argument1);
//gms_instance_set_real(argument0, "y", argument2);
//gms_instance_set_real(argument0, "speed", argument3);
//gms_instance_set_real(argument0, "direction", argument4);

var _dir, _sp;
_dir = round(argument4 * 11)
_sp = round((argument3 + 25.6) * 80);

XServer_preparesend();

buffer_write(_b, buffer_u16, argument0);
buffer_write(_b, buffer_s32, argument1);
buffer_write(_b, buffer_s32, argument2);
buffer_write(_b, buffer_u8, (_sp >> 4) & $FF);
buffer_write(_b, buffer_u8, ((_dir >> 8) & 15) | ((_sp & 15) << 4));
buffer_write(_b, buffer_u8, _dir & $FF);

XServer_send(mid_instance_4d);
#define XServer_instanceID
return ds_map_find_value(ds_map_find_value(global.__instance, ds_list_find_value(global.__instance_idmap, argument0)), "instance_id");

/*if(ds_map_exists(global.__instance, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__instance, argument0), "instance_id")
}else{
    return 0;
}*/
#define XServer_instanceN
return ds_list_size(global.__instance_idmap);
#define XServer_instance_get_varname
if(ds_map_exists(global.__instance, argument0))
{
    return ds_list_find_value(ds_map_find_value(ds_map_find_value(global.__instance, argument0), "variable_names"), argument1)
}else{
    return "";
}
#define XServer_instance_isfull
return ds_map_find_value(ds_map_find_value(global.__instance, ds_list_find_value(global.__instance_idmap, argument0)), "full_sync");

/*if(ds_map_exists(global.__instance, argument0))
{
    return ds_map_find_value(ds_map_find_value(global.__instance, argument0), "full_sync");
}else{
    return false;
}
#define XServer_instance_sync_ext
var __syncID = XServer_gainSyncID() + 1000000;
//SendInstance(1, local, (int)o_id, syncID, (int)x, (int)y, dir, speed);
XServer_instance_sendsync(1, argument0, argument2, __syncID, argument3, argument4, argument5, argument6, argument7);
global.__instance_varcount = 0;

var __i = XServer_new_instance(__syncID, argument1, argument3, argument4, argument5, argument6, false, gms_self_playerid());

ds_map_add(global.__instance, __syncID, __i);
ds_map_add(global.__instance_map, argument1, __syncID);
ds_list_add(global.__instance_idmap, __syncID);

return __syncID;
#define XServer_instance_sync_full
var __syncID = XServer_gainSyncID() + 1000000;
XServer_instance_sendsync(2, argument0, argument2, __syncID, argument3, argument4, argument5, argument6, argument7);

//XServer_instance_sendsync(2, local, (int)o_id, syncID, (int)x, (int)y, dir, speed, instanceOnce_count, instanceOnce_arguments);

//Instance *i = new Instance(syncID, (int)i_id, (int)x, (int)y, speed, dir, true);
//i->owner = player_id;
var __i = XServer_new_instance(__syncID, argument1, argument3, argument4, argument5, argument6, true, gms_self_playerid());

for(var __j = 0; __j < global.__instance_varcount; __j++)
{
    ds_map_add(__i, "*" + global.__instance_var[__j], global.__instance_val[__j]);
    ds_map_add(__i, ">" + global.__instance_var[__j], global.__instance_prec[__j]);
    ds_list_add(ds_map_find_value(__i, "variable_changed"), global.__instance_var[__j]);
    ds_list_add(ds_map_find_value(__i, "variable_names"), global.__instance_var[__j]);
}

ds_map_add(global.__instance, __syncID, __i);
ds_map_add(global.__instance_map, argument1, __syncID);
ds_list_add(global.__instance_idmap, __syncID);
global.__instance_varcount = 0;

return __syncID;
#define XServer_instance_sync_once
XServer_instance_sendsync(0, argument0, argument2, argument1, argument3, argument4, argument5, argument6, room);
global.__instance_varcount = 0;

return 1;
#define XServer_instance_sync_set_variable_real
argument0 = max(0, min(13, argument0));
global.__instance_var[argument0] = argument1;
global.__instance_val[argument0] = argument2;
global.__instance_prec[argument0] = argument3;

global.__instance_varcount = max(global.__instance_varcount, argument0 + 1);

return 0;
#define XServer_instance_sync_set_variable_string
argument0 = max(0, min(13, argument0));
global.__instance_var[argument0] = argument1;
global.__instance_val[argument0] = argument2;
global.__instance_prec[argument0] = argument3;

global.__instance_varcount = max(global.__instance_varcount, argument0 + 1);

return 0;
#define XServer_instance_varN
if(ds_map_exists(global.__instance, argument0))
{
    return ds_list_size(ds_map_find_value(ds_map_find_value(global.__instance, argument0), "variable_names"))
}else{
    return 0;
}
#define XServer_linksync
if(global.__debugging) show_debug_message("LinkSync: " + string(argument1) + " ==> " + string(argument0))
if(ds_map_exists(global.__instance, argument1))
{
    ds_map_replace(ds_map_find_value(global.__instance, argument1), "instance_id", argument0)
    ds_map_add(global.__instance_map, argument0, argument1);
    return argument0;
}else{
    return 0;
}
#define XServer_login_execute
if(!gms_info_isconnected())
{
    gms_connect();
    XServer_script_push(-3);
}else{
    XServer_preparesend();
    
    if(global.__login_password == "")
    {
        buffer_write(_b, buffer_u8, 0);
        XServer_writestring(_b, global.__login_username)
    }else{
        buffer_write(_b, buffer_u8, 1);
        XServer_writestring(_b, global.__login_username);
        XServer_writestring(_b, gms_sha512(global.__login_password + base64_decode("MFNTRkUsIGJ1dCBJVCBjaGFuZ2VzIChpdCBvbmx5IGJlY29tZXMgbG9uZ2VyKTogJzQwMDQ1ODNlYjhmYjdmODkhJw==")));
        buffer_write(_b, buffer_u8, string_length(global.__login_password));
        XServer_writestring(_b, gms_sha512(global.__login_password + global.__login_username + ("Y8d0cdofKW9J0ZxmfqE06VaelEQN8+CGaJ6sSJZEKmDVbQHJlAETkeQZtp6QjlWHJWrqu+CHkj4z14Sfh1FN2hKz1O0kUsdoNTrgMsPZHqCQ1kJFaxuowlPbjTuYzL8p6SIvhU/2Piy6RUrsjDnwgefmbQraodqi/")));
    }
    
    global.__name = global.__login_username;
    global.__login_username = "";
    global.__login_password = "";
    
    XServer_send(mid_login);
}
#define XServer_login_player_has_account
if(argument0 == "") return false;
if(!ds_map_exists(global.__login_accounts, argument0))
{
    XServer_preparesend();           
    XServer_writestring(_b, argument0);
    XServer_send(mid_playerinfo);
    
    ds_map_add(global.__login_accounts, argument0, -1);
    return -1;
}
return ds_map_find_value(global.__login_accounts, argument0);
#define XServer_other_index_changed
if(ds_map_exists(global.__player, argument0))
{
    var _m = ds_map_find_value(global.__player, argument0);
    if(ds_map_exists(_m, "%image_index"))
    {
        var _val = ds_map_find_value(_m, "%image_index");
        ds_map_replace(_m, "%image_index", 0);
        return _val;
    }else{
        return 0;
    }
}else{
    return 0;
}
#define XServer_p2p_send
XServer_preparesend();

XGms_cache_player_write(_b, argument1);
buffer_write(_b, buffer_u8, argument0);
buffer_write(_b, buffer_u8, global.__p2p_argument_count);
for(var i = 0; i < global.__p2p_argument_count; i++)
{
    XServer_writevaluetype(_b, global.__p2p_argument[i], 0.001);
}

global.__p2p_argument_count = 0;

XServer_send(mid_p2p);
#define XServer_p2p_set_real
global.__p2p_argument[argument0] = argument1;
global.__p2p_argument_count = max(argument0 + 1, global.__p2p_argument_count);
#define XServer_p2p_set_string
global.__p2p_argument[argument0] = argument1;
global.__p2p_argument_count = max(argument0 + 1, global.__p2p_argument_count);
#define XServer_request_file
show_error("File downloading is not supported in the Networking API version of GameMaker Server :(", true);
#define XServer_set_resource
XServer_preparesend();

buffer_write(_b, buffer_u8, argument0);
buffer_write(_b, buffer_s32, argument1);
XServer_writestring(_b, argument2);

XServer_send(mid_resource);
#define XServer_set_resource_sprite
XServer_preparesend();

buffer_write(_b, buffer_s32, argument0);//sid
XServer_writestring(_b, global.__sprite_resource);
buffer_write(_b, buffer_s32, argument1);//w
buffer_write(_b, buffer_s32, argument2);//h
buffer_write(_b, buffer_s32, argument3);//xo
buffer_write(_b, buffer_s32, argument4);//yo
buffer_write(_b, buffer_s32, argument5);//bbt
buffer_write(_b, buffer_s32, argument6);//bbl
buffer_write(_b, buffer_s32, argument7);//bbr
buffer_write(_b, buffer_s32, argument8);//bbb

XServer_send(mid_spriteresource);
#define XServer_set_resource_spritename
global.__sprite_resource = argument0;
#define XServer_step
global.__step_timer++;

XServer_network_update();

var pos = 0;
var buffersize = buffer_tell(_rr);
while(true)
{
    if(pos >= buffersize) break;
    
    buffer_seek(_rr, buffer_seek_start, pos);
    
    var tmp1, tmp2, size, prefixSize;
    tmp1 = buffer_read(_rr, buffer_u8);
    if(tmp1 % 2 == 1)
    {
        tmp2 = buffer_read(_rr, buffer_u8);
        size = (tmp1 >> 1) | (tmp2 << 7)
        prefixSize = 2;
    }else{
        size = tmp1 >> 1;
        prefixSize = 1;
    }
    
    //show_debug_message("Size: " + string(size) + ", buffersize: " + string(buffersize) + ", pos: " + string(pos) + ", prefixSize: " + string(prefixSize))
    
    if(size + pos + prefixSize <= buffersize)
    {
        var mid = buffer_read(_rr, buffer_u8);
        if(mid >= 190 && mid <= 253)
        {
            //Handle q4D message
            var _id = XGms_cache_player_read(_rr), mid_id = mid - 190;
            if(ds_map_exists(global.__player, _id))
            {
                var _m = ds_map_find_value(global.__player, _id);
                var _x = ds_map_find_value(_m, "#x"), 
                    _y = ds_map_find_value(_m, "#y"), 
                    _spd = ds_map_find_value(_m, "#speed"), 
                    _dir = ds_map_find_value(_m, "#direction"), _tmp, combi = false;
                //Update variables
                //X
                switch((mid_id >> 4) & 3)
                {
                    case 0:
                        //No X
                        break;
                    case 1:
                        _x = buffer_read(_rr, buffer_u16);
                        break;
                    case 2:
                        _x = buffer_read(_rr, buffer_s32);
                        break;
                    case 3:
                        //COMBI
                        combi = true;
                        break;
                }
                
                if(combi)
                {
                    switch ((mid_id >> 2) & 3)
                    {
                        case 0:
                            var b1 = buffer_read(_rr, buffer_u8),
                                b2 = buffer_read(_rr, buffer_u8),
                                b3 = buffer_read(_rr, buffer_u8);
                            
                            _x = ((b1 << 16) + (b2 << 8) + b3) % 4096
                            _y = (((b1 << 16) + (b2 << 8) + b3) >> 12) % 4096
                            break;
                        case 1:
                            _x = buffer_read(_rr, buffer_u8);
                            _y = buffer_read(_rr, buffer_u8);
                            break;
                        case 2:
                            _x = buffer_read(_rr, buffer_u8) * 2;
                            _y = buffer_read(_rr, buffer_u8) * 2;
                            break;
                        case 3:
                            _x = 0;
                            _y = 0;
                            break;
                    }
                }else{
                    //Y
                    switch ((mid_id >> 2) & 3)
                    {
                        case 0:
                            //No X
                            break;
                        case 1:
                            _y = buffer_read(_rr, buffer_u16);
                            break;
                        case 2:
                            _y = buffer_read(_rr, buffer_s32);
                            break;
                        case 3:
                            //COMBI
                            _y = buffer_read(_rr, buffer_u8) * 2;
                            break;
                    }
                }
                
                if (buffer_tell(_rr) < size + pos + prefixSize)
                {
                    if ((mid_id & 2) > 0)
                    {
                        switch (mid_id & 1)
                        {
                            case 0:
                                var b = buffer_read(_rr, buffer_u8);
                                _dir = (((b >> 4) & $F)) * 22.5;
                                _spd = (((b & $F))) - 8.0;
                                break;
                            case 1:
                                var b1 = buffer_read(_rr, buffer_u8),
                                    b2 = buffer_read(_rr, buffer_u8),
                                    b3 = buffer_read(_rr, buffer_u8);
                                
                                var us1 = ((b1 << 16) + (b2 << 8) + b3) % 4096,
                                    us2 = (((b1 << 16) + (b2 << 8) + b3) >> 12) % 4096;
                                _dir = us1 / 11.0;
                                _spd = us2 / 80.0 - 25.6;
                                break;
                        }
                    }
                    else
                    {
                        switch (mid_id & 1)
                        {
                            case 0:
                                _dir = (buffer_read(_rr, buffer_u8)) * 22.5;
                                break;
                            case 1:
                                _spd = (buffer_read(_rr, buffer_u8) - 128) / 8;
                                break;
                        }
                    }
                }
                
                var _delay = ds_map_find_value(_m, "#delay");
                if (_delay == 0)
                {
                    ds_map_replace(_m, "#speedCorrection", 0);
                }else{
                    ds_map_replace(_m, "#speedCorrection", (point_distance(ds_map_find_value(_m, "*x"), ds_map_find_value(_m, "*y"), _x, _y)) / _delay)
                }
                
                ds_map_replace(_m, "#x", _x)
                ds_map_replace(_m, "#y", _y)
                ds_map_replace(_m, "#speed", _spd)
                ds_map_replace(_m, "#direction", _dir)
                
                ds_map_replace(_m, "#delay", 0)
                
                ds_map_replace(_m, "#speedCorrection", _dir)
                
                //if(debug_mode) show_debug_message(string(_id) + ": 4d time: " + string((get_timer() - global.__last_4d) / 1000));
                global.__last_4d = get_timer();
                
                XServer_updatecoords(_m);
            }else{
                if(debug_mode) show_error("Server is sending corrupt player info (4D): Player does not exist (id = "+ string(_id) + ")", false);
            }
        }else{
            switch(mid)
            {
                case mid_hello:
                    if(debug_mode) show_debug_message("Connected!");
                    global.__connection_accepted = true;
                    break;
                case mid_time://56
                    global.__subtract_time = get_timer() / 1000000 - buffer_read(_rr, buffer_s32);
                    break;
                case mid_login:
                    var status = buffer_read(_rr, buffer_u8);
                    switch(status)
                    {
                        case 0:
                            global.__login_error = buffer_read(_rr, buffer_u8);
                            break;
                        case 2:
                            global.__login_save_code = buffer_read(_rr, buffer_string);
                            break;
                        case 1:
                            global.__loggedin = true;
                            global.__login_error = 0;
                            break;
                    }
                    XAction(34, 0);
                    break;
                case 3://Player variable
                    var _id = XGms_cache_player_read(_rr)
                    if(ds_map_exists(global.__player, _id))
                    {
                        var _m = ds_map_find_value(global.__player, _id),
                            _type = buffer_read(_rr, buffer_u8),
                            _name = "*" + XServer_readvariablename(_rr, 0, _type);
                        
                        if(_name == "*image_index")
                        {
                            ds_map_replace(_m, "%image_index", 1);
                        }
                        
                        if(ds_map_exists(_m, _name))
                        {
                            ds_map_replace(_m, _name, XServer_readvalue(_rr, global.__variable_receive_cache_type[0, _type]))
                        }else{
                            ds_map_add(_m, _name, XServer_readvalue(_rr, global.__variable_receive_cache_type[0, _type]))
                        }
                        if(debug_mode) show_debug_message(ds_map_find_value(_m, "*name") + " -> " + string(_name) + " = " + string(ds_map_find_value(_m, _name)));
                    }else{
                        if(debug_mode) show_error("Server is sending corrupt player info (variables): Player does not exist (id = "+ string(_id) + ")", false);
                    }
                    break;
                
                case 4://4D
                    var _id = XGms_cache_player_read(_rr)
                    if(ds_map_exists(global.__player, _id))
                    {
                        var _m = ds_map_find_value(global.__player, _id);
                        var _x, _y, _spd, _dir, _tmp;
                        _x = buffer_read(_rr, buffer_s32);
                        _y = buffer_read(_rr, buffer_s32);
                        _spd = buffer_read(_rr, buffer_u8) << 4;
                        _tmp = buffer_read(_rr, buffer_u8);
                        _spd |= (_tmp >> 4) & 15;
                        _dir = (buffer_read(_rr, buffer_u8) | ((_tmp & 15) << 8)) / 11;
                        _spd /= 80;
                        _spd -= 25.6;
                        
                        ds_map_replace(_m, "#x", _x)
                        ds_map_replace(_m, "#y", _y)
                        ds_map_replace(_m, "#speed", _spd)
                        ds_map_replace(_m, "#direction", _dir)
                        
                        //if(debug_mode) show_debug_message(string(_id) + ": 4d time: " + string((get_timer() - global.__last_4d) / 1000));
                        global.__last_4d = get_timer();
                        
                        XServer_updatecoords(_m);
                    }else{
                        if(debug_mode) show_error("Server is sending corrupt player info (4D): Player does not exist (id = "+ string(_id) + ")", false);
                    }
                    break;
                    
                case mid_global:
                    var _type = buffer_read(_rr, buffer_u8),
                        name = XServer_readvariablename(_rr, 1, _type);
                    if(debug_mode) show_debug_message("Global var " + name + ", " + string(_type))
                    
                    if(gms_global_exists(name))
                    {
                        ds_map_replace(global.__global, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[1, _type]))
                    }else{
                        ds_map_add(global.__global, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[1, _type]))
                    }
                    break;
                
                case mid_gameini_string:
                    var _type = buffer_read(_rr, buffer_u8),
                        name = XServer_readvariablename(_rr, 3, _type);
                    if(XServer_ini_game_exists(name))
                    {
                        ds_map_replace(global.__ini_game, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[3, _type]))
                    }else{
                        ds_map_add(global.__ini_game, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[3, _type]))
                    }
                    break;
                case mid_gameini_delete:
                    var name;
                    name = XServer_readstring(_rr);
                    ds_map_delete(global.__ini_game, name);
                    break;
                    
                case mid_playerini_string:
                    var _type = buffer_read(_rr, buffer_u8),
                        name = XServer_readvariablename(_rr, 2, _type);
                    if(XServer_ini_game_exists(name))
                    {
                        ds_map_replace(global.__ini_player, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[2, _type]))
                    }else{
                        ds_map_add(global.__ini_player, name, XServer_readvalue(_rr, global.__variable_receive_cache_type[2, _type]))
                    }
                    break;
                case mid_playerini_delete:
                    var name;
                    name = XServer_readstring(_rr);
                    ds_map_delete(global.__ini_player, name);
                    break;
                
                case 5:
                    var _type = buffer_read(_rr, buffer_u8),
                        _id   = XGms_cache_player_read(_rr);
                    
                    if(_type == 0 || _type == 2)
                    {
                        //SetPosition(16);
                        if(!ds_map_exists(global.__player, _id))
                        {
                            var _name = XServer_readstring(_rr);
                            
                            var _p = ds_map_create();
                            ds_map_add(_p, "id", _id);
                            ds_map_add(_p, "name", _name);
                            ds_map_add(_p, "has_changed", false);
                            ds_map_add(_p, "admininfo", 0);
                            
                            ds_map_add(_p, "#x", 0);
                            ds_map_add(_p, "#y", 0);
                            ds_map_add(_p, "#last-x", 0);
                            ds_map_add(_p, "#last-y", 0);
                            ds_map_add(_p, "#last-direction", 0);
                            ds_map_add(_p, "#sharpTurn", 0);
                            ds_map_add(_p, "#smoothSpeed", 0);
                            ds_map_add(_p, "#tickstart", 0);
                            ds_map_add(_p, "#tickend", 0);
                            ds_map_add(_p, "#speed", 0);
                            ds_map_add(_p, "#direction", 0);
                            ds_map_add(_p, "#delay", 0);
                            ds_map_add(_p, "#speedCorrection", 0);
                            
                            
                            ds_map_add(_p, "%image_index", 0);
                            
                            ds_map_add(_p, "*x", 0);
                            ds_map_add(_p, "*y", 0);
                            ds_map_add(_p, "*speed", 0);
                            ds_map_add(_p, "*direction", 0);
                            
                            ds_map_add(_p, "*name", _name);//* = variable
                            
                            ds_list_add(global.__player_idmap, _id);
                            ds_map_add(global.__player, _id, _p);
                            
                            XAction1((_type == 0) * 1 + (_type == 2) * 31, _id, _name);
                        }else{
                            //SetPosition(24);
                            if(debug_mode) show_error("The server is sending corrupt data: The player that was supposed to login, is already logged in.", false);
                        }
                    }else if(_type == 1 || _type == 3){
                        if(ds_map_exists(global.__player, _id))
                        {
                            ds_map_delete(global.__player, _id);
                            ds_list_delete(global.__player_idmap, ds_list_find_index(global.__player_idmap, _id));
                            //ShowError("Ereasing!");
                        }else{
                            if(debug_mode) show_error("Player possibly logged out without calling gms_logout, and is now stuck in the server.", false);
                        }
                        
                        XAction((_type == 0) * 2 + (_type == 2) * 32, _id);
                    }
                    break;
                    
                    
                case 7:
                    var _id = buffer_read(_rr, buffer_u8);
                    global.__team_score[_id] = buffer_read(_rr, buffer_f32);
                    break;
                    
                case 10:
                    var __sender = XGms_cache_player_read(_rr),
                        __color = buffer_read(_rr, buffer_s32), 
                        __text = XServer_readstring(_rr);
                    
                    var _a = ds_map_create();
                    ds_map_add(_a, "type", 3);
                    ds_map_add(_a, "from", __sender);
                    ds_map_add(_a, 0, __color);
                    ds_map_add(_a, 1, __text);
                    ds_map_add(_a, 2, string_length(__text));
                    ds_queue_enqueue(global.__actions, _a);
                    
                    break;
                    
                case 16:
                    if(global.__show_errors)
                    {
                        show_error("SERVER ERROR: " + XServer_readstring(_rr), false);
                    }
                    break;
                
                case 19:
                    global.__vs_ready = true;
                    XAction(29, 0);
                    break;
                case 20:
                    XAction(6, buffer_read(_rr, buffer_u8));
                    break;
                    
                case 21:
                    var __id = buffer_read(_rr, buffer_s32),
                        __type = buffer_read(_rr, buffer_u8);
                    XAction(7 + __type, __id);
                    break;
                    
                case 22:
                    var _sender = XGms_cache_player_read(_rr),
                        _id = buffer_read(_rr, buffer_u8),
                        _count = buffer_read(_rr, buffer_u8);
                    var _a = ds_map_create();
                    ds_map_add(_a, "type", 10);
                    ds_map_add(_a, "from", _sender);
                    
                    if(debug_mode) show_debug_message("P2p from " + string(_sender) + ", " + string(_count) + "arguments");
                    
                    ds_map_add(_a, 0, _id);
                    ds_map_add(_a, 1, _count);
                    for(var i = 0; i < _count; i++)
                    {
                        var _type = buffer_read(_rr, buffer_u8),
                            _val = XServer_readvalue(_rr, _type);
                        if(debug_mode) show_debug_message("Type " + string(_type) + " => " + string(_val))
                        ds_map_add(_a, i + 2, _val);
                    }
                    ds_queue_enqueue(global.__actions, _a);
                    break;
                    
                case 24:
                    global.__player_id = buffer_read(_rr, buffer_u16);
                    break;
                    
                case 25:
                    global.__sync_pos_start = buffer_read(_rr, buffer_u16);
                    global.__sync_pos_max   = buffer_read(_rr, buffer_u16);
                    global.__sync_pos = global.__sync_pos_start;
                    break;
                    
                case 35:
                    global.__ini_game_limit = buffer_read(_rr, buffer_u16);
                    global.__ini_player_limit = buffer_read(_rr, buffer_u16);
                    global.__num_logins = buffer_read(_rr, buffer_u32);
                    break;
                    
                case 40://Achievement
                    var _a_id = buffer_read(_rr, buffer_u32),
                        _text = XServer_readstring(_rr),
                        _short_name = XServer_readstring(_rr);
                    
                    var _m = ds_map_create();
                    ds_map_add(_m, "id", _a_id);
                    ds_map_add(_m, "text", _text);
                    ds_map_add(_m, "short_name", _short_name);
                    ds_map_add(_m, "value", false);
                    
                    ds_map_add(global.__achievement, _short_name, _m);
                    ds_list_add(global.__achievement_idmap, _short_name);
                    ds_map_add(global.__achievement_idmap2, _a_id, _short_name);
                    if(global.__show_errors) show_debug_message("Achievement: " + _short_name + " => " + _text);
                    break;
                case 41://Achievement reached
                    var _a_id = buffer_read(_rr, buffer_u32),
                        _a_sn = ds_map_find_value(global.__achievement_idmap2, _a_id);
                    if(ds_map_exists(global.__achievement, _a_sn))
                    {
                        if(global.__show_errors) show_debug_message("Achievement " + string(_a_sn) + " has been reached");
                        ds_map_replace(ds_map_find_value(global.__achievement, _a_sn), "value", true);
                    }
                    break;
                    
                case 42://Highscorelist (create)
                    var _h_id = buffer_read(_rr, buffer_u32),
                        _name = XServer_readstring(_rr);
                    
                    if(global.__show_errors) show_debug_message("Creating highscorelist " + string(_h_id));
                    if(!gms_highscore_list_exists(_h_id))
                    {
                        if(global.__show_errors) show_debug_message("Success.");
                        var _h = ds_map_create();
                        ds_map_add(_h, "names", ds_list_create());
                        ds_map_add(_h, "scores", ds_list_create());
                        ds_map_add(_h, "list_title", _name);
                        
                        ds_map_add(global.__highscore, _h_id, _h);
                        ds_list_add(global.__highscore_ids, _h_id);
                    }
                    break;
                case 43://Add highscore to highscorelist
                    var _h_id = buffer_read(_rr, buffer_u32),
                        _name = XServer_readstring(_rr),
                        _score = buffer_read(_rr, buffer_f64);
                    if(debug_mode) show_debug_message("Highscorelist " + string(_h_id) + ": " + _name + " => " + string(_score));
                    if(gms_highscore_list_exists(_h_id))
                    {
                        if(debug_mode) show_debug_message("Success.");
                        ds_list_add(ds_map_find_value(ds_map_find_value(global.__highscore, _h_id), "names"), _name);
                        ds_list_add(ds_map_find_value(ds_map_find_value(global.__highscore, _h_id), "scores"), _score);
                    }
                    break;
                case 44://Clear highscore list
                    var _h_id = buffer_read(_rr, buffer_u32);
                    if(debug_mode) show_debug_message("Clearing highscorelist " + string(_h_id));
                    if(gms_highscore_list_exists(_h_id))
                    {
                        if(debug_mode) show_debug_message("Success.");
                        ds_list_clear(ds_map_find_value(ds_map_find_value(global.__highscore, _h_id), "names"));
                        ds_list_clear(ds_map_find_value(ds_map_find_value(global.__highscore, _h_id), "scores"));
                    }
                    break;
                case 45:
                    global.__guest_highscore_result = buffer_read(_rr, buffer_u8);
                    break;
                    
                case 46:
                    var _user_id = buffer_read(_rr, buffer_u32),
                        _name = XServer_readstring(_rr);
                    
                    if(!ds_map_exists(global.__friend, _user_id))
                    {
                        var _map = ds_map_create();
                        if(debug_mode) show_debug_message("Friend " + _name);
                        ds_map_add(_map, "name", _name);
                        ds_map_add(_map, "user_id", _user_id);
                        ds_map_add(_map, "online", false);
                        
                        ds_map_add(global.__friend, _user_id, _map);
                        ds_list_add(global.__friend_idmap, _user_id);
                    }
                    break;
                case 47:
                    var _user_id = buffer_read(_rr, buffer_u32),
                        _name = XServer_readstring(_rr);
                    
                    if(ds_map_exists(global.__friend, _user_id))
                    {
                        var _map = ds_map_find_value(global.__friend, _user_id);
                        ds_map_replace(_map, "online", true);
                        
                        XAction(15, _user_id);
                    }
                    break;
                case 48:
                    var _user_id = buffer_read(_rr, buffer_u32),
                        _name = XServer_readstring(_rr);
                    
                    if(ds_map_exists(global.__friend, _user_id))
                    {
                        var _map = ds_map_find_value(global.__friend, _user_id);
                        ds_map_replace(_map, "online", false);
                        
                        XAction(16, _user_id);
                    }
                    break;
                    
                case 49:
                    global.__self_admininfo = buffer_read(_rr, buffer_u8);
                    break;
                    
                case 50://Guest info
                    global.__player_isguest = true;
                    global.__name = "Guest_" + global.__name;
                    break;
                case 51:
                    var _user_id = XGms_cache_player_read(_rr),
                        _rights = buffer_read(_rr, buffer_u8);
                    
                    if(ds_map_exists(global.__player, _user_id))
                    {
                        ds_map_replace(ds_map_find_value(global.__player, _user_id), "admininfo", _rights);
                    }else{
                        if(debug_mode) show_error("Server is sending corrupt admin info", false);
                    }
                    break;
                //52 aan het einde
                    
                case 53:
                    global.__master_player = XGms_cache_player_read(_rr);
                    break;
                    
                case 54://Statistic
                    var _s_id = buffer_read(_rr, buffer_u32),
                        _text = XServer_readstring(_rr),
                        _short_name = XServer_readstring(_rr);
                        
                    var _m = ds_map_create();
                    ds_map_add(_m, "id", _s_id);
                    ds_map_add(_m, "text", _text);
                    ds_map_add(_m, "short_name", _short_name);
                    ds_map_add(_m, "value", 0);
                    
                    ds_map_add(global.__stat, _short_name, _m);
                    ds_list_add(global.__stat_idmap, _short_name);
                    break;
                case 55://Statistic value
                    var _s_id = buffer_read(_rr, buffer_u32),
                        _val = buffer_read(_rr, buffer_f64);
                    if(ds_map_exists(global.__stat, _s_id))
                    {
                        ds_map_replace(ds_map_find_value(global.__stat, _s_id), "value", _val);
                    }else{
                        show_debug_message("Unknown statistic received");
                    }
                    break;
                //mid_time    
                case 58:
                    global._friend_request_result = buffer_read(_rr, buffer_u8);
                    XAction1(36, global._friend_request_result, global._friend_request_result);
                    break;
                    
                case 60://Force setvar; Not working, studio can't set variabeles
                    break;
                    
                
                case 65://Update not working, can't download/replace files with GM:Studio
                    global.__update_avaiable    = true;
                    global.__received_update    = true;
                    break;
                case 66:
                    global.__update_avaiable    = false;
                    global.__received_update    = true;
                    break;
                    
                case 80:
                    var __room = buffer_read(_rr, buffer_s32);
                    XAction1(21, 0, __room);
                    break;
                case 81:
                    XAction(22, 0);
                    break;
                case 82:
                    XAction(23, 0);
                    break;
                case 83:
                    XAction(24, 0);
                    break;
                case 84:
                    XAction1(25, 0, buffer_read(_rr, buffer_s32));
                    break;
                
                case 85:
                    XAction(26, 0);
                    break;
                    
                case 90:
                    global.__vs_time = buffer_read(_rr, buffer_s32);
                    if(global.__show_errors) show_debug_message("Time left: " + string(global.__vs_time))
                    break;
                    
                case 91:
                    XAction(29, 0);
                    
                    global.__vs_ready = false;
                    
                    XServer_clear_map_map(global.__player);
                    XServer_clear_instances(global.__instance);
                    break;
                
                    
                case 92:
                    global.__session_id = buffer_read(_rr, buffer_u16);
                    XAction(28, global.__session_id);
                    break;
                    
                case 94:
                    while(ds_list_size(global.__session) > 0)
                    {
                        ds_map_destroy(ds_list_find_value(global.__session, 0));
                        ds_list_delete(global.__session, 0);
                    }
                    var num = buffer_read(_rr, buffer_u8);
                    for(var i = 0; i < num; i++)
                    {
                        var _m = ds_map_create();
                        ds_map_add(_m, "id", buffer_read(_rr, buffer_u32));
                        ds_map_add(_m, "type", buffer_read(_rr, buffer_u8));
                        ds_map_add(_m, "players", buffer_read(_rr, buffer_u8));
                        ds_list_add(global.__session, _m);
                    }
                    break;
                    
                case 97:
                    var udp_unique = buffer_read(_rr, buffer_u32),
                        udp_port = buffer_read(_rr, buffer_u32);
                    break;
                case 98://UDP not supproted right now...
                    break;
                    
                case mid_instance_destroy:
                    var __syncID = buffer_read(_rr, buffer_u16) + 1000000;
                    var _a = ds_map_create();
                    
                    if(debug_mode) show_debug_message("Destroy " + string(__syncID));
                    ds_map_add(_a, "type", 11);
                    ds_map_add(_a, "from", 0);
                    ds_map_add(_a, 0, __syncID);
                    
                    if(ds_map_exists(global.__instance, __syncID))
                    {
                        if(debug_mode) show_debug_message("IID: " + string(ds_map_find_value(ds_map_find_value(global.__instance, __syncID), "instance_id")))
                        ds_map_add(_a, 1, ds_map_find_value(ds_map_find_value(global.__instance, __syncID), "instance_id"));
                        
                        XServer_instance_destroy(__syncID);
                    }
                    ds_queue_enqueue(global.__actions, _a);
                    break;
                case 61:
                    var __syncID = buffer_read(_rr, buffer_u16) + 1000000;
                    if(ds_map_exists(global.__instance, __syncID))
                    {
                        var _s = ds_map_find_value(global.__instance, __syncID),
                            _type = buffer_read(_rr, buffer_u8),
                            _name = XServer_readvariablename(_rr, 5, _type),
                            _val  = XServer_readvalue(_rr, global.__variable_receive_cache_type[5, _type]);
                        
                        if(ds_map_exists(_s, "*" + _name))
                        {
                            ds_map_replace(_s, "*" + _name, _val);
                        }else{
                            ds_map_add(_s, "*" + _name, _val);
                            ds_map_add(_s, ">" + _name, 0.01);
                        }
                    }else{
                        if(debug_mode) show_debug_message("Server sent unknown syncID")
                    }
                    break;
                
                case 62:
                    var __syncID = buffer_read(_rr, buffer_u16) + 1000000;
                    if(ds_map_exists(global.__instance, __syncID))
                    {
                        var _m = ds_map_find_value(global.__instance, __syncID);
                        var _x, _y, _spd, _dir, _tmp;
                        _x = buffer_read(_rr, buffer_s32);
                        _y = buffer_read(_rr, buffer_s32);
                        _spd = buffer_read(_rr, buffer_u8) << 4;
                        _tmp = buffer_read(_rr, buffer_u8);
                        _spd |= (_tmp >> 4) & 15;
                        _dir = (buffer_read(_rr, buffer_u8) | ((_tmp & 15) << 8)) / 11;
                        _spd /= 80;
                        _spd -= 25.6;
                        
                        ds_map_replace(_m, "#x", _x)
                        ds_map_replace(_m, "#y", _y)
                        ds_map_replace(_m, "#speed", _spd)
                        ds_map_replace(_m, "#direction", _dir)
                        
                        XServer_updatecoords(_m);
                    }else{
                        if(debug_mode) show_debug_message("Server sent unknown syncID")
                    }
                    break;
                case 63:
                    var __syncID = buffer_read(_rr, buffer_u16) + 1000000,
                        __newOwner = XGms_cache_player_read(_rr);
                    var _m = XServer_instance_find(__syncID);
                    if(_m != -1)
                    {
                        ds_map_replace(_m, "owner", __newOwner);
                    }else{
                        if(debug_mode) show_debug_message("Received takeover-request for instance that does not exist.")
                    }
                    break;
                
                case 26:
                case 27:
                case 8:
                case 28:
                case 29:
                case 30:
                    show_debug_message("Syncing instance...")
                    XServer_readinstance(mid, _rr);
                    break;
                case 52:
                    global.__register_status = buffer_read(_rr, buffer_u8);
                    XAction(35, 0);
                    if(debug_mode) show_debug_message("Register status: " + string(global.__register_status));
                    break;
                    
                case 100://ping
                case 101:
                    global.__socket_ping = buffer_read(_rr, buffer_u8) * 3 + 768 * (mid == 101);
                    XServer_preparesend();
                    XServer_send(100);
                    //if(debug_mode) show_debug_message("Ping: " + string(global.__socket_ping));
                    break;
                case 131:
                    global.__name = XServer_readstring(_rr);
                    break;
                case 132:
                    global.__loc_isonum = buffer_read(_rr, buffer_u32);
                    global.__loc_countrycode = XServer_readstring(_rr);
                    global.__loc_countryname = XServer_readstring(_rr);
                    global.__loc_languages = XServer_readstring(_rr);
                    break;
                case 133:
                case 134:
                case 135:
                case 136:
                case 137:
                case 138:
                    var _index = buffer_read(_rr, buffer_u8);
                    global.__variable_receive_cache_name[mid - 133, _index] = XServer_readstring(_rr);
                    global.__variable_receive_cache_type[mid - 133, _index] = buffer_read(_rr, buffer_u8);
                    break;
                case 140:
                    var _cacheID = buffer_read(_rr, buffer_u8);
                    global.__player_receive_cache[_cacheID] = (buffer_read(_rr, buffer_u32) << 32) | buffer_read(_rr, buffer_u32);
                    break;
                case mid_playerinfo:
                    var name = XServer_readstring(_rr), value = buffer_read(_rr, buffer_s32);
                    ds_map_replace(global.__login_accounts, name, value);
                    break;
                case 254:
                    show_error(XServer_readstring(_rr), true);
                    game_end();
                    break;
                    
                case 255:
                    global.__statuscode = buffer_read(_rr, buffer_u8);
                    XAction1(20, 0, XServer_readstring(_rr));
                    gms_logout();
                    break;
                default:
                    if(global.__show_errors) show_debug_message("Unknown mid: " + string(mid) + "; Size: " + string(size));
                    break;
            }
        }
        
        pos += size + prefixSize;
    }else{
        break;
    }
}

if(buffersize - pos > 0)
{
    buffer_copy(_rr, pos, buffersize - pos, _rb, 0);
    //show_debug_message("Bytes left: " + string(buffersize - pos));
    var swap = _rb;
    _rb = _rr;
    _rr = swap;
    buffer_seek(_rr, buffer_seek_start, buffersize - pos);
}else{
    buffer_seek(_rr, buffer_seek_start, 0);
}



if(global.__loggedin)// && (get_timer() - global.__last_send > global.__timer_threshold))
{
    //global.__last_send = get_timer();
    for(var i = 0; i < ds_list_size(global.__global_changed); i++)
    {
        var name = ds_list_find_value(global.__global_changed, i);
        XServer_preparesend();
    
        XServer_writevariable(_b, 1, name, ds_map_find_value(global.__global, name), ds_map_find_value(global.__global_prec, name));
        
        XServer_send(mid_global)
    }
    ds_list_clear(global.__global_changed);
    
    for(var i = 0; i < ds_list_size(global.__self_changed); i++)
    {
        var name = ds_list_find_value(global.__self_changed, i);
        XServer_preparesend();
    
        if(debug_mode) show_debug_message("Sending variable " + name + " = " + string(ds_map_find_value(global.__self, name)));
        
        XServer_writevariable(_b, 0, name, ds_map_find_value(global.__self, name), ds_map_find_value(global.__self_prec, name));
        
        XServer_send(mid_variable)
    }
    ds_list_clear(global.__self_changed);
    
    for(var i = 0; i < ds_list_size(global.__instance_idmap); i++)
    {
        var __syncID = ds_list_find_value(global.__instance_idmap, i),
            _s = ds_map_find_value(global.__instance, __syncID),
            _l = ds_map_find_value(_s, "variable_changed");
            
        if(ds_map_find_value(_s, "owner") != gms_self_playerid() && ds_map_find_value(_s, "full_sync"))
        {
            XServer_updateposition(_s);
        }
        
        for(var _j = 0; _j < ds_list_size(_l); _j++)
        {
            XServer_preparesend();
            
            buffer_write(_b, buffer_u16, __syncID - 1000000);
            var _name = ds_list_find_value(_l, _j);
            XServer_writevariable(_b, 5, _name, ds_map_find_value(_s, "*" + _name), ds_map_find_value(_s, ">" + _name));
            
            XServer_send(mid_instancevar);
        }
        
        ds_list_clear(_l);
        
        if(ds_map_find_value(_s, "has_moved"))
        {
            ds_map_replace(_s, "has_moved", 0);
            XServer_instance4d(__syncID - 1000000, ds_map_find_value(_s, "x"), ds_map_find_value(_s, "y"), ds_map_find_value(_s, "speed"), ds_map_find_value(_s, "direction"));
        }
    }
    
    if(global.__self_position_changed)
    {
        if(global.__self_prev_x + lengthdir_x(global.__self_speed, global.__self_direction) == global.__self_x &&   
            global.__self_prev_y + lengthdir_y(global.__self_speed, global.__self_direction) == global.__self_y &&
            global.__current_skip > 0)
        {
            global.__current_skip -= 1;
        }else{
            XServer_preparesend();
            
            var _mid = XServer_write4d(global.__self_position_changed, global.__self_x, global.__self_y, global.__self_speed, global.__self_direction);
            
            XServer_send(190 + _mid);
            global.__self_position_changed = 0;
            global.__current_skip = global.__max_skip;
        }
    }
    
    var count = ds_queue_size(global.__socket_script_queue);
    for(var  i = 0; i < count; i++)
    {
        if(ds_queue_head(global.__socket_script_queue) == -3)
        {
            ds_queue_dequeue(global.__socket_script_queue)
            XServer_login_execute();
        }else{
            script_execute(ds_queue_dequeue(global.__socket_script_queue));
        }
    }
}

for(var i = 0; i < ds_list_size(global.__player_idmap); i++)
{
    var _id = ds_list_find_value(global.__player_idmap, i);
    var _player = ds_map_find_value(global.__player, _id);
    
    XServer_updateposition(_player);
}

XServer_flush();
#define XServer_clear_instances
var __s = 0;
while(ds_map_size(argument0) > 0)
{
    __s = ds_map_find_value(argument0, ds_map_find_first(argument0));
    ds_list_destroy(ds_map_find_value(__s, "variable_names"));
    ds_list_destroy(ds_map_find_value(__s, "variable_changed"));
    ds_map_destroy(__s);
    ds_map_delete(argument0, ds_map_find_first(argument0));
}
ds_map_clear(argument0);
#define gms_network
if(ds_map_find_value(async_load, "id") == global.__socket)
{
    switch(ds_map_find_value(async_load, "type"))
    {
        case network_type_data:
            global.__socket_connected = true;
            global.__socket_connecting = false;
            var buffersize = max(0, ds_map_find_value(async_load, "size")) + max(0, buffer_tell(_rr));
            
            if(buffer_get_size(_rr) <= buffersize)
            {
                var newsize = ceil((buffersize + 1) / 2048) * 2048
                buffer_resize(_rr, newsize);
            }
            
            buffer_copy(ds_map_find_value(async_load, "buffer"), 0, ds_map_find_value(async_load, "size"), _rr, buffer_tell(_rr));
            buffer_seek(_rr, buffer_seek_start, buffersize);
            break;
    }
}
#define XServer_script_push
ds_queue_enqueue(global.__socket_script_queue, argument0);
#define XServer_preparesend
buffer_seek(_b, buffer_seek_start, 0);
#define XAction
var _a = ds_map_create();
ds_map_add(_a, "type", argument0);
ds_map_add(_a, "from", argument1);
ds_queue_enqueue(global.__actions, _a);
#define XAction1
var _a = ds_map_create();
ds_map_add(_a, "type", argument0);
ds_map_add(_a, "from", argument1);
ds_map_add(_a, 0, argument2);
ds_queue_enqueue(global.__actions, _a);
#define XServer_writestring
///XServer_writestring(buffer, str)
if(!is_string(argument1)) return 0;
buffer_write(argument0, buffer_u16, string_length(argument1))
buffer_write(argument0, buffer_string, argument1);
buffer_seek(argument0, buffer_seek_relative, -1);
#define XServer_readstring
///XServer_readstring(buffer);
var _len = buffer_read(argument0, buffer_u16);
if(_len > 0)
{
    buffer_seek(_sb, buffer_seek_start, _len);
    buffer_copy(argument0, buffer_tell(argument0), _len, _sb, 0);
    buffer_write(_sb, buffer_u16, 0);
    buffer_seek(argument0, buffer_seek_relative, _len );
    buffer_seek(_sb, buffer_seek_start, 0);
    return buffer_read(_sb, buffer_string);
}else{
    return "";
}
#define XServer_dbwts
if(is_string(argument0)) return VAR_STRING;
if(abs(1 - argument0) < argument1)
{
return VAR_BOOL_1;
}else if(abs(0 - argument0) < argument1)
{
return VAR_BOOL_0;
}else if(argument0 >= 0 && argument0 <= 1 && XServer_cPrec(argument0, 0.003921) < argument1)
{
return VAR_BYTE_D255;
}else if(argument0 >= -10 && argument0 <= 10 && XServer_cPrec(argument0, 0.07843) < argument1)
{
return VAR_SBYTE_D25;
}else if(argument0 >= -25 && argument0 <= 25 && XServer_cPrec(argument0, 0.19607) < argument1)
{
return VAR_SBYTE_D10;
}else if(argument0 >= 0 && argument0 <= 255 && XServer_cPrec(argument0, 1) < argument1)
{
return VAR_BYTE;
}else if(argument0 >= 0 && argument0 <= 364.0833 && XServer_cPrec(argument0, 0.0055555) < argument1)
{
return VAR_USHORT_D180;
}else if(argument0 >= 0 && argument0 <= 655.3500 && XServer_cPrec(argument0, 0.01) < argument1)
{
return VAR_USHORT_D100;
}else if(argument0 >= 0 && argument0 <= 65535 && XServer_cPrec(argument0, 1) < argument1)
{
return VAR_USHORT;
}else if(argument0 >= -2147483.647 && argument0 <= 2147483.647 && XServer_cPrec(argument0, 0.001) < argument1)
{
return VAR_INT_D1000;
}else if(argument0 >= -2147483647 && argument0 <= 2147483647 && XServer_cPrec(argument0, 1) < argument1)
{
return VAR_INT;
}else if(argument0 >= -1 * FLT_MAX && argument0 <= FLT_MAX && XServer_cPrec(argument0, 0.0001) < argument1)
{
return VAR_FLOAT;
}else{
return VAR_DOUBLE;
}
#define XServer_cPrec
return abs(round(argument0 / argument1) * argument1 - argument0);
#define XServer_writevaluetype
//buffer, value, precision
var type = XServer_dbwts(argument1, argument2);
buffer_write(argument0, buffer_u8, type);
XServer_writevalue(argument0, argument1, type);
#define XServer_writevalue
//XServer_writevalue(buffer, value, type)
if(argument2 == VAR_DOUBLE)
{
    buffer_write(argument0, buffer_f64, argument1);
}else if(argument2 == VAR_BYTE_D255)
{
    buffer_write(argument0, buffer_u8, round(argument1 * 255.0));
}else if(argument2 == VAR_SBYTE_D25)
{
    buffer_write(argument0, buffer_s8, round((argument1 + 10.0) * 12.25));
}else if(argument2 == VAR_SBYTE_D10)
{
    buffer_write(argument0, buffer_s8, round((argument1 + 25.0) * 5.0));
}else if(argument2 == VAR_BYTE_D2)
{
    buffer_write(argument0, buffer_u8, (argument1 * 2.55));
}else if(argument2 == VAR_BYTE)
{
    buffer_write(argument0, buffer_u8, round(argument1));
}else if(argument2 == VAR_USHORT_D180)
{
    buffer_write(argument0, buffer_u16, round(argument1 * 180.0));
}else if(argument2 == VAR_USHORT_D100)
{
    buffer_write(argument0, buffer_u16, round(argument1 * 100.0));
}else if(argument2 == VAR_USHORT)
{
    buffer_write(argument0, buffer_u16, round(argument1));
}else if(argument2 == VAR_INT_D1000)
{
    buffer_write(argument0, buffer_s32, round(argument1 * 1000.0));
}else if(argument2 == VAR_INT)
{
    buffer_write(argument0, buffer_s32, round(argument1));
}else if(argument2 == VAR_FLOAT)
{
    buffer_write(argument0, buffer_f32, argument1);
}else if(argument2 == VAR_STRING)
{
    XServer_writestring(argument0, argument1);
}else if(argument2 != VAR_BOOL_0 && argument2 != VAR_BOOL_1){
    show_debug_message("Unknown send type for value");
}
#define XServer_writevariable
///XServer_writevariable(buffer, cacheID, variable, value, precision)
var _type = XServer_dbwts(argument3, argument4);
if(XGms_cache_variable_write(argument0, argument1, argument2, _type))
{
    XServer_writevalue(argument0, argument3, _type);
}else{
    if(_type != VAR_STRING) _type = VAR_DOUBLE;//VAR_STRING = 1, VAR_DOUBLE = 0
    buffer_write(argument0, buffer_u8, !_type);//String = 0, double = 1
    XServer_writestring(argument0, argument2);
    XServer_writevalue(argument0, argument3, _type);
}
#define XServer_readvalue
///XServer_readvalue(buffer, send type);
switch(argument1)
{
    case VAR_DOUBLE:
        return buffer_read(argument0, buffer_f64);
    case VAR_BYTE_D255:
        return buffer_read(argument0, buffer_u8) / 255.0;
    case VAR_SBYTE_D25:
        return buffer_read(argument0, buffer_s8) / 12.25 - 10.0;
    case VAR_SBYTE_D10:
        return buffer_read(argument0, buffer_s8) / 5.0 - 25;
    case VAR_BYTE_D2:
        return buffer_read(argument0, buffer_u8) / 2.5;
    case VAR_BYTE:
        return buffer_read(argument0, buffer_u8);
    case VAR_USHORT_D180:
        return buffer_read(argument0, buffer_u16) / 180.0;
    case VAR_USHORT_D100:
        return buffer_read(argument0, buffer_u16) / 100.0;
        break;
    case VAR_USHORT:
        return buffer_read(argument0, buffer_u16);
    case VAR_INT_D1000:
        return (buffer_read(argument0, buffer_s32) / 1000.0);
    case VAR_INT:
        return buffer_read(argument0, buffer_s32);
    case VAR_FLOAT:
        return buffer_read(argument0, buffer_f32);
    case VAR_BOOL_0:
        return 0;
    case VAR_BOOL_1:
        return 1;
    case VAR_STRING:
        return XServer_readstring(argument0);
    default:
        if(argument1 == 25)
        {
            return XServer_readstring(argument0);
        }else if(argument1 == 26 || argument1 == 27)
        {
            return argument1 == 27
        }else if(argument1 >= 28 && argument1 <= 48)
        {
            return (argument1 - 28) / 20.0;
        }else if(argument1 == 49)
        {
            return buffer_read(argument0, buffer_u16) / 180.0
        }else if(argument1 == 50)
        {
            return buffer_read(argument0, buffer_s32);
        }else if(argument1 == 51)
        {
            return buffer_read(argument0, buffer_u8);
        }else if(argument1 == 52)
        {
            return buffer_read(argument0, buffer_u8) / 12.25 - 10.0;
        }else if(argument1 == 53)
        {
            return (floor(((buffer_read(argument0, buffer_u8)) / 12.25 - 10.0)*10.0)/10.0);
        }else if(argument1 == 54)
        {
            return (floor(((buffer_read(argument0, buffer_u8)) / 12.25 - 10.0)*10.0)/10.0);
        }else if(argument1 == 55)
        {
            return buffer_read(argument0, buffer_s32)
        }else if(argument1 == 56 || argument1 == 57)
        {
            return argument1 == 57
        }else if(argument1 == 58)
        {
            return (buffer_read(argument0, buffer_u8)) / 5.0 - 25.0;
        }else if(argument1 == 59)
        {
            return buffer_read(argument0, buffer_u16);
        }else if(argument1 == 60)
        {
            return ((buffer_read(argument0, buffer_u8)) / 25.5 - 10.0);
        }else if(argument1 == 61)
        {
            return buffer_read(argument0, buffer_u8) / 2.5;
        }else if(argument1 == 62)
        {
            return buffer_read(argument0, buffer_u8);
        }else if (argument1 >= 63 && argument1 <= 73)
        {
            return (argument1 - 63);
        }else{
            return 255;
        }
        break;
}
#define XServer_write4d
///XServer_write4d(_flags, x, y, speed, direction)
/*var _dir, _sp;
_dir = round(argument3 * 11)
_sp = round((argument2 + 25.6) * 80);

buffer_write(_b, buffer_s32, argument0);
buffer_write(_b, buffer_s32, argument1);
buffer_write(_b, buffer_u8, (_sp >> 4) & $FF);
buffer_write(_b, buffer_u8, ((_dir >> 8) & 15) | ((_sp & 15) << 4));
buffer_write(_b, buffer_u8, _dir & $FF);*/

var _id = 0, _flags = argument0;
if (argument1 == 0 && argument2 == 0)
{
    //2x 0: 1111xx
    _id |= 60;
}else{
    if (_flags & MOD_X)
    {
        if (_flags & MOD_Y)
        {
            //Combies: 11xxxx
            if (argument1 >= 0 && argument1 <= 255 && argument2 >= 0 && argument2 <= 255)
            {
                //Byte combo: 1101xx
                _id |= 52;
                buffer_write(_b, buffer_u8, argument1);
                buffer_write(_b, buffer_u8, argument2);
            }else if (argument1 >= 0 && argument1 <= 510 && argument2 >= 0 && argument2 <= 510 && !(argument1 & 1) && !(argument2 & 1)){
                //Byte * 2 combo: 1110xx
                _id |= 56;
                buffer_write(_b, buffer_u8, (argument1 / 2));
                buffer_write(_b, buffer_u8, (argument2 / 2));
            }else if (argument1 >= 0 && argument1 <= 4095 && argument2 >= 0 && argument2 <= 4095){
                //24bit combi: 1100xx
                _id |= 48;
                var __comb = round(argument1) + round((argument2) << 12);
                buffer_write(_b, buffer_u8, __comb >> 16);
                buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
                buffer_write(_b, buffer_u8, __comb % 256);
            }else if(argument1 >= 0 && argument1 <= 65535 &&  argument2 >= 0 && argument2 <= 65535) {
                //2x ushort: 0101xx
                _id |= 20;
                buffer_write(_b, buffer_u16, argument1);
                buffer_write(_b, buffer_u16, argument2);
            }else{
                //2x int: 1010xx
                _id |= 40;
                buffer_write(_b, buffer_s32, argument1);
                buffer_write(_b, buffer_s32, argument2);
            }
        }else{
            if (argument1 >= 0 && argument1 <= 65535)
            {
                //X ushort, no Y: 0100xx
                _id |= 16;
                buffer_write(_b, buffer_u16, argument1);
            }else{
                //X int, no Y: 1000xx
                _id |= 32;
                buffer_write(_b, buffer_s32, argument1);
            }
        }
    }
    else if (_flags & MOD_Y)
    {
        if (!((argument2) & 1) && argument2 < 510 && argument2 >= 0)
        {
            //Y byte * 2, no X: 0011xx
            _id |= 12;
            buffer_write(_b, buffer_u8, (argument2 / 2));
        }else if (y >= 0 && y <= 4095){
            //Y ushort, no X: 0001xx
            _id |= 4;
            buffer_write(_b, buffer_u16, argument2);
        }else{
            //Y int, no X: 
            _id |= 8;
            buffer_write(_b, buffer_s32, argument2);
        }
    }else{
        //No X or Y
        _id |= 0;
    }
}

//Now let's do the argument4 & argument3
if (_flags & MOD_DIR)
{
    if (_flags & MOD_SPEED)
    {
        //Combo
        if (((argument4 * 2)) % 45 == 0 && argument3 >= -8 && argument3 <= 8)
        {
            //8bit combo
            _id |= 2;
            buffer_write(_b, buffer_u8, ((round(argument3 + 8) & $F) | ((round(argument4 / 22.5) & $F) << 4)));
        }else{
            //24bit combo
            _id |= 3;
            var __comb = round(argument4 * 11) + ((round((argument3 + 25.6) * 80) << 12));
            buffer_write(_b, buffer_u8, __comb >> 16);
            buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
            buffer_write(_b, buffer_u8, __comb % 256);
        }
    }else{
        if (((argument4 * 2)) % 45 == 0)
        {
            //Combo is preciezer: Het kan exact worden uitgedrukt
            _id |= 2;
            buffer_write(_b, buffer_u8, ((round(argument3 + 8) & $F) | ((round(argument4 / 22.5) & $F) << 4)));
        }else{
            //Alleen dir als 8bit value
            _id |= 0;
            buffer_write(_b, buffer_u8, round(argument4 * 1.40625));
        }
    }
}else{
    if (_flags & MOD_SPEED)
    {
        if (argument3 >= -16 && argument3 <= 16)
        {
            //Alleen argument3
            _id |= 1;
            buffer_write(_b, buffer_u8, round((argument3 + 16) * 8));
        }else{
            //24bit combo
            _id |= 3;
            var __comb = round(argument4 * 11) + ((round((argument3 + 25.6) * 80) << 12));
            buffer_write(_b, buffer_u8, __comb >> 16);
            buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
            buffer_write(_b, buffer_u8, __comb % 256);
        }
    }else{
        //Helemaal niets
        _id |= 0;
    }
}

return _id;
#define XServer_variable_player_set_real
switch(argument0)
{
    case "x":
        if(global.__self_x != argument1) global.__self_position_changed |= MOD_X;
        global.__self_prev_x = global.__self_x;
        global.__self_x = argument1;
        break;
    case "y":
        if(global.__self_y != argument1) global.__self_position_changed |= MOD_Y;
        global.__self_prev_y = global.__self_y;
        global.__self_y = argument1;
        break;
    case "speed":
        if(global.__self_speed != argument1) global.__self_position_changed |= MOD_SPEED;
        global.__self_prev_speed = global.__self_speed;
        global.__self_speed = argument1;
        break;
    case "direction":
        if(global.__self_direction != argument1) global.__self_position_changed |= MOD_DIR;
        global.__self_prev_direction = global.__self_direction;
        global.__self_direction = argument1;
        break;
    default:
        if(ds_map_exists(global.__self, argument0))
        {
            if(argument1 != real(ds_map_find_value(global.__self, argument0))) ds_list_add(global.__self_changed, argument0);
            ds_map_replace(global.__self, argument0, argument1)
        }else{
            ds_map_add(global.__self, argument0, argument1)
            ds_map_add(global.__self_prec, argument0, global.__default_prec);
            ds_list_add(global.__self_changed, argument0);
        }
        break;
}
#define XServer_variable_player_set_string
if(ds_map_exists(global.__self, argument0))
{
    if(string(argument1) != string(ds_map_find_value(global.__self, argument0))) ds_list_add(global.__self_changed, argument0);
    ds_map_replace(global.__self, argument0, argument1)
}else{
    ds_map_add(global.__self, argument0, argument1)
    ds_map_add(global.__self_prec, argument0, global.__default_prec);
    ds_list_add(global.__self_changed, argument0);
}
#define gms_global_set_real
if(gms_global_exists(argument0))
{
    if(string(argument1) != string(ds_map_find_value(global.__global, argument0))) ds_list_add(global.__global_changed, argument0);
    ds_map_replace(global.__global, argument0, argument1)
}else{
    ds_map_add(global.__global, argument0, argument1)
    ds_map_add(global.__global_prec, argument0, global.__default_prec);
    ds_list_add(global.__global_changed, argument0);
}
#define gms_global_set_string
if(gms_global_exists(argument0))
{
    if(string(argument1) != string(ds_map_find_value(global.__global, argument0))) ds_list_add(global.__global_changed, argument0);
    ds_map_replace(global.__global, argument0, argument1)
}else{
    ds_map_add(global.__global, argument0, argument1)
    ds_map_add(global.__global_prec, argument0, global.__default_prec);
    ds_list_add(global.__global_changed, argument0);
}
#define XServer_clear_map_map
while(ds_map_size(argument0) > 0)
{
    ds_map_destroy(ds_map_find_value(argument0, ds_map_find_first(argument0)));
    ds_map_delete(argument0, ds_map_find_first(argument0));
}
ds_map_clear(argument0);
#define XServer_updateposition
var _p = argument0;
var _xto = ds_map_find_value(_p, "#x"), 
    _yto = ds_map_find_value(_p, "#y"), 
    _xlast = ds_map_find_value(_p, "#last-x"), 
    _ylast = ds_map_find_value(_p, "#last-y"), 
    _dirlast = ds_map_find_value(_p, "#last-direction"), 
    _smoothSpeed = ds_map_find_value(_p, "#smoothSpeed"), 
    _longRange = _smoothSpeed > 0.15,  
    _sharpTurn = ds_map_find_value(_p, "#sharpTurn"),
    _speedto = ds_map_find_value(_p, "#speed"), 
    _dirto = ds_map_find_value(_p, "#direction"),
    _tickstart = ds_map_find_value(_p, "#tickstart"),
    _tickend = ds_map_find_value(_p, "#tickend");

var _xnow = ds_map_find_value(_p, "*x"), 
    _ynow = ds_map_find_value(_p, "*y"), 
    _speednow = 0 * _speedto,;
    
var tmp, tX, tY;
switch(global.__spc)
{
    case 0:
        if(_tickend - _tickstart > 0){tmp=((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart)} else {tmp=2}
        if(tmp <= 1)
        {
            _xnow = _xlast * (1.0 - tmp) + _xto * tmp;
            _ynow = _ylast * (1.0 - tmp) + _yto * tmp;
        }else{
            _xnow = _xto;
            _ynow = _yto;
            _speednow = 0;
        }
        break;
    case 1:
        if(point_distance(_xnow, _ynow, _xto, _yto) < 64 && point_distance(_xnow, _ynow, _xto, _yto) > 2)
        {
            _xnow = (_xto * .35 + _xnow * .65);
            _ynow = (_yto * .35 + _ynow * .65);
        }else{
            _xnow = _xto;
            _ynow = _yto;
            _speednow = 0;
        }
        break;
    case 2:
        _xnow = _xto;
        _ynow = _yto;
        break;
    case 3:
        if(_tickend - _tickstart > 0){tmp=min(1,((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart))} else {tmp=1}
        _xnow = (_xto * .35 + (_xlast * (1 - tmp) + _xnow * tmp) * .65);
        _ynow = (_yto * .35 + (_ylast * (1 - tmp) + _ynow * tmp) * .65);
        break;
    case 4:
        if(_tickend - _tickstart > 0 && (get_timer() / 1000) - _tickend < 0)
        {
            tmp = min(1, (get_timer() / 1000 - _tickstart) / (_tickend - _tickstart));
        }else{
            tmp = 1;
        }
        break;
    case 5:
        if(_tickend - _tickstart > 0){tmp=((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart)} else {tmp=1}
        
        if(tmp > 1.0 && tmp < 1.5)
        {
        }else{
            if(_sharpTurn)
            {
                _xnow = _xnow * .35 + (_xlast * (1.0 - tmp) + _xto * tmp) * .65;
                _ynow = _ynow * .35 + (_ylast * (1.0 - tmp) + _yto * tmp) * .65;
            }else{
                if(_longRange)
                {
                    _xnow = (_xto * .35 + _xnow * .65);
                    _ynow = (_yto * .35 + _ynow * .65);
                }else{
                    _xnow = _xnow * .5 + (_xlast * (1.0 - tmp) + _xto * tmp) * .5;
                    _ynow = _ynow * .5 + (_ylast * (1.0 - tmp) + _yto * tmp) * .5;
                }
            }
        }     
        break;
    case 6:
        if(_tickend - _tickstart > 0){tmp=((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart)} else {tmp=2}
        if(tmp <= 1.0)
        {
            tmp = (get_timer() / 1000 - _tickstart) / (_tickend - _tickstart);
            _xnow = _xnow * .2 + (_xlast * (1.0 - tmp) + _xto * tmp) * .8;
            _ynow = _ynow * .2 + (_ylast * (1.0 - tmp) + _yto * tmp) * .8;
        }else{
            tmp = 2.0;
            _xnow = _xnow * .2 + (_xto + lengthdir_x(smoothSpeed * (tmp - 1.0) * global.__timer_threshold, _dirto)) * .8;
            _ynow = _ynow * .2 + (_yto + lengthdir_y(smoothSpeed * (tmp - 1.0) * global.__timer_threshold, _dirto)) * .8;
        }
        break;
    case 7:
        if(_tickend - _tickstart > 0){tmp=((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart)} else {tmp=2}
        if(tmp < 1.1)
        {
            tmp = (get_timer() / 1000 - _tickstart) / (_tickend - _tickstart);
            tX = _xnow * .35 + ((_xlast + lengthdir_x(_smoothSpeed * tmp * global.__timer_threshold, _dirto)) * (.3 - tmp * .3 + .7) + _xto * tmp * .3) * .65;
            tY = _ynow * .35 + ((_ylast + lengthdir_x(_smoothSpeed * tmp * global.__timer_threshold, _dirto)) * (.3 - tmp * .3 + .7) + _yto * tmp * .3) * .65;
        }else{
            tX = _xto;
            tY = _yto;
        }
        _xnow = tX * .6 + _xnow * .4;
        _ynow = tY * .6 + _ynow * .4;
        break;
    case 8:
        if(_tickend - _tickstart > 0){tmp=min(1, ((get_timer() / 1000) - _tickstart) / (_tickend - _tickstart))} else {tmp=1}

        _xnow = _xnow * .5 + (_xlast * (1 - tmp) + _xto * tmp) * .5;
        _ynow = _ynow * .5 + (_ylast * (1 - tmp) + _yto * tmp) * .5;
        break;
    case 9:
        var _delay = ds_map_find_value(_p, "#delay"),
            _speedCorrection = ds_map_find_value(_p, "#speedCorrection");
        if(abs(_speedto) > 0.1)
        {
            _xnow = _xnow * 0.6 + (_xto + lengthdir_x(_speedto + _speedCorrection, _dirto) * _delay) * 0.4;
            _ynow = _ynow * 0.6 + (_yto + lengthdir_y(_speedto + _speedCorrection, _dirto) * _delay) * 0.4;
        }else{
            _xnow = _xnow * 0.6 + _xto * 0.4;
            _ynow = _ynow * 0.6 + _yto * 0.4;
        }
        break;
}

ds_map_replace(_p, "*x", _xnow);
ds_map_replace(_p, "*y", _ynow);
ds_map_replace(_p, "*speed", _speednow);
ds_map_replace(_p, "*direction", _dirto);
ds_map_replace(_p, "#delay", _delay + 1);
#define XServer_updatecoords
var _p = argument0;
var _xto = ds_map_find_value(_p, "#x"), 
    _yto = ds_map_find_value(_p, "#y"), 
    _xlast = ds_map_find_value(_p, "#last-x"), 
    _ylast = ds_map_find_value(_p, "#last-y"), 
    _dirlast = ds_map_find_value(_p, "#last-direction"), 
//    _smoothSpeed = ds_map_find_value(_p, "#smoothSpeed"), 
//    _longRange = _smoothSpeed > 0.15,  
//    _sharpTurn = ds_map_find_value(_p, "#sharpTurn"),
    _speedto = ds_map_find_value(_p, "#speed"), 
    _dirto = ds_map_find_value(_p, "#direction");
//    _tickstart = ds_map_find_value(_p, "#tickstart"),
//    _tickend = ds_map_find_value(_p, "#tickend");

var _xnow = ds_map_find_value(_p, "*x"), 
    _ynow = ds_map_find_value(_p, "*y");
//    _speednow = ds_map_find_value(_p, "*speed"), 
//    _dirnow = ds_map_find_value(_p, "*direction");
    
var _dist = (_xto - _xnow) * (_xto - _xnow) + (_yto - _ynow) * (_yto - _ynow);
//var _update = false;
if(_dist > 10000)
{
    ds_map_replace(_p, "*x", _xto);
    ds_map_replace(_p, "*y", _yto);
    ds_map_replace(_p, "*speed", _speedto);
    ds_map_replace(_p, "*direction", _dirto);
}

ds_map_replace(_p, "#tickstart", get_timer() / 1000);
ds_map_replace(_p, "#tickend", (get_timer() + global.__timer_threshold) / 1000);

ds_map_replace(_p, "#last-x", _xnow);
ds_map_replace(_p, "#last-y", _ynow);

_smoothSpeed = point_distance(_xnow, _ynow, _xto, _yto) / (global.__timer_threshold / 1000);
ds_map_replace(_p, "#smoothSpeed", _smoothSpeed);

if(abs(_dirlast - _dirto) > 90)
{
    ds_map_replace(_p, "#sharpTurn", true);
}else{
    ds_map_replace(_p, "#sharpTurn", false);
} 
ds_map_replace(_p, "#last-direction", _dirto);
#define XServer_readvariablename
//XServer_writevariable(buffer, cacheID, type)
if(argument2 == 0 || argument2 == 1)
{
    return XServer_readstring(argument0);
}else{
    return global.__variable_receive_cache_name[argument1, argument2];
}
#define XServer_readinstance
//xPosServer_readinstance(message_id, buffer);
var _a = ds_map_create();
ds_map_add(_a, "type", 0);
ds_map_add(_a, "from", 0);

var xPos, yPos, dir, sp, obj_index, message_id = argument0;
var syncID = -1, senderID = 0;
senderID = buffer_read(argument1, buffer_u16);
if(message_id != 26 && message_id != 27) syncID = buffer_read(argument1, buffer_u16) + 1000000;
if(message_id == 26 || message_id == 27)//OneTime
{
    ds_map_replace(_a, "type", 4);
    ds_map_replace(_a, "from", senderID);
}else if(message_id == 8 || message_id == 28)
{
    ds_map_replace(_a, "type", 13);
    ds_map_replace(_a, "from", senderID);
}else if(message_id == 29 || message_id == 30)
{
    ds_map_replace(_a, "type", 14);
    ds_map_replace(_a, "from", senderID);
}else{
    if(debug_mode) show_error("Unknown SyncID " + string(message_id), false);
}

var flags = buffer_read(argument1, buffer_u8);

//////////////////////////////////////////////////
//New code! OH GOD PLEASE LET IT WORK :O
//////////////////////////////////////////////////

if ((flags & 8) > 0)
{
    obj_index = buffer_read(argument1, buffer_u32);
}
else
{
    obj_index = buffer_read(argument1, buffer_u8);
}

var combi = false;
switch((flags >> 6) & 3)
{
    case 0:
        xPos = buffer_read(argument0, buffer_u8);
        break;
    case 1:
        xPos = buffer_read(argument0, buffer_u8) * 2;
        break;
    case 2:
        xPos = buffer_read(argument0, buffer_u16);
        break;
    case 3:
        combi = true;
        break;
}

if(!combi)
{
    switch((flags >> 4) & 3)
    {
        case 0:
            yPos = buffer_read(argument0, buffer_u8);
            break;
        case 1:
            yPos = buffer_read(argument0, buffer_u8) * 2;
            break;
        case 2:
            yPos = buffer_read(argument0, buffer_u16);
            break;
        case 3:
            yPos = buffer_read(argument0, buffer_s32);
            break;
    }
}else{
    switch ((flags >> 4) & 3)
    {
        case 0:
            xPos = 0;
            yPos = 0;
            break;
        case 1:
            xPos = buffer_read(argument0, buffer_u16);
            yPos = x;
            break;
        case 2:
            var b1 = buffer_read(argument1, buffer_u8),
                b2 = buffer_read(argument1, buffer_u8),
                b3 = buffer_read(argument1, buffer_u8);
            
            var us1 = ((b1 << 16) + (b2 << 8) + b3) % 4096,
                us2 = (((b1 << 16) + (b2 << 8) + b3) >> 12) % 4096;
            xPos = us1;
            yPos = us2;
            break;
        case 3:
            xPos = buffer_read(argument0, buffer_s32);
            yPos = buffer_read(argument0, buffer_s32);
            break;
    }
}

if ((flags & 4) == 0)
{
    var b = buffer_read(argument0, buffer_u8);
    dir = (((b >> 4) & $F)) * 22.5;
    sp = (((b & $F))) - 8.0;
}
else
{
    var b1 = buffer_read(argument1, buffer_u8),
        b2 = buffer_read(argument1, buffer_u8),
        b3 = buffer_read(argument1, buffer_u8);
    
    var us1 = ((b1 << 16) + (b2 << 8) + b3) % 4096,
        us2 = (((b1 << 16) + (b2 << 8) + b3) >> 12) % 4096;
    
    dir = us1 / 11.0;
    sp = us2 / 80.0 - 25.6;
}

var var_count;
if((flags & 3) == 3)
{
    var_count = buffer_read(argument1, buffer_u8);
}else{
    var_count = flags & 3;
}

////////////////////////////////////////////////////////

ds_map_add(_a, 0, syncID);
ds_map_add(_a, 16, "syncID");
ds_map_add(_a, 1, obj_index);
ds_map_add(_a, 17, "object_index");
ds_map_add(_a, 2, xPos);
ds_map_add(_a, 18, "x");
ds_map_add(_a, 3, yPos);
ds_map_add(_a, 19, "y");
ds_map_add(_a, 4, dir);
ds_map_add(_a, 20, "direction");
ds_map_add(_a, 5, sp);
ds_map_add(_a, 21, "speed");

if(message_id == 29 || message_id == 30)//Full
{
    var _s = XServer_new_instance(syncID, 0, xPos, yPos, sp, dir, true, senderID);
    ds_map_add(global.__instance, syncID, _s);
    ds_list_add(global.__instance_idmap, syncID);
}else if(message_id == 8 || message_id == 28)//Create-destroy
{
    var _s = XServer_new_instance(syncID, 0, xPos, yPos, sp, dir, false, senderID);
    ds_map_add(global.__instance, syncID, _s);
    ds_list_add(global.__instance_idmap, syncID);
}


ds_map_add(_a, 6, var_count);
ds_map_add(_a, 22, "variable_count");

for(var i = 0; i < var_count; i++)
{
    var _type = buffer_read(argument1, buffer_u8),
        _name = XServer_readvariablename(_rr, 4,  _type),
        _val = XServer_readvalue(_rr, global.__variable_receive_cache_type[4, _type]);
    
    ds_map_add(_a, 23 + i, _name);
    if(message_id == 29 || message_id == 30)
    {
        ds_map_add(_s, "*" + string(_name), _val);
        ds_map_add(_s, ">" + string(_name), 0.01);//Precision
        ds_list_add(ds_map_find_value(_s, "variable_names"), string(_name));
    }
    
    ds_map_add(_a, 7 + i, _val);
}

ds_queue_enqueue(global.__actions, _a);
#define XServer_new_instance
var _s = ds_map_create();
ds_map_add(_s, "syncID", argument0);
ds_map_add(_s, "instance_id", argument1);
ds_map_add(_s, "x", argument2);
ds_map_add(_s, "y", argument3);
ds_map_add(_s, "speed", argument4);
ds_map_add(_s, "direction", argument5);
ds_map_add(_s, "#x", argument2);
ds_map_add(_s, "#y", argument3);
ds_map_add(_s, "#speed", argument4);
ds_map_add(_s, "#direction", argument5);
ds_map_add(_s, "full_sync", argument6);
ds_map_add(_s, "owner", argument7);

ds_map_add(_s, "#last-x", argument2);
ds_map_add(_s, "#last-y", argument3);

ds_map_add(_s, "#last-direction", argument5);
ds_map_add(_s, "#last-x", argument2);

ds_map_add(_s, "#tickstart", 0);
ds_map_add(_s, "#tickend", 0);

ds_map_add(_s, "#smoothSpeed", 0);
ds_map_add(_s, "#sharpTurn", 0);

ds_map_add(_s, "#last-dir", argument5);

ds_map_add(_s, "has_moved", false);

ds_map_add(_s, "variable_changed", ds_list_create());
ds_map_add(_s, "variable_names", ds_list_create());

return _s;
#define XServer_disconnected
XAction(19, 0)
#define XServer_instance_sendsync
//Leeg de buffer
//      0               1           2               3          4      5         6            7      8     
//(int argument0, double local, int object_index, int syncID, int x, int y, double dir, double sp, int count)
XServer_preparesend();
//Message-ID

if(argument0 != 0)
{
    buffer_write(_b, buffer_u16, argument3 - 1000000);//syncID
    
    //TODO: Check for room_index change
    buffer_write(_b, buffer_u32, argument8);//Room index
}


///////////////////////////////////////////////////////////////
/*buffer_write(_b, buffer_s32, argument2);//opbjIndex
buffer_write(_b, buffer_s32, argument4);//x
buffer_write(_b, buffer_s32, argument5);//y

//Message-Contents
var __comb = round(argument6 * 11) + ((round((argument7 + 25.6) * 80) << 12));
buffer_write(_b, buffer_u8, __comb >> 16);
buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
buffer_write(_b, buffer_u8, __comb % 256);

//Other variables
buffer_write(_b, buffer_u8, global.__instance_varcount);*/

var flags = 0;

//Firstly, X & Y
if(argument4 == 0 && argument4 == 0)
{
    flags |= 128 | 64 | 0 | 0;
}else if(round(argument4) == round(argument4) && argument4 >= 0 && argument4 <= 65535)
{
    flags |= 128 | 64 | 0 | 16;
}
else if (argument4 >= 255 && argument4 <= 4096 && argument4 >= 255 && argument4 <= 4096 && ((argument4 & 2) != 0 || argument4 > 510) && ((argument4 & 1) != 0 || argument4 > 510))
{
    //XY: 12bit combi
    flags |= 128 | 64 | 32 | 0;
}else if(argument4 > 65535 || argument4 < 0)
{
    //XY: int, int combi
    flags |= 128 | 64 | 32 | 16;
}else{
    //Individual X & Y
    if(argument4 >= 0 && argument4 <= 255)
    {
        //X: bargument4te
        flags |= 0 | 0;
    }else if(argument4 >= 0 && argument4 <= 510 && (argument4 & 1) == 0)
    {
        //X: bargument4te * 2
        flags |= 0 | 64;
    }else{
        //X: ushort
        flags |= 128 | 0;
    }
    
    if(argument4 >= 0 && argument4 <= 255)
    {
        //Y: bargument4te
        flags |= 0 | 0;
    }else if(argument4 >= 0 && argument4 <= 510 && (argument4 & 1) == 0)
    {
        //Y: bargument4te * 2
        flags |= 0 | 16;
    }else if(argument4 >= 0 && argument4 <= 65535){
        //Y: ushort
        flags |= 32 | 0;
    }else{
        //Y: int
        flags |= 32 | 16;
    }
}

if(argument2 > 255)
{
    flags |= 8;
}

if ((round(argument6 * 2)) % 45 == 0 && argument7 >= -8 && argument7 <= 8)
{
    //8bit combo
    flags |= 0;
}else{
    //24bit combo
    flags |= 4;
}

if(global.__instance_varcount < 3)
{
    flags |= global.__instance_varcount;
}
else
{
    flags |= 3;
}

/////////////////////////////////
//Write values
/////////////////////////////////

buffer_write(_b, buffer_u8, flags);
if ((flags & 8) > 0)
{
    buffer_write(_b, buffer_s32, argument2);
}
else
{
    buffer_write(_b, buffer_u8, argument2);
}

var combi = false;
switch ((flags >> 6) & 3)
{
    case 0:
        buffer_write(_b, buffer_u8, argument4);
        break;
    case 1:
        buffer_write(_b, buffer_u8, (argument4 / 2));
        break;
    case 2:
        buffer_write(_b, buffer_u16, argument4);
        break;
    case 3:
        combi = true;
        break;
}

if(!combi)
{
    switch ((flags >> 4) & 3)
    {
        case 0:
            buffer_write(_b, buffer_u8, argument4);
            break;
        case 1:
            buffer_write(_b, buffer_u8, (argument4 / 2));
            break;
        case 2:
            buffer_write(_b, buffer_u16, argument4);
            break;
        case 3:
            buffer_write(_b, buffer_s32, argument4);
            break;
    }
}else{
    switch ((flags >> 4) & 3)
    {
        case 0://argument4 = 0, argument4 = 0
            break;
        case 1:
            buffer_write(_b, buffer_u16, argument4);
            break;
        case 2:
            var __comb = round(argument4) + round((argument4) << 12);
            buffer_write(_b, buffer_u8, __comb >> 16);
            buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
            buffer_write(_b, buffer_u8, __comb % 256);
            break;
        case 3:
            buffer_write(_b, buffer_s32, argument4);
            buffer_write(_b, buffer_s32, argument4);
            break;
    }
}

if ((flags & 4) == 0)
{
    buffer_write(_b, buffer_u8, ((round(argument7 + 8) & $F) | ((round(argument6 / 22.5) & $F) << 4)));
}
else
{
    var __comb = round(argument6 * 11) + ((round((argument7 + 25.6) * 80) << 12));
    buffer_write(_b, buffer_u8, __comb >> 16);
    buffer_write(_b, buffer_u8, (__comb >> 8) % 256);
    buffer_write(_b, buffer_u8, __comb % 256);
}

if ((flags & 3) == 3)
{
    buffer_write(_b, buffer_u8, global.__instance_varcount);
}

///////////////////////////////////////////////////////////////////


for(var __i = 0; __i < global.__instance_varcount; __i++)
{
    XServer_writevariable(_b, 4, global.__instance_var[__i], global.__instance_val[__i], global.__instance_prec[__i]);
}

if(argument0 == 0)
{
    if(argument1)
    {
        XServer_send(mid_instance_once_local);
    }else{
        XServer_send(mid_instance_once);
    }
}else if(argument0 == 1)
{
    if(argument1)
    {
        XServer_send(mid_instance_ext_local);
    }else{
        XServer_send(mid_instance_ext);
    }
}else if(argument0 == 2)
{
    if(argument1)
    {
        XServer_send(mid_instance_full_local);
    }else{
        XServer_send(mid_instance_full);
    }
}
#define XServer_gainSyncID
global.__sync_pos++;
if(global.__sync_pos % 1000 == 0)
{
    global.__sync_pos = 0;
}
var __i = 0;
while(ds_map_exists(global.__instance, global.__sync_pos + global.__sync_pos_start) && __i++ < 10000)
{
    global.__sync_pos++;
    if(global.__sync_pos % 1000 == 0)
    {
        if(debug_mode) show_error("This client is syncing more than 1000 instances at the same time. There's a limit on the number of instances a client can sync. If you need more, you should destroy others.", 0);
        break;
    }
}
return global.__sync_pos + global.__sync_pos_start;
#define XServer_instance_find
if(ds_map_exists(global.__instance, argument0))
{
    return ds_map_find_value(global.__instance, argument0);
}else{
    if(ds_map_exists(global.__instance_map, argument0))
    {
        return XServer_instance_find(ds_map_find_value(global.__instance_map, argument0));
        //return XServer_instance_find(ds_list_find_value(global.__instance_idmap, argument0));
    }
}
return -1;
#define XServer_instance_destroy
if(ds_map_exists(global.__instance, argument0))
{
    var _m = ds_map_find_value(global.__instance, argument0);
    ds_map_delete(global.__instance_map, ds_map_find_value(_m, "instance_id"));
    
    var _m2 = ds_map_find_value(_m, "variable_names"),
        _m3 = ds_map_find_value(_m, "variable_changed");
    
    ds_list_destroy(_m2);
    ds_list_destroy(_m3);
    
    ds_list_delete(global.__instance_idmap, ds_list_find_index(global.__instance_idmap, argument0));
    ds_map_delete(global.__instance, argument0);
    return true;
}else{
    return false;
}
#define XServer_update_finish

#define gms_debug_enable
global.__debugging = true;
#define gms_location_isonum
return global.__loc_isonum;
#define gms_location_countrycode
return global.__loc_countrycode;
#define gms_location_countryname
return global.__loc_countryname;
#define gms_location_languages
return global.__loc_languages;
#define gms_admin_unban
XServer_preparesend();
XServer_writestring(_b, argument0);
XServer_send(mid_unban);
#define gms_session_exists
for(var i = 0; i < gms_session_count(); i += 1)
{
    if(gms_session_id(i) == argument0)
    {
        return true;
    }
}

return false;
#define gms_optimize_set_max_skip
global.__max_skip = argument0;
#define XGms_cache_variable_write
///XGms_cache_variable_write(buffer, cacheID, name, send_type)
var _index, _str;
_str = argument2 + chr(64 + argument3);
if(!ds_map_exists(global.__player_send_cache, _str))
{
    if(ds_map_exists(global.__variable_send_queue[argument1], _str))
    {
        //AddElement(_str)
        _index = ds_list_find_value(global.__variable_send_llist[argument1], 0);
        ds_list_delete(global.__variable_send_llist[argument1], 0);
        ds_list_add(global.__variable_send_llist[argument1], _index);
        
        //Update map to reflect new values
        var _oldValue = ds_map_find_value(global.__variable_isend_cache[argument1], _index);
        ds_map_delete(global.__variable_isend_cache[argument1], _index);
        ds_map_delete(global.__variable_send_cache[argument1], _oldValue);
        
        ds_map_add(global.__variable_isend_cache[argument1], _index, _str);
        ds_map_add(global.__variable_send_cache[argument1], _str, _index);
        
        //Send change
        buffer_write(global.__send_buffer, buffer_u8, (5 + string_length(argument2)) << 1);
        buffer_write(global.__send_buffer, buffer_u8, 133 + argument1);
        buffer_write(global.__send_buffer, buffer_u8, _index);
        
        //Damn you, GM:Studio! No 64bit-integer support? (TODO: Add in later when I finish class compiler)
        XServer_writestring(global.__send_buffer, argument2);
        buffer_write(global.__send_buffer, buffer_u8, argument3);
        
        //Write variable
        buffer_write(argument0, buffer_u8, _index);
        return true;
    }else{
        ds_map_add(global.__variable_send_queue[argument1], _str, 1);
        return false;
    }
}else{
    //MarkUsed(_str)
    _index = ds_map_find_value(global.__player_send_cache, _str);
    ds_list_delete(global.__variable_send_llist, 0);
    ds_list_add(global.__variable_send_llist, _index);
    
    //Write variable
    buffer_write(argument0, buffer_u8, _index);
    return true;
}
#define XGms_cache_variable_read

#define XGms_cache_player_read
///XGms_cache_player_read(buffer)
return global.__player_receive_cache[buffer_read(argument0, buffer_u8)];
#define XGms_cache_player_write
///XGms_cache_player_write(buffer, playerID)
var _index;
if(!ds_map_exists(global.__player_send_cache, argument1))
{
    //AddElement(argument1)
    _index = ds_list_find_value(global.__variable_send_llist, 0);
    ds_list_delete(global.__variable_send_llist, 0);
    ds_list_add(global.__variable_send_llist, _index);
    
    //Update map to reflect new values
    var _oldValue = ds_map_find_value(global.__player_isend_cache, _index);
    ds_map_delete(global.__player_isend_cache, _index);
    ds_map_delete(global.__player_send_cache, _oldValue);
    
    ds_map_add(global.__player_isend_cache, _index, argument1);
    ds_map_add(global.__player_send_cache, argument1, _index);
    
    //Send change
    buffer_write(global.__send_buffer, buffer_u8, 10 << 1);
    buffer_write(global.__send_buffer, buffer_u8, 140);
    buffer_write(global.__send_buffer, buffer_u8, _index);
    
    //Damn you, GM:Studio! No 64bit-integer support? (TODO: Add in later when I finish class compiler)
    buffer_write(global.__send_buffer, buffer_u32, argument1 >> 32);
    buffer_write(global.__send_buffer, buffer_u32, argument1);
}else{
    //MarkUsed(argument1)
    _index = ds_map_find_value(global.__player_send_cache, argument1);
    ds_list_delete(global.__variable_send_llist, 0);
    ds_list_add(global.__variable_send_llist, _index);
}

buffer_write(argument0, buffer_u8, _index);
