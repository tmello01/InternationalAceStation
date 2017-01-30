if not timer then
	timer = require "timer"
end

--[=[

	TOUCH API
	---------

	t in this instance is a Touch object.
	**No users should have to manually create touches; they should be handled in love.touch functions**



	**touches** is a container for all active touch objects.

]=]--

local t = {
	id = 0,
	x = 0,
	y = 0,
}
t.__index = t
local touches = { }
local public = { }

function t:new( id, x, y )
	local data = {id=id,x=x,y=y}
	local self = setmetatable(data,t)
	
	for i, v in pairs( Game.Objects ) do
		for k, z in pairs( v ) do
			if x >= z.x and x <= z.x + z.w and y >= z.y and y <= z.y + z.h then
				touchmanager.start( z, id )
			end
		end
	end
	table.insert( touches, self )
	return self
end

function t:update( dt )

end

function t:updatePosition( x, y )
	if self.x ~= x or self.y ~= y then
		if touchmanager.hasId( self.id ) then
			touchmanager.drag( self.id )
		end
	end
	self.x = x or self.x
	self.y = y or self.y
end

function t:remove()
	for i, v in pairs( touches ) do
		if v == self then
			touchmanager.remove( self.id )
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

function public.updatePosition(id,x,y)
	for i, v in pairs( touches ) do
		if v.id == id then
			v:updatePosition(x,y)
			--print( x, y )
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

function public.hasTouch(id)
	for i, v in pairs( touches ) do
		if v.id == id then
			return true
		end
	end
	return false
end

return public