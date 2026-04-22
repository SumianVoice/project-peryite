
local generator_boxes = {}

local function is_box_point_overlap(a, b, p)
	return (
		p.x >= a.x and p.x <= b.x and
		p.y >= a.y and p.y <= b.y and
		p.z >= a.z and p.z <= b.z
	)
end
-- minp maxp, minp maxp
local function is_box_overlap(min1, max1, min2, max2)
	return (
		min1.x <= max2.x and max1.x >= min2.x and
		min1.y <= max2.y and max1.y >= min2.y and
		min1.z <= max2.z and max1.z >= min2.z
	)
end

local function update_boxes()
	core.log("updating boxes")
	generator_boxes = core.ipc_get("amnv_game:mg_boxes") or {}
	-- error(dump(generator_boxes))
end

--#todo: implement octree for performance
function mg_custom.get_generator_at(pos)
	-- core.log("mg_custom.get_generator_at")
	if core.ipc_get("amnv_game:mg_update") == true then
		core.ipc_set("amnv_game:mg_update", false)
		update_boxes()
	end
	local box = nil
	local generator_name = "none"
	for i, b in ipairs(generator_boxes) do
		if is_box_point_overlap(b.minp, b.maxp, pos) then
			generator_name = b.generator_name
			box = b
			break
		end
	end
	local generator = mg_custom.registered_generators[generator_name]
	if generator and box then
		-- core.log(generator_name .. "  :  ".. tostring(pos))
		generator._box_center = (
			vector.floor(vector.add(box.minp, box.maxp) / 2)
		)
		generator._box = box
	end
	return generator
end
