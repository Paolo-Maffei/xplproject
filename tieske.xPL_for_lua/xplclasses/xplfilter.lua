local super = require("loop.simple")

local flt = super.class {

	-- list to store filters in, table with 6 filter elements and 'filter' with the filter string. each filter is keyed by its filterstring
	list = {},

	-- splits a filter string in a filter table with 6 indices ('-' between vendor and device is accepted) anf filter key with string value
	-- filter = string as '[msgtype].[vendor].[device].[instance].[class].[type]'
	split = function (self, flt)
		local flt = flt or self	-- allow both function calls and method calls
		assert(type(flt) == "string", "failed to split filter, string expected got " .. type(flt))
		local r = { string.match(flt, xpl.CAP_FILTER) }
		assert( #r == 6, "unable to split filter '" .. flt .. "'.")
		r.filter = table.concat(r, ".")
		return r
	end,

	-- add a filter to my list, no duplicates will be added, flt is string or table
	add = function (self, flt)
		if type(flt) == "string" then
			flt = self:split(flt)
		end
		assert(type(flt) == "table", "cannot add filter, string or table expected, got " .. type (flt))
		if not flt.filter then
			flt.filter = string.concat(flt, ".")
		end
		if not self.list[flt.filter] then -- only add if not in the list already
			self.list[flt.filter] = flt
		end
	end,

	-- remove filter from list
	remove = function (self, flt)
		if type(flt) == "table" then
			if not flt.filter then
				flt.filter = table.concat(flt, ".")
			end
			flt = flt.filter
		end
		assert(type(flt) == "string", "cannot remove filter, string or table expected, got " .. type (flt))
		self.list[flt] = nil
	end,

	match = function (self, flt)
		-- wildcards can be used in either one (filters and filter); '*'
		-- returns true if the filter matches the list

		if type(flt) == "string" then
			flt = self:split(flt)
		end
		assert(type(flt) == "table", "cannot match filter, string or table expected, got " .. type (flt))

		local match
		for _ , filter in pairs(self.list) do
			match = true
			for n = 1,6 do
				if flt[n] == "*" or filter[n]=="*" or flt[n]==filter[n] then
					-- matches
				else
					-- no match
					match = false
					break	-- exit 1-6 elements loop as it already failed
				end
			end
			if match then break end	-- exit filters loop, we've got a match already
		end
		return match
	end,

}

-- run tests
if xpl.settings._DEBUG then
	require ("table_ext")

	print("Testing xplfilter class")
	local filters = flt()	-- create instance

	-- test split (both calling as function and as method
	local f = "xpl-cmnd.tieske.somedev.inst.schema.class"
	local fs = filters:split(f)
	assert (fs.filter == f, "filter value in filter table not set properly")
	assert (#fs == 6, "too many/little items returned")
	assert (fs[1] == "xpl-cmnd", "message type is not correct ")
	assert (fs[2] == "tieske", "vendor is not correct")
	assert (fs[3] == "somedev", "device type is not correct")
	assert (fs[4] == "inst", "instance type is not correct")
	assert (fs[5] == "schema", "schema type is not correct")
	assert (fs[6] == "class", "class type is not correct")
	print ("   calling split function as method succeeded")

	local fs = filters.split(f)
	assert (fs.filter == f, "filter value in filter table not set properly")
	assert (#fs == 6, "too many/little items returned")
	assert (fs[1] == "xpl-cmnd", "message type is not correct ")
	assert (fs[2] == "tieske", "vendor is not correct")
	assert (fs[3] == "somedev", "device type is not correct")
	assert (fs[4] == "inst", "instance type is not correct")
	assert (fs[5] == "schema", "schema type is not correct")
	assert (fs[6] == "class", "class type is not correct")
	print ("   calling split function as function succeeded")

	local s = pcall(filters.split, 123)
	assert( not s, "error expected because of a number")
	local s = pcall(filters.split, {})
	assert( not s, "error expected because of a table")
	local s = pcall(filters.split, "*.to.little.items")
	assert( not s, "error expected because there are to little items")
	print ("   calling split function with errors succeeded")

	-- test add
	filters:add(f)
	local f = "xpl-cmnd.*.*.*.*.class"
	filters:add(f)
	assert(filters.list[f][2] == "*", "asterisk expected")
	assert(filters.list[f][6] == "class", "'class' expected")
	assert(filters.list[f].filter == f, "filter doesn't match")
	local f = "*.tieske.*.*.*.*"
	filters:add(f)
	assert(filters.list[f][2] == "tieske", "'tieske' expected")
	assert(filters.list[f][6] == "*", "'*' expected")
	assert(filters.list[f].filter == f, "filter doesn't match")
	local cnt = table.size(filters.list)
	filters:add(f)
	assert(cnt == table.size(filters.list), "same filter should not be added twice")
	print ("   calling add method succeeded")

	local s = pcall(filters.add, filters, 123)
	assert( not s, "error expected because of a number")
	local s = pcall(filters.add, filters, nil)
	assert( not s, "error expected because of a nil")
	print ("   calling add method with errors succeeded")

	-- test remove
	local f = "xpl-cmnd.*.*.*.*.class"
	assert(filters.list[f] ~= nil, "filter should be here, was added previously")
	filters:remove(f)
	assert(filters.list[f] == nil, "filter should have been removed")
	local f = "*.tieske.*.*.*.*"
	filters:remove(f)
	assert(filters.list[f] == nil, "filter should have been removed")
	assert(#filters.list == 0, "All filters should have been removed")
	print ("   calling remove method succeeded")

	local s = pcall(filters.remove, filters, 123)
	assert( not s, "error expected because of a number")
	local s = pcall(filters.remove, filters, nil)
	assert( not s, "error expected because of a nil")
	print ("   calling remove method with errors succeeded")

	-- test match
	filters:add("xpl-cmnd.*.*.*.*.class")
	filters:add("*.tieske.*.*.*.*")
	assert(filters:match("xpl-trig.tieske.device.inst.log.basic") == true, "filter should have matched")
	assert(filters:match("xpl-cmnd.tieske.device.inst.log.class") == true, "filter should have matched")
	assert(filters:match("xpl-trig.other.device.inst.log.basic") == false, "filter should have failed")
	print ("   calling match method succeeded")

	local s = pcall(filters.match, filters, 123)
	assert( not s, "error expected because of a number")
	local s = pcall(filters.match, filters, nil)
	assert( not s, "error expected because of a nil")
	print ("   calling match method with errors succeeded")


	print("Testing xplfilter class succeeded")
	print()
end

return flt