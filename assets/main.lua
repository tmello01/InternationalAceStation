--[=[


	MAIN FILE
	---------


]=]--

require "ser"

assets = require "assetmanager"

tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"


function love.load()



end

function love.update( dt )



end

function love.draw()



end


if love.system.getOS() == "Windows" then
	function love.mousepressed( x, y, button )

	end

	function love.mousereleased( x, y, button )

	end
else
	function love.touchpressed( id, x, y )

	end

	function love.touchreleased( id, x, y )

	end

	function love.touchmoved( id, x, y )

	end
end