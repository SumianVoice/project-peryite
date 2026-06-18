---@diagnostic disable: undefined-doc-name
local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_game = {}

amnv_game.dev_mode = (core.get_mapgen_setting("mg_name") ~= "singlenode")

amnv_game.match_map = {}
amnv_game.match_boxes = {}
amnv_game.match_rows = 8
amnv_game.match_count_max = amnv_game.match_rows ^ 2
amnv_game.match_spacing = 3200
amnv_game.chunk_offset = vector.new(48, 48, 48)

amnv_game.ores = {}
amnv_game.ore_list = {}

amnv_game._playerdata = {}
function amnv_game.pi(player)
	if not core.is_player(player) then return nil end
	local pi = amnv_game._playerdata[player]
	if not pi then pi = {}; amnv_game._playerdata[player] = pi end
	return pi
end

dofile(mod_path .. "/datatypes/Gamemode.lua")

dofile(mod_path .. "/world_logic.lua")
dofile(mod_path .. "/matches.lua")

dofile(mod_path .. "/biomes/flat_biome.lua")
dofile(mod_path .. "/biomes/mesas_biome.lua")

dofile(mod_path .. "/gamemodes/survival.lua")
dofile(mod_path .. "/gamemodes/lobby.lua")

core.register_mapgen_script(mod_path .. "/mg_core_mapgen.lua")
core.register_mapgen_script(mod_path .. "/mapgen/mesas.lua")
core.register_mapgen_script(mod_path .. "/mapgen/flat.lua")


-- don't do testing stuff when in dev mode
if amnv_game.dev_mode then return end


core.register_on_joinplayer(function(player, last_login)
	for i, match in ipairs(amnv_game.Gamemode.active_matches) do
		---@type Gamemode
		match = match
		if match.name == "survival" then
			amnv_game.player_join_match(match, player, true)
		end
	end
end)


core.set_mapgen_setting("seed", 54352, true)
amnv_game.start_match("lobby", "mesas")
amnv_game.start_match("survival", "mesas")

-- error(dump(amnv_game.match_map))

core.register_on_joinplayer(function(player, last_login)
	-- player:get_inventory():set_stack("main", 1, ItemStack("amnv_items:w_gl"))
	player:get_inventory():set_stack("main", 1, ItemStack("amnv_items:w_sword"))
	player:get_inventory():set_stack("main", 2, ItemStack("amnv_items:w_gl"))
end)


