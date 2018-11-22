-- CCButton.lua
-- CCKit
--
-- This file creates a subclass of CCView called CCButton, which allows a user
-- to click and start an action.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
local CCControl = require("CCControl")

function CCButton(x, y, width, height)
    local retval = CCControl(x, y, width, height)
    retval.textColor = CCKitGlobals.defaultTextColor
    retval.text = nil
    retval.backgroundColor = CCKitGlobals.buttonColor
    function retval:draw()
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
            if retval.text ~= nil then CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(self.text)) / 2), math.floor((self.frame.height - 1) / 2), self.text) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setText(text)
        self.text = text
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    return retval
end
