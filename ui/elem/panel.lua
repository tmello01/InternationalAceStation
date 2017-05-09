--[=[

	Panel
	-----

]=]--

local panel = {
	x = 0,
	y = 0,
	w = 400,
	h = 200,
	background = {255,255,255},
	foreground = {12,12,12},
	children = { },
	visible = true,
	substate = "Main",
	_substate = "Main",
	drawAboveObjects = false,
	setSubstate = function(self, state)
		self._substate = state
	end,
}
panel.__index = panel

function panel:new(data, parent)
	local data = copy3(data) or { }
	local self = setmetatable(data, panel)
	self.state = data.state or "Main"
	if parent then
	
		self.parent = parent
		table.insert(parent.children,self)
	else
		self.isroot = true
		table.insert(ui.roots, self)
	end
	return self
end

function panel:update( dt )
	if ui.checkState(self) then
		for i, v in pairs( self.children ) do
			if v ~= self then
				if v.update then v:update( dt ) end
			end
		end
	end
end

function panel:add(t,data)
	if ui.elements[t] then
		return ui.elements[t]:new(copy3(data),self)
	end
end

function panel:draw()
	if ui.checkState(self) then
		love.graphics.setColor(self.background)
		love.graphics.rectangle("fill",ui.getAbsX(self),ui.getAbsY(self),self.w,self.h)

		for i, v in pairs( self.children ) do
			if v ~= self then
				if v.draw then v:draw() end
			end
		end
		love.graphics.setColor( 255, 255, 255 )
	end
end

function panel:mousepressed( x, y, button )

	if ui.checkState(self) then
		local ax, ay = ui.getAbsX(self),ui.getAbsY(self)
		if x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.h then
			for i, v in pairs( self.children ) do
				if v ~= self then
					if v.mousepressed then v:mousepressed( x,y,button ) end
				end
			end
			return true
		end
	end
end
function panel:mousereleased( x, y, button )

	if ui.checkState(self) then
		local ax, ay = ui.getAbsX(self),ui.getAbsY(self)
		if x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.h then
			for i, v in pairs( self.children ) do
				if v ~= self then
					if v.mousereleased then v:mousereleased( x,y,button ) end
				end
			end
		end
	end

end

function panel:textinput( text )
	if ui.checkState( self ) then
		for i, v in pairs( self.children ) do
			if v ~= self then
				if v.input then 
					if v:input(text) then
						return true
					end
				end
			end
		end
	end
	return false
end
function panel:keypressed( key )
	if ui.checkState( self ) then
		for i, v in pairs( self.children ) do
			if v ~= self then
				if v.keypressed then 
					if v:keypressed( key ) then
						return true
					end
				end
			end
		end
	end
end
function panel:keyreleased( key )
	if ui.checkState( self ) then
		for i, v in pairs( self.children ) do
			if v ~= self then
				if v.keyreleased then v:keyreleased( key ) end
			end
		end
	end
end
return panel