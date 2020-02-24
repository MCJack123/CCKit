-- CCRadioGroup.lua
-- CCKit
-- 
-- This file defines a class called CCRadioGroup, which controls a group of
-- radio buttons.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCView = require "CCView"
local CCEventHandler = require "CCEventHandler"

return class "CCRadioGroup" {extends = {CCEventHandler, CCView}} {
    selectedId = -1,
    nextId = 0,
    hasEvents = true,
    action = nil,
    actionObject = nil,
    __init = function(x, y, width, height)
        _ENV.CCView(x, y, width, height)
        _ENV.CCEventHandler("CCRadioGroup")
        self.addEvent("radio_selected", self.radioHandler)
    end,
    setAction = function(func, obj)
        self.action = func
        self.actionObject = obj
    end,
    radioHandler = function(name, id)
        if name == self.name then
            for k,v in ipairs(self.subviews) do
                if v.class == "CCRadioButton" then v.setOn(v.buttonId == id) end
            end
            self.selectedId = id
            if self.action ~= nil then self.action(self.actionObject, self.selectedId) end
            return true
        end
        return false
    end,
    addSubview = function(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log.error("Cannot add nil subview"); return end
        if view.hasEvents then self.application.registerObject(view, view.name, false) end
        if view.class == "CCRadioButton" then
            view.buttonId = self.nextId
            self.nextId = self.nextId + 1
            view.groupName = self.name
        end
        view.setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY, self)
        table.insert(self.subviews, view)
    end
}