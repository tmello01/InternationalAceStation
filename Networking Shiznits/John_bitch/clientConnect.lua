local sock = require "sock"

function connectToServer()
	client = sock.newClient("127.0.0.1", 22122)

	client:on("connect", function(data)
		print(yourname .. " have successfully connected to " .. servername .. "'s server.")
	end)

	client:on("disconnect", function(data)
        print(yourname .. " has disconnected from the server.")
    end)

    client:connect()
end