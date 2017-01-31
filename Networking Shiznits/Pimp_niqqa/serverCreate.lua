local sock = require "sock"




function loadserver()
	server = sock.newServer("127.0.0.1", 22122)
	
end