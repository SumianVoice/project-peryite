local elemname = "bform_textarea"

---@class bform_textarea : bform_prototype
---@field content string
---@field label string
---@field close_on_enter boolean
---@field is_read_only boolean
---@field ignore_not_on_enter boolean
local class = setmetatable({}, {__index = aom_bform.prototype})

-- textarea[<X>,<Y>;<W>,<H>;<name>;<label>;<default>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "textarea["..self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.size[1]..","..self.size[2]..";")
    table.insert(fs, (self.is_read_only and "" or F(self.id))..";")
    table.insert(fs, F(self.label)..";"..F(self.content).."]")
    if (not self.is_read_only) and self.close_on_enter ~= true then
        table.insert(fs, "field_close_on_enter["..self.id..";false]")
    end
    table.insert(fs, "container["..self.pos[1]..","..self.pos[2].."]")
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    table.insert(fs, "container_end[]")
    return fs
end

function class:on_fields(player, formname, fields)
    aom_bform.debug("an on_fields call")
end

---@return bform_textarea
---@param size table | nil
---@param id string | nil
---@param label string | nil
---@param default_content string | nil
---@param is_read_only boolean | nil
---@param on_fields function | nil
function class.new(size, id, label, default_content, is_read_only, on_fields)
    local ret = {
        id = id or string.sub(minetest.sha1(tostring({})), 1, 8),
        size = size or {0, 0},
        offset = {0, 0},
        label = label or "",
        content = default_content or "",
        on_fields = on_fields or nil,
        is_read_only = is_read_only == true,
        close_on_enter = false,
        ignore_not_on_enter = true, -- minetest will still send the fields, we will just ignore them
        --
        pos = {0, 0},
        children = {},
        type = elemname,
    }
    return setmetatable(ret, {__index = class})
end

-- Whether to close the formspec when you press enter on this.
---@param value boolean
function class:set_close_on_enter(value) return self:_set_value("close_on_enter", value) end
-- Formspec fields will still be sent over the network, but if this is set, it will then ignore those fields unless it's on enter for this field.
---@param value boolean
function class:set_close_ignore_not_on_enter(value) return self:_set_value("close_ignore_not_on_enter", value) end

aom_bform.element.textarea = class
