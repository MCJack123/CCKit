-- CCTextField.lua
-- CCKit
--
-- This file creates the CCTextField class, which allows the user to type text.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCEventHandler = require "CCEventHandler"
local CCView = require "CCView"
local CCGraphics = require "CCGraphics"
local CCWindowRegistry = require "CCWindowRegistry"

return class "CCTextField" {extends = {CCEventHandler, CCView}} {
    text = "",
    isSelected = false,
    isEnabled = true,
    cursorOffset = 0, -- later
    backgroundColor = colors.lightGray,
    textColor = CCKitGlobals.defaultTextColor,
    placeholderText = nil,
    __init = function(x, y, width)
        _ENV.CCView(x, y, width, 1)
        _ENV.CCEventHandler("CCTextField")
        self.addEvent("mouse_click", self.onClick)
        self.addEvent("key", self.onKey)
        self.addEvent("char", self.onChar)
    end,
    setTextColor = function(color)
        self.textColor = color
        self.draw()
    end,
    setEnabled = function(e)
        self.isEnabled = e
        self.draw()
    end,
    setPlaceholder = function(text)
        self.placeholderText = text
        self.draw()
    end,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            local text = self.text
            if string.len(text) >= self.frame.width then text = string.sub(text, string.len(text)-self.frame.width+2)
            elseif string.len(text) == 0 and self.placeholderText ~= nil and not self.isSelected then
                text = self.placeholderText
                CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, colors.gray)
            end
            if self.isSelected then text = text .. "_" end
            CCGraphics.setString(self.window, 0, 0, text)
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end,
    onClick = function(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if button == 1 then
            self.isSelected = px >= self.frame.absoluteX and py == self.frame.absoluteY and px < self.frame.absoluteX + self.frame.width and self.isEnabled
            self.draw()
            return self.isSelected
        end
        return false
    end,
    onKey = function(key, held)
        if key == keys.backspace and self.isSelected and self.isEnabled then
            self.text = string.sub(self.text, 1, string.len(self.text)-1)
            self.draw()
            return true
        end
        return false
    end,
    onChar = function(ch)
        if self.isSelected and self.isEnabled then
            self.text = self.text .. ch
            self.draw()
            return true
        end
        return false
    end,
}