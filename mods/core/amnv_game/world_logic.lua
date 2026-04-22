
amnv_game.ores = {}
amnv_game.ore_list = {
	{
		name = "metal",
		color = {
			h=160, s=-90, l=40,
			main 		= "#d4d0cf",
			substrate 	= "#c6c5cc",
		},
	},
	{
		name = "octate",
		color = {
			h=140, s=-100, l=-30,
			main 		= "#7d6e87",
			substrate 	= "#997e7f",
		},
	},
	{
		name = "annite",
		color = {
			h=-90, s=0, l=0,
			main 		= "#58cf69",
			substrate 	= "#c5ccca",
		},
	},
	{
		name = "peryite",
		color = {
			h=180, s=80, l=20,
			main 		= "#51beff",
			substrate 	= "#d8b39d",
		},
	},
}
for i, oredef in ipairs(amnv_game.ore_list) do
	amnv_game.ores[oredef.name] = oredef
	oredef.color.main_rgb = core.colorspec_to_table(oredef.color.main)
	oredef.color.substrate_rgb = core.colorspec_to_table(oredef.color.substrate)
end
