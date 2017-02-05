local socket = require("socket")

--This part down here is for advertising the server
function advertiseServer do
	local send = socket.udp()
	--Tells it how long to look for until moving on. It's set to 0 basically means "oh there's nothing here. I'm not going to waste my time. I'm moving on"
	
	send:settimeout( 0 )

	local stop

	local counter = 0

	local function broadcast()
		local msg = "You've connected to " .. yourname .. "'s server!"
		send:sendto(msg, "localhost", 11111)

		send:setoption("broadcast", true)
		send:sendto(msg, "255.255.255.255", 11111)
		send:setoption("broadcast", false)

		counter = counter+1
		if (coutner == 80) then
			stop()
		end
	end

	local serverBroadcast = timer.performWithDelay(100, broadcast, 0)

	--something here, probably a "quit" button to stop the player from looking for servers. The code below this will go into that button.
		timer.cancel(serverBroadcast)



