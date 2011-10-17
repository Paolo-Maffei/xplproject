-- xPL library, copyright 2011, Thijs Schreijer
--
--
-- When this file is 'required' it will create a global 'hal' table for
-- xPL HAL related stuff. It will return an xPLDevice object that can be
-- registered with the listener to run.
-- The device will initialize/start/stop the xPL HAL server when the
-- corresponding methods on the device are invoked (by the listener)

require ("xpl")
local luasocket = require("socket")
local copas = require("copas")
local scheduler = require("xplhal.scheduler")

-- create global HAL table
hal = {
    -- Meta information is public even if beginning with an "_"
    _COPYRIGHT   = "Copyright (C) 2011 Thijs Schreijer",
    _DESCRIPTION = "xPL HAL homeautomation server for Lua",
    _VERSION     = "0.1",
    _XHCPVERSION = "1.5",
    }

local baseclass = xpl.classes.xpldevice
local xpldevice = {}

-----------------------------------------------------------------------------------------
-- Initializes the xpldevice.
-- Will be called upon instantiation of an object (when this file is 'required').
function xpldevice:initialize()
    -- call ancestor
    self.super.initialize(self)

    -- add your stuff here
	self.address = xpl.createaddress("tieske", "hal", "HOST")
    -- go initialize xPL HAL
    hal:initialize()
end

-----------------------------------------------------------------------------------------
-- Starts the xpldevice.
-- The listener will automatically call this method just before starting the network activity.
function xpldevice:start()
    -- call ancestor
    self.super.start(self)

    -- add your stuff here
    hal:start()
end

-----------------------------------------------------------------------------------------
-- Stops the xpldevice.
-- It will unregister the device from the xpllistener and stop the heartbeat sequence
function xpldevice:stop()

    -- add your stuff here
    hal:stop()

    -- call ancestor
    self.super.stop(self)
end

-----------------------------------------------------------------------------------------
-- Handler for incoming messages.
-- It will handle only the heartbeat messages (echos) to verify the devices own connection.
-- @param msg the xplmessage object that has to be handled
-- @return the message received or <code>nil</code> if it was fully handled
function xpldevice:handlemessage(msg)

    -- add your stuff here, for the raw unhandled message, still has echos, hbeat,
    -- non-filtered stuff etc.


    -- call ancestor, will handle heartbeat, filtermatching, clearing echos
    msg = self.super.handlemessage(self, msg)

    if msg then

       -- add your stuff here, message is yet unhandled, but passed the filter

    end

    return msg
end

-----------------------------------------------------------------------------------------
-- Heartbeat message creator.
-- Will be called to create the heartbeat message to be send. Override this function
-- to modify the hbeat content.
-- @param exit if true then an exit hbeat message, for example 'hbeat.end' needs to be created.
-- @return xplmessage object with the heartbeat message to be sent.
function xpldevice:createhbeatmsg(exit)

    -- call ancestor
    local msg = self.super.createhbeatmsg(self, exit)


    -- add your stuff here


    return msg
end

-----------------------------------------------------------------------------------------
-- Handler called whenever the device status changes. Override this method
-- to implement code upon status changes.
-- @param newstatus the new status of the device
-- @param oldstatus the previous status
function xpldevice:statuschanged(newstatus, oldstatus)
    -- call ancestor
    local msg = self.super.statuschanged(self, newstatus, oldstatus)


    -- add your stuff here


end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- xPL HAL main code
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- Globals
hal.globals = {
    -- list of HAL globals
    }

-- locals
local halserver                     -- the xPL HAL socket for listening on XHCP protocol
local cmdtimeout = 10               -- timeout while receiving asingle command
local sessiontimeout = 5 * 60       -- session timeout, 5 minutes
local crlf = string.char(13,10)     -- XHCP line terminator

