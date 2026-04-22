local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

_G.aom_bform = {}
aom_bform.element = {}
aom_bform.forms = {}
aom_bform.pl = {}
aom_bform.types = {}

function aom_bform.check_player(player)
    local pi = aom_bform.pl[player]
    if not pi then
        pi = {
            last_form = nil,
            ---@type bform
            inventory_form = nil,
        }
        aom_bform.pl[player] = pi
    end
    return pi
end


local allow_debug = false
local debug_tags = {
    -- all         = true,
    -- infoevent   = true,
    -- infofields  = true,
    changes     = true,
    auth        = true,
    run_debug   = true,
}
function aom_bform.debug(text, tag)
    if not allow_debug then return end
    if not debug_tags[tag or "all"] then return end
    minetest.log(text)
end

-- systems
dofile(mod_path .. "/register.lua")
dofile(mod_path .. "/prototype.lua")
dofile(mod_path .. "/receive_fields.lua")

-- classes
dofile(mod_path .. "/classes/form.lua")
dofile(mod_path .. "/classes/container.lua")
dofile(mod_path .. "/classes/image.lua")
dofile(mod_path .. "/classes/field.lua")
dofile(mod_path .. "/classes/label.lua")
dofile(mod_path .. "/classes/list.lua")
dofile(mod_path .. "/classes/style_type.lua")
dofile(mod_path .. "/classes/button.lua")
dofile(mod_path .. "/classes/image_button.lua")
dofile(mod_path .. "/classes/item_image_button.lua")
dofile(mod_path .. "/classes/item_image.lua")
dofile(mod_path .. "/classes/listring.lua")
dofile(mod_path .. "/classes/listcolors.lua")
dofile(mod_path .. "/classes/background9.lua")
dofile(mod_path .. "/classes/spacer.lua")
dofile(mod_path .. "/classes/scroll_container.lua")
dofile(mod_path .. "/classes/scrollbar.lua")
dofile(mod_path .. "/classes/custom.lua")
dofile(mod_path .. "/classes/textarea.lua")
dofile(mod_path .. "/classes/prepend.lua")

dofile(mod_path .. "/builtin.lua")

-- for dev
if allow_debug and debug_tags.run_debug then
    dofile(mod_path .. "/debug.lua")
end
