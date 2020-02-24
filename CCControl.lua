-- CCControl.lua
-- CCKit
--
-- This file defines the CCControl class, which is a base class for all controls.
-- Controls can be interacted with and show content relating to the program
-- state and any interactions done with the view.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCEventHandler = require "CCEventHandler"
local CCView = require "CCView"
local CCWindowRegistry = require "CCWindowRegistry"

self, super = nil

return class "CCControl" {extends = {CCView, CCEventHandler}} {
    hasEvents = true,
    isEnabled = true,
    isSelected = false,
    isHighlighted = false,
    action = nil,
    actionObject = nil,
    __init = function(x, y, width, height)
        _ENV.CCView(x, y, width, height)
        _ENV.CCEventHandler("CCControl")
        self.addEvent("key", self.onKeyDown)
        self.addEvent("key_up", self.onKeyUp)
        self.addEvent("mouse_click", self.onMouseDown)
        self.addEvent("mouse_up", self.onMouseUp)
    end,
    setAction = function(func, obj)
        self.action = func
        self.actionObject = obj
    end,
    setHighlighted = function(h)
        self.isHighlighted = h
        self.draw()
    end,
    setEnabled = function(e)
        self.isEnabled = e
        self.draw()
    end,
    onMouseDown = function(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil and self.isEnabled then 
            self.isSelected = true
            self.draw()
            return true
        end
        return false
    end,
    onMouseUp = function(button, px, py)
        --if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if self.isSelected and button == 1 then 
            self.isSelected = false
            self.draw()
            self.action(self.actionObject)
            return true
        end
        return false
    end,
    onKeyDown = function(key, held)
        if self.isHighlighted and key == keys.enter and self.isEnabled then 
            self.isSelected = true
            self.draw()
            return true
        end
        return false
    end,
    onKeyUp = function(key)
        if self.isHighlighted and self.isSelected and key == keys.enter and self.isEnabled then
            self.isSelected = false
            self.draw()
            self.action(self.actionObject)
            return true
        end
        return false
    end
}
