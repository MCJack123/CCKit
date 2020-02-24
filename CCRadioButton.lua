-- CCRadioButton.lua
-- CCKit
--
-- This file creates a view that is similar to CCCheckbox, but only allows one
-- to be selected at a time inside a CCRadioGroup.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCControl = require "CCControl"
local CCGraphics = require "CCGraphics"

return class "CCRadioButton" {extends = CCControl} {
    isOn = false,
    class = "CCRadioButton",
    buttonId = 0,
    groupName = nil,
    textColor = CCKitGlobals.defaultTextColor,
    backgroundColor = CCKitGlobals.buttonColor,
    __init = function(x, y, text)
        local size = 1
        if type(text) == "string" then size = string.len(text) + 2 end
        _ENV.CCControl(x, y, size, 1)
        self.text = text
        self.setAction(self.action, self)
    end,
    setOn = function(value)
        self.isOn = value
        self.draw()
    end,
    setTextColor = function(color)
        self.textColor = color
        self.draw()
    end,
    draw = function()
        if self.parentWindow ~= nil then
            local textColor
            local backgroundColor
            if self.isOn and self.isSelected then backgroundColor = CCKitGlobals.buttonHighlightedSelectedColor
            elseif self.isOn then backgroundColor = CCKitGlobals.buttonHighlightedColor
            elseif self.isSelected then backgroundColor = CCKitGlobals.buttonSelectedColor
            elseif not self.isEnabled then backgroundColor = CCKitGlobals.buttonDisabledColor
            else backgroundColor = self.backgroundColor end
            if self.isEnabled then textColor = self.textColor else textColor = CCKitGlobals.buttonDisabledTextColor end
            CCGraphics.drawBox(self.window, 0, 0, 1, 1, backgroundColor, textColor)
            if self.isOn then CCGraphics.setCharacter(self.window, 0, 0, string.char(7))
            else CCGraphics.setCharacter(self.window, 0, 0, string.char(0xBA)) end
            if self.text ~= nil then 
                CCGraphics.drawBox(self.window, 1, 0, string.len(self.text) + 1, 1, CCKitGlobals.windowBackgroundColor, textColor)
                CCGraphics.setString(self.window, 2, 0, self.text)
            end
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end,
    action = function()
        self.setOn(true)
        os.queueEvent("radio_selected", self.groupName, self.buttonId)
    end
}