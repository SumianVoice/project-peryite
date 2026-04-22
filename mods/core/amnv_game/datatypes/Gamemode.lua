---@diagnostic disable: undefined-doc-name

---@class Gamemode
---@field gamestate FSM
---@field minp vector
---@field maxp vector
amnv_game.Gamemode = {
	minp = vector.new(0,0,0),
	maxp = vector.new(0,0,0),
	size = vector.new(80,160,80),
	generator_name = "none",
	index = 0,
	players = {},
	on_match_ended = SIGNAL.Signal.new(),
	on_match_joinplayer = SIGNAL.Signal.new(),
	on_match_leaveplayer = SIGNAL.Signal.new(),
	__init = false,
}

amnv_game.Gamemode.__index = amnv_game.Gamemode

amnv_game.Gamemode.registered_gamemodes = {}
amnv_game.Gamemode.active_matches = {}

---@param name string
---@param def table
---@return Gamemode
function amnv_game.Gamemode.register_gamemode(name, def)
	def.name = name
	local self = setmetatable(def, amnv_game.Gamemode)
	self.__meta = {__index = self}
	amnv_game.Gamemode.registered_gamemodes[name] = self
	return self
end

---Creates a new instance of this gamemode.
---@param self Gamemode
---@return Gamemode
function amnv_game.Gamemode:new(overrides)
	local match = setmetatable({}, self.__meta)
	table.insert(amnv_game.Gamemode.active_matches, match)
	for k, v in pairs(overrides or {}) do
		match[k] = v
	end
	return match
end

---@param player PlayerRef
function amnv_game.Gamemode:on_player_join(player) end
---@param player PlayerRef
function amnv_game.Gamemode:on_player_leave(player) end

function amnv_game.Gamemode:end_match()
	SIGNAL("on_match_ended", self)
end

core.register_globalstep(function(dtime)
	for i, match in ipairs(amnv_game.Gamemode.active_matches) do
		if not match.__init then
			match:on_start()
			match.__init = true
		end
		match:on_step(dtime)
		FSM.on_step(match, dtime)
	end
end)
