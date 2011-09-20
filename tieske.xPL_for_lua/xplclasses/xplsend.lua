-- xPL message sender
-- Copyright 2011 Thijs Schreijer

socket = require ("socket")

local send = function (msg)

	local skt, emsg = socket.udp()			-- create and prepair socket
	assert (skt, "failed to create UDP socket; " .. emsg)

	skt:settimeout(1)
	skt:setoption("broadcast", true)

	local success, emsg = skt:sendto(msg, xpl.settings.broadcast, xpl.settings.xplport)
	assert (success, "Failed to send message over UDP socket; " .. emsg)
end

return send
