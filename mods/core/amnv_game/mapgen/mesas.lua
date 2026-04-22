
local function dist2(p1, p2)
	return (p1.x - p2.x)^2 + (p1.z - p2.z)^2 + (p1.y - p2.y)^2
end

local function sinelike_dist(x, f)
	x = math.min(1, math.max(x, 0))
	return (x^2) / (x^2 + (1-x)^f)
end

local function terrace(x, t, f)
	return (math.round(x / t) * t) * f + x * (1-f)
end

local function lerp(a,b,f)
	return (a*(1-f) + b*f)
end

local function is_box_point_overlap(a, b, p)
	return (
		p.x >= a.x and p.x <= b.x and
		p.y >= a.y and p.y <= b.y and
		p.z >= a.z and p.z <= b.z
	)
end

mg_custom.register_generator("mesas", {
	nv_maps = {
		ter1 = {
			np = {
				spread = {x = 16, y = 8000, z = 16},
				seed = 654,
				octaves = 2,
				persist = 0.3,
				lacunarity = 2.31,
				offset = 0.5,
				scale = 0.5,
			},
		},
		ter2 = {
			np = {
				spread = {x = 16, y = 8000, z = 16},
				seed = 7654,
				octaves = 2,
				persist = 0.3,
				lacunarity = 2.31,
				offset = 0.5,
				scale = 0.5,
			},
		},
		small1 = {
			np = {
				spread = {x = 8, y = 160, z = 8},
				seed = 765,
				octaves = 2,
				persist = 0.21,
				lacunarity = 2.27,
				offset = 0.5,
				scale = 0.5,
			},
		},
		ele1 = {
			np = {
				spread = {x = 80, y = 1000, z = 80},
				seed = 234,
				octaves = 3,
				persist = 0.2,
				lacunarity = 2.76,
				offset = 0.5,
				scale = 0.5,
			},
		},
	},
	nv_perlin = {
	},
	enable_schems = false,
	cids = {},
	cid_list = {},
	-- runs once per seed
	on_initialise = function(self, seed)
		for i, name in ipairs(self.cid_list) do
			self.cids[name] = mg_custom.to_cid(name)
		end
	end,
	mg_stone = "amnv_nodes:sandstone",
	mg_dirt = "amnv_nodes:sand",
	mg_barrier = "amnv_nodes:barrier",
	_box_center = nil,
	-- runs for every node, including the node above the active chunk
	on_position_generated = function(self, pos, w, data, di, ni)
		-- error(tostring(pos) .. " box minp " .. tostring(self._box.minp) .. " box maxp " .. tostring(self._box.maxp) .. "   :   " .. dump(self._box))
		local nv_maps = self.nv_maps
		local flatten_factor = 0
		local cdist = 999
		local max_dist = (self._box.maxp.x - self._box.minp.x) * 0.5
		if self._box_center then
			local p1 = vector.copy(self._box_center)
			p1.y = pos.y
			cdist = vector.distance(p1, pos)
			flatten_factor = 1 - math.min(20, math.max(cdist-10, 0)) / 20
			flatten_factor = math.max(flatten_factor, math.max(0, math.min(1, (cdist - max_dist*0.6) / (max_dist*0.2) + 0.2)))
		end
		local is_edge = not is_box_point_overlap(self._box.minp+vector.new(1,1,1), self._box.maxp-vector.new(1,1,1), pos)
		if is_edge then
			data[di] = mg_custom.to_cid(self.mg_barrier)
			return
		end

		local FH = math.floor(self._box.minp.y + (self._box.maxp.y - self._box.minp.y) * 0.2)

		if cdist > 50 and (pos.y <= FH) and flatten_factor > 0.8 then
			data[di] = mg_custom.to_cid("amnv_nodes:dried_riverbed")
			return
		end

		--- 1: sand, 2: stone
		local terrain_type = 0
		local T1 = 1-sinelike_dist(nv_maps.ter1.data[ni], 3)
		local T2 = 1-sinelike_dist(nv_maps.ter1.data[ni], 3)
		local S1 = sinelike_dist(nv_maps.small1.data[ni], 2)
		local E1 = nv_maps.ele1.data[ni]
		local H = 0
		local PH = pos.y - FH
		while true do
			local base_height = ((cdist > 50) and 0 or 8)
			H = math.min(20, (1-(T1)-T2) * 40 - 30) + sinelike_dist(E1, 2) * 20
			H = terrace(H, 6, 0.9) - S1*2
			H = H - flatten_factor * (H - base_height)
			if (PH <= H) then
				terrain_type = 2
				break
			end
			H = (1-T1) * 3 + sinelike_dist(E1, 2) * 10
			H = H - flatten_factor * (H - base_height)
			if (PH <= H) then
				terrain_type = 1
				break
			end
		break end

		if terrain_type == 1 then
			data[di] = mg_custom.to_cid("amnv_nodes:sand")
		elseif terrain_type == 2 then
			data[di] = mg_custom.to_cid(self.mg_stone)
		elseif terrain_type == 0 then
			pos.y = pos.y - 1
			local below_index = w.area:indexp(pos)
			if (data[below_index] == mg_custom.to_cid("amnv_nodes:sand")) then
				data[below_index] = mg_custom.to_cid("amnv_nodes:sand_top")
			end
		end

		-- data[di] = mg_custom.to_cid(self.mg_stone)
	end,
})
