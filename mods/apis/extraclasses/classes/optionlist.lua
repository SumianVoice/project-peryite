
---@class OptionList
local __option_list = {
	total = 0.0,
	last_index = 1,
	last_value = nil,
	random = function() return math.random() end,
	type = "OptionList",
	---Chooses a random option from the list and returns it.
	---@param self OptionList
	---@return any
	get_random = function(self)
		local r = self.random() * self.total
		for i, entry in ipairs(self) do
			r = r - entry[2]
			if r <= 0 then
				self.last_index = i
				self.last_value = entry[1]
				return self.last_value
			end
		end
	end,
	---Gets the next option in the list sequentially without randomness. Can loop indefinitely.
	---@param self any
	---@return any
	next = function(self)
		self.last_index = (self.last_index % #self) + 1
		return self[self.last_index][1]
	end,
}

local __meta_option_list = {
	__index = __option_list
}

--[[
	
	-- Gives a table which allows you to get a random `this:get_random()`.
	ExtraClasses.OptionList({
		-- index 1: option to return
		-- index 2: proportion of the probability
		{option_one, 4}, --> 4/5 chance
		{option_two, 1} --> 1/5 chance
	}, function() return math.random() end)

	-- Methods:
	return this:get_random() --> give a random option
	return this:next() --> give next sequential option from the last WITHOUT randomness
--]]
---@param t table
---@param rng function|nil
---@return OptionList
function ExtraClasses.OptionList(t, rng)
	if t.type == "OptionList" then return t end
	t = table.copy(t)
	t.total = 0
	if rng then t.random = rng end
	for i, entry in ipairs(t) do
		t.total = t.total + (entry[2] or 0)
	end
	return setmetatable(t, __meta_option_list)
end
