--[=[

	TIMER API
	---------
	
	t in this instance is a Timer object.
	t.intervals is a set of intervals where a user can program functions to occur at certian points.

	Create a new timer:

		local timer = require "timer"
		local a = timer.new(1)

	Create a new interval:

		local timer = require "timer"
		local a = timer.new(1)
		a:newInterval(0.5,function() error("interval!") end)

		(in this case, at 0.5 seconds after the timer "a" is started, the program will error with the reason "interval!")

]=]--



local t = {
	len = 1,
	count = 0,
	oncomplete = function() end,
	intervals = { },
	active = false,
}
t.__index = t

local public = { }
local timers = { }

function t:new( len )
	local data = {len=len}
	local self = setmetatable( data, t )
	table.insert( timers, self )
	return self
end

function t:update( dt )
	self.count = self.count + dt
	if self.intervals[self.count] then
		local ok, err = pcall(self.intervals[self.count])
		if not ok then
			error("Timer interval failure: " .. err )
		end
	end
	if self.count > self.len then
		self.active = false
		if self.oncomplete then self.oncomplete() end
	end
end

function t:newInterval(int,funct)
	self.intervals[int] = funct
end

function t:start()
	self.count = 0
	self.active = true
end

function t:stop()
	self.count = 0
	self.active = false
end

function t:pause()
	self.active = false
end

function t:resume()
	self.active = true
end

function t:delete()
	for i, v in pairs( timers ) do
		if v == self then
			timers[i] = nil
			v = nil
			self = nil
			break
		end
	end
end



--PUBLIC FUNCTIONS--

function public.new(len)
	return t:new(len)
end

function public.update( dt )
	for i, v in pairs( timers ) do
		v:update(dt)
	end
end

return public