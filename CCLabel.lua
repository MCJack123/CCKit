-- CCLabel.lua
-- CCKit
--
-- This is a subclass of CCView that displays text on screen.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCView = require "CCView"

return class "CCLabel" {extends = CCView} {
    textColor = CCKitGlobals.defaultTextColor,
    __init = function(x, y, text)
        _ENV.CCView(x, y, string.len(text), 1)
        self.text = text
    end,
    draw = function()
        if self.parentWindow ~= nil then
            for px=0,self.frame.width-1 do CCGraphics.setPixelColors(self.window, px, 0, self.textColor, self.backgroundColor) end
            CCGraphics.setString(self.window, 0, 0, self.text)
            for k,v in pairs(self.subviews) do v.draw() end
        end
    end
}