---@diagnostic disable: undefined-doc-name
local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_buildings.registered_buildings = {}

function amnv_buildings.register_building(def)
	amnv_buildings.registered_buildings[def.node_name] = def
end

function amnv_buildings.place_building_blueprint(pos, name, placer, flags)
end

function amnv_buildings.try_place_building(pos, name, placer, flags)
	flags = flags or {}
	pos = vector.floor(pos)
	if (not flags.force_placement) or CONDITIONAL("amnv_buildings:can_place", pos, name, placer, flags) then
		local obj = assert(amnv_buildings.place_building_blueprint(pos, name, placer, flags))
		SIGNAL("amnv_buildings:on_place", pos, name, placer, obj, flags)
	end
end

core.register_entity("amnv_buildings:blueprint", {
	initial_properties = {
		visual = "mesh",
		mesh = "amnv_buildings_blueprint.b3d",
		textures = {"[fill:1x1:#37e"},
		stepheight = 0,
		hp_max = 1,
		physical = false,
		pointable = false,
		collide_with_objects = false,
		collisionbox = {0,0,0,0,0,0},
		static_save = true,
	},
	_construction = 0.0,
	_bdef = nil,
	_add_construction = function(self, user, amount)
	end,
	_take_construction = function(self, user, amount)
	end,
	_on_completed = function(self, user)
	end,
	_on_destroyed = function(self, user)
	end,
	_initialise = function(self, bdef)
		self._bdef = bdef
	end,
	on_step = function(self, dtime)
	end,
	-- on_punch = function(self)
	--     self.object:remove()
	-- end,
	on_activate = function(self, staticdata, dtime_s)
		local data = core.deserialize(staticdata)
		if data then
			for key, val in pairs(data) do
				self[key] = val
			end
			if data._rotation then
				self.object:set_rotation(data._rotation)
			end
		end
	end,
	get_staticdata = function(self)
		local data = {}
		for i, key in pairs(self._aom_staticdata_load_list) do
			if key and self[key] ~= nil then
				data[key] = self[key]
			end
		end
		data._rotation = self.object:get_rotation()
		return core.serialize(data)
	end,
	on_deactivate = function(self, removal)
	end,
})

