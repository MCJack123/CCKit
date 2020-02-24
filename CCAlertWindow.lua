-- CCAlertWindow.lua
-- CCKit
--
-- This file creates the CCAlertWindow class, which provides a way to show alert
-- dialogs to the user.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCButton = require "CCButton"
local CCTextView = require "CCTextView"
local CCViewController = require "CCViewController"
local CCWindow = require "CCWindow"

self = nil -- silences errors

local AlertViewController = class "AlertViewController" {extends = CCViewController} {
    __init = function(w, h, text)
        self.button2 = CCButton((w-4)/2, h-3, 4, 1)
        self.text = text
        self.w = w
        self.h = h
    end,
    viewDidLoad = function()
        local label = CCTextView(1, 1, self.w-2, self.h-2)
        label.setText(self.text)
        self.view.addSubview(label)
        self.button2.setText("OK")
        self.button2.setAction(self.window.close, self.window)
        self.button2.setHighlighted(true)
        self.view.addSubview(self.button2)
    end
}

local function CCAlertWindow(x, y, width, height, title, message, application)
    local retval = CCWindow(x, y, width, height)
    retval.maximizable = false
    retval.setTitle(title)
    local newvc = AlertViewController(width, height, message)
    retval.setViewController(newvc, application)
    return retval
end

return CCAlertWindow