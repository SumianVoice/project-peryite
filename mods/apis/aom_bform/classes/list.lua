local elemname = "bform_list"

---@class bform_list : bform_prototype
---@field inventory string
---@field listname string
---@field invsize table
---@field slotspacing number
---@field slotsize number
---@field startindex number
local class = setmetatable({}, {__index = aom_bform.prototype})
class.type = elemname

-- list[<inventory location>;<list name>;<X>,<Y>;<W>,<H>;<starting item index>]

local F = core.formspec_escape

---@return table
function class:render(fs, data, ...)
    table.insert(fs, "style_type[list;spacing="..(self.slotspacing or 0)..";size="..(self.slotsize or 0.9).."]")
    table.insert(fs, "list["..F(self.inventory)..";"..F(self.listname)..";")
    table.insert(fs, self.pos[1]..","..self.pos[2]..";")
    table.insert(fs, self.invsize[1]..","..self.invsize[2]..";")
    table.insert(fs, (self.startindex or 1) .. "]")
    table.insert(fs, "container["..self.pos[1]..","..self.pos[2].."]")
    return fs
end

---@return table
function class:render_after(fs, data, ...)
    table.insert(fs, "container_end[]")
    return fs
end

---@return bform_list
---@param inventory string
---@param listname string
---@param invsize table
---@param slotspacing number | nil
---@param slotsize number | nil
---@param startindex number | nil
---@param id string | nil
function class.new(inventory, listname, invsize, slotspacing, slotsize, startindex, id)
    local ret = {
        id = id,
        inventory = inventory,
        listname = listname,
        offset = {0, 0},
        size = {
            invsize[1] * (1 + slotspacing),
            invsize[2] * (1 + slotspacing),
        },
        invsize = invsize,
        startindex = startindex,
        slotspacing = slotspacing,
        slotsize = slotsize,
        --
        pos = {0, 0},
        children = {},
    }
    return setmetatable(ret, {__index = class})
end

aom_bform.element.list = class