local response = {
    [200] = '200 %s Version %s XHCP %s ready' .. crlf,
    [201] = '201 Reload successful' .. crlf,
    [203] = '203 Script executed' .. crlf,
    [204] = '204 List of settings follows' .. crlf,
    [205] = '205 List of options follows' .. crlf,
    [206] = '206 Setting updated' .. crlf,
    [207] = '207 Error log follows' .. crlf,
    [208] = '208 Requested setting follows' .. crlf,
    [209] = '209 Configuration document follows' .. crlf,
    [210] = '210 Requested script follows' .. crlf,
    [211] = '211 Script saved successfully' .. crlf,
    [212] = '212 List of scripts follows' .. crlf,
    [213] = '213 XPL message transmitted' .. crlf,
    [214] = '214 Script successfully deleted' .. crlf,
    [215] = '215 Configuration document uploaded' .. crlf,
    [216] = '216 List of XPL devices follows' .. crlf,
    [217] = '217 List of config items follows' .. crlf,
    [218] = '218 List of events follows' .. crlf,
    [219] = '219 Event added successfully' .. crlf,
    [220] = '220 Configuration items received successfully' .. crlf,
    [221] = '221 Closing connection - good bye' .. crlf,
    [222] = '222 Event information follows' .. crlf,
    [223] = '223 Event deleted successfully' .. crlf,
    [224] = '224 List of subs follows' .. crlf,
    [225] = '225 Error log cleared' .. crlf,
    [229] = '229 Sub-routine follows' .. crlf,
    [230] = '230 Replication mode active' .. crlf,
    [231] = '231 List of global variables follows' .. crlf,
    [232] = '232 Global value updated' .. crlf,
    [233] = '233 Global variable deleted' .. crlf,
    [234] = '234 Configuration item value(s) follow' .. crlf,
    [235] = '235 Device configuration deleted' .. crlf,
--    [236] = '236 Capabilities string' .. crlf,            will be built dynamically
    [237] = '237 List of Determinator Rules follows' .. crlf,
    [238] = '238 Rule added successfully' .. crlf,
    [239] = '239 Status information follows' .. crlf,
    [240] = '240 List of determinator groups follows' .. crlf,
--    [241] = '241 Capabilities/subsystem information follows' .. crlf,     -- will be built dynamically
    [242] = '242 Script saved - additional information follows' .. crlf,
    [291] = '291 Global value follows' .. crlf,
    [311] = '311 Enter script, end with <CrLf>.<CrLf>' .. crlf,
    [313] = '313 Send message to be transmitted, end with <CrLf>.<CrLf>' .. crlf,
    [315] = '315 Enter configuration document, end with <CrLf>.<CrLf>' .. crlf,
    [319] = '319 Enter event data, end with <CrLf>.<CrLf>' .. crlf,
    [320] = '320 Send configuration items, end with <CrLf>.<CrLf>' .. crlf,
    [328] = '328 Send rule, end with <CrLf>.<CrLf>' .. crlf,
    [401] = '401 Reload failed' .. crlf,
    [403] = '403 Script not executed' .. crlf,
    [405] = '405 No such setting' .. crlf,
    [410] = '410 No such script' .. crlf,
    [416] = '416 No config available for specified device' .. crlf,
    [417] = '417 No such device' .. crlf,
    [418] = '418 No vendor information available for specified device.' .. crlf,
    [422] = '422 No such event' .. crlf,
    [429] = '429 No such sub-routine' .. crlf,
    [491] = '491 No such global' .. crlf,
    [500] = '500 Command not recognised' .. crlf,
    [501] = '501 Syntax error' .. crlf,
    [502] = '502 Permission denied' .. crlf,
    [503] = '503 Internal error - command not performed' .. crlf,
    [530] = '530 A replication client is already active' .. crlf,
    [600] = '600 Replication data follows' .. crlf,
}

--------------------------------------------------------------------------
-- Reads the remainder of a multiline command to be received
-- @param skt socket to read from
-- @return table with lines received or nil with error
local readbody = function(skt)
    local lines = {}
    local newline, err
    while not newline == "." do
        newline, err = skt:receive('*l', cmdtimeout)
        if not newline then
            -- we had an error
            return nil, err
        end
        if newline == "." then          -- we're complete
            -- nothing to do
        elseif newline == ".." then     -- escaped, unescape
            table.insert(lines, ".")
        else                            -- add line to command body
            table.insert(lines, newline)
        end
    end
    return lines
