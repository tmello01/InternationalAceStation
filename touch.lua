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
	pastDeadzone = false,
}
t.__index = t
local touches = { }
local public = { }

local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function t:new( id, x, y )
	local data = {id=id,x=x,y=y}
	local self = setmetatable(data,t)
	self.pastDeadzone = false
	table.insert( touches, self )
	for i, v in pairs( ReverseTable(Game.Objects) ) do
		if x >= v.x and x <= v.x + (v.w*2) and y >= v.y and y <= v.y + (v.h*2) then
			v:startTouch(id,x,y)
			break
		end
	end
	return self
end

function t:update( dt )

end

function t:updatePosition( x, y )
	if x ~= self.x or y ~= self.y then
		local deadzone = 10 * (love.graphics.getWidth()/800)
		if not self.pastDeadzone then
			self.pastDeadzone = math.abs(x-self.x) > deadzone or math.abs(y-self.y) > deadzone
		else	
			self.x = x or self.x
			self.y = y or self.y
			
			
			for i, v in pairs( Game.Objects ) do
				if v.currentTouchID == self.id then
					v:drag( x, y )
				end
			end
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
	for i, t in pairs( touches ) do
		if t.id == id then
			for i, v in pairs( Game.Objects ) do
				if v.currentTouchID == t.id then
					v:endTouch( t.id )
				end
			end
			table.remove( touches, i )
			break
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