-- CCCheckbox.lua
-- CCKit
--
-- This file creates the CCCheckbox class, which provides a binary toggleable
-- button for selecting states.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCControl = require "CCControl"
local CCGraphics = require "CCGraphics"

local function CCCheckbox(x, y, text)
    local size = 1
    if type(text) == "string" then size = string.len(text) + 2 end
    local retval = CCControl(x, y, size, 1)
    retval.isOn = false
    retval.text = text
    retval.textColor = CCKitGlobals.defaultTextColor
    retval.backgroundColor = CCKitGlobals.buttonColor
    function retval:setOn(value)
        self.isOn = value
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    function retval:draw()
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
            if retval.isOn then CCGraphics.setCharacter(self.window, 0, 0, "x")
            else CCGraphics.clearCharacter(self.window, 0, 0) end
            if retval.text ~= nil then 
                CCGraphics.drawBox(self.window, 1, 0, string.len(self.text) + 1, 1, CCKitGlobals.windowBackgroundColor, textColor)
                CCGraphics.setString(self.window, 2, 0, self.text)
            end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:action()
        self:setOn(not self.isOn)
        os.queueEvent("checkbox_toggled", self.name, self.isOn)
    end
    retval:setAction(retval.action, retval)
    return retval
end

return CCCheckbox