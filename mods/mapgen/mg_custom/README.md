# WORK IN PROGRESS
Much of this will change before it is releasable, so use at your own risk. It was designed for a specific game (trenchfront) and so is a bit ideosyncratic still until it is made into a more pure API.

# How to use
Make sure to use the threaded mapgen environment. `mg_custom` doesn't exist anywhere else.
```lua
local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
minetest.register_mapgen_script(mod_path .. "/my_mapgen_file.lua")
```

In your `my_mapgen_file.lua`:
```lua
-- to make a generator
mg_custom.register_generator(name, def)
-- set that generator
mg_custom.set_generator(name[, seed])
```


For set map bounds
```lua
-- optional bounds of the map (caution: setting this to a large number or the whole world will kill your game when it tries to delete it)
mg_custom.minp = vector.new(-1, 0,-1) * 80
mg_custom.maxp = vector.new( 1, 0, 1) * 80
-- to generate the map according to a generator (deletes the map bounds you have defined)
mg_custom.generate_map(generator_name, seed, force_emerge)
--> or to delete and regenerate an area:
mg_custom.regenerate(minp, maxp, force_emerge, callback)
```