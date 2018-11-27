-- CCLog.lua
-- CCKit
--
-- This file creates the CCLog class, which provides a native logging system
-- for applications. A default logger is also provided. Logs are stored at
-- /CCKit/logs/(name).log.
--
-- Copyright (c) 2018 JackMacWindows.

function string.trim(s)
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

CCLog = {}

CCLog.default = {}
CCLog.default.fileDescriptor = nil
CCLog.default.shell = nil
CCLog.default.logToConsole = true

function CCLog.default:open()
    if self.fileDescriptor == nil then
        self.fileDescriptor = fs.open("CCKit/logs/default.log", fs.exists("CCKit/logs/default.log") and "a" or "w")
        self.fileDescriptor.write("=== Logging started at " .. dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " ===\n")
        self.fileDescriptor.flush()
    end
end
function CCLog.default:write(text)
    self.fileDescriptor.write(text)
    if self.logToConsole then
        local lastColor = term.getTextColor()
        term.setTextColor(colors.red)
        write(text) 
        term.setTextColor(lastColor)
    end
end
function CCLog.default:debug(name, text, class, lineno)
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Debug] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(text .. "\n")
    self.fileDescriptor.flush()
end
function CCLog.default:log(name, text, class, lineno)
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Default] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(text .. "\n")
    self.fileDescriptor.flush()
end
function CCLog.default:warn(name, text, class, lineno)
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Warning] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(text .. "\n")
    self.fileDescriptor.flush()
end
function CCLog.default:error(name, text, class, lineno)
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Error] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(text .. "\n")
    self.fileDescriptor.flush()
end
function CCLog.default:critical(name, text, class, lineno)
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Critical] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(text .. "\n")
    self.fileDescriptor.flush()
end
function CCLog.default:traceback(name, errortext, class, lineno)
    local i = 4
    local statuse = nil
    local erre = "t"
    self:write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Traceback] " .. name .. ": ")
    if class ~= nil then 
        self:write(class)
        if lineno ~= nil then self:write("[" .. lineno .. "]") end
        self:write(": ")
    end
    self:write(errortext .. "\n")
    while erre ~= "" do
        statuse, erre = pcall(function() error("", i) end)
        if erre == "" then break end
        local filename = string.sub(erre, 1, string.find(erre, ":")-1)
        if self.shell ~= nil then filename = self.shell.resolveProgram(filename) end
        if string.find(erre, ":", string.find(erre, ":")+1) == nil then
            self:write("    at " .. erre .. "\n")
        else
            local lineno = tonumber(string.sub(erre, string.find(erre, ":")+1, string.find(erre, ":", string.find(erre, ":")+1)-1))
            --if i == 4 then lineno=lineno-1 end
            self:write("    at " .. erre .. string.trim(getLine(filename, lineno)) .. "\n")
        end
        i=i+1
    end
    self.fileDescriptor.flush()
end
function CCLog.default:close()
    self.fileDescriptor.close()
    self.fileDescriptor = nil
end

CCLog.default:open()

setmetatable(CCLog, {__call = function(idontneedthis, name)
    local retval = {}
    retval.name = name
    retval.fileDescriptor = nil
    retval.showInDefaultLog = true
    retval.shell = nil
    function retval:open()
        if self.fileDescriptor == nil then
            if type(self.name) == "table" then textutils.pagedPrint(textutils.serialize(self)) end
            self.fileDescriptor = fs.open("CCKit/logs/" .. self.name .. ".log", fs.exists("CCKit/logs/" .. self.name .. ".log") and "a" or "w")
            if self.fileDescriptor == nil then error("Could not open log file") end
            self.fileDescriptor.write("=== Logging for " .. name .. " started at " .. dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " ===\n")
            self.fileDescriptor.flush()
        end
    end
    function retval:debug(text, class, lineno)
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
            CCLog.default:debug(self.name, text, class, lineno) 
        end
    end
    function retval:log(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Default] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            CCLog.default:log(self.name, text, class, lineno) 
        end
    end
    function retval:warn(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Warning] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            CCLog.default:warn(self.name, text, class, lineno) 
        end
    end
    function retval:error(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Error] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            CCLog.default:error(self.name, text, class, lineno) 
        end
    end
    function retval:critical(text, class, lineno)
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Critical] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(text .. "\n")
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            CCLog.default:critical(self.name, text, class, lineno) 
        end
    end
    function retval:traceback(errortext, class, lineno)
        local i = 4
        local statuse, erre = nil
        self.fileDescriptor.write(dayToString(os.day()) .. " " .. textutils.formatTime(os.time(), false) .. " [Traceback] ")
        if class ~= nil then 
            self.fileDescriptor.write(class)
            if lineno ~= nil then self.fileDescriptor.write("[" .. lineno .. "]") end
            self.fileDescriptor.write(": ")
        end
        self.fileDescriptor.write(errortext .. "\n")
        while erre ~= "bios.lua:610: " do
            statuse, erre = pcall(function() error("", i) end)
            if erre == "bios.lua:610: " then break end
            local filename = string.sub(erre, 1, string.find(erre, ":")-1)
            if self.shell ~= nil then filename = self.shell.resolveProgram(filename) end
            if string.find(erre, ":") == nil or string.find(erre, ":", string.find(erre, ":")+1) == nil then
                self.fileDescriptor.write("    at " .. erre .. "\n")
            else
                local lineno = tonumber(string.sub(erre, string.find(erre, ":")+1, string.find(erre, ":", string.find(erre, ":")+1)-1))
                --if i == 4 then lineno=lineno-1 end
                self.fileDescriptor.write("    at " .. erre .. string.trim(getLine(filename, lineno)) .. "\n")
            end
            i=i+1
        end
        self.fileDescriptor.flush()
        if (self.showInDefaultLog) then 
            CCLog.default:traceback(self.name, errortext, class, lineno) 
        end
    end
    function retval:close()
        self.fileDescriptor.close()
        self.fileDescriptor = nil
    end
    return retval
end})