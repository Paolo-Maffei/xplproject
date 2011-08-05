--[[
WireShark dissector for xPL homeautomation protocol
===================================================
Copyright 2011 by Thijs Schreijer
thijs@thijsschreijer.nl
http://www.thijsschreijer.nl

Feedback is very welcome.

License
=======
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


Links
=====
WireShark       http://www.wireshark.org/
xPL protocol    http://xplproject.org.uk/


Changelog
=========
26-apr-2011   v1.0     Initial version
05-aug-2011   v1.1     Updated to allow longer length values; compatibility warning if more than 128
                       Updated to allow UTF8 in values; compatibility warning will be shown

]]--


-- declare our protocol
local xpl_proto = Proto("xPL","xPL Protocol")

-- Create fields and add them to the ptotocol
local f_type = ProtoField.string("xpl.type","Message type")
local f_hop = ProtoField.string("xpl.hop","Hop count")
local f_source = ProtoField.string("xpl.source","Source address")
local f_sourcev = ProtoField.string("xpl.source.vendor","Source VendorID")
local f_sourced = ProtoField.string("xpl.source.device","Source DeviceID")
local f_sourcei = ProtoField.string("xpl.source.instance","Source InstanceID")
local f_target = ProtoField.string("xpl.target","Target address")
local f_targetv = ProtoField.string("xpl.target.vendor","Target VendorID")
local f_targetd = ProtoField.string("xpl.target.device","Target DeviceID")
local f_targeti = ProtoField.string("xpl.target.instance","Target InstanceID")
local f_schema = ProtoField.string("xpl.schema","Message schema")
local f_schemac = ProtoField.string("xpl.schema.class","Message schema-class")
local f_schemat = ProtoField.string("xpl.schema.type","Message schema-type")
xpl_proto.fields = {
		f_type,
		f_hop,
		f_source,
		f_sourcev,
		f_sourced,
		f_sourcei,
		f_target,
		f_targetv,
		f_targetd,
		f_targeti,
		f_schema,
		f_schemac,
		f_schemat }

-- Construct validation ranges for message elements
local key_valid   = "abcdefghijklmnopqrstuvwxyz0123456789-"	-- structural elements
local addr_valid  = "abcdefghijklmnopqrstuvwxyz0123456789"	-- no hyphen in address
local value_valid = ""										-- values in body
local n
for n = 32, 126 do
	value_valid = value_valid .. string.char(n)
end
local value_valid2 = value_valid							-- values in body, UTF8 encoded
for n = 127, 255 do
	value_valid2 = value_valid2 .. string.char(n)
end


-- Verifies if all characters in a string are valid according to a given set, additionally
-- checks the minimum and maximum allowed length
local function isvalid(val, allowedlist, min, max)
	min = min or 0
	max = max or 99999
	allowedlist = allowedlist or ""
	local n
	if val ~= nil then
		if string.len(val) < min then
			return false		-- too short
		end
		if string.len(val) > max then
			return false		-- too long
		end
		for n = 1, string.len(val) do
			local result = false
			for i = 1, string.len(allowedlist) do
				if string.sub(val,n,n) == string.sub(allowedlist,i,i) then
					-- found it, so its allowedlist
					result = true
					break
				end
			end
			if result == false then
				-- character not found, so failed
				return false
			end
		end
	else
		return false	-- nil results in Failed
	end
	return true
end

-- utility string split function
local function split (str, patt)
	vals = {}; valindex = 1; word = ""
	-- need to add a trailing separator to catch the last value.
	str = str .. patt
	for i = 1, string.len(str) do
		cha = string.sub(str, i, i)
		if cha ~= patt then
			word = word .. cha
		else
			if word ~= nil then
				vals[valindex] = word
				valindex = valindex + 1
				word = ""
			else
				-- in case we get a line with no data.
				break
			end
		end

	end
	return vals
end

-- utility key-value split function
-- sample; k, v = keyvalue("keyword=value")  -->  k == "keyword", v = "value"
-- sep defaults to '='
local function keyvalue(str, sep)
	local k, v, l
	sep = sep or "="
	local t = split(str, sep)
	k = t[1]
	if k == nil then
		v = nil
	else
		l = string.len(k) + 2
		if l > string.len(str) then
			v = ""
		else
			v = string.sub(str, l)
		end
	end
	return k, v
