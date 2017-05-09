local ui = {
	path = ..., --absolute path to this UI file
	roots = { }, --for the rooted panels
	state = "Main",
	fonts = {}, --for containing all UI made fonts
	images = {},
}

for i, v in pairs(love.filesystem.getDirectoryItems("assets/fonts")) do
	ui.fonts[v:sub(1,-5)] = {}
end


ui.elements = {}
for i, v in pairs( love.filesystem.getDirectoryItems(ui.path.."/elem") ) do
	ui.elements[v:sub(1,-5)] = require(ui.path.."/elem/"..v:sub(1,-5))
end
function ui.checkState(obj,dbug)
	if obj.state and obj.state == ui.state and obj.visible then
		if obj.parent then
			if obj.parent._substate == obj.substate and ui.checkState(obj.parent) then
				return true
			else
				return false
			end
		end
		return true
	else
		return false
	end
end

function ui.font(size, font)
	local font = font or "Roboto-Light"
	if not ui.fonts[font][size] then
		if love.filesystem.isFile("assets/fonts/"..font..".ttf") then
			ui.fonts[font][size] = love.graphics.newFont("assets/fonts/"..font..".ttf", size)
		elseif love.filesystem.isFile("assets/fonts/"..font..".otf") then
			ui.fonts[font][size] = love.graphics.newFont("assets/fonts/"..font..".otf", size)
		end
	end
	return ui.fonts[font][size]
end
function ui.image(path)
	local path = path or "cards/blank"
	if not ui.images[path] then
		ui.images[path] = love.graphics.newImage("assets/images/"..path..".png")
	end
	return ui.images[path]
end

function ui.lighten(r,g,b,amt)
	local r = math.clamp(0,r+amt,255)
	local g = math.clamp(0,g+amt,255)
	local b = math.clamp(0,b+amt,255)
	return r,g,b
end

function ui.darken(r,g,b,amt)
	local r = math.clamp(0,r-amt,255)
	local g = math.clamp(0,g-amt,255)
	local b = math.clamp(0,b-amt,255)
	return r,g,b
end

function ui.getAbsX(obj)
	if obj.parent then
		return obj.x + ui.getAbsX(obj.parent)
	else
		return obj.x
	end
end
function ui.getAbsY(obj)
	if obj.parent then
		return obj.y + ui.getAbsY(obj.parent)
	else
		return obj.y
	end
end
function ui.getAbsPos(obj)
	return ui.getAbsX(obj), ui.getAbsY(obj)
end
function ui.getRadioGroup(group)
	local group = group or "_ALL"
	if group ~= "_ALL" then
		for i, v in pairs( ui.roots ) do
			for k, z in pairs( v.children ) do
				if z.type and z.type == "radio" and z.active and z.group == group then
					return z
				end
			end
		end
	end
end

function ui.new(data)
	return ui.elements.panel:new(copy3(data))
end

function ui.update( dt )
	for i, v in pairs( ui.roots ) do
		if v.update then v:update( dt ) end
	end
end

function ui.draw()
	for i, v in pairs( ui.roots ) do
		if v.draw and not v.drawAboveObjects then v:draw() end
	end
end

function ui.drawAbove()
	for i, v in pairs( ui.roots ) do
		if v.draw and v.drawAboveObjects then v:draw() end
	end
end

function ui.mousepressed( x, y, button )
	for i, v in pairs( ui.roots ) do
		if v.mousepressed then v:mousepressed(x, y, button) end
	end
end

function ui.mousereleased( x, y, button )
	for i, v in pairs( ui.roots ) do
		if v.mousereleased then v:mousereleased( x, y, button ) end
	end
end

function ui.textinput( text )
	for i, v in pairs( ui.roots ) do
		if v.textinput then 
			if v:textinput( text ) then
				return
			end
		end
	end
end
function ui.keypressed( key )
	for i, v in pairs( ui.roots ) do
		if v.keypressed then
			if v:keypressed( key ) then
				return
			end
		end
	end
end
function ui.keyreleased( key )
	for i, v in pairs( ui.roots ) do
		if v.keyreleased then v:keyreleased( key ) end
	end
end
return ui