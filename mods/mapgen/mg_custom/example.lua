
local function dist2(p1, p2)
	return (p1.x - p2.x)^2 + (p1.z - p2.z)^2 + (p1.y - p2.y)^2
end

mg_custom.register_generator("example", {
	nv_maps = {
		ter1 = {
			np = {
				spread = {x = 20, y = 70, z = 20},
				seed = 8467,
				octaves = 3,
				persist = 0.4,
				lacunarity = 1.841,
				offset = 0.5,
				scale = 0.5,
			},
		},
		ter2 = {
			np = {
				spread = {x = 20, y = 80, z = 20},
				seed = 234,
				octaves = 2,
				persist = 0.1,
				lacunarity = 2.1,
				offset = 0.5,
				scale = 0.5,
			},
		},
		ele1 = {
			np = {
				spread = {x = 100, y = 100, z = 100},
				seed = 234,
				octaves = 4,
				persist = 0.2,
				lacunarity = 2.3771,
				offset = 0.5,
				scale = 0.5,
			},
		},
		topsoil = {
			np = {
				spread = {x = 18, y = 4, z = 18},
				seed = 234,
				octaves = 2,
				persist = 0.1,
				lacunarity = 2.25,
				offset = 0.5,
				scale = 0.5,
			},
		},
		dirt = {
			np = {
				spread = {x = 12, y = 12, z = 12},
				seed = 7659,
				octaves = 4,
				persist = 0.1,
				lacunarity = 2.25,
				offset = 0.5,
				scale = 0.5,
			},
		},
	},
	nv_perlin = {
	},
	enable_schems = false,
	is_top_down = true,
	cids = {},
	cid_list = {},
	-- runs once per seed
	on_initialise = function(self, seed)
		for i, name in ipairs(self.cid_list) do
			self.cids[name] = mg_custom.to_cid(name)
		end
	end,
	_is_nvs_terrain = function(self, pos, T1, T2, E1)
		T2 = T2 * ((pos.y+T1*10) % (100+50*E1)) / (100+50*E1)
		T2 = T2 ^ 4
		return T1^2 > 0.2 and T2^(E1+0.05)*0.5 > 0.2
	end,
	_is_terrain = function(self, pos, w, data, di, ni)
		local nv_maps = self.nv_maps
		local T1 = nv_maps.ter1.data[ni]
		local T2 = nv_maps.ter2.data[ni]
		local E1 = nv_maps.ele1.data[ni]
		return self:_is_nvs_terrain(pos, T1, T2, E1)
	end,
	mg_stone = "mapgen_stone",
	mg_dirt = "mapgen_stone",
	mg_grass = "mapgen_stone",
	-- runs for every node, including the node above the active chunk
	on_position_generated = function(self, pos, w, data, di, ni)
		local is_terrain = self:_is_terrain(pos, w, data, di, ni)
		if is_terrain then
			if data[di] == mg_custom.to_cid("air") then
				local D1 = self.nv_maps.dirt.data[ni]
				if D1 > 0.5 then
					data[di] = mg_custom.to_cid(self.mg_dirt)
				else
					data[di] = mg_custom.to_cid(self.mg_stone)
				end
			end
		else
			local nv_maps = self.nv_maps
			local TOPSOIL = nv_maps.topsoil.data[ni]
			for i = 1, math.ceil(1 + 8 * TOPSOIL) do
				pos.y = pos.y - 1
				local below_index = w.area:indexp(pos)
				local bd = data[below_index]
				if (bd ~= mg_custom.to_cid(self.mg_dirt)) and (bd ~= mg_custom.to_cid(self.mg_stone)) then break end
				if i == 1 then
					data[below_index] = mg_custom.to_cid(self.mg_grass)
				else
					data[below_index] = mg_custom.to_cid(self.mg_dirt)
				end
			end
		end
	end,
})

mg_custom.set_generator("example")
