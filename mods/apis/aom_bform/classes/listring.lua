local elemname = "bform_listring"

---@class bform_listring : bform_prototype
---@field inventory string
---@field invlist string
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- listring[<inventory location>;<list name>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "listring["..F(self.inventory)..";"..F(self.invlist).."]")
    return fs
end

---@param inventory string
---@param invlist string | nil
---@param id string | nil
---@return bform_listring
function class.new(inventory, invlist, id)
    local ret = {
        id = id,
        inventory = inventory or "",
        invlist = invlist or "main",
        --
        children = {},
    }
    return setmetatable(ret, {__index = class})
end

aom_bform.element.listring = class
