local CardWidth = 38
local CardHeight = 61

local card = {
	suit = "diamond",
	value = 2,
	texture = "diamond2",
	--texture = Textures['diamond/1.png'],
	x = 0,
	y = 0,
	w = CardWidth,
	h = CardHeight,
	visible = true,
	dragx = 0,
	dragy = 0,
	inDeck = false,
	visible = true,
	getPosition = function( self )
		return self.x, self.y
	end,
	onHold = function( self )
		
	end,
	onTap = function( self )
		
	end,
	onDoubleTap = function( self )
		
	end,
	startDrag = function( self, x, y )
		
	end,
	remove = function( self )
		
	end,
	draw = function( self )
		if self.visible then
			
		end
	end,
	update = function( self, dt )
		
	end,
	
	
}
card.__index = card

function card:new( data )
	print( "[card] Making new card..." )
	local data = data or { }
	local self = setmetatable(data, card)
	self.__index = self
	
	table.insert( Game.Objects.Cards, self )
	Game.UpdateSpritebatch()
	
	return self
end

return card