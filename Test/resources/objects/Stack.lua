local path = ...

local Stack = {
	
	onTap = function( self, id, x, y )

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

	w = 32,
	h = 32,

	texture = textures['deck'],

	cards = {

	}

}
Stack.__index = Stack

return Stack