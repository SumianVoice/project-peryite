
-- ## Example:
--[[

	core.register_node("my_mod:my_node", {
		paramtype2 = "facedir",
		_multinode = {
			-- List of nodes to place and remove when placing and removing this node.
			-- In format `nodes[i] = {position, node, flags|nil}`. These can be any node.
			nodes = {
				-- usually you would just be using an invisible barrier, but you can use any node and rotation
				{vector.new(1,  0,  0), {name="my_mod:my_node_right", param1=1}},
				{vector.new(-1, 0,  0), {name="my_mod:my_node_left"}},
				{
					-- offset when node is facedir == 0
					vector.new(0,  1,  0),
					-- node
					{name="my_mod:my_node_top"},
					-- you can also specify flags in the [3] slot
					{
						-- alternative nodes that don't trigger this node being dug
						alts = { ["my_mod:my_node_right"] = true },
						-- don't need this to be placeable, and won't trigger dig (so ignores above alt nodes)
						optional = true,
						-- If true, you can place this such that it overlaps existing nodes.
						allow_already_present = nil,
						-- If true, digs existing nodes that it overlaps. This does not check for `buildable_to`.
						force = nil,
					}
				},
			},
			-- Whether to rotate the nodes above according to param2
			no_rotation = nil,
			-- Skips overriding `on_construct`, same flags for other `no_*` fields.
			no_on_construct = nil,
			no_on_destruct = nil,
			no_on_place = nil,
			-- Stops node checking and replacing its extra nodes when updated (by punch, place etc).
			no_on_node_update = nil,
			-- Stops node adding its extra nodes back if they are missing.
			no_add_nodes_again_on_update = nil,
			-- Stops node being destroyed when it detects a node missing and can't replace it.
			no_dig_if_missing_nodes = nil,
			-- If true, skips checking if all the `nodes` can be placed and just does it.
			-- Does not cause overwriting non-`buildable_to` nodes however.
			always_place = nil,
		},
	})
--]]
multinode = {}

multinode.registered_cids = {}

multinode.visible_blocker_node = true

local node_updates = (core.get_modpath("node_updates") ~= nil) and _G.node_updates
local has_node_updates_warning = false

-- blocks other nodes from being placed
core.register_node("multinode:blocker", {
	description = "",
	pointable = false, buildable_to = false, floodable = false, walkable = false,
	groups = { not_in_creative_inventory = 1, obstacle = 1, },
	sunlight_propagates = true, paramtype = "light",
	drawtype = multinode.visible_blocker_node and "glasslike" or "airlike",
	tiles = {
		"[combine:64x64:0,0=blank.png" ..
		"^[fill:64x1:0,0:#fff" ..
		"^[fill:64x1:0,63:#fff" ..
		"^[fill:1x64:0,0:#fff" ..
		"^[fill:1x64:63,0:#fff"
	},
})

local __cardinal_rotate_filters = {
	function (v) return vector.new( v.x, v.y, v.z) end, -- 0
	function (v) return vector.new( v.z, v.y,-v.x) end, -- 90
	function (v) return vector.new(-v.x, v.y,-v.z) end, -- 180
	function (v) return vector.new(-v.z, v.y, v.x) end, -- 270
}
-- rotates vector around Y axis, snapped to cardinal (90 degree) directions
function multinode.cardinal_rotate(v, r)
	return __cardinal_rotate_filters[math.round(r) % 4 + 1](v)
end

local paramtypes = {
	wallmounted = "wallmounted",
	facedir = "facedir",
	["4dir"] = "fourdir",
	colorwallmounted = "wallmounted",
	colorfacedir = "facedir",
	color4dir = "fourdir",
}

function multinode.get_eyepos(player)
	local eyepos = vector.add(player:get_pos(), vector.multiply(player:get_eye_offset(), 0.1))
	eyepos.y = eyepos.y + player:get_properties().eye_height
	return eyepos
end

function multinode.get_tool_range(itemstack)
	local range = itemstack and itemstack:get_definition().range
	if not range then
		range = minetest.registered_items[""].range or 4
	end
	return range
end

