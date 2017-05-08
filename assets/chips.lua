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
}