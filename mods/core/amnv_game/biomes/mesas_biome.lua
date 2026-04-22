
local this_biome = "mesas"
amnv_game.register_biome({
	name = this_biome,
    heat_point = 50,
    humidity_point = 50,
})

local y_min = core.registered_biomes[this_biome].y_min
local y_max = core.registered_biomes[this_biome].y_max

function amnv_game.register_ore_blob(def)
    core.register_ore({
        ore_type	= "blob",
        ore		    = "amnv_nodes:sand_ore_" .. def.orename,
        wherein		= def.wherein or {"amnv_nodes:sand_top"},
        clust_scarcity	= def.clust_scarcity or 2500,
        clust_num_ores	= 1,
        clust_size	= def.size or 6,
        noise_params = def.np or {
            offset = 0.5,
            scale = 0.4,
            spread = {x = 4, y = 4, z = 4},
            seed = def.seed or 2148,
            octaves = 2,
            persistence = 0.8,
            lacunarity = 2.17,
        },
        y_min = y_min,
        y_max = y_max,
        biomes = {def.biome},
    })
    core.register_decoration({
        deco_type = "simple",
        place_on = {"amnv_nodes:sand_ore_" .. def.orename},
        sidelen = 80,
        fill_ratio = 100,
        biomes = {def.biome},
        y_min = y_min,
        y_max = y_max,
        decoration = "amnv_nodes:ore_" .. def.orename,
        flags = "all_floors",
        _layer = 42,
    })
end

amnv_game.register_ore_blob({
    orename = "peryite",
    clust_scarcity = 1500,
    biome = this_biome,
    size = 4,
    np = {
        offset = -0.5,
        scale = 1.6,
        spread = {x = 12, y = 20, z = 12},
        seed = 432,
        octaves = 2,
        persistence = 0.8,
        lacunarity = 2.17,
    },
})

amnv_game.register_ore_blob({
    orename = "annite",
    clust_scarcity = 1000,
    biome = this_biome,
    size = 4,
    np = {
        offset = -0.2,
        scale = 1.1,
        spread = {x = 12, y = 20, z = 12},
        seed = 872,
        octaves = 2,
        persistence = 0.8,
        lacunarity = 2.17,
    },
})

amnv_game.register_ore_blob({
    orename = "metal",
    clust_scarcity = 1500,
    biome = this_biome,
    size = 4,
    np = {
        offset = -0.5,
        scale = 1.6,
        spread = {x = 12, y = 20, z = 12},
        seed = 39417,
        octaves = 2,
        persistence = 0.8,
        lacunarity = 2.17,
    },
})

amnv_game.register_ore_blob({
    orename = "octate",
    clust_scarcity = 1000,
    biome = this_biome,
    size = 6,
    np = {
        offset = -0.9,
        scale = 1.6,
        spread = {x = 12, y = 20, z = 12},
        seed = 43,
        octaves = 2,
        persistence = 0.8,
        lacunarity = 2.17,
    },
})
