local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_nodes = {}

core.register_node("amnv_nodes:placeholder", {
	description = S("Placeholder Node"),
	groups = { solid = 1, unbreakable = 1, },
	tiles = {
		{
			name = "amnv_nodes_placeholder_16x.png^[multiply:#888",
			align_style = "world", scale = 16,
		},
	},
	sunlight_propagates = false,
})

core.register_node("amnv_nodes:barrier", {
	description = S(""),
	drawtype = "airlike",
	groups = { solid = 1, unbreakable = 1, not_in_creative_inventory = 1, },
	sunlight_propagates = true,
	paramtype = "light",
	pointable = false,
	diggable = false,
})

local base_node = "amnv_nodes:placeholder"
core.register_alias("mapgen_stone", base_node)
core.register_alias("mapgen_water_source", base_node)
core.register_alias("mapgen_river_water_source", base_node)
core.register_alias("mapgen_lava_source", base_node)
core.register_alias("mapgen_cobble", base_node)

core.register_node("amnv_nodes:sand", {
	description = S(""),
	groups = { solid = 1, mining = 3, },
	tiles = {
		{
			name = "amnv_nodes_sand.png",
			align_style = "world", scale = 16,
		},
	},
	sunlight_propagates = false,
})

core.register_node("amnv_nodes:sand_top", {
	description = S(""),
	groups = { solid = 1, mining = 3, topsoil = 1, },
	tiles = {
		{
			name = "amnv_nodes_sand.png",
			align_style = "world", scale = 16,
		},
	},
	sunlight_propagates = false,
})

core.register_node("amnv_nodes:sandstone", {
	description = S(""),
	groups = { solid = 1, mining = 3, },
	tiles = {
		{
			name = "amnv_nodes_sandstone.jpg^[hsl:-10:120:0",
			align_style = "world", scale = 16,
		},
	},
	sunlight_propagates = false,
})

core.register_node("amnv_nodes:concrete", {
	description = S(""),
	groups = { solid = 1, mining = 1, },
	tiles = {
		{
			name = "amnv_nodes_concrete.jpg",
			align_style = "world", scale = 16,
		},
	},
	sunlight_propagates = false,
})

core.register_node("amnv_nodes:dried_riverbed", {
	description = S(""),
	groups = { solid = 1, mining = 1, },
	tiles = {
		{
			name = "amnv_nodes_tan_mud_cracked.jpg",
			align_style = "world", scale = 4,
		},
	},
	sunlight_propagates = false,
})

local function add_particles(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	if not ndef then return end
	if not ndef._particle_texture then return end
	local dist = 0.3
	local vel = 1
	core.add_particlespawner({
		amount = 3,
		time = 10,
		vertical = false,
		texpool = {
			{
				name = ndef._particle_texture,
				alpha_tween = {
					0.0, 1.0,
					style = "rev",
					reps = 1,
				},
			}
		},
		glow = 3,
		minpos = vector.new(-dist, -dist, -dist) + pos,
		maxpos = vector.new( dist,  dist,  dist) + pos,
		minvel = vector.new(-vel*0.3,  vel*0.1, -vel*0.3),
		maxvel = vector.new( vel*0.3,  vel*0.3,      vel*0.3),
		minexptime = 2,
		maxexptime = 5,
		minsize = 2,
		maxsize = 4,
	})
end

local function on_timer(pos, elapsed)
	add_particles(pos)
	return true
end

local function after_generated_rotate(pos)
	local node = core.get_node(pos)
	node.param2 = math.random(0, 239)
	core.swap_node(pos, node)
end


function amnv_nodes.register_ore_node(def)
	core.register_node("amnv_nodes:sand_ore_" .. def.name, {
		description = S(""),
		groups = { solid = 1, unbreakable = 1, },
		tiles = {
			{
				name = "amnv_nodes_sand.png^[hsl:0:-10:10" ..
				"^(amnv_nodes_ore_bed.png^[multiply:" .. def.color.main .. ")",
				align_style = "world", scale = 16,
			},
		},
		sunlight_propagates = false,
	})
	core.register_node("amnv_nodes:ore_" .. def.name, {
		description = S(""),
		groups = { ore = 1, deconstruct = 3, attached_node = 3, dig_immediate = 3, },
		drawtype = "mesh",
		mesh = "amnv_nodes_crystal.obj",
		tiles = {
			{
				name = "amnv_nodes_ore_crystal.png^[multiply:" .. def.color.substrate ..
				"^(amnv_nodes_ore_crystal_overlay.png^[multiply:" .. def.color.main .. ")",
			},
		},
		sunlight_propagates = false,
		paramtype = "light",
		paramtype2 = "degrotate",
		walkable = false,
		on_timer = on_timer,
		_particle_texture = string.format(
			"amnv_nodes_ore_base_particle.png^[hsl:%d:%d:%d",
			def.color.h, def.color.s + 50, def.color.l
		),
		_after_generated = after_generated_rotate,
	})
end


--[[
- Metal		--> building		grey
- Octate	--> fuel			black
- Annite	--> ammo			green
- Peryite	--> xp, objective	blue
]]

for i, oredef in ipairs(amnv_game.ore_list) do
	amnv_nodes.register_ore_node(oredef)
end




core.register_node("amnv_nodes:b_miner_barrier", {
	description = S(""),
	groups = { building = 1, },
	drawtype = "airlike",
	sunlight_propagates = true,
	paramtype = "light",
	pointable = false,
})

local barrier_plain = {name="amnv_nodes:b_miner_barrier"}
core.register_node("amnv_nodes:b_miner", {
	description = S(""),
	groups = { building = 1, deconstruct = 10, },
	drawtype = "mesh",
	mesh = "amnv_nodes_miner.obj",
	tiles = {
		{
			name = "amnv_nodes_miner.png",
		},
	},
	sunlight_propagates = false,
	paramtype = "light",
	paramtype2 = "4dir",
	selection_box = {
		type = "fixed",
		fixed = {
			{
				-0.5, -0.5, -0.5,
				 1.5,  1.5,  1.5,
			}
		},
	},
	pointable = true,
	_multinode = {
		nodes = {
			{vector.new(1,  0,  0), barrier_plain},
			{vector.new(0,  0,  1), barrier_plain},
			{vector.new(1,  0,  1), barrier_plain},

			{vector.new(0,  1,  0), barrier_plain},
			{vector.new(1,  1,  0), barrier_plain},
			{vector.new(0,  1,  1), barrier_plain},
			{vector.new(1,  1,  1), barrier_plain},

			{vector.new(0,  2,  0), barrier_plain},
			{vector.new(1,  2,  0), barrier_plain},
			{vector.new(0,  2,  1), barrier_plain},
			{vector.new(1,  2,  1), barrier_plain},

			{vector.new(0,  3,  0), barrier_plain},
			{vector.new(1,  3,  0), barrier_plain},
			{vector.new(0,  3,  1), barrier_plain},
			{vector.new(1,  3,  1), barrier_plain},
		},
		-- always_place = true,
	},
	_deconstruct_replace = "air",
})
