
---Signal class metatable. Non-functional on its own, use `Signal.new()`.
---Contains signal, conditional and listen functions.
---@class Signal
---@field callbacks table
local Signal = {}
function Signal.check_remove(source, removelist)
	for i = #removelist, 1, -1 do
		table.remove(source, removelist[i])
	end
end
---Add a callback to this event.
---@param func function
---@param i number | nil -- index to insert at (nil for 'front')
function Signal:listen(func, i)
	assert(type(func) == "function", "Signal:listen(func)" ..
	"--> `func` must be of type `function`. Got instead: " .. tostring(func))
	if i then
		table.insert(self.callbacks, i, func)
	else
		table.insert(self.callbacks, func)
	end
end
---`false` and abort if any ==false, `true` if one or more ==true, else `nil`
function Signal:conditional(...)
	local had_true
	local removals = {}
	for i, callback in ipairs(self.callbacks) do
		local val, removal = callback(...)
		if removal == true then
			table.insert(removals, i)
		end
		if val == true then
			had_true = true
		elseif val == false then
			had_true = false
			break
		end
	end
	Signal.check_remove(self.callbacks, removals)
	return had_true
end
---Send a signal to all callbacks.
function Signal:signal(...)
	local removals = {}
	for i, callback in ipairs(self.callbacks) do
		local val, removal = callback(...)
		if removal == true then
			table.insert(removals, i)
		end
	end
	Signal.check_remove(self.callbacks, removals)
end

Signal.__index = function(self, k) return rawget(self, k) or rawget(Signal, k) end
Signal.__newindex = function(...) end
Signal.__call = function(self, ...)
	return self.signal(...)
end

---Create a self contained signal. Has signal, conditional and listen metamethods.
---@param host table | nil
---@return Signal
function Signal.new(host)
	if not host then host = {} end
	host.callbacks = {}
	return setmetatable(host, Signal)
end




---SignalBus class metatable. Manages signals, but does not call any callbacks directly.
---@class SignalBus
local SignalBus = {}
---@param tag string
---@param func function
function SignalBus:listen(tag, func)
	return self[tag]:listen(func)
end
---@param tag string
function SignalBus:conditional(tag, ...)
	return self[tag]:conditional(...)
end
---@param tag string
function SignalBus:signal(tag, ...)
	return self[tag]:signal(...)
end

---@param self table
---@param k string | any
---@return Signal | any
function SignalBus.__index(self, k)
	local val = rawget(self, k)
	if val then return val end
	val = SignalBus[k]
	if val then return val end
	local signals = rawget(self, "signals")
	-- make up a signal
	val = rawget(signals, k)
	if not val then
		val = Signal.new()
		rawset(signals, k, val)
	end
	return val
end
function SignalBus.__newindex(self, k, v)
	local signals = rawget(self, "signals")
	if not signals[k] then signals[k] = Signal.new() end
end
function SignalBus.__call(self, ...)
	return self:signal(...)
end

SignalBus.Signal = Signal
SignalBus.SignalBus = SignalBus

---Creates a signal bus, which manages signals.
---Mostly just a wrapper that allows for indexing.
---Allows you to not have to hard depend on things and keep signals pure.
---@param host table | nil
---@return SignalBus
function SignalBus.new(host)
	if not host then host = {} end
	host.signals = {}
	host.listen = SignalBus.listen
	host.signal = SignalBus.signal
	host.conditional = SignalBus.conditional
	return setmetatable(host, SignalBus)
end





local _signalbus = SignalBus.new()

---Sends a signal of a certain name.
---`SIGNAL` is both this function and a table, because it has __call in its metamethods.
---@param signal_name string
---@param ... any
SIGNAL = function(signal_name, ...)
	return _signalbus:signal(signal_name, ...)
end

---Global event bus for general use.
---You may set e.g. `function SIGNAL.on_some_event_happened:signal(param1, param2) end` to give code hints.
---This will not overwrite anything, but your code editor will pick up on what kind of parameters are expected.
---Indexing with anything other than an existing field will create that Signal.
---For example, doing `SIGNAL.my_event_name` will result in `SIGNAL.signals.my_event_name` being created and returned.
---This means all indexes 'exist' as Signals by the time you reference them, so you never have to check nil.
--[[

	-- Example Use Cases
	-- Normal use
	LISTEN("on_my_event", function(...) return true end)
	SIGNAL("on_my_event", ...)
	if CONDITIONAL("on_my_event", ...) then do_something() end
	-- Make hints for easier editing
	function SIGNAL.on_my_event:signal(player, position, damage) end
	-- Make your own local event bus (why tho)
	local my_local_event_bus = SIGNAL.SignalBus.new()
	my_local_event_bus:signal("on_my_event", player, position, damage)
	-- Make your own single signal instance
	local on_my_event = SIGNAL.Signal.new()
	on_my_event:listen(function(a, b, ...) end)
	on_my_event:signal(1, 2, ...)
	-- For hints again:
	---@param a table
	---@param b number
	function on_my_event:signal(a, b) end -- does nothing but does provide hints
]]
SIGNAL = _signalbus

---Causes this function to be called when SIGNAL or CONDITIONAL is called with this `signal_name`.
---If CONDITIONAL, it should return boolean or nil.
---To remove this callback, it should return `any, true`
---@param func function
LISTEN = function(signal_name, func)
	return SIGNAL:listen(signal_name, func)
end

---`false` and abort if any ==false, `true` if one or more ==true, else `nil`
---@param signal_name string
---@param ... any
---@return boolean | nil
CONDITIONAL = function(signal_name, ...)
	return SIGNAL:conditional(signal_name, ...)
end
