local elemname = "bform_scrollbar"

---@class bform_scrollbar : bform_prototype
---@field is_hide_arrows boolean
---@field name string
---@field orientation string
---@field smallstep number
---@field thumbsize number
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- scrollbar[<X>,<Y>;<W>,<H>;<orientation>;<name>;<value>]

-- UNDER CONSTRUCTION

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
	table.insert(fs, table.concat({
		"scrollbar[", self.pos[1], ",", self.pos[2], ";",
		self.size[1], ",", self.size[2], ";",
		self.orientation, ";", F(self.name), ";", 0, --TODO: add scroll memory
		"]"
	}))
	return fs
end

---@return table
function class:render_after(fs, data, ...)
	table.insert(fs, table.concat({
		"scrollbaroptions[arrows=", self.is_hide_arrows and "hide" or "show", ";smallstep=", self.smallstep,
		";thumbsize=", self.thumbsize, ";max=",
		math.max(0, self.extent[2] - self.size[2]) * 10,
		"]",
	}))
	return fs
end

---@return bform_scrollbar
---@param size table | nil
---@param id string | nil
---@param is_horizontal boolean | nil
---@param name string | nil
function class.new(size, id, name, is_horizontal, smallstep, thumbsize, is_hide_arrows)
	local ret = {
		id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
		size = size or {0, 0},
		orientation = is_horizontal and "horizontal" or "vertical",
		is_hide_arrows = is_hide_arrows or false,
		smallstep = smallstep or 10,
		thumbsize = thumbsize or 20,
		name = name or "",
		offset = {0, 0},
		dir = {0,0},
		--
		pos = {0, 0},
		children = {},
	}
	return setmetatable(ret, {__index = class})
end

aom_bform.element.scrollbar = class
