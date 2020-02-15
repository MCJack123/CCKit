-- CCKernel.lua
-- CCKit
--
-- This file is designed to be run at boot, starting a "kernel" that manages
-- processes and inter-process communication.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCLog = require "CCLog"

kernel_running = true

function basename(p)
    if string.find(p, "/") == nil then return p
    else return string.sub(p, string.find(p, "/[^/]*$")+1) end
end

function main(first_program, ...)
    first_program = first_program or "/rom/programs/shell.lua"
    os.nativeQueueEvent = os.queueEvent
    function os.queueEvent(ev, ...)
        --print("PID: " .. tostring(_G._PID))
        --CCLog.default:traceback("queueEvent", "Where does this go?")
        os.nativeQueueEvent(ev, "CustomEvent,PID=" .. _G._PID, ...)
    end
    _ENV.process_table = {}
    local log = CCLog.CCLog("CCKernel")
    log:open()
    CCLog.default.logToConsole = false
    local oldPath = shell.path()
    if shell ~= nil then shell.setPath(oldPath .. ":/" .. CCKitGlobals.CCKitDir .. "/ktools") end
    table.insert(process_table, {coro=coroutine.create(os.run), path=first_program, started=false, filter=nil, args={...}})
    term.clear()
    term.setCursorPos(1, 1)
    print("CCKernel is now active.")
    while kernel_running do
        if process_table[1] == nil or process_table[1].path ~= first_program then
            log:log("First process stopped, ending CCKernel")
            --print("Press any key to continue.")
            kernel_running = false
        end
        local e = {os.pullEvent()}
        if e[1] == "key" and e[2] == keys.f12 then
            _G._PID = nil
            print("Kernel paused.")
            _ENV.kill_kernel=function() 
                os.nativeQueueEvent("kcall_kill_process", 0)
                getfenv(2).exit()
            end
            print("Entering debugger.")
            os.run(_ENV, "/rom/programs/lua.lua")
            print("Resuming.")
        end
        local PID = 0
        if type(e[2]) == "string" and string.find(e[2], "CustomEvent,PID=") ~= nil then
            PID = tonumber(string.sub(e[2], string.len("CustomEvent,PID=")+1))
            --print("Sending " .. e[1] .. " to " .. tostring(PID))
            table.remove(e, 2)
        end
        if e[1] == "kcall_get_process_table" then
            e[1] = "kcall_get_process_table"
            e[2] = deepcopy(process_table)
            e[2][0] = {coro=nil, path=CCKitGlobals.CCKitDir.."/CCKernel.lua", started=true, filter=nil, args={}}
        end
        if e[1] == "kcall_kill_process" then
            if e[2] == 0 then break end
            table.remove(process_table, e[2])
            local c = term.getTextColor()
            term.setTextColor(colors.red)
            print("Killed")
            term.setTextColor(c)
        elseif e[1] == "kcall_start_process" then
            table.remove(e, 1)
            local path = table.remove(e, 1)
            table.insert(process_table, {coro=coroutine.create(os.run), path=path, started=false, filter=nil, args=e})
        else
            local delete = {}
            for k,v in pairs(process_table) do
                if v.filter == nil or v.filter == e[1] then
                    local err = true
                    local res = nil
                    if v.started then
                        if PID == 0 or PID == k then
                            _G._PID = k
                            _G._FORK = false
                            err, res = coroutine.resume(v.coro, unpack(e))
                        end
                    else
                        log:log("Starting process", basename(v.path), k)
                        _G._PID = k
                        _G._FORK = true -- only check this before first yield
                        err, res = coroutine.resume(v.coro, _ENV, v.path, unpack(v.args))
                        v.started = true
                    end
                    if not err then
                        log:error("Process couldn't resume or threw an error", basename(v.path), k)
                        table.insert(delete, k)
                    end
                    if coroutine.status(v.coro) == "dead" then table.insert(delete, k) end
                    if res ~= nil then v.filter = res else v.filter = nil end -- assuming every yield is for pullEvent, this may be unsafe
                end
            end
            for k,v in pairs(delete) do table.remove(process_table, v) end
        end
    end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    log:close()
    os.queueEvent = os.nativeQueueEvent
    _G._PID = nil
    if shell ~= nil then shell.setPath(oldPath) end
    print("CCKernel is no longer active.")
end

function exec(path, ...)
    --print(tostring(_G._PID))
    if _G._PID ~= nil then 
        _G._PID = _G._PID
        os.queueEvent("kcall_start_process", path, ...)
        os.queueEvent("rfjkgvjkadnvbuiargrhnibmrjkbihioad") 
        -- just need to send any event, smashing the keyboard almost guarantees that nothing will pick up on it
        -- side note: PLEASE do not actually use this entire string as an event name to pull. if you do, may you be doomed to eternal debugging without any resolution
        -- and yes, i did just curse this code, so that's one more reason not to use that name
    else error("CCKernel is disabled", 2) end
    --print(tostring(_G._PID))
end

function get_processes()
    if _G._PID == nil then error("CCKernel is disabled", 2) end
    os.queueEvent("kcall_get_process_table")
    local ev, t = os.pullEvent("kcall_get_process_table")
    return t
end

function kill(pid)
    if _G._PID == nil then error("CCKernel is disabled", 2) end
    os.queueEvent("kcall_kill_process", pid)
end

function send(pid, ev, ...)
    if _G._PID == nil then error("CCKernel is disabled", 2) end
    os.nativeQueueEvent(ev, "CustomEvent,PID="..tostring(pid), ...)
end

function broadcast(ev, ...)
    send(0, ev, ...)
end

if shell ~= nil then main(...) end -- start main if this wasn't loaded as an API