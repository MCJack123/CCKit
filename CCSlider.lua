-- CCSlider.lua
-- CCKit
--
-- This file creates the CCSlider class, which allows users to control an analog
-- value via a bar and knob.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
local CCControl = require("CCControl")
loadAPI("CCGraphics")

function CCSlider(x, y, width)
    local retval = CCControl(x, y, width, 1)
    retval.value = 0.0
    retval.minimumValue = 0.0
    retval.maximumValue = 100.0
    retval.minimumColor = CCKitGlobals.buttonHighlightedColor
    retval.maximumColor = CCKitGlobals.buttonColor
    retval.buttonColor = CCKitGlobals.buttonColor
    retval.sliderValue = 0
    function retval:setValue(value)
        self.value = value
        self.sliderValue = ((self.frame.width - 1) * (self.minimumValue - self.value)) / (self.maximumValue - self.minimumValue)
        self:draw()
    end
    function retval:onMouseDown(button, px, py)
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.isEnabled then 
            self.isSelected = true
            self:onDrag(button, px, py)
            return true
        end
        return false
    end
    function retval:onDrag(button, px, py)
        if self.isSelected and button == 1 then
            if px < self.frame.absoluteX then self.sliderValue = 0
            elseif px > self.frame.absoluteX + self.frame.width - 1 then self.sliderValue = self.frame.width - 1
            else self.sliderValue = px - self.frame.absoluteX end
            self.value = self.sliderValue * ((self.maximumValue - self.minimumValue) / (self.frame.width - 1)) + self.minimumValue
            self:draw()
            os.queueEvent("slider_dragged", self.name, self.value)
            return true
        end
        return false
    end
    function retval:draw()
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
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    retval:setAction(function() return end, self)
    retval:addEvent("mouse_click", retval.onMouseDown)
    retval:addEvent("mouse_drag", retval.onDrag)
    return retval
end
