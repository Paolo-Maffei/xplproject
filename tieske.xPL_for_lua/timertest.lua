require("socket")
require("copas")
require("copastimer")
require("xpl")
require("base")

local port = 51035
local host = socket.dns.gethostname()
local sysip, sysdata = socket.dns.toip(host)
local server = socket.udp()
server:setsockname("*",port)

function sendhbeat()
	local hb = "xpl-stat\n{\nhop=1\nsource=tieske-luatest.copas\ntarget=*\n}\nhbeat.app\n{\ninterval=5\nport=%s\nremote-ip=%s\n}\n"
    local msg = string.format(hb, tostring(port), sysip)
    xpl.send(msg)
end


function handler(skt)
	skt = copas.wrap(skt)
	print("UDP connection handler")

	while true do
		local s, err
		print("receiving...")
		s, err = skt:receive(2048)
		if not s then
			print("Receive error: ", err)
			return
		end
		print("Received xPL message, bytes:" , #s)
        print (s)
	end
end


local steptimeout = 1/4

copas.addserver(server, handler, 1)
sendhbeat()

local lasttime
local f = function()
	if lasttime then
		print ("round-trip in : " .. socket.gettime() - lasttime .. " seconds")
	end
	lasttime = socket.gettime()
	--print ("iets" .. bestaatniet )
end
local errh = function(...)
	print("Error: ",  ... )
end
local t = copas.timer.create(function () print("I'm armed (not dangerous)") end,
                             f,
							 function () print("I'm cancelled") end,
							 true,
							 errh)
t:arm(1)
copas.timer.create(nil, function ()
										print ("now leaving...")
										t:cancel()
										copas.timer.isexiting = true
									end, nil, false):arm(20)

-- start it up
print ("starting loop")
copas.timer.loop(steptimeout)
print ("loop ended")
