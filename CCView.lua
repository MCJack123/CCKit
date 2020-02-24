-- CCView.lua
-- CCKit
--
-- This file creates the CCView class, which handles initializing, drawing,
-- and displaying information inside a CCWindow.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"

return class "CCView" {
    class = "CCView",
    superview = nil,
    parentWindowName = nil,
    parentWindow = nil,
    application = nil,
    window = nil,
    hasEvents = false,
    backgroundColor = colors.white,
    __init = function(x, y, width, height)
        self.events = {}
        self.subviews = {}
        self.frame = {x = x, y = y, width = width, height = height, absoluteX = x, absoluteY = y}
    end,
    setBackgroundColor = function(color)
        self.backgroundColor = color
        self.draw()
    end,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end,
    addSubview = function(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log.error("Cannot add nil subview", 2) end
        if view.hasEvents then self.application.registerObject(view, view.name, false) end
        view.setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY, self)
        table.insert(self.subviews, view)
    end,
    setParent = function(parent, application, name, absoluteX, absoluteY, superview)
        self.parentWindow = parent
        self.parentWindowName = name
        self.application = application
        self.superview = superview
        self.frame.absoluteX = absoluteX + self.frame.x
        self.frame.absoluteY = absoluteY + self.frame.y
        self.window = window.create(self.parentWindow, self.frame.x+1, self.frame.y+1, self.frame.width, self.frame.height)
        CCGraphics.initGraphics(self.window)
    end,
    updateAbsolutes = function(addX, addY)
        --print(addX .. ", " .. addY)
        self.frame.absoluteX = self.frame.absoluteX + addX
        self.frame.absoluteY = self.frame.absoluteY + addY
        for _,view in pairs(self.subviews) do view.updateAbsolutes(addX, addY) end
    end,
    deregisterSubview = function(view)
        if view.hasEvents and self.application ~= nil then
            self.application.deregisterObject(view.name)
            for _,v in pairs(view.subviews) do view.deregisterSubview(v) end
        end
    end,
    removeFromSuperview = function()
        if self.superview == nil then error("View already removed!", 2) end
        for k,v in ipairs(self.superview.subviews) do if v == self then
            table.remove(self.superview.subviews, k)
            self.superview.deregisterSubview(self)
            self.superview.draw()
            self.superview = nil
            return
        end end
    end
}