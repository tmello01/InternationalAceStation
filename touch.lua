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
	startx = 0,
	starty = 0,
	selecing = false,
	canselect = false
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

local function isOnObject(id,x,y)
	for i, v in pairs( ReverseTable(Game.Objects) ) do
		if v.type ~= "deckgroup" then
			if x >= v.x and x <= v.x + (v.w*2) and y >= v.y and y <= v.y + (v.h*2) then
				v:startTouch(id,x,y)
				return true
			end
		end
	end
end

function t:new( id, x, y )
	local data = {id=id,x=x,y=y}
	local self = setmetatable(data,t)
	self.pastDeadzone = false
	table.insert( touches, self )
	if not isOnObject(id,x,y) and ui.state == "Main" then
		self.startx = x
		self.starty = y
		self.selecting = true
		for i, v in pairs( Game.Objects ) do
			if v.selected then v.selected = false end
		end
	end
	return self
end

function t:update( dt )

end

function t:updatePosition( x, y )
	if x ~= self.x or y ~= self.y then
		local deadzone = 4.4 * (love.graphics.getWidth()/800)
		if not self.pastDeadzone then
			self.pastDeadzone = math.abs(x-self.x) > deadzone or math.abs(y-self.y) > deadzone
		else	
			self.x = x or self.x
			self.y = y or self.y
			self.canselect = true
			
			for i, v in pairs( Game.Objects ) do
				if v.currentTouchID == self.id then
					v:drag( x, y )
				end
			end
		end
	end
end

function t:draw()
	if self.selecting then
		local x1 = math.min(self.x, self.startx)
		local x2 = math.max(self.x, self.startx)
		local y1 = math.min(self.y, self.starty)
		local y2 = math.max(self.y, self.starty)
		love.graphics.setColor( 255, 0, 0 )
		love.graphics.rectangle("line", x1, y1, x2-x1, y2-y1)
		love.graphics.setColor( 255, 255, 255 )
	end
end

function t:endTouch(x, y)
	local x1 = math.min(self.x, self.startx)
	local x2 = math.max(self.x, self.startx)
	local y1 = math.min(self.y, self.starty)
	local y2 = math.max(self.y, self.starty)
	if self.selecting and self.canselect then
		for i, obj in pairs( Game.Objects ) do
			if obj.type ~= "deckgroup" then
				if obj.x >= x1 and obj.y >= y1 and obj.x + obj.w <= x2 and obj.y + obj.h <= y2 then
					obj.selected = true
					table.insert( Game.Selection, obj )
				end
			end
		end
	end

end


--PUBLIC FUNCTIONS--

function public.new(id,x,y)
	return t:new(id,x,y)
end

function public.draw()
	for i, v in pairs( touches ) do
		v:draw()
	end
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
			if t.selecting then
				t:endTouch(x,y)
			else
				for i, v in pairs( Game.Objects ) do
					if v.currentTouchID == t.id then
						v:endTouch( t.id )
					end
				end
				for i, v in pairs( Game.Objects ) do
					if v.selected then v.selected = false end
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