end

--------------------------------------------------------------------------
-- Sends the multiline response
-- @param skt socket to send through
-- @param lines list with strings to send
-- @return true or nil and error
local sendbody = function(skt, lines)
    local res, err
    for i, line in ipairs(lines) do
        if line == "." then line = ".." end     -- escape single dots
        res, err = skt:send(line .. crlf)
        if not res then
            return res, err
        end
    end
    res, err = skt:send("." .. crlf)            -- send closing line
    if not res then
        return res, err
    end
    return true
end


--------------------------------------------------------------------------
-- Executes a sub routine
-- @param subname string, name of the sub routine to execute
-- @param params string with parameters for the sub.
executesub = function(subname, params)
    -- TODO
end

--------------------------------------------------------------------------
-- Cleanup string to single line, that can be properly send
-- @param str string to cleanup
-- @return string without any CR and/or LF characters
local cleanmessage = function(str)
    str = str or ""
    str = string.gsub(str, crlf, " ")
    str = string.gsub(str, string.char(13), " ")
    str = string.gsub(str, string.char(10), " ")
    return str
end

local command = {

    ADDEVENT = function(skt, param)
        skt:send(response[319])     -- request event data
        local data = readbody(skt)
        if not data then
            -- some error
            skt:send(response[503])
            return
        end
        -- parse event data
        local event = {
                dow = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false },
                endtime = 0,
                interval = 60,
                params = "",
                rand = 0,
                starttime = 0,
                subname = "undefined",
                tag = "undefined"
            }
        for i,line in ipairs(data) do
            local key, val = string.match(line, "(.-)=(.*)")
            key = string.lower(key)

            if key == "dow" then
                -- expected 7 characters 0 or 1, pos 1 = sunday, pos 7 = saturday
                local dow = {}
                val = val .. "1111111"
                for i = 1, 7 do
                    dow[i] = (string.sub(val,i,i) == "1")
                end
                event.dow = dow
            elseif key == "endtime" then
                -- expected time in HH:MM format
                local h,m = string.match(val, "^([%d][%d]?):([%d][%d])$")
                h = h or 0
                m = m or 0
                event.endtime = h * 60 + m
            elseif key == "interval" then
                -- expected number of minutes
                event.interval = tonumber(val) or 0
            elseif key == "params" then
                -- expect string
                event.params = val
            elseif key == "rand" then
                -- expected number of minutes
                event.rand = tonumber(val) or 0
            elseif key == "starttime" then
                -- expected time in HH:MM format
                local h,m = string.match(val, "^([%d][%d]?):([%d][%d])$")
                h = h or 0
                m = m or 0
                event.starttime = h * 60 + m
            elseif key == "subname" then
                -- expect string
                event.subname = val
            elseif key == "tag" then
                -- expect string
                event.tag = val
            else
                -- unknown key, do nothing
            end
        end
        -- Add to scheduler
        hal.scheduler:addevent(event)

        skt:send(response[219]) -- event added success
        return true -- return nil plus error to indicate error and close connection
    end,

    ADDSINGLEEVENT = function(skt, param)
        skt:send(response[319])     -- request event data
        local data = readbody(skt)
        if not data then
            -- some error
            skt:send(response[503])
            return
        end
        -- parse event data
        local event = {
                day = 1,
                month = 1,
                year = 2010,
                starttime = 0,
                params = {},
                subname = "undefined",
                tag = "undefined",
            }
        for i,line in ipairs(data) do
            local key, val = string.match(line, "(.-)=(.*)")
            key = string.lower(key)

            if key == "date" then
                -- expected time in DD/MMM/YYYY HH:MM format
                local d, m, y, h, min = string.match(val, "^([%d][%d]?)/(.-)/([%d][%d][%d][%d]) ([%d][%d]?):([%d][%d])$")
                d = d or 1
                m = m or 1
                y = y or 2099
                h = h or 0
                min = min or 0
                -- check month value
                if not isnumber(m) then
                    local tm = { JAN = 1, FEB = 2, MAR = 3, APR = 4, MAY = 5, JUN = 6, JUL = 7, AUG = 8, SEP = 9, OCT = 10, NOV = 11, DEC = 12 }
                    m = tm[string.upper(m)] or 1
                end
                event.day = d
                event.month = m
                event.year = y
                event.minute = h * 60 + min
            elseif key == "params" then
                -- expect string
                event.params = val
            elseif key == "subname" then
                -- expect string
                event.subname = val
            elseif key == "tag" then
                -- expect string
                event.tag = val
            else
                -- unknown key, do nothing
            end
        end

        -- Add to scheduler
        hal.scheduler:addevent(event)

        skt:send(response[219]) -- event added success
        return true -- return nil plus error to indicate error and close connection
    end,

    CAPABILITIES = function(skt, param)
        local cap = ""
        -- Config manager
        cap = cap .. "-"    -- unsupported
        -- xAP support
        cap = cap .. "-"    -- unsupported
        -- Default scripting language
        cap = cap .. "L"    -- Lua
        -- Determinator support
        cap = cap .. "0"    -- unsupported  TODO
        -- Event support
        cap = cap .. "1"    -- supported
        -- Server platform
        cap = cap .. "L"    -- platform independent, but for the sakem of it choose Linux
        -- State tracking support
        cap = cap .. "0"    -- unknown? what is this, unsupported for now

        param = string.upper(param or "")
        if param == "SCRIPTING" then
            -- capabilities with scripting listed
            cap = "241 " .. cap .. crlf .. "L\tLua\t5.1\tlua\thttp://www.lua.org/" .. crlf .. "." .. crlf
        else
            -- capabilities only
            cap = "236 " .. cap .. crlf
        end
        skt:send(cap)
        return true -- return nil plus error to indicate error and close connection
    end,

    CLEARERRLOG = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    DELDEVCONFIG = function(skt, param)
        -- unsupported
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    DELEVENT = function(skt, param)
        if hal.scheduler:getevent(param) then
            -- Remove from scheduler
            hal.scheduler:removeevent(param)
            skt:send(response[223])     -- success
        else
            skt:send(response[422])     -- not found
        end
        return true -- return nil plus error to indicate error and close connection
    end,

    DELGLOBAL = function(skt, param)
        if param then hal.globals[param] = nil end
        skt:send(response[233]) -- success
        return true -- return nil plus error to indicate error and close connection
    end,

    DELRULE = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    DELSCRIPT = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETCONFIGXML = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETDEVCONFIG = function(skt, param)
        -- not supported
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETDEVCONFIGVALUE = function(skt, param)
        -- not supported
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETERRLOG = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETEVENT = function(skt, param)
        local ev = hal.scheduler:getevent(param)
        if ev then
            -- setup response message
            skt:send(response[222])     -- event follows
            local lines = {}
            local line
            if ev.dow then
                -- repeating event
                line = "dow="
                for i = 1,7 do
                    if ev.dow[i] then
                        line = line .. "1"
                    else
                        line = line .. "0"
                    end
                end
                table.insert(lines, line)
                line = "endtime=" .. string.format("%02d:%02d", math.floor(ev.endtime/60),ev.endtime - math.floor(ev.endtime/60) * 60)
                table.insert(lines, line)
                line = "interval=" .. tostring(ev.interval)
                table.insert(lines, line)
                line = "rand=" .. tostring(ev.rand)
                table.insert(lines, line)
                line = "starttime=" .. string.format("%02d:%02d", math.floor(ev.starttime/60),ev.starttime - math.floor(ev.starttime/60) * 60)
                table.insert(lines, line)
            else
                -- single event
                local m = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" }
                line = "date=" .. string.format("%02d/%s/%04d %02d:%02d", ev.day, m[ev.month], ev.year, math.floor(ev.starttime/60),ev.starttime - math.floor(ev.starttime/60) * 60)
            end
            table.insert(lines,"params=" .. ev.params)
            table.insert(lines,"subname=" .. ev.subname)
            table.insert(lines,"tag=" .. ev.tag)
            sendbody(skt, lines)
        else
            skt:send(response[422])     -- not found
        end

        return true -- return nil plus error to indicate error and close connection
    end,

    GETGLOBAL = function(skt, param)
        if hal.globals[param] == nil then
            skt:send(response[491])     -- not found
        else
            skt:send(response[291])     -- value follows
            local line = string.format("%q", tostring(hal.globals[param]))
            sendbody(skt, {line})
        end
        return true -- return nil plus error to indicate error and close connection
    end,

    GETRULE = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETSCRIPT = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    GETSETTING = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTALLDEVS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTDEVICES = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTEVENTS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTGLOBALS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTOPTIONS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTRULEGROUPS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTRULES = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTSCRIPTS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTSETTINGS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTSINGLEEVENTS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    LISTSUBS = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    MODE = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    PUTCONFIGXML = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    PUTDEVCONFIG = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    PUTSCRIPT = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    RELOAD = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    REPLINFO = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    RUNRULE = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    RUNSUB = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    SENDXAPMSG = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    SENDXPLMSG = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    SETGLOBAL = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    SETRULE = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    SETSETTING = function(skt, param)
        -- TODO
        skt:send(response[503])
        return true -- return nil plus error to indicate error and close connection
    end,

    QUIT = function(skt, param)
        skt:send(response[221])
        return true -- return nil plus error to indicate error and close connection
    end,
}


