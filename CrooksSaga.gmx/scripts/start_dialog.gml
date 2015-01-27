///start_dialog(filename);
with obj_dialog_manager {
    instance_destroy();
}
with instance_create(0,0,obj_dialog_manager) {
    var filename = argument0
    m_set(m_fight, false);
    dialogMap = load_dialog(filename)
    currentDialogPosition = "0";
    currentDialog = ds_map_find_value(dialogMap, currentDialogPosition);
}