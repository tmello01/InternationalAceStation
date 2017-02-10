local CardWidth = 38
local CardHeight = 61

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end
local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

local cardTemplate = {
	suit = "any",
	value = "any",
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
	istemplate = true,
	inhand = false,
	tweento = false,
	visible = true,
	firstTouchID = -1,
	lastTouchID = 1,
	currentTouchID = -1,
	touched = false,
	held = false,
	type = "cardTemplate",
	tapTimer = timer.new(0.5),
	getPosition = function( self )
		return self.x, self.y
	end,
	onHold = function( self )

		local cardsToStack = {}
		for i, v in pairs( Game.Objects ) do
			if v ~= self and v.type ~= "deckgroup" then
				if checkCollision(self.x, self.y, self.w, self.h,  v.x, v.y, v.w, v.h) then
					table.insert( cardsToStack, v )
				end
			end
		end
		if #cardsToStack > 0 then
			local cards = {} --a table to pass to the new deck
			for i, v in pairs( cardsToStack ) do
				if v.type == "cardTemplate" then
					table.insert( cards, {
						suit = v.suit,
						value = v.value,
						flipped = v.flipped,
						deckgroup = v.deckgroup
					})
				elseif v.type == "deckTemplate" then
					for k, z in pairs( v.cards ) do
						table.insert( cards, { 
							suit = z.suit,
							value = z.value,
							flipped = z.flipped,
							deckgroup = z.deckgroup,
						})
					end
				end
			end
			table.insert( cards, {
				value = self.value,
				suit = self.suit,
				flipped = self.flipped,
				deckgroup = self.deckgroup,
			})
			print("new deck:",table.serialize(cards))
			deckTemplate:new({x = self.x, y = self.y, cards=cards})
			local sound = love.math.random(1,4)
			Game.Sounds.CardPlace[sound]:stop()
			Game.Sounds.CardPlace[sound]:play()
			for i, v in pairs( cardsToStack ) do
				v:remove()
			end
			self:remove()
			return
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
		if not self.dragged then
			local sound = love.math.random(1,4)
			Game.Sounds.CardSlide[sound]:stop()
			Game.Sounds.CardSlide[sound]:play()

		end
		self.dragged = true
		self.x = x-self.dragx
		self.y = y-self.dragy
		if self.x < love.graphics.getWidth()/4 then
			if not SHOWCHARMS then
				SHOWCHARMS = true
				SHOWDECKCHARMS = false
				Tweens.Final.HideCharmsPanel.t:reset()
				Tweens.Final.ShowCharmsPanel.active = true
				Tweens.Final.HideCharmsPanel.active = false
			end
		else
			SHOWDECKCHARMS = false

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
			if self.tweento then
				if self.tweentotween:update( dt ) then
					self.tweento = false
				end
			end
		end
	end,
	draw = function( self )
		if self.visible then
			if not self.flipped then
				if self.suit ~= "any" then
					love.graphics.draw( Cards[self.suit][self.value], self.x, self.y, 0, 2, 2 )
				else
					love.graphics.draw( Cards.backs.blank, self.x, self.y, 0, 2, 2 )
				end
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
			local sound = love.math.random(1,4)
			Game.Sounds.CardSlide[sound]:stop()
			Game.Sounds.CardSlide[sound]:play()
			self.tapTimer:stop()
			if not self.held and not self.dragged then
				self:onSingleTap()
			end
			local w = 75

			Tweens.Final.ShowCharmsPanel.active = false
			Tweens.Final.HideCharmsPanel.active = true
			if self.dragged then

				if self.x + self.w >= 0 and self.x <= w and self.y + self.h >= 0 and self.y <= w then
					self:remove()
					SHOWCHARMS = false
				elseif self.x + self.w >= 0 and self.x <= w and self.y + self.h >= love.graphics.getHeight()/2-25 and self.y <= love.graphics.getHeight()/2-25 + w then

				end
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
cardTemplate.__index = cardTemplate

function cardTemplate:new( data )
	print( "[cardTemplate] Making new cardTemplate..." )
	local data = data or { }
	local self = setmetatable(data, cardTemplate)
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

return cardTemplate