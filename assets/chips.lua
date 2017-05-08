local chipWidth = 19
local chipHeight = 19

local function checkChipCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

local chip {
	chipColor= "white"
	value = "1",
	x = 0,
	y = 0,
	w = CardWidth,
	h = CardHeight,
	visible = true,
	dragx = 0,
	dragy = 0,
	dragged = false,
	inhand = false,
	tweento = false,
	firstTouchID = -1,
	lastTouchID = 1,
	currentTouchID = -1,
	selected = false,
	touched = false,
	held = false,
	type = "chip",
	tapTimer = timer.new(0.5),

    getPosition = function( self )
		return self.x, self.y
	end,
	--sigh
	onHold = function( self )
		
		local chipsToStack = {}
		for i, v in pairs( Game.Objects ) do
			if v ~= self then
				if checkCollision(self.x, self.y, self.w, self.h,  v.x, v.y, v.w, v.h) then
					table.insert( chipsToStack, v )
				end
			end
		end
		if #chipsToStack > 0 then
			local chips = {} 
			for i, v in pairs( chipsToStack ) do
				if v.type == "chip" then
					table.insert( chips, {
						chipColor = v.chipcolor,
						value = v.value,
					})
				elseif v.type == "stack" then
					for k, z in pairs( v.chips ) do
						table.insert( chips, { 
						chipColor = z.chipcolor,
						value = z.value,
						})
					end
				end
			end
			table.insert( cards, {
				value = self.value,
				suit = self.suit,
				flipped = self.flipped
			})
			stack:new({x = self.x, y = self.y, cards=cards})
			local sound = love.math.random(1,4)
			Game.Sounds.CardPlace[sound]:stop()
			Game.Sounds.CardPlace[sound]:play()
			for i, v in pairs( chipsToStack ) do
				v:remove()
			end
			self:remove()
			return
		end
	end,

	remove = function( self, noskip )
		for i, v in pairs( Game.Objects ) do
			if v == self then
				table.remove( Game.Objects, i )
				if not noskip then
					break
				end
			end
		end
		return
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
		if self.selected then
			for i, v in pairs( Game.Objects ) do
				if v ~= self and v.selected then
					if not v.dragged then
						v.dragged = true
					else
						v.x = x-v.dragx
						v.y = y-v.dragy
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
			if self.tweento then
				if self.tweentotween:update( dt ) then
					self.tweento = false
				end
			end
		end
		return
	end,

	startTouch = function( self, id, x, y, skipUpdate )
	
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
					
				else
					--v:bottomDrawOrder()
				end
			end
		end
		if not skipUpdate then
			self:topDrawOrder()
		end
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
					if self.selected then
						--[[for i = 1, #Game.Objects do
							if Game.Objects[i].type ~= "deckgroup" and Game.Objects[i] ~= self then
								if Game.Objects[i].selected then
									table.remove(Game.Objects, i)
								end
							end
						end
						for i, v in pairs( Game.Objects ) do
							if v.type ~= "deckgroup" and v ~= self and v.selected then
								table.remove(Game.Objects, i)
							end
						end--]]
					end
					self:remove()
					SHOWCHARMS = false
				end
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
		end
	end,
	cancelTouchManager = function( self, id )
		if self.touched then
			self.tapTimer:stop()
		end
	end,
	
	function card:new( data )
		local data = data or { }
		local self = setmetatable(data, card)
		self.__index = self
		
		if self.tweentox or self.tweentoy then
			self.tweentox = self.tweentox or self.x
			self.tweentoy = self.tweentoy or self.y
			self.tweento = true
			self.tweentotween = tween.new(0.2, self, {x = self.tweentox, y = self.tweentoy}, "inOutExpo")
		end
		table.insert( Game.Objects, self )
		
		self:topDrawOrder()


		return self
	end
}