--[=[

	MAIN FILE
	---------

	Special thanks to Simon Rahnasto for all his help. :)

	Programmed by Eric Bernard and Tyler Mello. 
	Art by Armen Eghian, Justin Stevens, Dylan Ross, Lore Bellavance, and Alex Mullin	

]=]--



require "ser"

tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"
ui = require "ui"
require "menus"
card = require "assets/card"
deck = require "assets/deck"
deckTemplate = require "assets/deckTemplate"
cardTemplate = require "assets/cardTemplate"
utf8 = require "utf8"
local Windows = love.system.getOS() == "Windows"


ui.state = "Menu"
--Creates table for server information, to be used by servercreate.lua

SHOWCHARMS = false

Game = {
	Objects = {},
	Zones = {},
	Players = {},
	Globals = {
		Gamestate = "Table",
		CardWidth = 38,
		CardHeight = 61,
	},
	Images = {
		Trash = love.graphics.newImage("assets/images/trash.png"),
		Shuffle = love.graphics.newImage("assets/images/shuffle.png"),
		Split = love.graphics.newImage("assets/images/split.png")
	},
	Sounds = {
		ButtonForward = love.audio.newSource("assets/sounds/button-forward.wav"),
		ButtonBackward = love.audio.newSource("assets/sounds/button-backward.wav"),
		ButtonNew = love.audio.newSource("assets/sounds/button-high.wav"),
		CardPlace = {
			love.audio.newSource("assets/sounds/cardPlace1.wav"),
			love.audio.newSource("assets/sounds/cardPlace2.wav"),
			love.audio.newSource("assets/sounds/cardPlace3.wav"),
			love.audio.newSource("assets/sounds/cardPlace4.wav"),
		},
		CardSlide = {
			love.audio.newSource("assets/sounds/cardSlide1.wav"),
			love.audio.newSource("assets/sounds/cardSlide2.wav"),
			love.audio.newSource("assets/sounds/cardSlide3.wav"),
			love.audio.newSource("assets/sounds/cardSlide4.wav"),
			love.audio.newSource("assets/sounds/cardSlide5.wav"),
			love.audio.newSource("assets/sounds/cardSlide6.wav"),
			love.audio.newSource("assets/sounds/cardSlide7.wav"),
			love.audio.newSource("assets/sounds/cardSlide8.wav"),
		},
	},
	Scale = {
		x = 1280/love.graphics.getWidth(),
		y = 720/love.graphics.getHeight()
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


DeckPresets = {
	Standard52Deck = {
		diamonds = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		spades = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		hearts = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		clubs = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	SpadesOnly = {
		spades = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	ClubsOnly = {
		clubs = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	HeartsOnly = {
		hearts = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	DiamondsOnly = {
		diamonds = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
}


WindowsTouchID = os.clock()

--Random useful functions--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end
function hex2rgb(hex)
    hex = hex:gsub("#","")
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
end
function string.split (str, sep) -- Split string
	local return_array = {}
	for v in string.gmatch(str, "([^"..sep.."]+)") do
		return_array[#return_array+1] = v
	end
	return return_array
end
function string.fromHex (str) -- FF32FF32 -> string
	local nStr = ""
	for i=1, #str/2 do
		local nDex = (i-1)*2
		local nnStr = string.char(tonumber(str:sub(nDex+1,nDex+2),16))
		nStr=nStr..nnStr
	end
	return nStr
end

--Load font awesome dictionary
dictionaryContents = require("fontAwesome") -- Place in the dictionary or load it from a file. Whichever works best.
dictLines = string.split(dictionaryContents,"\n") -- You can get a string splitting function from stack overflow for lua.
fontAwesome = {}
for i=1, #dictLines do
	local lineSplit = string.split(dictLines[i],":")
	fontAwesome[lineSplit[1]]=string.fromHex(lineSplit[2])
end



love.graphics.setBackgroundColor( hex2rgb("#2E7D32") )

function love.load()
	
	makeMenus()

	Tweens = {
		Data = {
			ShowAdminPanel = {
				x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
			},
			HideAdminPanel = {
				x = love.graphics.getWidth()*.75
			},
			ShowCharmsPanel = {
				x = -75,
			},
			HideCharmsPanel = {
				x = 0,
			}
		}
	}

	Tweens.Final = {
		ShowAdminPanel = {
			active = false,
			t = tween.new( 0.5, Tweens.Data.ShowAdminPanel, {x=love.graphics.getWidth()*.75}, "inOutExpo"),
			oncomplete = function()
				Tweens.Data.ShowAdminPanel.x = 0
				AdminPanel.x = love.graphics.getWidth()*.75
			end,
		},
		HideAdminPanel = {
			active = false,
			t = tween.new( 0.5, Tweens.Data.HideAdminPanel, {x=love.graphics.getWidth()-love.graphics.getWidth()*0.075}, "inOutExpo"),
			oncomplete = function()
				Tweens.Data.HideAdminPanel.x = 0
				AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
			end,
		},
		ShowCharmsPanel = {
			active = false,
			t = tween.new(0.4, Tweens.Data.ShowCharmsPanel, {x=0}, "inOutExpo"),
			oncomplete = function()
				Tweens.Data.ShowCharmsPanel.x = 0
			end
		},
		HideCharmsPanel = {
			active = false,
			t = tween.new(0.4, Tweens.Data.HideCharmsPanel, {x=-75}, "inOutExpo"),
			oncomplete = function()
				Tweens.Data.HideCharmsPanel.x = 0

				SHOWCHARMS = false
			end
		}
	}

end

function love.update( dt )

	ui.update( dt )
	if Windows then
		if touch.hasTouch(WindowsTouchID) then
			local x, y = love.mouse.getPosition()
			touch.updatePosition(WindowsTouchID, x, y)
		end
	end

	for i, v in pairs( Tweens.Final ) do
		if v.active then
			if v.t:update( dt ) then
				if v.oncomplete then v.oncomplete() end
				v.active = false
				v.t:reset()
			end
		end
	end
	if AdminPanel.substate == "Hidden" and Tweens.Final.HideAdminPanel.active then
		AdminPanel.x = Tweens.Data.HideAdminPanel.x
	elseif AdminPanel.substate == "Main" and Tweens.Final.ShowAdminPanel.active then
		AdminPanel.x = Tweens.Data.ShowAdminPanel.x
	end

	for _, v in pairs( Game.Objects ) do
		if v.update then v:update(dt) end
	end

end
--don't judge
function love.textinput( t )
   ui.textinput( t )
end

function love.keyreleased( key )
	ui.keyreleased( key )
end
function love.keypressed( key )
	ui.keypressed( key )
end
function love.draw()
	if SHOWCHARMS then
		local x = 0
		if Tweens.Final.ShowCharmsPanel.active then
			x = Tweens.Data.ShowCharmsPanel.x
		elseif Tweens.Final.HideCharmsPanel.active then

			print("Test")
			x = Tweens.Data.HideCharmsPanel.x
		end
		love.graphics.setColor(42, 42, 42)
		love.graphics.rectangle("fill", x, 0, 75, love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(ui.font(50, "FontAwesome"))
		love.graphics.print(fontAwesome['fa-trash-o'], 15+x, 15 )
		if SHOWDECKCHARMS then
			love.graphics.print(fontAwesome['fa-random'], 15+x, love.graphics.getHeight()/2-35)
			love.graphics.print(fontAwesome['fa-arrows-h'], 15+x, love.graphics.getHeight()-95)
		end
		--love.graphics.draw( Game.Images.Trash, 15, 15, 0, 0.5, 0.5 )
		--love.graphics.draw( Game.Images.Shuffle, 15, love.graphics.getHeight()/2-25, 0, 0.5, 0.5 )
		--love.graphics.draw( Game.Images.Split, 15, love.graphics.getHeight() - 115, 0, 0.5, 0.5 )
	end
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