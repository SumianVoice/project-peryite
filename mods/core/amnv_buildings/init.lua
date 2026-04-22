---@diagnostic disable: undefined-doc-name
local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_buildings = {}

dofile(mod_path .. "/register.lua")