-- checks if can rightclick node/entity etc, returns itemstack if it did find something, else nil
function multinode.try_rightclick(itemstack, user, pointed_thing, dry)
	if not pointed_thing then return end
	if not core.is_player(user) then return nil end
	local ctrl = user:get_player_control()
	if ctrl and ctrl.sneak then return nil end
	if pointed_thing.ref then
		-- There is no way to know whether an entity's on_rightclick was used for something
		-- this means you either shoot someone you're trying to talk to, or can't shoot something
		-- that is attacking you.
		local ent = (user ~= pointed_thing.ref) and pointed_thing.ref:get_luaentity()
		if ent and ent.on_rightclick then
			return itemstack
		end
	elseif pointed_thing.type == "node" then
		local def = core.registered_nodes[core.get_node(pointed_thing.under).name]
		if def.on_rightclick then
			if not dry then
				local node = core.get_node(pointed_thing.under)
				itemstack = def.on_rightclick(pointed_thing.under, node, user, ItemStack(itemstack), pointed_thing) or itemstack
			end
			return itemstack
		end
		return
	end
	return nil
end

---Predicts and returns the position and node (including param2) or `nil, nil` if it's not possible to place.
---@param itemstack `itemstack`
---@param placer table `playerRef`
---@param pointed_thing table
---@return table|nil `vector`
---@return table|nil `node`
function multinode.get_on_place_prediction(itemstack, placer, pointed_thing)
	local idef = itemstack:get_definition()
	if not idef then return end
	local place_pos
	local place_node = {name=itemstack:get_name(), param2=0}
	local unode = core.get_node_or_nil(pointed_thing.under)
	local udef = unode and core.registered_nodes[unode.name]
	local anode = core.get_node_or_nil(pointed_thing.above)
	local adef = anode and core.registered_nodes[anode.name]
	if (not udef) or udef.buildable_to then
		place_pos = pointed_thing.under
	elseif (not adef) or adef.buildable_to then
		place_pos = pointed_thing.above
	end
	if not place_pos then return end
	local p2type = idef.paramtype2
	if paramtypes[p2type] then
		place_node.param2 = core["dir_to_" .. paramtypes[p2type]](
			vector.subtract(place_pos, placer:get_pos())
		)
	else
		return
	end
	return place_pos, place_node
end

function multinode.override_item(iname, idef)
	local old_on_construct = idef.on_construct
	local old_on_destruct = idef.on_destruct
	local old_on_place = idef.on_place or core.item_place_node
	local old_on_node_update = idef._on_node_update
	local overrides = {}

	if not idef._multinode.no_on_construct then
		overrides.on_construct = old_on_construct and function(pos, ...)
			multinode.on_construct(pos)
			old_on_construct(pos, ...)
		end or multinode.on_construct
	end
	if not idef._multinode.no_on_destruct then
		overrides.on_destruct = old_on_destruct and function(pos, ...)
			multinode.on_destruct(pos)
			old_on_destruct(pos, ...)
		end or multinode.on_destruct
	end
	if not idef._multinode.no_on_place then
		overrides.on_place = function(itemstack, placer, pointed_thing)
			local ret = multinode.try_rightclick(itemstack, placer, nil, false)
			if ret then return ret, nil end
			-- predict placement pos and param2
			local pos, node
			if idef._get_on_place_prediction then
				pos, node = idef._get_on_place_prediction(itemstack, placer, pointed_thing)
			else
				pos, node = multinode.get_on_place_prediction(itemstack, placer, pointed_thing)
			end
			if not (pos and node) then return end
			-- test if the multinode nodes can be placed
			local can_place = idef._multinode.always_place or multinode.can_place(pos, node)
			if not can_place then return end
			return old_on_place(itemstack, placer, pointed_thing)
		end
	end
	if not idef._multinode.no_on_node_update then
		if (not node_updates) and not has_node_updates_warning then
			has_node_updates_warning = true
			core.log("warning", "[multinode] no `node_updates` mod detected."
			.. " This means nodes will not automatically detect and dig themselves when they have missing parts.")
		end
		overrides._on_node_update = function(pos, cause, user, data)
			if cause == "dig" then
				goto old_call
			end
			-- don't add nodes again
			if idef._multinode.no_add_nodes_again_on_update then
				if idef._multinode.no_dig_if_missing_nodes then
					-- do nothing
				else
					local success = multinode.process_all(pos, multinode.check_can_place)
					if (not success) then
						-- core.log("dug because could not place all nodes but didn't try to place")
						core.dig_node(pos)
						return nil, true
					end
				end
			-- do add nodes again
			else
				if idef._multinode.no_dig_if_missing_nodes then
					-- core.log("placed nodes without doing anything else")
					multinode.process_all(pos, multinode.place_nodes)
				else
					-- core.log("trying to place nodes")
					local success = multinode.process_all(pos, multinode.place_nodes_abort_on_failure)
					if (not success) then
						-- core.log("dug because tried but failed to place nodes")
						core.dig_node(pos)
						return nil, true
					end
				end
			end
			::old_call::
			if old_on_node_update then
				return old_on_node_update(pos, cause, user, data) or nil
			end
		end
	end

	core.override_item(iname, overrides)
