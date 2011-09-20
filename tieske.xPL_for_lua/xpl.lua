
----------------------------------------------------------------
-- define global tables for xPL related functions and settings
----------------------------------------------------------------
xpl = xpl or {}
xpl.classes = xpl.classes or {}
xpl.settings = {
	_DEBUG = true,					-- will run any tests at startup
	listenon = "ANY_LOCAL",			-- ANY_LOCAL (any local adapter) or a specific IP address
	listento = { "ANY_LOCAL" },		-- ANY_LOCAL (peers within same subnet) or table with IP addresses
	broadcast = "255.255.255.255",	-- to whom to broadcast outgoing messages
	xplport = 3865,					-- standard xPL port to send to
}

----------------------------------------------------------------
-- define constants for several capture patterns
----------------------------------------------------------------

	-- pattern to return the three elements of an address, no wildcards allowed
	xpl.CAP_ADDRESS = "([%l%u%d]+)[%-]([%l%u%d]+)%.([%l%u%d%-]+)"

	-- pattern to return the 6 elements of an xPL filter, wildcards are allowed, and the '-' instead of a '.' between vendor and device is also supported (special case)
	xpl.CAP_FILTER = "([%l%u%-%*]+)%.([%l%u%d%*]+)[%.%-]([%l%u%d%*]+)%.([%l%u%d%-%*]+)%.([%l%u%d%-%*]+)%.([%l%u%d%-%*]+)"

	-- pattern that returns the header information, with body and the remaining string (the remaining string can be used for the next iteration)
	xpl.CAP_MESSAGE = "(xpl%-[%l%u]+)\n{\nhop=(%d+)\nsource=([%l%u%d%-%.]+)\ntarget=([%l%u%d%-%.%*]+)\n}\n([%l%u%d%-]+%.[%l%u%d%-]+)\n{\n(.-\n)}\n(.*)"

	-- pattern that captures a key-value pair (must end with \n), and the remaining string (the remaining string can be used for the next iteration)
	xpl.CAP_KEYVALUE = "([%l%u%d%-]+)=(.-)\n(.*)"


----------------------------------------------------------------
-- load xpl related classes, functions and modules
----------------------------------------------------------------

	-- load classes
	xpl.classes.xplfilters = require ("xplclasses.xplfilter")
	xpl.classes.xpldevice = require ("xplclasses.xpldevice")
	xpl.classes.xplmessage = require ("xplclasses.xplmessage")

	-- load generic functions
	xpl.send = require("xplclasses.xplsend")



----------------------------------------------------------------
-- tests for xPLbase
----------------------------------------------------------------

if xpl.settings._DEBUG then
	print ("Testing capture patterns")

	print ("   Address: ", string.match("tieske-device.instance", xpl.CAP_ADDRESS))
	print ("   Filter1 : ", string.match("xpl-cmnd.tieske-device.instance.schema.class", xpl.CAP_FILTER))
	print ("   Filter2 : ", string.match("*.*.*.*.*.*", xpl.CAP_FILTER))
	local msg = "xpl-cmnd\n{\nhop=2\nsource=tieske-dev.inst\ntarget=*\n}\nschema.class\n{\nmy-key=some=value in=the=list\nsecond-key=some other value\nonemore=last one in the line\n}\n"
	msg = msg .. msg
	local cnt = 0
	while msg do
		local tpe, hop, source, target, schema, body
		tpe, hop, source, target, schema, body, msg = string.match(msg, xpl.CAP_MESSAGE)
		if not tpe then break end	-- no more found, exit loop
		cnt = cnt + 1
		print ("   Found a message " .. cnt)
		print("   ", tpe)
		print("   ", hop)
		print("   ", source)
		print("   ", target)
		print("   ", schema)
		print("   Body: ", body)
		while body do
			local key, value
			key, value, body = string.match(body,xpl.CAP_KEYVALUE)
			if not key then break end -- no more found, exit loop
			print ("        ", key, "=", value)
		end
		print()
	end
	print ("Testing capture patterns - end")
end

return xpl
