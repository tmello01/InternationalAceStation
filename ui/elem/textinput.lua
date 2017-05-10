local textinput = {
	x = 0,
	y = 0,
	w = 200,
	foreground = { 0, 0, 0 },
	background = { 255, 255, 255 },
	border = { 0, 0, 0 },
	borderweight = 1,
	placeholder = "A Text Input",
	substate = "Main",
	onHover = true,
	placeholderColor = { 150, 150, 150 },
	align = "left",
	text = "",

	hover = false,
	selected = false,
	active = false,
	visible = true,

	charset = "",
	checkCharset = function( self, char )
		if #self.charset > 0 then
			for i=1, #self.charset do
				if self.charset:sub(i,i) == char then
					return true
				end
			end
			return false
		end
		return true
	end,

	maxlength = -1,
}
textinput.__index = textinput

function textinput:new( data, parent )
	local data = data or {}
	local self = setmetatable(data, copy3(textinput))
	self.parent = parent or error("Textinput needs a parent object")
	self.state = data.state or parent.state
	if not self.font then self.font = ui.font(26) end
	self.h = self.font:getHeight() + 6
	table.insert(parent.children, self)
	return self
end

function textinput:update( dt )
	if ui.checkState(self) then
		if self.onHover then
			local mx, my = love.mouse.getPosition()
			local ax, ay = ui.getAbsPos(self)
			if mx >= ax and mx <= ax + self.w and my >= ay and my <= ay + self.font:getHeight()+6 then
				self.hover = true
			else
				self.hover = false
			end
		end
	end
end

function textinput:draw()
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos( self )
		local x = ax
		if self.active then
			love.graphics.setColor( self.border )
		else
			local r,g,b = unpack(self.border)
			love.graphics.setColor( ui.lighten( r, g, b, 25 ) )
		end
		if self.align == "center" then
			local twp = self.parent.w
			x = math.ceil(ax + (twp/2)-self.w/2)
		end		
		local drawtx = x + 5
		if self.font:getWidth(self.text) > self.w - self.font:getWidth("www") then
			--Text is too wide--
			local diff = self.font:getWidth(self.text) - self.w - - self.font:getWidth("www")
			drawtx = x - diff
		end

		love.graphics.setColor( self.background )
		love.graphics.rectangle("fill", x, ay, self.w, self.font:getHeight() + 6)
		love.graphics.setLineWidth( self.borderweight )
		love.graphics.rectangle("line", x, ay, self.w, self.font:getHeight() + 6)
		if #self.text < 1 and not self.active then
			love.graphics.setColor( self.placeholderColor )
			love.graphics.setFont( self.font )
			love.graphics.print( self.placeholder, x + 5, ay + 3 )
		else
			love.graphics.setColor( self.foreground )
			love.graphics.setFont(self.font)
			local appendChar = ""
			if self.active then
				appendChar = "|"
			end
			love.graphics.setScissor( x, ay, self.w, self.h )
			love.graphics.print( self.text..appendChar, drawtx, ay + 3 )
			love.graphics.setScissor()
		end
	end
end

function textinput:mousepressed( x, y, button )
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos( self )

		if self.align == "center" then
			local twp = self.parent.w
			ax = math.ceil(ax + (twp/2)-self.w/2)
		end
		if x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.font:getHeight() + 6 then
			self.active = true
			love.keyboard.setTextInput(true)
			love.keyboard.setKeyRepeat(true)
		else
			if self.active then
				love.keyboard.setKeyRepeat(false)
			end
			self.active = false
		end
	end
end

function textinput:input(i)
	if ui.checkState( self ) and self.active and (#self.text < self.maxlength or self.maxlength < 0) then
	
		print( self.placeholder )
		if self:checkCharset(i) then
			self.text = self.text .. i
			if self.onchange then self.onchange() end
		end
	end
end

function textinput:keypressed(key)
	if ui.checkState( self ) and self.active then
		if key == "backspace" then
			self.text = self.text:sub(1, -2)
			if self.onchange then self.onchange() end
		elseif key == "return" then
			self.active = false
			if self.onreturn then self.onreturn() end
			love.keyboard.setTextInput( false )
		end
	end
end

return textinput