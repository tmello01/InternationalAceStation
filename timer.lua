--Timer--

local timer = {
	limit = 0.5,
	onComplete = function() end,
	timer = 0,
	active = true
}
timer.__index = timer
local timers = {}

function timer:new( finishTime, onComplete )
	local limit = finishTime or 0.5
	local onComplete = onComplete or function() end
	local data = {
		limit = limit,
		onComplete = onComplete
	}
	local self = setmetatable( timer, data )
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
	return false
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

function timer:restart()
	self.active = false
	self.timer = 0
	self.active = true
end

function timer:getTime() 
	return self.timer
end

return timer