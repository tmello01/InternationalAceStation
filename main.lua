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

--Simon was here 2k17--

require "ser"

assets = require "assetmanager"

tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"
ui = require "ui"
card = require "assets/card"
timer = require "timer"

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

Cards = {}
for i, v in pairs( love.filesystem.getDirectoryItems( "assets/images/cards/" ) ) do
	Cards[v] = {}
	for k, z in pairs( love.filesystem.getDirectoryItems( "assets/images/cards/" .. v ) ) do
		Cards[v][z:sub(1,-5)] = love.graphics.newImage( "assets/images/cards/" .. v .. "/" .. z )
		Cards[v][z:sub(1,-5)]:setFilter("nearest", "nearest")
	end
end

WindowsTouchID = os.clock()

--ADD MATH.CLAMP FUNCTION--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


function love.load()
	
	local suits = { "diamonds", "clubs", "hearts", "spades" }
	
	MainPanel = ui.new({y=500, h = 100, w = 800})
	NewButton = MainPanel:add("button", {y=500, w= 100, text="Add Card", background={13,71,161}})
	NewButton.onclick = function()
		card:new({suit=suits[love.math.random(1,4)], value=tostring(love.math.random(2,10)),x = love.math.random(0,200), y = love.math.random(0,200)})
	end
	ClearButton = MainPanel:add("button", {y=500, x=100, w=100, background = {198, 40, 40}, text="Clear"})
	ClearButton.onclick = function()
		Game.Objects = {
			Decks = {},
			Cards = {},
			Chips = {},
			ChipStacks = {},
		}
	end
end

function love.update( dt )

	ui.update( dt )
	if Windows then
		if touch.hasTouch(WindowsTouchID) then
			local x, y = love.mouse.getPosition()
			touch.updatePosition(WindowsTouchID, x, y)
		end
	end
	
	for _, Group in pairs( Game.Objects ) do
		for i, v in pairs( Group ) do
			if v.update then v:update( dt ) end
		end
	end

end

function love.draw()

	ui.draw()
	for _, Group in pairs( Game.Objects ) do
		for i, v in pairs( Group ) do
			if v.draw then v:draw() end
		end
	end
end


if Windows then
	function love.mousepressed( x, y, button )
		WindowsTouchID = os.clock()
		ui.mousepressed( x, y, button )
		touch.new( WindowsTouchID, x, y )
	end

	function love.mousereleased( x, y, button )
		ui.mousereleased( x, y, button )
		touch.remove( WindowsTouchID, x, y )
	end
else
	function love.touchpressed( id, x, y )
		WindowsTouchID = os.clock()
		touch.new( WindowsTouchID, x, y )
		ui.mousepressed( x, y, 1 )
	end

	function love.touchreleased( id, x, y )
		touch.remove( WindowsTouchID, x, y )
		ui.mousereleased( x, y, 1 )
	end

	function love.touchmoved( id, x, y )
		touch.updatePosition( WindowsTouchID, x, y )
	end
end

function love.keyreleased( key )
	if key == "n" then
		local suits = { "diamonds", "clubs", "hearts", "spades" }
		card:new({suit=suits[love.math.random(1,4)], value=tostring(love.math.random(2,10)),x = love.math.random(0,200), y = love.math.random(0,200)})
	end
end