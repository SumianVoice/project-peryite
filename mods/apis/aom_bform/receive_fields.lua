
aom_bform.shown = {}

function aom_bform.on_auth_failed(player, formname, fields)
end

---comment
---@param form bform
---@param player table
---@param fields table
---@return boolean
local function has_probably_quit_form(form, player, fields)
    if fields.quit then
        return true
    end
    local field = fields.key_enter_field
    local elem = form:get_element_by_id(field)
    if elem and elem['close_on_enter'] then
        return true
    end
    for fieldname, v in pairs(fields) do
        elem = form:get_element_by_id(fieldname)
        if elem and elem['close_on_enter'] then
            return true
        end
    end
    return false
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local fname = formname
    ---@type bform | nil
    local form
    if fname == "" then
        form = aom_bform.get_inventory_form_or_nil(player)
        if form then
            form['is_used_as_fake_inventory'] = false
        end
        fname = "player_inventory"
    elseif fname == "fakeinv" then
        form = aom_bform.get_inventory_form_or_nil(player)
        if form then
            form['is_used_as_fake_inventory'] = true
        end
    end
    if not form then form = aom_bform.shown[fname] end
    if not form then form = aom_bform.forms[fname] end
    if not form then
        aom_bform.debug(minetest.colorize("#fea", "there is no form with name " .. formname), "auth")
        return end

    local pi = form.pl[player]
    if pi then pi.is_active = false end

    local pli = form.pl and form.pl[player] or {}
    aom_bform.debug(minetest.colorize("#fea", "EXPECTING HASH: ") .. (pli.last_hash or "nil"), "auth")
    aom_bform.debug(minetest.colorize("#fea", "BUT IT IS: ") .. (fields[pli.last_hash or "nil"] or "nil"), "auth")
    for n, v in pairs(fields) do
        aom_bform.debug(minetest.colorize("#fea", " ") .. (n), "auth")
    end

    if not form.auth_enabled then
        aom_bform.debug(minetest.colorize("#2a6", "Auth is DISABLED, allowing fields sent"), "auth")
    elseif form:is_auth(player, fields) then
        aom_bform.debug(minetest.colorize("#2f6", "HAS auth, allowing fields sent"), "auth")
    elseif (not fields.quit) and (not fields.key_enter) then
        aom_bform.debug(minetest.colorize("#f34", "DOES NOT have auth"), "auth")
        aom_bform.on_auth_failed(player, formname, fields)
        return
    else
        aom_bform.debug(minetest.colorize("#fd2", "DOES NOT have auth") .. ", but is from inventory formspec or closing form", "auth")
        return
    end

    -- hacky solution to show faked inventory forms again when updated
    if has_probably_quit_form(form, player, fields) then
        form:on_form_closed(player)
    elseif pi then
        pi.is_active = true
    end

    aom_bform.prototype._propagate_event(form, player, fname, fields)
end)
