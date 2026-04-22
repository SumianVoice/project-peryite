local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

mg_custom = {}

function mg_custom.sch(name)
	return (mod_path .. "/schematics/" .. name .. ".mts")
end

mg_custom.mg_name = core.get_mapgen_setting("mg_name")
mg_custom.enabled = (mg_custom.mg_name ~= "flat")

mg_custom.registered_generators = {}
mg_custom.generator = nil
mg_custom.generator_name = nil
mg_custom.seed = 12345
mg_custom.generate_everywhere = true

mg_custom.node_cid = {}

mg_custom.get_generator_on_every_node = false
rawset(mg_custom, "get_generator_at", function() return nil end)

function mg_custom.to_cid(node_name)
	local cid = mg_custom.node_cid[node_name]
	if not cid then
		cid = core.get_content_id(node_name)
		mg_custom.node_cid[node_name] = cid
	end
	return cid
end

function mg_custom.register_generator(name, def)
	mg_custom.registered_generators[name] = def
end

function mg_custom.set_generator(name, seed)
	mg_custom.generator = mg_custom.registered_generators[name]
	mg_custom.generator_name = name
	mg_custom.seed = seed or core.get_mapgen_setting("seed") or math.random(1,999999999)
end

function mg_custom.is_in_bounds(pos)
	return not ( -- if it's inside bounds
		((pos.y < mg_custom.minp.y) or (pos.y > mg_custom.maxp.y))
	or  ((pos.x < mg_custom.minp.x) or (pos.x > mg_custom.maxp.x))
	or  ((pos.z < mg_custom.minp.z) or (pos.z > mg_custom.maxp.z)))
end

local data = {}
local after_generated = function(vmanip, minp, maxp, blockseed)
	local gen = mg_custom.get_generator_at(minp) or mg_custom.generator
	if not gen then return end
	if not mg_custom.generate_everywhere then
		if (maxp.y < mg_custom.minp.y)
		or (maxp.x < mg_custom.minp.x)
		or (maxp.z < mg_custom.minp.z)
		or (minp.y > mg_custom.maxp.y)
		or (minp.x > mg_custom.maxp.x)
		or (minp.z > mg_custom.maxp.z) then
			return
		end
	end

	local emin, emax = vmanip:get_emerged_area()
	local w = {
		schems = {},
		gen = gen,
		minp = minp, maxp = maxp,
		emin = emin, emax = emax,
		vm = vmanip,
		area = VoxelArea:new{MinEdge = emin, MaxEdge = emax},
	}

	w.permapdims3d = vector.new(
		maxp.x - minp.x + 1,
		maxp.y - minp.y + 1 + 1,
		maxp.z - minp.z + 1
	)
	for name, p in pairs(gen.nv_maps or {}) do
		if not p.name then p.name = name end
		if not p.seed then p.seed = p.np.seed or 0 end
		if (p.map == nil) or p.np.seed ~= p.seed + mg_custom.seed then
			p.np.seed = p.seed + mg_custom.seed
			p.map = core.get_perlin_map(p.np, w.permapdims3d)
		end
		if not p.data then p.data = {} end
		p.map:get_3d_map_flat(minp, p.data or {})
	end

	for name, p in pairs(gen.nv_perlin or {}) do
		if not p.name then p.name = name end
		if not p.seed then p.seed = p.np.seed or 0 end
		p.np.seed = p.seed + mg_custom.seed
		if (p.perlin == nil) or p.np.seed ~= p.seed + mg_custom.seed then
			p.perlin = core.get_perlin(p.np)
		end
	end

	if gen.seed ~= mg_custom.seed then
		gen.seed = mg_custom.seed
		if gen.on_initialise then
			gen.on_initialise(gen, mg_custom.seed)
		end
	end

	w.vm:get_data(data)

	local ni = 1
	for di in w.area:iterp(minp, vector.offset(maxp, 0, 1, 0)) do
		local pos = w.area:position(di)
		if gen.on_position_generated
		and (mg_custom.generate_everywhere or mg_custom.is_in_bounds(pos)) then
			gen:on_position_generated(pos, w, data, di, ni)
		end
		ni = ni + 1
	end

	w.vm:set_data(data)

	for i, def in ipairs(w.schems) do
		core.place_schematic_on_vmanip(
			w.vm, def.pos, mg_custom.sch(def.name), def.rot or "random", nil,
			def.force_placement == true, def.flags or "place_center_x, place_center_z")
	end

	w.vm:calc_lighting()
	core.generate_ores(vmanip, minp, maxp)
	core.generate_decorations(vmanip, minp, maxp)
end


local function test_on_emerge_callback(calls_remaining, callback)
	if calls_remaining == 0 and callback then
		callback()
	end
end

function mg_custom.emerge(callback, minp, maxp)
	minp, maxp = minp or mg_custom.minp, maxp or mg_custom.maxp
	core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining, param)
		test_on_emerge_callback(calls_remaining, callback)
	end)
end

function mg_custom.regenerate(minp, maxp, force_emerge, callback)
	if not mg_custom.enabled then return end
	core.log("action", "regenerating for mapgen")
	core.delete_area(minp, maxp)
	if not force_emerge then return end
	core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining, param)
		-- if action == core.EMERGE_ERRORED or action == core.EMERGE_CANCELLED then end
		test_on_emerge_callback(calls_remaining, callback)
	end)
end

if core.get_mapgen_setting("mg_name") == "singlenode" then
	core.register_on_generated(after_generated)
end
