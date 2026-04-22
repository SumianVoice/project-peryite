
---Returns a PcgRandom wrapped in a function which returns 0.0 < n < 1.0
---@param seed any
---@return function
function ExtraClasses.get_rng(seed)
	local rand = PcgRandom(core.get_mapgen_setting("seed"), seed)
	return function()
		return ((rand:next() / 2147483647 + 1) / 0.5) % 1
	end
end
