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
deck = require "assets/deck"
timer = require "timer"
local Windows = love.system.getOS() == "Windows"

--Creates table for server information, to be used by servercreate.lua



Game = {
	Objects = {},
	Zones = {},
	Players = {},
	Globals = {
		Gamestate = "Table",
		CardWidth = 38,
		CardHeight = 61,
	},
	
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

love.graphics.setBackgroundColor( 255, 255, 0 )

WindowsTouchID = os.clock()

--ADD MATH.CLAMP FUNCTION--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


function love.load()
	
	local suits = { "diamonds", "clubs", "hearts", "spades" }
	local PanelW = love.graphics.getWidth()/4
	AdminPanel = ui.new({w=PanelW, h = love.graphics.getHeight(), x = love.graphics.getWidth()-PanelW})
	AdminPanel:add("text", {text = "MANAGE GAME", align="center", y=10, font = ui.font(22)})
	AdminPanel:add("text", {text = "Add Items", align="center", y = 55, font = ui.font(16)})
	NewCardButton = AdminPanel:add("button", {
		w = math.floor(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		y = 80,
		background = {33,150,243},
		foreground = {255, 255, 255},
		text = "Card",
	})
	NewCardButton.onclick = function()
		card:new({
			x = love.math.random(0, love.graphics.getWidth()-50),
			y = love.math.random(0, love.graphics.getHeight()-100),
			suit = suits[love.math.random(1,4)],
			value = tostring(love.math.random(2,10)),
		})
	end
	NewDeckButton = AdminPanel:add("button", {
		x = math.ceil(AdminPanel.w/2),
		y = 80,
		w = math.floor(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		background = {56, 142, 60},
		foreground = {255, 255, 255},
		text = "Deck",
	})
	NewDeckButton.onclick = function()

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
	
	for _, v in pairs( Game.Objects ) do
		if v.update then v:update(dt) end
	end

end
--don't judge
function love.textinput( t )
   text = text .. t
end

function love.keyreleased( key )
   if key == "return" then
      yourname = text
      text = ""
   end
end
function love.keypressed( key )
   if key == "backspace" then
      text = text:sub(1,-2)
   end
end
function love.draw()

	for i, v in pairs( Game.Objects ) do
		if v.draw then v:draw() end
	end
	ui.draw()
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
		touch.remove( 100, x, y )
	end
end