--[=[

	text
	-----

]=]--

local text = {
	x = 0,
	y = 0,
	background = {255,255,255},
	foreground = {12,12,12},
	state = "Main",
	align = "left",
	text = "Hello World!",
	visible = true,
}
text.__index = text

function text:new(data, parent)
	local data = data or { }
	local self = setmetatable(data, text)
	self.__index = self
	self.parent = parent or error("Text object needs a parent!")
	if not self.font then self.font = ui.font(16) end

	table.insert(parent.children,self)
	return self
end

function text:update( dt )
	if ui.checkState(self) then

	end
end

function text:draw()
	if ui.checkState(self) then
		if self.align == "center" then
			love.graphics.setColor(self.background)
			--love.graphics.rectangle("fill", ui.getAbsX(self)+(self.parent.w/2)-(self.font:getWidth(self.text)), ui.getAbsY(self), self.font:getWidth(self.text), self.font:getHeight())
			love.graphics.setColor(self.foreground or self.parent.foreground)
			love.graphics.setFont( self.font or ui.font(16))
			love.graphics.printf( self.text, ui.getAbsX(self), ui.getAbsY(self), self.parent.w, "center")
		else
			love.graphics.setColor(self.background)
			love.graphics.rectangle("fill",ui.getAbsX(self),ui.getAbsY(self),self.font:getWidth(self.text),self.font:getHeight())
			love.graphics.setColor(self.foreground or self.parent.foreground)
			love.graphics.setFont(self.font or ui.font(16))
			love.graphics.print(self.text,ui.getAbsX(self),ui.getAbsY(self))
		end
	end
end

return text