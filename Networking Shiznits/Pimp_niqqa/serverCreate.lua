local sock = require "sock"




function loadserver()
	servername = yourname

	server = sock.newServer("127.0.0.1", 22122)
	
end

function love.update( dt )
	server:update( dt )
end