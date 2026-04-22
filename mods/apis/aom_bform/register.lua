
---@return bform
function aom_bform.register_form(name, form)
    aom_bform.forms[name] = form
    return form
end

---@return bform | nil | bform_prepend
function aom_bform.get_form(name)
    return aom_bform.forms[name]
end

---@return string
function aom_bform.get_formspec(name, player, forceupdate)
    return aom_bform.forms[name] and aom_bform.forms[name]:get_form(player, forceupdate)
end

---@return bform | bform_prototype | nil
function aom_bform.add_element_to_id(name, id, element)
    local form = aom_bform.forms[name]
    if not form then return end
    local host = aom_bform.prototype.get_element_by_id(form, id)
    if not host then return end
    return aom_bform.prototype.add_child(host, element)
end

---@return self | nil
function aom_bform.show_form(name, player, ...)
    ---@type bform
    local form = aom_bform.forms[name]
    if not form then return end
    return form:show_form(player, ...)
end
