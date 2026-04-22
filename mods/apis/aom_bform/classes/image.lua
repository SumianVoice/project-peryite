local elemname = "bform_image"

---@class bform_image : bform_prototype
---@field texture string
---@field middle string
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- image[<X>,<Y>;<W>,<H>;<texture name>;<middle>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "image["..self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.size[1]..","..self.size[2]..";")
    table.insert(fs, F(self.texture))
    if self.middle then
        table.insert(fs, ";"..F(self.middle))
    end
    table.insert(fs, "]")
    table.insert(fs, "container["..self.pos[1]..","..self.pos[2].."]")
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    table.insert(fs, "container_end[]")
    return fs
end

---@param size table | nil
---@param texture string | nil
---@param id string | nil
---@param middle string | number | nil
---@return bform_image
function class.new(size, texture, id, middle)
    local ret = {
        id = id,
        size = size or {0, 0},
        offset = {0, 0},
        texture = texture or "blank.png",
        middle = middle,
        dir = {0,1},
        --
        pos = {0, 0},
        children = {},
    }
    return setmetatable(ret, {__index = class})
end

aom_bform.element.image = class
