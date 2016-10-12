local path = ...

local Card = {
	type = "Card",
	id = "S1",

	fixTexture = function(self, id)
		self.id = id or self.id
		self.texture = textures[self.id]
	end,
	onTap = function( self, id, x, y )
		print('ONE TAP')
		local st = { }
		for i, v in pairs( objects.getAll() ) do
			print( "V: " .. v.x .. "," .. v.y )
			print( "SELF: " .. self.x .. "," .. self.y )
			if self.x >= v.x and self.x <= v.x + v.w and self.y >= v.y and self.y <= v.y + v.h then
				if v ~= self then
					st[#st+1] = v.type or "Blank"
					v:delete()
				end
			end
		end
		objects.new("Stack", {x=self.x, y=self.y, cards=st})
		self:delete()
	end,
	onHold = function( self, id, x, y )
		if not self.locked then
			self.lockId = id
			self.locked = true
			self.dx = x - self.x
			self.dy = y - self.y
		end
	end,
	onHoldRelease = function( self, id, x, y )
		if self.locked then
			self.lockId = -1
			self.locked = false
			self.dx = 0
			self.dy = 0
		end
	end,
	onDoubleTap = function( self, id, x, y )

	end,

	w = 38,
	h = 61,

	texture = textures["blank"]

}
Card.__index = Card

return Card