-- xPL library, copyright 2011, Thijs Schreijer
--
--


socket = require("socket")
copas = require("copas")

xpldevice = {

	address = "tieske-mydev.instance",
	filters = { "*.*.*.*.*.*"}   	-- filter list = [msgtype].[vendor].[device].[instance].[class].[type]

	start = function ()
	end,

	stop = function ()
	end,
}

return xpldevice
