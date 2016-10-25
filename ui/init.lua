local ui = {
	path = ...,
}

ui.elements = {}
for i, v in pairs( love.filesystem.getDirectoryItems(ui.path.."/elem") ) do
	ui.elements[v:sub(1,-5)] = love.filesystem.load(ui.path.."/elem"..v)()
end



return ui