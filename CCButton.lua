-- CCButton.lua
-- CCKit
--
-- This file creates a subclass of CCView called CCButton, which allows a user
-- to click and start an action.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCView.lua")

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
  --math.randomseed(os.clock())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

function CCButton(x, y, width, height)
    local retval = CCView.CCView(x, y, width, height)
    retval.name = string.random(8)
    retval.textColor = colors.black
    retval.text = nil
    retval.hasEvents = true
    retval.action = nil
    retval.backgroundColor = colors.lightGray
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            if retval.text ~= nil then CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(self.text)) / 2), math.floor((self.frame.height - 1) / 2), self.text) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setAction(func, object)
        self.action = func
        self.actionObject = object
    end
    function retval:onClick(button, px, py)
        --print("got click")
        if self == nil then error("window is nil", 2) end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil then 
            --print("clicked button")
            self.action(self.actionObject) 
            return true
        end
        return false
    end
    function retval:setText(text)
        self.text = text
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    retval.events = {mouse_click = {func = retval.onClick, self = retval.name}}
    return retval
end
