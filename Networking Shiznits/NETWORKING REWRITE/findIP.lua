local socket = require "socket"

local getIP = function()
	local s = socket.udp()
	s:setpeername("74.125.115.104", 80)
	local ip, sock = s:getsockname()
	print("myIP:", ip, sock)
	return ip
end