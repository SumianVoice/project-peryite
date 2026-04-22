local elemname = "bform_item_image_button"

---@class bform_item_image_button : bform_prototype
---@field label string
---@field itemstring string
---@field noclip boolean
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- item_image_button[<X>,<Y>;<W>,<H>;<item name>;<name>;<label>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "item_image_button["..self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.size[1]..","..self.size[2]..";")
    table.insert(fs, F(self.itemstring) .. ";")
    table.insert(fs, F(self.id)..";"..F(self.label))
    table.insert(fs, "]")
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    return fs
end

function class:on_fields(player, formname, fields)
end

---@param itemstring string
---@param size table
---@param label string | nil
---@param id string | nil
---@param on_fields function | nil
---@return bform_item_image_button
function class.new(itemstring, size, label, id, on_fields)
    local ret = {
        id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
        offset = {0, 0},
        size = size or {1,1},
        label = label or "",
        itemstring = itemstring or "",
        noclip = false,
        drawborder = false,
        on_fields = on_fields,
        --
        pos = {0, 0},
        children = {},
        spacing = {0, 0},
    }
    return setmetatable(ret, {__index = class})
end

---@param value boolean
function class:set_noclip(value) return self:_set_value("noclip", value) end

---@param value string
function class:set_itemstring(value) return self:_set_value("itemstring", value) end

---@param value boolean
function class:set_drawborder(value) return self:_set_value("drawborder", value) end

aom_bform.element.item_image_button = class
