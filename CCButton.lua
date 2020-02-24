-- CCButton.lua
-- CCKit
--
-- This file creates a subclass of CCView called CCButton, which allows a user
-- to click and start an action.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCControl = require "CCControl"
local CCGraphics = require "CCGraphics"

self, super = nil -- to silence errors

return class "CCButton" {extends = CCControl} {
    textColor = CCKitGlobals.defaultTextColor,
    text = nil,
    backgroundColor = CCKitGlobals.buttonColor,
    draw = function()
        if self.parentWindow ~= nil then
            local textColor
            local backgroundColor
            if self.isHighlighted and self.isSelected then backgroundColor = CCKitGlobals.buttonHighlightedSelectedColor
            elseif self.isHighlighted then backgroundColor = CCKitGlobals.buttonHighlightedColor
            elseif self.isSelected then backgroundColor = CCKitGlobals.buttonSelectedColor
            elseif not self.isEnabled then backgroundColor = CCKitGlobals.buttonDisabledColor
            else backgroundColor = self.backgroundColor end
            if self.isEnabled then textColor = self.textColor else textColor = CCKitGlobals.buttonDisabledTextColor end
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, backgroundColor, textColor)
            if self.text ~= nil then CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(self.text)) / 2), math.floor((self.frame.height - 1) / 2), self.text) end
            for _,v in ipairs(self.subviews) do v.draw() end
        end
    end,
    setText = function(text)
        self.text = text
        self.draw()
    end,
    setTextColor = function(color)
        self.textColor = color
        self.draw()
    end
}