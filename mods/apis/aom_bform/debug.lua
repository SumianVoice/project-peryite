
aom_bform.get_form("player_inventory"):add_children({
    aom_bform.element.container.new({2,2}, {0,1}, "main"):add_children({
        aom_bform.element.container.new({2,2}, {1,0}, "row1"):add_children({
            aom_bform.element.image.new("white.png", {4,2}, nil, "titleimage1"),
            aom_bform.element.image.new("white.png^[multiply:#f33", {4,2}, nil, "titleimage2"),
            aom_bform.element.image.new("white.png^[multiply:#f3f", {4,2}, nil, "titleimage3"),
        }),
        aom_bform.element.list.new("current_player", "main", {10,4}, 0.2, 0.9, 0, "inventory:main"),
        aom_bform.element.list.new("current_player", "test", {2,2}, 0.2, 0.9, 0, "inventory:test"),
        aom_bform.element.listring.new("current_player", "main"),
        aom_bform.element.listring.new("current_player", "test"),
        aom_bform.element.listcolors.new("#f00", "#f00", "#f00"),
        aom_bform.element.listcolors.new("#00000010", nil, "#0ff"),
        aom_bform.element.container.new({2,2}, {1,0}, "row2"):add_children({
            aom_bform.element.image.new("white.png", {4,2}, nil, "titleimage4"),
            aom_bform.element.image.new("white.png^[multiply:#f33", {4,2}, nil, "titleimage5"),
            aom_bform.element.image.new("white.png^[multiply:#f3f", {4,2}, nil, "titleimage6"),
            aom_bform.element.field.new({4,1}, "testfield", "a field I made", "6", function(player, formname, fields)
                aom_bform.debug("element fields entered by callback", "infofields")
            end),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#f33", "pressme", "testbutton", function(player, formname, fields)
                aom_bform.debug("button press", "infofields")
                aom_bform.add_element_to_id("player_inventory", "row2",
                    aom_bform.element.image.new("white.png^[multiply:#333", {1,1})
                )
            end),
        }),
    }),
}):set_params({
    send_on_update = true,
    auth_enabled = true,
})

aom_bform.add_element_to_id("player_inventory", "titleimage3",
    aom_bform.element.image.new("white.png^[multiply:#333", {1,1}, "somenewimage")
)

minetest.register_on_joinplayer(function(player, last_login)
    local inv = player:get_inventory()
    -- DEBUG
    inv:set_size("test", math.max(4, inv:get_size("test")))
    inv:set_size("main", math.max(40, inv:get_size("main")))
end)

local inv = aom_bform.get_form("player_inventory")
if not inv then return end


-- test that children get their parent correctly no matter how they are added
local tmp = aom_bform.element.image.new("white.png^[multiply:#a3f", {1,1}, nil, "tmp4")

local cont = aom_bform.element.image.new("white.png^[multiply:#f82", {1,1}, nil, "tmp1"):add_children({
    aom_bform.element.image.new("white.png^[multiply:#29f", {1,1}, nil, "tmp2"):add_children({
        aom_bform.element.image.new("white.png^[multiply:#8f2", {1,1}, nil, "tmp3"),
        tmp
    })
})

inv:get_element_by_id("inventory:main"):add_child(cont)

aom_bform.debug("got root " .. (tmp:get_root().id or "no id"))


-- PREPEND
local col = "#a69a8e"
aom_bform.get_form("global_prepend"):add_children({
    -- remove the ugly square box menu bg
    aom_bform.element.custom.new(nil, "bgcolor", {
        "bgcolor[#00000000;neither]",
    }),
    -- style the buttons in the menu
    aom_bform.element.custom.new(nil, "buttonstyle", {
        "style_type[button;bgimg=bform_btn.png\\^\\[multiply:"..col..";bgimg_middle=8;",
        "bgimg_hovered=bform_btn.png\\^\\[multiply:"..col..";bgimg_pressed=bform_btn_press.png\\^\\[multiply:"..col..";",
        "bgcolor_hovered=#eee;bgcolor_pressed=#fff]",
        "style_type[button;border=false]",
    }),
    -- add 9 patch bg
    aom_bform.element.background9.new(nil, "bform_bg.png^[multiply:#113^bform_bg_outline.png", nil, true, 28),
    -- you can't use `label[]` in prepends, because minetest says no
    aom_bform.element.custom.new(nil, "version_notice", {
        "hypertext[0.4,5.2;6,1;test;<style color=#f67>",
        "My Game v69",
        "</style>",
        "]",
    }),
})



aom_bform.register_form("my_form", aom_bform.element.form:new(nil, 6, "my_form"))