-- handler for the incoming XHCP requests
local xhcp = function(sk1)
    skt = copas.wrap(sk1)
    skt:settimeout(cmdtimeout)
    local sessiontimer = 0
    local exit

    -- send welcome message
    local res, err = skt:send(string.format(response[200],hal.device.address, hal._VERSION, hal._XHCPVERSION))
    if not res then
        -- error while connecting
        exit = true -- exit immediately
    end
    -- enter client connection loop
    while not exit do
print("start receiving")
        local reqdata, err = skt:receive('*l')
print ("received", reqdata, err)
        if not reqdata then
            -- error reported
            if err == "timeout" then
                -- check connection state
                sessiontimer = sessiontimer + cmdtimeout
                if sessiontimer > sessiontimeout then
                    exit = true
                    skt:send(cleanmessage(response[221] .. "(session timeout)") .. crlf)
                end
            elseif err == "closed" then
                -- client closed connection
                exit = true
            else
                -- unknown error
print("Unknown error: " .. err)
            end
        else
            sessiontimer = 0
            -- received something, go deal with it
            local cmd, param = string.match(reqdata,"(.-)[ ](.*)")
            if not cmd then
                -- data is only a command
                cmd = reqdata
            end

            if command[cmd] ~= nil then
                -- recognized as a command, execute it
