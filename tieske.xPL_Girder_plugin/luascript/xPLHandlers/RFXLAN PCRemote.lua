--[[

This file is an xPL message handler template to be used with the xPLGirder plugin.

It will translate xPL messages from RFXLAN, received from a PC Remote rf remote control
into the proper generic Girder remote control events.


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

local EventList = {				-- list which maps key-codes to Girder events
	xb0 = "PLAY",				-- contains the keys codes as delivered minus the first 0, eg 0xb0 -> xb0
	x72 = "PAUSE",
	-- = "PLAY/PAUSE",
	xff = "RECORD",
	x70 = "STOP",
	xd8 = "NEXT",
	x3a = "PREVIOUS",
	xb8 = "FAST FORWARD",
	x38 = "FAST REVERSE",
	-- = "REPEAT",
	-- = "SHUFFLE",
	x60 = "MASTER VOLUME UP",
	xe0 = "MASTER VOLUME DOWN",
	xa0 = "MASTER MUTE",
	-- = "WAVE VOLUME UP",
	-- = "WAVE VOLUME DOWN",
	-- = "WAVE MUTE",
	-- = "APPLICATION VOLUME UP",
	-- = "APPLICATION VOLUME DOWN",
	-- = "APPLICATION MUTE",
	x40 = "CHANNEL UP",
	xc0 = "CHANNEL DOWN",
	x52 = "ENTER",
	xd5 = "ARROW UP",
	xd3 = "ARROW DOWN",
	xd2 = "ARROW LEFT",
	xd1 = "ARROW RIGHT",
	x82 = "KEY 1",
	x42 = "KEY 2",
	xc2 = "KEY 3",
	x22 = "KEY 4",
	xa2 = "KEY 5",
	x62 = "KEY 6",
	xe2 = "KEY 7",
	x12 = "KEY 8",
	x92 = "KEY 9",
	x02 = "KEY 0",
	-- = "+10",
	-- = "+100",
	-- = "MOUSE MODE ON",
	-- = "MOUSE MODE OFF",
	-- = "MOUSE UP",
	-- = "MOUSE DOWN",
	-- = "MOUSE LEFT",
	-- = "MOUSE RIGHT",
	-- = "MOUSE UPRIGHT",
	-- = "MOUSE DOWNRIGHT",
	-- = "MOUSE DOWNLEFT",
	-- = "MOUSE UPLEFT",
	-- = "MOUSE MODE TOGGLE",
	-- = "MOUSEBUTTON LEFT",
	-- = "MOUSEBUTTON MIDDLE",
	-- = "MOUSEBUTTON RIGHT",
	-- = "MOUSEBUTTON LEFT HOLD",
	-- = "MOUSEBUTTON LEFT DOUBLE CLICK",
	xf0 = "POWER",
	xb6 = "MENU",
	-- = "EJECT",
	-- = "SHUTDOWN",
	-- = "SUSPEND",
	-- = "HIBERNATE",
	-- = "RESTART",
	-- = "MONITOR TOGGLE",
	-- = "MONITOR OFF",
	-- = "MONITOR ON",
	-- = "TASKMANAGER NEXT",
	-- = "TASKMANAGER PREVIOUS",
	-- = "TASKMANAGER SELECT",
	-- = "MINIMIZE",
	-- = "MAXIMIZE",
	-- = "RESTORE",
	-- = "CLOSE",
	-- = "WEATHER CURRENT CONDITIONS",
	-- = "WEATHER FORECAST",
	-- = "WEATHER SATELLITE",
	-- = "TIME",
	-- = "INFO",
	-- = "MARK",
	-- = "SUBTITLE MENU",
	-- = "ROOT MENU",
	-- = "AUDIO MENU",
	-- = "TITLE MENU",
	-- = "SUBTITLE CYCLE",
	-- = "ANGLE CYCLE",
	-- = "AUDIO CYCLE",
	-- = "FULL SCREEN TOGGLE",
	-- = "WINAMP",
	-- = "WINDOWS MEDIA PLAYER",
	-- = "WINDOWS MEDIA PLAYER CLASSIC",
	-- = "POWERDVD",
	-- = "ZOOM PLAYER",
	-- = "WINDVD",
	-- = "WINDVD 6",
	-- = "WINDVD 7",
	-- = "THEATRETEK 2",
	-- = "ITUNES",
	-- = "J RIVER MEDIA CENTER",
	-- = "WINDOWS MEDIA CENTER",
	-- = "KEY A",
	-- = "KEY B",
	-- = "KEY C",
	-- = "KEY D",
	-- = "KEY E",
	-- = "KEY F",
	-- = "KEY G",
	-- = "KEY H",
	-- = "KEY I",
	-- = "KEY J",
	-- = "KEY K",
	-- = "KEY L",
	-- = "KEY M",
	-- = "KEY N",
	-- = "KEY O",
	-- = "KEY P",
	-- = "KEY Q",
	-- = "KEY R",
	-- = "KEY S",
	-- = "KEY T",
	-- = "KEY U",
	-- = "KEY V",
	-- = "KEY W",
	-- = "KEY X",
	-- = "KEY Y",
	-- = "KEY Z",
	-- = "KEY SHIFT",
	-- = "KEY CONTROL",
	-- = "KEY SPACE",
	-- = "KEY F1",
	-- = "KEY F2",
	-- = "KEY F3",
	-- = "KEY F4",
	-- = "KEY F5",
	-- = "KEY F6",
	-- = "KEY F7",
	-- = "KEY F8",
	-- = "KEY F9",
	-- = "KEY F10",
	-- = "KEY F11",
	-- = "KEY F12",
	-- = "TILDE",
	-- = "TAB",
	-- = "INSERT",
	-- = "HOME",
	-- = "PAGE UP",
	-- = "PAGE DOWN",
	-- = "END",
	-- = "DELETE",
	xc9 = "BACKSPACE",
	-- = "WWW",
	-- = "CD",
	-- = "DVD",
	-- = "TV",
	-- = "TUNER",
	-- = "VCR",
	-- = "MD",
	-- = "VIDEO",
	-- = "SATELITE",
	-- = "CABLE",
	-- = "AUX",
	-- = "STANDBY",
	-- = "GUIDE",
}



local myNewHandler = {

	ID = "PC-Remote",		-- enter a unique string to identify this handler



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
		"*.rfxcom.lan.*.remote.basic"
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
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
		local result = false
		local keycode = GetValueByKey('keys')

		if keycode ~= nil and string.sub(keycode,1,1) == '0' and string.len(keycode) > 1 then
			keycode = string.sub(keycode , 2)	-- ditch first '0'
		else
			keycode = nil						-- not a valid value
		end

		if keycode ~= nil then
			local eventstring = EventList[keycode]
			if eventstring ~= nil then
				gir.TriggerEvent( eventstring, xPLEventDevice )
				result = true	-- report to supress default event, we had a key event
			end
		end



		-- Determine the return value
		-- false: The standard xPLGirder event will still be created (if all other handlers also
		--        return false)
		-- true:  The standard xPLGirder event is suppressed, this should be used when the handler
		--        has created a more specific event from the xPL message than the regular xPLGirder
		--        event.
		return result
	end,
}


-- finally deliver the handler to the xPLGirder component
return myNewHandler
