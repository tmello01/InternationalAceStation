local value = {
	x = 0,
	y = 0,
	minvalue = 0,
	maxvalue = 100,
	value = 10,
	w = 60,
	h = 60,

	background = { 255, 255, 255 },
	buttons = { 200, 200, 200 },
	foreground = { 21, 21, 21 },

	valtimer = timer.new(0.3),
	incriment = 1,
	substate = "Main",
	visible = true
}
value.__index = value

function value:new( data, parent )
	local data = data or {}
	local self = setmetatable( data, value )
	self.font = data.font or ui.font( 16 )
	self.parent = parent or error("Value object needs a parent!")
	self.state = data.state or parent.state
	table.insert( self.parent.children, self )
	return self
end

function value:update( dt )
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos( self )
		if self.align == "center" then
			ax = ui.getAbsX(self) + self.parent.w/2 - self.w/2
		end
		if love.mouse.isDown(1) then
			if self.valtimer:update(dt) then
				local mx, my = love.mouse.getPosition()
				if mx >= ax and mx <= ax + self.w and my >= ay and my <= ay + self.h/3 then
					--increase value
					self.value = math.min(self.value + self.incriment, self.maxvalue)
				elseif mx >= ax and mx <= ax + self.w and my >= ay + self.h*.66 and my <= ay + self.h then
					--decrease value
					self.value = math.max(self.minvalue, self.value - self.incriment)
				end
				self.valtimer:restart()
			end
		else
			self.valtimer:stop()
		end
	end
end

function value:draw()
	if ui.checkState( self ) then
		local ax, ay = ui.getAbsPos( self )
		if self.align == "center" then
			ax = ui.getAbsX(self) + self.parent.w/2 - self.w/2
		end
		love.graphics.setColor( self.background )
		love.graphics.rectangle("fill", ax, ay, self.w, self.h)
		love.graphics.setColor( self.buttons )
		love.graphics.rectangle("fill", ax, ay, self.w, self.h/3)
		love.graphics.rectangle("fill", ax, ay+self.h*0.66, self.h/3)
		love.graphics.setColor( self.foreground )
		love.graphics.printf("v", ax, ay+self.h*0.66, self.w, "center")
		love.graphics.printf("^", ax, ay, self.w, "center")
		love.graphics.printf(tostring(self.value), ax, ay+self.h/3, self.w, "center")
		love.graphics.setColor( 255, 255, 255 )
	end
end

return value