sock = require "sock"
bitser = require "bitser"

serverInfo{yourname .. " " .. currentPort}

function loadserver()
	servername = yourname

	server = sock.newServer("127.0.0.1", currentPort)
	currentPort = currentPort + 1
	server:sendToAll(servername, currentPort)
end

function love.update( dt )
	server:update( dt )
end