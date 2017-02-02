local radio = {
	
	x = 0,
	y = 0,
	size = 20,
	foreground = { 0, 0, 0 },
	background = { 255, 255, 255 },
	onchange = function() end,
	state = "Main",
	label = "Radio",
	labelLocation = "right",

	onHover = true,

	hover = false,
	selected = false,
	active = false,
	visible = true,

}
radio.__index = radio

function radio:new( data, parent )
	local data = data or {}
	local self = setmetatable(data, radio)
	self.__index = self
	self.parent = parent or error("Radio object needs a parent")
	if not self.font then self.font = ui.font(16) end

	table.insert(parent.children,self)
	return self
end

function radio:update( dt )

	if ui.checkState(self) then
		if self.onHover then
			local mx, my = love.mouse.getPosition()
			local ax, ay = ui.getAbsX(self), ui.getAbsY(self)
			if mx >= ax and mx <= ax + self.size and my >= ay and my <= ay + self.size then
				self.hover = true
			else
				self.hover = false
			end
		end
	end
end

function radio:draw()
	if ui.checkState(self) then
		if self.active then
			love.graphics.setColor( self.foreground )
			love.graphics.rectangle("fill", ui.getAbsX(self), ui.getAbsY(self), self.size, self.size)
		else
			love.graphics.setColor( self.foreground )
			love.graphics.rectangle("line", ui.getAbsX(self), ui.getAbsY(self), self.size, self.size)
		end
		if self.label then
			if self.labelLocation == "left" then
				--
			else
				love.graphics.setColor( self.foreground )
				love.graphics.setFont( self.font )
				love.graphics.print( self.label, math.floor(ui.getAbsX(self) + self.size + self.size/2), math.floor(ui.getAbsY(self)) )
			end
		end
	end
end

function radio:mousepressed( x, y, button )
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos(self)
		if x >= ax and x <= ax + self.size and y >= ay and y <= ay + self.size then
			self.selected = true
		end
	end
end

function radio:mousereleased( x, y, button )
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos(self)
		if x >= ax and x <= ax + self.size and y >= ay and y <= ay + self.size then
			if self.selected then
				if self.onchange then self.onchange() end
				self.active = not self.active
			end
		end
	end
end

return radio