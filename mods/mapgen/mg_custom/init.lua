local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

----
core.register_mapgen_script(mod_path .. "/register.lua")
-- core.register_mapgen_script(mod_path .. "/example.lua")
----
