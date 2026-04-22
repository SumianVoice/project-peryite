local decors_by_layer = {}
local core_regdecor = core.register_decoration
--[[ Layer number guide:
 1-9  = large terrain modifying passes, base layers and really important first passes
    (force_placement, 5 = boulders)
10-19 = terrain modifying passes (pools/lakes)
    (force_placement, 15 = pools, 10 = mesa and cliffs and chasms, 16 = boulders)
20-29 = things that might prevent or get in the way of trees and other passes
    (25 = houses)
30-39 = trees and other "delicate" things that need to connect to the ground reliably
    (tallest first, 35 = medium oak, 30 = giant redwood, 39 = bushes)
40-49 = anything else completely unimportant, small details etc
    (important first, 45 = tall grasses, 49 = tiny specks of detail)
--]]
rawset(core, "register_decoration", function(def)
    if not def._layer then return core_regdecor(def) end
    local diff = def._layer - #decors_by_layer
    if diff > 0 then
        for i = 0, diff do
            table.insert(decors_by_layer, {})
        end
    end
    local decor_list = decors_by_layer[def._layer]
    table.insert(decor_list, def)
end)

core.register_on_mods_loaded(function()
    for layer_num, decor_list in pairs(decors_by_layer) do
        for i, decor_def in ipairs(decor_list) do
            core_regdecor(decor_def)
        end
    end
    decors_by_layer = nil
end)
