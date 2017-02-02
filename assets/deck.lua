local DeckWidth = 38
local DeckHeight = 61

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end



local deck = {
	suit = "diamonds",
	value = "2",
	--texture = Textures['diamond/1.png'],
	x = 0,
	y = 0,
	w = DeckWidth,
	h = DeckHeight,
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
	type = "deck",
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
						cards[#cards+1] = {
							suit = v.suit,
							value = v.value,
							flipped = v.flipped
						}
					else
						print( #cards )
						for i, v in pairs( v.cards ) do
							cards[i] = v
						end
						print( #cards )
						for i, v in pairs( self.cards ) do
							cards[#cards+i+1] = v
						end
						print(#cards)
					end
					deck:new({
						x = avgx,
						y = avgy,
						cards = cards,
					})
					table.remove( Game.Objects, i )
					self:remove()
					break
				end
			end
		end
	end,
	onSingleTap = function( self ) --What happens when the user taps once
		if #self.cards > 2 then
			--Drop card
			print( #self.cards )
			local c = self.cards[#self.cards] --the card we're dropping
			local newcard = card:new({
				suit = c.suit,
				value = c.value,
				x = self.x + self.w + 25,
				y = self.y,
				flipped = c.flipped,
			})
			for i, v in pairs( self.cards ) do
				if v == c then
					table.remove( self.cards, i )
					break
				end
			end
			newcard:topDrawOrder()
			print( #self.cards )
		else
			local c1 = self.cards[1]
			local c2 = self.cards[2]
			card:new({
				suit = c1.suit,
				value = c1.value,
				x = self.x + self.w/2 + 10,
				y = self.y,
				flipped = c1.flipped,
			})
			card:new({
				suit = c2.suit,
				value = c2.value,
				x = self.x - self.w/2 - 10,
				y = self.y,
				flipped = c2.flipped,
			})
			self:remove()
			--Split deck into the last two cards
		end
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
			local topCard = self.cards[#self.cards]
			if topCard.flipped then
				love.graphics.draw( Cards.backs.earth, self.x, self.y, 0, 2, 2 )
			else
				love.graphics.draw( Cards[topCard.suit][topCard.value], self.x, self.y, 0, 2, 2 )
			end
			love.graphics.draw( Cards.backs.cardstack, self.x, self.y, 0, 2, 2 )
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
deck.__index = deck

function deck:new( data )
	print( "[deck] Making new deck..." )
	local data = data or { }
	local self = setmetatable(data, deck)
	self.__index = self
	
	table.insert( Game.Objects, self )
	
	return self
end

return deck