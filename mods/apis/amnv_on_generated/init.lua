local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

amnv_on_generated = {}

amnv_on_generated.cid_after_generated_callbacks = {}
local cidcalls_after = amnv_on_generated.cid_after_generated_callbacks
amnv_on_generated.cid_on_generated_callbacks = {}
local cidcalls_on = amnv_on_generated.cid_on_generated_callbacks

minetest.register_on_mods_loaded(function()
    for nodename, def in pairs(minetest.registered_nodes) do
        if def._after_generated then
            local cid = minetest.get_content_id(nodename)
            cidcalls_after[cid] = def._after_generated
        end
        if def._on_generated then
            local cid = minetest.get_content_id(nodename)
            cidcalls_on[cid] = def._on_generated
        end
    end
end)

-- local avgtime = 0
local data = {}
local after_generated = function(minp, maxp, seed)
    -- local cl = os.clock()
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

    local do_after = {}
	vm:get_data(data)
	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		local di = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
            -- after_generated
            local callback = cidcalls_after[data[di]]
            if callback then
                table.insert(do_after, {
                    callback,
                    vector.new(x, y, z),
                })
            end
            -- on_generated
            callback = cidcalls_on[data[di]]
            if callback then
                local ret = callback(vector.new(x, y, z), vm)
                if ret then data[di] = ret end
            end
			di = di + 1
		end
	end end
    vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_liquids()
    -- actually run the after_generated calls
    for i, callback in ipairs(do_after) do
        callback[1](callback[2])
    end
    -- avgtime = ((avgtime * 9) + (os.clock()-cl)) * 0.1
    -- minetest.log(avgtime)
end
minetest.register_on_generated(after_generated)
