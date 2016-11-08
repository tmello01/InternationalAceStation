local ui = {
	path = ..., --absolute path to this UI file
	roots = { }, --for the rooted panels
	state = "Main",
	fonts = { }, --for containing all UI made fonts
}

ui.elements = {}
for i, v in pairs( love.filesystem.getDirectoryItems(ui.path.."/elem") ) do
	ui.elements[v:sub(1,-5)] = require(ui.path.."/elem/"..v:sub(1,-5))
end

function ui.checkState(obj)
	if obj.state and (obj.state == ui.state or obj.state == "_ALL") and obj.visible then
		return true
	else
		return false
	end
end

function ui.font(size)
	if not ui.fonts[size] then
		ui.fonts[size] = love.graphics.newFont(size)
	end
	return ui.fonts[size]
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
		return obj.y + ui.getAbsX(obj.parent)
	else
		return obj.y
	end
end



function ui.new(data)
	return ui.elements.panel:new(data)
end



function ui.update( dt )
	for i, v in pairs( ui.roots ) do
		if v.update then v:update( dt ) end
	end
end

function ui.draw()
	for i, v in pairs( ui.roots ) do
		if v.draw then v:draw() end
	end
end


return ui