aom_bform.get_form("my_form"):add_children({
    aom_bform.element.container.new({2,2}, {0,1}, "main"):add_children({
        aom_bform.element.listcolors.new("#00000000", "#00000000", "#00000000", "#00000000", "#00000000"),

        aom_bform.element.container.new({2,2}, {0,1}, "gearlike"):add_children({
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "A", "test_A", function(player, formname, fields)
                aom_bform.debug("Button press A", "infofields")
            end),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "B", "test_B", function(player, formname, fields)
                aom_bform.debug("Button press B; note that any button can be wired like this, even after being created", "infofields")
                aom_bform.debug("You also don't need to set an id; if left out, a hash will be used instead", "infofields")
            end),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "C", "test_C"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "D", "test_D"),
        }):set_absolute_pos({10, 4}),


        aom_bform.element.container.new({2,2}, {1,0}, "invlike"):add_children({
            aom_bform.element.container.new({2,2}, {0,1}, "invlike_row1"):add_children({
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "A"),
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "B"),
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "C"),
            }),
            aom_bform.element.container.new({2,2}, {0,1}, "invlike_row2"):add_children({
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "A"),
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "B"),
                aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "C"),
            }),
        }):set_absolute_pos({12, 4}),
    }):set_offset{0,1},
}):set_params({
    -- if set, fields will be ignored unless a hash is contained in the form
    -- prevents impersonation attacks, enabled by default, just showing here
    auth_enabled = true,
})

local cluster1 = (
    aom_bform.element.container.new({2,2}, {0,1}, "clust1"):add_children({
        aom_bform.element.background9.new({1,1}, "bform_bg.png^[multiply:#445^bform_bg_outline.png^[opacity:100", nil, false, 28):set_fill({0.4, 0.4}),
        aom_bform.element.container.new({2,2}, {1,0}, "clust1r1"):add_children({
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "A"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "B"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#478", "C"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#622", "D"),
        }):set_expand(true):set_space_evenly(true),
        aom_bform.element.container.new({2,2}, {1,0}, "clust1r2"):add_children({
            aom_bform.element.image_button.new({2,2}, "white.png^[multiply:#656", "special", "SPECIAL"):set_offset({0,0}),
        }):set_expand(true):set_space_evenly(true),
    }):set_size({6,4.5}):set_absolute_pos({5, 2}):set_space_evenly(true)
)
-- add it to form
aom_bform.add_element_to_id("my_form", "main", cluster1)


local yspace = 0.4
local rowspace = 0.8
local cluster2 = (
    aom_bform.element.container.new({2,2}, {1,0}, "clust2"):add_children({
        aom_bform.element.background9.new({1,1}, "bform_bg.png^[multiply:#776^bform_bg_outline.png^[opacity:100", nil, false, 28):set_fill({0.0, 0.0}),
        aom_bform.element.container.new({2,2}, {0,1}, "clust2c1"):add_children({
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#2e4", "A"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#622", "B"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "C end"),
        }):set_space_evenly(true):set_expand(true),
        aom_bform.element.container.new({2,2}, {0,1}, "clust2c2"):add_children({
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "A"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "B end"),
        }):set_space_evenly(true):set_expand(true),
        aom_bform.element.container.new({2,2}, {0,1}, "clust2c3"):add_children({
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "A"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "B"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "C"),
            aom_bform.element.image_button.new({1,1}, "white.png^[multiply:#889", "D end"),
        }):set_space_evenly(true):set_expand(true),
    }):set_absolute_pos({14.5, 0.5}):set_space_evenly(true):set_size({4, 5}):set_padding({0.4,0.4})
)

aom_bform.add_element_to_id("my_form", "main", cluster2)


minetest.register_on_joinplayer(function(player, last_login)
    -- aom_bform.show_form("my_form", player)
end)




aom_bform.element.container.new({2,2}, {1,0}, "row1"):add_children({
    aom_bform.element.image.new("white.png", {4,2}, nil, "titleimage4"),
})

local e = aom_bform.element

aom_bform.register_form("test_flow", aom_bform.element.form:new(nil, 6, "test_flow"))

aom_bform.get_form("test_flow"):add_children({
    e.container.new({2,2}, {1,0}, "main"):add_children({
        e.container.new({2,2}, {1,0}, "c1"):add_children({
            e.image_button.new({1,1}, "white.png^[multiply:#644", "A"),
            e.image_button.new({3,2}, "white.png^[multiply:#644", "A"),
            e.image_button.new({2,1}, "white.png^[multiply:#644", "A"),
        }):set_expand(true),
        e.container.new({2,2}, {0,1}, "c2"):add_children({
            e.image_button.new({1,1}, "white.png^[multiply:#889", "A"),
            e.image_button.new({3,2}, "white.png^[multiply:#889", "A"),
            e.image_button.new({2,1}, "white.png^[multiply:#889", "delme", "delme", function(self, player, formname, fields)
                aom_bform.prototype.remove_child(self.parent, self)
            end),
            e.image_button.new({2,1}, "white.png^[multiply:#889", "delme2", "delme2", function(self, player, formname, fields)
                self:add_child(e.image_button.new({3,2}, "white.png^[multiply:#889", "delme", "delme"))
            end),
        }),
    }):set_size({5,5}),
}):set_params({
    send_on_update = true
})

minetest.register_on_joinplayer(function(player, last_login)
    -- aom_bform.show_form("test_flow", player)
end)

