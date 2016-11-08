--[=[


	MAIN FILE
	---------


]=]--


--ADD MATH.CLAMP FUNCTION--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

require "ser"

assets = require "assetmanager"

tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"
ui = require "ui"


function love.load()

	local a = ui.new()
	local t = a:add("button",{text="Exit",font=ui.font(20)})
	function t:onclick()
		love.event.quit()
	end

end

function love.update( dt )

	ui.update( dt )

end

function love.draw()

	ui.draw()

end


if love.system.getOS() == "Windows" then
	function love.mousepressed( x, y, button )
		ui.mousepressed( x, y, button )
	end

	function love.mousereleased( x, y, button )
		ui.mousereleased( x, y, button )
	end
else
	function love.touchpressed( id, x, y )

	end

	function love.touchreleased( id, x, y )

	end

	function love.touchmoved( id, x, y )

	end
end