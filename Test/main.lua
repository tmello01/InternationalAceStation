require "ser"

--LOAD TEXTURES--
textures = { }
local function getTextures( dir )
	for i, v in pairs( love.filesystem.getDirectoryItems(dir) ) do
		if love.filesystem.isDirectory( dir .. "/" .. v ) then
			getTextures( dir .. "/" .. v )
		else
			textures[v:sub(1,-5)] = love.graphics.newImage( dir .. "/" ..v )
			textures[v:sub(1,-5)]:setFilter("nearest", "nearest")
			print( "[texture-handler] Loading image \"" .. v .. "\" to \"" ..v:sub(1,-5).."\" ... [OK]")
		end
	end
end
getTextures("resources/img")

timer = require "timer"

touches = require "touch"
objects = require "object"

function love.load()

	objects.new("Stack", {x=10,y=10})
	objects.new("Card", {x=100,y=10, texture=textures["S7"]})
	objects.new("Card", {x=10,y=100, texture=textures["S3"]})
	objects.new("Card", {x=100,y=100, texture=textures["S4"]})
	objects.new("Card", {x=200,y=10, texture=textures["S6"]})
	objects.new("Card", {x=10,y=200, texture=textures["S2"]})
	objects.new("Card", {x=200,y=200, texture=textures["S5"]})

end

function love.update( dt )

	UPDATE_TIMERS( dt )
	UPDATE_TOUCH( dt )
	objects.update( dt )
	love.touchmoved(100, love.mouse.getX(), love.mouse.getY())

end

function love.draw( )

	DRAW_TOUCH()
	objects.draw()

end

if love.system.getOS() == "Windows" then
	function love.mousepressed( x, y )
		love.touchpressed( 100, x, y )
	end

	function love.mousereleased( x, y )
		love.touchreleased( 100, x, y )
	end
end

function love.touchpressed( id, x, y )

	NEW_TOUCH( id, x, y )

end

function love.touchreleased( id, x, y )

	DEL_TOUCH( id, x, y )
	
end

function love.touchmoved( id, x, y )

	
	MOVE_TOUCH( id, x, y )

end