--Timer--

local timer = {
	limit = 1,
	onComplete = function() end,
	timer = 0,
	active = true
}
local timers = {}
timer.__index = timer

function timer:new( finishTime, onComplete )
	local finishTime = finishTime or 1
	local onComplete = onComplete or function() end
	local self = setmetatable( timer, {limit = finishTime, onComplete = onComplete})
	self.__index = self
	table.insert( timers, self )
	return self
end

function timer:update( dt )
	if self.active then
		self.timer = self.timer + dt
		if self.timer > self.limit then
			if self.onComplete then self.onComplete() end
			self.active = false
			return true
		end
	end
end

function timer:start()
	self.active = true
end

function timer:stop()
	self.active = false
	self.timer = 0
end

function timer:pause()
	self.active = false
end

function timer:reset()
	self.active = false
	self.timer = 0
	self.active = true
end

function timer:getTime() 
	return self.timer
end

return timer