end

core.register_on_mods_loaded(function()
	for iname, idef in pairs(core.registered_nodes) do if idef._multinode then
		multinode.override_item(iname, idef)
	end end
end)

-- Runs `func` on every node in your `_multinode.nodes` definition.
--[[

	local success = multinode.process_all(
		pos,
		function(pos, placement_def, origin_pos, origin_node)
			return nil -- continue
			return true -- break and return true
			return false -- break and return false
		end,
		idef,
		node
	)
]]
function multinode.process_all(pos, func, idef, node)
	node = node or core.get_node(pos)
	idef = idef or core.registered_nodes[node.name]
	if not idef._multinode then return end
	local no_rotation = idef._multinode.no_rotation
	local rot = node.param2 % 4
	for i, def in ipairs(idef._multinode.nodes or {}) do repeat
		local p = pos + (no_rotation and def[1] or multinode.cardinal_rotate(def[1], rot))
		local result = func(p, def, pos, node)
		if result == false then return false
		elseif result == true then return true end
	until true end
	return true
end

function multinode.rotate_param2(p2, r)
	local diff = (p2 + r) % 4
	p2 = (p2 - (p2 % 4)) + diff
end

-- Internal, do not use.
-- Place nodes according to the `_multinode` table and node.
-- Does no checks, always places.
function multinode.place_node(pos, placement_def, origin_pos, origin_node)
	local placenode = table.copy(placement_def[2])
	local placedef = core.registered_nodes[placenode.name]
	if paramtypes[placedef.paramtype2] ~= nil then
		placenode.param2 = placenode.param2 or 0
		placenode.param2 = multinode.rotate_param2(placenode.param2, origin_node.param2)
	end
	core.set_node(pos, placenode)
end

-- Internal, do not use.
function multinode.place_nodes_abort_on_failure(pos, placement_def, origin_pos, origin_node)
	local node = core.get_node_or_nil(pos)
	if node and (node.name == placement_def[2].name) then return end
	local ndef = node and core.registered_nodes[node.name]
	if (ndef and ndef.buildable_to) or (placement_def[3] and placement_def[3].force)
	or (core.get_item_group(node.name, "multinode_diggable") > 0) then
		core.dig_node(pos)
		multinode.place_node(pos, placement_def, origin_pos, origin_node)
	elseif not (placement_def[3] or {}).optional then
		return false
	end
end
-- Internal, do not use.
function multinode.place_nodes(pos, placement_def, origin_pos, origin_node)
	local flags = (placement_def[3] or {})
	local node = core.get_node_or_nil(pos)
	if node and (node.name == placement_def[2].name) then return end
	local ndef = node and core.registered_nodes[node.name]
	if (ndef and ndef.buildable_to) or (flags.force)
	or (core.get_item_group(node.name, "multinode_diggable") > 0) then
		core.dig_node(pos)
		multinode.place_node(pos, placement_def, origin_pos, origin_node)
	end
end
-- Internal, do not use.
function multinode.remove_nodes(pos, placement_def, origin_pos, origin_node)
	local node = core.get_node_or_nil(pos)
	if node and (node.name == placement_def[2].name) then
		core.set_node(pos, {name="air"})
	end
end
-- Internal, do not use.
function multinode.check_can_place(pos, placement_def, origin_pos, origin_node)
	local flags = (placement_def[3] or {})
	if flags.optional == true then return end
	local node = core.get_node_or_nil(pos)
	if node and flags.allow_already_present and (node.name == placement_def[2].name)
	and node.param2 == placement_def[2].param2 then return end
	if node and flags.alts and flags.alts[node.name] then return end
	local ndef = node and core.registered_nodes[node.name]
	if (ndef and ndef.buildable_to) or (flags.force) then return end
	if (core.get_item_group(node.name, "multinode_diggable") > 0) then return end
	return false
end

---Tests if this node can be placed here without occupying a non-`buildable_to` node.
---@param pos table `vector`
---@param node table `node, {name="my_mod:my_node", param2=0}`
---@return boolean|nil
function multinode.can_place(pos, node)
	return multinode.process_all(pos, multinode.check_can_place, nil, node)
end

---Used to override `on_construct` in the node definition.
---@param pos table `vector`
function multinode.on_construct(pos)
	multinode.process_all(pos, multinode.place_nodes)
end

---Used to override `on_destruct` in the node definition.
---@param pos table `vector`
function multinode.on_destruct(pos)
	multinode.process_all(pos, multinode.remove_nodes)
end
