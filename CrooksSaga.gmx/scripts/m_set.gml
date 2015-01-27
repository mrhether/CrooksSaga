///m_set(macro, value)
{
    if (not ds_exists(global.mMap, ds_type_map)) {
        global.mMap = ds_map_create()
    }
    if (ds_exists(argument1, ds_type_list)) {
        return ds_map_replace_list(global.mMap, argument0, argument1);
    } else {
        return ds_map_replace(global.mMap,argument0, argument1);
    }
}