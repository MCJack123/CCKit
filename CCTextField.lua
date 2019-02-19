-- CCTextField.lua
-- CCKit
--
-- This file creates the CCTextField class, which allows the user to type text.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
local CCEventHandler = CCRequire("CCEventHandler")
local CCView = CCRequire("CCView")
loadAPI("CCGraphics")
loadAPI("CCWindowRegistry")

function CCTextField(x, y, width)
    local retval = multipleInheritance(CCView(x, y, width, 1), CCEventHandler("CCTextField"))
    retval.text = ""
    retval.isSelected = false
    retval.isEnabled = true
    retval.cursorOffset = 0 -- later
    retval.backgroundColor = colors.lightGray
    retval.textColor = CCKitGlobals.defaultTextColor
    retval.placeholderText = nil
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    function retval:setEnabled(e)
        self.isEnabled = e
        self:draw()
    end
    function retval:setPlaceholder(text)
        self.placeholderText = text
        self:draw()
    end
    function retval:draw()
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
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:onClick(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if button == 1 then
            self.isSelected = px >= self.frame.absoluteX and py == self.frame.absoluteY and px < self.frame.absoluteX + self.frame.width and self.isEnabled
            self:draw()
            return self.isSelected
        end
        return false
    end
    function retval:onKey(key, held)
        if key == keys.backspace and self.isSelected and self.isEnabled then
            self.text = string.sub(self.text, 1, string.len(self.text)-1)
            self:draw()
            return true
        end
        return false
    end
    function retval:onChar(ch)
        if self.isSelected and self.isEnabled then
            self.text = self.text .. ch
            self:draw()
            return true
        end
        return false
    end
    retval:addEvent("mouse_click", retval.onClick)
    retval:addEvent("key", retval.onKey)
    retval:addEvent("char", retval.onChar)
    return retval
end