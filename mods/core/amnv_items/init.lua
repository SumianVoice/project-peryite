local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_items = {}

local function add_particles(pos)
	local dist = 0.1
	local vel = 25
	core.add_particlespawner({
		amount = 40,
		time = 0.000001,
		vertical = false,
		texpool = {
			{
				name = "amnv_nodes_ore_base_particle.png^[hsl:170:40:30",
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
		minvel = vector.new(-vel,  vel*0.05, -vel),
		maxvel = vector.new( vel,  vel,       vel),
		minexptime = 0.7,
		maxexptime = 2,
		minsize = 2,
		maxsize = 6,
	})
	vel = 10
	core.add_particlespawner({
		amount = 20,
		time = 0.000001,
		vertical = false,
		texpool = {
			{
				name = "amnv_nodes_ore_base_particle.png^[hsl:140:-50:-30",
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
		minvel = vector.new(-vel,  vel*0.05, -vel),
		maxvel = vector.new( vel,  vel,       vel),
		minexptime = 0.7,
		maxexptime = 2,
		minsize = 4,
		maxsize = 16,
	})
end

function amnv_items.get_eyepos(player)
    local eyepos = vector.add(player:get_pos(), vector.multiply(player:get_eye_offset(), 0.1))
    eyepos.y = eyepos.y + player:get_properties().eye_height
    return eyepos
end

function amnv_items.get_pointed_thing(player)
	local eyepos = amnv_items.get_eyepos(player)
	local dir = player:get_look_dir()
	local ray = core.raycast(eyepos, eyepos + (dir * 300), false, false, nil)
	for pt in ray do
		if pt.type == "node" then
			return pt
		end
	end
end

local function shoot_projectile(stack, player, pointed_thing)
	if not core.is_player(player) then return end
	pointed_thing = amnv_items.get_pointed_thing(player)
	if not pointed_thing then return end
	local pos = pointed_thing.intersection_point
	add_particles(pos)
	local objects = core.get_objects_inside_radius(pos, 8)
	for i, object in ipairs(objects) do
		local p = object:get_pos()
		if core.is_player(object) then
			p = amnv_items.get_eyepos(player)
			p.y = p.y
		end
		local dist = vector.distance(pos, p)
		local df = math.max(0, dist/8 - 0.5)
		local dir = vector.direction(pos, p)
		dir.y = dir.y + 0.1
		object:add_velocity(dir * (30 - (20*df)))
	end
end

core.register_tool("amnv_items:w_gl", {
	description = "amnv_items:w_gl",
	groups = { combat = 2, },

	on_use = function(stack, user, pointed_thing)
		return shoot_projectile(stack, user, pointed_thing)
	end,

	_on_select = function(stack, player) end,
	_on_deselect = function(stack, player) end,
	_on_step = function(stack, player, dtime) end,
	-- every step whether wielded or not
	_on_inventory_step = function(itemstack, player, dtime, list_name, list_index) end,
	-- on this item moved to another index and/or list
	_on_inventory_move = function(itemstack, player, from_list, to_list, from_index, to_index) end, --> return ==false to cancel
	-- before creating an item entity
	_on_drop = function(itemstack, player)end, --> return ==false to cancel
	-- after creating an item entity
	_on_dropped = function(itemstack, player, object) end,
})

local function propel_player(player, dir, amount)
	if not core.is_player(player) then return end
	local y = 0.3
	dir.y = 0
	dir = vector.normalize(dir)
	dir.y = y
	dir = dir * amount
	dir.y = dir.y + math.max(-5, (-player:get_velocity().y))
	player:add_velocity(dir)
end

core.register_tool("amnv_items:w_sword", {
	description = "amnv_items:w_sword",
	groups = { combat = 2, },

	on_use = function(stack, user, pointed_thing)
		if not core.is_player(user) then return end
		playerphysics.add_physics_factor(user, "gravity", "amnv_items:w_sword", 0.6)
		playerphysics.add_physics_factor(user, "acceleration_air", "amnv_items:w_sword", 0.2)
		playerphysics.add_physics_factor(user, "acceleration_default", "amnv_items:w_sword", 0.02)
		local dir = user:get_look_dir()
		propel_player(user, vector.copy(dir), 15)
		core.after(0.5, function()
			playerphysics.remove_physics_factor(user, "gravity", "amnv_items:w_sword")
			playerphysics.remove_physics_factor(user, "acceleration_air", "amnv_items:w_sword")
			playerphysics.remove_physics_factor(user, "acceleration_default", "amnv_items:w_sword")
		end)
	end,

	_on_select = function(stack, player) end,
	_on_deselect = function(stack, player)
		playerphysics.remove_physics_factor(player, "gravity", "amnv_items:w_sword")
		playerphysics.remove_physics_factor(player, "acceleration_air", "amnv_items:w_sword")
		playerphysics.remove_physics_factor(player, "acceleration_default", "amnv_items:w_sword")
	end,
	_on_step = function(stack, player, dtime) end,
	-- every step whether wielded or not
	_on_inventory_step = function(itemstack, player, dtime, list_name, list_index) end,
	-- on this item moved to another index and/or list
	_on_inventory_move = function(itemstack, player, from_list, to_list, from_index, to_index) end, --> return ==false to cancel
	-- before creating an item entity
	_on_drop = function(itemstack, player)end, --> return ==false to cancel
	-- after creating an item entity
	_on_dropped = function(itemstack, player, object) end,
})
