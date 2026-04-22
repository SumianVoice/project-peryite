
local this_biome = "flat"
amnv_game.register_biome({
	name = this_biome,
    heat_point = 50,
    humidity_point = 50,
})

local y_min = core.registered_biomes[this_biome].y_min
local y_max = core.registered_biomes[this_biome].y_max
