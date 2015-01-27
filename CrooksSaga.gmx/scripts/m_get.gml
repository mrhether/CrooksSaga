///m_get(macro)
{
    if (not ds_exists(global.mMap, ds_type_map)) {
        global.mMap = ds_map_create()
    }
    return ds_map_find_value(global.mMap,argument0)
}