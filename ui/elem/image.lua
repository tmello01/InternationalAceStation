local image = {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	shader = { 255, 255, 255 },
	border = { 255, 255, 255, 0 },
	borderweight = 0,
	substate = "Main",
	onHover = false,

	align = "left",
	hover = false,
	selected = false,
	active = false,
	visible = true,
	scalex = 1,
	scaley = 1,

	path = "cards/blank"
}
image.__index = image

function image:new( data, parent )
	local data = data or {}
	local self = setmetatable(data, copy3(image))
	self.__index = self
	self.parent = parent or error("Image object needs a parent!")
	self.state = data.state or parent.state
	self.w = ui.image(self.path):getWidth()*self.scalex
	self.h = ui.image(self.path):getHeight()*self.scaley

	table.insert( self.parent.children, self )
	return self
end

function image:update( dt )

end

function image:draw( )
	if ui.checkState( self ) then
		if self.onHover then

		end
		local x = self.x
		if self.align == "center" then
			x = self.parent.w/2 - ui.image(self.path):getWidth()/2
		end
		love.graphics.setColor( self.shader )
		love.graphics.draw( ui.image(self.path), x, self.y, 0, self.scalex, self.scaley )
	end
end

return image