local socket = require "socket"

local udp = socket.udp()

udp.settimeout(0)

udp.setsocketname('*', 11111)

local data, msg_or_ip, port_or_nil
local entity, cmd, parms

local running = true

print "beginning server loop."

while running do

	data, msg_or_ip, port_or_nil = udp:receivefrom()

	if cmd == 'move' then
		local x, y = parms


end