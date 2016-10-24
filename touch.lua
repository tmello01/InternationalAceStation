if not timer then
	timer = require "timer"
end

--[=[

	TOUCH API
	---------

	t in this instance is a Touch object.
	**No users should have to manually create touches; they should be handled in love.touch functions**



	touches is a container for all active touch objects.

]=]--

local t = {
	id = 0,
	x = 0,
	y = 0,
	timer = timer:new(1.5),
}
t.__index = t
local touches = { }
local public = { }

function t:new( id, x, y )
	local data = {id=id,x=x,y=y}
	local self = setmetatable(data,t)
	self.timer.oncomplete = function()

	end
	table.insert( touches, self )
	return self
end

function t:update( dt )

end

function t:updatePosition( x, y )
	self.x = x or self.x
	self.y = y or self.y
end

function t:remove()
	for i, v in pairs( touches ) do
		if v == self then
			touches[i] = nil
			v = nil
			self = nil
			break
		end
	end
end



--PUBLIC FUNCTIONS--

function public.new(id,x,y)
	return t:new(id,x,y)
end

function public.updatePositions(id,x,y)
	for i, v in pairs( touches ) do
		if v.id == id then
			v:updatePosition(x,y)
		end
	end
end

function public.remove(id,x,y)
	for i, v in pairs( touches ) do
		if v.id == id then
			v:remove()
		end
	end
end

return public