--[=[


	MAIN FILE
	---------
	The **Game** table is for global things, like decks and cards.
	**Game**
		+ Objects
			+ Decks
			+ Cards
			+ Chips
			+ ChipStacks
			
		+ Zones
		+ Players
		+ Globals
]=]--



require "ser"

assets = require "assetmanager"

tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"
ui = require "ui"
card = require "assets/card"
timer = require "timer"
touchmanager = require "touchmanager"

local Windows = love.system.getOS() == "Windows"


Tileset = love.graphics.newImage("assets/images/cards.png")
Tileset:setFilter("nearest", "nearest")

Game = {
	Objects = {
		Decks = {},
		Cards = {},
		Chips = {},
		ChipStacks = {},
	},
	Zones = {},
	Players = {},
	Globals = {
		Gamestate = "Table",
		CardWidth = 38,
		CardHeight = 61,
	},
	Spritebatch = love.graphics.newSpriteBatch(Tileset, 5000),
	
	UpdateSpritebatch = function()
		Game.Spritebatch:clear()
		for i, v in pairs( Game.Objects ) do
			for k, z in pairs( v ) do
				if z.texture and TextureQuads[ z.texture ] then
					Game.Spritebatch:add( TextureQuads[ z.texture ], z.x, z.y, 0, 2, 2 )
				end
			end
		end
	end,
	
	
	getState = function() return Game.Globals.Gamestate end,
}

SpriteBatchLookup = {
	[0] = {
		"spade2", "spade3", "spade4", "spade5", "spade6", "spade7", "spade8", "spade9", "spade10", "spadeA", "spadeJ", "spadeQ", "spadeK",
	},
	[61] = {
		"club2", "club3", "club4", "club5", "club6", "club7", "club8", "club9", "club10", "clubA", "clubJ", "clubQ", "clubK",
	},
	[122] = {
		"heart2", "heart3", "heart4", "heart5", "heart6", "heart7", "heart8", "heart9", "heart10", "heartA", "heartJ", "heartQ", "heartK"
	},
	[183] = {
		"diamond2", "diamond3", "diamond4", "diamond5", "diamond6", "diamond7", "diamond8", "diamond9", "diamond10", "diamondA", "diamondJ", "diamondQ", "diamondK",
	},
	[244] = {
		"earthback", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"
	},
}
TextureQuads = {}
for y, b in pairs( SpriteBatchLookup ) do
	for x, k  in pairs( b ) do
		TextureQuads[ k ] = love.graphics.newQuad( (x-1)*Game.Globals.CardWidth, y, Game.Globals.CardWidth, Game.Globals.CardHeight, Tileset:getWidth(), Tileset:getHeight() )
	end
end

--ADD MATH.CLAMP FUNCTION--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


function love.load()

	newcard = card:new()

end

function love.update( dt )

	ui.update( dt )
	touchmanager.update( dt )
	if Windows then
		if touch.hasTouch(100) then
			local x, y = love.mouse.getPosition()
			touch.updatePosition(100, x, y)
		end
	end

end

function love.draw()

	ui.draw()
	
	--Draw cards--
	love.graphics.draw( Game.Spritebatch )

end


if Windows then
	function love.mousepressed( x, y, button )
		ui.mousepressed( x, y, button )
		touch.new( 100, x, y )
	end

	function love.mousereleased( x, y, button )
		ui.mousereleased( x, y, button )
		touch.remove( 100, x, y )
	end
else
	function love.touchpressed( id, x, y )

	end

	function love.touchreleased( id, x, y )

	end

	function love.touchmoved( id, x, y )

	end
end