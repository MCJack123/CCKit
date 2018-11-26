-- CCWindowRegistry.lua
-- CCKit
--
-- This file creates functions that provide ray-casting for mouse clicks so that
-- only the top-most window recieves actions.
--
-- Copyright (c) 2018 JackMacWindows.

if _G.windowRegistry == nil then 
    _G.windowRegistry = {}
    _G.windowRegistry.zPos = {}
end

function registerApplication(appname)
    _G.windowRegistry[appname] = {}
    _G.windowRegistry.zPos[table.maxn(_G.windowRegistry.zPos)+1] = appname
end

function registerWindow(win)
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    table.insert(_G.windowRegistry[win.application.name], {name=win.name, x=win.frame.x, y=win.frame.y, width=win.frame.width, height=win.frame.height})
end

function deregisterApplication(appname)
    _G.windowRegistry[appname] = nil
    for k,v in pairs(_G.windowRegistry.zPos) do if v == appname then
        table.remove(_G.windowRegistry.zPos, k)
        break
    end end
end

function deregisterWindow(win)
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then return end
    for k,v in pairs(_G.windowRegistry[win.application.name]) do if v.name == win.name then
        table.remove(_G.windowRegistry[win.application.name], k)
        break
    end end
end

function setAppZ(appname, z)
    local n = 0
    for k,v in pairs(_G.windowRegistry.zPos) do if v == appname then n = k end end
    if n == 0 then error("Couldn't find application " .. appname, 2) end
    table.insert(_G.windowRegistry.zPos, z, table.remove(_G.windowRegistry.zPos, n))
end

function setAppTop(appname) setAppZ(appname, table.maxn(_G.windowRegistry.zPos)) end

function setWinZ(win, z)
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    local n = 0
    for k,v in pairs(_G.windowRegistry[win.application.name]) do if v.name == win.name then n = k end end
    if n == 0 then error("Couldn't find window " .. win.name, 2) end
    table.insert(_G.windowRegistry[win.application.name], z, table.remove(_G.windowRegistry[win.application.name], n))
end

function setWinTop(win) 
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    setWinZ(win, table.maxn(_G.windowRegistry[win.application.name]))
end

function moveWin(win, x, y)
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    for k,v in pairs(_G.windowRegistry[win.application.name]) do if v.name == win.name then
        v.x = x
        v.y = y
        break
    end end
end

function resizeWin(win, x, y)
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    for k,v in pairs(_G.windowRegistry[win.application.name]) do if v.name == win.name then
        v.width = x
        v.height = y
        break
    end end
end

function isAppOnTop(appname) return _G.windowRegistry.zPos[table.maxn(_G.windowRegistry.zPos)] == appname end 

function isWinOnTop(win) 
    if win.application == nil then error("Window does not have application", 2) end
    if _G.windowRegistry[win.application.name] == nil then error("Application " .. win.application.name .. " is not registered", 2) end
    return _G.windowRegistry[win.application.name][table.maxn(_G.windowRegistry[win.application.name])].name == win.name
end

function hitTest(win, px, py)
    return not (px < win.x or py < win.y or px >= win.x + win.width or py >= win.y + win.height)
end

function getAppZ(appname)
    for k,v in pairs(_G.windowRegistry.zPos) do if v == appname then return k end end
    return -1
end

function rayTest(win, px, py)
    if win.application == nil or _G.windowRegistry[win.application.name] == nil or win.frame == nil or px == nil or py == nil then return false end
    -- If the click isn't on the window then of course it didn't hit
    if px < win.frame.x or py < win.frame.y or px >= win.frame.x + win.frame.width or py >= win.frame.y + win.frame.height then return false end
    -- If the app and window are both on top, then it hit
    if isAppOnTop(win.application.name) and isWinOnTop(win) then return true
    -- If the app is not on top, check if this window is the uppermost window in the position
    else
        -- Get the highest window at the point for each app
        local wins = {}
        for k,v in pairs(_G.windowRegistry) do if k ~= "zPos" then
            wins[k] = {}
            wins[k].z = -1
            for l,w in pairs(v) do if hitTest(w, px, py) and l > wins[k].z then wins[k] = {win=w,app=k,z=l} end end
        end end
        -- Get the highest window of the highest app at the point
        local finalwin = nil
        for k,v in pairs(wins) do if finalwin == nil or getAppZ(v.app) > getAppZ(finalwin.app) then finalwin = v end end
        -- Check if win is the highest window
        return finalwin.win.name == win.name
    end
end