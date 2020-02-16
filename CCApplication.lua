-- CCApplication.lua
-- CCKit
--
-- This file creates the CCApplication, which manages the program's run loop.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCLog = require "CCLog"
--if _G._PID ~= nil then loadAPI("CCKernel") end
local CCWindowRegistry = require("CCWindowRegistry")

local colorString = "0123456789abcdef"

local function cp(color)
    local recurses = 1
    local cc = color
    while cc ~= 1 do 
        cc = bit.blogic_rshift(cc, 1)
        recurses = recurses + 1
    end
    --print(recurses .. " " .. color .. " \"" .. string.sub(colorString, recurses, recurses) .. "\"")
    return string.sub(colorString, recurses, recurses)
end

local function drawFilledBox(x, y, endx, endy, color) for px=x,x+endx-1 do for py=y,y+endy-1 do 
    term.setCursorPos(px, py)
    term.blit(" ", "0", cp(color)) 
end end end

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
  --math.randomseed(os.clock())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

local function CCApplication(name)
    local retval = {}
    term.setBackgroundColor(colors.black)
    retval.name = string.random(8)
    retval.class = "CCApplication"
    retval.objects = {count = 0}
    retval.events = {}
    retval.isApplicationRunning = false
    retval.backgroundColor = colors.black
    retval.objectOrder = {}
    retval.applicationName = name
    retval.showName = false
    if name ~= nil then retval.log = CCLog(name)
    else retval.log = CCLog.default end
    CCLog.default.logToConsole = false
    retval.log:open()
    function retval:setBackgroundColor(color)
        self.backgroundColor = color
        term.setBackgroundColor(color)
        term.setCursorPos(1, 1)
        term.clear()
        term.clear()
        for k,v in pairs(self.objects) do if k ~= "count" and v.class == "CCWindow" then v:redraw() end end
    end
    function retval:registerObject(win, name, up) -- adds the events in the object to the run loop
        --if win.class ~= "CCWindow" then error("tried to register non-CCWindow type " .. win.class, 2) end
        if win == nil then 
            self.log:error("win is nil") 
            return
        end
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
        self.objects[name] = nil
        local remove = {}
        for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == name then table.insert(remove, {f = k, s = l}) end end end
        for a,b in pairs(remove) do self.events[b.f][b.s] = nil end
    end
    function retval:runLoop()
        --print("starting loop")
        self.log:open()
        if _G.windowRegistry[self.name] == nil then CCWindowRegistry.registerApplication(self.name) end
        if CCKernel ~= nil then CCKernel.broadcast("redraw_all", self.name, true) end
        while self.isApplicationRunning do
            --print("looking for event")
            if self.objects.count == 0 then break end
            if self.showName then
                term.setBackgroundColor(self.backgroundColor)
                term.setTextColor(colors.white)
                term.setCursorPos(1, 1)
                term.write(self.applicationName)
            end
            local evd = {os.pullEvent()}
            local ev, p1, p2, p3, p4, p5 = table.unpack(evd)
            --print("recieved event " .. ev)
            if ev == "closed_window" then
                if self.objects[p1] == nil or self.objects[p1].class ~= "CCWindow" then 
                    self.log:error("Missing window for " .. p1, "CCApplication")
                else
                    drawFilledBox(self.objects[p1].frame.x, self.objects[p1].frame.y, self.objects[p1].frame.width, self.objects[p1].frame.height, self.backgroundColor)
                    CCWindowRegistry.setAppTop(self.name)
                    CCWindowRegistry.deregisterWindow(self.objects[p1])
                    if CCKernel ~= nil then CCKernel.broadcast("redraw_all", self.name) end
                    self.objects[p1] = nil
                    self.objects.count = self.objects.count - 1
                    if self.objects.count == 0 then break end
                    local remove = {}
                    for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == p1 then table.insert(remove, {f = k, s = l}) end end end
                    for a,b in pairs(remove) do self.events[b.f][b.s] = nil end
                    for k,v in pairs(self.objectOrder) do if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v].window.redraw() end end 
                end
            elseif ev == "redraw_window" then
                if self.objects[p1] ~= nil and self.objects[p1].redraw ~= nil then self.objects[p1]:redraw() end
            elseif ev == "redraw_all" then
                if p1 ~= self.name then for k,v in pairs(self.objectOrder) do if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v]:redraw(false) end end
                elseif p2 == true then CCWindowRegistry.setAppTop(self.name) end
            end
            local didEvent = false
            local redraws = {}
            for k,v in pairs(self.events) do if ev == k then 
                --print("got event " .. ev)
                --print(textutils.serialize(v))
                for l,w in ipairs(v) do 
                    if self.objects[w.self] == nil then 
                        self.log:debug(textutils.serialize(w))
                        self.log:error("Could not find object for " .. tostring(w.self), "CCApplication")
                    else
                        if w.func(self.objects[w.self], table.unpack(evd, 2)) then 
                            redraws[w.self] = true
                            didEvent = true
                            break 
                        end
                    end
                end 
            end end
            if didEvent then for _,vv in ipairs(_G.windowRegistry[self.name]) do for _,v in ipairs(self.objectOrder) do 
                if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil and self.objects[v].name == vv.name then self.objects[v].window.redraw() end end end
            end
        end
        --print("ending loop")
        self.log:close()
        CCWindowRegistry.deregisterApplication(self.name)
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
    CCWindowRegistry.registerApplication(retval.name)
    return retval
end

return CCApplication