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

require 'Classes.DelayedExecutionDispatcher'
require 'thread'
require 'date'

local xPLEventDevice = 10124	-- when raising events, use this as source to set it to xPLGirder

local GetValueByKey = function (msg, key)
	-- get a value from the message at hand by its key (the first occurence of that key)
	for k,v in ipairs(msg.body) do
		if v.key == key then
			return v.value
		end
	end
end

local CleanKey = function (key)
	if type(key) == "string" then
		key = string.gsub(key, '%.', '_' )  -- remove any '.' (dot) as the variable inspector will not show tables with them
		key = string.gsub(key, '%:', '_' )  -- remove any ':' (dot) as the variable inspector will not show tables with them
	end
	return key
end

local myNewHandler = {

	ID = "UPnP",		-- enter a unique string to identify this handler

	Filters = {
		"*.*.*.*.upnp.basic",
		"*.*.*.*.upnp.announce",
		"*.*.*.*.upnp.method",
		"*.*.*.*.hbeat.end",
		"*.*.*.*.config.end",
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
		--print ("Initializing the xPL handler ID: " .. self.ID)

		-- define global tables
		UPnP = {
			IDlist = self.IDlist,
			devices = self.DevList,
			CallMethod = function (self, methodid, ...)
					methodid = (methodid or "") .. ""	-- convert to string
					local method = self.IDlist[methodid]
					if method == nil then
						error("No (valid) method provided, first argument must be method id, remaining arguments the parameters to the method.", 2)
					end
					return method:execute(unpack(arg))
				end,
			PollValue = function (self, id)
					id = (id or "") .. "" -- convert to string
					if id == "" then
						error ("No ID provided for the element whose values to poll")
					end
					local elem = self.IDlist[id]
					if elem == nil then
						error ("ID '" .. id .. "' is not valid for polling variables values")
					end
					if type(elem.poll) ~= "function" then
						error ("ID '" .. id .. "' is not valid for polling variables values")
					end
					elem:poll()
				end,
		}

		-- send announce request, but wait until xPLGirder is fully initialized
		local ded = Classes.DelayedExecutionDispatcher:New (3000, function () self:RequestAnnounce() end)
	end,

	ShutDown = function (self)
		-- function called upon shuttingdown this handler
		-- print ("Shutting down the xPL handler ID: " .. self.ID)
		for k,v in pairs(self.DevList) do
			self:DeleteRootDevice(v)
		end
		UPnP = nil 	-- destroy global variable
	end,


	AnnFragments = {},		-- list (by their ID) of announcements received, but not yet completed
	CompFragments = {},		-- list (by their ID) of fragments that are complete (all children attached, or no children)
	IDlist = {},			-- public list of all elements by their ID
	DevList = {}, 			-- public list of all completed root devices by their UDN
	CallID = 0,				-- a unique call ID for method calls
	ResponseQueue = {},		-- ID's of methods calls waiting for a response


	_lock = thread.newmutex(),

	Lock = function (self)
		self._lock:lock()
	end,

	Unlock = function (self)
		self._lock:unlock()
	end,

	MessageHandler = function (self, msg, filter)
		-- protected handler to run only singular, other threads can only enter after this call completed
		self:Lock()
		local result = false
		local s,r = pcall(self._MessageHandler, self, msg, filter)
		if s then	-- success
			result = r
		else	-- failure
			-- error was returned from handler
			print("xPLHandler " .. self.ID .. " had a lua error;" .. r)
			print("while handling the following xPL message;")
			table.print(msg)
			gir.LogMessage(xPLGirder.Name, self.ID .. ' failed while processing a message, see lua console', 2)
		end
		self:Unlock()
		return result
	end,

	_MessageHandler = function (self, msg, filter)
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

		local result = false	-- default return value; do not suppress standard event

		if msg.schema == "upnp.basic" and msg.type == "xpl-trig" then
			-- updated state variable arrived
			self:UpdateStateVariable(msg)
			result = true	-- suppress standard event

		elseif msg.schema == "upnp.method" and msg.type == "xpl-trig" then
			-- method call results are being delivered
			local callid = GetValueByKey(msg, "callid")
			if callid ~= nil then
				if self.ResponseQueue[callid] ~= nil then
					-- its a response we're waiting for, so go store it
					self.ResponseQueue[callid] = msg
				end
			end
			result = true	-- suppress standard event

		elseif msg.schema == "upnp.announce" and msg.type == "xpl-trig" and GetValueByKey(msg, "announce") ~= "left" then
			-- new device or service or other element added
			self:AddAnnouncedFragment(msg)
			result = true	-- suppress standard event

		elseif msg.schema == "config.end" or msg.schema == "hbeat.end" or (msg.schema == "upnp.announce" and msg.type == "xpl-trig" and GetValueByKey(msg, "announce") == "left") then
			-- an xPL/UPnP device is leaving, check if its one of ours and delete the root devices
			result = self:RemoveDevice(msg)

		else
			-- unknown schema, do nothing
			result = false	-- do not suppress standard event
		end

		-- Determine the return value
		-- false: The standard xPLGirder event will still be created (if all other handlers also
		--        return false)
		-- true:  The standard xPLGirder event is suppressed, this should be used when the handler
		--        has created a more specific event from the xPL message than the regular xPLGirder
		--        event.
		return result
	end,

	RemoveDevice = function (self, msg)
		-- received a message that something is leaving, either UPnP or xPL device, do cleanup
		if msg.schema == "upnp.announce" and msg.type == "xpl-trig" and GetValueByKey(msg, "announce") == "left" then
			-- UPnP device is leaving
			self:RemoveUPnPDevice(msg)
			return true	-- suppress default event from xPLGirder
		elseif msg.schema == "config.end" or msg.schema == "hbeat.end" then
			-- xPLDevice is leaving
			self:RemovexPLDevice(msg)
			return false	-- do not suppress default event from xPLGirder
		end
	end,

	RemoveUPnPDevice = function (self, msg)
		-- a UPnP device is leaving, go find and delete it
		local t = GetValueByKey(msg, "id")
		t = string.Split(t, ",")
		t = t[1]					-- first item is devices main ID
		t = self.IDlist[t]			-- get device itself
		if t ~= nil then
			-- check if its a root device, and remove if so
			if t.announce == "device" and t.parent == nil then
				self:DeleteRootDevice(t)
			end
		end
	end,

	RemovexPLDevice = function (self, msg)
		-- an xPL device is leaving, check if its one of our root devices
		local del = "not nil"
		while del ~= nil do	-- use While loop because we'll be modifying the iterated table, repeat until no more found.
			del = nil
			for k,v in pairs(self.DevList) do
				if v.xpl == msg.source then
					del = v
					break
				end
			end
			if del ~= nil then
				-- so its one of ours, delete device itself
				self:DeleteRootDevice(del)
			end
		end
	end,

	DeleteRootDevice = function (self, dev)
		-- removes a specific device table from the global tables and raises Girder event
		self.DevList[dev.deviceid] = nil
		self:DeleteElement(dev)
		-- trigger event girder event for left device
		gir.TriggerEvent("UPnP device left; " .. dev.name, xPLEventDevice, dev.deviceid)
	end,

	DeleteElement = function (self, dev)
		-- removes a specific element table from the global ID list, will call itself recursive
		-- go delete the child elements
		if dev.IDlist ~= nil then
			for k, v in pairs(dev.IDlist) do
				self:DeleteElement(self.IDlist[v])
			end
		end
		-- delete myself
		self.IDlist[dev.ID] = nil
	end,

	RequestAnnounce = function (self)
		-- send an broadcast xpl message to announce UPnP devices
		local req = "xpl-cmnd\n{\nhop=1\nsource=%s\ntarget=*\n}\nupnp.basic\n{\ncommand=announce\n}\n"
		local msg = string.format(req, xPLGirder.Source)
		xPLGirder:SendMessage(msg)
	end,

	AddAnnouncedFragment = function (self, msg)
		local part = {}					-- will hold our received part
		-- create ID list
		local t = GetValueByKey(msg, "id")
		t = string.Split(t, ",")
		part.ID = t[1]					-- first item is our own ID
		if self.IDlist[part.ID] ~= nil then
			if self.IDlist[part.ID].announce == "variable" and GetValueByKey("announce") == "variable" then
				-- we already have a variable value for this ID, so probably
				-- a variable update was received before the announcement itself
				-- get the already created table containing the value and continue
				-- from there in this case
				part = self.IDlist[part.ID]
			end
		end
		-- Add remaining data to the part
		for k,v in ipairs(msg.body) do
			if v.key ~= "id" then
				part[v.key] = v.value
			end
		end
		-- split allowed values list
		if type(part.allowed) == string then
			part.allowed = string.Split(part.allowed, ',')
		end
		-- treat subdevices as devices, check the absence of 'parent' key as inidicator that its a root device
		if part.announce == "subdevice" then
			part.announce = "device"
		end
		-- add methods for execution of element specific code
		if part.announce == "method" then
			self:AppendCall(part)		-- add 'execute' function to the methods table
		elseif part.announce == "variable" or part.announce == "service" or part.announce == "device" then
			self:AppendPoll(part)		-- add 'poll' function to the variable/service/device tables
		end
		-- create the ID list of the child elements
		part.IDlist = {}				-- list with all our children ids
		part.WaitingFor = {}			-- list with ids waiting for, to be complete
		if part.announce == "method" then
			part.order = {}				-- table with the argument order for the method
		end
		for i, v in ipairs(t) do
			if v ~= part.ID then		-- if its not our own ID, then add it
				part.IDlist[v] = v
				part.WaitingFor[v] = v
				if part.announce == "method" then
					part.order[i-1] = v		-- use n-1 becasause the first is always the skipped own ID
				end
			end
		end
		-- Check if any of my children are around already
		if not table.IsEmpty(part.WaitingFor) then
			-- I do have children, go check each one in the COMPLETED list
			local done ={}		-- done list, will be deleted at end, to prevent messing with table while iterating
			for k,v in pairs(part.WaitingFor) do
				local p = self.CompFragments[k]
				if p ~= nil then
					-- found one !
					if p.announce == "device" then
						part.devices = part.devices or {}
						part.devices[CleanKey(p.deviceid)] = p
					elseif p.announce == "service" then
						part.services = part.services or {}
						part.services[CleanKey(p.service)] = p
					elseif p.announce == "method" then
						part.methods = part.methods or {}
						part.methods[p.name] = p
					elseif p.announce == "argument" then
						part.arguments = part.arguments or {}
						part.arguments[p.name] = p
					elseif p.announce == "variable" then
						part.variables = part.variables or {}
						part.variables[p.name] = p
					end
					-- add to list to be removed because they are done
					done[p.ID] = p.ID
				end
			end
			-- remove 'done' list
			for k,v in pairs(done) do
				part.WaitingFor[k] = nil
				self.CompFragments = nil
			end
		end

		-- store received fragment
		self.AnnFragments[part.ID] = part

		-- Check if I'm complete...
		if table.IsEmpty(part.WaitingFor) then
			-- Part is complete go deal with it
			self:PartComplete(part.ID)
		end
	end,

	PartComplete = function (self, pID)
		-- the mentioned ID is complete and in the CompFragments list, attach it to parent
		-- and check parent completenss
		local p = self.AnnFragments[pID]
		if pID == nil then
			return
		end
		if p.announce == "device" and p.parent == nil then
			-- its a completed root-device, just move it to the complete lists
			self.AnnFragments[p.ID] = nil
			self.DevList[p.deviceid] = p
			self.IDlist[p.ID] = p
			p.WaitingFor = nil
			gir.TriggerEvent("UPnP device arrived; " .. p.name, xPLEventDevice, p.deviceid)
			-- announcement complete, request the devices variable values, but delayed to prevent flooding the xPL network
			local ded = Classes.DelayedExecutionDispatcher:New (3000, function () self:RequestVariableValues(pID) end)
		else
			if p.announce == "service" then
				-- whenever a service completes, update all methods to attach the related statevariable table
				-- to the 'variable' key instead of the received ID
				if p.methods ~= nil then
					for methodname, methodtable in pairs(p.methods) do
						if methodtable.arguments ~= nil then
							for argname, argtable in pairs(methodtable.arguments) do
								if type(argtable.variable) ~= "table" then
									argtable.variable = self.IDlist[argtable.variable]
								end
							end
						end
					end
				end
			end
			-- find parent and attach it
			local pt = self.AnnFragments[p.parent]
			if pt == nil then
				-- parent not found, so do nothing, have to wait for it to arrive
			else
				-- attach to parent
				if p.announce == "device" then
					pt.devices = pt.devices or {}
					pt.devices[CleanKey(p.deviceid)] = p
				elseif p.announce == "service" then
					pt.services = pt.services or {}
					pt.services[CleanKey(p.service)] = p
				elseif p.announce == "method" then
					pt.methods = pt.methods or {}
					pt.methods[p.name] = p
				elseif p.announce == "argument" then
					pt.arguments = pt.arguments or {}
					pt.arguments[p.name] = p
				elseif p.announce == "variable" then
					pt.variables = pt.variables or {}
					pt.variables[p.name] = p
				end
				-- remove from waiting for list and add to complete list
				self.AnnFragments[p.ID] = nil
				pt.WaitingFor[p.ID] = nil
				self.IDlist[p.ID] = p
				p.WaitingFor = nil
				-- check parent completeness
				if table.IsEmpty(pt.WaitingFor) then
					-- handle complete item (resursive function call)
					self:PartComplete(pt.ID)
				end
			end
		end
	end,

	UpdateStateVariable = function (self, msg)
		for i,kvp in ipairs(msg.body) do
			local svar = self.IDlist[kvp.key]
            local k = kvp.key
            local v = kvp.value
            -- check if value was chopped, and restore if necesary
            if v == "<<chopped_it>>" then
                -- it was chopped, so we must reconstruct
                local c = 1
                local kv
                v = ""
                repeat
                    kv = GetValueByKey(msg, k .. "-" .. c)
                    if kv then
                        v = v .. kv
                    end
                    c = c + 1
                until kv == nil
            end

			if svar ~= nil then
				-- found a statevariable
				local old = svar.value
				svar.value = v
				local pservice = self.IDlist[svar.parent]		-- gets the parent service of the statevariable
				if pservice ~= nil then
					local pdevice = self.IDlist[pservice.parent]	-- gets the parent device of the service
					if pdevice ~= nil then
						local devname = pdevice.name					-- gets the actual device name
						gir.TriggerEvent("UPnP value update " .. devname .. ":" .. svar.name, xPLEventDevice, k, v, old)
					else
						-- device not found, assume announcement incomplete, no girder event
					end
				else
					-- service not found, assume announcement incomplete, no girder event
				end
			elseif tonumber(k) ~= nil then
				-- statevariable was not found, but it is a number, assume that statevariable is not yet
				-- completely announced and add a table for it anyway
				local svar = {}
				svar.ID = k
				svar.value = v
				svar.announce = "variable"
				svar.IDlist = {}
				svar.name = "unknown, value was announced before definition; awaiting completion of announcement"
				self.IDlist[k] = svar
				-- we don't have (don't know) our parent, so cannot raise event
			end
		end
	end,

	CallMethod = function (self, method, ...)
		-- Calls the provided UPnP method using the extra arguments
		-- check method
		if method == nil then
			error("No method provided, first argument must be method table", 2)
		elseif method.announce == nil then
			error("Table provided is not a UPnP element", 2)
		elseif method.announce ~= "method" then
			error("UPnP element provided is not a Method", 2)
		end

		-- construct xPL message
		local header = "xpl-cmnd\n{\nhop=1\nsource=%s\ntarget=%s\n}\nupnp.method\n{\ncommand=methodcall\nmethod=%s\ncallid=%s\n"
		local footer = "}\n"
		local body = ""
		for i,v in ipairs(method.order) do
			local t = type(arg[i])
			local value = arg[i]
			-- first convert value to string type
			if t == "string" then
				-- no need to do anything
			elseif t == "number" then
				value = value .. ""
			elseif t == "boolean" then
				if value then
					value = "True"
				else
					value = "False"
				end
			elseif t == "nil" then
				value = ""
			else
				-- function, userdata, thread, and table
				error("Cannot handle type '" .. t .. "' as input parameter for a UPnP methodcall.")
			end
			body = body .. string.format("%s=%s\n", v, value)
		end
		local msg = string.format(header .. body .. footer, xPLGirder.Source, method.xpl, method.ID, self.CallID)
		self.CallID = self.CallID + 1					-- increase unique ID by 1
		xPLGirder:SendMessage(msg)
		return self:WaitForResponse(method.ID, self.CallID - 1)
	end,

	WaitForResponse = function (self, MethodID, CallID)
		-- waits for a response on a method call, by ID of 'CallID' and returns the returned UPnP parameters
		CallID = CallID .. "" 	-- force to a string
		self:Lock()
		self.ResponseQueue[CallID] = CallID		-- post ID we're waiting for
		self:Unlock()
		local done = false
		local msg
		local waituntil = date:now()
		waituntil.Second = waituntil.Second + 20	-- timeout after 20 seconds
		while not done do
			win.Sleep(100)
			self:Lock()
			if type(self.ResponseQueue[CallID]) == "table" then
				-- type changed to a table, so it now contains the xPL message with the response
				msg = self.ResponseQueue[CallID]
				self.ResponseQueue[CallID] = nil
				done = true
			elseif waituntil < date:now() then
				-- waiting timed out, so exit
				self.ResponseQueue[CallID] = nil	-- cleanup
				done = true
			end
			self:Unlock()
		end
		-- we're done
		if msg == nil then
			-- timedout
			return false, "No response received (time out)"
		else
			-- deal with the response
			local success = (string.lower(GetValueByKey(msg, "success") or "") == "true")
			if not success then
				-- failed call, report error
				return false, GetValueByKey(msg, "error") or "No error message was provided"
			else
				-- successfull call, dissect response
				local response = {}
				local i = 1
				-- lookup the method it was a response to
				local method = self.IDlist[MethodID]
				if method == nil then
					-- something is wrong
					return false, "Could not locate method for this reponse message, UPnP device left?"
				end
				response[i] = GetValueByKey(msg, "retval") or ""	-- 2nd argument is return value
				i = i + 1
				-- now add all OUT parameters
				for n,argID in ipairs(method.order) do	-- loop through the arguments in the correct order as specified
					if self.IDlist[argID].direction == "out" then
						-- got an out-going parameter, get value and add it
						response[i] = GetValueByKey(msg, argID) or ""
                        if response[i] == "<<chopped_it>>" then
                            -- it was chopped, so we must reconstruct
                            local c = 1
                            local kv
                            response[i] = ""
                            repeat
                                kv = GetValueByKey(msg, argID .. "-" .. c)
                                if kv then
                                    response[i] = response[i] .. kv
                                end
                                c = c + 1
                            until kv == nil
                        end
						i = i + 1
					end
				end
				-- response table completed, now return the values
				return true, unpack(response)
			end
		end
	end,

	AppendCall = function (self, method)
		-- takes a 'method' table and appends an 'execute' function
		method.execute = function (method, ...) return self:CallMethod(method, unpack(arg)) end
		return method
	end,

	RequestVariableValues = function (self, pID)
		-- Request variable values for this device
		if not table.IsEmpty(self.AnnFragments) then
			-- Announcement fragment list is not empty, so probably we're still in the announcement phase with lots
			-- of traffic, so delay the variable update request
			local ded = Classes.DelayedExecutionDispatcher:New (3000, function () self:RequestVariableValues(pID) end)
		else
			pID = (pID or "") .. ""		-- convert to string
			if pID == "" then
				error("No ID provided for the element to poll for its variables.")
			end
			local dev = self.IDlist[pID]
			if dev.announce ~= "device" and dev.announce ~= "service" and dev.announce ~= "variable" then
				error("Can only request values for types device, service, and variable. Not for type " .. dev.announce)
			end
			local req = "xpl-cmnd\n{\nhop=1\nsource=%s\ntarget=%s\n}\nupnp.basic\n{\ncommand=requestvalue\nid=%s\n}\n"
			local msg = string.format(req, xPLGirder.Source, dev.xpl, pID)
			xPLGirder:SendMessage(msg)
		end
	end,

	AppendPoll = function(self, element)
		-- append a 'poll' method to the element table
		local id = element.ID
		element.poll = function () self:RequestVariableValues(id) end
	end,
}



-- finally deliver the handler to the xPLGirder component
return myNewHandler
