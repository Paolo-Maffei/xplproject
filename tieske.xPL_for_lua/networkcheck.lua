--- Network connection check module
-- @author Thijs Schreijer
-- @copyright 2011 Thijs Schreijer
-- @release version 0.1, unreleased yet

socket = require ("socket")

--- Checks the network connection of the system and detects changes in connection or IP adress.
-- Call repeatedly to check status for changes. With every call include the previous results to compare with.
-- @param oldState (table) previous result to compare with, or nil if not called before
-- @return changed (boolean) same as <code>newstate.changed</code> (see below), the initial call will always return <code>true</code>.
-- @return newState (table) same as regular info from <code>socket.dns</code> calls, but extended with;
-- <ul><li><code>localhostname </code>= (string) name of localhost (only field that can be set, defaults to <code>'localhost'</code>)</li>
-- <li><code>localhostip   </code>= (string) ip address for localhostname</li>
-- <li><code>connected     </code>= (string) either <code>'yes'</code>, <code>'no'</code>, or <code>'loopback'</code> (loopback means connected to localhost, no external connection)</li>
-- <li><code>changed       </code>= (boolean) true if oldstate is different on; <code>name</code>, <code>connected</code>, or <code>ip[1]</code> properties</li></ul>
-- @usage function test()
--     print ("TEST: entering endless check loop, change connection settings and watch the changes come in...")
--     require ("base")	-- from stdlib
--     local change, data
--     while true do
--         change, data = checkconnection(data)
--         if change then
--             print (tostring(data))
--         end
--     end
-- end
function checkconnection (oldState)
	oldState = oldState or {}
	oldState.alias = oldState.alias or {}
	oldState.ip = oldState.ip or {}
	local sysname = socket.dns.gethostname()
	local newState = {
				name = sysname or "no name resolved",
				localhostname = oldState.localhostname or "localhost",
				localhostip = socket.dns.toip(oldState.localhostname or "localhost") or "127.0.0.1",
				alias = {},
				ip = {},
			}
	if not sysname then
		newState.connected = "no"
	else
		local sysip, data = socket.dns.toip(sysname)
		if sysip then
			newState.ip = data.ip
			newState.alias = data.alias
			if newState.ip[1] == newState.localhostip then
				newState.connected = "loopback"
			else
				newState.connected = "yes"
			end
		else
			newState.connected = "no"
		end
	end
	newState.changed = (oldState.name ~= newState.name or oldState.ip[1] ~= newState.ip[1] or newState.connected ~= oldState.connected)
	return newState.changed, newState
end







local function test()
	print ("TEST: entering endless check loop, change connection settings and watch the changes come in...")
	require ("base")	-- from stdlib
	local change, data
	while true do
		change, data = checkconnection(data)
		if change then
			print (tostring(data))
		end
	end
end

test()
