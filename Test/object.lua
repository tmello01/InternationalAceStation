local object = {
	--[=[
	onTap, onHold, onDoubleTap
	]=]--
	tapTimer = 0,
	tappedOnce = false,
	tappedTwice = false,
	waitForSecondTap = false,
	--Tap len 0.15
	x = 0,
	y = 0,
	w = 20,
	h = 10,
	dx = 0,
	dy = 0,
	texture = textures["card"],

	lockId = -1,
	locked = false
}
object.__index = object

local obj = { }
local objects = { }

local raw_objs = { }

--Load objects--
for i, v in pairs( love.filesystem.getDirectoryItems("resources/objects/") ) do
	print(v)
	raw_objs[v:sub(1,-5)] = love.filesystem.load("resources/objects/"..v)()
end

function object:new(name,data)
	if raw_objs[name] then
		local data = data or { }
		local preobj = setmetatable(raw_objs[name],object)
		local self = setmetatable(data,preobj)
		table.insert(obj,self)
		return self
	else
		error("No object named \""..name.."\"")
	end

end

function object:update( dt )
	if self.locked then
		local b = GET_TOUCH(self.lockId)
		if b then
			self.x = b.x - self.dx
			self.y = b.y - self.dy
		end
	end
end

function object:delete()
	for i, v in pairs( obj ) do
		if v == self then
			obj[i] = nil
			self = nil
		end
	end
end

function object:draw( )
	if self.animated then

	else
		if self.texture then
			love.graphics.draw( self.texture, self.x, self.y )
		end
	end
end

function object:handleTap( id )
	if tappedOnce then
		self.tappedTwice = true
	else
		self.tappedOnce = true
		self.waitForSecondTap = true
	end
end

function objects.update( dt )
	for i, v in pairs( obj ) do
		if v.update then v:update(dt) end
	end
end

function objects.draw( )
	for i,v in pairs( obj ) do
		if v.draw then v:draw() end
	end
end

function objects.new( name, data )
	return object:new( name, data )
end

function objects.checkPosition(x,y,id)
	for i, v in pairs( obj ) do
		if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
			v:onTap(id)
			return
		end
	end
end

function objects.startHold( x, y, id )
	for i, v in pairs( obj ) do
		if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
			v:onHold(id,x,y)
			return true
		end
	end
end 

function objects.endHold( x, y, id )
	for i, v in pairs( obj ) do
		if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
			v:onHoldRelease(id, x, y )
		end
	end
end

function objects.getAll()
	return obj
end


return objects