--[[

This file is an xPL message handler to remove events based on device heartbeat
and configuration messages. These messages usually have little value in everyday use.

All this handler does is stop the xPLGirder component from raising events for these
messages. To change its behaviour, adjust the filter below.



=================================================================================================
(c) Copyright 2011 Richard A Fox Jr., Thijs Schreijer

This file is part of xPLGirder.

xPLGirder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

xPLGirder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with xPLGirder.  If not, see <http://www.gnu.org/licenses/>.

See the accompanying ReadMe.txt file for additional information.
=================================================================================================

]]--


local xPLEventDevice = 10124	-- when raising events, use this as source to set it to xPLGirder


local myNewHandler = {

	ID = "RemoveHbeatAndConfig",		-- enter a unique string to identify this handler



	--[[
	first define a list of filters to trigger the message handler. Any filter that has a positive
	match will trigger the handler. Each Handler will be called once per message, so if this handler
	has 2 filters that match, only the first will call the handler.

	a filter is a dot ('.') separated string with xPL message elements, each element may be
	wildcarded with an asterix ('*').

		filter = [msgtype].[vendor].[device].[instance].[schemaclass].[schematype]

	The default filter '*.*.*.*.*.*' will call the handler for every message received

	]]--

	Filters = {
		"*.*.*.*.hbeat.*",
		"*.*.*.*.config.*",
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
	end,

	ShutDown = function (self)
		-- function called upon shuttingdown this handler
	end,

	MessageHandler = function (self, msg, filter)
		return true -- return true, suppress standard event
	end,
}


-- finally deliver the handler to the xPLGirder component
return myNewHandler
