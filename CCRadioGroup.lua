-- CCRadioGroup.lua
-- CCKit
-- 
-- This file defines a class called CCRadioGroup, which controls a group of
-- radio buttons.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCView = require "CCView"
local CCEventHandler = require "CCEventHandler"

local function CCRadioGroup(x, y, width, height)
    local retval = CCKitGlobals.multipleInheritance(CCView(x, y, width, height), CCEventHandler("CCRadioGroup"))
    retval.selectedId = -1
    retval.nextId = 0
    retval.hasEvents = true
    retval.action = nil
    retval.actionObject = nil
    function retval:setAction(func, obj)
        self.action = func
        self.actionObject = obj
    end
    function retval:radioHandler(name, id)
        if name == self.name then
            for k,v in ipairs(self.subviews) do
                if v.class == "CCRadioButton" then v:setOn(v.buttonId == id) end
            end
            self.selectedId = id
            if self.action ~= nil then self.action(self.actionObject, self.selectedId) end
            return true
        end
        return false
    end
    function retval:addSubview(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log:error("Cannot add nil subview")
        return end
        if view.hasEvents then self.application:registerObject(view, view.name, false) end
        if view.class == "CCRadioButton" then
            view.buttonId = self.nextId
            self.nextId = self.nextId + 1
            view.groupName = self.name
        end
        view:setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY, self)
        table.insert(self.subviews, view)
    end
    retval:addEvent("radio_selected", retval.radioHandler)
    return retval
end

return CCRadioGroup