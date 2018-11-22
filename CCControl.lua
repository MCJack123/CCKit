-- CCControl.lua
-- CCKit
--
-- This file defines the CCControl class, which is a base class for all controls.
-- Controls can be interacted with and show content relating to the program
-- state and any interactions done with the view.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
local CCEventHandler = require("CCEventHandler")
local CCView = require("CCView")

function CCControl(x, y, width, height)
    local retval = multipleInheritance(CCView(x, y, width, height), CCEventHandler("CCControl"))
    retval.hasEvents = true
    retval.isEnabled = true
    retval.isSelected = false
    retval.isHighlighted = false
    retval.action = nil
    retval.actionObject = nil
    function retval:setAction(func, obj)
        self.action = func
        self.actionObject = obj
    end
    function retval:setHighlighted(h)
        self.isHighlighted = h
        self:draw()
    end
    function retval:setEnabled(e)
        self.isEnabled = e
        self:draw()
    end
    function retval:onMouseDown(button, px, py)
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil and self.isEnabled then 
            self.isSelected = true
            self:draw()
            return true
        end
        return false
    end
    function retval:onMouseUp(button, px, py)
        -- TODO: Make sure only the top window gets clicked.
        if self.isSelected and button == 1 then 
            self.isSelected = false
            self:draw()
            self.action(self.actionObject)
            return true
        end
        return false
    end
    function retval:onKeyDown(key, held)
        if self.isHighlighted and key == keys.enter and self.isEnabled then 
            self.isSelected = true
            self:draw()
            return true
        end
        return false
    end
    function retval:onKeyUp(key)
        if self.isHighlighted and self.isSelected and key == keys.enter and self.isEnabled then
            self.isSelected = false
            self:draw()
            self.action(self.actionObject)
            return true
        end
        return false
    end
    retval:addEvent("key", retval.onKeyDown)
    retval:addEvent("key_up", retval.onKeyUp)
    retval:addEvent("mouse_click", retval.onMouseDown)
    retval:addEvent("mouse_up", retval.onMouseUp)
    return retval
end
