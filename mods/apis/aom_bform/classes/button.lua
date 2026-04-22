local elemname = "button"

---@class bform_button : bform_prototype
---@field label string
---@field on_fields function
---@field close_on_enter boolean
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- button[<X>,<Y>;<W>,<H>;<name>;<label>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    local buttontype = (self.close_on_enter and "button_exit[" or "button[")
    table.insert(fs, buttontype..self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.size[1]..","..self.size[2]..";")
    table.insert(fs, F(self.id)..";"..F(self.label).."]")
    return fs
end

function class:on_fields(player, formname, fields)
end

---@param size table | nil
---@param label string | nil
---@param id string | nil
---@param on_fields function | nil
---@return bform_button
function class.new(size, label, id, on_fields)
    local ret = {
        id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
        offset = {0, 0},
        size = size or {1, 1},
        label = label or "",
        on_fields = on_fields,
        --
        pos = {0, 0},
        children = {},
        spacing = {0, 0},
        close_on_enter = false,
    }
    return setmetatable(ret, {__index = class})
end

-- Whether to close the formspec when you press enter on this.
---@param value boolean
function class:set_close_on_enter(value) return self:_set_value("close_on_enter", value) end

aom_bform.element.button = class
