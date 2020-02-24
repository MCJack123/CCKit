-- CCSlider.lua
-- CCKit
--
-- This file creates the CCSlider class, which allows users to control an analog
-- value via a bar and knob.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCControl = require "CCControl"
local CCGraphics = require "CCGraphics"
local CCWindowRegistry = require "CCWindowRegistry"

return class "CCSlider" {extends = CCControl} {
    value = 0.0,
    minimumValue = 0.0,
    maximumValue = 100.0,
    minimumColor = CCKitGlobals.buttonHighlightedColor,
    maximumColor = CCKitGlobals.buttonColor,
    buttonColor = CCKitGlobals.buttonColor,
    sliderValue = 0,
    __init = function(x, y, width)
        _ENV.CCControl(x, y, width, 1)
        self.setAction(function() return end, self)
        self.addEvent("mouse_click", self.onMouseDown)
        self.addEvent("mouse_drag", self.onDrag)
        self.addEvent("mouse_up", self.onMouseUp)
    end,
    setValue = function(value)
        self.value = value
        self.sliderValue = ((self.frame.width - 1) * (self.minimumValue - self.value)) / (self.maximumValue - self.minimumValue)
        self.draw()
    end,
    onMouseDown = function(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.isEnabled then 
            self.isSelected = true
            self.onDrag(button, px, py)
            return true
        end
        return false
    end,
    onDrag = function(button, px, py)
        --if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if self.isSelected and button == 1 then
            if px < self.frame.absoluteX then self.sliderValue = 0
            elseif px > self.frame.absoluteX + self.frame.width - 1 then self.sliderValue = self.frame.width - 1
            else self.sliderValue = px - self.frame.absoluteX end
            self.value = self.sliderValue * ((self.maximumValue - self.minimumValue) / (self.frame.width - 1)) + self.minimumValue
            self.draw()
            os.queueEvent("slider_dragged", self.name, self.value)
            return true
        end
        return false
    end,
    onMouseUp = function(button, px, py)
        if self.isSelected and button == 1 then 
            self.isSelected = false
            self.draw()
            return true 
        end
    end,
    draw = function()
        if self.parentWindow ~= nil then
            local i = 0
            while i < self.frame.width do
                CCGraphics.clearCharacter(self.window, i, 0)
                if i < self.sliderValue then
                    CCGraphics.setPixelColors(self.window, i, 0, self.minimumColor, self.backgroundColor)
                    CCGraphics.setPixel(self.window, i*2, 1)
                    CCGraphics.setPixel(self.window, i*2+1, 1)
                elseif i == self.sliderValue then
                    if self.isSelected then CCGraphics.setPixelColors(self.window, i, 0, self.backgroundColor, CCKitGlobals.buttonSelectedColor)
                    else CCGraphics.setPixelColors(self.window, i, 0, self.backgroundColor, self.buttonColor) end
                else
                    CCGraphics.setPixelColors(self.window, i, 0, self.maximumColor, self.backgroundColor)
                    CCGraphics.setPixel(self.window, i*2, 1)
                    CCGraphics.setPixel(self.window, i*2+1, 1)
                end
                i = i + 1
            end
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end
}
