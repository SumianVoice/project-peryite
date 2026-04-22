
amnv_game.Gamemode.register_gamemode("lobby", {
	generator_name = "none",
	size = vector.new(80,160,80),
	_FSM_states = {
		await_mapgen = {
			on_start = function(self)
			end,
		}
	},
	_floor_pos = nil,
	on_start = function(self)
		self._floor_pos = (self.minp + self.maxp) / 2
		self._floor_pos.y = self.minp.y + (self.maxp.y - self.minp.y) * 0.2 + 9
	end,
	on_end = function(self)
	end,
	on_step = function(self, dtime)
	end,
	on_player_join = function(self, player)
		player:set_pos(self._floor_pos)
	end,
	on_player_leave = function(self, player) end,
})
