
---Finite State Machine
---@class FSM
---@field _FSM_active_state_name string
---@field _FSM_state_meta table
---@field _FSM_states table
---@field _FSM_has_init boolean|nil
---@field _globalstep_enabled boolean|nil
FSM = {}

local _state_machine_globalsteps = {}

-- runs every time you change stuff, to make sure your entity is set up correctly
function FSM.init_states(self)
	if self._FSM_has_init then return end
	self._FSM_active_state_name = ""
	self._FSM_state_meta = {state_time = 0}
	self._FSM_states = self._FSM_states or {}
	for i, state in ipairs(self._FSM_states) do
		self._FSM_states[state.name] = state
	end
	self._FSM_has_init = true
end
-- get the temporary metadata that is given to each state seperately
---@param state_name string
function FSM.get_state_meta(self, state_name)
	return self._FSM_state_meta
end
-- do the state code, based on functype e.g. on_step or on_end
---@param state_name string
---@param functype string
function FSM.do_state(self, state_name, functype, ...)
	if self._FSM_states[state_name] and self._FSM_states[state_name][functype] then
		return self._FSM_states[state_name][functype](self, ...)
	end
end
-- set a single state and trigger its on_start if it isn't already active
---@param new_state_name string
function FSM.set_state(self, new_state_name)
	FSM.init_states(self)
	local old_state_name = self._FSM_active_state_name
	local old_state_exists = (self._FSM_states[old_state_name] ~= nil)
	if old_state_exists then
		local meta = self._FSM_state_meta
		FSM.do_state(self, old_state_name, "on_end", meta)
	end
	-- start new state
	self._FSM_active_state_name = new_state_name
	self._FSM_state_meta = {
		state_time = 0,
	}
	FSM.do_state(self, new_state_name, "on_start", self._FSM_state_meta)
end
-- get the state name ("" if not set yet)
function FSM.get_state(self)
	return self._FSM_active_state_name
end
-- put this in your on_step of your entity (or use the enable_globalstep if it's not an entity)
function FSM.on_step(self, dtime)
	FSM.init_states(self)
	local state_name = self._FSM_active_state_name
	local state_exists = (self._FSM_states[state_name] ~= nil)
	if not state_exists then return end
	local meta = self._FSM_state_meta
	local new_state_name = FSM.do_state(self, state_name, "on_step", dtime, meta)
	meta.state_time = meta.state_time + dtime
	if new_state_name then
		return FSM.set_state(self, new_state_name)
	end
end
-- add to the globalstep list so that `on_step` happens automatically
function FSM.enable_globalstep(self)
	if self._globalstep_enabled then return end
	self._globalstep_enabled = true
	table.insert(_state_machine_globalsteps, self)
end
-- remove from the globalstep list so it doesn't `on_step`
function FSM.disable_globalstep(self)
	if not self._globalstep_enabled then return end
	local i = table.indexof(_state_machine_globalsteps, self)
	if i > 0 then
		table.remove(_state_machine_globalsteps, i)
	end
end

core.register_globalstep(function(dtime)
	-- iterate backwards in case any state machine removes itself
	for i = #_state_machine_globalsteps, 1, -1 do
		_state_machine_globalsteps[i]:on_step(dtime)
	end
end)

FSM.__index = FSM

--- Create a new state machine, optionally inserting it into `host` table.
--- 
--- Example:
--[[

	local my_fsm = FSM.new({
		_FSM_states = {
			idle = {
				on_start = function(fsm, meta)
					core.log("idle start")
				end,
				on_end = function(fsm, meta)
					core.log("idle end")
				end,
				on_step = function(fsm, dtime, meta)
					if meta.state_time > 4 then
						return "test"
					end
				end,
			},
			test = {
				on_start = function(fsm, meta)
					core.log("test start")
				end,
				on_end = function(fsm, meta)
					core.log("test end")
				end,
				on_step = function(fsm, dtime, meta)
					if meta.state_time > 4 then
						return "idle"
					end
				end,
			},
		},
	})
	my_fsm:enable_globalstep()
	my_fsm:set_state("idle")
--]]
---@param host table
---@param parent table|nil
---@return FSM
function FSM.new(host, parent)
	local new = setmetatable(host or {}, FSM)
	new.parent = parent
	return new
end
