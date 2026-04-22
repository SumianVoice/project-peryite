
mg_custom.register_generator("flat", {
	nv_maps = {},
	nv_perlin = {},
	enable_schems = false,
	cids = {},
	cid_list = {},
	-- runs once per seed
	on_initialise = function(self, seed)
		for i, name in ipairs(self.cid_list) do
			self.cids[name] = mg_custom.to_cid(name)
		end
	end,
	mg_stone = "mapgen_stone",
	mg_dirt = "mapgen_dirt",
	mg_grass = "mapgen_dirt",
	mg_barrier = "amnv_nodes:barrier",
	_box_center = nil,
	-- runs for every node, including the node above the active chunk
	on_position_generated = function(self, pos, w, data, di, ni)
		local FH = math.floor(self._box.minp.y + (self._box.maxp.y - self._box.minp.y) * 0.2)
		if pos.y <= FH then
			data[di] = mg_custom.to_cid(self.mg_stone)
		else
			data[di] = mg_custom.to_cid("air")
		end
	end,
})
