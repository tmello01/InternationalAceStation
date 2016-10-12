timer = {
	t = 0,
	len = 1,
	oncomplete=function() end
}
timer.__index = timer

local timers = { }

function timer:new( time,oncomplete )
	local t = {t=0,len=time,oncomplete=oncomplete}
	local a = setmetatable(t,timer)
	table.insert(timers, a)
	return a
end

function timer:update( dt )
	self.t = self.t + dt
	if self.t >= self.len then
		if self.oncomplete then self.oncomplete() end
		for i, v in pairs( timers ) do
			if v == self then
				timers[i] = nil
			end
		end
		return true
	end
end

function timer:getTime()
	return self.t
end

function timer:getPercentageComplete()
	return math.abs(self.t/self.len)
end

function UPDATE_TIMERS(dt)
	for i, v in pairs( timers ) do
		if v.update then v:update( dt ) end
	end
end


return timer