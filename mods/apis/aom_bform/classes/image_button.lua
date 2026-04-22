local elemname = "bform_image_button"

---@class bform_image_button : bform_prototype
---@field label string
---@field texture string
---@field noclip boolean
---@field drawborder boolean
---@field texture_pressed string
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>;<noclip>;<drawborder>;<pressed texture name>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "image_button["..self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.size[1]..","..self.size[2]..";")
    table.insert(fs, F(self.texture) .. ";")
    table.insert(fs, F(self.id)..";"..F(self.label))
    if self.noclip ~= nil then
        table.insert(fs, ";"..tostring(self.noclip and true))
    end
    if self.drawborder ~= nil then
        table.insert(fs, ";"..tostring(self.drawborder and true))
    end
    if self.texture_pressed ~= nil then
        table.insert(fs, ";"..F(self.texture_pressed))
    end
    table.insert(fs, "]")
    return fs
end

function class:on_fields(player, formname, fields)
end

---@param size table | nil
---@param texture string | nil
---@param label string | nil
---@param id string | nil
---@param on_fields function | nil
---@return bform_image_button
function class.new(size, texture, label, id, on_fields)
    local ret = {
        id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
        offset = {0, 0},
        size = size or {1,1},
        label = label or "",
        texture = texture or "blank.png",
        noclip = false,
        drawborder = false,
        texture_pressed = nil,
        on_fields = on_fields,
        --
        pos = {0, 0},
        children = {},
        spacing = {0, 0},
    }
    return setmetatable(ret, {__index = class})
end

---@param value string
function class:set_texture_pressed(value) return self:_set_value("texture_pressed", value) end

---@param value boolean
function class:set_noclip(value) return self:_set_value("noclip", value) end

---@param value boolean
function class:set_drawborder(value) return self:_set_value("drawborder", value) end

aom_bform.element.image_button = class
