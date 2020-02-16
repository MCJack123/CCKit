local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCControl = require "CCControl"
local CCMenu = require "CCMenu"

local function CCPopUpButton(x, y, width, pullsDown)
    local retval = CCControl(x, y, width, 1)
    retval.backgroundColor = CCKitGlobals.buttonColor
    retval.pullsDown = pullsDown
    retval.menu = CCMenu(...)
    retval.selectedItem = nil
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
end

return CCPopUpButton