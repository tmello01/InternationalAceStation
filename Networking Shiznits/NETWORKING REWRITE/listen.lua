local sock = require "socket"

--Opens a udp socket, and begins listening for servers on specified port 
local function findServer()
	local newServers = []
	local listen = socket.udp()

	local name