end


-- create a function to dissect it
function xpl_proto.dissector(buffer,pinfo,tree)

	-- verify that the first 4 characters are 'xpl-', otherwise its not an xpl message and exit
	local isxpl = false
	if buffer:len() > 4 then
		local rng = buffer:range(0, 4)
		local str = string.lower(rng:string())
		if str == "xpl-" then
			isxpl = true
		end
		local rng = nil
		local str = nil
	end
	if not isxpl then
		return
	end

    pinfo.cols.protocol = "xPL"
	local rng = buffer:range()		-- convert to range
	local msg = rng:string()		-- convert range to bytearray
	local x = split(msg, "\n")		-- split in table with individual lines


	-- get source and target adddress for header display
	local src
	local dst
	if x[5] ~= nil then
		src = split(x[4], "=")[2]	-- 4th line is source address
		dst = split(x[5], "=")[2]   -- 5th line is destination address
	end
	if src == nil then
		src = "'unknown'"
	else
		src = "'" .. src .."'"
	end
	if dst == nil then
		dst = "'unknown'"
	else
		if dst == "*" then
			dst = "Broadcast ('*')"
		else
			dst = "'" .. dst .. "'"
		end
	end
	-- create header text and add it to the tree
	local desc = "xPL Protocol, Src: " .. src .. ", Dst: " .. dst
    local mtree = tree:add(xpl_proto,buffer(), desc)
	mtree:add(buffer(),"xPL data size: " .. buffer:len() .. " bytes")


	-- Create the message sub tree and fill it with the message in plain text format
	local subtree = mtree:add(buffer(),"xPL Message")
	local cnt = 0
	local i
	local lines = {}
	for i,line in ipairs(x) do
		local l = string.len(line) + 1
		if line ~= "" then		-- last line is empty, but shouldn't display
			if cnt + l <= buffer:len()  then
				lines[i] = subtree:add(buffer(cnt,l), line)
			else
				-- probably the trailing LF after the last } is missing
				lines[i] = subtree:add(buffer(cnt,buffer:len() - cnt ), line)
			end
		end
		cnt = cnt + l
	end


	-- create the field subtree and message verification subtree
    local ftree = mtree:add(xpl_proto,buffer(),"xPL Fields")		-- Field tree
    --local etree = mtree:add(xpl_proto,buffer(),"xPL Verification")	-- Error tree
	local val, k, v, ok
	local errors = {}
	cnt = 0			-- pointer to current position in buffer
	-- xpl message type
	val = x[1]
	if val ~= nil then
		ftree:add(f_type, buffer(cnt, string.len(val)))
		if val ~= string.lower(val) then
			lines[1]:add_expert_info(PI_MALFORMED, PI_ERROR, "Message type should be all lowercase")
			--etree:add(buffer(cnt, string.len(val)),"Line 1; Message type should be all lowercase")
			val = string.lower(val)
		end
		if val ~= "xpl-cmnd" then
			if val ~= "xpl-trig" then
				if val ~= "xpl-stat" then
					lines[1]:add_expert_info(PI_MALFORMED, PI_ERROR, "Unknown message type, line must be either xpl-cmnd, xpl-trig or xpl-stat")
					--etree:add(buffer(cnt, string.len(val)),"Line 1; Unknown message type, line must be either xpl-cmnd, xpl-trig or xpl-stat")
				end
			end
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[1]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 1; missing, must be either xpl-cmnd, xpl-trig or xpl-stat")
		--etree:add(buffer(),"Line 1; missing, must be either xpl-cmnd, xpl-trig or xpl-stat")
	end
	-- open accolade
	val = x[2]
	if val ~= nil then
		if val ~= "{" then
			lines[2]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line should must be a single opening accolade '{'")
			--etree:add(buffer(cnt, string.len(val)),"Line 2; Line should must be a single opening accolade '{'")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[2]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 2; missing, must be a single opening accolade '{'")
		--etree:add(buffer(),"Line 2; missing, must be a single opening accolade '{'")
	end
	-- Hop count
	val = x[3]
	if val ~= nil then
		k,v = keyvalue(val)
		ok = true
		if not isvalid(k, key_valid, 3, 3) or not isvalid(v, "0123456789" , 1 , 6) then
			ok = false
		else
			if k ~= "hop" then
				ok = false
			else
				ftree:add(f_hop, buffer(cnt + 4, string.len(v)))
			end
		end
		if not ok then
			lines[3]:add_expert_info(PI_MALFORMED, PI_ERROR, "Should contain 'hop=X' where X is a numeric (integer) value")
			--etree:add(buffer(),"Line 3; should contain 'hop=X' where X is a numeric (integer) value")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[3]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 3; missing, should contain the message hop-count as 'hop=X' where X is a numeric (integer) value")
		--etree:add(buffer(),"Line 3; missing, should contain the message hop-count as 'hop=X' where X is a numeric (integer) value")
	end
	-- Source address
	val = x[4]
	if val ~= nil then
		k,v = keyvalue(val)
		ftree:add(f_source, buffer(cnt + string.len(k) + 1, string.len(v)))
		ok = true
		local p1, p2, p3	-- address parts
		if k ~= "source" then
			ok = false
		else
			if v == "*" then
				ok = false	-- wildcard not allowed in source address
				lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Wildcard 'source=*' is not allowed for a source address")
				--etree:add(buffer(),"Line 4; wildcard 'source=*' is not allowed for a source address")
			else
				local temp
				temp = split(v, "-")
				p1 = temp[1]
				temp = temp[2] or ""
				temp = split(temp, ".")
				p2 = temp[1]
				p3 = temp[2] or ""
				if not isvalid(p1, addr_valid, 1, 8) then
					ok = false	-- no vendorid
					lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid vendorid, max 8 characters, using a-z and 0-9")
					--etree:add(buffer(),"Line 4; invalid vendorid, max 8 characters, using a-z and 0-9")
				else
					if not isvalid(p2, addr_valid, 1, 8) then
						ok = false -- no deviceid
						lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid deviceid, max 8 characters, using a-z and 0-9")
						--etree:add(buffer(),"Line 4; invalid deviceid, max 8 characters, using a-z and 0-9")
					else
						if not isvalid(p3, key_valid, 1, 16) then
							ok = false	-- no instance id
							lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid instanceid, max 16 characters, using a-z, 0-9 and '-'")
							--etree:add(buffer(),"Line 4; invalid instanceid, max 16 characters, using a-z, 0-9 and '-'")
						else
							-- parts are valid, add to list
							ftree:add(f_sourcev, buffer(cnt + 7, string.len(p1)))
							ftree:add(f_sourced, buffer(cnt + 7 + string.len(p1) + 1, string.len(p2)))
							ftree:add(f_sourcei, buffer(cnt + 7 + string.len(p1) + 1 + string.len(p2) + 1, string.len(p3)))
						end
					end
				end
			end
		end
		if not ok then
			lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 4; should contain the source address as 'source=VENDOR-DEVICE.INSTANCE', wildcard 'source=*' is not allowed")
			--etree:add(buffer(),"Line 4; should contain the source address as 'source=VENDOR-DEVICE.INSTANCE', wildcard 'source=*' is not allowed")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[4]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 4; missing, should contain the source address as 'source=VENDOR-DEVICE.INSTANCE', wildcard 'source=*' is not allowed")
		--etree:add(buffer(),"Line 4; missing, should contain the source address as 'source=VENDOR-DEVICE.INSTANCE', wildcard 'source=*' is not allowed")
	end
	-- Destination address
	val = x[5]
	if val ~= nil then
		k,v = keyvalue(val)
		ftree:add(f_target, buffer(cnt + string.len(k) + 1, string.len(v)))
		ok = true
		local p1, p2, p3	-- address parts
		if k ~= "target" then
			ok = false
		else
			if v == "*" then
				ftree:add(f_targetv, buffer(cnt + 7, 1))
				ftree:add(f_targetd, buffer(cnt + 7, 1))
				ftree:add(f_targeti, buffer(cnt + 7, 1))
			else
				if string.lower(x[1]) ~= "xpl-cmnd" then
					lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Target address must be broadcast ('*') if the message type is not 'xpl-cmnd'")
					--etree:add(buffer(),"Line 5; Target address must be broadcast ('*') if the message type is not 'xpl-cmnd'")
				end
				temp = split(v, "-")
				p1 = temp[1]
				temp = temp[2] or ""
				temp = split(temp, ".")
				p2 = temp[1]
				p3 = temp[2] or ""
				if not isvalid(p1, addr_valid, 1, 8) then
					ok = false	-- no vendorid
					lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid vendorid, max 8 characters, using a-z and 0-9")
					--etree:add(buffer(),"Line 5; invalid vendorid, max 8 characters, using a-z and 0-9")
				else
					if not isvalid(p2, addr_valid, 1, 8) then
						ok = false -- no deviceid
						lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid deviceid, max 8 characters, using a-z and 0-9")
						--etree:add(buffer(),"Line 5; invalid deviceid, max 8 characters, using a-z and 0-9")
					else
						if not isvalid(p3, addr_valid, 1, 16) then
							ok = false	-- no instance id
							lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Invalid instanceid, max 16 characters, using a-z and 0-9")
							--etree:add(buffer(),"Line 5; invalid instanceid, max 16 characters, using a-z and 0-9")
						else
							-- parts are valid, add to list
							ftree:add(f_targetv, buffer(cnt + 7, string.len(p1)))
							ftree:add(f_targetd, buffer(cnt + 7 + string.len(p1) + 1, string.len(p2)))
							ftree:add(f_targeti, buffer(cnt + 7 + string.len(p1) + 1 + string.len(p2) + 1, string.len(p3)))
						end
					end
				end
			end
		end
		if not ok then
			lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Should contain the target address as 'target=VENDOR-DEVICE.INSTANCE', or 'target=*' for a broadcast")
			--etree:add(buffer(),"Line 5; should contain the target address as 'target=VENDOR-DEVICE.INSTANCE', or 'target=*' for a broadcast")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[5]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 5; missing, should contain the target address as 'target=VENDOR-DEVICE.INSTANCE', or 'target=*' for a broadcast")
		--etree:add(buffer(),"Line 5; missing, should contain the target address as 'target=VENDOR-DEVICE.INSTANCE', or 'target=*' for a broadcast")
	end
	-- close accolade
	val = x[6]
	if val ~= nil then
		if val ~= "}" then
			lines[6]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line must be a single closing accolade '}'")
			--etree:add(buffer(),"Line 6; Line must be a single closing accolade '}'")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[6]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 6; missing, must be a single closing accolade '}'")
		--etree:add(buffer(),"Line 6; missing, must be a single closing accolade '}'")
	end
	-- schema
	val = x[7]
	if val ~= nil then
		ftree:add(f_schema, buffer(cnt, string.len(val)))
		ok = true
		local cls, typ	-- schema parts
		cls = split(val, ".")[1]
		if string.len(cls) + 1 >= string.len(val) then
			-- no type
			typ = ""
		else
			typ = string.sub(val, string.len(cls) + 2)
		end
		ftree:add(f_schemac, buffer(cnt, string.len(cls)))
		ftree:add(f_schemat, buffer(cnt + string.len(cls) + 1, string.len(typ)))
		if not isvalid(cls, key_valid, 1, 8) then
			lines[7]:add_expert_info(PI_MALFORMED, PI_ERROR, "invalid schema class, max 8 characters, a-z, 0-9 and '-'")
			--etree:add(buffer(),"Line 7; invalid schema class, max 8 characters, a-z, 0-9 and '-'")
			ok = false
		end
		if not isvalid(typ, key_valid, 1, 8) then
			lines[7]:add_expert_info(PI_MALFORMED, PI_ERROR, "invalid schema type, max 8 characters, a-z, 0-9 and '-'")
			--etree:add(buffer(),"Line 7; invalid schema type, max 8 characters, a-z, 0-9 and '-'")
			ok = false
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[7]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 7; missing, should contain the message schema as 'schema=CLASS.TYPE'")
		--etree:add(buffer(),"Line 7; missing, should contain the message schema as 'schema=CLASS.TYPE'")
	end
	-- open accolade
	val = x[8]
	if val ~= nil then
		if val ~= "{" then
			lines[8]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line should be restricted to only a single opening accolade '{'")
			--etree:add(buffer(cnt, string.len(val)),"Line 8; Line should be restricted to only a single opening accolade '{'")
		end
		cnt = cnt + string.len(val) + 1
	else
		lines[8]:add_expert_info(PI_MALFORMED, PI_ERROR, "Line 8; missing, must be a single opening accolade '{'")
		--etree:add(buffer(),"Line 8; missing, must be a single opening accolade '{'")
	end
	-- close accolade
	val = x[table.getn(x)]
	if val ~= nil then
		if val == "" then
			-- OK
			x[table.getn(x)] = nil		-- delete empty line
			val = x[table.getn(x)]
			if val == "}" then
				-- OK, correct closing accolade
				x[table.getn(x)] = nil	-- delete the accolade so we only have values to iterate left
			else
				-- there something unknown on this line, leave it to try fix value in next part
				lines[table.getn(x)]:add_expert_info(PI_MALFORMED, PI_ERROR, "Last line; Line should be restricted to only a single closing accolade '}' and a final linefeed (0x0A)")
				--etree:add(buffer(),"Last line; Line should be restricted to only a single closing accolade '}' and a final linefeed (0x0A)")
			end
		else
			-- Not OK
			if val == "}" then
				-- here's the accolade, so last linefeed is missing
				lines[table.getn(x)]:add_expert_info(PI_MALFORMED, PI_ERROR, "Last line; The single closing accolade '}' is missing the final linefeed (0x0A)")
				--etree:add(buffer(),"Last line; The single closing accolade '}' is missing the final linefeed (0x0A)")
				x[table.getn(x)] = nil	-- delete the accolade so we only have values to iterate left
			else
				-- there something unknown on this line, leave it to try fix value in next part
				lines[table.getn(x)]:add_expert_info(PI_MALFORMED, PI_ERROR, "Last line; Line should be restricted to only a single closing accolade '}' and a final linefeed (0x0A)")
				--etree:add(buffer(),"Last line; Line should be restricted to only a single closing accolade '}' and a final linefeed (0x0A)")
			end
		end
	end
	-- handle key-value pairs in body
	for i = 9, table.getn(x) do
		val = x[i]
		k,v = keyvalue(val)
		ok = true
		if not isvalid(k, key_valid, 1, 16) then
			lines[i]:add_expert_info(PI_MALFORMED, PI_ERROR, "Key of key-value pair is invalid, max 16 characters, a-z, 0-9 and '-'")
			--etree:add(buffer(cnt, string.len(k)),"Line " .. i .. "; key of key-value pair is invalid, max 16 characters, a-z, 0-9 and '-'")
			ok = false
		end
		if string.len(v) > 128 then
			lines[i]:add_expert_info(PI_MALFORMED, PI_WARN, "Value of key-value pair has more than 128bytes. Is allowed, but might be incompatible with older applications.")
		end
		if not isvalid(v, value_valid, 0, nil) then
			-- not valid against ASCII, now validate against UTF8
			if not isvalid(v, value_valid2, 0, nil) then
				-- Neither valid on UTF8 nor ASCII
				lines[i]:add_expert_info(PI_MALFORMED, PI_ERROR, "Value of key-value pair is invalid, only use; UTF8 or ASCII encoding, bytes values 32-255")
				--etree:add(buffer(cnt + string.len(k) + 1, string.len(v)),"Line " .. i .. "; value of key-value pair is invalid, max 128 characters, ASCII codes 32-126")
				ok = false
			else
				-- warn for UTF8 incompatibilities
				lines[i]:add_expert_info(PI_MALFORMED, PI_WARN, "Value of key-value pair contains byte values 127-255, probably UTF8 encoding. Is allowed but might be incompatible with older applications")
			end
		end
		if not ((k .. "=" .. v) == val) then
			lines[i]:add_expert_info(PI_MALFORMED, PI_ERROR, "key-value pair is invalid, no '=' included. Line should be composed as 'key=value'")
			--etree:add(buffer(cnt + string.len(k) + 1, string.len(v)),"Line " .. i .. "; key-value pair is invalid, no '=' included. Line should be composed as 'key=value'")
			ok = false
		end
		cnt = cnt + string.len(val) + 1
	end
end


-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
-- register our protocol to handle udp port 3865
udp_table:add(3865,xpl_proto)
