--[=[

	text
	-----

]=]--

local text = {
	x = 0,
	y = 0,
	background = {255,255,255},
	foreground = {12,12,12},
	align = "left",
	text = "Hello World!",
	visible = true,
	substate = "Main",
}
text.__index = text

function text:new(data, parent)
	local data = data or { }
	local self = copy3(text)
	self = setmetatable(data,self)
	self.parent = parent or error("Text object needs a parent!")
	self.background = data.background or parent.background
	self.state = data.state or parent.state
	if not self.font then self.font = ui.font(16) end
	self.lines = {""}
	local words = {}
	for word in self.text:gmatch("%S+") do
		table.insert( words, word )
	end
	local line = 1
	for i, v in pairs( words ) do
		if self.font:getWidth(self.lines[line]..v) >= self.parent.w - self.x - 10 then
			self.lines[line+1] = v
			line = line + 1
		else
			if #self.lines[line] < 1 then
				self.lines[line] = v
			else
				self.lines[line] = self.lines[line] .. " " .. v
			end
		end
	end
	
	self.originaltext = self.text
	--print( table.serialize( self.lines ) )

	table.insert(parent.children,self)
	return self
end

function text:reformat()
	self.lines = {""}
	local words = {}
	for word in self.text:gmatch("%S+") do
		table.insert( words, word )
	end
	local line = 1
	for i, v in pairs( words ) do
		if self.font:getWidth(self.lines[line]..v) >= self.parent.w - self.x - 10 then
			self.lines[line+1] = v
			line = line + 1
		else
			if #self.lines[line] < 1 then
				self.lines[line] = v
			else
				self.lines[line] = self.lines[line] .. " " .. v
			end
		end
	end
end

function text:update( dt )
	if ui.checkState(self) then
		if self.text ~= self.originaltext then
			self:reformat()
		end
	end
end

function text:draw()
	if ui.checkState(self) then
		if self.align == "center" then
			love.graphics.setColor(self.foreground or self.parent.foreground)
			love.graphics.setFont( self.font or ui.font(16))
			for i, v in pairs( self.lines ) do
				love.graphics.printf( self.lines[i], ui.getAbsX(self), ui.getAbsY(self)+((i-1)*self.font:getHeight()), self.parent.w-self.x, "center")
			end
		else
			--love.graphics.setColor(self.background)
			--love.graphics.rectangle("fill",ui.getAbsX(self),ui.getAbsY(self),self.font:getWidth(self.text),self.font:getHeight())
			love.graphics.setColor(self.foreground or self.parent.foreground)
			love.graphics.setFont(self.font or ui.font(16))
			for i, v in pairs( self.lines ) do
				love.graphics.print( self.lines[i], ui.getAbsX(self), ui.getAbsY(self)+((i-1)*self.font:getHeight()) )
			end
		end
	end
end

return text