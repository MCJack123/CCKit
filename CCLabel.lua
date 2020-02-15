-- CCLabel.lua
-- CCKit
--
-- This is a subclass of CCView that displays text on screen.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCView = require "CCView"

local function CCLabel(x, y, text)
    local retval = CCView(x, y, string.len(text), 1)
    retval.text = text
    retval.textColor = CCKitGlobals.defaultTextColor
    function retval:draw()
        if self.parentWindow ~= nil then
            for px=0,self.frame.width-1 do CCGraphics.setPixelColors(self.window, px, 0, self.textColor, self.backgroundColor) end
            CCGraphics.setString(self.window, 0, 0, self.text)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    return retval
end

return CCLabel