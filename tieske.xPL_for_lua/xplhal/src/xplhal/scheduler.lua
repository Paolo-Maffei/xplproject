-- Eventscheduler for xPLHal

--[[
event format;

repeating event
    event = {
        dow = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false },
        endtime = 0,        -- integer; minute of the day
        interval = 0,       -- integer; interval in minutes
        params = "",
        rand = 0,           -- integer; minutes
        starttime = 0,      -- integer; minute of the day
        subname = "undefined",
        tag = "undefined"
    }
single event
    event = {
        day = 1,
        month = 1,
        year = 2010,
        starttime = 0,      -- integer; minute of the day
        params = "",
        subname = "undefined",
        tag = "undefined",
    }

value auto added;
    expire  = date/time of next expiry
    next    = next event in the list (based on expire)
    previous= previous event in the list (based on expire)

--]]

date = require ("date")
require ("copastimer")

local events = {}       -- local list with events, indexed by tag
local first             -- first event to expire, start of linked list
local timer = nil       -- will hold the timer
local thread = nil      -- the thread on which the event executes (thread allows custom code to yield)

----------------------------------------------------------------------------------------
-- Checks an event whether it is a repeating or single event
-- @param ev event to check
-- @return true if it is repeating, false if its a single event
local isrepeating = function(ev)
    -- returns true if ev is a repeating event, false if single
    return (ev.dow ~= nil) -- repeating if dow field is present
end

----------------------------------------------------------------------------------------
-- Removes an event from event list, no calculation or timer setting
-- @param ev event to add. Either a single or repeating event
local remove = function(ev)
    if events[ev.tag] then
        events[ev.tag] = nil
        -- now update linked list
        if ev == first then
            -- it is the first in the list
            first = ev.next
            if first then
                first.previous = nil
            end
        else
            -- not the first in the list
            ev.previous.next = ev.next
            if ev.next then
                ev.next.previous = ev.previous
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- Insert an event in the list, no calculating or timer setting
-- @param ev event to add. Either a single or repeating event
local insert = function(ev)
    if events[ev.tag] then
        -- it is already in the list, remove it
        remove(ev)
    end
    ev.next = nil
    ev.previous = nil
    if not first then
        -- list is empty
        first = ev
    else
        if ev.expire < first.expire then
            -- first in line, insert at top
            ev.next = first
            first.previous = ev.next
        else
            -- find my spot and insert
            local insertafter = first   -- position in list
            while insertafter.next and insertafter.next.expire < ev.expire do
                insertafter = insertafter.next
            end
            if insertafter.next then
                -- insert between 2 items
                ev.next = insertafter.next
                ev.previous = insertafter
                insertafter.next.previous = ev
                insertafter.next = ev
            else
                -- append as last item
                insertafter.next = ev
                ev.previous = insertafter
            end
        end
    end
    events[ev.tag] = ev
end


