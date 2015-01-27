///in_view()
if (x > view_xview and 
    x < view_xview + view_wview
    and y > view_yview 
    and y < view_yview + view_hview) {
    return true;    
} else {
    return false;
}
