--[[

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

]]--




--[[

This file was created as an xPL message handler for all messages with schema 'sensor.basic'.
It generates specific events for just the changed values of the sensors (so new messages
with same values are not evented).

The value will be in payload 1, any additional fields provided will be stored in payload 2-4.

Sensor values can be accessed in lua through table;
	xPLGirder.Handlers.SensorBasic.sensors

try typing the following in the interavctive lua console;
	table.print (xPLGirder.Handlers.SensorBasic.sensors)

]]--


local xPLEventDevice = 10124	-- when raising events, use this as source to set it to xPLGirder


local myNewHandler = {

	ID = "SensorBasic",		-- enter a unique string to identify this handler



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
		"*.*.*.*.sensor.basic"
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
		self.sensors = {}	-- reset table with sensor values
	end,

	ShutDown = function (self)
		-- function called upon shuttingdown this handler
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
		-- create a unique sensor ID by using the address and sensor type together
		local sensorID = msg.source .. ': ' .. GetValueByKey('device') .. ', ' .. GetValueByKey('type')
		local newVal = GetValueByKey('current')

		if (self.sensors[sensorID] == nil) or (self.sensors[sensorID] ~= newVal) then
			-- first time we get this sensor, or value is different than before
			self.sensors[sensorID] = newVal
			local pld = {}
			local p = 2
			local i
			pld[1] = newVal

			for i = 1,table.getn(msg.body) do
				local k = msg.body[i].key
				if k ~= 'device' and k ~= 'type' and k~= 'current' and p <= 4 then
					-- found an unknown key, append its value in the next payload
					pld[p] = msg.body[i].value
					p = p + 1
				end
			end

			gir.TriggerEvent('Sensor update ' .. sensorID, xPLEventDevice, pld[1], pld[2], pld[3], pld[4] )
		end



		-- Determine the return value
		-- false: The standard xPLGirder event will still be created (if all other handlers also
		--        return false)
		-- true:  The standard xPLGirder event is suppressed, this should be used when the handler
		--        has created a more specific event from the xPL message than the regular xPLGirder
		--        event.
		return true
	end,
}


-- finally deliver the handler to the xPLGirder component
return myNewHandler