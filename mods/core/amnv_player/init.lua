local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)
local S = core.get_translator(mod_name)

amnv_player = {}

core.register_on_joinplayer(function(player, last_login)
    player:set_armor_groups({
        fall_damage_add_percent = -100,
        fleshy = 100,
    })
    player:set_properties({
        stepheight = 1.9,
        eye_height = 2.7
    })
    playerphysics.remove_all_physics_factors(player)

    player:set_sky({
        type = "regular",
        clouds = false,
        sky_color = {
            -- day_sky = "#61b5f5",
            -- day_horizon = "#90d3f6",
            -- dawn_sky = "#b4bafa",
            -- dawn_horizon = "#bac1f0",
            -- night_sky = "#006bff",
            -- night_horizon = "#4090ff",
            -- indoors = "#646464",
            -- fog_sun_tint = "#f47d1d",
            -- fog_moon_tint = "#7f99cc",
            day_sky = "#006adf",
            day_horizon = "#b1a18e",
            dawn_sky = "#b4bafa",
            dawn_horizon = "#bac1f0",
            night_sky = "#006bff",
            night_horizon = "#4090ff",
            indoors = "#646464",
            fog_sun_tint = "#f47d1d",
            fog_moon_tint = "#7f99cc",
        },
        fog = {
            fog_start = 0.7,
            -- fog_color = "#74888e"
        }
    })
end)

core.register_globalstep(function(dtime) for i, player in ipairs(core.get_connected_players()) do
    local dir = player:get_look_dir()
    dir.y = 0
	dir = vector.normalize(dir)
    local old_vel = player:get_velocity()
    local old_y = old_vel.y
    old_vel.y = 0
    local speed = vector.length(old_vel) + ((math.abs(old_y) > 0.01) and 6 or 0)
    local new_vel = dir * speed
    local dot = vector.dot(
        vector.normalize(new_vel),
        vector.normalize(old_vel)
    )
    local factor = math.max(0, math.min(1, dot + 0.5))
    player:add_velocity(
        (new_vel - old_vel) * dtime * factor
    )
end end)
