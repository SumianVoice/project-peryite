local elemname = "bform_scroll_container"

---@class bform_scroll_container : bform_prototype
---@field orientation string | "horizontal" | "vertical"
---@field scroll_factor number
---@field content_padding number
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- scroll_container[<X>,<Y>;<W>,<H>;<scrollbar name>;<orientation>;<scroll factor>;content_padding]

-- UNDER CONSTRUCTION

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
	table.insert(fs, table.concat({
        "scroll_container[", self.pos[1], ",", self.pos[2], ";",
        self.size[1], ",", self.size[2], ";",
        F(self.id) ,  ";", self.orientation, ";",
        self.scroll_factor, ";", self.content_padding, "]",
	}))
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    table.insert(fs, "scroll_container_end[]")
    return fs
end

---@return bform_scroll_container
---@param size table | nil
---@param id string | nil
---@param is_horizontal boolean | nil
---@param scroll_factor number | nil
function class.new(size, id, dir, is_horizontal, scroll_factor, content_padding)
    local ret = {
        id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
        size = size or {0, 0},
        offset = {0, 0},
        orientation = is_horizontal and "horizontal" or "vertical",
        scroll_factor = scroll_factor or 0.1,
        content_padding = content_padding or 0,
        dir = dir or {0,1},
        --
        pos = {0, 0},
        children = {},
    }
    return setmetatable(ret, {__index = class})
end

aom_bform.element.scroll_container = class
