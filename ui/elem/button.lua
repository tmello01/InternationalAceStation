--[=[

	button
	-----

]=]--

local button = {
	x = 0,
	y = 0,
	w = 200,
	h = 100,
	background = {33,150,243},
	foreground = {255,255,255},
	onclick = function() end,
	state = "Main",
	text = "A Button",
	onHover = true,

	hover = false,
	selected = false,
	visible = true,
}
button.__index = button

function button:new(data, parent)
	local data = data or { }
	local self = setmetatable(data, button)
	self.__index = self
	self.parent = parent or error("Button object needs a parent!")
	if not self.font then self.font = ui.font(16) end

	table.insert(parent.children,self)
	return self
end

function button:update( dt )
	if ui.checkState(self) then
		if self.onHover then
			local mx, my = love.mouse.getPosition()
			local ax, ay = ui.getAbsX(self),ui.getAbsY(self)
			if mx >= ax and mx <= ax + self.w and my >= ay and my <= ay + self.h then
				self.hover = true
			else
				self.hover = false
			end
		end
	end
end

function button:draw()
	if ui.checkState(self) then
		love.graphics.setColor(self.background)
		if self.hover then
			local r, g, b = unpack(self.background)
			love.graphics.setColor(ui.lighten(r,g,b,25))
		end
		if self.selected then
			local r, g, b = unpack(self.background)
			love.graphics.setColor(ui.lighten(r,g,b,25))
		end
		love.graphics.rectangle("fill",ui.getAbsX(self),ui.getAbsY(self),self.w,self.h)
		love.graphics.setColor(self.foreground or self.parent.foreground)
		love.graphics.setFont(self.font or ui.font(16))
		love.graphics.print(self.text,math.floor(ui.getAbsX(self)+(self.w/2-self.font:getWidth(self.text)/2)),math.floor(ui.getAbsY(self)+(self.h/2-self.font:getHeight()/2)))
	end
end

function button:mousepressed( x, y, button )
	if ui.checkState(self) then
		local ax, ay = ui.getAbsX(self),ui.getAbsY(self)
		if x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.h then
			self.selected = true
		end
	end
end

function button:mousereleased( x, y, button )
	if ui.checkState(self) then
		local ax, ay = ui.getAbsX(self),ui.getAbsY(self)
		if x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.h then
			if self.selected then
				if self.onclick then self.onclick() end
				self.selected = false
			end
		end
	end
end


return button