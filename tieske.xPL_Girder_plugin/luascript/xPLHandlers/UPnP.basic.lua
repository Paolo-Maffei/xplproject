--[[

This file is an xPL message handler template to be used with the xPLGirder plugin.
It grabs UPnP updates from devices and reports them into the global UPnP table.



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

	ID = "UPnP",		-- enter a unique string to identify this handler



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
		"*.*.*.*.upnp.basic"
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
		print ("Initializing the xPL handler ID: " .. self.ID)

		UPnP = UPnP or {}		-- initialize global table
	end,

	ShutDown = function (self)
		-- function called upon shuttingdown this handler
		print ("Shutting down the xPL handler ID: " .. self.ID)

		UPnP = nil 	-- destroy global variable
	end,

	MessageHandler = function (self, msg, filter)
		--[[
		The handler function below will handle the actual message. The parameters are the xPL message
		and the filter string that passed the message.

		The return value should be a boolean indicating whether the standard xPLGirder event should
		be suppressed.
			msg is a table with the following keys;
			msg.type		message type, either one of 'xpl-cmnd', 'xpl-trig', or 'xpl-stat'.
			msg.hop			message hop-count
			msg.source		source address
			msg.target		target address (or wildcard)
			msg.schema		message schema
			msg.body		contains sub-tables, each with a 'key' and a 'value' field, so to access;
							first key value  :   msg.body[1].key
							first value value:   msg.body[1].value
		]]--

		local GetValueByKey = function (key)
			-- get a value from the message at hand by its key (the first occurence of that key)
			for k,v in ipairs(msg.body) do
				if v.key == key then
					return v.value
				end
			end
		end




		-- add your code here to handle the actual message
		print ("Got one on filter: " .. filter .. " from source: " .. msg.source)

		-- Get the source name and cleanup
		local source = string.gsub(msg.source, '%.', '_' )  -- remove any '.' (dot) as the variable inspector will not show tables with them

		-- Get the device table within the UPnP domain
		UPnP[source] = UPnP[source] or {}
		local dev = UPnP[source]

		-- Get the service name
		local _, _, _, _, _, service = string.find(GetValueByKey('service'),'([%a%d%p^:]-):([%a%d%p^:]-):([%a%d%p^:]-):(.+)')
		service = string.gsub(service, '%.', '_' )  -- remove any '.' (dot) as the variable inspector will not show tables with them

		-- Get the service table within the device table
		dev[service] = dev[service] or {}
		service = dev[service]

		-- Set the value of the reported variable in the table
		service[GetValueByKey('name')] = GetValueByKey('value')

		-- Determine the return value
		-- false: The standard xPLGirder event will still be created (if all other handlers also
		--        return false)
		-- true:  The standard xPLGirder event is suppressed, this should be used when the handler
		--        has created a more specific event from the xPL message than the regular xPLGirder
		--        event.
		return false
	end,
}


-- finally deliver the handler to the xPLGirder component
return myNewHandler
