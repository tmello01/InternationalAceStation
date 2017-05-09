local radio = {
	
	x = 0,
	y = 0,
	size = 20,
	foreground = { 0, 0, 0 },
	foregroundinactive = { 50, 50, 50 },
	background = { 255, 255, 255 },
	onchange = function() end,
	label = "Radio",
	labelLocation = "right",

	selectable = true,

	substate = "Main",
	onHover = true,

	type = "radio",

	align = "left",

	hover = false,
	selected = false,
	active = false,
	visible = true,

	group = "_ALL",

}
radio.__index = radio

function radio:new( data, parent )
	local data = data or {}
	local self = setmetatable(data, copy3(radio))
	self.__index = self
	self.parent = parent or error("Radio object needs a parent")
	self.state = data.state or parent.state
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
		local x = ui.getAbsX(self)
		local y = 0
		if self.align == "center" then
			local twp = self.parent.w --total width, parent
			local tws = self.size + self.size/2 + self.font:getWidth(self.label)
			x = math.ceil((twp/2 - tws/2) + ui.getAbsX(self))
		end
		if self.active then
			if self.selectable then
				love.graphics.setColor( self.foreground )
			else
				love.graphics.setColor( self.foregroundinactive )
			end
			love.graphics.rectangle("fill", x, ui.getAbsY(self), self.size, self.size)
		else
			if self.selectable then
				love.graphics.setColor( self.foreground )
			else
				love.graphics.setColor( self.foregroundinactive )
			end
			love.graphics.rectangle("line", x, ui.getAbsY(self), self.size, self.size)
		end
		if self.label then
			if self.labelLocation == "left" then
				--
			else
				if self.selectable then
					love.graphics.setColor( self.foreground )
				else
					love.graphics.setColor( self.foregroundinactive )
				end
				love.graphics.setFont( self.font )
				love.graphics.print( self.label, math.floor(x + self.size + self.size/2), math.floor(ui.getAbsY(self)) )
			end
		end
	end
end

function radio:mousepressed( x, y, button )
	if ui.checkState( self ) and self.selectable then
		local ax, ay = ui.getAbsPos(self)
		if self.align == "center" then
			local twp = self.parent.w --total width, parent
			local tws = self.size + self.size/2 + self.font:getWidth(self.label)
			ax = math.ceil((twp/2 - tws/2) + ui.getAbsX(self))
		end
		if x >= ax and x <= ax + self.size + self.font:getWidth(self.label) and y >= ay and y <= ay + self.size then
			self.selected = true
		end
	end
end

function radio:mousereleased( x, y, button )
	if ui.checkState( self ) and self.selectable then
		local ax, ay = ui.getAbsPos(self)
		if self.align == "center" then
			local twp = self.parent.w --total width, parent
			local tws = self.size + self.size/2 + self.font:getWidth(self.label)
			ax = math.ceil((twp/2 - tws/2) + ui.getAbsX(self))
		end
		if x >= ax and x <= ax + self.size + self.font:getWidth(self.label) and y >= ay and y <= ay + self.size then
			if self.selected then
				if self.group == "_ALL" then
					self.active = not self.active
					self.selected = false
					if self.onchange then self:onchange() end
				else
					for i, v in pairs( self.parent.children ) do
						if v.type and v.type == "radio" and v.group == self.group and v ~= self then
							v.active = false
							if v.onchange then v:onchange() end
						end
					end
					self.active = true
					if self.onchange then self:onchange() end
				end
			end
		end
	end
end

return radio