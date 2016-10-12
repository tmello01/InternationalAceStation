local touch = {
	x=0,
	y=0,
	id=0,
	group=-1,
	color = {255,255,255},
	refx = 0,
	refy = 0,
	action = "tap",
	locked = false
}

local touchSensitivity = 20

local group = { 
}

touch.__index = touch

local touches = { } 

function touch:new(id,x,y)

	local t={x=x,y=y,id=id,color={255,255,255},held = "line",refx=x,refy=y}
	t.timer = timer:new(0.5,function() t.held="fill" end)
	local a = setmetatable(t,touch)

	for i, v in pairs( touches ) do
		if v.id ~= id then
			--[=[local dist = math.sqrt((v.x-x)^2+(v.y-y)^2)
			if dist <= touchSensitivity*2 then
				v.group = #groups+1
				a.group = #groups+1
				table.insert( groups, {v.id, a.id } )
			end--]=]
		end
	end

	table.insert( touches, a )
	return a
end

function touch:move(id,x,y)
	if self.id == id then
		self.x = x
		self.y = y
		local dist = math.sqrt((self.x-self.refx)^2 + (self.y-self.refy)^2)
		if dist >= touchSensitivity/2 and not self.locked then
			self.refx = x
			self.refy = y

			if objects.startHold( self.x, self.y, self.id ) then
				self.locked = true
			end
			self.timer = timer:new(0.5,function() self.held="fill" end)
		end
		if self.group > 0 then

		end
	end
end

function touch:update( dt )
	if self.timer:getPercentageComplete() > 0.99 and not self.locked then
		self.locked = true
		objects.startHold( self.x, self.y, self.id )
	end
end

function touch:remove(id,x,y)
	print( self.locked )
	if self.id == id then
		if self.locked then
			objects.endHold(x,y,id)
		else
			objects.checkPosition(x,y,id)
		end
		self = nil
		return true
	end
end

function touch:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle("line", self.x, self.y, touchSensitivity, 100)
	love.graphics.circle("fill", self.x, self.y, touchSensitivity*self.timer:getPercentageComplete(), 100)
	love.graphics.setColor(255,255,255)
end

function NEW_TOUCH(id,x,y)
	touch:new(id,x,y)
end

function MOVE_TOUCH(id,x,y)
	for i, v in pairs( touches ) do
		v:move(id,x,y)
	end
end

function DEL_TOUCH(id,x,y)
	for i, v in pairs( touches ) do
		if v:remove(id,x,y) then
			touches[i] = nil
		end
	end
end

function DRAW_TOUCH()
	for i, v in pairs( touches ) do
		v:draw()
	end
end

function UPDATE_TOUCH(dt)
	for i, v in pairs( touches ) do
		v:update( dt )
	end
end

function GET_TOUCH(id)
	for i, v in pairs( touches ) do
		if v.id == id then
			return v
		end
	end
end

return touch