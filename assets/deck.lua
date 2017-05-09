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
	networkID = "",
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
	selected = false,
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
			Game.InitializeDeck(self.x, self.y, cards)
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
			
			for i, v in pairs( self.cards ) do
				if v == c then
					table.remove( self.cards, i )
					break
				end
			end
			if Game.IsAdmin() then
				Game.SendToClients("UPDATEDECK", {n = self.networkID, c = self.cards})
				Game.InitializeCard(c.suit, c.value, self.x, self.y, c.flipped, self.x + self.w + 50)
			else
				Game.SendToHost("DRAWCARD", {n = self.networkID})
			end
			
			print( #self.cards )
		else
			local c1 = self.cards[1]
			local c2 = self.cards[2]
			print( table.serialize( self.cards ) )
			if c1 and c2 then
				if Game.IsAdmin() then
					Game.InitializeCard(c1.suit,c1.value,self.x,self.y,c1.flipped)
					Game.InitializeCard(c2.suit,c2.value,self.x,self.y,c2.flipped,self.x + self.w + 50)
				else
					Game.SendToHost("DRAWCARD", {n = self.networkID})
				end
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
				if Game.IsAdmin() then
					Game.SendToClients("REMOVE", {n = self.networkID})
				else
					Game.SendToHost("REMOVE", {n = self.networkID})
				end
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
		if Game.IsAdmin() then
			Game.SendToClients("MOVE", {n = self.networkID, x = self.x, y = self.y})
		else
			Game.SendToHost("MOVE", {n = self.networkID, x = self.x, y = self.y})
		end
		if self.x < love.graphics.getWidth()/4 then
			if not SHOWCHARMS then
				SHOWCHARMS = true
				SHOWDECKCHARMS = not self.selected
				Tweens.Final.HideCharmsPanel.t:reset()
				Tweens.Final.ShowCharmsPanel.active = true
				Tweens.Final.HideCharmsPanel.active = false
			end
		else

			Tweens.Final.ShowCharmsPanel.active = false
			Tweens.Final.HideCharmsPanel.active = true
		end
		if self.selected then
			for i, v in pairs( Game.Selection ) do
				for k, z in pairs( Game.Objects ) do
					if z.networkID == v then
						z.x = x - z.dragx
						z.y = y - z.dragy
					end
				end
			end
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
			if self.selected then
				love.graphics.setLineWidth(3)
				love.graphics.setColor( 0, 255, 0 )
				love.graphics.rectangle("line", self.x, self.y, self.w*2, self.h*2 )
				love.graphics.setColor( 255, 255, 255 )
				love.graphics.setLineWidth(1)
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
		if self.selected then
			for i, v in ipairs( Game.Objects ) do
				if v.type ~= "deckgroup" and v.selected then
					v.dragx = x-v.x
					v.dragy = y-v.y
				end
			end
		end
		self:topDrawOrder()
	end,
	endTouch = function( self, id )
		if self.touched and self.currentTouchID == id then
			self.tapTimer:stop()
			if not self.held and not self.dragged then
				self:onSingleTap()
			end
			local w = 75
			if self.dragged then
				Tweens.Final.ShowCharmsPanel.active = false
				Tweens.Final.HideCharmsPanel.active = true
				if self.x + self.w >= 0 and self.x <= w and self.y + self.h >= 0 and self.y <= w then
					if self.selected then
						for i, v in pairs( Game.Selection ) do
							for k, z in pairs( Game.Objects ) do
								if z.networkID == v then
									z:remove()
								end
							end
						end
					end
					self:remove()
				elseif (not self.selected) and self.x + self.w >= 0 and self.x <= w and self.y + self.h >= love.graphics.getHeight()/2-25 and self.y <= love.graphics.getHeight()/2-25 + w then
					shuffleTable(self.cards)
					if Game.IsAdmin() then
						
						Game.SendToClients("SHUFFLE", {c=self.cards, n = self.networkID, x = self.startdx, y = self.startdy})
						self.gotostart = tween.new(0.3, self, {x = self.startdx, y = self.startdy}, "inOutExpo")
						self.tweenback = true
					
					else
						Game.SendToHost("SHUFFLE", {n = self.networkID, x = self.startdx, y = self.startdy})
					end
				elseif (not self.selected) and self.x + self.w >= 0 and self.x <= w and self.y + self.h >= love.graphics.getHeight()-115 and self.y <= love.graphics.getHeight() -15 then
					Game.Sounds.CardSlide[love.math.random(5,8)]:play()
					if #self.cards == 2 then
						local c1 = self.cards[1]
						local c2 = self.cards[2]
						Game.InitializeCard( c1.suit, c1.value, self.x, self.y, c1.flipped, self.startdx-DeckWidth-2, self.startdy )
						Game.InitializeCard( c2.suit, c2.value, self.x, self.y, c2.flipped, self.startdx+DeckWidth+2, self.startdy )
						self:remove()
						return
					elseif #self.cards == 3 then
						local c1 = self.cards[1]
						Game.InitializeCard( c1.suit, c1.value, self.x, self.y, c1.flipped, self.startdx-DeckWidth-2, self.startdy )
						table.remove(self.cards, 1)
						Game.InitializeDeck(self.x,self.y,self.cards, self.startdx+DeckWidth+2, self.startdy )
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
					Game.InitializeDeck(self.x, self.y, d1, self.startdx-DeckWidth-2, self.startdy)
					Game.InitializeDeck(self.x, self.y, d2, self.startdx+DeckWidth+2, self.startdy)
					self:remove()
					return
				end

				self.dragged = false
				
			end
			Game.Sounds.CardSlide[love.math.random(1,4)]:play()
			self.dragged = false
			self.held = false
			self.touched = false
			self.selected = false
		end
		self.dragged = false
		self.held = false
		self.touched = false
		for i, v in pairs( Game.Objects ) do
			v.dragged = false
			v.selected = false
			v.touched = false
			v.held = false
		end
		love.graphics.setCanvas( Game.SelectionCanvas )
		love.graphics.clear()
		love.graphics.setCanvas()
		Game.Selection = {}
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
	bottomDrawOrder = function( self )
		for i, v in ipairs( Game.Objects ) do
			if v == self then
				table.remove( Game.Objects, i )
				table.insert( Game.Objects, 1, self )
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
	print( self.tweentox, self.x )
	table.insert( Game.Objects, self )
	return self
end

return deck