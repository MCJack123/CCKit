-- CCViewController.lua
-- CCKit
--
-- This file creates the CCViewController class, which is used in a CCWindow
-- to control the window contents. This can be subclassed to create custom
-- controllers for your application.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCView = require "CCView"

local function CCViewController()
    local retval = {}
    retval.view = {}
    retval.window = nil
    retval.application = nil
    function retval:loadView(win, app)
        --print("loaded view " .. win.name)
        self.window = win
        self.application = app
        local width, height = win.window.getSize()
        if self.window.showTitleBar then self.view = CCView(0, 1, width, height - 1)
        else self.view = CCView(0, 0, width, height) end
        self.view:setParent(self.window.window, self.application, self.window.name, self.window.frame.x, self.window.frame.y)
    end
    retval.superLoadView = retval.loadView
    function retval:viewDidLoad()
        -- override this to create custom subviews
    end
    function retval:dismiss()
        if self.view.subviews ~= nil then
            for k,v in pairs(self.view.subviews) do self.view:deregisterSubview(v) end
        end
    end
    return retval
end

return CCViewController