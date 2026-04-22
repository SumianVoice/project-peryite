local elemname = "bform_label"

---@class bform_label : bform_prototype
---@field text string
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- label[<X>,<Y>;<label>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, table.concat({
        "label[", self.pos[1], ",", self.pos[2], ";", F(self.text or ""), "]"
    }))
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    return fs
end

---@param size table | nil
---@param text string | nil
---@param offset table | nil
---@param id string | nil
---@return bform_label
function class.new(size, text, offset, id)
    local ret = {
        id = id,
        size = size or {0, 0},
        text = text or "",
        offset = offset or {0, 0},
        --
        dir = {0,1},
        pos = {0, 0},
        children = {},
    }
    return setmetatable(ret, {__index = class})
end

aom_bform.element.label = class
