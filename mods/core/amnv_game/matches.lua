---@diagnostic disable: undefined-doc-name

local biome_count = 0
function amnv_game.register_biome(def)
    def.y_min = biome_count * 1600 - 16000
    def.y_max = (biome_count + 1) * 1600 - 16000 - 1
	core.register_biome(def)
	biome_count = biome_count + 1
end

---Gives a minp position given an index and a biome. Each biome has a y slice.
function amnv_game.get_match_pos(i, biome_name)
	local r = amnv_game.match_rows
	local s = amnv_game.match_spacing
	i = i - 1
	local bdef = core.registered_biomes[biome_name]
	local p1 = vector.new(
		((i%r) * s),
		bdef.y_min,
		((i-(i%r)) / r * s)
	) + amnv_game.chunk_offset
	return p1
end

---Gets the `Match` instance from a given position. Needs to check every active match currently.
---@param pos any
---@return Gamemode|nil
function amnv_game.get_match_from_pos(pos)
	-- local mp = vector.floor((pos + amnv_game.chunk_offset) / amnv_game.match_spacing)
	for i, match in ipairs(amnv_game.Gamemode.active_matches) do
		if amnv_game.is_box_point_overlap(match.minp, match.maxp, pos) then
			return match
		end
	end
end

---Sends the match info across to the mapgen thread.
function amnv_game.update_match_boxes()
	amnv_game.match_boxes = {}
	for i, match in ipairs(amnv_game.Gamemode.active_matches) do
		table.insert(amnv_game.match_boxes, {
			minp = match.minp,
			maxp = match.maxp,
			generator_name = match.generator_name,
			match_index = table.indexof(amnv_game.match_map[match.generator_name] or {}, match)
		})
	end
	core.ipc_set("amnv_game:mg_boxes", amnv_game.match_boxes)
	core.ipc_set("amnv_game:mg_update", true)
	core.log("updated boxes on main thread")
end

---Start a match if available, given a gamemode e.g. "survival" and a biome name e.g. "mesas".
function amnv_game.start_match(gamemode_name, biome_name)
	if amnv_game.dev_mode then return end
	if not core.registered_biomes[biome_name] then
		core.log("error", "[amnv_game.start_match] No biome with name: " .. biome_name)
		return
	end
	local matchlist = amnv_game.match_map[biome_name]
	if not matchlist then matchlist = {}; amnv_game.match_map[biome_name] = matchlist end
	local index = 0
	for i = 1, amnv_game.match_count_max do
		if matchlist[i] == nil then
			index = i
			break
		end
	end
	if index == 0 then return false end
	---@type Gamemode
	local def = assert(
		amnv_game.Gamemode.registered_gamemodes[gamemode_name],
		"No gamemode of name " .. tostring(gamemode_name)
	)
	local match = def:new()
	matchlist[index] = match
	match.generator_name = biome_name
	match.minp = amnv_game.get_match_pos(index, biome_name)
	match.maxp = match.minp + match.size - vector.new(1,1,1)
	match.index = index
	amnv_game.update_match_boxes()
	SIGNAL("on_match_started", match)
	core.delete_area(match.minp, match.maxp)
	return match
end

---@param match Gamemode
LISTEN("on_match_ended", function(match)
	core.delete_area(
		match.minp - vector.new(80, 80, 80) * 4,
		match.maxp + vector.new(80, 80, 80) * 4
	)
	amnv_game.update_match_boxes()
end)

---Gives a list of active matches. `return[1] == Match`
---@return table
function amnv_game.get_match_list()
	return amnv_game.Gamemode.active_matches
end

---@param match Gamemode
---@param player PlayerRef
---@param force boolean|nil
function amnv_game.player_join_match(match, player, force)
	if amnv_game.dev_mode then return end
	local pi = assert(amnv_game.pi(player))
	---@type Gamemode|nil
	local old_match = pi.match
	if force then
		amnv_game.player_leave_match(player)
		old_match = nil
	end
	if old_match then return false end
	if CONDITIONAL("can_player_join_match", match, player) == false then return end
	pi.match = match
	table.insert(match.players, player)
	match:on_player_join(player)
	SIGNAL("on_player_join_match", match, player)
end

function amnv_game.player_leave_match(player)
	local pi = assert(amnv_game.pi(player))
	---@type Gamemode|nil
	local match = pi.match
	if not match then return end
	if CONDITIONAL("can_player_leave_match", match, player) == false then return end
	pi.match = nil
	local i = table.indexof(match.players, player)
	if i and i > 0 then
		table.remove(match.players, i)
	end
	match:on_player_leave(player)
	SIGNAL("on_player_leave_match", match, player)
end

function amnv_game.get_player_match(player)
	return assert(amnv_game.pi(player)).match
end