local scheduler = {

    ----------------------------------------------------------------------------------------
    -- Calculates the <code>expire</code> field of an event. It will calculate the next time, from the
    -- current <code>expire</code> value. To calculate from scratch, set <code>expire</code> to
    -- <code>nil</code> before calling this method.
    -- @param ev event to calculate the expire time for. Either a single or repeating event.
    -- @return the <code>expire</code> property of <code>ev</code> will be set to the new expire time.
    calculateevent = function(self, ev)
        if isrepeating(ev) then
            -- calculate next time to expire
            if ev.interval == 0 then
                -- run only once a day
                if ev.expire == nil then
                    -- not expired yet
                    ev.expire = date()
                    ev.expire:setminutes(0)
                    ev.expire:sethours(0)
                    ev.expire:setseconds(0)
                    ev.expire:setticks(0)
                    ev.expire:addminutes(starttime)
                    if ev.expire < date() then
                        ev.expire:adddays(1)
                    end
                else
                    -- already expired, so add a day
                    ev.expire:adddays(1)
                end
            else
                -- running at interval, set initial value if not present
                if ev.expire == nil then
                    ev.expire = date()  -- set to now, to schedule from here.
                end

                if ev.starttime == ev.endttime then
                    -- start and end at the same time, so 24hrs round, just add minutes
                    ev.expire:addminutes(ev.interval)
                elseif ev.starttime > ev.endtime then
                    -- starts after it ends, so if beyond end, then forward to start, remain at same day
                    ev.expire:addminutes(ev.interval)
                    if ev.endtime <= (ev.expire:getminutes() + ev.expire:gethours() * 60) then
                        ev.expire:setminutes(0)
                        ev.expire:sethours(0)
                        ev.expire:addminutes(starttime)
                    end
                else
                    -- endtime is beyond start time, if beyond end, forward to start at next day
                    if (ev.expire:getminutes() + ev.expire:gethours() * 60 + ev.interval) < ev.endttime then
                        -- within limit of endtime, so just add it
                        ev.expire:addminutes(ev.interval)
                    else
                        -- beyond endtime, so move to starttime at next day
                        ev.expire:setminutes(0)
                        ev.expire:sethours(0)
                        ev.expire:adddays(1)
                        ev.expire:addminutes(starttime)
                    end
                end
            end

            -- check the days we're supposed to run on
            while not ev.dow[ev.expire:getweekday()] do
                -- we're not set to run on this day, so pick the next
                ev.expire:adddays(1)
            end
        else
            -- single event, this is easy
            ev.expire = date(ev.year, ev.month, ev.day)
            ev.expire:addminutes(ev.starttime)
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Verifies an event and adjusts to proper values if necessary
    -- @param ev event to verify
    verifyevent = function(self, ev)
        if type(ev) ~= "table" then ev = {} end
        if isrepeating(ev) then
            if type(ev.dow) ~= "table" then ev.dow = {} end
            local one
            for i = 1, 7 do
                if ev.dow[i] then one = true end
            end
            if not one then
                ev.dow = { [1] = true }
            end
            ev.endtime = tonumber(ev.endtime) or 0
            if ev.endtime<0 then ev.endtime = 0 end
            if ev.endtime>=24*60 then ev.endtime = 0 end
            ev.interval = tonumber(ev.interval) or 60
            if ev.interval < 0 then ev.interval = 0 end
            if ev.interval > 365*24*60 then ev.interval = 0 end
            ev.params = tostring(ev.params)
            ev.rand = tonumber(ev.rand) or 0
            if ev.rand < 0 then ev.rand = 0 end
            if ev.rand > 24*60 then ev.rand = 0 end
            ev.starttime = tonumber(ev.starttime) or 0
            if ev.startttime<0 then ev.starttime = 0 end
            if ev.starttime>=24*60 then ev.starttime = 0 end
            ev.subname = tostring(ev.subname)
            ev.tag = tostring(ev.tag)
        else
            local now = date()
            ev.year = tonumber(ev.year) or (now:getyear())
            if ev.year < 100 then ev.year = ey.year + 2000 end
            if ev.year < (now:getyear()) then ev.year = (now:getyear()) end
            ev.month = tonumber(ev.month) or (now:getmonth())
            if ev.month < 1 or ev.month > 12 then ev.month = (now:getmonth()) end
            ev.day = tonumber(ev.day) or (now:getday())
            if ev.day < 1 then ev.day = 1 end
            now = date(ev.year, ev.month, 1)
            now:addmonths(1)
            now:adddays(-1)     -- we're now at the last day of the month
            if ev.day > now:getday() then ev.day = now:getday() end
            ev.starttime = tonumber(ev.starttime) or 0
            if ev.startttime<0 then ev.starttime = 0 end
            if ev.starttime>=24*60 then ev.starttime = 0 end
            ev.params = tostring(ev.params)
            ev.subname = tostring(ev.subname)
            ev.tag = tostring(ev.tag)
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Adds an event to the event list
    -- @param ev event to add. Either a single or repeating event
    addevent = function(self, ev)
        self:verifyevent(ev)
        assert (type(ev) == "table", "expected an event table, got " .. type(ev))
        ev.expire = nil -- reset expiry time, to recalculate properly
        self:calculateevent(ev)
        insert(ev)
        if ev == first then     -- adjust timer because this one is up first
            self:settimer()
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Removes an event to the event list
    -- @param ev event to add. Either a single or repeating event
    removeevent = function(self, ev)
        if events[ev.tag] then
            if ev == first then
                remove(ev)
                self:settimer()
            else
                remove(ev)
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Sets the timer to the first item to expire in the list
    settimer = function(self)
        if timer then
            timer:cancel()
        else
            timer = copas.timer.create(nil, function() self:timerexpire() end, nil, false)
        end
        if thread then
            -- we've got a thread running, set to expire immediately, at next step in the CopasTimer loop
            -- to finish this task first before setting the next
            timer:arm(0)
        else
            -- calculate when to expire
            local now = date()
            if first.expire <= now then
                timer:arm(0)    -- already late
            else
                local span = first.expire - now
                if span:spanhours() >= 12 then
                    -- more than 12 hours away, schedule 12 hours
                    timer:arm(12*60*60)
                else
                    -- set actual expiry time
                    if first.rand > 0 then
                        -- randomize around the expired time, so 50% before, and 50% after
                        span = first.expire:addseconds(math.random() * (first.rand * 60) - (first.rand * 60 / 2)) - now
                    end
                    timer:arm(span:spanseconds())
                end
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Executes when the timer expires
    timerexpire = function(self)
        if not thread then
            local now = date()
            if first.expire <= now then
                -- so the item expired
                ev = first
                remove(ev)  -- remove from the list
                -- Execute it
                thread = coroutine.create(function() hal:executesub(ev.subname, ev.params) end)
                -- add again if repeating
                if isrepeating(ev)  then
                    self:calculateevent(ev)
                    insert(ev)
                end
            end
        end
        -- (re)execute thread
        if thread then
            local res, err = coroutine.resume(thread)
            if not res then
                print("xPLHAL: event execution returned error; " .. tostring(err))
            end
            if coroutine.status(thread) == "dead" then
                thread = nil        -- clear thread because we're done with it
            end
        end
        -- settimer
        self:settimer()
    end,

    ----------------------------------------------------------------------------------------
    -- Stops the scheduler. Completes running thread and exits.
    stop = function(self)
        -- cencel a running timer
        if timer then
            timer:cancel()
            timer = nil
        end
        -- finish the thread
        while thread do
            if coroutine.status(thread) == "dead" then
                thread = nil        -- clear thread because we're done with it
            else
                local res, err = coroutine.resume(thread)
                if not res then
                    print("xPLHAL: event execution returned error; " .. tostring(err))
                end
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Starts the scheduler. Clears thread and recalculates initial expire times
    start = function(self)
        -- clear stuff
        thread = nil
        local oevents = events
        events = {}
        first = nil
        if timer then
            timer:cancel()
            timer = nil
        end
        -- add all events again to recalculate and order them properly
        for _, e in pairs(oevents) do
            self:addevent(e)
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Get event from the event list
    -- @param tag tag of event to look up
    -- @return the event table or nil if not found
    getevent = function(self, tag)
        return events[tag]
    end,

}

return scheduler
