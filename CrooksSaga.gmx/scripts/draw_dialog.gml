#define draw_dialog
///draw_dialog(name, text, choices)

var title = argument0
var dialog = argument1
var list = argument2



var xx = display_get_gui_width()/2 - width/2;
var yy = y;

var startY = yy;
var startX = xx;

var selection = "-1";

draw_set_alpha(1)
draw_rectangle_colour(xx-2, yy-2, xx+width+2, yy+animHeight+2, color_secondary, color_secondary, color_secondary, color_secondary, false)
draw_rectangle_colour(xx, yy, xx+width, yy+animHeight, color_primary, color_primary, color_primary, color_primary, false)

xx += border
yy += border

draw_set_font(ft_dengXian)
draw_text_outlined(xx, yy, title, color_secondary, c_white)
yy += string_height(title);

draw_set_font(ft_dengXianSmall)
draw_set_colour(c_white)


draw_text_ext(xx,yy,dialog,string_height(" "),width - border*2)
yy += string_height_ext(dialog, string_height(" "), width - border*2)
yy += border

for (var i = 0; i < ds_list_size(list); i++) {
    
    yy += border;
    var choice = list[| i];
    var choiceSelection = ds_list_find_value(choice,0);
    var answer = ds_list_find_value(choice, 1);
    
    var x2 = xx + string_width_ext(answer, string_height(" "), width-border*2)
    var y2 = yy + string_height_ext(answer, string_height(" "), width-border*2)
    
    if (mouse_in(xx,yy,x2,y2)) {
        draw_text_ext(xx,yy+0.5,answer,string_height(" "),width - border*2)
        draw_text_ext(xx,yy-0.5,answer,string_height(" "),width - border*2)
    }
    draw_text_ext(xx,yy,answer,string_height(" "),width - border*2)
    
    if (mouse_in(xx,yy,x2,y2) and mouse_check_button_released(mb_left)) {
    
          /* calculate selection location */
          if (string_pos("?",choiceSelection)) {
          
                var ifStatement = ds_list_find_value(string_split(choiceSelection,"?"),0);
                var selectionChoices = string_split(ds_list_find_value(string_split(choiceSelection,"?"),1),":");
                
                var opp = get_comparison(ifStatement);
                var left = ds_list_find_value(string_split(ifStatement,opp),0);
                
                if (!is_undefined(m_get(left))) {
                    left = m_get(left);
                } else {
                    left = realorboolean(left);
                }
                
                var right = ds_list_find_value(string_split(ifStatement,opp),1);
                if (!is_undefined(m_get(right))) {
                    right = m_get(right);
                } else {
                    right = realorboolean(right);
                }
                
                show_debug_message(opp + " " + string(left) + " " + string(right));
                
                
                if (opp == ">") {
                    if (left > right) selection = selectionChoices[|0];
                    else selection = selectionChoices[|1];
                }
                if (opp == "<") {
                    if (left < right) selection = selectionChoices[|0];
                    else selection = selectionChoices[|1];
                }
                if (opp == "=") {
                    if (left == right) selection = selectionChoices[|0];
                    else selection = selectionChoices[|1];
                }
                
                
          } else {
                selection = choiceSelection
          }
          
              
          /* calculate variable changes*/
          for (var j = 2; j < ds_list_size(choice); j++) {
                var changeString = ds_list_find_value(choice, j);
                
                if (string_pos("+",changeString)) {
                    var opp = "+"
                }
                
                if (string_pos("-",changeString)) {
                    var opp = "-"
                }
                
                if (string_pos("=",changeString)) {
                    var opp = "="
                }
                
                var changeInfo = string_split(changeString, opp)
                if (opp == "+") {
                    var currentValue = m_get(changeInfo[|0]) + real(changeInfo[|1]);
                } else if (opp == "-") {
                    var currentValue = m_get(changeInfo[|0]) - real(changeInfo[|1]);
                } else {
                    var currentValue = realorboolean(changeInfo[|1]);
                }
                m_set(changeInfo[|0], currentValue)
          }
    }
    
    yy = y2;
}

yy += border
height = yy - startY;

animHeight = approach(animHeight,height,10)

return selection;

#define get_comparison
///get_comparison(string)
{
    var opp = "="
    if (string_pos(">",argument0)) {
        opp = ">"
    }
    if (string_pos("<",argument0)) {
        opp = "<"
    }
    if (string_pos("=",argument0)) {
        opp = "="
    }
    return opp
}