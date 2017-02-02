sock = require "sock"
bitser = require "bitser"
local count = 1
local servernum = 0

love.graphics.print("Searching for servers...Please wait")



while (count <= 10) do
	
	client = sock.newClient("127.0.0.1", currentPort)
	client:connect()
	client:update()
	if (client:getState() == connecting or client:getState() == connection_pending or client:getState() == connection_succeeded or client:getState() == acknowledging_connect) do
	x = servernum
	local storage = 
	serverInfo{client:get}

	end
	servernum = servernum + 1
	count = count + 1
end
