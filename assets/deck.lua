local DeckWidth = 38
local DeckHeight = 61

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end
math.randomseed(os.time())
local function shuffleTable( t )
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

local deck = {
	x = 0,
	y = 0,
	w = DeckWidth,
	h = DeckHeight,
	istemplate = false,
	visible = true,
	dragx = 0, --Drag X position
	dragy = 0, --Drag Y position
	dragged = false, --If card is being dragged or not
	visible = true,
	touched = false,
	tweento = false,
	startdx = -1,
	startdy = -1,
	locked,
	inhand = false,
	held = false,
	type = "deck",
	tapTimer = timer.new(0.5),
	getPosition = function( self )
		return self.x, self.y
	end,
	onHold = function( self )
		local cardsToStack = {}
		for i, v in pairs( Game.Objects ) do
			if v ~= self then
				if checkCollision(self.x, self.y, self.w, self.h,  v.x, v.y, v.w, v.h) then
					table.insert( cardsToStack, v )
				end
			end
		end
		if #cardsToStack > 0 then
			local cards = {}
			for i, v in pairs( cardsToStack ) do
				if v.type == "card" then
					table.insert( cards, {
						suit = v.suit,
						value = v.value,
						flipped = v.flipped
					})
				elseif v.type == "deck" then
					for k, z in pairs( v.cards ) do
						table.insert( cards, {
							suit = z.suit,
							value = z.value,
							flipped = z.flipped,
						})
					end
				end
			end
			for i, v in pairs( self.cards ) do
				table.insert( cards, {
					suit = v.suit,
					value = v.value,
					flipped = v.flipped,
				})
			end
			print(table.serialize( cards ) )
			for i, v in pairs( cardsToStack ) do
				v:remove()
			end
			newdeck = deck:new({cards=cards, x = self.x, y=self.y})
			local sound = love.math.random(1,4)
			Game.Sounds.CardPlace[sound]:stop()
			Game.Sounds.CardPlace[sound]:play()
			self:remove()
			return
		end
	end,
	onSingleTap = function( self ) --What happens when the user taps once
		if #self.cards > 2 then
			--Drop card
			local c = self.cards[#self.cards] --the card we're dropping
			local newcard = card:new({
				suit = c.suit,
				value = c.value,
				x = self.x,
				y = self.y,
				flipped = c.flipped,
				tweentox = self.x + self.w + 50,
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
			print( table.serialize( self.cards ) )
			if c1 and c2 then
				card:new({
					suit = c1.suit,
					value = c1.value,
					x = self.x,
					y = self.y,
					flipped = c1.flipped,
				})
				card:new({
					suit = c2.suit,
					value = c2.value,
					x = self.x,
					y = self.y,
					flipped = c2.flipped,
					tweentox = self.x + self.w + 50,
				})
				self:remove()
				return
			end
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
		if not self.dragged then
			Game.Sounds.CardSlide[love.math.random(1,4)]:play()
			self.startdx = self.x
			self.startdy = self.y
		end
		self.dragged = true
		self.x = x-self.dragx
		self.y = y-self.dragy
		if self.x < love.graphics.getWidth()/4 then
			if not SHOWCHARMS then
				SHOWCHARMS = true
				SHOWDECKCHARMS = true
				Tweens.Final.HideCharmsPanel.t:reset()
				Tweens.Final.ShowCharmsPanel.active = true
				Tweens.Final.HideCharmsPanel.active = false
			end
		else

			Tweens.Final.ShowCharmsPanel.active = false
			Tweens.Final.HideCharmsPanel.active = true
		end
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
			if self.tweenback then
				if self.gotostart:update( dt ) then
					self.tweenback = false
					self.startdx = -1
					self.startdy = -1
				end
			end
			if self.tweento then
				if self.tweentotween:update( dt ) then
					self.tweento = false
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
				--print( table.serialize( self.cards ) )
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
			local w = 75
			if self.dragged then
				Tweens.Final.ShowCharmsPanel.active = false
				Tweens.Final.HideCharmsPanel.active = true
				if self.x + self.w >= 0 and self.x <= w and self.y + self.h >= 0 and self.y <= w then
					self:remove()
				elseif self.x + self.w >= 0 and self.x <= w and self.y + self.h >= love.graphics.getHeight()/2-25 and self.y <= love.graphics.getHeight()/2-25 + w then
					shuffleTable(self.cards)

					self.gotostart = tween.new(0.3, self, {x = self.startdx, y = self.startdy}, "inOutExpo")
					self.tweenback = true
				elseif self.x + self.w >= 0 and self.x <= w and self.y + self.h >= love.graphics.getHeight()-115 and self.y <= love.graphics.getHeight() -15 then
					Game.Sounds.CardSlide[love.math.random(5,8)]:play()
					if #self.cards == 2 then
						local c1 = self.cards[1]
						local c2 = self.cards[2]
						card:new({value=c1.value,suit=c1.suit,x=self.startdx-DeckWidth,y=self.startdy,flipped=c1.flipped})
						card:new({value=c2.value,suit=c2.suit,x=self.startdx+DeckWidth,y=self.startdy,flipped=c2.flipped})
						self:remove()
						return
					elseif #self.cards == 3 then
						local c1 = self.cards[1]
						card:new({value=c1.value,suit=c1.suit,x=self.startdx-DeckWidth,y=self.startdy,flipped=c1.flipped})
						table.remove(self.cards, 1)
						deck:new({cards=self.cards,x=self.startdx+DeckWidth,y=self.startdy})
						self:remove()
						return
					end
					local half = math.ceil(#self.cards/2)
					local d1 = {}
					local d2 = {}
					print( table.serialize(self.cards))
					for i, v in pairs( self.cards ) do
						if i <= half then
							table.insert( d1, {
								value = v.value,
								suit = v.suit,
								flipped = v.flipped
							})
						else
							table.insert( d2, { 
								value = v.value,
								suit = v.suit,
								flipped = v.flipped,
							})
						end
					end
					deck:new({cards=d1,x=self.x, y=self.y, tweentox = self.startdx-DeckWidth-2, tweentoy = self.startdy})
					deck:new({cards=d2,x=self.x, y=self.y, tweentox = self.startdx+DeckWidth+2, tweentoy = self.startdy})
					self:remove()
					return
				end
			end
			Game.Sounds.CardSlide[love.math.random(1,4)]:play()
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
	self.tweenback = false
	self.__index = self
	if self.tweentox or self.tweentoy then
		self.tweentox = self.tweentox or self.x
		self.tweentoy = self.tweentoy or self.y
		self.tweento = true
		self.tweentotween = tween.new(0.2, self, {x = self.tweentox, y = self.tweentoy}, "inOutExpo")
	end
	table.insert( Game.Objects, self )
	
	return self
end

return deck