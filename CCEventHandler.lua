-- CCEventHandler.lua
-- CCKit
--
-- This file defines an interface named CCEventHandler that CCApplication uses
-- to handle events.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"

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

return class "CCEventHandler" {
    hasEvents = true, -- for CCView compatibility
    __init = function(class)
        self.name = string.random(8)
        self.class = class
        self.events = {}
    end,
    addEvent = function(name, func)
        self.events[name] = {}
        self.events[name].func = func
        self.events[name].self = self.name
    end
}