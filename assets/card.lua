local CardWidth = 38
local CardHeight = 61

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end



local card = {
	suit = "diamonds",
	value = "2",
	--texture = Textures['diamond/1.png'],
	x = 0,
	y = 0,
	w = CardWidth,
	h = CardHeight,
	visible = true,
	dragx = 0, --Drag X position
	dragy = 0, --Drag Y position
	dragged = false, --If card is being dragged or not
	inDeck = false, --Possibly defunct
	visible = true,
	firstTouchID = -1,
	lastTouchID = 1,
	currentTouchID = -1,
	touched = false,
	held = false,
	type = "card",
	tapTimer = timer.new(0.5),
	getPosition = function( self )
		return self.x, self.y
	end,
	onHold = function( self )
		for i, v in pairs( Game.Objects ) do
			if v ~= self then
				if checkCollision(self.x, self.y, self.w, self.h,  v.x, v.y, v.w, v.h) then
					--Create a deck--
					local avgx = (self.x + v.x)/2
					local avgy = (self.y + v.y)/2
					local cards = {}
					if v.type == "card" then
						cards[1] = {
							suit = v.suit,
							value = v.value,
							flipped = v.flipped
						}
					else
						for i, z in pairs( v.cards ) do
							print( i )
							cards[i] = z
						end
					end

					cards[#cards+1] = {
						suit = self.suit,
						value = self.value,
						flipped = self.flipped,
					}
					deck:new({
						x = avgx,
						y = avgy,
						cards = cards,
					})
					table.remove( Game.Objects, i )
					self:remove()
					return
				end
			end
		end
	end,
	onSingleTap = function( self ) --What happens when the user taps once
		self.flipped = not self.flipped
	end,
	onDoubleTap = function( self ) --What happens when the user taps twice
		
	end,
	remove = function( self )
		for i, v in pairs( Game.Objects ) do
			if v == self then
				table.remove( Game.Objects, i )
				break
			end
		end
	end,
	drag = function( self, x, y )
		self.dragged = true
		self.x = x-self.dragx
		self.y = y-self.dragy
	end,
	update = function( self, dt )
		if self.visible then
			if self.touched and not self.dragged then
				if self.tapTimer:update( dt ) then
					self.held = true
					if self.onHold then self:onHold() end
					self.tapTimer:stop()
				end
			end
		end
	end,
	draw = function( self )
		if self.visible then
			if not self.flipped then
				love.graphics.draw( Cards[self.suit][self.value], self.x, self.y, 0, 2, 2 )
			else
				love.graphics.draw( Cards.backs.earth, self.x, self.y, 0, 2, 2 )
			end
		end
	end,
	startTouch = function( self, id, x, y )
	
		self.dragx = x-self.x
		self.dragy = y-self.y
		self.touched = true
		self.currentTouchID = id
		self.tapTimer:restart()
		self.tapTimer:start()
		self:topDrawOrder()
	end,
	endTouch = function( self, id )
		if self.touched then
			self.tapTimer:stop()
			if not self.held and not self.dragged then
				self:onSingleTap()
			end
			self.dragged = false
			self.held = false
			self.touched = false
		end
	end,
	cancelTouchManager = function( self, id )
		if self.touched then
			self.tapTimer:stop()
		end
	end,
	topDrawOrder = function( self )
		for i, v in pairs( Game.Objects ) do
			if v == self then
				table.remove( Game.Objects, i )
				table.insert( Game.Objects, self )
				break
			end
		end
	end,
}
card.__index = card

function card:new( data )
	print( "[card] Making new card..." )
	local data = data or { }
	local self = setmetatable(data, card)
	self.__index = self
	
	table.insert( Game.Objects, self )
	
	return self
end

return card