print(string.format("XHCP command received: %s", reqdata))
                local res, err = command[cmd](skt, param)
                if not res then
                    -- error returned, exit now
                    err = err or ""
                    skt:send(cleanmessage(response[503] .. "; " .. err) .. crlf)
                    exit = true
                end
                if cmd == "QUIT" then exit = true end        -- gotta go !
            else
                -- unknown command, send error
                skt:send(response[500])
            end
        end
    end
    sk1:close()
print("connection was closed by client")
end

-----------------------------------------------------------------------------------------
-- Initializes xPL HAL. Will be called from the device:initialize() method
function hal:initialize()
print("initializing HAL")


    -- add scheduler to hal table
    self.scheduler = scheduler

end

-----------------------------------------------------------------------------------------
-- Starts xPL HAL. Will be called from the device:start() method
function hal:start()
    -- setup the socket and server code
    halserver = socket.bind("*", xpl.settings.xplport)
    assert (halserver, "Could not create xPL HAL server socket")
    copas.addserver(halserver, xhcp)

    -- start scheduler
    self.scheduler:start()
end

-----------------------------------------------------------------------------------------
-- Stops xPL HAL. Will be called from the device:stop() method
function hal:stop()
    -- stop scheduler
    self.scheduler:stop()
    -- close connections
    halserver:close()
    halserver = nil
end


-- instantiate (and initialize) xPL device for HAL
hal.device = baseclass:new(xpldevice)
--return hal.device

--
xpl.listener.register(hal.device)
xpl.listener.start()
--]]
