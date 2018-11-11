-- CCApplication.lua
-- CCKit
--
-- This file creates the CCApplication, which manages the program's run loop.
--
-- Copyright (c) 2018 JackMacWindows.

if CCLog == nil then os.loadAPI("CCKit/CCLog.lua") end

local colorString = "0123456789abcdef"

local function cp(color)
    local recurses = 1
    local cc = color
    while cc ~= 1 do 
        cc = bit.brshift(cc, 1)
        recurses = recurses + 1
    end
    --print(recurses .. " " .. color .. " \"" .. string.sub(colorString, recurses, recurses) .. "\"")
    return string.sub(colorString, recurses, recurses)
end

local function drawFilledBox(x, y, endx, endy, color) for px=x,x+endx-1 do for py=y,y+endy-1 do 
    term.setCursorPos(px, py)
    term.blit(" ", "0", cp(color)) 
end end end

function CCApplication(name)
    local retval = {}
    term.setBackgroundColor(colors.black)
    retval.class = "CCApplication"
    retval.objects = {count = 0}
    retval.events = {}
    retval.isApplicationRunning = false
    retval.backgroundColor = colors.black
    retval.objectOrder = {}
    retval.applicationName = name
    if name ~= nil then retval.log = CCLog.CCLog(name)
    else retval.log = CCLog.default end
    CCLog.default.logToConsole = false
    function retval:setBackgroundColor(color)
        self.backgroundColor = color
        term.setBackgroundColor(color)
        term.clear()
        for k,v in pairs(self.objects) do if k ~= "count" and v.class == "CCWindow" then v:redraw() end end
    end
    function retval:registerObject(win, name, up) -- adds the events in the object to the run loop
        --if win.class ~= "CCWindow" then error("tried to register non-CCWindow type " .. win.class, 2) end
        if win == nil then error("win is nil", 2) end
        if up == nil then up = true end
        if win.repaintColor ~= nil then win.repaintColor = self.backgroundColor end
        self.objects[name] = win
        table.insert(self.objectOrder, name)
        if up then self.objects.count = self.objects.count + 1 end
        --print("added to " .. name)
        --local i = 0
        --print(textutils.serialize(win.events))
        for k,v in pairs(win.events) do
            if self.events[k] == nil then self.events[k] = {} end
            table.insert(self.events[k], v)
            --print("added event " .. k)
            --i=i+1
        end
        --print(textutils.serialize(self.events))
        --print(i)
    end
    function retval:deregisterObject(name)
        retval.objects[name] = nil
        local remove = {}
        for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == name then table.insert(remove, {f = k, s = l}) end end end
        for a,b in pairs(remove) do self.events[b.f][b.s] = nil end
    end
    function retval:runLoop()
        --print("starting loop")
        self.log:open()
        while self.isApplicationRunning do
            --print("looking for event")
            if retval.objects.count == 0 then break end
            local ev, p1, p2, p3, p4, p5 = os.pullEvent()
            --print("recieved event " .. ev)
            if ev == "closed_window" then
                if retval.objects[p1] == nil then error("object is missing") end
                drawFilledBox(retval.objects[p1].frame.x, retval.objects[p1].frame.y, retval.objects[p1].frame.width, retval.objects[p1].frame.height, self.backgroundColor)
                retval.objects[p1] = nil
                retval.objects.count = retval.objects.count - 1
                if retval.objects.count == 0 then break end
                local remove = {}
                for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == p1 then table.insert(remove, {f = k, s = l}) end end end
                for a,b in pairs(remove) do self.events[b.f][b.s] = nil end
                for k,v in pairs(self.objectOrder) do if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v].window.redraw() end end
            elseif ev == "redraw_window" then
                if retval.objects[p1] ~= nil and retval.objects[p1].redraw ~= nil then retval.objects[p1]:redraw() end
            end
            local didEvent = false
            local redraws = {}
            for k,v in pairs(self.events) do if ev == k then 
                --print("got event " .. ev)
                --print(textutils.serialize(v))
                for l,w in pairs(v) do 
                    if self.objects[w.self] == nil then error(w.self .. " is nil") end
                    if w.func(self.objects[w.self], p1, p2, p3, p4, p5) then 
                        redraws[w.self] = true
                        didEvent = true
                        break 
                    end
                end 
            end end
            if didEvent then for k,v in pairs(self.objectOrder) do if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v].window.redraw() end end end
        end
        --print("ending loop")
        self.log:close()
        coroutine.yield()
    end
    function retval:startRunLoop()
        self.coro = coroutine.create(self.runLoop)
        self.isApplicationRunning = true
        coroutine.resume(self.coro, self)
    end
    function retval:stopRunLoop()
        self.isApplicationRunning = false
    end
    return retval
end
