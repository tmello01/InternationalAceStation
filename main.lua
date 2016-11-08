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
ui = require "ui"


function love.load()

	local a = ui.new()
	local t = a:add("text",{text="Test",font=ui.font(25)})

end

function love.update( dt )

	ui.update( dt )

end

function love.draw()

	ui.draw()

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