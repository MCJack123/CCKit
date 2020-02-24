-- CCLog.lua
-- CCKit
--
-- This file creates the CCLog class, which provides a native logging system
-- for applications. A default logger is also provided. Logs are stored at
-- /CCKit/logs/(name).log.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"

local function string_trim(s)
    return string.match(s,'^()%s*$') and '' or string.match(s,'^%s*(.*%S)')
end  

local function getLine(filename, lineno)
    local i = 1
    local retval = ""
    if type(filename) ~= "string" or (not fs.exists(filename)) then return "" end
    for line in io.lines(filename) do
        if i == lineno then retval = line end
        i=i+1
    end
    return retval
end

-- this doesn't account for leap years, but that doesn't matter in Minecraft
local junOff = 31 + 28 + 31 + 30 + 31 + 30
local function dayToString(day)
    if day <= 31 then return "Jan " .. day
    elseif day > 31 and day <= 31 + 28 then return "Feb " .. day - 31
    elseif day > 31 + 28 and day <= 31 + 28 + 31 then return "Mar " .. day - 31 - 28
    elseif day > 31 + 28 + 31 and day <= 31 + 28 + 31 + 30 then return "Apr " .. day - 31 - 28 - 31
    elseif day > 31 + 28 + 31 + 30 and day <= 31 + 28 + 31 + 30 + 31 then return "May " .. day - 31 - 28 - 31 - 30
    elseif day > 31 + 28 + 31 + 30 + 31 and day <= junOff then return "Jun " .. day - 31 - 28 - 31 - 30 - 31
    elseif day > junOff and day <= junOff + 31 then return "Jul " .. day - junOff
    elseif day > junOff + 31 and day <= junOff + 31 + 31 then return "Aug " .. day - junOff - 31
    elseif day > junOff + 31 + 31 and day <= junOff + 31 + 31 + 30 then return "Sep " .. day - junOff - 31 - 31
    elseif day > junOff + 31 + 31 + 30 and day <= junOff + 31 + 31 + 30 + 31 then return "Oct " .. day - junOff - 31 - 31 - 30
    elseif day > junOff + 31 + 31 + 30 + 31 and day <= junOff + 31 + 31 + 30 + 31 + 30 then return "Nov " .. day - junOff - 31 - 31 - 30 - 31
    else return "Dec " .. day - junOff - 31 - 31 - 30 - 31 - 30 end
end

local default = {}

local CCLog = class "CCLog" {
    fileDescriptor = nil,
    showInDefaultLog = true,
    shell = nil,
    __init = function(name)
        self.name = name
    end,
    open = function()
        if self.fileDescriptor == nil then
            self.fileDescriptor = fs.open("CCKit/logs/" .. self.name .. ".log", fs.exists("CCKit/logs/" .. self.name .. ".log") and "a" or "w")
            if self.fileDescriptor == nil then error("Could not open log file") end
            self.fileDescriptor.write("=== Logging for " .. self.name .. " started at " .. dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " ===\n")
            self.fileDescriptor.flush()
        end
    end,
    debug = function(text, class, lineno)
        if self == nil then error("No self") end
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Debug] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.debug(self.name, text, class, lineno) 
        end
    end,
    log = function(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Default] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.log(self.name, text, class, lineno) 
        end
    end,
    warn = function(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Warning] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.warn(self.name, text, class, lineno) 
        end
    end,
    error = function(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Error] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.error(self.name, text, class, lineno) 
        end
    end,
    critical = function(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Critical] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.critical(self.name, text, class, lineno) 
        end
    end,
    traceback = function(errortext, class, lineno)
        local i = 4
        local statuse, erre = nil
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Traceback] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(errortext .. "\n")
        while erre ~= "" do
            statuse, erre = pcall(function() error("", i) end)
            if erre == "" then break end
            local filename = string.sub(erre, 1, string.find(erre, ":")-1)
            if self.shell ~= nil then filename = self.shell.resolveProgram(filename) end
            if string.find(erre, ":") == nil or string.find(erre, ":", string.find(erre, ":")+1) == nil then
                self.fileDescriptor.write("    at " .. erre .. "\n")
            else
                local mlineno = tonumber(string.sub(erre, string.find(erre, ":")+1, string.find(erre, ":", string.find(erre, ":")+1)-1))
                --if i == 4 then lineno=lineno-1 end
                self.fileDescriptor.write("    at " .. erre .. string_trim(getLine(filename, mlineno)) .. "\n")
            end
            i=i+1
        end
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            default.traceback(self.name, errortext, class, lineno) 
        end
    end,
    close = function()
        self.fileDescriptor.close()
        self.fileDescriptor = nil
    end
}

default.fileDescriptor = nil
default.shell = nil
default.logToConsole = true

function default.open()
    if default.fileDescriptor == nil then
        default.fileDescriptor = fs.open("CCKit/logs/default.log", fs.exists("CCKit/logs/default.log") and "a" or "w")
        default.fileDescriptor.write("=== Logging started at " .. dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " ===\n")
        default.fileDescriptor.flush()
    end
end
function default.write(text)
    default.fileDescriptor.write(text)
    if default.logToConsole then
        local lastColor = term.getTextColor()
        term.setTextColor(colors.red)
        write(text) 
        term.setTextColor(lastColor)
    end
end
function default.debug(name, text, class, lineno)
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Debug] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(text .. "\n")
    default.fileDescriptor.flush()
end
function default.log(name, text, class, lineno)
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Default] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(text .. "\n")
    default.fileDescriptor.flush()
end
function default.warn(name, text, class, lineno)
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Warning] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(text .. "\n")
    default.fileDescriptor.flush()
end
function default.error(name, text, class, lineno)
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Error] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(text .. "\n")
    default.fileDescriptor.flush()
end
function default.critical(name, text, class, lineno)
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Critical] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(text .. "\n")
    default.fileDescriptor.flush()
end
function default.traceback(name, errortext, class, lineno)
    local i = 4
    local statuse = nil
    local erre = "t"
    default.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Traceback] " .. name .. ": ")
    if class ~= nil then 
        default.write(class)
        if lineno ~= nil then default.write("[" .. lineno .. "]") end
        default.write(": ")
    end
    default.write(errortext .. "\n")
    while erre ~= "" do
        statuse, erre = pcall(function() error("", i) end)
        if erre == "" then break end
        local filename = string.sub(erre, 1, string.find(erre, ":")-1)
        if default.shell ~= nil then filename = default.shell.resolveProgram(filename) end
        if string.find(erre, ":", string.find(erre, ":")+1) == nil then
            default.write("    at " .. erre .. "\n")
        else
            local nlineno = tonumber(string.sub(erre, string.find(erre, ":")+1, string.find(erre, ":", string.find(erre, ":")+1)-1))
            --if i == 4 then lineno=lineno-1 end
            default.write("    at " .. erre .. string_trim(getLine(filename, nlineno)) .. "\n")
        end
        i=i+1
    end
    default.fileDescriptor.flush()
end
function default.close()
    default.fileDescriptor.close()
    default.fileDescriptor = nil
end

default.open()

return setmetatable({default = default}, {__call = function(_, name) return CCLog(name) end})